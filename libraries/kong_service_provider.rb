# encoding: UTF-8
#
# Cookbook Name:: kong
# Library:: kong_service_provider
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015-2016 Xabier de Zuazo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/service'
require 'chef/provider/service/init'

# Internal `kong` cookbook classes and modules.
class KongCookbook
  # Chef service provider for the Kong init script.
  #
  # @example
  #   service 'kong' do
  #     provider KongCookbook::KongServiceProvider
  #     action :start
  #   end
  class KongServiceProvider < Chef::Provider::Service::Init
    # Gets Init Command.
    attr_reader :init_command

    # `KongServiceProvider` constructor.
    #
    # Sets init command, supported actions and status command.
    #
    # @param new_resource [Chef::Resource] New resource.
    # @param run_context [Chef::RunContext] Chef Run Context.
    def initialize(new_resource, run_context)
      super
      @init_command = 'kong'
      pid_file = node['kong']['pid_file']
      new_resource.supports(restart: true, reload: true, status: true)
      new_resource.status_command("kill -0 $(cat #{pid_file})")
    end

    # Checks if Kong scripts supports an action.
    #
    # Detects the action support dynamically calling the init command.
    #
    # @param action [String, Symbol] Action name.
    # @return [Boolean] `true` if the action is supported.
    # @example
    #   kong_supports_action?(:start) #=> true
    # @private
    def kong_supports_action?(action)
      cmd = shell_out("'#{init_command.delete("'")}' 2>&1 | grep -F #{action}")
      cmd.status.success?
    end

    # Defines a *Resource Requirement* to check that Kong init script is
    # installed.
    #
    # The *Requirement* raises a `Chef::Exceptions::Service` exception if not
    # met.
    #
    # @return void
    # @example
    #   all_actions_requirements
    # @private
    def all_actions_requirements
      requirements.assert(:all_actions) do |a|
        which_kong = shell_out("which '#{init_command.delete("'")}'")
        a.assertion { which_kong.status.success? }
        a.failure_message(
          Chef::Exceptions::Service, "#{init_command} does not exist!"
        )
      end
    end

    # Defines some *Resource Requirements* to check that Kong init script
    # supports some actions: `:start`, `:stop`, `:restart` and `:reload`.
    #
    # The *Requirement* raises a `Chef::Exceptions::Service` exception if not
    # met.
    #
    # @return void
    # @example
    #   actions_requirements
    # @private
    def actions_requirements
      [:start, :stop, :restart, :reload].each do |action|
        requirements.assert(action) do |a|
          a.assertion { kong_supports_action?(action) }
          a.failure_message(
            Chef::Exceptions::Service,
            "#{@new_resource}: kong command does not support #{action}!"
          )
          a.whyrun('Assuming service would be disabled.')
        end
      end
    end

    # Defines some *Resource Requirements* to check that Kong init script
    # is installed and supports the required actions.
    #
    # The *Requirement* raises a `Chef::Exceptions::Service` exception if not
    # met.
    #
    # @return void
    # @example
    #   define_resource_requirements
    # @api public
    def define_resource_requirements
      shared_resource_requirements

      all_actions_requirements
      actions_requirements
    end

    # Gets or sets the open files user limit.
    #
    # Reads the limits if no argument is given.
    #
    # @param limits [Array] Limits with the following format: *soft limit*,
    #   *hard limit*.
    # @example
    #   ulimit_nofile #=> [1024, 1024]
    #   ulimit_nofile(2048, 4096) #=> [1024, 1024]
    #   ulimit_nofile #=> [2048, 4096]
    # @return [Array] Previous limits.
    # @private
    def ulimit_nofile(limits = nil)
      cur_limits = Process.getrlimit(Process::RLIMIT_NOFILE)
      return cur_limits if limits.nil?
      Process.setrlimit(Process::RLIMIT_NOFILE, limits[0], limits[1])
      cur_limits
    rescue Errno::EPERM => e
      Chef::Log.warn("Cannot change open files limit: #{e}")
    end

    # Ensures that the open files limit is above a value.
    #
    # @param limit [Integer] Open files minimum value. The same value for both
    #   *soft* and *hard* limits.
    # @return [Array] Previous limits.
    # @private
    def ulimit_nofile_minimum(limit)
      cur_limit = ulimit_nofile
      new_limit = cur_limit.map { |x| [x, limit].max }
      if cur_limit[0] < new_limit[0] || cur_limit[1] < new_limit[1]
        ulimit_nofile(new_limit)
      end
      cur_limit
    end

    # Runs a block with the correct user limits required by Kong.
    #
    # @yield [] the block to run.
    # @return [Mixed] The value returned by the block.
    # @example
    #   def start_service
    #     run_within_ulimit { super }
    #   end
    # @api public
    def run_within_ulimit
      old_limit = ulimit_nofile_minimum(4096)
      value = yield
      ulimit_nofile(old_limit)
      value
    end

    # Starts the service using the correct user limits (`$ ulimit -n`).
    #
    # @return [Mixed] The `Chef::Provider::Service::Init#start_service` result.
    # @example
    #   start_service
    # @api public
    def start_service
      run_within_ulimit { super }
    end

    # Restarts the service using the correct user limits (`$ ulimit -n`).
    #
    # @return [Mixed] The `Chef::Provider::Service::Init#restart_service`
    #   result.
    # @example
    #   restart_service
    # @api public
    def restart_service
      run_within_ulimit { super }
    end
  end
end

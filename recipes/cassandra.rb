# encoding: UTF-8
#
# Cookbook Name:: kong
# Recipe:: cassandra
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015 Xabier de Zuazo
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

self.class.send(:include, ::KongCookbook::Helpers)

# Required by cassandra init script:
package 'initscripts' if node['platform_family'] == 'rhel'

package 'tar'

if node['cassandra']['config']['cluster_name'].nil?
  node.default['cassandra']['config']['cluster_name'] = 'kong'
  node.default['cassandra']['install_method'] = 'tarball'
  Chef::Log.warn(
    "Please set the `node['cassandra']['config']['cluster_name']` and "\
    "`node['cassandra']['install_method']` attributes. See the documentation "\
    'here: https://supermarket.chef.io/cookbooks/cassandra-dse'
  )
end

cassandra_port = cassandra_localhost_port
node.default['cassandra']['config']['native_transport_port'] = cassandra_port

include_recipe 'cassandra-dse'

# Wait until Cassandra is UP:

include_recipe 'netstat'

execute 'check "wait for cassandra" requirements' do
  command 'which netstat awk grep'
end

# @example
#   resource 'name' do
#     [...]
#     if node['kong']['manage_cassandra']
#       notifies :run, 'ruby_block[wait for cassandra]'
#     end
#     notifies :restart, 'service[kong]'
#  end
wait = node['kong']['wait_for_cassandra']
delay = 5

ruby_block 'wait for cassandra' do
  retries wait.is_a?(Integer) ? wait / delay : 0
  retry_delay delay
  block do
    # Sometimes `lsof` does not work properly inside docker
    # shell_out!("lsof -itcp:#{cassandra_port}")
    Mixlib::ShellOut.new(
      "netstat -ptln | awk '$4 ~ /:#{cassandra_port}$/' | grep -F :"
    ).run_command.error!
  end
  action :run
  only_if { wait.is_a?(Integer) }
end

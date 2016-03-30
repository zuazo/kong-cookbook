# encoding: UTF-8
#
# Cookbook Name:: kong
# Library:: cookbook_helpers
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015-2016 Xabier de Zuazo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Internal `kong` cookbook classes and modules.
class KongCookbook
  # Some helpers used in the `kong` cookbook.
  #
  # @example
  #   self.class.send(:include, ::KongCookbook::Helpers)
  #   self.manage_ssl_certificate #=> true
  module Helpers
    # Gets some substitutions to apply to some attribute values using
    # `Kernel.format`.
    #
    # @return [Hash] substitution list.
    # @example
    #   self.substitutions #=> {:version=>"0.4.2"}
    # @api public
    def substitutions
      { version: node['kong']['version'] }
    end

    # Gets the package name from `node['kong']['package_file']` after making
    # substitutions.
    #
    # @return [String] package name.
    # @example
    #   self.package_name #=> "kong-0.4.2.squeeze_all.deb"
    # @see #substitutions
    # @api public
    def package_name
      format(node['kong']['package_file'], substitutions)
    end

    # Gets the package full URL after making substitutions.
    #
    # @return [String] URL.
    # @example
    #   self.package_url
    #     #=> "https://github.com/Mashape/kong/releases/download/0.4.2/"\
    #     #   "kong-0.4.2.squeeze_all.deb"
    # @see #substitutions
    # @api public
    def package_url
      format("#{node['kong']['mirror']}#{package_name}", substitutions)
    end

    # Gets package file full path in disk.
    #
    # @return [String] package path.
    # @example
    #   self.package_path #=> "/var/chef/cache/kong-0.4.2.squeeze_all.deb"
    # @api public
    def package_path
      ::File.join(Chef::Config[:file_cache_path], package_name)
    end

    # Calculates whether an object should be managed by the cookbook or not.
    #
    # This is used to calculate the `node['kong']['manage_cassandra']` and
    # `node['kong']['manage_ssl_certificate']` attributes.
    #
    # @param obj [String] the name of the object to manage.
    # @return [Boolean] whether the object should be managed by the cookbook.
    # @example
    #   self.calculate_management('cassandra') #=> true
    # @private
    def calculate_management(obj)
      unless node['kong']["manage_#{obj}"].nil?
        return node['kong']["manage_#{obj}"]
      end
      node.default['kong']["manage_#{obj}"] = send("calculate_manage_#{obj}")
    end

    # Gets Cassandra properties from node attributes from
    # `node['kong']['kong.yml']['cassandra']`
    #
    # @return [Mash] Cassandra properties.
    # @example
    #   self.cassandra_properties
    #     #=> {"hosts"=>"localhost:9042", "timeout"=>1000, "keyspace"=>"kong",
    #     #    "keepalive"=>60000}
    # @api public
    def cassandra_properties
      node['kong']['kong.yml']['cassandra']
    end

    # Gets the Cassandra hosts from Node attributes.
    #
    # @return [Array] hosts list.
    # @example
    #   self.cassandra_hosts #=> ["localhost:9042", "db.example.com:9042"]
    # @api public
    def cassandra_hosts
      cassandra_properties['contact_points']
    end

    # Gets the Cassandras hosts in local machine searching in
    # `['cassandra']['properties']['host']` Node attribute.
    #
    # @return [Array] hosts list.
    # @example
    #   self.cassandra_localhosts #=> ["localhost:9042"]
    # @api public
    def cassandra_localhosts
      cassandra_hosts.select do |x|
        %w(localhost 127.0.0.1).include?(x.split(':', 2)[0])
      end
    end

    # Gets the Cassandra server address to be installed in local machine.
    #
    # Reads the data from `['cassandra']['properties']['host']` Node attribute.
    #
    # @return [String] the local server address in the `'host:port'` format.
    # @example
    #   self.cassandra_localhost_host #=> "localhost:9042"
    # @api public
    def cassandra_localhost_host
      localhosts = cassandra_localhosts
      localhosts.empty? ? cassandra_hosts.first : localhosts.first
    end

    # Gets the local Cassandra server port number.
    #
    # Reads the data from `['cassandra']['properties']['host']` Node attribute.
    #
    # @return [String] the Cassandra server port number.
    # @example
    #   self.cassandra_localhost_port #=> "9042"
    # @api public
    def cassandra_localhost_port
      cassandra_localhost_host.split(':', 2)[1] || '9042'
    end

    # Calculates whether the Cassandra installation should be managed by the
    # cookbook or not based only on the **Kong configuration**.
    #
    # Returns `true` if the `properties['contact_points']` value includes a
    # *localhost* machine: `'localhost'` or `'127.0.0.1'`.
    #
    # @return [Boolean] `true` if Cassandra should be installed locally.
    # @example
    #   self.calculate_manage_cassandra #=> true
    # @api public
    def calculate_manage_cassandra
      hosts = [cassandra_hosts].flatten
      hosts = hosts.map { |x| x.split(':', 2).first }
      !(hosts & %w(localhost 127.0.0.1)).empty?
    end

    # Calculates whether the Cassandra installation should be managed by the
    # cookbook or should not based on the **Node attributes* and the
    # **Kong configuration**.
    #
    # Tries to read the value from `node['kong']['manage_cassandra']` and
    # calculates it if not set.
    #
    # @return [Boolean] `true` if Cassandra should be installed locally.
    # @example
    #   self.manage_cassandra #=> true
    # @see #calculate_manage_cassandra
    # @api public
    def manage_cassandra
      calculate_management('cassandra')
    end

    # Calculates whether the SSL certificate should be managed by the cookbook
    # or should not based only on the **Kong configuration**.
    #
    # Returns `true` if both the `node['kong']['kong.yml']['ssl_cert_path']` and
    # `node['kong']['kong.yml']['ssl_key_path']` are set.
    #
    # @return [Boolean] `true` if SSL certificate should be managed.
    # @example
    #   self.calculate_manage_ssl_certificate #=> true
    # @api public
    def calculate_manage_ssl_certificate
      node['kong']['kong.yml']['ssl_cert_path'].nil? ||
        node['kong']['kong.yml']['ssl_key_path'].nil?
    end

    # Calculates whether the SSL certificate should be managed by the cookbook
    # or should not based on the **Node attributes* and the
    # **Kong configuration**.
    #
    # Tries to read the value from `node['kong']['manage_ssl_certificate']` and
    # calculates it if not set.
    #
    # @return [Boolean] `true` if SSL certificate should be managed.
    # @example
    #   self.manage_ssl_certificate #=> true
    # @see #calculate_manage_ssl_certificate
    # @api public
    def manage_ssl_certificate
      calculate_management('ssl_certificate')
    end
  end
end

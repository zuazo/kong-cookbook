# encoding: UTF-8
#
# Cookbook Name:: kong
# Attributes:: configuration
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

default['kong']['kong.yml'] = Mash.new

# Specify which database to use:
default['kong']['kong.yml']['database'] = 'cassandra'

# Cassandra configuration:
default_cassandra = default['kong']['kong.yml']['cassandra']
default_cassandra['contact_points'] = %w(localhost:9042)
default_cassandra['keyspace'] = 'kong'
default_cassandra['timeout'] = 5000

# The path to the SSL certificate and key that Kong will use when listening on
# the `https` port:
default['kong']['kong.yml']['ssl_cert_path'] = nil
default['kong']['kong.yml']['ssl_key_path'] = nil
default['kong']['kong.yml']['template']['cookbook'] = 'kong'

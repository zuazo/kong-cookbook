# encoding: UTF-8
#
# Cookbook Name:: kong
# Recipe:: _configuration
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
recipe = self

if manage_ssl_certificate
  cert = ssl_certificate 'kong' do
    namespace node['kong']
    notifies :run, 'ruby_block[wait for cassandra]' if recipe.manage_cassandra
    notifies :restart, 'service[kong]'
  end

  node.default['kong']['kong.yml']['ssl_key_path'] = cert.key_path
  node.default['kong']['kong.yml']['ssl_cert_path'] = cert.cert_path
end

template '/etc/kong/kong.yml' do
  source 'kong.yml.erb'
  cookbook node['kong']['kong.yml']['template']['cookbook']
  mode 00644
  variables(
    manage_ssl_certificate: recipe.manage_ssl_certificate,
    config: node['kong']['kong.yml']
  )
  notifies :run, 'ruby_block[wait for cassandra]' if recipe.manage_cassandra
  notifies :restart, 'service[kong]'
end

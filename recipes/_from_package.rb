# encoding: UTF-8
#
# Cookbook Name:: kong
# Recipe:: _from_package
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

self.class.send(:include, ::KongCookbook::Helpers)
recipe = self

node['kong']['required_packages'].each do |pkg|
  package pkg do
    action :install
  end
end

remote_file package_name do
  path recipe.package_path
  source recipe.package_url
  mode 00644
  checksum node['kong']['package_checksum']
end

case node['platform_family']
when 'debian'
  dpkg_package 'kong' do
    source recipe.package_path
    version node['kong']['version']
    action :install
  end
when 'rhel', 'fedora'
  yum_package 'kong' do
    source recipe.package_path
    version node['kong']['version']
    options '--nogpgcheck'
    action :install
  end
else raise "Unsupported platform family: #{node['platform_family']}"
end

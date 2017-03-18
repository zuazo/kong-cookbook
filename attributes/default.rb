# encoding: UTF-8
#
# Cookbook Name:: kong
# Attributes:: default
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

default['kong']['version'] = '0.8.2'
default['kong']['mirror'] =
  'https://github.com/Mashape/kong/releases/download/%{version}/'

case node['platform_family']
when 'debian'
  case node['platform']
  when 'debian'
    default['kong']['required_packages'] =
      %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq)
    case node['platform_version'].to_i
    when 6
      default['kong']['version'] = '0.7.0' # version 0.8.0 is not supported
      default['kong']['package_file'] = 'kong-%{version}.squeeze_all.deb'
      default['kong']['package_checksum'] =
        '42b247465a9380c26ae7fbb2bcd2f7bfc0622c2740e6ac4e05e4b8106618b1db'
    when 7
      default['kong']['package_file'] = 'kong-%{version}.wheezy_all.deb'
      default['kong']['package_checksum'] =
        '1bdf804482328dabc15d862be61b6fa8831ca2aea3811b167d4083475d2f86d9'
    when 8
      default['kong']['package_file'] = 'kong-%{version}.jessie_all.deb'
      default['kong']['package_checksum'] =
        'a390008a0765dd061b64e4877eceb4a50c2dc59736c2883b4d9a5927d0fbd470'
    else raise "Unsupported Debian version: #{node['platform_version']}"
    end
  when 'ubuntu'
    default['kong']['required_packages'] =
      %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq)
    case node['platform_version'].to_f
    when 12.04
      default['kong']['package_file'] = 'kong-%{version}.precise_all.deb'
      default['kong']['package_checksum'] =
        'f54e32f5f1886b820ed02e57b1dcda07f341c76b65b4626c8e3383fcea3e786e'
    when 14.04
      default['kong']['package_file'] = 'kong-%{version}.trusty_all.deb'
      default['kong']['package_checksum'] =
        '93d723580481835026bd1666f9bc564485913b3976a45f06ebfaa6c9bd47a554'
    when 15.04
      default['kong']['package_file'] = 'kong-%{version}.vivid_all.deb'
      default['kong']['package_checksum'] =
        '4c5a7c4ef3d5c1bf34f51ed2743febc863013182be04b992239eb42bb7eb25ef'
    when 16.04
      default['kong']['version'] = '0.8.3' # version 0.8.2 is not supported
      default['kong']['package_file'] = 'kong-%{version}.xenial_all.deb'
      default['kong']['package_checksum'] =
        '4e2fcdaaee8983176425af72bbb47a72164249407e04695c55d7bc67820bb6d1'
    else raise "Unsupported Ubuntu version: #{node['platform_version']}"
    end
  end
when 'rhel'
  default['kong']['required_packages'] = %w(sudo)
  case node['platform']
  when 'amazon'
    default['kong']['package_file'] = 'kong-%{version}.aws.rpm'
    default['kong']['package_checksum'] =
      '2be206f8c27b44670c5c4e1306de4821c4951a024c5328ab04f39740ee59a99b'
  else
    default['kong']['package_file'] =
      "kong-%{version}.el#{node['platform_version'].to_i}.noarch.rpm"
    case node['platform_version'].to_i
    when 5
      default['kong']['package_checksum'] =
        'e85dceac3121b1ecd013ad4aa79c63c1ac09af8944951df28426602ea256f809'
    when 6
      default['kong']['package_checksum'] =
        '9df585771354e8076ab9247be05ef3bace33a618559521551dc7b9061defe4cc'
    when 7
      default['kong']['package_checksum'] =
        'cf11e394951ce08da71d9766716a022d6eec525b2a4f2dfc67a165266b61cb75'
    else raise "Unsupported CentOS version: #{node['platform_version']}"
    end
  end
when 'fedora'
  default['kong']['required_packages'] = %w(sudo)
  default['kong']['package_file'] = 'kong-%{version}.el7.noarch.rpm'
  default['kong']['package_checksum'] =
    'cf11e394951ce08da71d9766716a022d6eec525b2a4f2dfc67a165266b61cb75'
else raise "Unsupported platform family: #{node['platform_family']}"
end

default['kong']['manage_ssl_certificate'] = nil
default['kong']['wait_for_cassandra'] = 300
default['kong']['manage_cassandra'] = nil

if Gem::Requirement.new('>= 0.6.0')
                   .satisfied_by?(Gem::Version.new(node['kong']['version']))
  default['kong']['pid_file'] = '/usr/local/kong/nginx.pid'
else
  default['kong']['pid_file'] = '/usr/local/kong/kong.pid'
end

default['kong']['cert_path'] = '/usr/local/kong/ssl/kong-default.crt'
default['kong']['key_path'] = '/usr/local/kong/ssl/kong-default.key'

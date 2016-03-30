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

default['kong']['version'] = '0.7.0'
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
      default['kong']['package_file'] = 'kong-%{version}.squeeze_all.deb'
      default['kong']['package_checksum'] =
        '42b247465a9380c26ae7fbb2bcd2f7bfc0622c2740e6ac4e05e4b8106618b1db'
    when 7
      default['kong']['package_file'] = 'kong-%{version}.wheezy_all.deb'
      default['kong']['package_checksum'] =
        'e1b08a3f4b6dc970f73821d015771f7b820c2b1d51d68359056bf6352a4347e0'
    when 8
      default['kong']['package_file'] = 'kong-%{version}.jessie_all.deb'
      default['kong']['package_checksum'] =
        'e34166fe1616819ebae99f94b131335f905b2119ef4ba10e9ecf1d077a33b9dc'
    else raise "Unsupported Debian version: #{node['platform_version']}"
    end
  when 'ubuntu'
    default['kong']['required_packages'] =
      %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq)
    case node['platform_version'].to_f
    when 12.04
      default['kong']['package_file'] = 'kong-%{version}.precise_all.deb'
      default['kong']['package_checksum'] =
        '9583ec05c4190d9c9b796d33559c3c9bfbc3e94619d636bbad825feb57984e5e'
    when 14.04
      default['kong']['package_file'] = 'kong-%{version}.trusty_all.deb'
      default['kong']['package_checksum'] =
        'cbf79d45ccdcbd5c4b988e84526aa2b752c1cd4084004c50c8aa131d74edfd67'
    when 15.04
      default['kong']['package_file'] = 'kong-%{version}.vivid_all.deb'
      default['kong']['package_checksum'] =
        'b6e2b571f90cb2974e6dbbd46e9389b968d1f9d36463514e0e4a8890891dd426'
    else raise "Unsupported Ubuntu version: #{node['platform_version']}"
    end
  end
when 'rhel'
  default['kong']['required_packages'] = %w(sudo)
  default['kong']['package_file'] =
    "kong-%{version}.el#{node['platform_version'].to_i}.noarch.rpm"
  case node['platform_version'].to_i
  when 5
    default['kong']['package_checksum'] =
      'c881298d75bdcda380cf03e0d75b72238e997ce1d7035b1755a8a79595721386'
  when 6
    default['kong']['package_checksum'] =
      '025807534a9cb9776af998b61165f9c4ed9707c01a249721843e4f4db0fa8982'
  when 7
    default['kong']['package_checksum'] =
      '34d145ec8195ed644df52ea7e5ff96e14912804766f89cee1738ea04dcfbd7ac'
  else raise "Unsupported CentOS version: #{node['platform_version']}"
  end
when 'fedora'
  default['kong']['required_packages'] = %w(sudo)
  default['kong']['package_file'] = 'kong-%{version}.el7.noarch.rpm'
  default['kong']['package_checksum'] =
    '34d145ec8195ed644df52ea7e5ff96e14912804766f89cee1738ea04dcfbd7ac'
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

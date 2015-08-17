# encoding: UTF-8
#
# Cookbook Name:: kong
# Attributes:: default
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

default['kong']['version'] = '0.4.2'
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
        'ce82a4393eb5d463a5ea79b3161af011ed6309be723f97426a6068154674a8a8'
    when 7
      default['kong']['package_file'] = 'kong-%{version}.wheezy_all.deb'
      default['kong']['package_checksum'] =
        'f8bfd156a62816b3321e4097ad71075e8cd272c1399460fe49bb4a458a2d4f8e'
    when 8
      default['kong']['package_file'] = 'kong-%{version}.jessie_all.deb'
      default['kong']['package_checksum'] =
        'd79a41c9e9779d215df15e50083de68275fea4c3584b8290d2748bf2e9a489d3'
    else fail "Unsupported Debian version: #{node['platform_version']}"
    end
  when 'ubuntu'
    default['kong']['required_packages'] =
      %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq)
    case node['platform_version'].to_f
    when 12.04
      default['kong']['package_file'] = 'kong-%{version}.precise_all.deb'
      default['kong']['package_checksum'] =
        'ead80ce722af8b2af722cf54b9e1b46438a8e9e047499e7ab2d26bc2498e64b3'
    when 14.04
      default['kong']['package_file'] = 'kong-%{version}.trusty_all.deb'
      default['kong']['package_checksum'] =
        '0740e2169fed5f63d4dda872fe3f74eb8d719e8ec756f16a0c87c1250504aef9'
    when 15.04
      default['kong']['package_file'] = 'kong-%{version}.vivid_all.deb'
      default['kong']['package_checksum'] =
        'a8184e4a1260700a0a7ba7e7bdd57c3bef5ebeb63395b5826efc1217a81de96c'
    else fail "Unsupported Ubuntu version: #{node['platform_version']}"
    end
  end
when 'rhel'
  default['kong']['required_packages'] = %w(sudo)
  default['kong']['package_file'] =
    "kong-%{version}.el#{node['platform_version'].to_i}.noarch.rpm"
  case node['platform_version'].to_i
  when 5
    default['kong']['package_checksum'] =
      '48fdac533510abb60847208ec46c5343b7a3eae63bb05bc879c74b0b793ac24c'
  when 6
    default['kong']['package_checksum'] =
      '2a924ad5801856f84490fea63f1214f0083aa1b899236e33e5c0f38675d9eb22'
  when 7
    default['kong']['package_checksum'] =
      'abd88ff4af7c734f29993290d1733a34c0af34756185f3d3d8b927ecdb9ccc74'
  else fail "Unsupported CentOS version: #{node['platform_version']}"
  end
when 'fedora'
  default['kong']['required_packages'] = %w(sudo)
  default['kong']['package_file'] = 'kong-%{version}.el7.noarch.rpm'
  default['kong']['package_checksum'] =
    'abd88ff4af7c734f29993290d1733a34c0af34756185f3d3d8b927ecdb9ccc74'
else fail "Unsupported platform family: #{node['platform_family']}"
end

default['kong']['manage_ssl_certificate'] = nil
default['kong']['wait_for_cassandra'] = 300
default['kong']['manage_cassandra'] = nil

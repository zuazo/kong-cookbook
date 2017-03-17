# encoding: UTF-8
#
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

require_relative '../spec_helper'

describe 'kong::_from_package', order: :random do
  version = '0.8.2'

  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }
  let(:mirror) { 'https://github.com/Mashape/kong/releases/download' }

  shared_examples 'test platform' do |platform, info|
    platform, platform_version = platform.split('@', 2)
    package = info[:package]
    requirements = info[:requirements] || []
    package_version = info[:version] || version

    context "on #{platform.capitalize} #{platform_version}" do
      let(:chef_runner) do
        ChefSpec::SoloRunner.new(platform: platform, version: platform_version)
      end
      let(:package_source) { "#{mirror}/#{package_version}/#{package}" }
      let(:package_path) do
        ::File.join(Chef::Config[:file_cache_path], package)
      end

      requirements.each do |requirement|
        it "installs #{requirement} package" do
          expect(chef_run).to install_package(requirement)
        end
      end # requirements each

      it 'downloads the kong package' do
        expect(chef_run).to create_remote_file(package)
          .with_path(package_path)
          .with_source([package_source])
          .with_mode(00644)
          .with_checksum(node['kong']['package_checksum'])
      end

      it 'sets file checksum' do
        chef_run
        expect(node['kong']['package_checksum']).to be_a(String)
      end

      it 'installs the kong package' do
        if node['platform_family'] == 'debian'
          expect(chef_run).to install_dpkg_package('kong')
            .with_source(package_path)
            .with_version(package_version)
        else
          expect(chef_run).to install_yum_package('kong')
            .with_source(package_path)
            .with_version(package_version)
        end
      end
    end # context on platform version
  end # shared examples test platform

  it 'installs sudo package' do
    expect(chef_run).to install_package('sudo')
  end

  debian_requirements = %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq)
  centos_requirements = %w(sudo)

  include_examples 'test platform', 'debian@6.0.5',
                   # Next versions are not available for Debian 6:
                   version: '0.7.0',
                   package: 'kong-0.7.0.squeeze_all.deb',
                   requirements: debian_requirements

  include_examples 'test platform', 'debian@7.0',
                   package: "kong-#{version}.wheezy_all.deb",
                   requirements: debian_requirements

  include_examples 'test platform', 'debian@8.0',
                   package: "kong-#{version}.jessie_all.deb",
                   requirements: debian_requirements

  include_examples 'test platform', 'ubuntu@12.04',
                   package: "kong-#{version}.precise_all.deb",
                   requirements: debian_requirements

  include_examples 'test platform', 'ubuntu@14.04',
                   package: "kong-#{version}.trusty_all.deb",
                   requirements: debian_requirements

  include_examples 'test platform', 'ubuntu@15.04',
                   package: "kong-#{version}.vivid_all.deb",
                   requirements: debian_requirements

  include_examples 'test platform', 'ubuntu@16.04',
                   # Earlier versions are not available for Ubuntu 16:
                   version: '0.8.3',
                   package: 'kong-0.8.3.xenial_all.deb',
                   requirements: debian_requirements

  include_examples 'test platform', 'centos@5.10',
                   package: "kong-#{version}.el5.noarch.rpm",
                   requirements: centos_requirements

  include_examples 'test platform', 'centos@6.0',
                   package: "kong-#{version}.el6.noarch.rpm",
                   requirements: centos_requirements

  include_examples 'test platform', 'centos@7.0',
                   package: "kong-#{version}.el7.noarch.rpm",
                   requirements: centos_requirements

  include_examples 'test platform', 'amazon@2015.09',
                   package: "kong-#{version}.aws.rpm",
                   requirements: centos_requirements
end

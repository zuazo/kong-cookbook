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
  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }
  version = '0.7.0'
  let(:mirror) do
    "https://github.com/Mashape/kong/releases/download/#{version}/"
  end

  it 'installs sudo package' do
    expect(chef_run).to install_package('sudo')
  end

  distro_packages = {
    'debian@6.0.5' => {
      requirements: %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq),
      file: "kong-#{version}.squeeze_all.deb"
    },
    'debian@7.0' => {
      requirements: %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq),
      file: "kong-#{version}.wheezy_all.deb"
    },
    'debian@8.0' => {
      requirements: %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq),
      file: "kong-#{version}.jessie_all.deb"
    },
    'ubuntu@12.04' => {
      requirements: %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq),
      file: "kong-#{version}.precise_all.deb"
    },
    'ubuntu@14.04' => {
      requirements: %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq),
      file: "kong-#{version}.trusty_all.deb"
    },
    'ubuntu@15.04' => {
      requirements: %w(sudo netcat lua5.1 openssl libpcre3 dnsmasq),
      file: "kong-#{version}.vivid_all.deb"
    },
    'centos@5.10' => {
      requirements: %w(sudo),
      file: "kong-#{version}.el5.noarch.rpm"
    },
    'centos@6.0' => {
      requirements: %w(sudo),
      file: "kong-#{version}.el6.noarch.rpm"
    },
    'centos@7.0' => {
      requirements: %w(sudo),
      file: "kong-#{version}.el7.noarch.rpm"
    },
    'amazon@2015.09' => {
      requirements: %w(sudo),
      file: "kong-#{version}.aws.rpm"
    }
  }

  distro_packages.each do |distro, packages|
    platform, platform_version = distro.split('@', 2)

    context "on #{platform.capitalize} #{platform_version}" do
      let(:chef_runner) do
        ChefSpec::SoloRunner.new(platform: platform, version: platform_version)
      end
      let(:package_source) { "#{mirror}#{packages[:file]}" }
      let(:package_path) do
        ::File.join(Chef::Config[:file_cache_path], packages[:file])
      end

      packages[:requirements].each do |requirement|
        it "installs #{requirement} package" do
          expect(chef_run).to install_package(requirement)
        end
      end # requirements each

      it 'downloads the kong package' do
        expect(chef_run).to create_remote_file(packages[:file])
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
            .with_version(version)
        else
          expect(chef_run).to install_yum_package('kong')
            .with_source(package_path)
            .with_version(version)
        end
      end
    end # context on platform version
  end # distro packages each
end

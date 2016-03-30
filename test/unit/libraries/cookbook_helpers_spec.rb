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
require 'cookbook_helpers'

# A recipe which includes EncryptedAttributesHelpers
class FakeRecipe
  include KongCookbook::Helpers
end

describe KongCookbook::Helpers, order: :random do
  let(:helpers) { FakeRecipe.new }
  let(:node) { Chef::Node.new }
  let(:version) { '1.0.0' }
  let(:mirror) { 'http://example.com/' }
  let(:cassandra_hosts) { %w(A:9042 B:9042 C:9042) }
  let(:cassandra_properties) { Mash.new(contact_points: cassandra_hosts) }
  before do
    Chef::Config[:file_cache_path] = '/tmp'
    allow(helpers).to receive(:node).and_return(node)
    node.set['kong']['version'] = version
    node.set['kong']['package_file'] = 'kong_package_%{version}'
    node.set['kong']['mirror'] = mirror
    node.set['kong']['kong.yml']['cassandra'] = cassandra_properties
  end

  context '#substitutions' do
    subject { helpers.substitutions }
    it { should eq(version: version) }
  end # context #substitutions

  context '#package_name' do
    subject { helpers.package_name }
    it { should include(version) }
    it { should eq("kong_package_#{version}") }
  end # context #package_name

  context '#package_url' do
    subject { helpers.package_url }
    it { should eq("#{mirror}kong_package_#{version}") }
  end # context #package_url

  context '#package_path' do
    subject { helpers.package_path }
    it { should include(Chef::Config[:file_cache_path]) }
    it { should eq("/tmp/kong_package_#{version}") }
  end # context #package_path

  context '#cassandra_properties' do
    subject { helpers.cassandra_properties }
    it { should eq(cassandra_properties) }
  end # context #cassandra_properties

  context '#cassandra_hosts' do
    subject { helpers.cassandra_hosts }
    it { should eq(cassandra_hosts) }
  end # context #cassandra_hosts

  context '#cassandra_localhosts' do
    subject { helpers.cassandra_localhosts }
    let(:cassandra_hosts) { %w(A:1234 localhost:5678 127.0.0.1:9012 Z:3456) }
    it { should eq(%w(localhost:5678 127.0.0.1:9012)) }
  end # context #cassandra_localhosts

  context '#cassandra_localhost_host' do
    subject { helpers.cassandra_localhost_host }

    context 'with a localhost server' do
      let(:cassandra_hosts) { %w(A:1234 localhost:5678 127.0.0.1:9012 Z:3456) }
      it { should eq('localhost:5678') }
    end

    context 'without a localhost server' do
      let(:cassandra_hosts) { %w(A:1234 Z:3456) }
      it { should eq('A:1234') }
    end
  end # context #cassandra_localhost_hosts

  context '#cassandra_localhost_port' do
    subject { helpers.cassandra_localhost_port }

    context 'with a localhost server' do
      let(:cassandra_hosts) { %w(A:1234 localhost:5678 127.0.0.1:9012 Z:3456) }
      it { should eq('5678') }
    end

    context 'without a localhost server' do
      let(:cassandra_hosts) { %w(A:1234 B:5678) }
      it { should eq('1234') }
    end

    context 'without ports' do
      let(:cassandra_hosts) { %w(A B) }
      it { should eq('9042') }
    end
  end # context #cassandra_localhost_port

  context '#calculate_manage_cassandra' do
    subject { helpers.calculate_manage_cassandra }

    context 'with localhost' do
      let(:cassandra_hosts) { 'localhost:9042' }
      it { should be(true) }
    end

    context 'with 127.0.0.1' do
      let(:cassandra_hosts) { '127.0.0.1:9042' }
      it { should be(true) }
    end

    context 'with one extarn host' do
      let(:cassandra_hosts) { 'external:9042' }
      it { should be(false) }
    end

    context 'with multiple hosts including localhost' do
      let(:cassandra_hosts) { %w(external:9042 localhost:9042) }
      it { should be(true) }
    end

    context 'with multiple hosts including 127.0.0.1' do
      let(:cassandra_hosts) { %w(external:9042 127.0.0.1:9042) }
      it { should be(true) }
    end

    context 'with multiple hosts external' do
      let(:cassandra_hosts) { %w(hostA:9042 hostB:9042) }
      it { should be(false) }
    end
  end # context #calculate_manage_cassandra

  context '#manage_cassandra' do
    subject { helpers.manage_cassandra }

    context 'by default' do
      it 'calls #calculate_manage_cassandra' do
        expect(helpers).to receive(:calculate_manage_cassandra).once
          .and_return('calculate_manage_cassandra')
        subject
      end

      it 'returns #calculate_manage_cassandra result' do
        allow(helpers).to receive(:calculate_manage_cassandra)
          .and_return('calculate_manage_cassandra')
        expect(subject).to eq('calculate_manage_cassandra')
      end
    end

    context 'with manage cassandra enabled' do
      before { node.set['kong']['manage_cassandra'] = true }

      it { should eq(true) }

      it 'does not call calculate_manage_cassandra' do
        expect(helpers).to_not receive(:calculate_manage_cassandra)
        subject
      end
    end

    context 'with manage cassandra disabled' do
      before { node.set['kong']['manage_cassandra'] = false }

      it { should eq(false) }

      it 'does not call calculate_manage_cassandra' do
        expect(helpers).to_not receive(:calculate_manage_cassandra)
        subject
      end
    end
  end # context #manage_cassandra

  context '#calculate_manage_ssl_certificate' do
    subject { helpers.calculate_manage_ssl_certificate }

    context 'by default' do
      it { should be(true) }
    end

    context 'with cert path set' do
      before { node.set['kong']['kong.yml']['ssl_cert_path'] = 'cert' }
      it { should be(true) }
    end

    context 'with key path set' do
      before { node.set['kong']['kong.yml']['ssl_key_path'] = 'key' }
      it { should be(true) }
    end

    context 'with cert path and key path set' do
      before do
        node.set['kong']['kong.yml']['ssl_key_path'] = 'key'
        node.set['kong']['kong.yml']['ssl_cert_path'] = 'cert'
      end
      it { should be(false) }
    end
  end # context calculate_manage_ssl_certificate

  context '#manage_ssl_certificate' do
    subject { helpers.manage_ssl_certificate }

    context 'by default' do
      it 'calls #calculate_manage_ssl_certificate' do
        expect(helpers).to receive(:calculate_manage_ssl_certificate).once
          .and_return('calculate_manage_ssl_certificate')
        subject
      end

      it 'returns #calculate_manage_ssl_certificate result' do
        allow(helpers).to receive(:calculate_manage_ssl_certificate)
          .and_return('calculate_manage_ssl_certificate')
        expect(subject).to eq('calculate_manage_ssl_certificate')
      end
    end

    context 'with manage ssl_certificate enabled' do
      before { node.set['kong']['manage_ssl_certificate'] = true }

      it { should eq(true) }

      it 'does not call calculate_manage_ssl_certificate' do
        expect(helpers).to_not receive(:calculate_manage_ssl_certificate)
        subject
      end
    end

    context 'with manage ssl_certificate disabled' do
      before { node.set['kong']['manage_ssl_certificate'] = false }

      it { should eq(false) }

      it 'does not call calculate_manage_ssl_certificate' do
        expect(helpers).to_not receive(:calculate_manage_ssl_certificate)
        subject
      end
    end
  end # context #manage_ssl_certificate
end

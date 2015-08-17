# encoding: UTF-8
#
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

require_relative '../spec_helper'

describe 'kong::cassandra', order: :random do
  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }
  before { allow(Chef::Log).to receive(:warn) }

  context 'on Ubuntu' do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04')
    end

    it 'does not install initscripts package' do
      expect(chef_run).to_not install_package('initscripts')
    end

    it 'installs tar package' do
      expect(chef_run).to install_package('tar')
    end
  end

  context 'on CentOS' do
    let(:chef_runner) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6')
    end

    it 'installs initscripts package' do
      expect(chef_run).to install_package('initscripts')
    end

    it 'installs tar package' do
      expect(chef_run).to install_package('tar')
    end
  end

  context 'when cassandra cluster name is not set' do
    it 'prints a Chef warning' do
      expect(Chef::Log).to receive(:warn).with(/Please set the .*cluster_name/)
      chef_run
    end

    it 'set cluster name' do
      chef_run
      expect(node['cassandra']['cluster_name']).to eq('kong')
    end

    it 'set install method to "tarball"' do
      chef_run
      expect(node['cassandra']['install_method']).to eq('tarball')
    end

    it 'enables restart notifications' do
      chef_run
      expect(node['cassandra']['notify_restart']).to eq(true)
    end
  end

  context 'when cassandra cluster name is set' do
    before { node.set['cassandra']['cluster_name'] = 'cluster1' }

    it 'does not print a Chef warning' do
      expect(Chef::Log)
        .not_to receive(:warn).with(/Please set the .*cluster_name/)
      chef_run
    end
  end

  it 'includes cassandra-dse recipe' do
    expect(chef_run).to include_recipe('cassandra-dse')
  end

  context 'when waiting for cassandra to start' do
    it 'includes netstat recipe' do
      expect(chef_run).to include_recipe('netstat')
    end

    it 'checks requirements for "wait for cassandra"' do
      expect(chef_run).to run_execute('check "wait for cassandra" requirements')
        .with_command('which netstat awk grep')
    end

    it 'waits for cassandra' do
      expect(chef_run).to run_ruby_block('wait for cassandra')
        .with_retries(60)
        .with_retry_delay(5)
    end

    context 'waiting for 30 seconds' do
      before { node.set['kong']['wait_for_cassandra'] = 30 }

      it 'retries 6 times' do
        expect(chef_run).to run_ruby_block('wait for cassandra')
          .with_retries(6)
          .with_retry_delay(5)
      end
    end # context waiting for 30 seconds

    context 'with wait disabled' do
      before { node.set['kong']['wait_for_cassandra'] = false }

      it 'does not wait for cassandra' do
        expect(chef_run).to_not run_ruby_block('wait for cassandra')
      end
    end # context with wait disabled
  end # context when waiting for cassandra to start
end

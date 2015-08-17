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

describe 'kong::default', order: :random do
  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }
  let(:set_cassandra_properties) do
    node.set['kong']['kong.yml']['databases_available']['cassandra']\
      ['properties']
  end

  it 'includes cassandra recipe' do
    expect(chef_run).to include_recipe('kong::cassandra')
  end

  context 'with manage cassandra enabled' do
    before { node.set['kong']['manage_cassandra'] = true }

    it 'includes cassandra recipe' do
      expect(chef_run).to include_recipe('kong::cassandra')
    end
  end

  context 'with manage cassandra disabled' do
    before { node.set['kong']['manage_cassandra'] = false }

    it 'does not include cassandra recipe' do
      expect(chef_run).to_not include_recipe('kong::cassandra')
    end
  end

  context 'with a local cassandra server' do
    before { set_cassandra_properties['hosts'] = %w(localhost:9042) }

    it 'includes cassandra recipe' do
      expect(chef_run).to include_recipe('kong::cassandra')
    end
  end

  context 'with one cassandra server on local machine' do
    before do
      set_cassandra_properties['hosts'] = %w(localhost:9042 remote:9042)
    end

    it 'includes cassandra recipe' do
      expect(chef_run).to include_recipe('kong::cassandra')
    end
  end

  context 'with a remote cassandra' do
    before { set_cassandra_properties['hosts'] = %w(remote:9042) }

    it 'does not include cassandra recipe' do
      expect(chef_run).to_not include_recipe('kong::cassandra')
    end
  end

  %w(_from_package _configuration _service).each do |recipe|
    it "includes #{recipe} recipe" do
      expect(chef_run).to include_recipe("kong::#{recipe}")
    end
  end
end

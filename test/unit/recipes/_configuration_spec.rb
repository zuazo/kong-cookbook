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

  shared_examples 'restarts kong' do
    it 'notifies "wait for cassandra"' do
      expect(resource)
        .to notify('ruby_block[wait for cassandra]').to(:run).delayed
    end

    context 'with manage cassandra disabled' do
      before { node.set['kong']['manage_cassandra'] = false }

      it 'does not notify "wait for cassandra"' do
        expect(resource)
          .to_not notify('ruby_block[wait for cassandra]').to(:run)
      end
    end

    it 'notifies kong restart' do
      expect(resource).to notify('service[kong]').to(:restart).delayed
    end
  end # shared example restarts kong

  context 'with manage ssl enabled' do
    it 'creates ssl certificate' do
      expect(chef_run).to create_ssl_certificate('kong')
    end
  end # context with manage ssl enabled

  context 'with manage ssl disabled' do
    before { node.set['kong']['manage_ssl_certificate'] = false }

    it 'does not create ssl certificate' do
      expect(chef_run).to_not create_ssl_certificate('kong')
    end
  end # context with manage ssl disabled

  context 'ssl certificate resource' do
    let(:resource) { chef_run.ssl_certificate('kong') }
    it_behaves_like 'restarts kong'
  end # context ssl certificate resource

  it 'creates kong.yml configuration file' do
    expect(chef_run).to create_template('/etc/kong/kong.yml')
      .with_source('kong.yml.erb')
      .with_cookbook('kong')
      .with_mode(00644)
  end

  context 'kong.yml template resource' do
    let(:resource) { chef_run.template('/etc/kong/kong.yml') }
    it_behaves_like 'restarts kong'
  end
end

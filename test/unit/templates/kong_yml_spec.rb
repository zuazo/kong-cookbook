# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2017 Xabier de Zuazo
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

require 'yaml'
require_relative '../spec_helper'
require_relative '../support/template_render'

describe 'kong.yml template', order: :random do
  let(:template) { TemplateRender.new('kong.yml.erb') }
  let(:node) { template.node }
  let(:variables) { { config: node['kong']['kong.yml'] } }

  context 'with default configuration' do
    it 'does not quote database' do
      expect(template.render(variables)).to match(/^\s*database:\s+[a-zA-Z]+$/)
    end

    it 'does not quote keyspace' do
      expect(template.render(variables)).to match(/^\s*keyspace:\s+[a-zA-Z]+$/)
    end

    it 'does not quote timeout' do
      expect(template.render(variables)).to match(/^\s*timeout:\s+[0-9]+$/)
    end

    it 'quotes contact_points' do
      expect(template.render(variables)).to match(/^\s*-\s+"localhost:9042"$/)
    end
  end

  context 'with IP address configuration value' do
    let(:value) { '127.0.0.1' }
    before { node.default['kong']['kong.yml']['cluster_listen'] = value }

    it 'quotes the value' do
      expect(template.render(variables))
        .to match(/^\s*cluster_listen:\s+"#{Regexp.escape(value)}"$/)
    end
  end

  context 'with port address configuration value' do
    let(:value) { 'myhost:7946' }
    before { node.default['kong']['kong.yml']['cluster_listen'] = value }

    it 'quotes the value' do
      expect(template.render(variables))
        .to match(/^\s*cluster_listen:\s+"#{Regexp.escape(value)}"$/)
    end
  end

  context 'when yaml engine is expected to add ""' do
    let(:value) { "0.0.0.0:7946\n " }
    let(:escaped_value) { value.gsub("\n", '\\\\n') }
    before { node.default['kong']['kong.yml']['noneedtoquote'] = value }

    it 'yaml engine adds ""' do
      expect({ k: value }.to_yaml).to include("\"#{escaped_value}\"")
    end

    it 'does not quote it again' do
      expect(template.render(variables))
        .to match(/^\s*noneedtoquote:\s+"#{Regexp.escape(escaped_value)}"$/)
    end
  end

  context "when yaml engine is forced to use ''" do
    let(:value) { '0.0.0.0:7946 ' }
    before { node.default['kong']['kong.yml']['noneedtoquote'] = value }

    it "yaml engine adds ''" do
      expect({ k: value }.to_yaml).to include("'#{value}'")
    end

    it 'does not quote it again' do
      expect(template.render(variables))
        .to match(/^\s*noneedtoquote:\s+'#{Regexp.escape(value)}'$/)
    end
  end
end

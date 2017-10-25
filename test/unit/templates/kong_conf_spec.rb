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

require_relative '../spec_helper'
require_relative '../support/template_render'

describe 'kong.conf template', order: :random do
  let(:template) { TemplateRender.new('kong.conf.erb') }
  let(:node) { template.node }
  let(:variables) { { config: node['kong']['kong.conf'] } }

  context 'with default configuration' do
    it 'database exists' do
      expect do
        pattern = '/^\s*database\s+=\s+[a-zA-Z]+$/'
        template.render(variables).to match(pattern)
      end
    end

    it 'cassandra_keyspace exists' do
      expect do
        pattern = '/^\s*cassandra_keyspace\s+=\s+[a-zA-Z]+$/'
        template.render(variables).to match(pattern)
      end
    end

    it 'cassandra_contact_points exists' do
      expect do
        pattern = '/^\s*database\s+=\s+[a-zA-Z]+$/'
        template.render(variables).to match(pattern)
      end
    end

    it 'cassandra_port exists' do
      expect do
        pattern = '/^\s*database\s+=\s+[a-zA-Z]+$/'
        template.render(variables).to match(pattern)
      end
    end

    it 'cassandra_timeout exists' do
      expect do
        pattern = '/^\s*database\s+=\s+[a-zA-Z]+$/'
        template.render(variables).to match(pattern)
      end
    end
  end
end

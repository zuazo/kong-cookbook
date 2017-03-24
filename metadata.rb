# encoding: UTF-8
#
# Cookbook Name:: kong
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

name 'kong'
maintainer 'Xabier de Zuazo'
maintainer_email 'xabier@zuazo.org'
license 'Apache 2.0'
description <<-EOH
Installs and Configures Kong: An open-source management layer for APIs,
delivering high performance and reliability.
EOH
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.5.0'

if respond_to?(:source_url)
  source_url "https://github.com/zuazo/#{name}-cookbook"
end
if respond_to?(:issues_url)
  issues_url "https://github.com/zuazo/#{name}-cookbook/issues"
end

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'ubuntu'

depends 'cassandra-dse', '~> 4.0'
depends 'netstat', '~> 0.1.0' # Required to check cassandra status
depends 'ssl_certificate', '~> 1.1'

recipe 'kong::default', 'Installs and configures Kong.'
recipe 'kong::cassandra', 'Installs and configures Cassandra.'

attribute 'kong/version',
          display_name: 'kong version',
          description: 'Kong version to install.',
          type: 'string',
          required: 'optional',
          default: '0.8.2'

attribute 'kong/mirror',
          display_name: 'kong mirror',
          description: 'Kong path without including the file name.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'kong/kong.yml',
          display_name: 'kong.yml',
          description:
            'Kong YAML configuration options. See the default configuration '\
            'values.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'kong/manage_ssl_certificate',
          display_name: 'kong manage ssl certificate',
          description:
            'Whether to manage HTTPS certificate creation using the '\
            'ssl_certificate cookbook.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'kong/manage_cassandra',
          display_name: 'kong manage cassandra',
          description:
            'Whether to manage Cassandra server installation using the '\
            'cassandra-dse cookbook.',
          type: 'string',
          required: 'recommended',
          calculated: true

attribute 'kong/wait_for_cassandra',
          display_name: 'kong wait for cassandra',
          description:
            'Time in seconds to wait for Cassandra to start. Only used with '\
            '`manage_cassandra` enabled.',
          type: 'string',
          required: 'optional',
          default: 300

attribute 'kong/pid_file',
          display_name: 'kong pid file',
          description: 'Kong nginx PID file path.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'kong/required_packages',
          display_name: 'kong required packages',
          description: 'Some packages required by Kong.',
          type: 'array',
          required: 'optional',
          calculated: true

attribute 'kong/package_file',
          display_name: 'kong package file',
          description: 'Kong package file name.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'kong/package_checksum',
          display_name: 'kong package checksum',
          description: 'Kong package file checksum.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'kong/kong.yml/template/cookbook',
          display_name: 'kong template cookbook',
          description: 'Whether to get kong template from current cookbook'\
                       'or from wrapped cookbook',
          type: 'string',
          required: 'optional',
          default: 'kong'

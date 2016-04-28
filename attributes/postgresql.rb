# encoding: UTF-8
#
# Cookbook Name:: postgres
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

# postgres configuration:
default_postgres = default['kong']['kong.yml']['postgres']
default_postgres['host'] = 'localhost'
default_postgres['port'] = 5432
default_postgres['database'] = 'kong'
default_postgres['user'] = 'kong'
default_postgres['password'] = 'password'

# kong requires a minimum of 9.4 to start.
default['postgresql']['version'] = '9.4'
default['postgresql']['dir'] = '/etc/postgresql/9.4/main'
default['postgresql']['client']['packages'] = [
  'postgresql-client-9.4',
  'libpq-dev'
]
default['postgresql']['server']['packages'] = ['postgresql-9.4']
default['postgresql']['contrib']['packages'] = ['postgresql-contrib-9.4']

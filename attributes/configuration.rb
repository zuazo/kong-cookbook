# encoding: UTF-8
#
# Cookbook Name:: kong
# Attributes:: configuration
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

## Available plugins on this server
default['kong']['kong.yml']['plugins_available'] = %w(
  ssl
  keyauth
  basicauth
  oauth2
  ratelimiting
  tcplog
  udplog
  filelog
  httplog
  cors
  request_transformer
  response_transformer
  requestsizelimiting
  ip_restriction
  mashape-analytics
)

## Port configuration
default['kong']['kong.yml']['proxy_port'] = 8000
default['kong']['kong.yml']['proxy_ssl_port'] = 8443
default['kong']['kong.yml']['admin_api_port'] = 8001

## Secondary port configuration
default['kong']['kong.yml']['dnsmasq_port'] = 8053

## Specify the DAO to use
default['kong']['kong.yml']['database'] = 'cassandra'

## Databases configuration
default_cassandra =
  default['kong']['kong.yml']['databases_available']['cassandra']['properties']

default_cassandra['hosts'] = %w(localhost:9042)
default_cassandra['timeout'] = 1000
default_cassandra['keyspace'] = 'kong'
default_cassandra['keepalive'] = 60_000 # in milliseconds

## Cassandra cache configuration
default['kong']['kong.yml']['database_cache_expiration'] = 5 # in seconds

## SSL Settings
## (Uncomment the two properties below to set your own certificate)
default['kong']['kong.yml']['ssl_cert_path'] = nil
default['kong']['kong.yml']['ssl_key_path'] = nil

## Sends anonymous error reports
default['kong']['kong.yml']['send_anonymous_reports'] = true

## In-memory cache size (MB)
default['kong']['kong.yml']['memory_cache_size'] = 128

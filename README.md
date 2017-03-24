Kong Cookbook
=============
[![GitHub](http://img.shields.io/badge/github-zuazo/kong--cookbook-blue.svg?style=flat)](https://github.com/zuazo/kong-cookbook)
[![License](https://img.shields.io/github/license/zuazo/kong-cookbook.svg?style=flat)](#license-and-author)

[![Cookbook Version](https://img.shields.io/cookbook/v/kong.svg?style=flat)](https://supermarket.chef.io/cookbooks/kong)
[![Dependency Status](http://img.shields.io/gemnasium/zuazo/kong-cookbook.svg?style=flat)](https://gemnasium.com/zuazo/kong-cookbook)
[![Code Climate](http://img.shields.io/codeclimate/github/zuazo/kong-cookbook.svg?style=flat)](https://codeclimate.com/github/zuazo/kong-cookbook)
[![Build Status](http://img.shields.io/travis/zuazo/kong-cookbook/0.5.0.svg?style=flat)](https://travis-ci.org/zuazo/kong-cookbook)
[![Circle CI](https://circleci.com/gh/zuazo/kong-cookbook/tree/master.svg?style=shield)](https://circleci.com/gh/zuazo/kong-cookbook/tree/master)
[![Coverage Status](http://img.shields.io/coveralls/zuazo/kong-cookbook/0.5.0.svg?style=flat)](https://coveralls.io/r/zuazo/kong-cookbook?branch=0.5.0)
[![Inline docs](http://inch-ci.org/github/zuazo/kong-cookbook.svg?branch=master&style=flat)](http://inch-ci.org/github/zuazo/kong-cookbook)

[Chef](https://www.chef.io/) cookbook to install [Kong](https://getkong.org/): An open-source management layer for APIs, delivering high performance and reliability.

Requirements
============

## Supported Platforms

This cookbook has been tested on the following platforms:

* Amazon Linux
* CentOS
* Debian
* Ubuntu

Please, [let me know](https://github.com/zuazo/kong-cookbook/issues/new?title=I%20have%20used%20it%20successfully%20on%20...) if you use it successfully on any other platform.

## Required Cookbooks

* [cassandra-dse](https://supermarket.chef.io/cookbooks/cassandra-dse)
* [netstat](https://supermarket.chef.io/cookbooks/netstat)
* [ssl_certificate](https://supermarket.chef.io/cookbooks/ssl_certificate)

## Required Applications

* Chef `12` or higher.
* Ruby `2.2` or higher.

Attributes
==========

| Attribute                                | Default      | Description                      |
|:-----------------------------------------|:-------------|:---------------------------------|
| `node['kong']['version']`                | `'0.8.2'`    | Kong version to install.
| `node['kong']['mirror']`                 | *calculated* | Kong URL path without including the file name.
| `node['kong']['kong.yml']`               | *calculated* | Kong *YAML* configuration options. See [the default configuration values](https://github.com/zuazo/kong-cookbook/blob/master/attributes/configuration.rb).
| `node['kong']['manage_ssl_certificate']` | *calculated* | Whether to manage HTTPS certificate creation using the [`ssl_certificate`](https://supermarket.chef.io/cookbooks/ssl_certificate) cookbook.
| `node['kong']['manage_cassandra']`       | *calculated* | Whether to manage Cassandra server installation using the [`cassandra-dse`](https://supermarket.chef.io/cookbooks/cassandra-dse) cookbook.
| `node['kong']['wait_for_cassandra']`     | `300`        | Time in seconds to wait for Cassandra to start. Only used with `manage_cassandra` enabled.
| `node['kong']['pid_file']`               | *calculated* | Kong nginx PID file path.
| `node['kong']['kong.yml']['template']['cookbook']` | `'kong'` | Kong template cookbook.

## Platform Support Related Attributes

Some cookbook attributes are used internally to support the different platforms. Surely you want to change them if you want to support new platforms or want to improve the support of some platforms already supported.

| Attribute                           | Default      | Description                      |
|:------------------------------------|:-------------|:---------------------------------|
| `node['kong']['required_packages']` | *calculated* | Some packages required by Kong.
| `node['kong']['package_file']`      | *calculated* | Kong package file name.
| `node['kong']['package_checksum']`  | *calculated* | Kong package file checksum.

Recipes
=======

## kong::default

Installs and configures Kong.

## kong::cassandra

Installs and configures Cassandra.

Usage Examples
==============

## Including in a Cookbook Recipe

You can simply include it in a recipe:

```ruby
include_recipe 'kong'
```

Don't forget to include the `kong` cookbook as a dependency in the metadata.

```ruby
# metadata.rb
# [...]

depends 'kong', '~> 0.1.0'
```

## Including in the Run List

Another alternative is to include the default recipe in your *Run List*:

```json
{
  "name": "api.example.com",
  "[...]": "[...]",
  "run_list": [
    "recipe[kong]"
  ]
}
```

## Configuring the Cassandra Server Address

It is highly recommended to use an **external Cassandra server** with this cookbook.

For example:

```ruby
node.default['kong']['kong.yml']['cassandra']['contact_points'] =
  'cassandra.example.com'

include_recipe 'kong'
```

If you want to use the local Cassandra server installed by this cookbook, it is recommended to set the following attributes:

```ruby
node.default['cassandra']['config']['cluster_name'] = # ...
node.default['cassandra']['install_method'] = # ...
# node.default['cassandra'][...]
# ...

include_recipe 'kong'
```

See the [`cassandra-dse` cookbook documentation](https://supermarket.chef.io/cookbooks/cassandra-dse).

By default, this cookbook installs a local Cassandra server if the `'hosts'` attribute is not set or includes `'localhost'`. You can use the `node['kong']['manage_cassandra']` attribute to force this behavior.

## The HTTPS Certificate

This cookbook uses the [`ssl_certificate`](https://supermarket.chef.io/cookbooks/ssl_certificate) cookbook to create the HTTPS certificate. The namespace used is `node['kong']`. For example:

```ruby
node.default['kong']['common_name'] = 'api.example.com'
include_recipe 'kong'
```

See the [`ssl_certificate` namespace documentation](https://supermarket.chef.io/cookbooks/ssl_certificate#namespaces) for more information.

You can disable the SSL certificate creation by setting the `node['kong']['kong.yml']['ssl_cert_path']` and `node['kong']['kong.yml']['ssl_key_path']` attributes. You can use the `node['kong']['manage_ssl_certificate']` attribute to force this behavior.

Testing
=======

See [TESTING.md](https://github.com/zuazo/kong-cookbook/blob/master/TESTING.md).

Contributing
============

Please do not hesitate to [open an issue](https://github.com/zuazo/kong-cookbook/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/zuazo/kong-cookbook/blob/master/CONTRIBUTING.md).

TODO
====

See [TODO.md](https://github.com/zuazo/kong-cookbook/blob/master/TODO.md).


License and Author
=====================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@zuazo.org>)
| **Contributor:**     | [Mark Keisler](https://github.com/grimm26)
| **Contributor:**     | [Alexander Vynnyk](https://github.com/cosmonaut-ok)
| **Contributor:**     | [Igor Moroz](https://github.com/igormr)
| **Contributor:**     | [Yves Jans](https://github.com/yvesjans)
| **Copyright:**       | Copyright (c) 2015-2016, Xabier de Zuazo
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

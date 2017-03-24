kong CHANGELOG
==============

This file is used to list changes made in each version of the `kong` cookbook.

## v0.5.0 (2017-03-24)

* Require Chef `12` and Ruby >= `2.2` (**breaking change**).
* Quote yaml strings containing `.` or `:` ([issue #6](https://github.com/zuazo/kong-cookbook/pull/6), thanks [Mark Keisler](https://github.com/grimm26)).
* Fix for `0.9`.x versions ([issue #7](https://github.com/zuazo/kong-cookbook/pull/7), thanks [Alexander Vynnyk](https://github.com/cosmonaut-ok)).
* Move yml template cookbook to attributes ([issue #10](https://github.com/zuazo/kong-cookbook/pull/10), thanks [Igor Moroz](https://github.com/igormr)).
* Add support for Ubuntu `16.04` (Xenial) ([issue #11](https://github.com/zuazo/kong-cookbook/pull/11), thanks [Yves Jans](https://github.com/yvesjans)).
* Update kong version to `0.8.2`.
* Update foodcritic to `6.3` and RuboCop to `0.40`.
* README: Update *Configuring the Cassandra Server Address* documentation.

## v0.4.0 (2016-04-03)

* Add Amazon Linux support.
* Support package version upgrade (thanks Jannes Pockelé).

Testing:
* Fix Travis with Chef 11.
* Remove Travis exclude matrix (no longer needed).

## v0.3.0 (2016-03-30)

* Remove Ruby `1.9` support (**breaking change**).
* Update kong to version `0.7.0` (**breaking change**).
* Update `cassandra-dse` cookbook to version `4`.
* Update RuboCop to version `4` and foodcritic to `0.39`.

Documentation:
* Improve testing documentation.
* Fix documentation bug: Missing param name.
* README: Add license badge.

Testing:
* Fix nokogiri error.
* Fix bundle args.
* Update Berkshelf to `4`.
* Update `.kitchen.yml` files.
* Update `kitchen-ec2` to version `1`.

## v0.2.0 (2015-09-10)

* Remove `nginx` cookbook from dependencies.

* Documention:
 * README:
  * Add *Required Cookbooks* section.
  * Add GitHub badge.

* Testing:
 * Integrate Kitchen tests with CircleCI.
 * Include amazon instances in the .kitchen.cloud.yml file.
 * Add Vagrantfile.
 * Gemfile: foodcritic `~> `4.0.0`, rubocop `~> `0.34.0`.
 * Travis CI: Use bundler cache.
 * .rubocop.yml: Exclude vendor directory.
 * Berksfile: Fix cookbooks constraint error.
 * Rakefile:
  * Use Kitchen class instead of sh.
  * Run docker by default in the CI.

## v0.1.0 (2015-08-18)

* Initial release of `kong`.

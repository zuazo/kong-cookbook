kong CHANGELOG
==============

This file is used to list changes made in each version of the `kong` cookbook.

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

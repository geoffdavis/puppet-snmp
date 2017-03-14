source 'https://rubygems.org'

### Environment variable version overrrides

puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 4.8.2' # from puppet enterprise

### Gem requirements
gem 'rake'
gem 'rspec'
gem 'puppet', puppet_version
gem 'rspec-puppet', '>= 1.0.1'
#gem 'rcov'

gem 'puppet-lint'

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem 'ci_reporter_rspec'

source 'https://rubygems.org'

facterversion = ENV.key?('FACTER_VERSION') ? "= #{ENV['FACTER_VERSION']}" : ['= 1.6.7']
puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['= 2.7.12']
rspecversion = ENV.key?('RSPEC_VERSION') ? "= #{ENV['RSPEC_VERSION']}" : ['>= 2.9']

gem 'rake'
gem 'rspec', rspecversion
gem 'facter', facterversion
gem 'puppet', puppetversion
gem 'hiera-puppet'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper'
gem 'puppet-lint'
gem 'ci_reporter'

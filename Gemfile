source 'https://rubygems.org'

### Environment variable version overrrides

# facter
facter_version = ENV.key?('FACTER_VERSION') ? "= #{ENV['FACTER_VERSION']}" : \
  '= 1.7.5' # from puppet enterprise 3.2.3
# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 3.4.3' # from puppet enterprise 3.2.3
# hiera
hiera_version = ENV.key?('HIERA_VERSION') ? "= #{ENV['HIERA_VERSION']}" : \
  '= 1.3.2' # from puppet enterprise 3.2.3
# hiera-puppet
hiera_puppet_version = ENV.key?('HIERA_PUPPET_VERSION') ? \
  "= #{ENV['HIERA_PUPPET_VERSION']}" : '>= 1.0.0' # from puppet enterprise 3.2.3

### Gem requirements
gem 'rake'
gem 'rspec', '< 3.0.0'
gem 'facter', facter_version
gem 'puppet', puppet_version
gem 'rspec-puppet', '>= 1.0.1'
#gem 'rcov'

## Puppet 2.x does not include hiera.
if puppet_version =~ /^([^0-9]+)?([^\.]|)2(\..*?)$/
  gem 'hiera', hiera_version
  gem 'hiera-puppet', hiera_puppet_version
end

gem 'puppet-lint'

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem 'ci_reporter_rspec'

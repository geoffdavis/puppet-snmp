source 'https://rubygems.org'

### Environment variable version overrrides

# facter
facter_version = ENV.key?('FACTER_VERSION') ? "= #{ENV['FACTER_VERSION']}" : \
  '= 1.7.5' # from puppet enterprise 2.8
# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 3.4.3' # from puppet enterprise 2.8
# hiera
hiera_version = ENV.key?('HIERA_VERSION') ? "= #{ENV['HIERA_VERSION']}" : \
  '= 1.3.2' # from puppet enterprise 2.8
# hiera-puppet
hiera_puppet_version = ENV.key?('HIERA_PUPPET_VERSION') ? \
  "= #{ENV['HIERA_PUPPET_VERSION']}" : '= 1.0.0' # from puppet enterprise 2.8
# rspec
rspec_version = ENV.key?('RSPEC_VERSION') ? "= #{ENV['RSPEC_VERSION']}" : \
  '>= 2.9'
# rspec-puppet
# Per GH-137, versions 1.0.0 and 1.0.1 conflict with hiera-puppet-helper
# See: https://github.com/rodjek/rspec-puppet/issues/137
rspec_puppet_version = ENV.key?('RSPEC_PUPPET_VERSION') ? \
  "= #{ENV['RSPEC_VERSION']}" : '0.1.6'

# choose between the two implementations: hiera-puppet-helper or hiera-spec
hiera_spec_gem = ENV.key?('HIERA_SPEC_GEM') ? ENV['HIERA_SPEC_GEM'] :\
  'hiera-puppet-helper'
hiera_spec_gem_version =  ENV.key?('HIERA_SPEC_GEM_VERSION') ?\
  ENV['HIERA_SPEC_GEM_VERSION'] : '1.0.1'


### Gem requirements
gem 'rake'
gem 'rspec', rspec_version
gem 'facter', facter_version
gem 'puppet', puppet_version
gem 'rspec-puppet', rspec_puppet_version
#gem 'rcov'

## Puppet 2.x does not include hiera.
if puppet_version =~ /^([^0-9]+)?([^\.]|)2(\..*?)$/
  gem 'hiera', hiera_version
  gem 'hiera-puppet', hiera_puppet_version
end

gem 'puppet-lint'
gem hiera_spec_gem, hiera_spec_gem_version

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem "ci_reporter"

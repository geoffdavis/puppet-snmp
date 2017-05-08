source 'https://rubygems.org'

### Environment variable version overrrides

# puppet
puppet_version = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : \
  '= 4.8.2' # from puppet enterprise 3.2.3


### Gem requirements
gem 'rake'
gem 'json_pure'
gem 'rspec'
gem 'puppet', puppet_version
gem 'rspec-puppet', '>= 2.0'
gem 'puppet-syntax', :require => false

#gem 'rcov'
gem 'parallel_tests', :require => false
# http://www.camptocamp.com/en/actualite/getting-code-ready-puppet-4/
gem 'puppet-lint-unquoted_string-check'
gem 'puppet-lint-empty_string-check'
gem 'puppet-lint-leading_zero-check'
gem 'puppet-lint-variable_contains_upcase'
gem 'puppet-lint-spaceship_operator_without_tag-check'
gem 'puppet-lint-absolute_classname-check'
gem 'puppet-lint-undef_in_function-check'
gem 'puppet-lint-roles_and_profiles-check'


gem 'puppet-lint'

gem 'puppetlabs_spec_helper'
gem 'git', '>= 1.2.6'
gem 'ci_reporter_rspec'

gem 'generate-puppetfile'

require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'ci/reporter/rake/rspec'

PuppetLint.configuration.send('relative')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

task :spec  => 'ci:setup:rspec'
task :clean => 'ci:setup:spec_report_cleanup'

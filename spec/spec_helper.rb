## spec_helper for the site module
#
# This helper script is for rspec testing. It includes the ability to test our
# hiera data, and defines some Rspec shared_contexts for testing.

## Setup
#
#
gems = [
  'rubygems',
  'puppetlabs_spec_helper/module_spec_helper',
]

# Load all the gems
begin
  gems.each {|gem| require gem}
rescue Exception => e
  puts '=' * e.message.length
  puts e.message
  puts '=' * e.message.length
  exit(1)
end

class Undef
  def inspect
    'undef'
  end
end
def String.natural_order(nocase=false)
  proc do |str|
    i = true
    str = str.upcase if nocase
    str.gsub(/\s+/,'').split(/(\d+)/).map {|x| (i = !i) ? x.to_i : x}
  end
end

## Set up the hiera environment
module Helpers
  class Data
    def self.shared_facts
      {
        :concat_basedir => 'foo/bar/baz',
        :fqdn           => 'testhost.testfqdn',
        :hostname       => 'testhost',
      }
    end
    def self.antelope_base_facts
      {
        :antelope_contrib_basedir => {
          '5.4'                   => '',
          '5.4post'               => '/contrib',
        },
      }
    end
    def self.role_shared_pre_conditions(rolename)
      return [
        "$site_role='#{rolename}'",
        "hiera_include('classes')",
      ]
    end
    def self.site_supported_platforms
      [ 'centos6','centos7',
        'darwin14','darwin15',
        'freebsd8','freebsd10',
        'sol10s','sol10x',
      ]
    end
    def self.site_unsupported_platforms
      [ 'debian7','ubuntu14' ]
    end
    def self.site_supported_pops
      [ 'hpwren',
        'hpwren-svr',
        'igpp-workstations',
        'irisdmc',
        'siocolo',
        'sdscroof',
        'solarium',
      ]
    end
    def self.site_unsupported_pops
      [ 'public' ]
    end
    def self.site_platforms
      return [ self.site_supported_platforms,self.site_unsupported_platforms
      ].flatten.sort_by(&String.natural_order)
    end
  end

  class Paths
    def self.fixture_path
      File.expand_path(File.join(__FILE__, '..', 'fixtures'))
    end
    def self.parent_repo_path
      # Path to the enclosing puppet-environments repository
      File.expand_path(File.join(__FILE__, '..', '..', '..', '..'))
    end
  end

  extend RSpec::SharedContext
  def hiera_config_content
    h_config = 'spec/fixtures/hiera/hiera.yaml'

    return h_config
  end

  # include Helpers to get this :hiera_config
  let(:hiera_config) {hiera_config_content}
end

RSpec.configure do |c|
  c.include Helpers # use hiera_config in every context
  c.fail_fast = false # should we bail out on the first error?
end

## Shared contexts to cut down on copy/paste testing code
# shared variables for all contexts are defined in the Helpers class above
shared_context 'Unsupported Platform' do
  it 'should complain about being unsupported' do
    should raise_error(Puppet::Error,/unsupported/)
  end
end

shared_context 'centos6' do
  before do
    @shared_platform_facts = {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :architecture              => 'x86_64',
      :hardwareisa               => 'x86_64',
      :kernel                    => 'Linux',
      :kernelmajversion          => '2.6',
      :kernelrelease             => '2.6.32-504.16.2.el6.x86_64',
      :kernelversion             => '2.6.32',
      :lsbmajdistrelease         => '6',
      :operatingsystemmajrelease => '6',
      :operatingsystemrelease    => '6.6',
      :memorysize_mb             => '8192',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'centos7' do
  before do
    @shared_platform_facts = {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :architecture              => 'x86_64',
      :hardwareisa               => 'x86_64',
      :kernel                    => 'Linux',
      :kernelmajversion          => '3.10',
      :kernelrelease             => '3.10.0-229.1.2.el7.x86_644',
      :kernelversion             => '3.10.0',
      :lsbmajdistrelease         => '7',
      :operatingsystemmajrelease => '7',
      :operatingsystemrelease    => '7.1.1503',
      :memorysize_mb             => '8192',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'darwin13' do
  before do
    @shared_platform_facts = {
      :osfamily                    => 'Darwin',
      :operatingsystem             => 'Darwin',
      :operatingsystemrelease      => '13.4.0',
      :kernel                      => 'Darwin',
      :kernelmajversion            => '13.4',
      :kernelrelease               => '13.4.0',
      :kernelversion               => '13.4.0',
      :macosx_productname          => 'Mac OS X',
      :macosx_productversion       => '10.9.5',
      :macosx_productversion_major => '10.9',
      :macosx_productversion_minor => '5',
      :memorysize_mb               => '8192',
      :xcodebuild_version          => '6.1',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'darwin14' do
  before do
    @shared_platform_facts = {
      :osfamily                    => 'Darwin',
      :operatingsystem             => 'Darwin',
      :operatingsystemrelease      => '14.0.0',
      :kernel                      => 'Darwin',
      :kernelmajversion            => '14.0',
      :kernelrelease               => '14.0.0',
      :kernelversion               => '14.0.0',
      :macosx_productname          => 'Mac OS X',
      :macosx_productversion       => '10.10.1',
      :macosx_productversion_major => '10.10',
      :macosx_productversion_minor => '1',
      :memorysize_mb               => '8192',
      :xcodebuild_version          => '6.1.1',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'darwin15' do
  before do
    @shared_platform_facts = {
      :osfamily                    => 'Darwin',
      :operatingsystem             => 'Darwin',
      :operatingsystemrelease      => '15.0.0',
      :kernel                      => 'Darwin',
      :kernelmajversion            => '15.0',
      :kernelrelease               => '15.0.0',
      :kernelversion               => '15.0.0',
      :macosx_productname          => 'Mac OS X',
      :macosx_productversion       => '10.11.1',
      :macosx_productversion_major => '10.11',
      :macosx_productversion_minor => '1',
      :memorysize_mb               => '8192',
      :xcodebuild_version          => '7.1',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'debian7' do
  before do
    @shared_platform_facts = {
      :memorysize_mb             => '8192',
      :architecture              => 'armv5tel',
      :hardwareisa               => 'unknown',
      :hardwaremodel             => 'armv5tel',
      :kernel                    => 'Linux',
      :kernelmajversion          => '3.2',
      :kernelrelease             => '3.2.0-4-kirkwood',
      :kernelversion             => '3.2.0',
      :lsbdistcodename           => 'wheezy',
      :lsbdistdescription        => 'Debian GNU/Linux 7.7 (wheezy)',
      :lsbdistid                 => 'Debian',
      :lsbdistrelease            => '7.7',
      :lsbmajdistrelease         => '7',
      :lsbminordistrelease       => '7',
      :operatingsystem           => 'Debian',
      :operatingsystemmajrelease => '7',
      :operatingsystemrelease    => '7.7',
      :osfamily                  => 'Debian',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'freebsd8' do
  before do
    @shared_platform_facts = {
      :osfamily                  => 'FreeBSD',
      :operatingsystem           => 'FreeBSD',
      :operatingsystemrelease    => '8.4-RELEASE-p27',
      :operatingsystemmajrelease => '8',
      :kernel                    => 'FreeBSD',
      :kernelrelease             => '8.4-RELEASE-p27',
      :kernelversion             => '8.4',
      :memorysize_mb             => '8000',
      :hardwareisa               => 'amd64',
      :pkgng_enabled             => true,
      :pkgng_supported           => true,
      :pkgng_version             => '1.5.4',
    }.merge(Helpers::Data.shared_facts)
  end
  let :facts do @shared_platform_facts end
end

shared_context 'freebsd10' do
  before do
    @shared_platform_facts = {
      :osfamily                  => 'FreeBSD',
      :operatingsystem           => 'FreeBSD',
      :operatingsystemrelease    => '10.1-RELEASE',
      :operatingsystemmajrelease => '10',
      :kernel                    => 'FreeBSD',
      :kernelrelease             => '10.1-RELEASE',
      :kernelversion             => '10.1',
      :memorysize_mb             => '8000',
      :hardwareisa               => 'amd64',
      :pkgng_enabled             => true,
      :pkgng_supported           => true,
      :pkgng_version             => '1.5.4',
    }.merge(Helpers::Data.shared_facts)
  end
  let :facts do @shared_platform_facts end
end

shared_context 'sol10s' do
  before do
    @shared_platform_facts = {
      :osfamily               => 'Solaris',
      :operatingsystem        => 'Solaris',
      :hardwareisa            => 'sparc',
      :kernel                 => 'SunOS',
      :kernelrelease          => '5.10',
      :kernelmajversion       => 'Generic_144488-11',
      :kernelversion          => 'Generic_144488-11',
      :operatingsystemrelease => '10_u8',
      :memorysize_mb          => '8000',
      :productname            => 'Sun Fire T100',
    }.merge(Helpers::Data.shared_facts)
  end

  let(:facts) { @shared_platform_facts }
end

shared_context 'sol10x' do
  before do
    @shared_platform_facts = {
      :osfamily               => 'Solaris',
      :operatingsystem        => 'Solaris',
      :hardwareisa            => 'i386',
      :kernel                 => 'SunOS',
      :kernelrelease          => '5.10',
      :kernelmajversion       => 'Generic_147148-26',
      :kernelversion          => 'Generic_147148-26',
      :operatingsystemrelease => '10_u11',
      :memorysize_mb          => '8000',
      :productname            => 'VMware Virtual Platform',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'sol11x' do
  before do
    @shared_platform_facts = {
      :osfamily               => 'Solaris',
      :operatingsystem        => 'Solaris',
      :hardwareisa            => 'i386',
      :kernel                 => 'SunOS',
      :kernelrelease          => '5.11',
      :memorysize_mb          => '8000',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end

shared_context 'ubuntu14' do
  before do
    @shared_platform_facts = {
      :memorysize_mb             => '8000',
      :architecture              => 'amd64',
      :hardwareisa               => 'x86_64',
      :hardwaremodel             => 'x86_64',
      :kernel                    => 'Linux',
      :kernelmajversion          => '3.13',
      :kernelrelease             => '3.13.0-43-lowlatency',
      :kernelversion             => '3.13.0',
      :lsbdistcodename           => 'trusty',
      :lsbdistdescription        => 'Ubuntu 14.04.1 LTS',
      :lsbdistid                 => 'Ubuntu',
      :lsbdistrelease            => '14.04',
      :lsbmajdistrelease         => '14.04',
      :operatingsystem           => 'Ubuntu',
      :operatingsystemmajrelease => '14.04',
      :operatingsystemrelease    => '14.04',
      :osfamily                  => 'Debian',
      :type                      => 'Desktop',
    }.merge(Helpers::Data.shared_facts)
  end
  let(:facts) { @shared_platform_facts }
end


require 'spec_helper'

describe 'snmp::install', :type => :class  do
  shared_context 'Darwin' do
    it { should contain_package('net-snmp').with_provider('macports') }

    context 'with apple provider' do
      let :pre_condition do
        'class { snmp::params: darwin_provider => apple }
        class { snmp: }'
      end
        it { should_not contain_package('net-snmp') }
    end
  end

  shared_context 'FreeBSD' do
    it { should contain_package('net-snmp') }
  end

  shared_context 'RedHat' do
    it { should contain_package('net-snmp') }
  end

  shared_context 'Solaris' do
    it { should contain_package('SUNWsmagt').with_provider('sun') }
    it { should contain_package('SUNWsmcmd').with_provider('sun') }
    it { should contain_package('SUNWsmmgr').with_provider('sun') }
  end

  shared_context 'Solaris x86' do
    it { should_not contain_package('SUNWmasf').with_provider('sun') }
    it { should_not contain_package('SUNWmasfr').with_provider('sun') }
    it { should_not contain_package('SUNWpiclh').with_provider('sun') }
    it { should_not contain_package('SUNWpiclr').with_provider('sun') }
    it { should_not contain_package('SUNWpiclu').with_provider('sun') }
    it { should_not contain_package('SUNWescdl').with_provider('sun') }
  end

  shared_context 'Solaris SPARC' do
    it { should contain_package('SUNWmasf').with_provider('sun') }
    it { should contain_package('SUNWmasfr').with_provider('sun') }
    it { should contain_package('SUNWpiclh').with_provider('sun') }
    it { should contain_package('SUNWpiclr').with_provider('sun') }
    it { should contain_package('SUNWpiclu').with_provider('sun') }
    it { should contain_package('SUNWescdl').with_provider('sun') }
  end

  Helpers::Data.site_platforms.each do |platform|
    context "on platform #{platform}" do
      include_context platform
      let :pre_condition do 'class { snmp: }' end

      case platform
      when /^centos/ then
        it_behaves_like 'RedHat'
      when /^darwin/ then
        it_behaves_like 'Darwin'
      when /^freebsd/ then
        it_behaves_like 'FreeBSD'
      when 'sol10s' then
        it_behaves_like 'Solaris'
        it_behaves_like 'Solaris SPARC'
      when 'sol10x' then
        it_behaves_like 'Solaris'
        it_behaves_like 'Solaris x86'
      else
        it_behaves_like 'Unsupported Platform'
      end
    end
  end
end

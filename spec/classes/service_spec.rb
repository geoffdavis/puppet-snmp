require 'spec_helper'

describe 'snmp::service', :type => :class  do

  shared_context 'Darwin' do
    it { should contain_service('snmpd').with({
      :ensure => 'running',
      :enable => true,
      :name   => 'org.macports.net-snmp',
    }) }

    it { should contain_service('org.net-snmp.snmpd').with({
      :ensure => 'stopped',
      :enable => false,
    }).that_comes_before('Service[snmpd]') }

    context 'with apple provider' do
      let :pre_condition do
        'class { snmp::params: darwin_provider => apple }
        class { snmp: }'
      end
      it { should contain_service('snmpd').with({
        :ensure => 'running',
        :enable => true,
        :name   => 'org.net-snmp.snmpd',
      }) }

      it { should contain_service('org.macports.net-snmp').with({
        :ensure => 'stopped',
        :enable => false,
      }).that_comes_before('Service[snmpd]') }
    end
  end

  shared_context 'FreeBSD' do
    it { should contain_service('snmpd').with({
      :ensure => 'running',
      :enable => true,
      :name   => 'snmpd',
    }) }
  end

  shared_context 'RedHat' do
    it { should contain_service('snmpd').with({
      :ensure => 'running',
      :enable => true,
      :name   => 'snmpd',
    }) }
  end

  shared_context 'Solaris' do
    it { should contain_service('snmpd').with({
      :ensure => 'running',
      :enable => true,
      :name   => 'svc:/application/management/sma:default',
    }) }

    it { should contain_service('netsnmpd').with({
      :ensure => 'stopped',
      :enable => false,
    }).that_comes_before('Service[snmpd]') }
    it { should contain_service('netsnmptrapd').with({
      :ensure => 'stopped',
      :enable => false,
    }).that_comes_before('Service[snmpd]') }
  end

  shared_context 'Solaris x86' do
    it { should_not contain_service('masfd') }
  end

  shared_context 'Solaris SPARC' do
    it { should contain_service('masfd').with({
      :ensure    => 'running',
      :enable    => true,
      :hasstatus => false,
      :provider  => 'init',
    }).that_comes_before('Service[snmpd]') }
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

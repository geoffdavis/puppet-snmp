require 'spec_helper'

describe 'snmp::config', :type => :class  do

  shared_context 'Darwin' do
    it { should contain_file('snmpd.conf').with({
      :ensure => 'file',
      :path   => '/opt/local/etc/snmp/snmpd.conf',
      :owner  => 'root',
      :group  => 'wheel',
    }) }
    it { should contain_file('/private/etc/snmp/snmpd.conf').with_ensure('absent') }

    context 'with apple provider' do
      let :pre_condition do
        'class { snmp::params: darwin_provider => apple }
        class { snmp: }'
      end
      it { should contain_file('/opt/local/etc/snmp/snmpd.conf').with_ensure('absent') }
      it { should contain_file('snmpd.conf').with({
        :ensure => 'file',
        :path   => '/private/etc/snmp/snmpd.conf',
      }) }
    end
  end

  shared_context 'FreeBSD' do
    it { should contain_file('snmpd.conf').with({
      :ensure => 'file',
      :path   => '/usr/local/etc/snmp/snmpd.conf',
      :owner  => 'root',
      :group  => 'wheel',
    }) }
    it { should contain_file_line('rc.conf snmpd_flags') }
    it { should contain_file_line('rc.conf snmpd_pidfile') }
    it { should contain_file_line('rc.conf snmpd_conffile') }
  end

  shared_context 'RedHat' do
    it { should contain_file('snmpd.conf').with({
      :ensure => 'file',
      :path   => '/etc/snmp/snmpd.conf',
      :owner  => 'root',
      :group  => 'root',
    }) }
    it { should contain_file('/etc/sysconfig/snmpd').with({
      :ensure => 'file',
      :owner  => 'root',
      :group  => 'root',
    }) }
  end

  shared_context 'Solaris' do
    it { should contain_file('snmpd.conf').with({
      :ensure => 'file',
      :path   => '/etc/sma/snmp/snmpd.conf',
      :owner  => 'root',
      :group  => 'sys',
    }) }
    it { should contain_file('/etc/opt/csw/snmp/snmpd.conf').with_ensure('absent') }
  end

  shared_context 'Solaris x86' do
    it { should_not contain_file('/etc/init.d/masfd') }
    it { should_not contain_file('/etc/opt/SUNWmasf/conf/snmpd.conf') }
  end

  shared_context 'Solaris SPARC' do
    it { should contain_file('/etc/init.d/masfd').that_notifies('Service[masfd]') }
    it { should contain_file('/etc/opt/SUNWmasf/conf/snmpd.conf').that_notifies('Service[masfd]') }
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

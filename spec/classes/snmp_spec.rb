require 'spec_helper'

describe 'snmp', :type=>'class' do
  context 'On a Solaris OS version 5.10' do
    let(:facts) {{
      :operatingsystem=>'Solaris',
      :osfamily=>'Solaris',
      :operatingsystemrelease=>'5.10',
    }}

    it { should contain_package('SUNWsmagt') }
    it { should contain_package('SUNWsmcmd') }
    it { should contain_package('SUNWsmmgr') }
  end

  context 'On a RedHat OS' do
    let(:facts) {{
      :operatingsystem=>'CentOS',
      :osfamily=>'RedHat',
    }}

    it { should contain_package('net-snmp') }
  end

  context 'On a valid OS' do
    let(:facts) {{
      :operatingsystem=>'CentOS',
      :osfamily=>'RedHat',
    }}

    context 'with basic params' do
      let(:params) { {
        :read_community => 'public',
        :read_restrict => '192.168.2.3',
      } }
      it { should contain_file('snmpd.conf')\
        .with_content(/^rocommunity public 192\.168\.2\.3$/)
      }
    end

    context 'with disable = true' do
      let(:params) { {
        :disable => true,
      } }

      it { should contain_service('snmpd').with_enable(false) }
    end

    context 'with read_restrict as an array' do
      let(:params) { {
        :read_restrict => ['192.168.1.0/24', '10.0.0.5' ],
      } }

      it { should contain_file('snmpd.conf')\
        .with_content(/^rocommunity public 192\.168\.1\.0\/24$/)\
        .with_content(/^rocommunity public 10\.0\.0\.5$/)
      }
    end

  end
end

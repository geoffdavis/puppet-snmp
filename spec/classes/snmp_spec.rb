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
end

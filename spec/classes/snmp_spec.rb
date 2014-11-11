require 'spec_helper'

describe 'snmp', :type=>'class' do
  context 'On a Solaris OS version 5.10' do
    basefacts = {
      :operatingsystem        => 'Solaris',
      :osfamily               => 'Solaris',
      :operatingsystemrelease => '5.10',
    }

    let(:facts) { basefacts }

    it { should contain_package('SUNWsmagt') }
    it { should contain_package('SUNWsmcmd') }
    it { should contain_package('SUNWsmmgr') }
    it { should contain_service('netsnmpd').with_ensure('stopped') }
    it { should contain_service('netsnmptrapd').with_ensure('stopped') }

    context 'with masf_proxy = false' do
      let(:params) {{
        :masf_proxy => false,
      }}

      it { should_not contain_package('SUNWescpl') }
      it { should_not contain_package('SUNWeschl') }
      it { should_not contain_package('SUNWeserl') }
      it { should_not contain_package('SUNWespdl') }
      it { should_not contain_package('SUNWesonl') }
    end

    context 'with masf_proxy = true' do
      let(:params) {{
        :masf_proxy => true,
      }}

      context 'on a T2000' do
        let(:facts) { {
          :productname   => 'Sun Fire T200',
          :hardwareisa   => 'sparc',
          :hardwaremodel => 'sun4v',
        }.merge(basefacts) }
        it { should contain_package('SUNWesonl') }
        it { should contain_package('SUNWespdl') }
      end

    end

    context 'on a SPARC ISA system' do
      let(:facts) { {
        :hardwareisa     => 'sparc',
      }.merge(basefacts) }
      it { should contain_file('snmpd.conf').with_content(
        /\/usr\/sfw\/lib\/sparcv9/) }
    end
    context 'on an i386 ISA system' do
      let(:facts) { {
        :hardwareisa => 'i386',
      }.merge(basefacts) }
      it { should contain_file('snmpd.conf').with_content(
        /\/usr\/sfw\/lib\/amd64/) }
    end
    context 'on an unknown ISA system' do
      let(:facts) { {
        :hardwareisa => nil,
      }.merge(basefacts) }
      it { should contain_file('snmpd.conf').with_content(
        /(?<!\/usr\/sfw)/ ) }
    end
  end
#  context 'On a FreeBSD OS' do
#    let(:facts) {{
#      :operatingsystem=>'FreeBSD',
#      :osfamily=>'FreeBSD',
#    }}
#
#    it { should contain_package('net-snmp') }
#    it { should contain_service('snmpd') }
#    it { should contain_freebsd__rc_conf('snmpd_conffile') }
#    it { should contain_freebsd__rc_conf('snmpd_enable') }
#    it { should contain_freebsd__rc_conf('snmpd_flags') }
#    it { should contain_file('snmpd.conf').with_content(
#      /(?<!\/usr\/sfw)/ ) }
#    it { should_not contain_service('netsnmpd').with_ensure('stopped') }
#    it { should_not contain_service('netsnmptrapd').with_ensure('stopped') }
#  end

  context 'On a RedHat OS' do
    let(:facts) {{
      :operatingsystem=>'CentOS',
      :osfamily=>'RedHat',
    }}

    it { should contain_package('net-snmp') }
    it { should contain_service('snmpd') }
    it { should contain_file('snmpd.conf').with_content(
      /(?<!\/usr\/sfw)/
    ) }

    it { should_not contain_service('netsnmpd').with_ensure('stopped') }
    it { should_not contain_service('netsnmptrapd').with_ensure('stopped') }
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
        .with_content(/^rocommunity public 192\.168\.2\.3$/)\
        .with_content(/skipNFSInHostResources false/)
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
    context 'with skipNFSInHostResources enabled' do
      let(:params) { {
        :skip_nfs_in_host_resources => true,
      } }

      it { should contain_file('snmpd.conf')\
        .with_content(/skipNFSInHostResources true/)
      }
    end

  end
end

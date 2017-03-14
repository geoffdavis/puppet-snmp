require 'spec_helper'

describe 'snmp', :type => :class  do
  shared_context 'Supported Platform' do
    it { should contain_anchor('snmp::begin').that_comes_before('Class[snmp::install]') }
    it { should contain_class('snmp::install').that_comes_before('Class[snmp::config]') }
    it { should contain_class('snmp::config').that_notifies('Class[snmp::service]') }
    it { should contain_class('snmp::service').that_comes_before('Anchor[snmp::end]') }
    it { should contain_anchor('snmp::end') }

    context 'with ensure=absent' do
      let :params do { :ensure => 'absent' } end
      it { should contain_anchor('snmp::begin').that_comes_before('Class[snmp::service]') }
      it { should contain_class('snmp::service').that_comes_before('Class[snmp::config]') }
      it { should contain_class('snmp::config').that_comes_before('Class[snmp::install]') }
      it { should contain_class('snmp::install').that_comes_before('Anchor[snmp::end]') }
      it { should contain_anchor('snmp::end') }
    end
  end

  Helpers::Data.site_platforms.each do |platform|
    context "on platform #{platform}" do
      include_context platform

      let :facts do
        @shared_platform_facts.merge({
          :hostname => 'example',
          :fqdn     => 'example.com',
        })
      end
      case platform
      when /^centos/ then
        it_behaves_like 'Supported Platform'
      when /^darwin/ then
        it_behaves_like 'Supported Platform'
      when /^freebsd/ then
        it_behaves_like 'Supported Platform'
      when /^sol10/ then
        it_behaves_like 'Supported Platform'
      else
        it_behaves_like 'Unsupported Platform'
      end
    end
  end
end

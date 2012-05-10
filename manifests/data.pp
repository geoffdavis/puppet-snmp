class snmp::data {
  require 'stdlib'

  $template = 'snmp/snmpd.conf.erb'

  $package_names = $::operatingsystem ? {
    'Solaris' => $::operatingsystemrelease ? {
      '5.10'  => ['SUNWsmagt', 'SUNWsmcmd', 'SUNWsmmgr' ],
      default => undef,
    },
    /(RedHat|CentOS)/ => 'net-snmp',
    default           => undef,
  }

  $package_provider = $::operatingsystem ? {
    'Solaris' => $::operatingsystemrelease ? {
      '5.10'  => 'sun',
      default => undef,
    },
    default => undef,
  }

  $service = $::operatingsystem ? {
    'Solaris' => $::operatingsystemrelease ? {
      '5.10'  => 'svc:/application/management/sma:default',
      default => 'sma',
    },
    'Darwin'          => 'org.net-snmp.snmpd',
    /(RedHat|CentOS)/ => 'snmpd',
  }

  $config_directory = $::operatingsystem ? {
    'Solaris'         => '/etc/sma/snmp',
    /(RedHat|CentOS)/ => '/etc/snmp',
    default           => '/etc/snmp',
  }

  $config_file_owner = $::operatingsystem ? {
    default   => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    'Solaris' => 'sys',
    default   => 'root',
  }

  $sysdescr = $::snmp_sysdescr? {
    default => $::snmp_sysdescr,
    ''      => "$::operatingsystem $::operatingsystemrelease $::hostname $::productname",
  }

  $syscontact = $::snmp_syscontact ? {
    default => $::snmp_syscontact,
    ''      => "Root <root@$::fqdn>",
  }

  $syslocation = $::snmp_syslocation ? {
    default => $::snmp_syslocation,
    ''      => 'Unknown (configure the Puppet SNMP module)',
  }

  $read_community = $::snmp_read_community ? {
    default => $::snmp_read_community,
    ''      => 'public',
  }

  $read_restrict = $::snmp_read_restrict ? {
    default => $::snmp_read_commnunity,
    ''      => '',
  }

  $audit_only = $::snmp_audit_only ? {
    '' => $::audit_only ? {
      ''      => false,
      default => $::audit_only,
    },
    default => $::snmp_audit_only,
  }

  $masf_base_packages = [
    'SUNWmasf',
    'SUNWmasfr',
    'SUNWpiclh',
    'SUNWpiclr',
    'SUNWpiclu',
    'SUNWescdl',
  ]

  # Source: http://docs.oracle.com/cd/E19467-01/821-0654-10/chapter1.html
  $masf_platform_packages = $::productname ? {
    /Sun Fire V(125|210|215|240|245)/      => 'SUNWescpl',
    /Netra (210|240)/                      => 'SUNWescpl',
    /Sun Fire V(440|445)/                  => 'SUNWeschl',
    'Sun Fire T100'                          => [ 'SUNWeserl', 'SUNWespdl', ],
    /(Sun Fire|Netra) T200/                => [ 'SUNWesonl', 'SUNWespdl', ],
    /SPARC Enterprise T5(12|22|14|24|44)0/ => [ 'SUNWesonl', 'SUNWespdl', ],
    default                                  => undef,
  }

  $masf_packages = $masf_platform_packages ? {
    ''      => undef,
    default => flatten( [ $masf_base_packages, $masf_platform_packages ] ),
  }

}

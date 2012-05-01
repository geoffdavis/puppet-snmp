class snmp::data {
  $package_names = $::operatingsystem ? {
    'Solaris' => $::operatingsystemrelease ? {
      '5.10'  => ['SUNWsmagt', 'SUNWsmcmd', 'SUNWsmmgr' ],
      default => undef,
    },
    '(RedHat|CentOS)' => 'net-snmp',
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
    '(RedHat|CentOS)' => 'snmpd',
  }

  $config_directory = $::operatingsystem ? {
    'Solaris'         => '/etc/sma/snmp',
    '(RedHat|CentOS)' => '/etc/snmp',
    default           => '/etc/snmp',
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

  $audit_only = $::snmp_audit_only ? {
    '' => $::audit_only ? {
      ''      => false,
      default => $::audit_only,
    },
    default => $::snmp_audit_only,
  }

}

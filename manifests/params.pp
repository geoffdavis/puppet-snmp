# shared data for the snmp module
# Set $darwin_provider to undef to use the (unreliable) OS built-in.
class snmp::params(
  $darwin_provider  = 'macports',
) {
  validate_re($::osfamily,'^(Darwin|FreeBSD|RedHat|Solaris)$',
    "${::operatingsystem} unsupported")
  validate_re($darwin_provider,'^(apple|macports)$',
    '$darwin_provider must be set to "apple" or "macports"')


  $flags              = '-LS0-4d -Lf /dev/null'
  $pidfile            = '/var/run/snmpd.pid'
  $config_source      = undef
  $config_template    = 'snmp/snmpd.conf.erb'
  $sysconfig_template = $::osfamily ? {
    default  => undef,
    'RedHat' => 'snmp/redhat.sysconfig.erb',
  }
  $skip_nfs_in_host_resources = false

  $package_names = $::osfamily ? {
    default            => undef,
    /(RedHat|FreeBSD)/ => 'net-snmp',
    'Darwin'           => $darwin_provider ? {
      'macports' => 'net-snmp',
      default    => undef,
    },
    'Solaris' => $::kernelrelease ? {
      '5.10'  => ['SUNWsmagt', 'SUNWsmcmd', 'SUNWsmmgr' ],
      default => undef,
    },
  }

  $package_provider = $::osfamily ? {
    default   => undef,
    'Solaris' => $::kernelrelease ? {
      '5.10'  => 'sun',
      default => undef,
    },
    'Darwin'  => $darwin_provider ? {
      'macports' => 'macports',
      default    => undef,
    },
  }

  $service = $::osfamily ? {
    default   => 'snmpd',
    'Solaris' => $::kernelrelease ? {
      '5.10'  => 'svc:/application/management/sma:default',
      default => 'sma',
    },
    'Darwin'  => $darwin_provider ? {
      'macports' => 'org.macports.net-snmp',
      default    => 'org.net-snmp.snmpd',
    },
  }

  # kill off any competing snmp daemons that hijack the ports
  $service_disabled = $::osfamily ? {
    default   => undef,
    'Solaris' => ['netsnmpd','netsnmptrapd'],
    'Darwin'  => $darwin_provider ? {
      'macports' => 'org.net-snmp.snmpd',
      default    => 'org.macports.net-snmp',
    },
  }
  $config_file_absent = $::osfamily ? {
    default   => undef,
    'Solaris' => '/etc/opt/csw/snmp/snmpd.conf',
    'Darwin'  => $darwin_provider ? {
      'macports' => '/private/etc/snmp/snmpd.conf',
      default    => '/opt/local/etc/snmp/snmpd.conf',
    },
  }

  $config_directory = $::osfamily ? {
    default   => '/etc/snmp',
    'FreeBSD' => '/usr/local/etc/snmp',
    'Solaris' => '/etc/sma/snmp',
    'Darwin'  => $darwin_provider ? {
      'macports' => '/opt/local/etc/snmp',
      default    => '/private/etc/snmp',
    },
  }

  $config_file_owner = 'root'
  $config_file_group = $::osfamily ? {
    'Solaris'            => 'sys',
    /^(Darwin|FreeBSD)$/ => 'wheel',
    default              => 'root',
  }

  $sysdescr = join(delete_undef_values([
    $facts[':operatingsystem'],
    $facts['operatingsystemrelease'],
    $facts['hostname'],
    $facts['productname'],
  ]),' ')
  $syscontact     = "Root <root@${::fqdn}>"
  $syslocation    = 'Unknown (configure the Puppet SNMP module)'
  $read_community = 'public'
  $read_restrict  = undef

  ## Solaris MASF
  $masf_proxy         = true
  $masf_base_packages = [
    'SUNWmasf',
    'SUNWmasfr',
    'SUNWpiclh',
    'SUNWpiclr',
    'SUNWpiclu',
    'SUNWescdl',
  ]

  # Source: http://docs.oracle.com/cd/E19467-01/821-0654-10/chapter1.html
  $masf_platform_packages = $::osfamily ? {
    'Solaris' => $facts['productname'] ? {
      /Sun Fire V(125|210|215|240|245)/      => 'SUNWescpl',
      /Netra (210|240)/                      => 'SUNWescpl',
      /Sun Fire V(440|445)/                  => 'SUNWeschl',
      'Sun Fire T100'                        => ['SUNWeserl','SUNWespdl'],
      /(Sun Fire|Netra) T200/                => ['SUNWesonl','SUNWespdl'],
      /SPARC Enterprise T5(12|22|14|24|44)0/ => ['SUNWesonl','SUNWespdl'],
      default                                => undef,
    },
    default => undef,
  }

  # If we're not supporting a $::productname that's known, we provide
  # no packages, and therefore MASF management doesn't happen.
  $masf_packages = $masf_platform_packages ? {
    undef   => undef,
    default => delete_undef_values(union(
      $masf_base_packages,$masf_platform_packages)),
  }
}

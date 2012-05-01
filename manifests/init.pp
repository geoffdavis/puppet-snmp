# Class: snmp
#
# This class manages the snmpd agent service and it's configuration
# file, snmpd.conf. It is also capable of basic management of read-only
# access to snmp with the $read_community and $read_restrict parameters
#
# At the moment, it can allow one or more IP address or subnet access
# to the snmpd agent with a single pre-defined community name.
# Anything more complex than that will require a custom written
# configuration file, or wrappers around Augeus.
#
# Parameters:
#
# *[read_restrict]* is a string or array containing an ip address or
#   ip/netmask combo. If set, a line will be inserted allowing read-
#   only access by the ip address using the community specified in
#   read_community
class snmp (
  $audit_only  = $snmp::data::audit_only,
  $absent      = $snmp::data::absent,
  $disable     = $snmp::data::disable,
  $disableboot = $snmp::data::disableboot,
  $source      = $snmp::data::source,
  $template    = $snmp::data::template,
  $syscontact  = $snmp::data::syscontact,
  $sysdescr    = $snmp::data::sysdescr,
  $syslocation = $snmp::data::syslocation,
  $read_community = $snmp::data::read_community,
  $read_restrict = ''
) inherits snmp::data {

  $bool_audit_only = any2bool($audit_only)
  $bool_absent = any2bool($absent)
  $bool_disable = any2bool($disable)
  $bool_disableboot = any2bool($disableboot)

  $manage_service_enable = $smtp::bool_disableboot ? {
    true    => false,
    default => $ntp::bool_disable ? {
      true    => false,
      default => $ntp::bool_absent ? {
        true    => false,
        default => true,
      },
    },
  }

  $manage_service_ensure = $snmp::bool_disable ? {
    true    => 'stopped',
    default => $snmp::bool_absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_file = $snmp::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_file_source = $snmp::source ? {
    ''      => undef,
    default => $snmp::source,
  }

  $manage_file_content = $snmp::template ? {
    ''      => undef,
    default => template($snmp::template),
  }

  $manage_audit = $snmp::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $snmp::bool_audit_only ? {
    true  => false,
    false => true,
  }

  ### Set dependency order
  if $bool_absent {
    $package_before = undef
  } else {
    $package_before = [ Service['snmpd'], File['snmpd.conf'] ]
  }

  ### Manage resources

  package { $snmp::package_names :
    ensure => $snmp::manage_package,
    before => $package_before,
  }

  service { 'snmpd':
    ensure    => $snmp::manage_service_ensure,
    name      => $snmp::service,
    enable    => $snmp::manage_service_enable,
    hasstatus => $snmp::service_status,
  }

  file { 'snmpd.conf':
    ensure  => $snmp::file_ensure,
    path    => "$config_directory/snmpd.conf",
    mode    => '0755',
    owner   => $snmp::config_file_owner,
    group   => $snmp::config_file_group,
    notify  => Service['snmpd'],
    source  => $snmp::manage_file_source,
    content => $snmp::manage_file_content,
    replace => $snmp::manage_file_replace,
    audit   => $snmp::manage_file_audit,
  }

}

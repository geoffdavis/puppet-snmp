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
#
# *[masf_proxy]*
#   Only has an effect on Solaris. Sets up the old MASF hardware daemon
#   on SPARC platforms to work as an agentx subagent to snmpd
class snmp (
  $audit_only     = false,
  $absent         = false,
  $disable        = false,
  $disableboot    = false,
  $source         = $snmp::data::source,
  $template       = $snmp::data::template,
  $syscontact     = $snmp::data::syscontact,
  $sysdescr       = $snmp::data::sysdescr,
  $syslocation    = $snmp::data::syslocation,
  $read_community = $snmp::data::read_community,
  $read_restrict  = $snmp::data::read_restrict,
  $masf_proxy = true
) inherits snmp::data {

  validate_bool($audit_only)
  validate_bool($absent)
  validate_bool($disable)
  validate_bool($disableboot)

  $manage_service_enable = $disableboot ? {
    true    => false,
    false => $disable ? {
      true    => false,
      false => $absent ? {
        true    => false,
        false => true,
      },
    },
  }

  $manage_masf_service_enable = $snmp::masf_proxy ? {
    true  => $snmp::manage_service_enable,
    false => false,
  }

  # Force sun provider for SNMP packages for the time being
  # pkgutil provider needs special configuration to handle SUNW
  # packages
  $manage_package_provider = $::operatingsystem ? {
    solaris => 'sun',
    default => undef,
  }

  $manage_service_ensure = $disable ? {
    true    => 'stopped',
    default => $absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_masf_service_ensure = $snmp::masf_proxy ? {
    true  => $snmp::manage_service_ensure,
    false => 'stopped',
  }

  $manage_file = $snmp::absent ? {
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

  $manage_audit = $audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $audit_only ? {
    true  => false,
    false => true,
  }

  ### Set dependency order
  if $absent {
    $package_before = undef
  } else {
    $package_before = [ Service['snmpd'], File['snmpd.conf'] ]
  }

  ### Manage resources

  package { $snmp::package_names :
    ensure   => $snmp::manage_package,
    provider => $snmp::manage_package_provider,
    before   => $package_before,
  }

  service { 'snmpd':
    ensure    => $snmp::manage_service_ensure,
    name      => $snmp::service,
    enable    => $snmp::manage_service_enable,
    hasstatus => $snmp::service_status,
  }

  file { 'snmpd.conf':
    ensure  => $snmp::manage_file,
    path    => "${snmp::data::config_directory}/snmpd.conf",
    mode    => '0644',
    owner   => $snmp::config_file_owner,
    group   => $snmp::config_file_group,
    notify  => Service['snmpd'],
    source  => $snmp::manage_file_source,
    content => $snmp::manage_file_content,
    replace => $snmp::manage_file_replace,
    audit   => $snmp::manage_file_audit,
  }

  ### manage MASF resources on Select Sun platforms only

  if $snmp::data::masf_packages {

    if $snmp::masf_proxy {
      package { $snmp::data::masf_packages :
        ensure   => $snmp::manage_package,
        provider => $snmp::manage_package_provider,
        before   => [
          File['masf init.d'],
          File['masf snmpd.conf'],
        ],
      }

      file { 'masf init.d':
        ensure  => $manage_file,
        path    => '/etc/init.d/masfd',
        mode    => '0744', # as installed by sun, makes little sense
        owner   => $snmp::config_file_owner,
        group   => $snmp::config_file_group,
        notify  => Service['masfd'],
        source  => 'puppet:///modules/snmp/masfd',
        replace => $snmp::manage_file_replace,
        audit   => $snmp::manage_file_audit,
      }

      file { 'masf snmpd.conf' :
        ensure  => $manage_file,
        path    => '/etc/opt/SUNWmasf/conf/snmpd.conf',
        mode    => '0644',
        owner   => $snmp::config_file_owner,
        group   => $snmp::config_file_group,
        notify  => Service['masfd'],
        content => template('snmp/masf.snmpd.conf.erb'),
        replace => $snmp::manage_file_replace,
        audit   => $snmp::manage_file_audit,
      }

    }

    service { 'masfd':
      ensure    => $snmp::manage_masf_service_ensure,
      provider  => 'init',
      pattern   => '/opt/SUNWmasf/sbin/snmpd',
      enable    => $snmp::manage_masf_service_enable,
      hasstatus => false,
    }

  } # end MASF block

}

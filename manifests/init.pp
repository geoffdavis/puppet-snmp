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
  $audit_only        = false,
  $absent            = false,
  $disable           = false,
  $disableboot       = false,
  $source            = $snmp::params::source,
  $template          = $snmp::params::template,
  $syscontact        = $snmp::params::syscontact,
  $sysdescr          = $snmp::params::sysdescr,
  $syslocation       = $snmp::params::syslocation,
  $read_community    = $snmp::params::read_community,
  $read_restrict     = $snmp::params::read_restrict,
  $masf_proxy        = true,
) inherits snmp::params {

  # Normalize some un-tweakable params to this namespace.
  $config_directory  = $snmp::params::config_directory
  $config_file_owner = $snmp::params::config_file_owner
  $config_file_group = $snmp::params::config_file_group
  $masf_packages     = $snmp::params::masf_packages
  $manage_package    = $snmp::params::manage_package
  $package_names     = $snmp::params::package_names
  $service           = $snmp::params::service
  $service_status    = $snmp::params::service_status

  include stdlib

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

  $manage_masf_service_enable = $masf_proxy ? {
    true  => $manage_service_enable,
    false => false,
  }

  # Force sun provider for SNMP packages for the time being
  # pkgutil provider needs special configuration to handle SUNW
  # packages
  $manage_package_provider = $::operatingsystem ? {
    'Solaris' => 'sun',
    default   => undef,
  }

  $manage_service_ensure = $disable ? {
    true    => 'stopped',
    default => $absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_masf_service_ensure = $masf_proxy ? {
    true  => $manage_service_ensure,
    false => 'stopped',
  }

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_file_source = $source ? {
    ''      => undef,
    default => $source,
  }

  $manage_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  $manage_audit = $audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $audit_only ? {
    true  => false,
    false => true,
  }

  $sysconfig_content = join([
    "# Managed by Puppet ${module_name}.",
    'OPTIONS="-LS0-4d -Lf /dev/null -p /var/run/snmpd.pid"',
    "\n",
  ], "\n")

  ### Set dependency order
  if $absent {
    $package_before = undef
  } else {
    $package_before = [ Service['snmpd'], File['snmpd.conf'] ]
  }

  ### Manage resources

  package { $package_names :
    ensure   => $manage_package,
    provider => $manage_package_provider,
    before   => $package_before,
  }

  service { 'snmpd':
    ensure    => $manage_service_ensure,
    name      => $service,
    enable    => $manage_service_enable,
    hasstatus => $service_status,
  }

  file { 'snmpd.conf':
    ensure  => $manage_file,
    path    => "${config_directory}/snmpd.conf",
    mode    => '0644',
    owner   => $config_file_owner,
    group   => $config_file_group,
    notify  => Service['snmpd'],
    source  => $manage_file_source,
    content => $manage_file_content,
    replace => $manage_file_replace,
    audit   => $manage_audit,
  }

  ### manage MASF resources on Select Sun platforms only

  if $masf_packages {

    if $masf_proxy {
      package { $masf_packages :
        ensure   => $manage_package,
        provider => $manage_package_provider,
        before   => [
          File['masf init.d'],
          File['masf snmpd.conf'],
        ],
      }

      file { 'masf init.d':
        ensure  => $manage_file,
        path    => '/etc/init.d/masfd',
        mode    => '0744', # as installed by sun, makes little sense
        owner   => $config_file_owner,
        group   => $config_file_group,
        notify  => Service['masfd'],
        source  => 'puppet:///modules/snmp/masfd',
        replace => $manage_file_replace,
        audit   => $manage_audit,
      }

      file { 'masf snmpd.conf' :
        ensure  => $manage_file,
        path    => '/etc/opt/SUNWmasf/conf/snmpd.conf',
        mode    => '0644',
        owner   => $config_file_owner,
        group   => $config_file_group,
        notify  => Service['masfd'],
        content => template('snmp/masf.snmpd.conf.erb'),
        replace => $manage_file_replace,
        audit   => $manage_audit,
      }

    }

    service { 'masfd':
      ensure    => $manage_masf_service_ensure,
      provider  => 'init',
      pattern   => '/opt/SUNWmasf/sbin/snmpd',
      enable    => $manage_masf_service_enable,
      hasstatus => false,
    }

  }

  case $::osfamily {
    'RedHat': {
      file { '/etc/sysconfig/snmpd':
        ensure  => $manage_file,
        mode    => '0644',
        owner   => $config_file_owner,
        group   => $config_file_group,
        notify  => Service['snmpd'],
        content => $sysconfig_content,
        replace => $manage_file_replace,
        audit   => $manage_audit,
      }
    } 'FreeBSD': {
      $rc = {
        'snmpd_conffile' => { value => "${config_directory}/snmpd.conf" },
        'snmpd_enable'   => { value => true },
        'snmpd_flags'    => { value => '-a' },
      }
      create_resources('freebsd::rc_conf',$rc)
    } default: {
      # NOOP
    }
  }
}

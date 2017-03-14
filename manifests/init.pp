# Class: snmp
#)
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
#
# *[skip_nfs_in_host_resources]*
#   Enables/disables skipNFSInHostResources.  Must be a bool.
#   Defaults to false per the snmpd.conf man pages.
class snmp(
  $ensure                     = 'present',
  $syscontact                 = $snmp::params::syscontact,
  $sysdescr                   = $snmp::params::sysdescr,
  $syslocation                = $snmp::params::syslocation,
  $read_community             = $snmp::params::read_community,
  $read_restrict              = $snmp::params::read_restrict,
  $flags                      = $snmp::params::flags,
  $pidfile                    = $snmp::params::pidfile,
  $config_directory           = $snmp::params::config_directory,
  $config_file_disabled       = $snmp::params::config_file_disabled,
  $config_file_owner          = $snmp::params::config_file_owner,
  $config_file_group          = $snmp::params::config_file_group,
  $config_source              = $snmp::params::config_source,
  $config_template            = $snmp::params::config_template,
  $sysconfig_template         = $snmp::params::sysconfig_template,
  $manage_package             = $snmp::params::manage_package,
  $package_names              = $snmp::params::package_names,
  $service                    = $snmp::params::service,
  $package_provider           = $snmp::params::package_provider,
  $skip_nfs_in_host_resources = $snmp::params::skip_nfs_in_host_resources,
  $masf_packages              = $snmp::params::masf_packages,
  $masf_proxy                 = $snmp::params::masf_proxy,
) inherits snmp::params {

  validate_bool($skip_nfs_in_host_resources)
  validate_re($ensure,'^(ab|pre)sent$')

  # Normalize some un-tweakable params to this namespace.
  $ensure_file = $ensure ? { 'present' => 'file'     , default => $ensure   }
  $ensure_link = $ensure ? { 'present' => 'link'     , default => $ensure   }
  $ensure_dir  = $ensure ? { 'present' => 'directory', default => $ensure   }
  $ensure_svc  = $ensure ? { 'present' => 'running'  , default => 'stopped' }
  $enable_svc  = $ensure ? { 'present' => true       , default => false     }

  # $config_source overrides $config_template
  $config_content = $config_source ? {
    undef   => template($config_template),
    default => undef,
  }
  $config_source_real = $config_source ? {
    undef   => undef,
    default => $config_source,
  }

  $sysconfig_content = $sysconfig_template ? {
    undef   => undef,
    default => template($sysconfig_template),
  }

  # Solaris-specific vars
  $enable_masf_service = $masf_proxy ? {
    true  => $enable_svc,
    false => false,
  }
  $ensure_masf_service = $masf_proxy ? {
    true  => $ensure_svc,
    false => 'stopped',
  }

  ### Manage resources
  if $ensure == 'present' {
    Anchor['snmp::begin']->
    Class['::snmp::install']->
    Class['::snmp::config']~>
    Class['::snmp::service']->
    Anchor['snmp::end']
  } else {
    Anchor['snmp::begin']->
    Class['::snmp::service']->
    Class['::snmp::config']->
    Class['::snmp::install']->
    Anchor['snmp::end']
  }

  anchor { 'snmp::begin'    : }
  class  { '::snmp::install': }
  class  { '::snmp::config' : }
  class  { '::snmp::service': }
  anchor { 'snmp::end'      : }
}

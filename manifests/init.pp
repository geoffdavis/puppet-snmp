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
#
# *[skip_nfs_in_host_resources]*
#   Enables/disables skipNFSInHostResources.  Must be a bool.
#   Defaults to false per the snmpd.conf man pages.
class snmp (
  $audit_only                 = false,
  $absent                     = false,
  $disable                    = false,
  $disableboot                = false,
  $source                     = $snmp::params::source,
  $template                   = $snmp::params::template,
  $syscontact                 = $snmp::params::syscontact,
  $sysdescr                   = $snmp::params::sysdescr,
  $syslocation                = $snmp::params::syslocation,
  $read_community             = $snmp::params::read_community,
  $read_restrict              = $snmp::params::read_restrict,
  $masf_proxy                 = true,
  $skip_nfs_in_host_resources = false,
  $flags                      = '-LS0-4d -Lf /dev/null',
  $pidfile                    = '/var/run/snmpd.pid',
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

  validate_bool($audit_only)
  validate_bool($absent)
  validate_bool($disable)
  validate_bool($disableboot)
  validate_bool($skip_nfs_in_host_resources)

  $sea_proxy_isa_libdir = $::operatingsystem ? {
    'Solaris' => $::hardwareisa ? {
      'i386'  => '/usr/sfw/lib/amd64',
      'sparc' => '/usr/sfw/lib/sparcv9',
      default => undef,
    },
    default => undef,
  }
  $manage_service_enable = $disableboot ? {
    true  => false,
    false => $disable ? {
      true  => false,
      false => $absent ? { true => false, false => true },
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
    default => $absent ? { true => 'stopped', default => 'running' },
  }
  $manage_masf_service_ensure = $masf_proxy ? {
    true  => $manage_service_ensure,
    false => 'stopped',
  }
  $manage_solaris_netsnmp_ensure = 'stopped'
  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present',
  }
  $manage_file_source = $source ? {
    undef   => undef,
    default => $source,
  }
  $manage_file_content = $template ? {
    undef   => undef,
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
    "OPTIONS=\"${flags} -p ${pidfile}\"",
    "\n",
  ],"\n")

  ### Set dependency order
  $package_before = $absent ? {
    undef   => File['snmpd.conf'],
    default => undef,
  }

  ### Manage resources

  if $package_names {
    package { $package_names :
      ensure   => $manage_package,
      provider => $manage_package_provider,
      before   => $package_before,
    }
  }

  file { 'snmpd.conf':
    ensure  => $manage_file,
    path    => "${config_directory}/snmpd.conf",
    mode    => '0644',
    owner   => $config_file_owner,
    group   => $config_file_group,
    source  => $manage_file_source,
    content => $manage_file_content,
    replace => $manage_file_replace,
    audit   => $manage_audit,
    notify  => Service['snmpd'],
  }

  service { 'snmpd':
    ensure    => $manage_service_ensure,
    name      => $service,
    enable    => $manage_service_enable,
    hasstatus => $service_status,
  }

  case $::osfamily {
    'RedHat': {
      file { '/etc/sysconfig/snmpd':
        ensure  => $manage_file,
        mode    => '0644',
        owner   => $config_file_owner,
        group   => $config_file_group,
        content => $sysconfig_content,
        replace => $manage_file_replace,
        audit   => $manage_audit,
        notify  => Service['snmpd'],
      }
    } 'FreeBSD': {
      # Per `man 5 snmp_config`
      ensure_resource('file',$snmp::params::config_directory,{
        ensure => 'directory',
        before => File['snmpd.conf'],
      })
      create_resources('file_line',{
        'rc.conf snmpd_flags' => {
          line  => "snmpd_flags=\"${flags}\"",
          match => '^snmpd_flags=',
        },
        'rc.conf snmpd_pidfile' => {
          line  => "snmpd_pidfile=\"${pidfile}\"",
          match => '^snmpd_pidfile=',
        },
        'rc.conf snmpd_conffile' => {
          line  => "snmpd_conffile=\"${config_directory}/snmpd.conf\"",
          match => '^snmpd_conffile=',
        },
      },{
        path   => '/etc/rc.conf',
        notify => Service['snmpd'],
      })
    } 'Solaris': {
      # kill off the OpenCSW snmp daemons that hijack the ports
      service { ['netsnmpd','netsnmptrapd'] :
        ensure => $manage_solaris_netsnmp_ensure,
        before => Service['snmpd'],
      }

      ### manage MASF resources on Select Sun platforms only
      if $masf_packages {
        if $masf_proxy {
          ensure_packages($masf_packages,{
            ensure   => $manage_package,
            provider => $manage_package_provider,
          })
          create_resources('file',{
            'masf init.d'     => {
              path    => '/etc/init.d/masfd',
              mode    => '0744', # as installed by sun, makes little sense
              source  => 'puppet:///modules/snmp/masfd',
            },
            'masf snmpd.conf' => {
              path    => '/etc/opt/SUNWmasf/conf/snmpd.conf',
              mode    => '0644',
              content => template('snmp/masf.snmpd.conf.erb'),
            },
          },{
            ensure  => $manage_file,
            owner   => $config_file_owner,
            group   => $config_file_group,
            replace => $manage_file_replace,
            audit   => $manage_audit,
            notify  => Service['masfd'],
            require => Package[$masf_packages],
          })
        }
        service { 'masfd':
          ensure    => $manage_masf_service_ensure,
          provider  => 'init',
          pattern   => '/opt/SUNWmasf/sbin/snmpd',
          enable    => $manage_masf_service_enable,
          hasstatus => false,
        }
      }
    } default: {
      # NOOP
    }
  }
}

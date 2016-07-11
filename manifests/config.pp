# Should be called by init class only
class snmp::config {

  if $snmp::ensure == 'present' {
    File[$snmp::config_directory] -> File['snmpd.conf']
  } else {
    File['snmpd.conf'] -> File[$snmp::config_directory]
  }

  file { $snmp::config_directory :
    ensure  => $snmp::ensure_dir,
    mode    => '0755',
    owner   => $snmp::config_file_owner,
    group   => $snmp::config_file_group,
  }

  file { 'snmpd.conf':
    ensure  => $snmp::ensure_file,
    path    => "${snmp::config_directory}/snmpd.conf",
    mode    => '0644',
    owner   => $snmp::config_file_owner,
    group   => $snmp::config_file_group,
    source  => $snmp::config_source_real,
    content => $snmp::config_content,
  }

  # Make sure any competeing providers' config files are gone.
  if $snmp::config_file_absent {
    file { $snmp::config_file_absent :
      ensure => 'absent',
    }
  }

  case $::osfamily {
    'RedHat': {
      file { '/etc/sysconfig/snmpd':
        ensure  => $snmp::ensure_file,
        mode    => '0644',
        owner   => $snmp::config_file_owner,
        group   => $snmp::config_file_group,
        content => $snmp::sysconfig_content,
      }
    } 'FreeBSD': {
      # Per `man 5 snmp_config`
      ensure_resource('file',$snmp::config_directory,{
        ensure => 'directory',
        before => File['snmpd.conf'],
      })
      create_resources('file_line',{
        'rc.conf snmpd_flags' => {
          line  => "snmpd_flags=\"${snmp::flags}\"",
          match => '^snmpd_flags=',
        },
        'rc.conf snmpd_pidfile' => {
          line  => "snmpd_pidfile=\"${snmp::pidfile}\"",
          match => '^snmpd_pidfile=',
        },
        'rc.conf snmpd_conffile' => {
          line  => "snmpd_conffile=\"${snmp::config_directory}/snmpd.conf\"",
          match => '^snmpd_conffile=',
        },
      },{
        path => '/etc/rc.conf',
      })
    } 'Solaris': {

      ### manage MASF resources on Select Sun platforms only
      if undef != $snmp::masf_packages and $snmp::masf_proxy {
        create_resources('file',{
          '/etc/init.d/masfd'                 => {
            mode    => '0744', # as installed by sun, makes little sense
            source  => 'puppet:///modules/snmp/masfd',
          },
          '/etc/opt/SUNWmasf/conf/snmpd.conf' => {
            mode    => '0644',
            content => template('snmp/masf.snmpd.conf.erb'),
          },
        },{
          ensure  => $snmp::ensure_file,
          owner   => $snmp::config_file_owner,
          group   => $snmp::config_file_group,
          notify  => Service['masfd'],
          require => Package[$snmp::masf_packages],
        })
      }
    } default: {
      # NOOP
    }
  }
}

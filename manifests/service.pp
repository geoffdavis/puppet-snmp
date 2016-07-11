# Should be called by init class only
class snmp::service {

  service { 'snmpd':
    ensure => $snmp::ensure_svc,
    enable => $snmp::enable_svc,
    name   => $snmp::service,
  }

  # Sometimes we might be disabling one provider's daemon and turning
  # the other on.
  if $snmp::service_disabled {
    service { $snmp::service_disabled :
      ensure => 'stopped',
      enable => false,
      before => Service['snmpd'],
    }
  }

  # manage MASF resources on select Sun platforms only
  if $::osfamily == 'Solaris' and $snmp::masf_packages and $snmp::masf_proxy {
    service { 'masfd':
      ensure    => $snmp::ensure_masf_service,
      enable    => $snmp::enable_masf_service,
      provider  => 'init',
      pattern   => '/opt/SUNWmasf/sbin/snmpd',
      hasstatus => false,
      before    => Service['snmpd'],
    }
  }
}

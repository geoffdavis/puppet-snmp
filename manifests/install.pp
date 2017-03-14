# Should be called by init class only
class snmp::install {
  if $snmp::package_names {
    package { $snmp::package_names :
      provider => $snmp::package_provider,
    }
  }

  # manage MASF resources on select Sun platforms only
  if $::osfamily == 'Solaris' and
  undef != $snmp::masf_packages and
  $snmp::masf_proxy {
    ensure_packages($snmp::masf_packages,{
      provider => 'sun',
    })
  }
}

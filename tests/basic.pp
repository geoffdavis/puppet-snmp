include 'stdlib'

class { 'snmp' :
  read_community => 'public',
  read_restrict  => '169.228.44.0/25'
}

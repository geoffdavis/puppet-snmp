include 'stdlib'

class { 'snmp' :
  read_community => 'public',
  read_restrict  => '192.168.2.3'
}

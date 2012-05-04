include 'stdlib'

class { 'snmp' :
  syscontact     => 'Site Administrators <foo@bar.com> x12345',
  syslocation    => 'HappyFunCoLo Inc',
  read_community => 'public',
  read_restrict  => ['192.168.1.0/24', '10.0.0.5' ],
}

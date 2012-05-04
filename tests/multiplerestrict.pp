include 'stdlib'

class { 'snmp' :
  syscontact     => 'ANF Sysadmins <anf-sysadmins@anfmon.ucsd.edu>',
  syslocation    => 'SDSC Datacenter',
  read_community => 'public',
  read_restrict  => ['169.228.44.0/25', '132.239.4.0/24' ],
}

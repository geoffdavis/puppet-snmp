puppet-snmp
===========

Version: 0.1.5

Puppet module for managing SNMP agents

Requirements
------------

 - PuppetLabs stdlib

Goals
-----

Goals of this module are to support:

Solaris:

 - [SMA (Sun version of Net-SNMP)](http://docs.oracle.com/cd/E18752_01/html/817-3000/index.html)
 - make sure the old snmpdx doesn't conflict, install the seaProxy modules
 - support [MASF (sun hardware monitoring)](http://docs.oracle.com/cd/E19467-01/821-0654-10/chapter1.html) as a sub-agent to SMA

Linux:

 - Net-SNMP

Darwin:

 - Apple's net-snmp implementation

General:

 - Should be able to enable and disable
 - Templating should support SNMP v1 and v2c, extra credit for v3

Additional Background
---------------------

 - [SNMP on Solaris 10](http://blog.jrh.org/?p=4)

Examples
--------

See the tests directories for additional examples

Basic usage:

    include 'snmp'

More advanced:
    class { 'snmp' :
      syscontact  => "System Administrator <root@$::fqdn>",
      syslocation => 'Server room Rack 103a',
    }

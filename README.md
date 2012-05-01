puppet-snmp
===========

Puppet module for managing SNMP agents

Goals
-----

Goals of this module are to support:

Solaris:

 - [SMA (Sun version of Net-SNMP)](http://docs.oracle.com/cd/E18752_01/html/817-3000/index.html)
 - make sure the old snmpdx doesn't conflict, most likely stop it
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

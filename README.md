puppet-snmp
===========

Puppet module for managing SNMP agents

Goals
-----

Goals of this module are to support:

Solaris:

 - SMA (Sun version of Net-SNMP)
 - make sure snmpdx doesn't conflict, most likely stop it
 - support MASF (sun hardware monitoring) as a sub-agent to SMA

Linux:

 - Net-SNMP

Darwin:

 - Apple's net-snmp implementation

General:

 - Should be able to enable and disable
 - Templating should support SNMP v1 and v2c, extra credit for v3

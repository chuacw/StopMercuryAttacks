StopMercuryAttacks
==================

[Mercury SMTP](http://www.pmail.com/overviews/ovw_mercwin.htm) is an email server written in C/C++ by David Harris.


StopMercuryAttacks is a Delphi XE11 project group consisting of 3 plugin projects:
1. Mercury.Daemons.StopSMTPAttacks
2. Mercury.Daemons.StopPOP3Attacks
3. Mercury.Daemons.MapIPv6

that protects both the Mercury SMTP and POP3 server from the following issues:
1. connections from the same IP within 70 seconds to the SMTP server
2. clients presenting EHLO/HELO with an IP address to the SMTP server
3. multiple AUTHs from the same connection within 5 seconds to the SMTP server
4. multiple failed logins to the POP3 server from the same host

It also provides the following functionality:

1. IPv6 mapping, so that connections via IPv6 are possible.

After compilation, update the DAEMON.INI to the following:<br/>

[Daemons]<br />
POPAttack2  = C:\\PathName\\Mercury.Daemons.StopPOP3Attacks.dll<br/>
SMTPAttack2 = C:\\PathName\\Mercury.Daemons.StopSMTPAttacks.dll<br/>

If you wish to add support for IPv6, add the Mercury.Daemons.MapIPv6 plugin to the Daemons section as well.

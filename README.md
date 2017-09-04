StopMercuryAttacks
==================

<a href="http://www.pmail.com/overviews/ovw_mercwin.htm">Mercury SMTP</a> is an email server written in C/C++ by David Harris.


StopMercuryAttacks is a Delphi XE10 project group consisting of 3 plugin projects<br/>
1) Mercury.Daemons.StopSMTPAttacks<br />
2) Mercury.Daemons.StopPOP3Attacks<br />
3) Mercury.Daemons.MapIPv6

that protects both the Mercury SMTP and POP3 server from the following issues:<br/>
1) connections from the same IP within 70 seconds to the SMTP server<br/>
2) clients presenting EHLO/HELO with an IP address to the SMTP server<br/>
3) multiple AUTHs from the same connection within 5 seconds to the SMTP server<br/>
4) multiple failed logins to the POP3 server from the same host<br/>

It also provides the following functionality:

1) IPv6 mapping, so that connections via IPv6 are possible.<br/>


After compilation, update the DAEMON.INI to the following:<br/>

[Daemons]<br />
POPAttack2  = C:\PathName\Mercury.Daemons.StopPOP3Attacks.dll<br/>
SMTPAttack2 = C:\PathName\Mercury.Daemons.StopSMTPAttacks.dll<br/>


StopMercuryAttacks
==================

StopMercuryAttacks is a Delphi XE5 project group consisting of 2 projects<br/>
1) StopSMTPAttacks<br />
2) StopPOP3Attacks<br />

that protects both the Mercury SMTP and POP3 server from the following issues:<br/>
1) connections from the same IP within 70 seconds to the SMTP server<br/>
2) clients presenting EHLO/HELO with an IP address to the SMTP server<br/>
3) multiple AUTHs from the same connection within 5 seconds to the SMTP server<br/>
4) multiple failed logins to the POP3 server from the same host<br/>

After compilation, update the DAEMON.INI to the following:<br/>

[Daemons]<br />
POPAttack2  = C:\PathName\StopPOP3Attacks.dll<br/>
SMTPAttack2 = C:\PathName\StopSMTPAttacks.dll<br/>


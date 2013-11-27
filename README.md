StopMercuryAttacks
==================

StopMercuryAttacks is a Delphi XE5 project group consisting of 2 projects<br />
1) StopSMTPAttacks<br />
2) StopPOP3Attacks<br />

that prevents connections to the Mercury SMTP server from the same connection within 5 seconds by blacklisting these connections.

After compilation, update the DAEMON.INI to the following:<br/>

[Daemons]<br />
POPAttack2  = C:\PathName\StopPOP3Attacks.dll<br />
SMTPAttack2 = C:\PathName\StopSMTPAttacks.dll<br />


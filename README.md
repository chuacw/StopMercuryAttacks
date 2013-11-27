StopMercuryAttacks
==================

StopMercuryAttacks is a Delphi XE5 project group consisting of 2 projects
1) StopSMTPAttacks
2) StopPOP3Attacks

that prevents connections to the Mercury SMTP server from the same connection within 5 seconds by blacklisting these connections.

After compilation, update the DAEMON.INI to the following:

[Daemons]
POPAttack2  = C:\PathName\StopPOP3Attacks.dll
SMTPAttack2 = C:\PathName\StopSMTPAttacks.dll


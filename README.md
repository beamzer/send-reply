# send-reply
perl script to send reply mail from commandline

Simple script to generate a reply mail, the trick is to take the Message-ID from the original message and use that in the header part of the reply mail. You will need the MIME:Lite module, if you don't have it, install through CPAN.

`usage:  
send-reply.pl <to-address> <from-address> <Subject> <msgid> filename`

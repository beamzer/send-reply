#!/usr/bin/perl
#
# (c) Ewald 20191221
#
## Script to send a reply e-mail from commandline
#
# NB, user who sends via this script should be configured with
# Tusername in sendmail.cf otherwise the recipient will see a
# X-Authentication-warning: in the headers
#
#use strict;
use FileHandle;
use MIME::Lite;

my $DEBUG = 0;
my $content;

$TO = shift;
if (($TO eq "-h") || ($#ARGV<1)) {
   print "Send an e-mail from a specified e-mail address\n";
   print "usage: $ARGV[0] <to-address> <from-address> <Subject> <msgid> filename\n";
   print "only got $#ARGV arguments on commandline\n";
   exit 0;
   }

if ($TO eq "-d") {
   $DEBUG = 1;
   $TO = shift;
   }

($FROM = shift) || die "usage: $ARGV[0] <to-address> <from-address> <Subject> <msgid> filename\n";
($SUBJECT = shift) || die "usage: $ARGV[0] <to-address> <from-address> <Subject> filename\n";
($MSGID = shift) || die "usage: $ARGV[0] <to-address> <from-address> <Subject> <msgid> filename\n";
($filename = shift) || die "usage: $ARGV[0] <to-address> <from-address> <Subject> <msgid> filename\n";

open(my $fh, '<', $filename) or die "cannot open file $filename";
{
  local $/;
  $content = <$fh>;
  }
close($fh);

my @dayofweek = (qw(Sun Mon Tue Wed Thu Fri Sat));
my @monthnames = (qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec));
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday, $isdst) = localtime();
$year += 1900;
my $ran_num = int(rand(100000)); #This is a 5 figure random number which ensures the MID is really, really unique!
my $MYMSGID = sprintf("<%04d.%s.%02d.%s.%02d.%02d.%02d.%05d\@yourcompany.nl>", $year, $monthnames[$mon], $mday, $dayofweek[$wday], $hour, $min, $sec, $ran_num);

$msg=new MIME::Lite
        'To'      =>$TO,
        'From'    =>$FROM,
        'Subject' =>$SUBJECT,
        'Type'    =>'text/plain',
        'Message-ID' => $MYMSGID,
        'References' => $MSGID,
        'In-Reply-To:' => $MSGID,
        'Encoding'   =>'7bit',
        'Data'       =>"$content";

sendmail MIME::Lite "/usr/lib/sendmail", "-t", "-oi", "-oem","-f$FROM";

if ($DEBUG) {
        $msg->print(\*STDOUT);
        }
else {
        print STDERR "Sending...\n";
        $msg->send();
        print STDERR "done!\n";
        }


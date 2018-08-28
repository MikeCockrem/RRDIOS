#!/usr/bin/perl
# M. Cockrem - mikecockrem@gmail.com

use strict;
use warnings FATAL => 'all';
use diagnostics;
my $basedir = ".";

open( my $in, "/usr/bin/iostat -k -d -x 1 1 |") or die "Error, Can't read IOSTAT command: Quitting\n";

        while (<$in>) {

                chomp;
                next if /^(Linux|Device|\s*\Z)/;
                my @inarray = ( my $dev, my $rrqm, my $wrqm, my $rs, my $ws, my $rkb, my $wkb, my $avgrqsz, my $avgqusz, my $await, my $svctm, my $util ) = split/\s+/;
                next unless @inarray == 12;

                # Join inarray skipping "dev" (0) - integers only
                my @jarray = @inarray[1,2,3,4,5,6,7,8,9,10,11];
                # Join to array with ":" delimiters
                my $datajoin = join(":",@jarray);
                my $filehandle = "$basedir/$inarray[0]_db.rrd";

                if ( ! -f $filehandle ) {
                        #next if ( -e $filehandle );

                        system ("/usr/bin/rrdtool create $basedir/$inarray[0]_db.rrd --step 60 \\
                                DS:rrqm:GAUGE:120:0.00:99.99    \\
                                DS:wrqm:GAUGE:120:0.00:99.99     \\
                                DS:rs:GAUGE:120:0.00:99.99      \\
                                DS:ws:GAUGE:120:0.00:99.99      \\
                                DS:rkb:GAUGE:120:0.00:99.99     \\
                                DS:wkb:GAUGE:120:0.00:99.99     \\
                                DS:avgrqsz:GAUGE:120:0.00:99.99 \\
                                DS:avgqusz:GAUGE:120:0.00:99.99 \\
                                DS:await:GAUGE:120:0.00:99.99   \\
                                DS:svctm:GAUGE:120:0.00:99.99   \\
                                DS:util:GAUGE:120:0.00:99.99    \\
                                RRA:MAX:0.5:1:1500
                        ");
                } else {
                        system ("/usr/bin/rrdtool  update $basedir/$inarray[0]_db.rrd --template rrqm:wrqm:rs:ws:rkb:wkb:avgrqsz:avgqusz:await:svctm:util N:$datajoin");
                }
        }
close($in) || die "Error closing IOSTAT read";
exit(0);

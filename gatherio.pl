#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use diagnostics;
my $basedir = ".";
my $flag = $ARGV[0];

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

                if (defined $ARGV[0]){
                        if ( $flag == 1 )
                        {
                                system ("rrdtool graph '$inarray[0]_graph.png' --title \"$inarray[0] I/O Metrics\" \\
                                --start -86400 --end now --slope-mode --watermark \"`date`\" --lower-limit 0 \\
                                --x-grid MINUTE:10:HOUR:1:MINUTE:120:0:%R --alt-y-grid --rigid \\
                                'DEF:a=$inarray[0]_db.rrd:rrqm:LAST'   \\
                                'DEF:b=$inarray[0]_db.rrd:wrqm:LAST'   \\
                                'DEF:c=$inarray[0]_db.rrd:rs:LAST'             \\
                                'DEF:d=$inarray[0]_db.rrd:ws:LAST'             \\
                                'DEF:e=$inarray[0]_db.rrd:rkb:LAST'            \\
                                'DEF:f=$inarray[0]_db.rrd:wkb:LAST'    \\
                                'DEF:g=$inarray[0]_db.rrd:avgrqsz:LAST'        \\
                                'DEF:h=$inarray[0]_db.rrd:avgqusz:LAST'        \\
                                'DEF:i=$inarray[0]_db.rrd:await:LAST'  \\
                                'DEF:j=$inarray[0]_db.rrd:svctm:LAST'  \\
                                'DEF:k=$inarray[0]_db.rrd:util:LAST'   \\
                                'GPRINT:a:LAST:\"RRQM\/s\\: %5.2lf\"'     \\
                                'GPRINT:b:LAST:\"WRQM/s\\: %5.2lf\"'       \\
                                'GPRINT:c:LAST:\"r/s\\: %5.2lf\"'  \\
                                'GPRINT:d:LAST:\"w/s\\: %5.2lf\"'  \\
                                'GPRINT:e:LAST:\"rkB/s\\: %5.2lf\"'        \\
                                'GPRINT:f:LAST:\"wkB/s\\: %5.2lf\"'        \\
                                'GPRINT:g:LAST:\"avgrq-sz\\: %5.2lf\"'     \\
                                'GPRINT:h:LAST:\"Avgqu-sz\\: %5.2lf\"'     \\
                                'GPRINT:i:LAST:\"AWAIT\\: %5.2lf\"'        \\
                                'GPRINT:j:LAST:\"SVCTM\\: %5.2lf\"'        \\
                                'GPRINT:k:LAST:\"UTIL\\: %5.2lf\"' \\
                                'LINE1:a#336666:RRQM/s:STACK'         \\
                                'LINE1:b#FFFF99:WRQM/s:STACK'         \\
                                'LINE1:c#3399CC:r/s:STACK'    \\
                                'LINE1:d#3300FF:w/s:STACK'    \\
                                'LINE1:e#000066:rkB/s:STACK'  \\
                                'LINE1:f#0099CC:wkB/s:STACK'  \\
                                'LINE1:g#FF3333:avgrq-sz:STACK'       \\
                                'LINE1:h#CCFF99:Avgqu-sz:STACK'       \\
                                'LINE1:i#000000:AWAIT:STACK'  \\
                                'LINE1:j#336600:SVCTM:STACK'  \\
                                'AREA:k#FFC0CB:UTIL' \\
                                ");
                        }
                }

                if ( ! -f $filehandle ) {
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
                                RRA:MIN:0.5:1:210240    \\
                                RRA:MAX:0.5:1:210240    \\
                                RRA:AVERAGE:0.5:1:210240 \\
                                RRA:LAST:0.5:1:210240 \\
                        ");
                } else {
                        system ("/usr/bin/rrdtool  update $basedir/$inarray[0]_db.rrd --template rrqm:wrqm:rs:ws:rkb:wkb:avgrqsz:avgqusz:await:svctm:util N:$datajoin");
                #       print "/usr/bin/rrdtool  update $basedir/$inarray[0]_db.rrd --template rrqm:wrqm:rs:ws:rkb:wkb:avgrqsz:avgqusz:await:svctm:util N:$datajoin\n";
                }
        }
close($in) || die "Error closing IOSTAT read";
exit(0);

#!/usr/bin/perl
########################################################################################################
#
# Dieses Skript erzeugt eine Datei im iCalender-Format mit den Abfuhrterminen der Entsorgungsbetriebe
# der Stadt Ulm (EBU). Ein Aufruf erzeugt den Kalender für einen Abfuhrbezirk und eine Kombination
# von Tonnentypen:Restmüll 2-wöchig / 4-wöchig, Biotonne, Gelber Sack und Papiertonne (EBU).
# 
# Das Format des Aufrufs kann nit einem Aufruf des Skripts mit der Option "-h" angezeigt werden.
#
# Der Abfuhrkalander des aktuellen Jahrs ist am Ende des Skripts Datei, nach der Trenzeile "__DATA__" 
# angehängt, eine Zeile pro Tag, in kalendarischer Reihenfolge, 01.01. bis 31.12.
#
# Das Format der Datenzeilen entspricht dem Format des Abfuhrkalenders im Faltbaltt "Müllinfo 2011":
#
#  <tag> <wochentag> Christbaumabfuhr <bezirk1>-<bezirk1>
#  oder
#  <tag> <wochentag> <restmüll2> <restmüll4> <biomüll> <papier> <gelberSack>
#      
#     <tag>:        Tag des Monats
#     <wochentag>:  Wochentag: Mo, Di, Mi,...
#     <restmüll2>:  Bezirke, in denen Restmülltonnen mit zweiwöchiger Leerung geleert werden
#     <restmüll4>:  Bezirke, in denen Restmülltonnen mit vierwöchiger Leerung geleert werden
#     <biomüll>:    Bezirke, in denen Biomülltonnen geleert werden
#     <papier>:     Bezirke, in denen Papiertonnen geleert werden
#     <gelberSack>: Bezirke, in denen gelbe Säcke abgeholt werden
#                                    
# Die Bezirke für einen Abfuhrtyp werden als Liste von Bezirksnummern, getrennt durch Kommas, 
# ohne Leerzeichen angegeben. 
#
# Beispiel, 31.01.2011:
#
#  31 Mo 6 6 1,6 ?? 1
#        | |  |  |  |
#        | |  |  |  +- Gelber Sack: Bezirk 1
#        | |  |  +- Papiertonne: keine Leerung
#        | |  +- Biomüll: Bezirk 1 und 6
#        | +- Restmüll 4-wö.: Bezirk 6
#        +- Restmüll: 2-wö., Bezirk 6
# 
# Das Skript wurde unter Linux/Debian entwickelt und getestet. Die Kalenderdatei wurde für Bezirk 3 
# mit Thunderbird unter Linux/Debian erfolgreich getestet.
#
########################################################################################################
#
# Autor: 
#    Rainer Unseld
#
########################################################################################################
#
# Lizenzhinweis: 
#    Dieses Werk bzw. Inhalt steht unter einer Creative Commons Namensnennung 3.0 Deutschland Lizenz.
#    Siehe: http://creativecommons.org/licenses/by/3.0/de/
#
########################################################################################################

# use strict;
# require 5.002;

use English;
#use Switch;
   use Date::ICal;
   use Data::ICal;
   use Data::ICal::Entry::Event;
   use Data::ICal::Entry::Alarm::Display;
#------------------------------------------------------------------------------------
# Daten
#------------------------------------------------------------------------------------
%text=("r2", "Restmüll, 2 - wö.",
       "r4", "Restmüll, 4 - wö.",
       "b",  "Biomüll",
       "g",  "Gelber Sack",
       "p",  "Papier");
#------------------------------------------------------------------------------------
# Funktionen
#------------------------------------------------------------------------------------
sub help
{
   @a = split (/\//, $0);
   print "Aufruf: $a[$#a] -b bezirk -t r2|r4|b|p|g [-a hh]\n";
   print "        -b Abfuhrbezirk\n";
   print "        -t Tonnentypen, z.B. r2bg = Restmüll 2-wöchig, Bio, Gelber Sack\n";
   print "        -a Alarm am Vortag um hh Uhr\n";
   print "        -h Gibt diesen Text aus\n";
}
#------------------------------------------------------------------------------------
# Start of Program
#------------------------------------------------------------------------------------
   if ($#ARGV < 0) {
       # Script invoked with no command-line args?
       help ();
       exit;        # Exit and explain usage, if no argument(s) given.
   }

   $bezirk = 0;
   $tonne = "";
   $alarm_hour = -1;
   while ($#ARGV >= 0){
      if (substr($ARGV[0], 0, 1) eq "-"){
         $opt = substr($ARGV[0], 1, 1);
         if ($opt eq "h"){
            help ();
            exit;
         }elsif ($opt eq "b"){
            shift @ARGV;
            $bezirk = $ARGV[0];
         }elsif ($opt eq "t"){
            shift @ARGV;
            $tonne = lc ($ARGV[0]);
         }elsif ($opt eq "a"){
            shift @ARGV;
            $alarm_hour = $ARGV[0];
         }else {
            print "Invalid option: $ARGV[0]\n";
            help();
            exit;
         }
      }else{
         print "Invalid option: $ARGV[0]\n";
         help();
         exit;
      }
      shift @ARGV;
   }
   if ($bezirk == 0 || $tonne eq ""){
      help ();
      exit;
   }
   
   my $calendar = Data::ICal->new();
   $calendar->add_properties(
            method      => "PUBLISH",
   );
   $mon = 1;
   $day = 0;
   my $year = 2012;
   while (defined ($line=<DATA>)){
      chomp $line;
      @a = split (/ /, $line);
      if ($#a > 2 && $a[0] =~ /^\d{2}/) {
         if ($day > $a[0]){
            $mon++;
            if ($mon == 13){
               $mon = 1;
               $year++;
            }
         }
         $day = $a[0];
         #$col = 1;         # Spalte
         #print $a[2],"\n";
         for ($col=2; $col<=$#a; $col++){
            if ($a[$col] eq "Christbaumabfuhr"){
               @b = split (/-/, $a[$col+1]);
               if ($bezirk >= $b[0] and $bezirk <= $b[1]){
                  my $event = Data::ICal::Entry::Event->new();
                  $ds = sprintf "%4d%02d%02d", $year, $mon, $day;
                  $de = sprintf "%4d%02d%02d", $year, $mon, $day+1;
                  $uid = sprintf "EBU-%s-Christbaum", $ds;
                  $event->add_properties(
                        class       => "PUBLIC",
                        transp      => "TRANSPARENT",
                        uid         => $uid,
                        summary     => "Christbaumabfuhr",
                        dtstart => [$ds,  { value => 'DATE' } ],
                        dtend   => [$de,  { value => 'DATE' } ],
                        dtstamp     => Date::ICal->new( epoch => time )->ical( localtime => 1 ),
                  );
                  if ($alarm_hour >= 0){
                     my $valarm = Data::ICal::Entry::Alarm::Display->new();
                     my $offset = sprintf "-PT%02dH", 24-$alarm_hour;
                     $valarm->add_properties(
                           description => "Christbaumabfuhr",
                           trigger   => [ $offset,
                                          { value => 'DURATION' } ],
                     );
                     $event->add_entry($valarm);
                  }
                  $calendar->add_entry($event);
               }
            }else{
               @b = split (/,/, $a[$col]);
               for ($i=0; $i<=$#b; $i++){
                  if ($b[$i] == $bezirk){
                     if ($col == 2) {
                        $t = "r2";
                     }elsif ($col == 3) {
                        $t = "r4";
                     }elsif ($col == 4) {
                        $t = "b";
                     }elsif ($col == 5) {
                        $t = "p";
                     }elsif ($col == 6) {
                        $t = "g";
                     }else{
                        die "Fehler $line";
                     }
                     if (index($tonne, $t) >= 0){
                        $summary = $text{$t};
                        my $event = Data::ICal::Entry::Event->new();
                        $ds = sprintf "%4d%02d%02d", $year, $mon, $day;
                        $de = sprintf "%4d%02d%02d", $year, $mon, $day+1;
                        $uid = sprintf "EBU-%s-%02d-%02s", $ds, $bezirk, $col;
                        $event->add_properties(
                              class       => "PUBLIC",
                              #organizer   => "MAILTO:foo\@bar",
                              #location    => "Phone call",
                              #priority    => 5,
                              transp      => "TRANSPARENT",
                              #sequence    => 0,
                              uid         => $uid,
                              summary     => $summary,
                              #description => "FreeFormText.\\nMore FreeFormText.\\n\\n",
                              dtstart => [$ds,  { value => 'DATE' } ],
                              dtend   => [$de,  { value => 'DATE' } ],
                              dtstamp     => Date::ICal->new( epoch => time )->ical( localtime => 1 ),
                        );
                        if ($alarm_hour >= 0){
                           my $valarm = Data::ICal::Entry::Alarm::Display->new();
                           my $offset = sprintf "-PT%02dH", 24-$alarm_hour;
                           $valarm->add_properties(
                                 description => $summary,
                                 trigger   => [ $offset,
                                                { value => 'DURATION' } ],
                           );
                           $event->add_entry($valarm);
                        }
                        $calendar->add_entry($event);
                     }
                  }
               }
            }
         }
      }
   }
   print $calendar->as_string;

__DATA__
01 So Neujahr
02 Mo 6 6 1,6 – 1
03 Di 7 7 2,7 – 2
04 Mi 8 8 3,8 – 3
05 Do 9 9 4,9 – 4
06 Fr Hl. Drei Könige
07 Sa 10 10 5,10 – 5
08 So – – – – –
09 Mo 1 1 – 6 6
10 Di 2 2 – 7 7
11 Mi 3 3 – 8 8
12 Do 4 4 – 9 9
13 Fr 5 5 – 10 10
14 Sa Christbaumabfuhr 1-5
15 So – – – – –
16 Mo 6 – 1,6 – 1
17 Di 7 – 2,7 – 2
18 Mi 8 – 3,8 – 3
19 Do 9 – 4,9 – 4
20 Fr 10 – 5,10 – 5
21 Sa Christbaumabfuhr 6-10
22 So – – – – –
23 Mo 1 – – 1 6
24 Di 2 – – 2 7
25 Mi 3 – – 3 8
26 Do 4 – – 4 9
27 Fr 5 – – 5 10
28 Sa – – – – –
29 So – – – – –
30 Mo 6 6 1,6 – 1
31 Di 7 7 2,7 – 2
01 Mi 8 8 3,8 – 3
02 Do 9 9 4,9 – 4
03 Fr 10 10 5,10 – 5
04 Sa – – – – –
05 So – – – – –
06 Mo 1 1 – 6 6
07 Di 2 2 – 7 7
08 Mi 3 3 – 8 8
09 Do 4 4 – 9 9
10 Fr 5 5 – 10 10
11 Sa – – – – –
12 So – – – – –
13 Mo 6 – 1,6 – 1
14 Di 7 – 2,7 – 2
15 Mi 8 – 3,8 – 3
16 Do 9 – 4,9 – 4
17 Fr 10 – 5,10 – 5
18 Sa – – – – –
19 So – – – – –
20 Mo 1 – – 1 6
21 Di 2 – – 2 7
22 Mi 3 – – 3 8
23 Do 4 – – 4 9
24 Fr 5 – – 5 10
25 Sa – – – – –
26 So – – – – –
27 Mo 6 6 1,6 1
28 Di 7 7 2,7 – 2
29 Mi 8 8 3,8 – 3
01 Do 9 9 4,9 – 4
02 Fr 10 10 5,10 – 5
03 Sa – – – – –
04 So – – – – –
05 Mo 1 1 – 6 6
06 Di 2 2 – 7 7
07 Mi 3 3 – 8 8
08 Do 4 4 – 9 9
09 Fr 5 5 – 10 10
10 Sa – – – – –
11 So – – – – –
12 Mo 6 – 1,6 – 1
13 Di 7 – 2,7 – 2
14 Mi 8 – 3,8 – 3
15 Do 9 – 4,9 – 4
16 Fr 10 – 5,10 – 5
17 Sa – – – – –
18 So – – – – –
19 Mo 1 – – 1 6
20 Di 2 – – 2 7
21 Mi 3 – – 3 8
22 Do 4 – – 4 9
23 Fr 5 – – 5 10
24 Sa – – – – –
25 So – – – – –
26 Mo 6 6 1,6 – 1
27 Di 7 7 2,7 – 2
28 Mi 8 8 3,8 – 3
29 Do 9 9 4,9 – 4
30 Fr 10 10 5,10 – 5
31 Sa – – – – –
01 So – – – – –
02 Mo 1 1 – 6 6
03 Di 2 2 – 7 7
04 Mi 3 3 – 8 8
05 Do 4 4 – 9 9
06 Fr Karfreitag
07 Sa 5 5 – 10 10
08 So Ostersonntag
09 Mo Ostermontag
10 Di 6 – 1,6 – 1
11 Mi 7 – 2,7 – 2
12 Do 8 – 3,8 – 3
13 Fr 9 – 4,9 – 4
14 Sa 10 – 5,10 – 5
15 So – – – – –
16 Mo 1 – – 1 6
17 Di 2 – – 2 7
18 Mi 3 – – 3 8
19 Do 4 – – 4 9
20 Fr 5 – – 5 10
21 Sa – – – – –
22 So – – – – –
23 Mo 6 6 1,6 – 1
24 Di 7 7 2,7 – 2
25 Mi 8 8 3,8 – 3
26 Do 9 9 4,9 – 4
27 Fr 10 10 5,10 – 5
28 Sa – – – – –
29 So – – – – –
30 Mo 1 1 – 6 6
01 Di Maifeiertag
02 Mi 2 2 – 7 7
03 Do 3 3 – 8 8
04 Fr 4 4 – 9 9
05 Sa 5 5 – 10 10
06 So – – – – –
07 Mo 6 – 1,6 – 1
08 Di 7 – 2,7 – 2
09 Mi 8 – 3,8 – 3
10 Do 9 – 4,9 – 4
11 Fr 10 – 5,10 – 5
12 Sa – – – – –
13 So – – – – –
14 Mo 1 – – 1 6
15 Di 2 – – 2 7
16 Mi 3 – – 3 8
17 Do Chr. Himmelfahrt
18 Fr 4 – – 4 9
19 Sa 5 – – 5 10
20 So – – – – –
21 Mo 6 6 1,6 – 1
22 Di 7 7 2,7 – 2
23 Mi 8 8 3,8 – 3
24 Do 9 9 4,9 – 4
25 Fr 10 10 5,10 – 5
26 Sa – – – – –
27 So Pfingstsonntag
28 Mo Pfingstmontag
29 Di 1 1 – 6 6
30 Mi 2 2 – 7 7
31 Do 3 3 – 8 8
01 Fr 4 4 – 9 9
02 Sa 5 5 – 10 10
03 So – – – – –
04 Mo 6 – 1,6 – 1
05 Di 7 – 2,7 – 2
06 Mi 8 – 3,8 – 3
07 Do Fronleichnam
08 Fr 9 – 4,9 – 4
09 Sa 10 – 5,10 – 5
10 So – – – – –
11 Mo 1 – 1,6 1 6
12 Di 2 – 2,7 2 7
13 Mi 3 – 3,8 3 8
14 Do 4 – 4,9 4 9
15 Fr 5 – 5,10 5 10
16 Sa – – – – –
17 So – – – – –
18 Mo 6 6 1,6 – 1
19 Di 7 7 2,7 – 2
20 Mi 8 8 3,8 – 3
21 Do 9 9 4,9 – 4
22 Fr 10 10 5,10 – 5
23 Sa – – – – –
24 So – – – – –
25 Mo 1 1 1,6 6 6
26 Di 2 2 2,7 7 7
27 Mi 3 3 3,8 8 8
28 Do 4 4 4,9 9 9
29 Fr 5 5 5,10 10 10
30 Sa – – – – –
01 So – – – – –
02 Mo 6 – 1,6 – 1
03 Di 7 – 2,7 – 2
04 Mi 8 – 3,8 – 3
05 Do 9 – 4,9 – 4
06 Fr 10 – 5,10 – 5
07 Sa – – – – –
08 So – – – – –
09 Mo 1 – 1,6 1 6
10 Di 2 – 2,7 2 7
11 Mi 3 – 3,8 3 8
12 Do 4 – 4,9 4 9
13 Fr 5 – 5,10 5 10
14 Sa – – – – –
15 So – – – – –
16 Mo 6 6 1,6 – 1
17 Di 7 7 2,7 – 2
18 Mi 8 8 3,8 – 3
19 Do 9 9 4,9 – 4
20 Fr 10 10 5,10 – 5
21 Sa – – – – –
22 So – – – – –
23 Mo 1 1 1,6 6 6
24 Di 2 2 2,7 7 7
25 Mi 3 3 3,8 8 8
26 Do 4 4 4,9 9 9
27 Fr 5 5 5,10 10 10
28 Sa – – – – –
29 So – – – – –
30 Mo 6 – 1,6 – 1
31 Di 7 – 2,7 – 2
Abfuhrkalender 2012
Juli
2012
August
2012
September
2012
www.ebu-ulm.de
Oktober
2012
November
2012
Dezember
2012
Januar
2013
Ihre Abfuhrbezirksnummer finden Sie auf Ihrem Abfallgebührenbescheid, im Straßenverzeichnis in der Informationsbroschüre
Müllinfo 2012 und im Internet.
Bitte beachten Sie! Restmüll-, Biomüll-, Blaue Tonnen und Gelbe Säcke müssen am Abfuhrtag bis 6.00 Uhr am Straßenrand bereitgestellt und die Deckel
der Mülltonnen geschlossen sein. Vom 11. Juni bis 14. September findet die Biomüllabfuhr wöchentlich statt.
Restmüll, 2 - wö.
Biomüll
Gelber Sack
Papier
Restmüll, 4 - wö.
Restmüll, 2 - wö.
Biomüll
Gelber Sack
Papier
Restmüll, 4 - wö.
Restmüll, 2 - wö.
Biomüll
Gelber Sack
Papier
Restmüll, 4 - wö.
Restmüll, 2 - wö.
Biomüll
Gelber Sack
Papier
Restmüll, 4 - wö.
Restmüll, 2 - wö.
Biomüll
Gelber Sack
Papier
Restmüll, 4 - wö.
Restmüll, 2 - wö.
Biomüll
Gelber Sack
Papier
Restmüll, 4 - wö.
Restmüll, 2 - wö.
Biomüll
Gelber Sack
Papier
Restmüll, 4 - wö.
01 Mi 8 – 3,8 – 3
02 Do 9 – 4,9 – 4
03 Fr 10 – 5,10 – 5
04 Sa – – – – –
05 So – – – – –
06 Mo 1 – 1,6 1 6
07 Di 2 – 2,7 2 7
08 Mi 3 – 3,8 3 8
09 Do 4 – 4,9 4 9
10 Fr 5 – 5,10 5 10
11 Sa – – – – –
12 So – – – – –
13 Mo 6 6 1,6 – 1
14 Di 7 7 2,7 – 2
15 Mi 8 8 3,8 – 3
16 Do 9 9 4,9 – 4
17 Fr 10 10 5,10 – 5
18 Sa – – – – –
19 So – – – – –
20 Mo 1 1 1,6 6 6
21 Di 2 2 2,7 7 7
22 Mi 3 3 3,8 8 8
23 Do 4 4 4,9 9 9
24 Fr 5 5 5,10 10 10
25 Sa – – – – –
26 So – – – – –
27 Mo 6 – 1,6 – 1
28 Di 7 – 2,7 – 2
29 Mi 8 – 3,8 – 3
30 Do 9 – 4,9 – 4
31 Fr 10 – 5,10 – 5
01 Sa – – – – –
02 So – – – – –
03 Mo 1 – 1,6 1 6
04 Di 2 – 2,7 2 7
05 Mi 3 – 3,8 3 8
06 Do 4 – 4,9 4 9
07 Fr 5 – 5,10 5 10
08 Sa – – – – –
09 So – – – – –
10 Mo 6 6 1,6 – 1
11 Di 7 7 2,7 – 2
12 Mi 8 8 3,8 – 3
13 Do 9 9 4,9 – 4
14 Fr 10 10 5,10 – 5
15 Sa – – – – –
16 So – – – – –
17 Mo 1 1 – 6 6
18 Di 2 2 – 7 7
19 Mi 3 3 – 8 8
20 Do 4 4 – 9 9
21 Fr 5 5 – 10 10
22 Sa – – – – –
23 So – – – – –
24 Mo 6 – 1,6 – 1
25 Di 7 – 2,7 – 2
26 Mi 8 – 3,8 – 3
27 Do 9 – 4,9 – 4
28 Fr 10 – 5,10 – 5
29 Sa – – – – –
30 So – – – – –
01 Mo 1 – – 1 6
02 Di 2 – – 2 7
03 Mi Tag d. Dt. Einheit
04 Do 3 – – 3 8
05 Fr 4 – – 4 9
06 Sa 5 – – 5 10
07 So – – – – –
08 Mo 6 6 1,6 – 1
09 Di 7 7 2,7 – 2
10 Mi 8 8 3,8 – 3
11 Do 9 9 4,9 – 4
12 Fr 10 10 5,10 – 5
13 Sa – – – – –
14 So – – – – –
15 Mo 1 1 – 6 6
16 Di 2 2 – 7 7
17 Mi 3 3 – 8 8
18 Do 4 4 – 9 9
19 Fr 5 5 – 10 10
20 Sa – – – – –
21 So – – – – –
22 Mo 6 – 1,6 – 1
23 Di 7 – 2,7 – 2
24 Mi 8 – 3,8 – 3
25 Do 9 – 4,9 – 4
26 Fr 10 – 5,10 – 5
27 Sa – – – – –
28 So – – – – –
29 Mo 1 – – 1 6
30 Di 2 – – 2 7
31 Mi 3 – – 3 8
01 Do Allerheiligen
02 Fr 4 – – 4 9
03 Sa 5 – – 5 10
04 So – – – – –
05 Mo 6 6 1,6 – 1
06 Di 7 7 2,7 – 2
07 Mi 8 8 3,8 – 3
08 Do 9 9 4,9 – 4
09 Fr 10 10 5,10 – 5
10 Sa – – – – –
11 So – – – – –
12 Mo 1 1 – 6 6
13 Di 2 2 – 7 7
14 Mi 3 3 – 8 8
15 Do 4 4 – 9 9
16 Fr 5 5 – 10 10
17 Sa – – – – –
18 So – – – – –
19 Mo 6 – 1,6 – 1
20 Di 7 – 2,7 – 2
21 Mi 8 – 3,8 – 3
22 Do 9 – 4,9 – 4
23 Fr 10 – 5,10 – 5
24 Sa – – – – –
25 So – – – – –
26 Mo 1 – – 1 6
27 Di 2 – – 2 7
28 Mi 3 – – 3 8
29 Do 4 – – 4 9
30 Fr 5 – – 5 10
01 Sa – – – – –
02 So – – – – –
03 Mo 6 6 1,6 – 1
04 Di 7 7 2,7 – 2
05 Mi 8 8 3,8 – 3
06 Do 9 9 4,9 – 4
07 Fr 10 10 5,10 – 5
08 Sa – – – – –
09 So – – – – –
10 Mo 1 1 – 6 6
11 Di 2 2 – 7 7
12 Mi 3 3 – 8 8
13 Do 4 4 – 9 9
14 Fr 5 5 – 10 10
15 Sa – – – – –
16 So – – – – –
17 Mo 6 – 1,6 – 1
18 Di 7 – 2,7 – 2
19 Mi 8 – 3,8 – 3
20 Do 9 – 4,9 – 4
21 Fr 10 – 5,10 – 5
22 Sa 1 – – 1 6
23 So – – – – –
24 Mo 2 – – 2 7
25 Di 1. Weihnachtstag
26 Mi 2. Weihnachtstag
27 Do 3 – – 3 8
28 Fr 4 – – 4 9
29 Sa 5 – – 5 10
30 So – – – – –
31 Mo 6 6 1,6 – 1
01 Di Neujahr
02 Mi 7 7 2,7 – 2
03 Do 8 8 3,8 – 3
04 Fr 9 9 4,9 – 4
05 Sa 10 10 5,10 – 5
06 So Hl. Drei Könige
07 Mo 1 1 – 6 6
08 Di 2 2 – 7 7
09 Mi 3 3 – 8 8
10 Do 4 4 – 9 9
11 Fr 5 5 – 10 10
12 Sa Christbaumabfuhr 1-5
13 So – – – – –
14 Mo 6 – 1,6 – 1
15 Di 7 – 2,7 – 2
16 Mi 8 – 3,8 – 3
17 Do 9 – 4,9 – 4
18 Fr 10 – 5,10 – 5
19 Sa Christbaumabfuhr 6 -10
20 So – – – – –
21 Mo 1 – – 1 6
22 Di 2 – – 2 7
23 Mi 3 – – 3 8
24 Do 4 – – 4 9
25 Fr 5 – – 5 10
26 Sa – – – – –
27 So – – – – –
28 Mo 6 6 1,6 – 1
29 Di 7 7 2,7 – 2
30 Mi 8 8 3,8 – 3
31 Do 9 9 4,9 – 4


# ebu-termine-2012

 Dieses Skript erzeugt eine Datei im iCalender-Format mit den Abfuhrterminen der Entsorgungsbetriebe
 der Stadt Ulm (EBU). Ein Aufruf erzeugt den Kalender für einen Abfuhrbezirk und eine Kombination
 von Tonnentypen:Restmüll 2-wöchig / 4-wöchig, Biotonne, Gelber Sack und Papiertonne (EBU).
 
 Das Format des Aufrufs kann nit einem Aufruf des Skripts mit der Option "-h" angezeigt werden.

 Der Abfuhrkalander des aktuellen Jahrs ist am Ende des Skripts Datei, nach der Trenzeile "__DATA__" 
 angehängt, eine Zeile pro Tag, in kalendarischer Reihenfolge, 01.01. bis 31.12.

 Das Format der Datenzeilen entspricht dem Format des Abfuhrkalenders im Faltbaltt "Müllinfo 2011":

  <tag> <wochentag> Christbaumabfuhr <bezirk1>-<bezirk1>
  oder
  <tag> <wochentag> <restmüll2> <restmüll4> <biomüll> <papier> <gelberSack>
      
     <tag>:        Tag des Monats
     <wochentag>:  Wochentag: Mo, Di, Mi,...
     <restmüll2>:  Bezirke, in denen Restmülltonnen mit zweiwöchiger Leerung geleert werden
     <restmüll4>:  Bezirke, in denen Restmülltonnen mit vierwöchiger Leerung geleert werden
     <biomüll>:    Bezirke, in denen Biomülltonnen geleert werden
     <papier>:     Bezirke, in denen Papiertonnen geleert werden
     <gelberSack>: Bezirke, in denen gelbe Säcke abgeholt werden
                                    
 Die Bezirke für einen Abfuhrtyp werden als Liste von Bezirksnummern, getrennt durch Kommas, 
 ohne Leerzeichen angegeben. 

 Beispiel, 31.01.2011:

  31 Mo 6 6 1,6 ?? 1
        | |  |  |  |
        | |  |  |  +- Gelber Sack: Bezirk 1
        | |  |  +- Papiertonne: keine Leerung
        | |  +- Biomüll: Bezirk 1 und 6
        | +- Restmüll 4-wö.: Bezirk 6
        +- Restmüll: 2-wö., Bezirk 6
 
 Das Skript wurde unter Linux/Debian entwickelt und getestet. Die Kalenderdatei wurde für Bezirk 3 
 mit Thunderbird unter Linux/Debian erfolgreich getestet.
 
## Autor

Rainer Unseld 

## Lizenz

 Lizenzhinweis: 
    Dieses Werk bzw. Inhalt steht unter einer Creative Commons Namensnennung 3.0 Deutschland Lizenz.
    Siehe: http://creativecommons.org/licenses/by/3.0/de/



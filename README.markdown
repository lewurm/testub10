# Uebersetzerbau \(SS10\)

Dies ist eine gemeinschaftliche Sammlung von Testfaellen fuer die Uebungsbeispiele
der LVA "Uebersetzerbau \(SS10\)" an der TU Wien.

Kurzes HOWTO (fuer die g0):

	$ git clone git://github.com/lewurm/testub10.git ~/test

Danach koennen die Testfaelle durch diesen Befehl aktualisiert werden:

	$ cd ~/test && git pull

Das Testskript selbst wird von der LVA-Leitung zur Verfuegung gestellt:

	$ /usr/ftp/pub/ubvl/test/scanner/test
	$ /usr/ftp/pub/ubvl/test/parser/test
	$ /usr/ftp/pub/ubvl/test/ag/test
	$ /usr/ftp/pub/ubvl/test/codea/test
	$ /usr/ftp/pub/ubvl/test/codeb/test
	$ /usr/ftp/pub/ubvl/test/gesamt/test

Weiters wurde das bekannte Benchmarkskript von viper fuer codea, codeb und
gesamt angepasst und eingebaut das sich in

	$ ~/test/scripts/test.sh

befindet und mit {code{a,b},gesamt} als parameter aufgerufen wird.

# Namenskonventionen fuer das Skript (Zitat LVA Leitung):

Die Dateien mit der Eingabe heissen \*.0, \*.1, \*.2 oder \*.3, wobei die
Ziffer hinten den Exit-Code angibt. Eine Datei, die einen
Syntax-Fehler enthaelt, werden Sie also z.B. foo.2 nennen.  Beim
Scanner-Beispiel gibt es fuer akzeptable Eingaben (also Dateien, die
auf .0 enden) auch noch eine Ausgabe, die ueberprueft werden muss; die
erwartete Ausgabe fuer die Datei bar.0 nennen Sie bar.out.

## Weitere Namenskonventionen fuer uns:

*	Jeder Testfall hat als Praefix "<nick>_", sodass keine Namenskonflikte entstehen.
*	Ab codea sollte auch fuer jeden erfolgreichen Testfall eine .instr Datei angelegt werden die einen Referenzwert der Instruktionen enthaelt.

### Hinweis fuer *gesamt* und `bench.sh`

In der Call-Datei bitte **nur** Funktionen deklarieren die tatsaechlich in der
Call-Datei selbst aufgerufen werden. Beispiel:
	method f()
		return g();
	end;
	method g()
		return 123;
	end;
so muss in der Call-Datei nur `f()` deklariert werden.


# Wie kannst du beitragen?

## mit git:

*	forke das Repository auf github, committe deine Aenderungen und mach einen "Pull Request"
*	clone das Repository, committe deine Aenderungen, erzeuge Patches mit

		git format-patch

	und maile sie oder poste sie im Informatikforum

## ohne git:

*	schicke deine Testfaelle als Anhang per Mail (mit passenden Dateinamen bitte!)
*	poste deine Testfaelle im Informatikforum und haenge sie als Attachment an (mit passenden Dateinamen bitte!)

und natuerlich ist jeder herzlichst dazu eingeladen im Forum ueber Testfaelle zu diskutieren :)

Infforum-Thread: <http://tinyurl.com/testub10>

Mailadresse(n): lewurm_AT_gmail_DOT_com (weitere Freiwillige sind willkommen, einfach eintragen)



# Allgemeine Tipps:

praktische Ergaenzungen am Makefile fuer codea:

	#bricht beim ersten fehlerhaften Testfall ab
	#usage: make atest
	
	atest:
		~/test/scripts/modlvatest_codea.sh 2>&1

	
	#offizielles Testskript der LVA
	#usage: make lvatest
	
	lvatest:
		/usr/ftp/pub/ublu/test/codea/test 2>&1

	
	#Benchmarkskript. Testet nur *.0 Testfaelle
	#usage: make bench
	
	bench:
		~/test/scripts/bench.sh codea

Ausserdem befindet sich ein Skript zum Testen *eines* Testfalles (auch nur fuer
\*.0 Testfaelle gedacht) hier:
	$ ~/test/scripts/onetest ~/test/codea/namen.0

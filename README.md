csob-txt2gpc
============

skript na prevod txt vypisu pohybu na ucte CSOB na format ABO

pouziti:
na strankach IB csob (internetbanking 24) v sekci ??? vybrat nejake obdobi a ucet, zobrazi se tabulka s pohyby na ucte.

V prave horni casti tabulky kliknout na ikonku exportu do txt

stazeny soubor ( HIST_CISLO_UCTU_DATUM.txt) se pouzije takto:

cat HIST_CISLO_UCTU_DATUM.txt | ruby txt2gpc.rb nazev_firmy_vlastnici_ucte nazev_souboru_kam_zapsat_vysledke.gpc

gpc pote lze naimportovat napr. do Flexibee

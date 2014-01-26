csob-txt2gpc
============

skript na prevod txt vypisu pohybu na ucte CSOB na format ABO

pouziti:
na strankach IB csob (internetbanking 24) v sekci ??? vybrat nejake obdobi a ucet, zobrazi se tabulka s pohyby na ucte.

V prave horni casti tabulky kliknout na ikonku exportu do txt

stazeny soubor ( HIST_CISLO_UCTU_DATUM.txt) se pouzije takto:

`cat HIST_CISLO_UCTU_DATUM.txt | ruby txt2gpc.rb nazev_firmy_vlastnici_ucte nazev_souboru_kam_zapsat_vysledke.gpc`

gpc pote lze naimportovat napr. do Flexibee


dokumentace vystupniho formatu:
http://www.fio.cz/docs/cz/struktura-gpc.pdf

vstupni format:

`header\r\n`

`\r\n`

`pohyb`

`\r\n`

`pohyb`

`\r\n`

`.`

`.`

`.`


pricemz `pohyb` se sestava z radek:

`datum zaúčtování:  31.12.2013\r\n`

`částka:            3836.39\r\n`

`měna:              CZK\r\n`

`zůstatek:          6664.08\r\n`

`konstantní symbol: 0582\r\n`

`variabilní symbol: 12345\r\n`

`specifický symbol: 123\r\n`

`označení operace:  Čerpání úvěru\r\n`

`název protiúčtu:   nejake jmeno\r\n`

`protiúčet: 123456879/0800\r\n`

`poznámka: vzkaz pro prijemce\r\n`


_poznamka:_
uvodni radka vystupniho abo obsahuje ma obsahovat zustatek na zacatku a na konci vypisu - coz se mi nechtelo resit, takze vyplnuji nulami ;-) - pri importu do flexibee toto nevadi

version 8
clear

/*wars in neighboring countries data provided by James Fearon*/
use "data/nwarsl.dta",clear
sort ccode year
save "data/nwarsl.dta",replace

/*public Fearon and Laitin data from Fearon's website*/
use "data/Fearon and Latin 2003 apsr data.dta"
sort ccode year
merge ccode year using "data/nwarsl.dta"
drop _merge

/*replication of FL M1 and M3*/
iis ccode
tis year
logit onset warl gdpenl lpopl1 lmtnest ncontig Oil nwstate instab polity2l ethfrac relfrac 
logit onset warl gdpenl lpopl1 lmtnest ncontig Oil nwstate instab ethfrac relfrac anocl deml

/*generate new variable and variable labels*/
gen loglang=log(numlang)
la var loglang "log (number of languages)"
la var nwarsl "wars in neighboring countries"

/*fix coding error*/
replace onset=. if onset==4

keep onset warl gdpenl lpopl1 lmtnest ncontig Oil nwstate instab polity2l ethfrac relfrac anocl deml nwarsl plural plurrel muslim loglang colfra eeurop lamerica ssafrica asia nafrme second

save "data/fl-merged.dta",replace


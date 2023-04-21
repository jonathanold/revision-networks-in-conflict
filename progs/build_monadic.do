
****************************************
****************************************
** This file is a subproogram of build_bases.do
** It builds the monadic base from the dyadic base
****************************************
****************************************

use KRTZ_base_mt.dta,clear
sort group_d year
collapse (sum) Nfighting Nalliance, by(group_d year)
rename Nfighting Totfighting_d 
rename Nalliance Totalliance_d
sort group_d year
save temp_mt.dta, replace

use KRTZ_base_mt.dta,clear
sort group_d year
merge group_d year using temp_mt
tab _merge
drop _merge
save KRTZ_base_mt.dta,replace
erase temp_mt.dta

drop if group==group_d
sort group group_d year
** option **  
* gen Fighting_Enemy_d = (Totfighting_d - Nfighting) * (enemy==1)
 gen Fighting_Enemy_d = (Totfighting_d) * (enemy==1)

** option **   
* gen Fighting_Allied_d = (Totfighting_d - Nalliance) * (allied==1)
 gen Fighting_Allied_d = (Totfighting_d) * (allied==1)

** option **  
gen Fighting_Neutral_d = (Totfighting_d) * (neutral==1)

* Check here what happens with negative values of Fighting_allied: I guess this comes from removing alliances with three partners + in some events tehre is no identified enemy in the raw data  
sum Fighting_Allied_d , d
replace Fighting_Allied_d =0 if Fighting_Allied_d <0
gen Alliance_Enemy_d = (Totalliance_d ) * (enemy==1)
gen Alliance_Allied_d = (Totalliance_d - Nalliance) * (allied==1)

sum Fighting_Enemy_d, d
sum Fighting_Allied_d, d
sum Fighting_Neutral_d, d
sum Alliance_Enemy_d, d
sum Alliance_Allied_d, d
sort country group year
collapse (sum) allied enemy Nfighting Nalliance Fighting_Enemy_d Fighting_Allied_d Fighting_Neutral_d Alliance_Enemy_d Alliance_Allied_d, by (country group year)

rename allied degree_plus
rename enemy degree_minus
rename Nfighting TotFight
rename Nalliance TotAlliance
rename Fighting_Enemy_d TotFight_Enemy
rename Fighting_Allied_d TotFight_Allied
rename Fighting_Neutral_d TotFight_Neutral
rename Alliance_Enemy_d TotAlliance_Enemy 
rename Alliance_Allied_d TotAlliance_Allied
order group year TotFight TotAlliance TotFight_Enemy TotFight_Allied TotFight_Neutral TotAlliance_Enemy TotAlliance_Allied 
sort country group year

label variable degree_plus "d+ (#allies)"
label variable degree_minus "d- (#enemies)"
label variable group "KRTZ Group Identifier"
label variable TotFight "Nb of bilateral Fighting"
label variable TotAlliance "Nb of bilateral Alliances"
label variable TotFight_Enemy "Total Fight. of enemies w/o bil. Fighting"
label variable TotFight_Allied "Total Fight. of Allies w/o bil. Alliances"
label variable TotFight_Neutral "Total Fight. of Neutrals"
label variable TotAlliance_Enemy "Total Alliances of enemies"
label variable TotAlliance_Allied "Total Alliances of Allies w/o bil. Alliances"
save KRTZ_monadic_base_mt.dta,replace

use KRTZ_base_mt.dta,clear
sort country group year
bysort country group: keep if [_n]==1
keep country group id name
sort country group
save temp_mt.dta, replace

use KRTZ_monadic_base_mt.dta, clear
sort country group
merge  country group using temp_mt.dta
tab _merge 
drop _merge
label variable id "ACLED Group Identifier"
label variable name "Group's name"
save KRTZ_monadic_base_mt.dta,replace
erase KRTZ_base_mt.dta

use KRTZ_dyadic_base_mt.dta, clear
label variable group "KRTZ Group Identifier"
label variable group_d "KRTZ Group Identifier_d"
label variable allied "Time invariant dummy for Alliance"
label variable enemy "Time invariant dummy for Rivalry"
label variable Nfighting "Nb of bilateral fighting"
label variable Nalliance "Nb of bilateral alliances"
label variable id "ACLED Group Identifier"
label variable name "Group's name"
label variable id_d "ACLED Group Identifier_d"
label variable name_d "Group's name_d"
label var inconsistency "Both allied - enemy in the time-invariant adj. matrix"
save KRTZ_dyadic_base_mt.dta,replace	
capture erase temp_mt.dta 

************************
*** ADD CONTROLS ***
* TO BE CLEANED + CREATE LABELS
************************

use KRTZ_monadic_base_mt.dta,clear
sort id year
save masterdata_DRC_temp, replace
use ..\original_data\controls_all.dta 
rename YEAR year
sort id year
save controls_recoded.dta, replace
use masterdata_DRC_temp, clear
merge id year using controls_recoded.dta
drop if _merge==2
drop _merge
tab year, gen(TE)
sort id year
save masterdata_DRC, replace
erase masterdata_DRC_temp.dta
erase controls_recoded.dta


*** ADD TOTAL FIGHTING OUTSIDE DRC
do ..\progs\Create_control_total_fighting_everywhere_but_DRC.do
use masterdata_DRC, clear
sort id year
merge id year using total_fighting_Africa_exclDRC.dta
drop if _merge==2
drop _merge
replace total_fighting_Africa_exclDRC=0 if total_fighting_Africa_exclDRC==.
save masterdata_DRC, replace
erase total_fighting_Africa_exclDRC.dta


*** CREATE VARIOUS MEASURES OF GROUP STRENGTH [TO BE REWRITTEN!]
use masterdata_DRC, clear
sort id
by id: egen avg_troops=mean(total_troops)
destring rebestimate, replace
egen troops = rowmean(total_troops rebestimate)
*gen inter=Government_org*net_fighting_elsewhere
sort id
by id: egen avg_troops2=mean(troops)
sort id
by id: egen avg_rebestimate=mean(rebestimate)
sort id
by id: egen avg_Strenght=mean(Strenght)
gen avg_troops3=avg_troops
replace avg_troops3=avg_rebestimate if avg_troops==.
egen troops_3ds = rowmean(total_troops rebestimate Strenght)
sort id
by id: egen avg_troops_3ds=mean(troops_3ds)
gen avg_troops4=avg_troops3
replace avg_troops4=avg_Strenght if avg_troops4==.
save masterdata_DRC, replace





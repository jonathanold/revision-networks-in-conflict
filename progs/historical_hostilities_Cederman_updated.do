*This do-file adds historical hostilities from Cederman*
*********************************************************
*open Cederman
*clear all
clear
use ..\original_data\CBR_JCR_repdata.dta 
keep dyadid ccode year group grpname egip incidence
*keep only ethnic groups that linked to ACLED fighting groups in DRC
gen junk=0
replace junk=1 if group==6
replace junk=1 if group==13
replace junk=1 if group==110
replace junk=1 if group==111
replace junk=1 if group==120
replace junk=1 if group==124
replace junk=1 if group==137
replace junk=1 if group==137.5
replace junk=1 if group==138
replace junk=1 if group==146
replace junk=1 if group==146.5
replace junk=1 if group==168
replace junk=1 if group==332
replace junk=1 if group==500
replace junk=1 if group==719
replace junk=1 if group==771
replace junk=1 if group==772
replace junk=1 if group==814
replace junk=1 if group==815
replace junk=1 if group==852
replace junk=1 if group==853
replace junk=1 if group==1028
replace junk=1 if group==1243
keep if junk==1
drop junk
*keep only years before our sample starts
drop if year>1997
*already sort out simple cases
sort group
by group: egen mean_incid=mean(incidence)
by group: egen mean_egip=mean(egip)
*groups that always out of power and never in a war will have no alliances and no rivalries 
*--> drop, as later on in code when alliance or rivalry variable is missing, it will be replaced by 0
tab group if mean_incid==0 & mean_egip==0
drop if mean_incid==0 & mean_egip==0
order ccode year group egip incidence
sort ccode year group  
duplicates report ccode year
drop mean*
drop dyadid
save temp.dta, replace
* build group dyads by country - year
use temp, clear
distinct group 
scalar nb=r(ndistinct)
bys group: keep if [_n]==1
keep group grpname
sort group
gen obs=[_n]
sort obs
save tempa.dta, replace
use temp, clear
tab ccode
tab year
sort ccode year
bys ccode year: keep if [_n]==1
duplicates report ccode
tab year
keep ccode year
expand nb
sort ccode year
bys ccode year: gen obs=[_n]
sort obs
merge obs using tempa
tab _merge
drop _merge
drop obs
rename group group_d
rename grpname grpname_d
sort ccode year group_d
expand nb
bys ccode year group_d: gen obs=[_n]
sort obs
merge obs using tempa
tab _merge
drop _merge
drop obs
order ccode year group group_d 
sort ccode year group group_d 
save tempa.dta, replace
*
use temp, clear
cap drop grpname
sort ccode year group
save temp, replace
rename group group_d
rename egip egip_d
rename incidence incidence_d
sort ccode year group_d
save temp_d, replace

use tempa, clear
sort ccode year group
merge ccode year group using temp
tab _merge
drop _merge
sort ccode year group_d
merge ccode year group_d using temp_d
tab _merge
drop _merge
erase temp.dta
erase temp_d.dta
save tempa, replace

* definition of the links
use tempa, clear
drop if group==group_d
gen ALLIED=0
gen ENEMY=0
replace ALLIED=1 if egip==1 & egip_d==1 
replace ENEMY=1 if egip==1 & egip_d==0 & incidence_d==1
replace ENEMY=1 if egip==0 & egip_d==1 & incidence==1
bysort group group_d: egen allied=sum(ALLIED)
bysort group group_d: egen enemy=sum(ENEMY)
gen inconsistency=0
replace inconsistency=1 if enemy>0 & allied>0
tab inconsistency if enemy>0 | allied>0
order group group_d grpname grpname_d ccode year
sort group group_d ccode year 

* build time-invariant network
bysort group group_d: keep if [_n]==1
keep group group_d grp* allied enemy inconsistency

* check that we have a balanced dyads
distinct group
scalar b=r(ndistinct)
distinct group_d
scalar c=r(ndistinct)
count
di c *(b-1)

rename group cbr_id
rename group_d cbr_id_d
rename allied cbr_allied
rename enemy cbr_enemy
rename inconsistency cbr_inconsistency
rename grpname cbr_name
rename grpname_d cbr_name_d
replace cbr_allied=(cbr_allied>0)
replace cbr_enemy=(cbr_enemy>0)
sort cbr_id cbr_id_d
save tempa, replace
save temp_cederman, replace
erase tempa.dta

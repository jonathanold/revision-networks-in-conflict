********************************************************/
* This program is a subroutine of table10.do
* It builds the baseline samples using the fake ACLED dataset
********************************************************/

*coordinates
use ..\original_data\LGM\MC.dta, clear
keep id LON LAT
sort id 
save lon_lat.dta, replace

clear all

**********************************
** We re-label the variables
**********************************
use all_africa_ext_fake, clear

keep if GWNO==490
drop if COUNTRY=="Burundi"
drop if COUNTRY=="Central African Republic"
tab COUNTRY if GWNO==490
drop GWNO 
replace COUNTRY="DRC"
drop EVENT_ID_CNTY EVENT_DATE TIME_PRECISION EVENT_TYPE 
rename EVENT_ID_NO_CNTY event
rename YEAR year
rename COUNTRY country
keep year event country LATITUDE LONGITUDE id_ALLY_ACTOR_2B id_ALLY_ACTOR_1B id_ALLY_ACTOR_2 id_ACTOR2 id_ALLY_ACTOR_1 id_ACTOR1 ALLY_ACTOR_2B ALLY_ACTOR_1B FATALITIES ALLY_ACTOR_2 ACTOR2 ALLY_ACTOR_1 ACTOR1

* We now merge/suppress several groups according to "obvious coding issues in ACLED dataset" 
 do ..\progs\recode_groups.do

*KICK OUT MONUC
foreach x of var ACTOR1 ACTOR2 ALLY_ACTOR_2 ALLY_ACTOR_1 ALLY_ACTOR_1B ALLY_ACTOR_2B{

replace `x'=" "	if id_`x'==93
replace id_`x'=.	if id_`x'==93
}

*
*MERGE GOV CONGO
 
foreach x of var ACTOR1 ACTOR2 ALLY_ACTOR_2 ALLY_ACTOR_1 ALLY_ACTOR_1B ALLY_ACTOR_2B{

replace `x'="Military Forces of Democratic Republic of Congo (2001-)"	if id_`x'==96

replace `x'="Military Forces of Democratic Republic of Congo (2001-)"	if id_`x'==19
replace id_`x'=96	if id_`x'==19

}
*
foreach x of var ACTOR1 ACTOR2 ALLY_ACTOR_2 ALLY_ACTOR_1 ALLY_ACTOR_1B ALLY_ACTOR_2B{

replace `x'="Military Forces of Democratic Republic of Congo (1997-2001) (Kabila, L.)"	if id_`x'==30

replace `x'="Military Forces of Democratic Republic of Congo (1997-2001) (Kabila, L.)"	if id_`x'==1025
replace id_`x'=30	if id_`x'==1025

}
*MERGE May-May
 
foreach x of var ACTOR1 ACTOR2 ALLY_ACTOR_2 ALLY_ACTOR_1 ALLY_ACTOR_1B ALLY_ACTOR_2B{

replace `x'="Mayi-Mayi Milita"	if id_`x'==982
replace id_`x'=49	if id_`x'==982
}
*

*MERGE Mutiny
*
foreach x of var ACTOR1 ACTOR2 ALLY_ACTOR_2 ALLY_ACTOR_1 ALLY_ACTOR_1B ALLY_ACTOR_2B{

replace `x'="Mutiny of Military Forces of Democratic Republic of Congo (2003-)"	if id_`x'==287

replace `x'="Mutiny of Military Forces of Democratic Republic of Congo (2003-)"	if id_`x'==301
replace id_`x'=287	if id_`x'==301

replace `x'="Mutiny of Military Forces of Democratic Republic of Congo (2003-)"	if id_`x'==1514
replace id_`x'=287	if id_`x'==1514

replace `x'="Mutiny of Military Forces of Democratic Republic of Congo (2003-)"	if id_`x'==348
replace id_`x'=287	if id_`x'==348

}
*

rename LATITUDE latitude
rename LONGITUDE longitude
rename id_ACTOR1 idA1
rename id_ALLY_ACTOR_1 idA2
rename id_ALLY_ACTOR_1B idA3
rename id_ACTOR2 idB1
rename id_ALLY_ACTOR_2 idB2
rename id_ALLY_ACTOR_2B idB3
rename FATALITIES fatalities
order country event year idA1 idA2 idA3 idB1 idB2 idB3 fatalities
sort year event
duplicates report year event
gen obs=[_n]
duplicates report obs
order country obs event year idA1 idA2 idA3 idB1 idB2 idB3 fatalities
drop if year==1997
drop if year==2011
save temp_dr.dta, replace


**************************************
* we first build a database of geoloc events by group that we export to ArcGIS for building centroid
**********************************

use temp_dr, clear
sum year
scalar Minyear=r(min)
scalar Maxyear=r(max)
rename idB1 idA4
rename idB2 idA5
rename idB3 idA6
sort obs
reshape long idA, i(obs) j(rank)
rename idA id 
sort obs rank
gen name=ACTOR1 if rank==1
replace name=ALLY_ACTOR_1 if rank==2 
replace name=ALLY_ACTOR_1B if rank==3 
replace name=ACTOR2 if rank==4 
replace name=ALLY_ACTOR_2 if rank==5 
replace name=ALLY_ACTOR_2B if rank==6 

drop if id==.
keep country year latitude longitude id fatalities name
sort id year
by id: gen obs=[_n]
by id: egen total_fight=max (obs)
label var obs "obs by group" 
sort id year
gen OBS=[_n]
label var OBS "obs identifier"
sort id year OBS    
label var id "ACLED group identifier"
label var name "group name"
label var total_fight "group total amount of fighting events"
drop obs
keep country year latitude longitude id fatalities name total_fight 
order id year latitude longitude fatalities name total_fight   
sort id year
save geoloc_fight_by_group.dta, replace

* an additional database at the location-year level [for editing an ArcGIS map of violence by location]
use geoloc_fight_by_group.dta, clear
sort latitude longitude
egen geoloc=group (latitude longitude)
gen fight=1
distinct geoloc year
sort geoloc year 
by geoloc year: egen loc_event_yr=sum(fight)
by geoloc: egen loc_event_tot=sum(fight)
keep geoloc year latitude longitude loc_event_yr loc_event_tot
label var loc_event_yr "nb events by location year"
label var loc_event_tot "nb events by location 1998-2011"
order geoloc latitude longitude year loc_event_yr loc_event_tot
sort geoloc year
by geoloc year: keep if [_n]==1
save fight_by_location.dta, replace


**************************************
* build the skeleton of the database
* we first build a bilateral database
**********************************

** Important : selection of fighting events - We consequently loose 22 fighting groups  
* Non bilateral fighting events are removed 
use temp_dr, clear
egen campA=rowtotal(idA1 idA2 idA3)
tab campA
replace campA=1 if campA>0
tab campA
egen campB=rowtotal(idB1 idB2 idB3)
tab campB
replace campB=1 if campB>0
tab campB
table campA campB
drop if campA==0|campB==0
drop campA campB
save temp_dr.dta, replace
**

use temp_dr, clear
sum year
scalar Minyear=r(min)
scalar Maxyear=r(max)
keep country obs id* ACTOR* ALLY*
rename idB1 idA4
rename idB2 idA5
rename idB3 idA6
sort obs
reshape long idA, i(obs) j(rank)
rename idA id 
sort obs rank
gen name=ACTOR1 if rank==1
replace name=ALLY_ACTOR_1 if rank==2 
replace name=ALLY_ACTOR_1B if rank==3 
replace name=ACTOR2 if rank==4 
replace name=ALLY_ACTOR_2 if rank==5 
replace name=ALLY_ACTOR_2B if rank==6 
keep country id name
bysort country id : keep if [_n]==1
duplicates report id name
duplicates report id
drop if id==.
sort country id
gen group=[_n]
order group id name country
sort group 
save tempA_mt, replace

keep group id name
rename group group_d
rename id id_d
rename name name_d
sort group_d
save tempB_mt, replace
 
use  tempA_mt, clear
sum group
scalar N=r(N)
expand N
gen group_d=.
bysort group: replace group_d=[_n]
sort group_d
merge group_d using tempB_mt
tab _merge
drop _merge
erase tempA_mt.dta
erase tempB_mt.dta
order group id group_d id_d
sort group group_d

scalar Nbyear=Maxyear-Minyear+1
expand Nbyear
gen year=Minyear
bysort group group_d: replace year=year-1+[_n]
order group group_d year id id_d name country
sort group group_d year
sort id id_d year 
save KRTZ_base_mt.dta, replace

******************************************
* Include the Nb events in the main base
* Tedious because many combinations are possible
* We ignore (rare) fighting events with 3 belligerants in the same camp
******************************************
use temp_dr, clear
keep country obs event year id* fatalities
drop idA3 idB3
gen counter=1
save temp_dr.dta, replace

use temp_dr, clear
sort idA1 idA2 year
collapse(sum) counter, by(idA1 idA2 year)
rename idA1 id
rename idA2 id_d
rename counter allA1A2
sort id id_d year
save tempA1A2.dta, replace
rename id trash
rename id_d id
rename trash id_d
rename allA1A2 allA2A1
sort id id_d year
save tempA2A1.dta, replace

use temp_dr, clear
sort idB1 idB2 year
collapse(sum) counter, by(idB1 idB2 year)
rename idB1 id
rename idB2 id_d
rename counter allB1B2
sort id id_d year
save tempB1B2.dta, replace
rename id trash
rename id_d id
rename trash id_d
rename allB1B2 allB2B1
sort id id_d year
save tempB2B1.dta, replace

use temp_dr, clear
sort idA1 idB1 year
collapse(sum) counter, by(idA1 idB1 year)
rename idA1 id
rename idB1 id_d
rename counter fighA1B1
sort id id_d year
save tempA1B1.dta, replace
rename id trash
rename id_d id
rename trash id_d
rename fighA1B1 fighB1A1
sort id id_d year
save tempB1A1.dta, replace

use temp_dr, clear
sort idA1 idB2 year
collapse(sum) counter, by(idA1 idB2 year)
rename idA1 id
rename idB2 id_d
rename counter fighA1B2
sort id id_d year
save tempA1B2.dta, replace
rename id trash
rename id_d id
rename trash id_d
rename fighA1B2 fighB2A1
sort id id_d year
save tempB2A1.dta, replace

use temp_dr, clear
sort idA2 idB1 year
collapse(sum) counter, by(idA2 idB1 year)
rename idA2 id
rename idB1 id_d
rename counter fighA2B1
sort id id_d year
save tempA2B1.dta, replace
rename id trash
rename id_d id
rename trash id_d
rename fighA2B1 fighB1A2
sort id id_d year
save tempB1A2.dta, replace

use temp_dr, clear
sort idA2 idB2 year
collapse(sum) counter, by(idA2 idB2 year)
rename idA2 id
rename idB2 id_d
rename counter fighA2B2
sort id id_d year
save tempA2B2.dta, replace
rename id trash
rename id_d id
rename trash id_d
rename fighA2B2 fighB2A2
sort id id_d year
save tempB2A2.dta, replace

** merge **
use KRTZ_base_mt.dta, clear
sort id id_d year
merge id id_d year using tempA1A2
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempA2A1
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempB1B2
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempB2B1
tab _merge 
drop if _merge==2
drop _merge
order group group_d year all*
egen Nalliance= rowtotal(allA1A2 allA2A1 allB1B2 allB2B1)
erase tempA1A2.dta 
erase tempA2A1.dta 
erase tempB1B2.dta 
erase tempB2B1.dta 
drop all*
save KRTZ_base_mt.dta,replace

use KRTZ_base_mt.dta, clear
sort id id_d year
merge id id_d year using tempA1B1
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempB1A1
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempA2B1
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempB1A2
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempA1B2
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempB2A1
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempA2B2
tab _merge 
drop if _merge==2
drop _merge
sort id id_d year
merge id id_d year using tempB2A2
tab _merge 
drop if _merge==2
drop _merge
order group group_d year figh*
egen Nfighting= rowtotal(fighA1B1 fighA2B1 fighA1B2 fighA2B2 fighB1A1 fighB2A1 fighB1A2 fighB2A2)
erase tempA1B1.dta 
erase tempA1B2.dta 
erase tempA2B1.dta 
erase tempA2B2.dta 
erase tempB1A1.dta 
erase tempB1A2.dta 
erase tempB2A1.dta 
erase tempB2A2.dta 
drop figh*
order group group_d year Nfighting Nalliance id id_d name name_d country

replace Nfighting=0 if id==id_d
replace Nalliance=0 if id==id_d
save temp_acled_dyadic.dta, replace
erase temp_dr.dta


********************************************************************************
********************************************************************************
* We create now various dyadic links according to various sources
********************************************************************************
********************************************************************************
******************************

******************************************************
* SIPRI dyadic links
******************************************************
*Only code really confirmed links 
*Government
use temp_acled_dyadic.dta, clear
global GovSIPRI "19 30 96 "
global AlliesGovSIPRI "27 7 68 55 200 69 49 1046 2268 405 1047 765 493 227"
global op_gled "" 

gen allied=0
gen neutral=0
gen enemy=0
foreach y of global AlliesGovSIPRI {
replace allied=1 if id==`y' & id_d==19 $op_gled
replace allied=1 if id==`y' & id_d==30 $op_gled
replace allied=1 if id==`y' & id_d==96 $op_gled

        }
foreach y of global GovSIPRI {
replace allied=1 if id==`y' & id_d==27 $op_gled
replace allied=1 if id==`y' & id_d==7 $op_gled
replace allied=1 if id==`y' & id_d==68 $op_gled
replace allied=1 if id==`y' & id_d==55 $op_gled
replace allied=1 if id==`y' & id_d==69 $op_gled
replace allied=1 if id==`y' & id_d==49 $op_gled
replace allied=1 if id==`y' & id_d==200 $op_gled
replace allied=1 if id==`y' & id_d==1046 $op_gled
replace allied=1 if id==`y' & id_d==2268 $op_gled
replace allied=1 if id==`y' & id_d==405 $op_gled
replace allied=1 if id==`y' & id_d==1047 $op_gled
replace allied=1 if id==`y' & id_d==765 $op_gled
replace allied=1 if id==`y' & id_d==493 $op_gled
replace allied=1 if id==`y' & id_d==227 $op_gled
        }			
*Rebels
replace allied=1 if id==33 & id_d==41 $op_gled 
replace allied=1 if id==41 & id_d==33 $op_gled
replace allied=1 if id==33 & id_d==471 $op_gled 
replace allied=1 if id==471 & id_d==33 $op_gled

replace allied=1 if id==71 & id_d==9 $op_gled
replace allied=1 if id==9 & id_d==71 $op_gled

replace allied=1 if id==88 & id_d==9 $op_gled
replace allied=1 if id==9 & id_d==88 $op_gled

*Congo vs. RCD

global camp40_1 "19 30 96" 
global camp40_2 "33 146 88 71 41 471 9" 
				
foreach y of global camp40_2 {
replace enemy=1 if id==`y' & id_d==19 $op_gled
replace enemy=1 if id==`y' & id_d==30 $op_gled
replace enemy=1 if id==`y' & id_d==96 $op_gled
        }
foreach y of global camp40_1 {
replace enemy=1 if id==`y' & id_d==33 $op_gled
replace enemy=1 if id==`y' & id_d==146 $op_gled
replace enemy=1 if id==`y' & id_d==88 $op_gled
replace enemy=1 if id==`y' & id_d==71 $op_gled
replace enemy=1 if id==`y' & id_d==41 $op_gled
replace enemy=1 if id==`y' & id_d==471 $op_gled
replace enemy=1 if id==`y' & id_d==9 $op_gled
        }
*

keep id id_d year enemy allied neutral
rename enemy enemy_SIPRI
label var enemy_SIPRI "SIPRI dyadic Full period"
rename allied allied_SIPRI
label var allied_SIPRI "SIPRI dyadic Full period"
rename neutral neutral_SIPRI
label var neutral_SIPRI "SIPRI dyadic Full period"
sort id id_d year
save temp_SIPRI.dta, replace


******************************************************
* Full period ACLED dyadic links
******************************************************
use temp_acled_dyadic.dta, clear
bysort group group_d: egen allied=sum(Nalliance)
bysort group group_d: egen enemy=sum(Nfighting)
replace enemy=0 if id==id_d
replace allied=0 if id==id_d
replace enemy=0 if enemy<2
replace allied=(allied>0)
replace enemy=(enemy>0)

replace allied=0 if id==30 & id_d==96 $op_gled
replace allied=0 if id==96 & id_d==30 $op_gled
replace allied=0 if id==471 & id_d==41 $op_gled
replace allied=0 if id==41 & id_d==471 $op_gled
replace enemy=0 if id==30 & id_d==96 $op_gled
replace enemy=0 if id==96 & id_d==30 $op_gled
replace enemy=0 if id==471 & id_d==41 $op_gled
replace enemy=0 if id==41 & id_d==471 $op_gled

table enemy allied
gen neutral=1-(allied + enemy)
tab neutral
keep id id_d year enemy allied neutral
rename enemy enemy_AF
label var enemy_AF "ACLED dyadic Full period"
rename allied allied_AF
label var allied_AF "ACLED dyadic Full period"
rename neutral neutral_AF
label var neutral_AF "ACLED dyadic Full period"
sort id id_d year
save temp_AF.dta, replace


******************************************************
* Sample Split ACLED dyadic links
******************************************************

  
  foreach num of numlist 2000 2001 2002 2003{
         		
use temp_acled_dyadic.dta, clear
gen splitNalliance=0
gen splitNfighting=0
replace splitNalliance=Nalliance if year<= `num'
replace splitNfighting=Nfighting if year<= `num'
bysort group group_d: egen allied=sum(splitNalliance)
bysort group group_d: egen enemy=sum(splitNfighting)
gen inconsistency=1 if enemy>0 & allied>0
replace enemy=0 if id==id_d
replace allied=0 if id==id_d
replace enemy=0 if enemy<2
replace allied=(allied>0)
replace enemy=(enemy>0)
replace allied=0 if id==30 & id_d==96 $op_gled
replace allied=0 if id==96 & id_d==30 $op_gled
replace allied=0 if id==471 & id_d==41 $op_gled
replace allied=0 if id==41 & id_d==471 $op_gled
replace enemy=0 if id==30 & id_d==96 $op_gled
replace enemy=0 if id==96 & id_d==30 $op_gled
replace enemy=0 if id==471 & id_d==41 $op_gled
replace enemy=0 if id==41 & id_d==471 $op_gled
table enemy allied
gen neutral=1-(allied + enemy)
tab neutral
keep id id_d year enemy allied neutral
rename enemy enemy_pre`num'
label var enemy_pre`num' "ACLED dyadic sample split"
rename allied allied_pre`num'
label var allied_pre`num' "ACLED dyadic sample split"
rename neutral neutral_pre`num'
label var neutral_pre`num' "ACLED dyadic sample split"
sort id id_d year
save temp_pre`num'.dta, replace

        }

		
  foreach num of numlist 2000 2001 2002 2003 {
         		
use temp_acled_dyadic.dta, clear
gen splitNalliance=0
gen splitNfighting=0
replace splitNalliance=Nalliance if year> `num'
replace splitNfighting=Nfighting if year> `num'
bysort group group_d: egen allied=sum(splitNalliance)
bysort group group_d: egen enemy=sum(splitNfighting)
gen inconsistency=1 if enemy>0 & allied>0
replace enemy=0 if id==id_d
replace allied=0 if id==id_d
 replace enemy=0 if enemy<2
replace allied=(allied>0)
replace enemy=(enemy>0)
replace allied=0 if id==30 & id_d==96 $op_gled
replace allied=0 if id==96 & id_d==30 $op_gled
replace allied=0 if id==471 & id_d==41 $op_gled
replace allied=0 if id==41 & id_d==471 $op_gled
replace enemy=0 if id==30 & id_d==96 $op_gled
replace enemy=0 if id==96 & id_d==30 $op_gled
replace enemy=0 if id==471 & id_d==41 $op_gled
replace enemy=0 if id==41 & id_d==471 $op_gled
table enemy allied
gen neutral=1-(allied + enemy)
tab neutral
keep id id_d year enemy allied neutral
rename enemy enemy_post`num'
label var enemy_post`num' "ACLED dyadic sample split"
rename allied allied_post`num'
label var allied_post`num' "ACLED dyadic sample split"
rename neutral neutral_post`num'
label var neutral_post`num' "ACLED dyadic sample split"
sort id id_d year
save temp_post`num'.dta, replace

        }

*

******************************************************
* Cederman and Same Ethnicity links
******************************************************

* construction of the Cederman network
do ..\progs\historical_hostilities_Cederman_updated.do
import excel ..\original_data\ACLED_Cederman_and_al_merging_key_REVISED_DR.xls, sheet("Sheet1") firstrow clear
rename idnew id
destring CBR*, replace
destring id, replace
gen cbr_id=CBR_code_primary
replace cbr_id=CBR_code_secondary if cbr_id==.
gen murdock_id=Murdock_code_primary
replace murdock_id=Murdock_code_secondary if Murdock_code_primary=="."
destring murdock_id, replace
keep id cbr_id Broad_Hutu murdock_id
sort id 
save mk_cbr.dta, replace
use mk_cbr.dta, clear
rename id id_d
rename cbr_id cbr_id_d
rename Broad_Hutu Broad_Hutu_d
rename murdock_id murdock_id_d
sort id_d
save mk_cbr_d.dta, replace

use temp_acled_dyadic.dta, clear
keep id id_d year
sort id year
merge id using mk_cbr.dta
tab _merge
drop _merge
sort id_d year
merge id_d using mk_cbr_d.dta
tab _merge
drop _merge
sort cbr_id cbr_id_d year
merge cbr_id cbr_id_d using temp_cederman
tab _merge
drop if id==id_d
drop _merge
replace cbr_allied=0 if cbr_allied==.
replace cbr_enemy=0 if cbr_enemy==.

*Generate Ethnic Group variables:
gen same_ethnic_greg=0
replace same_ethnic_greg=1 if cbr_id==cbr_id_d
gen same_Hutu_Tutsi=0
replace same_Hutu_Tutsi=1 if Broad_Hutu==1 & Broad_Hutu_d==1
replace same_Hutu_Tutsi=1 if Broad_Hutu==2 & Broad_Hutu_d==2
gen different_Hutu_Tutsi=0
replace different_Hutu_Tutsi=1 if Broad_Hutu==1 & Broad_Hutu_d==2
replace different_Hutu_Tutsi=1 if Broad_Hutu==2 & Broad_Hutu_d==1
gen zero_Hutu=0
replace zero_Hutu=1 if Broad_Hutu~=2 & Broad_Hutu_d~=2
gen one_Hutu=0
replace one_Hutu=1 if Broad_Hutu~=2 & Broad_Hutu_d==2
replace one_Hutu=1 if Broad_Hutu==2 & Broad_Hutu_d~=2
gen two_Hutu=0
replace two_Hutu=1 if Broad_Hutu==2 & Broad_Hutu_d==2
gen same_murdock=0
replace same_murdock=1 if murdock_id==murdock_id_d 

keep year id id_d cbr_allied cbr_enemy same_ethnic_greg same_Hutu_Tutsi different_Hutu_Tutsi same_murdock one_Hutu two_Hutu
rename cbr_enemy enemy_CEDERMAN
label var enemy_CEDERMAN "CEDERMAN historical hostilities"
rename cbr_allied allied_CEDERMAN
label var allied_CEDERMAN "CEDERMAN historical hostilities"
label var same_ethnic_greg "same greg ethnic group"
label var same_Hutu_Tutsi "based on broad Hutu vs Tutsi coding by DR starting from GREG"
label var different_Hutu_Tutsi "based on broad Hutu vs Tutsi coding by DR starting from GREG"
label var one_Hutu "based on broad Hutu vs Tutsi coding by DR starting from GREG"
label var two_Hutu "based on broad Hutu vs Tutsi coding by DR starting from GREG"
label var same_murdock "same Murdock ethnic group" 
sort id id_d year
save temp_CEDERMAN_ETHNIC.dta, replace


******************************************************
* Gleditsch confirmed alliance and enmity links 
******************************************************
use temp_acled_dyadic.dta, clear
gen allied=0
gen enemy=0
gen neutral=0
global op_gled ""

global camp40_2RCD "146"
global camp40_2RCDALLIES "4 41 471 15 9"
foreach y of global camp40_2RCD {
replace allied=1 if id==`y' & id_d==4 $op_gled
replace allied=1 if id==`y' & id_d==41 $op_gled
replace allied=1 if id==`y' & id_d==471 $op_gled
replace allied=1 if id==`y' & id_d==15 $op_gled
replace allied=1 if id==`y' & id_d==9 $op_gled
        }			
foreach y of global camp40_2RCDALLIES {
replace allied=1 if id==`y' & id_d==146 $op_gled 
        }			

*Congo vs. RCD

global camp40_1 "19 30 96"
global camp40_2 "146" 
				
foreach y of global camp40_2 {
replace enemy=1 if id==`y' & id_d==19 $op_gled
replace enemy=1 if id==`y' & id_d==30 $op_gled
replace enemy=1 if id==`y' & id_d==96 $op_gled
        }
foreach y of global camp40_1 {
replace enemy=1 if id==`y' & id_d==146 $op_gled
        }
*DYAD ID 41
global camp41_1 "19 30 96" 
global camp41_2 "88" 
	
foreach y of global camp41_2 {
replace enemy=1 if id==`y' & id_d==19 $op_gled
replace enemy=1 if id==`y' & id_d==30 $op_gled
replace enemy=1 if id==`y' & id_d==96 $op_gled
        }
foreach y of global camp41_1 {
replace enemy=1 if id==`y' & id_d==88 $op_gled
        }
*DYAD ID 42
global camp42_1 "19 30 96" 
global camp42_2 "71" 
					
foreach y of global camp42_2 {
replace enemy=1 if id==`y' & id_d==19 $op_gled
replace enemy=1 if id==`y' & id_d==30 $op_gled
replace enemy=1 if id==`y' & id_d==96 $op_gled
        }
foreach y of global camp42_1 {
replace enemy=1 if id==`y' & id_d==71 $op_gled
        }

* Dyad ID 646: Congo/Zaire vs. CNDP

replace enemy=1 if id==19 & id_d==73 
replace enemy=1 if id==73 & id_d==19

replace enemy=1 if id==96 & id_d==73 
replace enemy=1 if id==73 & id_d==96

*DYAD ID 651
global camp651_1 "19 96"
global camp651_2 "595"

foreach y of global camp651_2 {
replace enemy=1 if id==`y' & id_d==19 $op_gled
replace enemy=1 if id==`y' & id_d==96 $op_gled
        }
foreach y of global camp651_1 {
replace enemy=1 if id==`y' & id_d==595 $op_gled
        }
*

keep id id_d year enemy allied neutral
rename enemy enemy_GLEDITSCH
label var enemy_GLEDITSCH "GLEDITSCH confirmed dyadic Full period 2"
rename allied allied_GLEDITSCH
label var allied_GLEDITSCH "GLEDITSCH confirmed dyadic Full period 2"
rename neutral neutral_GLEDITSCH
label var neutral_GLEDITSCH "GLEDITSCH confirmed dyadic Full period 2"
sort id id_d year
save temp_GLEDITSCH.dta, replace


***************
* ICG Coding
***************
use temp_acled_dyadic.dta, clear
gen allied_icg=0
gen enemy_icg=0
gen neutral_icg=0

* Kabila (before 2001) and ZWE p.1

replace allied_icg=1 if id==55 & id_d==30 
replace allied_icg=1 if id==30 & id_d==55

* Kabila (before 2001) and NAM p.1

replace allied_icg=1 if id==200 & id_d==30 
replace allied_icg=1 if id==30 & id_d==200

* Kabila (before 2001) and AGO p.1

replace allied_icg=1 if id==7 & id_d==30 
replace allied_icg=1 if id==30 & id_d==7

* Kabila (before 2001) and Mai-Mai (only main faction) p.1

replace allied_icg=1 if id==49 & id_d==30 
replace allied_icg=1 if id==30 & id_d==49

* Kabila (before 2001) and former RWA soldiers p.1

replace allied_icg=1 if id==227 & id_d==30 
replace allied_icg=1 if id==30 & id_d==227

* Kabila (before 2001) and ADF p.1

replace allied_icg=1 if id==31 & id_d==30 
replace allied_icg=1 if id==30 & id_d==31

* Kabila (before 2001) and FDD (CNDD-FDD) p.1

replace allied_icg=1 if id==54 & id_d==30 
replace allied_icg=1 if id==30 & id_d==54

* Kabila (before 2001) against the Banyamulenge p.4

replace enemy_icg=1 if id==919 & id_d==30
replace enemy_icg=1 if id==30 & id_d==919

* ADFL and RWA (before 2000) p.4

replace allied_icg=1 if id==116 & id_d==41
replace allied_icg=1 if id==41 & id_d==116

* Kabila (before 2001) against RCD p.6

replace enemy_icg=1 if id==146 & id_d==30
replace enemy_icg=1 if id==30 & id_d==146

* Kabila (before 2001) against RCD-G

replace enemy_icg=1 if id==33 & id_d==30
replace enemy_icg=1 if id==30 & id_d==33

* Kabila (before 2001) against RCD-K

replace enemy_icg=1 if id==71 & id_d==30
replace enemy_icg=1 if id==30 & id_d==71

* Kabila (before 2001) against RCD-M

replace enemy_icg=1 if id==1256 & id_d==30
replace enemy_icg=1 if id==30 & id_d==1256

* Kabila (before 2001) against RCD-N

replace enemy_icg=1 if id==1571 & id_d==30
replace enemy_icg=1 if id==30 & id_d==1571

* RWA (before 2000) and UGA p.18

replace allied_icg=1 if id==41 & id_d==9 
replace allied_icg=1 if id==9 & id_d==41

* Kabila (before 2001) and SDN p.18

replace allied_icg=1 if id==27 & id_d==30 
replace allied_icg=1 if id==30 & id_d==27

* Kabila (before 2001) against RWA (before 2000) p.18

replace enemy_icg=1 if id==41 & id_d==30
replace enemy_icg=1 if id==30 & id_d==41

* Kabila (before 2001) against UGA p.18

replace enemy_icg=1 if id==9 & id_d==30
replace enemy_icg=1 if id==30 & id_d==9

* UGA against ADF p.18

replace enemy_icg=1 if id==9 & id_d==31
replace enemy_icg=1 if id==31 & id_d==9

* UGA against LRA P.19

replace enemy_icg=1 if id==9 & id_d==3
replace enemy_icg=1 if id==3 & id_d==9

* AGO against UNITA p.22

replace enemy_icg=1 if id==7 & id_d==4
replace enemy_icg=1 if id==4 & id_d==7

* Kabila (before 2001) and TCD p.25

replace allied_icg=1 if id==68 & id_d==30 
replace allied_icg=1 if id==30 & id_d==68

keep id id_d year enemy allied neutral
label var enemy_icg "ICG confirmed dyadic Full period"
label var allied_icg "ICG confirmed dyadic Full period"
label var neutral_icg "ICG confirmed dyadic Full period"
sort id id_d year
save temp_ICG.dta, replace


***************
* Williams Coding
***************

use temp_acled_dyadic.dta, clear
gen allied_williams=0
gen enemy_williams=0
gen neutral_williams=0

* Kabila (before 2001) and AFDL p.87

replace allied_williams=1 if id==30 & id_d==116 
replace allied_williams=1 if id==116 & id_d==30

* Hutus against RWA (before 2000) p. 88

replace enemy_williams=1 if id==11 & id_d==41
replace enemy_williams=1 if id==41 & id_d==11

* Hutus against UGA p.88

replace enemy_williams=1 if id==11 & id_d==9
replace enemy_williams=1 if id==9 & id_d==11

* ADF against RWA p.88

replace enemy_williams=1 if id==31 & id_d==41
replace enemy_williams=1 if id==41 & id_d==31

* ADF against UGA p.88

replace enemy_williams=1 if id==31 & id_d==9
replace enemy_williams=1 if id==9 & id_d==31

* ADF and SDN p.88

replace allied_williams=1 if id==31 & id_d==27 
replace allied_williams=1 if id==27 & id_d==31

* Kabila (before 2001) and SDN p.88

replace allied_williams=1 if id==30 & id_d==27 
replace allied_williams=1 if id==27 & id_d==30

* SDN against UGA p.88 and p.96

replace enemy_williams=1 if id==27 & id_d==9
replace enemy_williams=1 if id==9 & id_d==27

* Kabila (before 2001) and Interahamwe p.88 

replace allied_williams=1 if id==30 & id_d==69 
replace allied_williams=1 if id==69 & id_d==30

* Kabila (before 2001) and ex-FAR p.88

replace allied_williams=1 if id==30 & id_d==227 
replace allied_williams=1 if id==227 & id_d==30

* Kabila (before 2001) against RWA (before 2000) p.89

replace enemy_williams=1 if id==30 & id_d==41
replace enemy_williams=1 if id==41 & id_d==30

* RWA (before 2000) and UGA p.89

replace allied_williams=1 if id==41 & id_d==9 
replace allied_williams=1 if id==9 & id_d==41

* Kabila (before 2001) against UGA p.89

replace enemy_williams=1 if id==30 & id_d==9
replace enemy_williams=1 if id==9 & id_d==30

* Kabila (before 2001) against RCD p.89

replace enemy_williams=1 if id==146 & id_d==30
replace enemy_williams=1 if id==30 & id_d==146

* Kabila (before 2001) against RCD-G

replace enemy_williams=1 if id==33 & id_d==30
replace enemy_williams=1 if id==30 & id_d==33

* Kabila (before 2001) against RCD-K

replace enemy_williams=1 if id==71 & id_d==30
replace enemy_williams=1 if id==30 & id_d==71

* Kabila (before 2001) against RCD-M

replace enemy_williams=1 if id==1256 & id_d==30
replace enemy_williams=1 if id==30 & id_d==1256

* Kabila (before 2001) against RCD-N

replace enemy_williams=1 if id==1571 & id_d==30
replace enemy_williams=1 if id==30 & id_d==1571

* Kabila (before 2001) and AGO p.89

replace allied_williams=1 if id==7 & id_d==30 
replace allied_williams=1 if id==30 & id_d==7

* Kabila (before 2001) and ZWE p.89

replace allied_williams=1 if id==55 & id_d==30 
replace allied_williams=1 if id==30 & id_d==55

* AGO against UGA p.89

replace enemy_williams=1 if id==7 & id_d==9
replace enemy_williams=1 if id==9 & id_d==7

* AGO against RWA (before 2000) p.89

replace enemy_williams=1 if id==7 & id_d==41
replace enemy_williams=1 if id==41 & id_d==7

* RWA (before 2000) and BDI p.90

replace allied_williams=1 if id==41 & id_d==15 
replace allied_williams=1 if id==15 & id_d==41

* UGA and BDI p.90

replace allied_williams=1 if id==9 & id_d==15 
replace allied_williams=1 if id==15 & id_d==9

* Kabila (before 2001) and NMB p.90

replace allied_williams=1 if id==200 & id_d==30 
replace allied_williams=1 if id==30 & id_d==200

* Kabila (before 2001) and SDN p.90

replace allied_williams=1 if id==27 & id_d==30 
replace allied_williams=1 if id==30 & id_d==27

* Kabila (before 2001) and TCD p.90

replace allied_williams=1 if id==68 & id_d==30 
replace allied_williams=1 if id==30 & id_d==68

* RWA (before 2000) against ex-FAR p.90

replace enemy_williams=1 if id==41 & id_d==227 
replace enemy_williams=1 if id==227 & id_d==41

* RWA (before 2000) against Interahamwe p.90

replace enemy_williams=1 if id==41 & id_d==69 
replace enemy_williams=1 if id==69 & id_d==41

* UGA against LRA p.92

replace enemy_williams=1 if id==9 & id_d==3 
replace enemy_williams=1 if id==3 & id_d==9

* SDN and LRA p.92

replace allied_williams=1 if id==27 & id_d==3 
replace allied_williams=1 if id==3 & id_d==27

* BDI against FDD (CNDD-FDD) p.93

replace enemy_williams=1 if id==15 & id_d==54
replace enemy_williams=1 if id==54 & id_d==15

* Kabila (before 2001) and FDD (CNDD-FDD) p.93

replace allied_williams=1 if id==54 & id_d==30
replace allied_williams=1 if id==30 & id_d==54

* AGO against UNITA p.94

replace enemy_williams=1 if id==7 & id_d==4 
replace enemy_williams=1 if id==4 & id_d==7

* UNITA and RWA (before 2000) p.94 (allegations)

replace allied_williams=1 if id==4 & id_d==41
replace allied_williams=1 if id==41 & id_d==4

* UNITA and UGA p.94 (allegations)

replace allied_williams=1 if id==4 & id_d==9
replace allied_williams=1 if id==9 & id_d==4

* UNITA against NMB p.95 (allegations)

replace enemy_williams=1 if id==200 & id_d==4 
replace enemy_williams=1 if id==4 & id_d==200

* UGA and SPLA p.95

replace allied_williams=1 if id==9 & id_d==24
replace allied_williams=1 if id==24 & id_d==9

keep id id_d year enemy allied neutral
label var enemy_williams "Williams confirmed dyadic Full period"
label var allied_williams "Williams confirmed dyadic Full period"
label var neutral_williams "Williams confirmed dyadic Full period"
sort id id_d year
save temp_williams.dta, replace


***************
* Coding Reyntjens (2001): The DRC, from Kabila to Kabila ** 
***************

use temp_acled_dyadic.dta, clear
gen allied_reyntjens2001=0
gen enemy_reyntjens2001=0
gen neutral_reyntjens2001=0

* Kabila (before 2001) and AGO p.311

replace allied_reyntjens2001=1 if id==7 & id_d==30 
replace allied_reyntjens2001=1 if id==30 & id_d==7

* Kabila (before 2001) and ZWE p.311

replace allied_reyntjens2001=1 if id==55 & id_d==30 
replace allied_reyntjens2001=1 if id==30 & id_d==55

* Kabila (before 2001) and NAM p.311

replace allied_reyntjens2001=1 if id==200 & id_d==30 
replace allied_reyntjens2001=1 if id==30 & id_d==200

* Kabila (before 2001) against RWA (before 2000) p.311

replace enemy_reyntjens2001=1 if id==41 & id_d==30 
replace enemy_reyntjens2001=1 if id==30 & id_d==41

* Kabila (before 2001) against UGA p.311

replace enemy_reyntjens2001=1 if id==9 & id_d==30 
replace enemy_reyntjens2001=1 if id==30 & id_d==9

* Kabila (before 2001) against BDI p.311

replace enemy_reyntjens2001=1 if id==15 & id_d==30 
replace enemy_reyntjens2001=1 if id==30 & id_d==15

* RCD-Goma and RWA (before 2000) p.311

replace allied_reyntjens2001=1 if id==41 & id_d==33 
replace allied_reyntjens2001=1 if id==33 & id_d==41

* MLC and UGA p.311

replace allied_reyntjens2001=1 if id==88 & id_d==9 
replace allied_reyntjens2001=1 if id==9 & id_d==88

* Mai-Mai against RCD-Goma p.311

replace enemy_reyntjens2001=1 if id==49 & id_d==33 
replace enemy_reyntjens2001=1 if id==33 & id_d==49


* Lendu (DRC) against Hema p.311

replace enemy_reyntjens2001=1 if id==115 & id_d==252 
replace enemy_reyntjens2001=1 if id==252 & id_d==115

keep id id_d year enemy allied neutral
label var enemy_reyntjens2001 "reyntjens2001 confirmed dyadic Full period"
label var allied_reyntjens2001 "reyntjens2001 confirmed dyadic Full period"
label var neutral_reyntjens2001 "reyntjens2001 confirmed dyadic Full period"
sort id id_d year
save temp_reyntjens2001.dta, replace


***************
* DRC Government
***************

use temp_acled_dyadic.dta, clear
gen allied=0


global GOV "96 19 30 1025"
foreach y of global GOV {
foreach z of global GOV {
replace allied=1 if id==`y' & id_d==`z' 
        }			
}			

		
keep id id_d year allied 
rename allied allied_GOV
label var allied_GOV "DRC Government alliances"
sort id id_d year
save temp_GOV.dta, replace

******************************************************
* RCD
******************************************************
use temp_acled_dyadic.dta, clear
gen allied=0

*146	RCD: Rally for Congolese Democracy
*33	    RCD: Rally for Congolese Democracy (Goma)
*71	    RCD: Rally for Congolese Democracy (Kisangani)
*1256	RCD: Rally for Congolese Democracy (Masunzu)
*1571	RCD: Rally for Congolese Democracy (National)
*general RCD (withour RCD-G)

* conservative coding
global RCD "33 146 1571 "
foreach y of global RCD {
foreach z of global RCD {
replace allied=1 if id==`y' & id_d==`z' 
        }			
}			
global RCD "71 146 1571 "
foreach y of global RCD {
foreach z of global RCD {
replace allied=1 if id==`y' & id_d==`z' 
        }			
}			
global RCD "1256 146 1571 "
foreach y of global RCD {
foreach z of global RCD {
replace allied=1 if id==`y' & id_d==`z' 
        }			
}
*/

keep id id_d year allied 
rename allied allied_RCD
label var allied_RCD "RCD alliances"
sort id id_d year
save temp_RCD.dta, replace

******************************************************
* May
******************************************************
use temp_acled_dyadic.dta, clear
gen allied=0

global May "49 1046 2268 405 1047 765 493"
foreach y of global May {
foreach z of global May {
replace allied=1 if id==`y' & id_d==`z' 
        }			
}			

		
keep id id_d year allied 
rename allied allied_May
label var allied_May "May-May alliances"
sort id id_d year
save temp_May.dta, replace

******************************************************
* Merge all dyadic links
******************************************************

use temp_acled_dyadic.dta, clear
sort id id_d year
merge id id_d year using temp_AF
tab _merge
drop _merge
sort id id_d year
merge id id_d year using temp_SIPRI
tab _merge
drop _merge
sort id id_d year
merge id id_d year using temp_CEDERMAN_ETHNIC
tab _merge
drop _merge
sort id id_d year
merge id id_d year using temp_GLEDITSCH
tab _merge
drop _merge
sort id id_d year
merge id id_d year using temp_ICG
tab _merge
drop _merge
sort id id_d year
merge id id_d year using temp_williams
tab _merge
drop _merge
sort id id_d year
merge id id_d year using temp_reyntjens2001
tab _merge
drop _merge

 
foreach num of numlist 2000 2001 2002 2003 {
sort id id_d year
merge id id_d year using temp_pre`num'
tab _merge
drop _merge
erase temp_pre`num'.dta
        }

 foreach num of numlist 2000 2001 2002 2003 {
 sort id id_d year
merge id id_d year using temp_post`num'
tab _merge
drop _merge
erase temp_post`num'.dta
        }
 
sort id id_d year
merge id id_d year using temp_RCD
tab _merge
drop _merge

sort id id_d year
merge id id_d year using temp_GOV
tab _merge
drop _merge

sort id id_d year
merge id id_d year using temp_May
tab _merge
drop _merge

drop if id==id_d
save temp_acled_dyadic.dta, replace

erase temp_AF.dta
erase temp_SIPRI.dta
erase temp_CEDERMAN_ETHNIC.dta
erase temp_GLEDITSCH.dta
erase temp_ICG.dta
erase temp_williams.dta
erase temp_reyntjens2001.dta
erase mk_cbr_d.dta
erase temp_RCD.dta
erase temp_GOV.dta
erase temp_May.dta
 
******************************************************************************** 
******************************************************************************** 
** We select now the coding rule for links
** and build the related dyadic and monadic bases 
******************************************************************************** 
********************************************************************************  

**


**
use temp_acled_dyadic.dta, clear
gen enemy_SG= max(enemy_SIPRI, enemy_GLEDITSCH, enemy_icg, enemy_williams)
gen allied_SG= max(allied_SIPRI, allied_RCD, allied_GLEDITSCH, allied_icg, allied_williams)
table enemy_SG allied_SG
gen enemy=enemy_SG
replace enemy=enemy_AF if enemy_SG==0 & allied_SG==0 & allied_AF==0 
gen allied=allied_SG
replace allied=allied_AF if allied_SG==0 & enemy_SG==0 & enemy_AF==0
table allied enemy
gen inconsistency=1 if enemy>0 & allied>0
replace enemy=0 if inconsistency==1
replace allied=0 if inconsistency==1 
gen neutral=1-enemy-allied

sort group group_d year
save KRTZ_dyadic_base_mt.dta,replace
save KRTZ_base_mt.dta,replace
save KRTZ_base_benchmark.dta, replace 
do ..\progs\build_monadic.do
do ..\progs\Build_new_IV_rainfall_mt.do 
use temp_rain, clear
do ..\progs\recode_and_label_variables_before_regressions_dr.do
count if degree_plus==0 & degree_minus==0
distinct group if degree_plus==0 & degree_minus==0
 foreach var of varlist  rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 {
                replace `var'=0 if `var'==.
        }
sort id year 
by id: gen lag1TotFight_Enemy=TotFight_Enemy[_n-1]
by id: gen lag1TotFight_Allied=TotFight_Allied[_n-1]
sort id year
merge m:1 id using lon_lat.dta
rename LON longitude
rename LAT latitude
drop if _merge==2
drop _merge
sort id year
save KRTZ_monadic_AF.dta, replace 		
use KRTZ_dyadic_base_mt.dta, clear
save KRTZ_dyadic_AF.dta, replace

***********
*Only battles
do ..\progs\bootstrap_build_bases_battles.do
save temp_battle.dta, replace 		
cap erase KRTZ_base_mt.dta
cap erase KRTZ_dyadic_base_mt.dta

***********
*Updating ACLED coordinates with GED
do ..\progs\bootstrap_Build_all_bases_updating_acled_coordinates_with_ged_when_evts_matched.do
save temp_ged_coord.dta, replace 		
cap erase KRTZ_base_mt.dta
cap erase KRTZ_dyadic_base_mt.dta



cap erase KRTZ_base_mt.dta
cap erase KRTZ_dyadic_base_mt.dta
cap erase aminus.dta
cap erase aplus.dta
cap erase masterdata_DRC.dta
cap erase mk_cbr.dta
cap erase temp_rain.dta
cap erase tempFG.dta
cap erase KRTZ_monadic_base_mt.dta
cap erase KRTZ_base_benchmark.dta
cap erase temp_acled_dyadic.dta
cap erase temp_cederman.dta
cap erase fight_by_location.dta
cap erase geoloc_fight_by_group.dta
cap erase lon_lat.dta

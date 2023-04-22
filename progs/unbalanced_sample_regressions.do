** We consider time-varying periods of activity 


***************************
*** GENERAL SPECIFICATIONS  ***
***************************


clear all
set matsize 1000
qui do  ../progs/my_spatial_2sls

*globals
global lag_specif "	lag(1000000) dist(150) lagdist(1000000) bartlett partial"

global clus "r cl(id)" 
global controlsFE "govern_* foreign_* unpopular_* strong_* D96 D30 D41 D471"

global window_of_activity "keep if year > startyear -1 & year < endyear+1"
global window_of_activity_extended "keep if year > startyear -4 & year < endyear+4"
global active_window "((year > startyear -1) & (year < endyear+1))"
global active_window_extended "((year > startyear -4) & (year < endyear+4))"

* TABLE 1 - BASELINE  

global controlsFE  "govern_* foreign_* unpopular_*          D96_* D30_* D41_* D471_*"
global IVBaseline "rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1"
global controlBaseline "meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE Dgroup*"
global ENDO "TotFight_Enemy TotFight_Allied TotFight_Neutral "


use KRTZ_monadic_AF.dta, clear
my_spatial_2sls TotFight $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif

********************
** Balanced Sample 
********************



****
** Balanced panel with expert coding windows of activity
****
clear
import excel using ../original_data/windows_activity_groups_march16_fz.xls, first
keep id name group_start group_end militia* dummy*
rename name name_fz
destring group_start group_end militia*, replace
*to be consistent with baseline: Let J.Kabila start only in 2002
replace group_start=2002 if id==96
* visual inspection shows that  may-may militia must be recoded
replace militia_start= group_start if id==49 & militia_start==.
replace militia_end= group_end if id==49 & militia_end==.
replace group_start= . if id==49 & militia_start!=.
replace group_end= . if id==49 & militia_end!=.
sort id 
save temp_window.dta, replace
use KRTZ_monadic_AF.dta, clear
sort id
merge m:1 id using temp_window.dta
tab _merge
drop if _merge==2
drop _merge
gen start_fz=max(militia_start, group_start)
gen end_fz=min(militia_end, group_end)
gen window_activity_expert=(year > start_fz -1) & (year < end_fz+1)
sort id year
*br id year name_fz name group_start group_end militia* dummy* window_activity_expert 
sort group year
gen nonzero=year if TotFight>0
gen active = window_activity_expert

foreach num of numlist 1 (1) 85 {
*                display `num'
				cap gen ActiveGroup`num' = active * Dgroup`num'
        }



* eststo: my_spatial_2sls TotFight   active  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 


*regression
eststo: my_spatial_2sls TotFight  ActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight ($ENDO=$IVBaseline) ActiveGroup*  $controlBaseline, $clus first


foreach num of numlist 1 (1) 85 {
foreach y of numlist 1998 (1) 2010 {
				cap gen NonActiveGroup`num'_`y' = (active==0) * Dgroup`num'  * (year==`y')
				cap sum NonActiveGroup`num'_`y'
				scalar M=r(max)
				if M==0{
				cap drop NonActiveGroup`num'_`y'
				* cap di "drop"
				}
        }
}


* eststo: my_spatial_2sls TotFight  NonActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 


****
** Balanced panel with dummies " TotFight>0 x Dgroup*"
****

use KRTZ_monadic_AF.dta, clear
gen nonzero=year if TotFight>0
bysort group: egen startyear= min(nonzero)
bysort group: egen endyear= max(nonzero)
gen active = (TotFight>0)

foreach num of numlist 1 (1) 85 {
*                display `num'
				cap gen ActiveGroup`num' = active * Dgroup`num'
        }


*eststo: my_spatial_2sls TotFight   active  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 

* eststo: my_spatial_2sls TotFight  ActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 





****
** Balanced panel with dummies " ((year > startyear -1) & (year < endyear+1)) x Dgroup*"
****

use KRTZ_monadic_AF.dta, clear
gen nonzero=year if TotFight>0
bysort group: egen startyear= min(nonzero)
bysort group: egen endyear= max(nonzero)
gen active = $active_window

foreach num of numlist 1 (1) 85 {
*                display `num'
				cap gen ActiveGroup`num' = active * Dgroup`num'
        }



* eststo: my_spatial_2sls TotFight   active  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 

*regression
eststo: my_spatial_2sls TotFight  ActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight ($ENDO=$IVBaseline) ActiveGroup*  $controlBaseline, $clus first

 
 
foreach num of numlist 1 (1) 85 {
foreach y of numlist 1998 (1) 2010 {
				cap gen NonActiveGroup`num'_`y' = (active==0) * Dgroup`num'  * (year==`y')
				cap sum NonActiveGroup`num'_`y'
				scalar M=r(max)
				if M==0{
				cap drop NonActiveGroup`num'_`y'
				* cap di "drop"
				}
        }
}


* eststo: my_spatial_2sls TotFight  NonActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 




****
** Balanced panel with dummies " ((year > startyear -4) & (year < endyear+4)) x Dgroup*"
****

use KRTZ_monadic_AF.dta, clear
gen nonzero=year if TotFight>0
bysort group: egen startyear= min(nonzero)
bysort group: egen endyear= max(nonzero)
gen active = $active_window_extended

foreach num of numlist 1 (1) 85 {
*                display `num'
				cap gen ActiveGroup`num' = active * Dgroup`num'
        }



* eststo: my_spatial_2sls TotFight   active  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 

*regression
eststo: my_spatial_2sls TotFight  ActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight ($ENDO=$IVBaseline) ActiveGroup*  $controlBaseline, $clus first

 
 
foreach num of numlist 1 (1) 85 {
foreach y of numlist 1998 (1) 2010 {
				cap gen NonActiveGroup`num'_`y' = (active==0) * Dgroup`num'  * (year==`y')
				cap sum NonActiveGroup`num'_`y'
				scalar M=r(max)
				if M==0{
				cap drop NonActiveGroup`num'_`y'
				* cap di "drop"
				}
        }
}


* eststo: my_spatial_2sls TotFight  NonActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 


/*
*****
** Generalized Fabrizio Dummies
*****
use KRTZ_monadic_AF.dta, clear
gen zeroActivity=(TotFight==0)

foreach y of numlist 1998 (1) 2010 {
foreach num of numlist 1 (1) 85 {
				cap gen NonActiveGroup`num'_`y' = zeroActivity * Dgroup`num'  * (year==`y')
        }
}


*eststo:  my_spatial_2sls TotFight $controlBaseline NonActive*, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif

drop if zeroActivity==1
eststo:  my_spatial_2sls TotFight $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
*/

********************
** Unbalanced Sample 
********************


*********
** Only window_of_activity from expert coding (FZ)

use KRTZ_monadic_AF.dta, clear
sort id
merge m:1 id using temp_window.dta
*erase temp_window.dta
tab _merge
*br if _merge==2
*sort name_fz
*br id name_fz name group_start group_end militia* dummy* _merge if year==2000|year==.
* visual inspection shows that there is no issue with _merge==2 
drop if _merge==2
drop _merge

gen start_fz=max(militia_start, group_start)
gen end_fz=min(militia_end, group_end)
gen window_activity_expert=(year > start_fz -1) & (year < end_fz+1)
sort id year
*br id year name_fz name group_start group_end militia* dummy* window_activity_expert 

sort group year
save temp_time_varying_network.dta, replace
*global window_of_activity "keep if year > startyear -1 & year < endyear+1"
use temp_time_varying_network.dta, clear
keep if window_activity_expert==1
keep group year
sort group year
gen active=1
save temp_active, replace
rename group group_d
sort group_d year
rename active active_d 
save temp_active_d, replace
* Unbalanced panel
use KRTZ_dyadic_AF, clear
keep group group_d year allied enemy
sort group_d year
merge group_d year using temp_active_d
tab _merge
drop _merge 
keep if active_d==1
sort  group year  group_d
collapse (sum) degree_plus_time=allied degree_minus_time=enemy, by( group year)
sort group year
merge group year using temp_time_varying_network.dta
tab _merge
drop _merge 
keep if window_activity_expert==1
qui ivreg2 TotFight ($ENDO =  $IVBaseline)  $controlBaseline,  partial(Dgroup*   $controlsFE)
scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])


local step =1
local prec = 1

*while `prec' >0.0000001 & `step'<100 {
while `prec' >0.002 & `step'<1000 {
cap drop GAM AGG_GAM phistar
gen GAM=1/(1 + beta * degree_plus_time - gamma * degree_minus_time) 
bysort year: egen AGG_GAM=sum(GAM)
gen phistar= GAM * (1-(1/AGG_GAM)) * (1/AGG_GAM)

qui ivreg2 TotFight ($ENDO =  $IVBaseline)  phistar  $controlBaseline,  partial(Dgroup*   $controlsFE)
local prec= 0.5 * (((beta - abs(_b[ TotFight_Allied]))^2 + (gamma - abs(_b[ TotFight_Enemy]))^2)^0.5)

scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

di "Iteration "`step' " with precision " `prec'
local step = `step' + 1

 }

*regression:
eststo: my_spatial_2sls TotFight phistar  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight ($ENDO=$IVBaseline) phistar  $controlBaseline, $clus first
* We check below that 2SLS and Control Functions deliver the same results
ivreg2 TotFight phistar  $controlBaseline ($ENDO = $IVBaseline), r
reg TotFight_Enemy  phistar  $controlBaseline $IVBaseline
predict residE, resid
reg TotFight_Allied  phistar  $controlBaseline $IVBaseline
predict residA, resid
reg TotFight_Neutral  phistar  $controlBaseline $IVBaseline
predict residN, resid
*eststo: reg TotFight phistar  $controlBaseline $ENDO residE residA residN

/*
** Option 1: Only active years: "TotFight >0"

* We build a time varying network based on windows of activity
use KRTZ_monadic_AF.dta, clear
gen nonzero=year if TotFight>0
bysort group: egen startyear= min(nonzero)
bysort group: egen endyear= max(nonzero)
sort group year
save temp_time_varying_network.dta, replace
use temp_time_varying_network.dta, clear
keep if TotFight>0
*keep if TotFight>0
keep group year
sort group year
gen active=1
save temp_active, replace
rename group group_d
sort group_d year
rename active active_d 
save temp_active_d, replace
* Unbalanced panel
use KRTZ_dyadic_AF, clear
keep group group_d year allied enemy
sort group_d year
merge group_d year using temp_active_d
tab _merge
drop _merge 
keep if active_d==1
sort  group year  group_d
collapse (sum) degree_plus_time=allied degree_minus_time=enemy, by( group year)
sort group year
merge group year using temp_time_varying_network.dta
tab _merge
drop _merge 
keep if TotFight>0


qui ivreg2 TotFight ($ENDO =  $IVBaseline)  $controlBaseline,  partial(Dgroup*   $controlsFE)
scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

local step =1
local prec = 1


*while `prec' >0.0000001 & `step'<100 {
while `prec' >0.001 & `step'<1000 {
cap drop GAM AGG_GAM phistar
gen GAM=1/(1 + beta * degree_plus_time - gamma * degree_minus_time) 
bysort year: egen AGG_GAM=sum(GAM)
gen phistar= GAM * (1-(1/AGG_GAM)) * (1/AGG_GAM)

qui ivreg2 TotFight ($ENDO =  $IVBaseline)  phistar  $controlBaseline,  partial(Dgroup*   $controlsFE)
local prec= 0.5 * (((beta - abs(_b[ TotFight_Allied]))^2 + (gamma - abs(_b[ TotFight_Enemy]))^2)^0.5)

scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

di "Iteration "`step' " with precision " `prec'
local step = `step' + 1

 }


*ivreg2 TotFight ($ENDO =  $IVBaseline) phistar $controlBaseline,  partial(Dgroup*   $controlsFE)  
* eststo: my_spatial_2sls TotFight phistar  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*/


*********
** Only window_of_activity "keep if year > startyear -1 & year < endyear+1"
** With or Without dummies " TotFight>0 x Dgroup* "

* We build a time varying network based on windows of activity
use KRTZ_monadic_AF.dta, clear
gen nonzero=year if TotFight>0
bysort group: egen startyear= min(nonzero)
bysort group: egen endyear= max(nonzero)
sort group year
save temp_time_varying_network.dta, replace
*global window_of_activity "keep if year > startyear -1 & year < endyear+1"
use temp_time_varying_network.dta, clear
$window_of_activity
*keep if TotFight>0
keep group year
sort group year
gen active=1
save temp_active, replace
rename group group_d
sort group_d year
rename active active_d 
save temp_active_d, replace
* Unbalanced panel
use KRTZ_dyadic_AF, clear
keep group group_d year allied enemy
sort group_d year
merge group_d year using temp_active_d
tab _merge
drop _merge 
keep if active_d==1
sort  group year  group_d
collapse (sum) degree_plus_time=allied degree_minus_time=enemy, by( group year)
sort group year
merge group year using temp_time_varying_network.dta
tab _merge
drop _merge 
$window_of_activity
qui ivreg2 TotFight ($ENDO =  $IVBaseline)  $controlBaseline,  partial(Dgroup*   $controlsFE)
scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

local step =1
local prec = 1


*while `prec' >0.0000001 & `step'<100 {
while `prec' >0.002 & `step'<1000 {
cap drop GAM AGG_GAM phistar
gen GAM=1/(1 + beta * degree_plus_time - gamma * degree_minus_time) 
bysort year: egen AGG_GAM=sum(GAM)
gen phistar= GAM * (1-(1/AGG_GAM)) * (1/AGG_GAM)

qui ivreg2 TotFight ($ENDO =  $IVBaseline)  phistar  $controlBaseline,  partial(Dgroup*   $controlsFE)
local prec= 0.5 * (((beta - abs(_b[ TotFight_Allied]))^2 + (gamma - abs(_b[ TotFight_Enemy]))^2)^0.5)

scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

di "Iteration "`step' " with precision " `prec'
local step = `step' + 1

 }

*regression
eststo: my_spatial_2sls TotFight phistar  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight ($ENDO=$IVBaseline) phistar  $controlBaseline, $clus first

foreach num of numlist 1 (1) 85 {
*                display `num'
				cap gen ActiveGroup`num' = (TotFight>0) * Dgroup`num'
        }
 
* eststo: my_spatial_2sls TotFight phistar ActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 


*********
** Only window_of_activity_extended "keep if year > startyear -3 & year < endyear+3"
** With or Without dummies " TotFight>0 x Dgroup* "

* We build a time varying network based on windows of activity
use KRTZ_monadic_AF.dta, clear
gen nonzero=year if TotFight>0
bysort group: egen startyear= min(nonzero)
bysort group: egen endyear= max(nonzero)
sort group year
save temp_time_varying_network.dta, replace
*global window_of_activity "keep if year > startyear -1 & year < endyear+1"
use temp_time_varying_network.dta, clear
$window_of_activity_extended
*keep if TotFight>0
keep group year
sort group year
gen active=1
save temp_active, replace
rename group group_d
sort group_d year
rename active active_d 
save temp_active_d, replace
* Unbalanced panel
use KRTZ_dyadic_AF, clear
keep group group_d year allied enemy
sort group_d year
merge group_d year using temp_active_d
tab _merge
drop _merge 
keep if active_d==1
sort  group year  group_d
collapse (sum) degree_plus_time=allied degree_minus_time=enemy, by( group year)
sort group year
merge group year using temp_time_varying_network.dta
tab _merge
drop _merge 
$window_of_activity_extended
qui ivreg2 TotFight ($ENDO =  $IVBaseline)  $controlBaseline,  partial(Dgroup*   $controlsFE)
scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

local step =1
local prec = 1


*while `prec' >0.0000001 & `step'<100 {
while `prec' >0.002 & `step'<1000 {
cap drop GAM AGG_GAM phistar
gen GAM=1/(1 + beta * degree_plus_time - gamma * degree_minus_time) 
bysort year: egen AGG_GAM=sum(GAM)
gen phistar= GAM * (1-(1/AGG_GAM)) * (1/AGG_GAM)

qui ivreg2 TotFight ($ENDO =  $IVBaseline)  phistar  $controlBaseline,  partial(Dgroup*   $controlsFE)
local prec= 0.5 * (((beta - abs(_b[ TotFight_Allied]))^2 + (gamma - abs(_b[ TotFight_Enemy]))^2)^0.5)

scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

di "Iteration "`step' " with precision " `prec'
local step = `step' + 1

 }

*regression:
eststo: my_spatial_2sls TotFight phistar  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight ($ENDO=$IVBaseline) phistar  $controlBaseline, $clus first


foreach num of numlist 1 (1) 85 {
*                display `num'
				cap gen ActiveGroup`num' = (TotFight>0) * Dgroup`num'
        }
 
*eststo: my_spatial_2sls TotFight phistar ActiveGroup*  $controlBaseline, end($ENDO) iv( $IVBaseline) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 


** TOBIT and Poisson with Balanced Panel**
use KRTZ_monadic_AF.dta, clear

qui{
cap drop junk1
cap drop junk2
reg TotFight_Enemy $IVBaseline $controlBaseline
predict junk1, residuals
reg TotFight_Allied $IVBaseline $controlBaseline
predict junk2, residuals
reg TotFight_Neutral $IVBaseline $controlBaseline
predict junk3, residuals
*reg TotFight $ENDO  junk1 junk2 $controlBaseline
}

* Tobit with control functions and bootstraped SE 
*eststo: tobit TotFight $ENDO  junk1 junk2  $controlBaseline,   ll(0) vce(boot, r(10))
eststo: tobit TotFight $ENDO  junk1 junk2 $controlBaseline,  ll(0) 
* vce(cluster group)
* Poisson with control functions and bootstraped SE 
*poisson TotFight $ENDO  junk1 junk2 $controlBaseline,  diff technique(bfgs) iter(200) vce(cluster group)
*poisson TotFight $ENDO  junk1 junk2 $controlBaseline,  diff technique(bfgs) iter(200) vce(boot, r(10))
* Should we do Zero inflated Poisson to cope with our many zeroes?
* eststo: margins , dydx( $ENDO)
 
*/

log using ../results/table_unbalanced_sample.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear

cap erase temp_time_varying_network.dta
cap erase temp_active.dta
cap erase temp_active_d.dta
cap erase temp_window.dta




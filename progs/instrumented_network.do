
clear all

use KRTZ_monadic_AF.dta, clear
save KRTZ_monadic_ref.dta, replace
use KRTZ_dyadic_AF.dta, clear
save KRTZ_dyadic_ref, replace


qui do  ..\progs\my_spatial_2sls

global clus "r cl(id)" 
global lag_specif "lag(1000000) dist(150) lagdist(1000000) partial"
global controlsFE "govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_*"
global IVBaseline "rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1"
global baseline_specification "  xtivreg TotFight (TotFight_Enemy TotFight_Allied  TotFight_Neutral =  $IVBaseline)  meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE, fe i(group) "

** Select the multinomial logit
global FixedEffects "Dgroup1 Dgroup2 Dgroup3 Dgroup4 Dgroup5 Dgroup6 Dgroup7 Dgroup8 Dgroup9 Dgroup10 Dgroup11 Dgroup12 Dgroup13 Dgroup14 Dgroup15 Dgroup16 Dgroup17 Dgroup18 Dgroup19 Dgroup20 Dgroup21 Dgroup22 Dgroup23 Dgroup24 Dgroup25 Dgroup26 Dgroup27 Dgroup29 Dgroup30 Dgroup31 Dgroup33 Dgroup34 Dgroup35 Dgroup37 Dgroup38 Dgroup40 Dgroup41 Dgroup42 Dgroup44 Dgroup56 Dgroup61 Dgroup62 Dgroup63 Dgroup69 Dgroup72 Dgroup73"
global network_cov "common_allied common_enemy common_all_en"
global struc_cov "geodist_dyad same_ethnic_greg same_Hutu_Tutsi different_Hutu_Tutsi  zero_Gov zero_For"
global baseline_logit "asclogit link  csf_surplus ,  case(dyad) alternatives(alternative) casevars($network_cov $struc_cov  $FixedEffects)  basealternative(0)  diff  technique(bfgs)" 

** Construction of the Instruments based on predicted probabilities from the multinomial logit
qui do ..\progs\instrumented_network_proba.do

**
* TABLE B.3 Column 9
**


use KRTZ_monadic_ref.dta, clear
sort group year
merge group year using temp_pred_rain
tab _merge
tab year if _merge==2
drop if _merge==2
drop _merge

eststo clear
log using ../results/TABLE_B3_Col9.txt, text replace
set linesize 150
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(pred_rain_enemies0 pred_sqrain_enemies0 pred_rain_allies0 pred_sqrain_allies0 pred_rain_enemies_enemies0 pred_sqrain_enemies_enemies0 pred_rain_enemies_of_allies0 pred_sqrain_enemies_of_allies0 pred_rain_enemies1 pred_sqrain_enemies1 pred_rain_allies1 pred_sqrain_allies1 pred_rain_enemies_enemies1 pred_sqrain_enemies_enemies1 pred_rain_enemies_of_allies1 pred_sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif  
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear

**
* TABLE B.13
**

use KRTZ_monadic_ref.dta, clear
sort group year
merge group year using temp_pred_rain
tab _merge
tab year if _merge==2
drop if _merge==2
drop _merge

eststo clear

* col. 1
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(pred_rain_enemies0 pred_sqrain_enemies0 pred_rain_allies0 pred_sqrain_allies0 pred_rain_enemies_enemies0 pred_sqrain_enemies_enemies0 pred_rain_enemies_of_allies0 pred_sqrain_enemies_of_allies0 pred_rain_enemies1 pred_sqrain_enemies1 pred_rain_allies1 pred_sqrain_allies1 pred_rain_enemies_enemies1 pred_sqrain_enemies_enemies1 pred_rain_enemies_of_allies1 pred_sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif  

* col. 2
clear
import excel using ..\original_data\windows_activity_groups_march16_fz.xls, first
keep id name group_start group_end militia* dummy*
rename name name_fz
destring group_start group_end militia*, replace
replace group_start=2002 if id==96
replace militia_start= group_start if id==49 & militia_start==.
replace militia_end= group_end if id==49 & militia_end==.
replace group_start= . if id==49 & militia_start!=.
replace group_end= . if id==49 & militia_end!=.
sort id 
save temp_window.dta, replace
use KRTZ_monadic_ref.dta, clear
sort group year
merge group year using temp_pred_rain
tab _merge
tab year if _merge==2
drop if _merge==2
drop _merge
sort id
merge m:1 id using temp_window.dta
tab _merge
drop if _merge==2
drop _merge
gen start_fz=max(militia_start, group_start)
gen end_fz=min(militia_end, group_end)
gen window_activity_expert=(year > start_fz -1) & (year < end_fz+1)
sort id year
sort group year
gen nonzero=year if TotFight>0
gen active = window_activity_expert

foreach num of numlist 1 (1) 85 {
				cap gen ActiveGroup`num' = active * Dgroup`num'
        }

		
eststo: my_spatial_2sls TotFight ActiveGroup* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(pred_rain_enemies0 pred_sqrain_enemies0 pred_rain_allies0 pred_sqrain_allies0 pred_rain_enemies_enemies0 pred_sqrain_enemies_enemies0 pred_rain_enemies_of_allies0 pred_sqrain_enemies_of_allies0 pred_rain_enemies1 pred_sqrain_enemies1 pred_rain_allies1 pred_sqrain_allies1 pred_rain_enemies_enemies1 pred_sqrain_enemies_enemies1 pred_rain_enemies_of_allies1 pred_sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif  


* col. 3
use KRTZ_monadic_ref.dta, clear
sort group year
merge group year using temp_pred_rain
tab _merge
tab year if _merge==2
drop if _merge==2
drop _merge
sort id
merge m:1 id using temp_window.dta
tab _merge
drop if _merge==2
drop _merge

gen start_fz=max(militia_start, group_start)
gen end_fz=min(militia_end, group_end)
gen window_activity_expert=(year > start_fz -1) & (year < end_fz+1)
sort id year

sort group year
save temp_time_varying_network.dta, replace
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
use KRTZ_dyadic_ref, clear
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
ivreg TotFight (TotFight_Enemy TotFight_Allied  TotFight_Neutral =  $IVBaseline)   meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE 

scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])


local step =1
local prec = 1

while `prec' >0.002 & `step'<1000 {
cap drop GAM AGG_GAM phistar
gen GAM=1/(1 + beta * degree_plus_time - gamma * degree_minus_time) 
bysort year: egen AGG_GAM=sum(GAM)
gen phistar= GAM * (1-(1/AGG_GAM)) * (1/AGG_GAM)
qui xtivreg TotFight (TotFight_Enemy TotFight_Allied  TotFight_Neutral =  $IVBaseline) phistar    meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE, fe i(group)
local prec= 0.5 * (((beta - abs(_b[ TotFight_Allied]))^2 + (gamma - abs(_b[ TotFight_Enemy]))^2)^0.5)

scalar beta  = abs(_b[ TotFight_Allied])
scalar gamma = abs(_b[ TotFight_Enemy])

di "Iteration "`step' " with precision " `prec'
local step = `step' + 1

 }


eststo: my_spatial_2sls TotFight phistar meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(pred_rain_enemies0 pred_sqrain_enemies0 pred_rain_allies0 pred_sqrain_allies0 pred_rain_enemies_enemies0 pred_sqrain_enemies_enemies0 pred_rain_enemies_of_allies0 pred_sqrain_enemies_of_allies0 pred_rain_enemies1 pred_sqrain_enemies1 pred_rain_allies1 pred_sqrain_allies1 pred_rain_enemies_enemies1 pred_sqrain_enemies_enemies1 pred_rain_enemies_of_allies1 pred_sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif  

log using ../results/TABLE_B13.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear






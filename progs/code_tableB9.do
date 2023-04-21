**************************************************************
* This program calls the subprogram code_tableB9_sub
**************************************************************

**
* we first select the benchmark 2SLS and the counterfactual OLS and the counterfactual 2SLS that are called below AND in the subprogram
**

global bench2SLS "xtivreg TotFight (TotFight_Enemy TotFight_Allied  TotFight_Neutral = rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 )  meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 govern_* foreign_* unpopular_*          D96_* D30_* D41_* D471_*, fe i(group)"
global count2SLS "xtivreg EFFORT (EFFORT_Enemy EFFORT_Allied  EFFORT_Neutral = rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 )  meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 govern_* foreign_* unpopular_*          D96_* D30_* D41_* D471_*, fe i(group)"
global countOLS "xtreg EFFORT EFFORT_Enemy EFFORT_Allied   TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 D96_* D30_* D41_* D471_*, fe i(group)"


**
* we select the relevant monadic and dyadic dataset before building adjency matrices
**
use KRTZ_monadic_AF.dta, clear
save KRTZ_monadic_ref.dta, replace
use KRTZ_dyadic_AF.dta, clear
save KRTZ_dyadic_ref, replace

* build adjacency matrices
use KRTZ_dyadic_ref.dta, clear
drop if group==group_d
bysort group group_d: keep if [_n]==1 
rename allied aplus
keep group group_d aplus
save aplus_ref.dta, replace

use KRTZ_dyadic_ref.dta, clear
drop if group==group_d
bysort group group_d: keep if [_n]==1 
rename enemy aminus
keep group group_d aminus
save aminus_ref.dta, replace

use KRTZ_dyadic_ref.dta, clear
drop if group==group_d
bysort group group_d: keep if [_n]==1 
keep group group_d id id_d name name_d
save acled_KRTZ_identifiers.dta, replace
	

use KRTZ_monadic_ref.dta, clear
save temp_counterfactual, replace

******************************************************
* Step 1 - Build the (Benchmark) Observed Sample
* outputs are the following dataset : bench_data.dta bench_aplus.dta bench_aminus.dta
******************************************************

*** Check that we replicate our baseline spec w/o clustering
use temp_counterfactual, clear

$bench2SLS

predict RESID, e
predict FE, u
gen stor1=TotFight_Enemy
gen stor2=TotFight_Allied
replace TotFight_Enemy=0
replace TotFight_Allied=0
predict shifter, xb
replace TotFight_Enemy = stor1
replace TotFight_Allied = stor2
gen check= TotFight -( _b[ TotFight_Allied] * TotFight_Allied +  _b[ TotFight_Enemy] * TotFight_Enemy + shifter + FE + RESID)
sum check, d
drop check
gen gamma= _b[ TotFight_Enemy]
gen beta= - _b[ TotFight_Allied]
scalar Tgamma = _b[ TotFight_Enemy]
scalar Tbeta=  - _b[ TotFight_Allied]
gen sd_gamma= _se[ TotFight_Enemy]
gen sd_beta= _se[ TotFight_Allied]
gen scale_correction=1
gen SHIFTER= - shifter * scale_correction
replace FE=FE * scale_correction
replace RESID=RESID * scale_correction
gen hostility=1/(1+beta * degree_plus - gamma * degree_minus) 
tab hostility
tab name if hostility<0
bysort year: egen agg_hostility=sum(hostility)
gen PHI=1-[1/(agg_hostility)]
gen U= PHI * (1- PHI) * hostility
* combine observed/unobserved in one variable
gen TOTAL_SHIFTER=SHIFTER+U-FE-RESID
* separate observed/unobserved variables
rename SHIFTER OBS_SHIFTER
gen EPSILON=-RESID
sum EPSILON, d
gen SD_EPSILON=r(sd)
gen E=U-FE
gen interior=(TotFight>0)
gen Restr_Host = U 
gen Extd_Host = - OBS_SHIFTER + U - E -EPSILON
sum Restr_Host Extd_Host , d
order year beta gamma name hostility group degree_plus degree_minus hostility TotFight TotFight_Enemy TotFight_Allied  TOTAL_SHIFTER OBS_SHIFTER U E EPSILON SD_EPSILON Restr_Host Extd_Host interior 
save bench_data, replace
* a test 
reg TotFight TotFight_Enemy TotFight_Allied OBS_SHIFTER U E EPSILON, noc
keep if e(sample)==1
gen RHS= - OBS_SHIFTER + U - E - EPSILON
reg TotFight TotFight_Enemy TotFight_Allied RHS, noc

rename beta beta_bench 
rename gamma gamma_bench
rename sd_beta sd_beta_bench 
rename sd_gamma sd_gamma_bench


* We retrieve the rain coefficients from the first stage
cap drop e
ivreg2 TotFight (TotFight_Enemy TotFight_Allied = rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 ) meanc_rain1 sqmeanc_rain1 TE* Dgroup*,  $clus first
gen e=e(sample)
xtreg  TotFight_Enemy rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1  meanc_rain1 sqmeanc_rain1 TE*  if e==1, fe i(group)
gen raincoeff= - _b[rain_enemies1]
gen sqraincoeff= - _b[sqrain_enemies1]

keep raincoeff sqraincoeff TotFight TotFight_Enemy TotFight_Allied year beta_bench gamma_bench sd_beta_bench sd_gamma_bench group name OBS_SHIFTER E EPSILON Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1  govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_* TotFight_Neutral  rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 
sort year group
by year : gen MCref=[_n]
duplicates report group MCref
label var MCref "group id in the Monte Carlo simulation"
sort year MCref
save bench_data, replace
keep if year==2000
keep group MCref
sort group
save MC_merging_key.dta, replace

** build bench networks data
use aminus_ref, clear
sort group
by group: keep if [_n]==1
replace group_d=group
replace aminus=0
tab aminus
sort group group_d
save temp_square, replace
use aminus_ref, clear
append using temp_square
sort group group_d
save bench_aminus, replace
use aplus_ref, clear
sort group
by group: keep if [_n]==1
replace group_d=group
replace aplus=0
tab aplus
sort group group_d
save temp_square, replace
use aplus_ref, clear
append using temp_square
sort group group_d
save bench_aplus, replace
erase temp_square.dta

use MC_merging_key.dta, clear
rename MCref MCref_d
rename group group_d
sort group_d
save temp, replace

use bench_aminus, clear
sort group
merge group using MC_merging_key
tab _merge
drop _merge
sort group_d
merge group_d using temp
tab _merge
drop _merge
drop group group_d
sort MCref MCref_d
save bench_aminus, replace
use bench_aplus, clear
sort group
merge group using MC_merging_key
tab _merge
drop _merge
sort group_d
merge group_d using temp
tab _merge
drop _merge
drop group group_d
sort MCref MCref_d
save bench_aplus, replace



******************************************************
* step 2 - Create Fake Data and Estimate
******************************************************

* we first select the set of probabilities of mismeasurement 
global range "0 0.01 0.1 0.2 0.5 1"

set seed 24081972 

qui clear
qui gen beta_est=.
qui gen gamma_est=.
qui gen gamma_OLSest=.
qui gen beta_OLSest=.
qui gen beta_data=.
qui gen gamma_data=.
qui gen sd_beta_data=.
qui gen sd_gamma_data=.
qui gen proba_mismeasure_allied=. 
qui gen proba_mismeasure_ennemy=.
qui gen interior=.
qui save MC_result_enmity_alliance, replace
qui save MC_result_enmity_only, replace
qui save MC_result_alliance_only, replace



**
* Simulation 1: Mismeasurement of enmities and alliances
foreach mis of numlist $range  {
di `mis'
qui scalar p_mismeasure_allied=`mis'   
qui scalar p_mismeasure_ennemy=`mis'

qui do ..\progs\code_tableB9_sub.do

qui use MC3_result, clear
qui save MC3_result_`mis', replace
qui cap erase MC3_result.dta

}

qui use MC_result_enmity_alliance, clear
foreach mis of numlist $range  {
qui append using MC3_result_`mis'
qui cap erase MC3_result_`mis'.dta
}

qui save MC_result_enmity_alliance, replace


**
* Simulation 2: Mismeasurement of enmities only

foreach mis of numlist $range  {
di `mis'
qui scalar p_mismeasure_allied=0   
qui scalar p_mismeasure_ennemy=`mis'
qui do ..\progs\code_tableB9_sub.do
qui use MC3_result, clear
qui save MC3_result_`mis', replace
qui cap erase MC3_result.dta
}
qui use MC_result_enmity_only, clear
foreach mis of numlist $range  {
qui append using MC3_result_`mis'
qui cap erase MC3_result_`mis'.dta
}
qui save MC_result_enmity_only, replace

**
* Simulation 3: Mismeasurement of alliances only

foreach mis of numlist $range  {
di `mis'
qui scalar p_mismeasure_allied=`mis'   
qui scalar p_mismeasure_ennemy=0
qui do ..\progs\code_tableB9_sub.do
qui use MC3_result, clear
qui save MC3_result_`mis', replace
qui cap erase MC3_result.dta
}
qui use MC_result_alliance_only, clear
foreach mis of numlist $range  {
qui append using MC3_result_`mis'
qui cap erase MC3_result_`mis'.dta
}
qui save MC_result_alliance_only, replace






******************************************************
* Step 3 - Display the results 
******************************************************

log using ../results/TableB9.txt, text replace
set linesize 150

*---------------------------------------------------
*---------------------------------------------------
* TRUE COEFFICIENTS 
*---------------------------------------------------
*---------------------------------------------------

di " True coefficient beta is " Tbeta
di "True coefficient gamma is " Tgamma

*---------------------------------------------------
*---------------------------------------------------

use MC_result_enmity_alliance, clear
rename proba_mismeasure_allied proba_mismeasure
sort proba_mismeasure 
collapse (mean) avg_beta=beta_est avg_gamma=gamma_est (sd) sd_beta=beta_est sd_gamma=gamma_est, by(proba_mismeasure)

*---------------------------------------------------
*---------------------------------------------------
*  Results for mismeasurement of both enmities and alliances
*---------------------------------------------------
*---------------------------------------------------

list

*---------------------------------------------------
*---------------------------------------------------

use MC_result_enmity_only, clear
rename proba_mismeasure_ennemy proba_mismeasure
sort proba_mismeasure 
collapse (mean) avg_beta=beta_est avg_gamma=gamma_est (sd) sd_beta=beta_est sd_gamma=gamma_est, by(proba_mismeasure)

*---------------------------------------------------
*---------------------------------------------------
*  Results for mismeasurement of enmities only
*---------------------------------------------------
*---------------------------------------------------

list

*---------------------------------------------------
*---------------------------------------------------

use MC_result_alliance_only, clear
rename proba_mismeasure_allied proba_mismeasure
sort proba_mismeasure 
collapse (mean) avg_beta=beta_est avg_gamma=gamma_est (sd) sd_beta=beta_est sd_gamma=gamma_est, by(proba_mismeasure)

*---------------------------------------------------
*---------------------------------------------------
*  Results for mismeasurement of alliances only
*---------------------------------------------------
*---------------------------------------------------

list

*---------------------------------------------------
*---------------------------------------------------

log close


************
** cleaning 
************

cap erase 
global time "1998(1)2010"
foreach num of numlist $time {
                cap erase  temp`num'.dta
				}
				cap erase acled_KRTZ_identifiers.dta
cap erase KPresult.dta
cap erase Foreign_KPresult.dta
cap erase avgbench_data.dta
cap erase MC_merging_key.dta
cap erase KeyPlayer_result.dta
cap erase bench_data.dta
cap erase bench_simul.dta
cap erase bench_aminus.dta
cap erase bench_aplus.dta
cap erase temp_counterfactual.dta
cap erase simul.dta
cap erase temp.dta
cap erase temp_aplus.dta
cap erase temp_aminus.dta
cap erase temp_MC.dta
cap erase avgbench_simul.dta
cap erase aminus_ref.dta
cap erase aplus_ref.dta
cap erase KRTZ_dyadic_ref.dta
cap erase KRTZ_monadic_ref.dta
cap erase temp_minus.dta
cap erase temp_plus.dta
cap erase MC_result_alliance_only.dta
cap erase MC_result_enmity_only.dta
cap erase MC_result_enmity_alliance.dta
cap erase MC3_result_.5
cap erase MC3_result_.2
cap erase MC3_result_.1
cap erase MC3_result_.01
cap erase bench_aminus.dta
cap erase bench_aplus.dta
cap erase acled_KRTZ_identifiers.dta
	

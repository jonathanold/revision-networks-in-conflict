
*********************************************************************
** step 1 : estimation of multinomial logit on the baseline network**
*********************************************************************

****
* Step 1.1 - Build the (Benchmark) Observed Sample
* outputs are the following dataset : bench_data.dta bench_aplus.dta bench_aminus.dta that are used for building the matrix of covariates for all three alternatives
****

use KRTZ_monadic_ref.dta, clear
keep id group
save temp_id.dta, replace
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
*
use KRTZ_monadic_ref.dta, clear
save temp_counterfactual, replace
use temp_counterfactual, clear

$baseline_specification

sum group
scalar nb_group=r(max)
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
keep Government_org Foreign Restr_Host Extd_Host hostility interior beta gamma TotFight TotFight_Enemy TotFight_Allied EPSILON  SD_EPSILON E OBS_SHIFTER U TOTAL_SHIFTER hostility degree_plus degree_minus year group name 
order year beta gamma name hostility group degree_plus degree_minus hostility TotFight TotFight_Enemy TotFight_Allied  TOTAL_SHIFTER OBS_SHIFTER U E EPSILON SD_EPSILON Restr_Host Extd_Host interior 
save bench_data, replace
* a test 
reg TotFight TotFight_Enemy TotFight_Allied OBS_SHIFTER U E EPSILON, noc
keep if e(sample)==1
gen RHS= - OBS_SHIFTER + U - E - EPSILON
reg TotFight TotFight_Enemy TotFight_Allied RHS, noc
keep Government_org Foreign year beta gamma group name TotFight TotFight_Enemy TotFight_Allied  OBS_SHIFTER  U E EPSILON RHS
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

* Benchmark = average data
use bench_data, clear
sort MCref group name year
collapse (mean) Foreign Government_org  beta gamma TotFight TotFight_Enemy TotFight_Allied OBS_SHIFTER E EPSILON year, by (MCref group name)
replace year=1000
global time "1000"
save avgbench_data, replace

* Simulate the benchmark equilibrium
use avgbench_data, clear
save temp_MC, replace
use bench_aminus, clear
save temp_aminus, replace
use bench_aplus, clear
save temp_aplus, replace
qui do ../progs/eq_simul.do
use simul, clear
save avgbench_simul, replace
collapse(sum) EFFORT
scalar bench_rd = EFFORT
 
*********      
* We build the matrix of covariates for all alternatives
*********

* Build the CSF joint surplus matrix for all alternatives
* Caution: HIGH COMPUTATION TIME ! 
* do ../progs/endo_CSF_surplus_all_alternatives 
* An alternative and faster option is to use directly the outcome dataset of the previous subroutine - This is what we do below
use ../original_data/csf_surplus.dta, clear
save csf_surplus.dta, replace

* Build the network related covariates for all alternatives
 do ../progs/network_related_covariates_alternatives_Fast.do

* build and append the matrix of realized alternatives
use bench_aplus, clear
merge MCref MCref_d using bench_aminus
tab _merge
drop _merge
gen a=aplus-aminus
tab a, missing
keep MCref MCref_d a
sort MCref MCref_d
merge MCref MCref_d using csf_surplus.dta 
tab _merge
drop if _merge==2
drop _merge
tab a
gen link=(a==alternative)
tab link
sort MCref MCref_d alternative
count
count if csf_surplus==.

* create group dummies
foreach g of numlist  1(1) 100 {
if `g'<nb_group+1{
gen Dgroup`g'= (MCref==`g'|MCref_d==`g')
}
}

 
* shape the data for asclogit (triangular)
sum MCref
scalar nb_group=r(max)
drop if MCref<MCref_d
sort MCref MCref_d alternative
egen dyad=group(MCref MCref_d)
drop if MCref==MCref_d


sort MCref MCref_d alternative a
merge MCref MCref_d alternative using temp_cov
tab _merge
drop _merge* 

* retrieve the structural covariates
save temp_struc_cov.dta, replace

use ../original_data/endo_structural_covariates.dta,clear
save temp_structural_covariates.dta, replace

use acled_KRTZ_identifiers.dta, clear
keep id id_d group group_d
sort id id_d 
merge id id_d using temp_structural_covariates.dta 
tab _merge
drop if _merge==2
drop _merge 
drop id id_d
drop if group < group_d
collapse (max) enemy_CEDERMAN allied_CEDERMAN same_ethnic_greg same_Hutu_Tutsi different_Hutu_Tutsi zero_Hutu one_Hutu two_Hutu same_murdock geodist_dyad zero_sectarian one_sectarian two_sectarian zero_Gov one_Gov two_Gov zero_For one_For two_For zero_strong one_strong two_strong , by(group group_d)
sort group group_d
save temp_structural_covariates.dta, replace

use  temp_struc_cov.dta, clear
sort group group_d year
merge group group_d  using temp_structural_covariates.dta
tab _merge
drop _merge 

*********      
* Estimate Multinomial Logit and the unobserved utility draws that are compatible with the observed networks (to be used in the future MC) 
*********

* Estimate the multinomial logit

eststo: $baseline_logit

* predict the baseline probabilities and observed utilities
predict base_proba
keep MCref MCref_d group group_d alternative a base_proba
order MCref MCref_d alternative a base_proba
save temp_baseline.dta, replace

*********      
* Build IVs 
*********

** Retrieve Rainfall data
global lag " 0"
global aggregation "collapse (sum)"
use ../original_data/MC.dta, clear
keep id MCr*
rename MCr10 rain2010
rename MCr09 rain2009
rename MCr08 rain2008
rename MCr07 rain2007
rename MCr06 rain2006
rename MCr05 rain2005
rename MCr04 rain2004
rename MCr03 rain2003
rename MCr02 rain2002
rename MCr01 rain2001
rename MCr00 rain2000
rename MCr99 rain1999
rename MCr98 rain1998
cap rename MCr97 rain1997
cap rename MCr96 rain1996
cap rename MCr95 rain1995
cap drop MCr9510
cap drop MCr11
cap drop MCr9811
sort id
reshape long rain, i(id) j(year)
rename rain meanc_rain_t
replace year=year+ $lag 
label var meanc_rain_t "Rainfall (at the mean-center)"
order id 
sort id year
save temp.dta, replace

use temp_id, clear
rename group group_d
sort id 
merge id using temp
tab _merge
drop if _merge==2
drop _merge
drop id
sort group_d year
save temp.dta, replace


use temp_baseline, clear
rename group trash
rename group_d group
rename trash group_d
rename MCref trash
rename MCref_d MCref
rename trash MCref_d
append using temp_baseline
save temp_network, replace
* create years
use temp_network, clear
expand 16
bysort group group_d alternative: gen year=1994 + [_n] 
sort group_d year
merge group_d year using temp
tab _merge
drop if _merge==2 
drop _merge
* now we weight rainfall by the link probability
replace meanc_rain_t = meanc_rain_t * base_proba
* we keep only enmities and alliances
drop if alternative==0
sort group group_d year alternative
order group group_d year alternative
save temp_network, replace

use temp_network,clear
rename meanc_rain_t meanc_rain0
cap drop meanc_rain_t
replace year=year-1
sort group_d year
merge group_d year using temp
tab _merge
drop if _merge==2 
drop _merge
gen meanc_rain1= meanc_rain_t * base_proba
cap drop meanc_rain_t
replace year=year-1
sort group_d year
merge group_d year using temp
tab _merge
drop if _merge==2 
drop _merge
gen meanc_rain2= meanc_rain_t * base_proba
cap drop meanc_rain_t
replace year=year-1
sort group_d year
merge group_d year using temp
tab _merge
drop if _merge==2 
drop _merge
gen meanc_rain3= meanc_rain_t * base_proba
cap drop meanc_rain_t
replace year=year+3
sort group group_d year alternative
order group group_d year alternative
cap drop meanc_rain_t
save temp_rain, replace
	

* Rainfall for Enemies and Enemies of Enemies

use temp_rain, clear
keep if alternative==-1
sort group year
collapse (sum) meanc_rain*, by(group year)
replace meanc_rain0=. if meanc_rain0==0
replace meanc_rain1=. if meanc_rain1==0
replace meanc_rain2=. if meanc_rain2==0
replace meanc_rain3=. if meanc_rain3==0
rename meanc_rain0 rain_enemies0
rename meanc_rain1 rain_enemies1
rename meanc_rain2 rain_enemies2
rename meanc_rain3 rain_enemies3
sort group year
save tempA, replace

rename group group_d
sort group_d year
save tempAB, replace

use temp_network,clear
sort group group_d year
keep if alternative==-1
keep group  group_d base_proba year
sort group_d year
merge group_d year using tempAB
tab _merge
drop _merge
replace rain_enemies0= rain_enemies0 * base_proba 
replace rain_enemies1= rain_enemies1 * base_proba 
replace rain_enemies2= rain_enemies2 * base_proba 
replace rain_enemies3= rain_enemies3 * base_proba 
sort group year 
collapse (sum) rain_enemies*, by(group year)
rename rain_enemies0 rain_enemies_enemies0
rename rain_enemies1 rain_enemies_enemies1
rename rain_enemies2 rain_enemies_enemies2
rename rain_enemies3 rain_enemies_enemies3
sort group year
save tempB, replace

* Rainfall for Allies and Allies of Allies

use temp_rain, clear
keep if alternative==1
sort group year
collapse (sum) meanc_rain*, by(group year)
replace meanc_rain0=. if meanc_rain0==0
replace meanc_rain1=. if meanc_rain1==0
replace meanc_rain2=. if meanc_rain2==0
replace meanc_rain3=. if meanc_rain3==0
rename meanc_rain0 rain_allies0
rename meanc_rain1 rain_allies1
rename meanc_rain2 rain_allies2
rename meanc_rain3 rain_allies3
sort group year
save tempC, replace

rename group group_d
sort group_d year
save tempCD, replace

use temp_network,clear
sort group group_d year
keep if alternative==1
keep group  group_d base_proba year
sort group_d year
merge group_d year using tempCD
tab _merge
drop _merge
replace rain_allies0= rain_allies0 * base_proba 
replace rain_allies1= rain_allies1 * base_proba 
replace rain_allies2= rain_allies2 * base_proba 
replace rain_allies3= rain_allies3 * base_proba 
sort group year 
collapse (sum) rain_allies*, by(group year)
rename rain_allies0 rain_allies_allies0
rename rain_allies1 rain_allies_allies1
rename rain_allies2 rain_allies_allies2
rename rain_allies3 rain_allies_allies3
sort group year
save tempD, replace

* Rainfall for Enemies of Allies

use temp_network,clear
sort group group_d year
keep if alternative==1
keep group  group_d base_proba year
sort group_d year
merge group_d year using tempAB
tab _merge
drop _merge

replace rain_enemies0= rain_enemies0 * base_proba 
replace rain_enemies1= rain_enemies1 * base_proba 
replace rain_enemies2= rain_enemies2 * base_proba 
replace rain_enemies3= rain_enemies3 * base_proba 
sort group year 
collapse (sum) rain_enemies*, by(group year)
rename rain_enemies0 rain_enemies_of_allies0
rename rain_enemies1 rain_enemies_of_allies1
rename rain_enemies2 rain_enemies_of_allies2
rename rain_enemies3 rain_enemies_of_allies3
sort group year
save tempE, replace


* Merge all dataset

use tempA, clear
sort group year
merge group year using tempB
tab _merge
drop _merge
sort group year
merge group year using tempC
tab _merge
drop _merge
sort group year
merge group year using tempD
tab _merge
drop _merge
sort group year
merge group year using tempE
tab _merge
drop _merge
sort group year

foreach x of varlist rain* {
				gen pred_sq`x'  = (`x')^2  
				rename `x' pred_`x'

        }

		

cap erase temp.dta
cap erase tempA.dta
cap erase tempB.dta
cap erase tempC.dta
cap erase tempD.dta
cap erase tempE.dta
cap erase tempAB.dta
cap erase tempCD.dta

save temp_pred_rain, replace




*********************************************************************
** Estimation of multinomial logit on the baseline network**
*********************************************************************

****
* Build the (Benchmark) Observed Sample
****

* we first select the Baseline monadic and dyadic dataset before building adjency matrices
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
keep Government_org Foreign year degree_plus degree_minus beta gamma group name TotFight TotFight_Enemy TotFight_Allied  OBS_SHIFTER  U E EPSILON RHS
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
collapse (mean) Foreign Government_org degree_plus degree_minus  beta gamma TotFight TotFight_Enemy TotFight_Allied OBS_SHIFTER E EPSILON year, by (MCref group name)
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
* Build the matrix of covariates for all alternatives
*********

* Build the CSF joint surplus matrix for all alternatives
* Caution: HIGH COMPUTATION TIME ! 
* do ../progs/endo_CSF_surplus_all_alternatives 
* An alternative and faster option is to use directly the outcome dataset of the previous subroutine - This is what we do below
use ../original_data/csf_surplus.dta, clear
save csf_surplus.dta, replace

* Build the network related covariates for all alternatives
 do ../progs/network_related_covariates_alternatives_Fast.do

* Build and append the matrix of realized alternatives
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
* below the option (set in the mother program) for multinomial logit
log using ../results/TABLE_B12.txt, text replace
set linesize 150
eststo: $baseline_logit
esttab, keep(csf_surplus $network_cov $struc_cov) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


* predict the baseline probabilities and observed utilities
predict base_proba
predict base_Xbeta, xb
gen exp_base_Xbeta=exp(base_Xbeta)
bysort MCref MCref_d: egen base_inclusive=sum(exp_base_Xbeta)
order MCref MCref_d alternative link base_proba
save temp_baseline.dta, replace


* Draw (for Future Monte Carlo) epsilons that are compatible with the observed networks, 
* CAUTION: epsilon should be Type I (Gumbel-type) extreme-value random variables with mean 
* (the Euler Mascheroni constant, approximately 0.577) and variance (square of pi)/6.

use temp_baseline.dta,clear
keep MCref MCref_d alternative link base_Xbeta base_proba a
gen V_enemity= base_Xbeta if alternative==-1 
gen V_neutral= base_Xbeta if alternative==0 
gen V_allied= base_Xbeta if alternative==1 

replace base_proba=. if link==0
collapse (mean)a V_* base_proba , by (MCref MCref_d)
expand MC_draws  
sort MCref MCref_d

gen success=0
gen epsilon_enemity=.
gen epsilon_neutral=. 
gen epsilon_allied=.


scalar stoploop=0
while stoploop==0 {
qui replace epsilon_enemity= -ln(-ln(runiform())) if success==0
qui replace epsilon_neutral= -ln(-ln(runiform())) if success==0
qui replace epsilon_allied= -ln(-ln(runiform())) if success==0

* below the option (set in the mother program) for unobserved utility: unconditional or conditional to the observation of a link
$unobs1
$unobs2
$unobs3
 
qui sum success
qui scalar stoploop=r(min)
}


tab success

keep MCref MCref_d epsilon_enemity epsilon_neutral epsilon_allied
bysort MCref MCref_d: gen mcdraw=[_n] 
rename epsilon_enemity epsilon_0
rename epsilon_neutral epsilon_1
rename epsilon_allied epsilon_2

egen dyadmc=group(MCref MCref_d mcdraw)
sort dyadmc
reshape long epsilon_, i(dyadmc) j(alternative)
drop dyadmc
replace alternative=alternative-1
rename epsilon_ epsilon
sort mcdraw MCref MCref_d  alternative 
save MC_draws.dta,  replace


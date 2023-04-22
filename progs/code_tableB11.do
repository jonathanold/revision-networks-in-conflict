******************************************************
* Random removal of ACLED events involving small groups
******************************************************

use KRTZ_monadic_AF.dta, clear
keep if year==2000
gen large=degree_plus+ degree_minus
tab large 
gen charac_large=(large>=3)
tab charac_large
keep id charac*
gen p_attrition=0
foreach var of newlist id_ACTOR1 id_ALLY_ACTOR_1 id_ACTOR2 id_ALLY_ACTOR_2 id_ALLY_ACTOR_1B id_ALLY_ACTOR_2B {
                gen `var' = id
        }
drop id
save temp_attrition.dta, replace

******************************************************
* Create Fake Data and Estimate
******************************************************

clear
set obs 1
gen beta=.
gen gama=.
gen delta=.
gen p_attrition=.
gen mc_draw=.
save boostrap_acled_removal_small_groups_results.dta, replace

* we set of probabilities of mismeasurement 
global range " 0.01 0.1 0.2 0.5"

set seed 24081972 


foreach mis of numlist $range  {
di `mis'
qui{
use temp_attrition.dta, clear
replace p_attrition=`mis' if charac_large==0
save temp_attrition.dta, replace
use ../original_data/all_africa_ext, clear
keep if GWNO==490
drop if COUNTRY=="Burundi"
drop if COUNTRY=="Central African Republic"
sort EVENT_ID_NO_CNTY
save temp_all_africa_ext.dta, replace
foreach var of varlist id_ACTOR1 id_ALLY_ACTOR_1 id_ACTOR2 id_ALLY_ACTOR_2 id_ALLY_ACTOR_1B id_ALLY_ACTOR_2B {
                use temp_attrition.dta, clear
				sort `var'
				save temp_attrition.dta,replace
				use temp_all_africa_ext.dta, clear
				sort `var'
				merge `var' using temp_attrition.dta
				tab _merge
				drop if _merge==2
				drop _merge
				rename p_attrition p_attrition_`var'
				cap drop charac*
				save temp_all_africa_ext.dta, replace
        }

foreach mc of numlist 1(1)1000{
di `mc'

use temp_all_africa_ext.dta, clear
foreach var of varlist id_ACTOR1 id_ALLY_ACTOR_1 id_ACTOR2 id_ALLY_ACTOR_2 id_ALLY_ACTOR_1B id_ALLY_ACTOR_2B {
sum p_attrition_`var'
              replace `var'=. if (runiform() < p_attrition_`var') & p_attrition_`var'!=.
        }
drop p_attrition*

qui save all_africa_ext_fake.dta, replace
qui do ../progs/bootstrap_build_base_AF.do

qui use KRTZ_monadic_AF.dta, clear
qui global controlsFE "govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_*" 
ivreg2 TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE (TotFight_Enemy TotFight_Allied TotFight_Neutral = rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) 
keep if [_n]==1
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui gen delta= _b[TotFight_Neutral]
qui keep beta gama delta
qui gen p_attrition=`mis'
qui gen mc_draw=`mc'
qui append using boostrap_acled_removal_small_groups_results.dta
qui save boostrap_acled_removal_small_groups_results.dta, replace
}
}
}
 


use boostrap_acled_removal_small_groups_results.dta, clear
sort p_attrition mc_draw
collapse (mean) avg_beta=beta avg_gama=gam avg_delta=delta (sd) sd_beta=beta sd_gama=gam sd_delta=delta, by(p_attrition)
log using ../results/TableB11.txt, text replace
list
log close
               

cap erase temp_attrition.dta
cap erase temp_all_africa_ext.dta
cap erase all_africa_ext_fake.dta
cap erase boostrap_acled_removal_small_groups_results.dta
cap erase KRTZ_dyadic_AF.dta
cap erase KRTZ_monadic_AF.dta
cap erase boostrap_results_wr_Table_2.dta
cap erase temp_all_africa_ext.dta
cap erase fake_acled_temp.dta

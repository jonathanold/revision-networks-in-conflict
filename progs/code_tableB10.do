
******************************************************
* Draw ACLED events with replacement
* Create Fake Data and Estimate
******************************************************

**
** First we retrieve the events that are in superdataset and that are NOT in ACLED
**
use KRTZ_monadic_AF.dta, clear
keep id year TotFight_Enemy TotFight_Allied TotFight_Neutral TotFight 
foreach var in  TotFight_Enemy TotFight_Allied TotFight_Neutral TotFight {
	rename `var' baseline_acled_`var'
         }
sort id year		 
save baseline_acled_temp.dta, replace
use temp_superdataset.dta, clear
sort id year
merge id year using baseline_acled_temp.dta
tab _merge
keep if _merge==1|_merge==3
drop _merge
replace baseline_acled_TotFight=0 if baseline_acled_TotFight==.
replace baseline_acled_TotFight_Enemy=0 if baseline_acled_TotFight_Enemy==.
replace baseline_acled_TotFight_Allied=0 if baseline_acled_TotFight_Allied==.
replace baseline_acled_TotFight_Neutral=0 if baseline_acled_TotFight_Neutral==.
foreach var in  TotFight_Enemy TotFight_Allied TotFight_Neutral TotFight {
	gen super_`var' = `var' -  baseline_acled_`var'
	drop `var'
         }
sort id year		 
save super_temp.dta, replace
erase baseline_acled_temp.dta


**
** Start of boostrap
**

clear
set obs 1
gen beta=.
gen gama=.
gen delta=.
gen mc_draw=.
save boostrap_results_wr_Table_2.dta, replace

foreach num of numlist 1(1)8 {
                 clear
				 set obs 1
				 gen beta=.
				 gen gama=.
				 gen delta=.
				 gen mc_draw=.
				 save boostrap_results_wr_col_`num'.dta, replace
}


set seed 24081972 

use ../original_data/all_africa_ext, clear
keep if GWNO==490
drop if COUNTRY=="Burundi"
drop if COUNTRY=="Central African Republic"
sort EVENT_ID_NO_CNTY
gen obs=[_n]
sum obs
scalar sample_size=r(max)
sort obs
save bootstrap_temp1.dta, replace
keep obs
sort obs
save bootstrap_temp2.dta, replace

qui{
foreach mc of numlist 1(1)1000{
di `mc'

qui use bootstrap_temp2.dta, clear
qui sum obs
qui scalar sample_size=r(max)
qui replace obs= ceil(runiform() * sample_size)
qui sort obs
qui merge obs using bootstrap_temp1.dta
qui tab _merge
qui keep if _merge==3
qui drop _merge
qui drop obs
qui save all_africa_ext_fake.dta, replace
qui do ../progs/bootstrap_build_base.do

global clus "r cl(id)" 
global controlsFE_reduced  "D96_* D30_* D41_* D471_*" 
global controlsFE "govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_*" 
*Col 1 
use KRTZ_monadic_AF.dta, clear
ivreg2 TotFight TotFight_Enemy TotFight_Allied Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui keep beta gama
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_1.dta
qui save boostrap_results_wr_col_1.dta, replace
*Col 2 
use KRTZ_monadic_AF.dta, clear
ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup* 
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui keep beta gama
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_2.dta
qui save boostrap_results_wr_col_2.dta, replace
*Col 3  
use KRTZ_monadic_AF.dta, clear
ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup* 
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui keep beta gama
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_3.dta
qui save boostrap_results_wr_col_3.dta, replace
*Col 4 
use KRTZ_monadic_AF.dta, clear
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE 
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui gen delta= _b[TotFight_Neutral]
qui keep beta gama delta
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_4.dta
qui save boostrap_results_wr_col_4.dta, replace
*Col 5  
use temp_battle, clear
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE 
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui gen delta= _b[TotFight_Neutral]
qui keep beta gama delta
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_5.dta
qui save boostrap_results_wr_col_5.dta, replace
* Col 6  
use KRTZ_monadic_AF.dta, clear
keep if degree_minus>0
keep if degree_plus>0
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE 
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui gen delta= _b[TotFight_Neutral]
qui keep beta gama delta
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_6.dta
qui save boostrap_results_wr_col_6.dta, replace
*Col 7  
use temp_ged_coord.dta, clear
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE 
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui gen delta= _b[TotFight_Neutral]
qui keep beta gama delta
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_7.dta
qui save boostrap_results_wr_col_7.dta, replace
*Col 8  
use KRTZ_monadic_AF.dta, clear
keep id year TotFight_Enemy TotFight_Allied TotFight_Neutral TotFight 
foreach var in  TotFight_Enemy TotFight_Allied TotFight_Neutral TotFight {
	rename `var'  fake_acled_`var'
         }
sort id year		 
save fake_acled_temp.dta, replace

use super_temp.dta, clear
sort id year
merge id year using fake_acled_temp.dta
tab _merge
keep if _merge==1|_merge==3
drop _merge
replace fake_acled_TotFight=0 if fake_acled_TotFight==.
replace fake_acled_TotFight_Enemy=0 if fake_acled_TotFight_Enemy==.
replace fake_acled_TotFight_Allied=0 if fake_acled_TotFight_Allied==.
replace fake_acled_TotFight_Neutral=0 if fake_acled_TotFight_Neutral==.
gen TotFight= super_TotFight + fake_acled_TotFight
gen TotFight_Enemy= super_TotFight_Enemy + fake_acled_TotFight_Enemy
gen TotFight_Allied= super_TotFight_Allied + fake_acled_TotFight_Allied
gen TotFight_Neutral= super_TotFight_Neutral + fake_acled_TotFight_Neutral

ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE 
qui gen beta = _b[TotFight_Allied]
qui gen gama = _b[TotFight_Enemy]
qui gen delta= _b[TotFight_Neutral]
qui keep beta gama delta
qui keep if [_n]==1
qui gen mc_draw=`mc'
qui append using boostrap_results_wr_col_8.dta
qui save boostrap_results_wr_col_8.dta, replace
}
}

foreach num of numlist 1(1)8 {
use boostrap_results_wr_col_`num'.dta, clear
gen column=`num'
append using boostrap_results_wr_Table_2.dta
save boostrap_results_wr_Table_2.dta, replace
}



use boostrap_results_wr_Table_2.dta, clear
log using ../results/TableB10.txt, text replace
sort column mc_draw
collapse (mean) avg_beta=beta avg_gama=gam avg_delta=delta (sd) sd_beta=beta sd_gama=gam sd_delta=delta, by(column)
list
log close
            


cap erase bootstrap_temp1.dta
cap erase bootstrap_temp2.dta
foreach num of numlist 1(1)8 {
cap erase boostrap_results_wr_col_`num'.dta
}
cap erase boostrap_results_wr_Table_2.dta
cap erase temp_all_africa_ext.dta
cap erase all_africa_ext_fake.dta
cap erase KRTZ_dyadic_AF.dta
cap erase KRTZ_monadic_AF.dta
cap erase super_temp.dta

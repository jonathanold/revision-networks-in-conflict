
*Code for Table B8

clear
global drop all

*Prepare datasets

use ..\original_data\KRTZ_monadic_TRMM50.dta, clear		
keep group year rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1
foreach var in rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1{
	rename 	`var' TRMM50_`var'
         }
		 
sort group year		 
save temp_TRMM50.dta, replace

use ..\original_data\KRTZ_monadic_GPCP.dta, clear		
keep group year rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1
foreach var in rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1{
	rename 	`var' GPCP_`var'
         }
		 
sort group year		 
save temp_GPCP.dta, replace


use KRTZ_monadic_AF.dta, clear
sort group year

merge group year using temp_TRMM50
tab _merge
drop _merge		
sort group year
merge group year using temp_GPCP
tab _merge
drop _merge		
save KRTZ_monadic_sat.dta, replace

use temp_battle, clear
sort group year

merge group year using temp_TRMM50
tab _merge
keep if _merge==3
drop _merge		
sort group year
merge group year using temp_GPCP
tab _merge
keep if _merge==3
drop _merge		
save temp_battle_sat.dta, replace

use temp_ged_coord.dta, clear
sort group year

merge group year using temp_TRMM50
tab _merge
keep if _merge==3
drop _merge		
sort group year
merge group year using temp_GPCP
tab _merge
keep if _merge==3
drop _merge		
save temp_ged_coord_sat.dta, replace

use temp_superdataset.dta, clear
sort group year

merge group year using temp_TRMM50
tab _merge
keep if _merge==1|_merge==3
drop _merge		
sort group year
merge group year using temp_GPCP
tab _merge
keep if _merge==1|_merge==3
rename _merge super_merge
save temp_superdataset_sat.dta, replace
* we replace TRMM/GPCP with GPCC for groups that are not in the baseline sample
use temp_superdataset_sat.dta, clear
foreach var in rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1  rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1{
	replace TRMM50_`var'=`var' if super_merge==1
	replace GPCP_`var'=`var' if super_merge==1
}
drop super_merge
save temp_superdataset_sat.dta, replace
erase temp_TRMM50.dta
erase temp_GPCP.dta

*****************************
** DEFINE GLOBAL
*****************************
clear

qui do  ..\progs\my_spatial_2sls

global TRMM50_IV_rest "TRMM50_rain_enemies1 TRMM50_sqrain_enemies1 TRMM50_rain_allies1 TRMM50_sqrain_allies1" 
global GPCP_IV_rest "GPCP_rain_enemies1 GPCP_sqrain_enemies1 GPCP_rain_allies1 GPCP_sqrain_allies1" 

global TRMM50_control "TRMM50_meanc_rain0 TRMM50_sqmeanc_rain0 TRMM50_meanc_rain1 TRMM50_sqmeanc_rain1"
global GPCP_control "GPCP_meanc_rain0 GPCP_sqmeanc_rain0 GPCP_meanc_rain1 GPCP_sqmeanc_rain1"

global TRMM50_IV_full "TRMM50_rain_enemies0 TRMM50_sqrain_enemies0 TRMM50_rain_allies0 TRMM50_sqrain_allies0 TRMM50_rain_enemies_enemies0 TRMM50_sqrain_enemies_enemies0 TRMM50_rain_enemies_of_allies0 TRMM50_sqrain_enemies_of_allies0 TRMM50_rain_enemies1 TRMM50_sqrain_enemies1 TRMM50_rain_allies1 TRMM50_sqrain_allies1 TRMM50_rain_enemies_enemies1 TRMM50_sqrain_enemies_enemies1 TRMM50_rain_enemies_of_allies1 TRMM50_sqrain_enemies_of_allies1" 
global GPCP_IV_full "GPCP_rain_enemies0 GPCP_sqrain_enemies0 GPCP_rain_allies0 GPCP_sqrain_allies0 GPCP_rain_enemies_enemies0 GPCP_sqrain_enemies_enemies0 GPCP_rain_enemies_of_allies0 GPCP_sqrain_enemies_of_allies0 GPCP_rain_enemies1 GPCP_sqrain_enemies1 GPCP_rain_allies1 GPCP_sqrain_allies1 GPCP_rain_enemies_enemies1 GPCP_sqrain_enemies_enemies1 GPCP_rain_enemies_of_allies1 GPCP_sqrain_enemies_of_allies1"

global TRMM50_IV_full_neutrals "$TRMM50_IV_full TRMM50_rain_neutral0 TRMM50_sqrain_neutral0 TRMM50_rain_neutral1 TRMM50_sqrain_neutral1"
global GPCP_IV_full_neutrals "$GPCP_IV_full GPCP_rain_neutral0 GPCP_sqrain_neutral0 GPCP_rain_neutral1 GPCP_sqrain_neutral1"

global lag_specif_ols "lag(1000000) dist(150) lagdist(1000000) "
global lag_specif "lag(1000000) dist(150) lagdist(1000000) partial "
global clus "r cl(id)" 
global controlsFE_reduced  "D96_* D30_* D41_* D471_*" 
global controlsFE "govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_*" 
global controlsFE_excl "govern_* foreign_* D96_* D30_* D41_* D471_*" 

	
******************************************************
***  Panel A: TRMM50 corrected 98 with GPCP        ***
******************************************************

global IV_rest "$TRMM50_IV_rest"
global IV_full "$TRMM50_IV_full"
global IV_full_neutrals "$TRMM50_IV_full_neutrals"
global control "$TRMM50_control"

** Unpopular 10 **
qui{
foreach file in KRTZ_monadic_sat.dta temp_battle_sat.dta{
                use "`file'", clear
				cap drop unpopular_* unpopular*
				forvalues i = 1998(1)2011 {
				gen unpopular_`i'=0
				replace unpopular_`i'=1 if  degree_minus>=10 & year==`i' //95% percentil
				}
				gen unpopular=0
				replace unpopular=1 if degree_minus>=10
				
				foreach var in   rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1  meanc_rain1 sqmeanc_rain1  rain_neutral1 sqrain_neutral1{
				replace TRMM50_`var'=GPCP_`var' if year==1998
				}
				save "TTEMP_`file'", replace
        }
}

*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
tab degree_minus if year==2000
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

** Unpopular 6 **

qui{
foreach file in KRTZ_monadic_sat.dta temp_battle_sat.dta{
                use "`file'", clear
				cap drop unpopular_* unpopular*
				forvalues i = 1998(1)2011 {
				gen unpopular_`i'=0
				replace unpopular_`i'=1 if  degree_minus>=6 & year==`i' //95% percentil
				}
				gen unpopular=0
				replace unpopular=1 if degree_minus>=6
				foreach var in   rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1  meanc_rain1 sqmeanc_rain1  rain_neutral1 sqrain_neutral1{
				replace TRMM50_`var'=GPCP_`var' if year==1998
				}
				save "TTEMP_`file'", replace
        }
}


*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

** Without Unpopular **

*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE_excl, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE_excl Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE_excl, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE_excl Dgroup*, $clus first

log using ../results/TableB8_PanelA.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


******************************************************
*** Panel B: GPCP                                  ***
******************************************************

global IV_rest "$GPCP_IV_rest "
global IV_full "$GPCP_IV_full "
global IV_full_neutrals "$GPCP_IV_full_neutrals "
global control "$GPCP_control"


** Unpopular 10 **
qui{
foreach file in KRTZ_monadic_sat.dta temp_battle_sat.dta{
                use "`file'", clear
				cap drop unpopular_* unpopular*
				forvalues i = 1998(1)2011 {
				gen unpopular_`i'=0
				replace unpopular_`i'=1 if  degree_minus>=10 & year==`i' //95% percentil
				}
				gen unpopular=0
				replace unpopular=1 if degree_minus>=10
				save "TTEMP_`file'", replace
        }
}

*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
tab degree_minus if year==2000
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

** Unpopular 6 **

qui{
foreach file in KRTZ_monadic_sat.dta temp_battle_sat.dta{
                use "`file'", clear
				cap drop unpopular_* unpopular*
				forvalues i = 1998(1)2011 {
				gen unpopular_`i'=0
				replace unpopular_`i'=1 if  degree_minus>=6 & year==`i' //85% percentil
				}
				gen unpopular=0
				replace unpopular=1 if degree_minus>=6
				save "TTEMP_`file'", replace
        }
}


*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

** Without Unpopular **

*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE_excl, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE_excl Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE_excl, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE_excl Dgroup*, $clus first

log using ../results/TableB8_PanelB.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


******************************************************
***  Panel C: GPCP and TRMM50 corr 98 with GPCP    ***
******************************************************

global IV_rest "$TRMM50_IV_rest $GPCP_IV_rest"
global IV_full "$TRMM50_IV_full $GPCP_IV_full"
global IV_full_neutrals "$TRMM50_IV_full_neutrals $GPCP_IV_full_neutrals"
global control "$TRMM50_control $GPCP_control"

** Unpopular 10 **
qui{
foreach file in KRTZ_monadic_sat.dta temp_battle_sat.dta{
                use "`file'", clear
				cap drop unpopular_* unpopular*
				forvalues i = 1998(1)2011 {
				gen unpopular_`i'=0
				replace unpopular_`i'=1 if  degree_minus>=10 & year==`i' //95% percentil
				}
				gen unpopular=0
				replace unpopular=1 if degree_minus>=10
				
				foreach var in   rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1  meanc_rain1 sqmeanc_rain1  rain_neutral1 sqrain_neutral1{
				replace TRMM50_`var'=GPCP_`var' if year==1998
				}
				save "TTEMP_`file'", replace
        }
}

*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
tab degree_minus if year==2000
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

** Unpopular 6 **

qui{
foreach file in KRTZ_monadic_sat.dta temp_battle_sat.dta{
                use "`file'", clear
				cap drop unpopular_* unpopular*
				forvalues i = 1998(1)2011 {
				gen unpopular_`i'=0
				replace unpopular_`i'=1 if  degree_minus>=6 & year==`i' //95% percentil
				}
				gen unpopular=0
				replace unpopular=1 if degree_minus>=6
				foreach var in   rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1  meanc_rain1 sqmeanc_rain1  rain_neutral1 sqrain_neutral1{
				replace TRMM50_`var'=GPCP_`var' if year==1998
				}
				save "TTEMP_`file'", replace
        }
}


*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE Dgroup*, $clus first

** Without Unpopular **

*Col 4 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_KRTZ_monadic_sat.dta,clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE_excl, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE_excl Dgroup*, $clus first

*Col 5 - 2SLS with degree 1 and 2 neighbors (current rain & lag1) and controlsFE and NEUTRALS
use TTEMP_temp_battle_sat.dta, clear
eststo: my_spatial_2sls TotFight $control Dgroup* $controlsFE_excl, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv($IV_full_neutrals) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral =$IV_full_neutrals) $control $controlsFE_excl Dgroup*, $clus first

log using ../results/TableB8_PanelC.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


*------------------------
* Define globals
*------------------------

clear all
qui do  ..\progs\my_spatial_2sls
global lag_specif_ols "lag(1000000) dist(150) lagdist(1000000) "
global lag_specif "lag(1000000) dist(150) lagdist(1000000) partial "
global clus "r cl(id)" 
global controlsFE_reduced  "D96_* D30_* D41_* D471_*" 
global controlsFE "govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_*" 


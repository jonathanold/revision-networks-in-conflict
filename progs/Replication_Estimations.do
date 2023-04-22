
***********************************************************************************************************
*** REPLICATION DATASET FOR 
*** Koenig, Michael, Dominic Rohner, Mathias Thoenig and Fabrizio Zilibotti, 
*** "Networks in Conflict: Theory and Evidence from the Great War of Africa", 
*** Econometrica ***
*** PLEASE CITE THIS PAPER WHEN USING THE DATA ***
***********************************************************************************************************


*------------------------
* Specify your path
*------------------------

*Note: start by maintaining the same file structure, with a folder XXX and subfolders "regressions", "progs", "original_data" and "results"; do not remove any of the files.
*cd XXX/regressions


*------------------------
* Build Bases for Baseline Table
*------------------------
qui do "${code}/build_databases_baseline_table.do"

*------------------------
* Define globals
*------------------------

clear all
qui do  "${code}/my_spatial_2sls"
global lag_specif_ols "lag(1000000) dist(150) lagdist(1000000) "
global lag_specif "lag(1000000) dist(150) lagdist(1000000) partial "
global clus "r cl(id)" 
global controlsFE_reduced  "D96_* D30_* D41_* D471_*" 
global controlsFE "govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_*" 

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

*** REPLICATION TABLES MAIN TEXT ***


*------------------------
* Replicate Table 1
*------------------------

* Note: The R-squared values can be obtained from the commented out ivreg2 commands.

use KRTZ_monadic_AF.dta, clear

*Col 1 - OLS
my_spatial_2sls TotFight TotFight_Enemy TotFight_Allied Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced , end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  
*eststo: ivreg2 TotFight TotFight_Enemy TotFight_Allied Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced, $clus first

*Col 2 - Reduced IV
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, $clus first

*Col 3 - Full IV
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, $clus first

*Col 4 - Neutrals
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 5 - Battles
use temp_battle, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

* Col 6 - Only with d+>0 & d->0
use KRTZ_monadic_AF.dta, clear
keep if degree_minus>0
keep if degree_plus>0
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 7 - GED coord.
use temp_ged_coord.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 8 - GED union
use temp_superdataset.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

log using ../results/Table1.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


* Quantification Baseline Marginal Effects - col. 4
ivreg2 TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE (TotFight_Enemy TotFight_Allied TotFight_Neutral = rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) 
sum TotFight
scalar SD_TotFight=r(sd)
sum TotFight_Enemy
scalar SD_TotFight_Enemy=round(r(sd))
sum TotFight_Allied
scalar SD_TotFight_Allied=round(r(sd))
scalar ME_Enemy_nb= round(SD_TotFight_Enemy * _b[TotFight_Enemy]) 
scalar ME_Allied_nb= round(SD_TotFight_Allied * _b[TotFight_Allied]) 
scalar ME_Enemy= round(SD_TotFight_Enemy * _b[TotFight_Enemy] / SD_TotFight, .01)
scalar ME_Allied= round(SD_TotFight_Allied * _b[TotFight_Allied] / SD_TotFight, .01)
log using ../results/Quantification_Marginal_Effect_Baseline.txt, text replace
set linesize 150
di " A one SD increase in TFE (" SD_TotFight_Enemy " events) translates into a " ME_Enemy " SD increase in TotFight (" ME_Enemy_nb " events) "
di " A one SD increase in TFA (" SD_TotFight_Allied " events) translates into a " ME_Allied " SD increase in TotFight (" ME_Allied_nb " events)"
log close

stop


*------------------------
* Replicate Table 2
*------------------------

*Col 2 of Table 1
use KRTZ_monadic_AF.dta, clear
cap drop e
my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
gen e=e(sample)
keep if e~=.
eststo: my_spatial_2sls TotFight_Enemy rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  
eststo: my_spatial_2sls TotFight_Allied rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  

*Col 3 of Table 1
use KRTZ_monadic_AF.dta, clear
cap drop e
my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
gen e=e(sample)
keep if e~=.
eststo: my_spatial_2sls TotFight_Enemy rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  
eststo: my_spatial_2sls TotFight_Allied rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  

*Col 4 of Table 1
use KRTZ_monadic_AF.dta, clear
cap drop e
my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
gen e=e(sample)
keep if e~=.
eststo: my_spatial_2sls TotFight_Enemy rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  
eststo: my_spatial_2sls TotFight_Allied rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  

log using ../results/Table2.txt, text replace
set linesize 150
esttab, keep(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


*------------------------
* Replicate Table 3
*------------------------

do ${code}/code_table3.do


*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

*** REPLICATION TABLES MAIN APPENDIX ***


*------------------------
* Replicate Table B.1
*------------------------

use KRTZ_monadic_AF.dta, clear
sum TotFight TotFight_Enemy TotFight_Allied TotFight_Neutral degree_minus degree_plus meanc_rain1


*------------------------
* Replicate Table B.2
*------------------------

use KRTZ_monadic_AF.dta, clear
cap drop unpopular_* unpopular*
forvalues i = 1998(1)2011 {
gen unpopular_`i'=0
replace unpopular_`i'=1 if  degree_minus>=6 & year==`i'
				}
gen unpopular=0
replace unpopular=1 if degree_minus>=6

*Col 1 - OLS
eststo: my_spatial_2sls TotFight TotFight_Enemy TotFight_Allied Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced , end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  
*eststo: ivreg2 TotFight TotFight_Enemy TotFight_Allied Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced, $clus first

*Col 2 - Reduced IV
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, $clus first

*Col 3 - Full IV
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, $clus first

*Col 4 - Neutrals
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 5 - Battles
use temp_battle, clear
cap drop unpopular_* unpopular*
forvalues i = 1998(1)2011 {
gen unpopular_`i'=0
replace unpopular_`i'=1 if  degree_minus>=6 & year==`i'
				}
gen unpopular=0
replace unpopular=1 if degree_minus>=6

eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

* Col 6 - Only with d+>0 & d->0
use KRTZ_monadic_AF.dta, clear
cap drop unpopular_* unpopular*
forvalues i = 1998(1)2011 {
gen unpopular_`i'=0
replace unpopular_`i'=1 if  degree_minus>=6 & year==`i'
				}
gen unpopular=0
replace unpopular=1 if degree_minus>=6
keep if degree_minus>0
keep if degree_plus>0
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 7 - GED coord.
use temp_ged_coord.dta, clear
cap drop unpopular_* unpopular*
forvalues i = 1998(1)2011 {
gen unpopular_`i'=0
replace unpopular_`i'=1 if  degree_minus>=6 & year==`i'
				}
gen unpopular=0
replace unpopular=1 if degree_minus>=6

eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 8 - GED union
use temp_superdataset.dta, clear
cap drop unpopular_* unpopular*
forvalues i = 1998(1)2011 {
gen unpopular_`i'=0
replace unpopular_`i'=1 if  degree_minus>=6 & year==`i'
				}
gen unpopular=0
replace unpopular=1 if degree_minus>=6

eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

log using ../results/TableB2.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


*------------------------
* Replicate Table B.3
*------------------------

* Col 1 - Only degree 2
use KRTZ_monadic_AF.dta, clear
gen sqrain_neutral2=rain_neutral2*rain_neutral2
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 meanc_rain2 sqmeanc_rain2 rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies2 sqrain_enemies2 rain_allies2 sqrain_allies2 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 rain_neutral2 sqrain_neutral2 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_enemies_enemies2 sqrain_enemies_enemies2 rain_enemies_of_allies2 sqrain_enemies_of_allies2) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 rain_neutral2 sqrain_neutral2 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_enemies_enemies2 sqrain_enemies_enemies2 rain_enemies_of_allies2 sqrain_enemies_of_allies2) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 meanc_rain2 sqmeanc_rain2 rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies2 sqrain_enemies2 rain_allies2 sqrain_allies2 Dgroup* $controlsFE, $clus first

*Col 2 - Sample Split 
use ../original_data/KRTZ_monadic_pre02.dta, clear //new standard
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 3 - Only violent events
use ../original_data/KRTZ_violent, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 4 - Only battles, riots and violence against civilians
use ../original_data/KRTZ_battle_violence, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 5 - exclude bilateral events
use ../original_data/KRTZ_base_without_bilat_evts.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

* Col 6 - Lags
use KRTZ_monadic_AF.dta, clear
sort id year 
by id: gen lag1TotFight_Neutral=TotFight_Neutral[_n-1]
eststo: my_spatial_2sls TotFight lag1TotFight_Enemy lag1TotFight_Allied lag1TotFight_Neutral meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE lag1TotFight_Enemy lag1TotFight_Allied lag1TotFight_Neutral, $clus first

*Col 7 - One event enemy
use ../original_data/KRTZ_n0n0, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 8 - Two events ally
use ../original_data/KRTZ_nevts, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 9 - RUM 
*See replication code of Table B.13 Col. 1 in the program "Replication_Policies.do"

*Col 10 - Third polynomial
use KRTZ_monadic_AF.dta, clear

gen p3meanc_rain0=meanc_rain0*meanc_rain0*meanc_rain0
gen p3meanc_rain1=meanc_rain1*meanc_rain1*meanc_rain1
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 p3meanc_rain0 meanc_rain1 sqmeanc_rain1 p3meanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 p3meanc_rain0 meanc_rain1 sqmeanc_rain1 p3meanc_rain1 Dgroup* $controlsFE, $clus first

log using ../results/TableB3.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


*------------------------
* Replicate Table B.4
*------------------------

* Col 1 - FARDC
use ../original_data/KRTZ_merge_gov, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 2 - Mayi Mayi
use ../original_data/KRTZ_merge_MayMay, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

use ../original_data/KRTZ_merge_Rwanda, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

use ../original_data/KRTZ_merge_govDRC_Rwanda.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

log using ../results/TableB4.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


*------------------------
* Replicate Table B.5
*------------------------

*Col 1 - Uga-Rwa neutral
use ../original_data/KRTZ_Ug_Rwa_neutral.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 2 - Uga-Rwa allies
use ../original_data/KRTZ_Ug_Rwa_allied.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 3 - Uga-Rwa allies then neutral
use ../original_data/KRTZ_Ug_Rwa_allied_then_neutral.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 4 - FARDC-FDLR allies then enemies
use ../original_data/KRTZ_DRC_FDLR_allied_enemy.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 5 - FARDC-FDLR neutral
use ../original_data/KRTZ_DRC_FDLR_neutral.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 6 - Exclude CNDD
use ../original_data/KRTZ_withoutCNDD.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 7 - Uga-RCDG enemies
use ../original_data/KRTZ_monadic_Ug_RCDG_enemies.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 8 SADC allies
use ../original_data/KRTZ_monadic_SADC.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 9 Dyadic Closure
use ../original_data/KRTZ_monadic_DyClos.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

log using ../results/TableB5.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


*------------------------
* Replicate Table B.6
*------------------------

*Col 1 - FADRC-ALIR allied 
use ../original_data/KRTZ_monadic_ALIR_GOV_allies.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 2 - FARDC-FDLR/Interahamwe ally then enemy
use ../original_data/KRTZ_DRC_FDLRInterahamwe_allied_enemy.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 3 - FARDC-FDLR/Interahamwe neutral
use ../original_data/KRTZ_DRC_FDLRInterahamwe_neutral.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 4 - FARDC-ADF enemy
use ../original_data/KRTZ_monadic_ADF_GOV_enemies.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 5 - Hema ethnic militia-MLC ally
use ../original_data/KRTZ_monadic_Hema_MLC_allies.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

*Col 6 - FDLR-MayiMayi ally
use ../original_data/KRTZ_monadic_FDLR_MayMay_allies.dta, clear
eststo: my_spatial_2sls TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
*eststo: ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first

log using ../results/TableB6.txt, text replace
set linesize 150
esttab, keep(TotFight_Enemy TotFight_Allied TotFight_Neutral) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear


*------------------------
* Replicate Table B.7
*------------------------

use ../original_data/nc_rain.dta, clear
eststo: reg GPCC TRMM nb_acled Dyear*  if ccode==490 ,  r cl(gid)
eststo: xtreg GPCC TRMM nb_acled Dyear*  if ccode==490 , fe i(gid)  r cl(gid)
eststo: reg lGPCC lTRMM nb_acled Dyear*  if ccode==490 ,  r cl(gid)
eststo: xtreg lGPCC lTRMM nb_acled Dyear*  if ccode==490 , fe i(gid)  r cl(gid)
eststo: reg GPCC GPCP nb_acled Dyear*  if ccode==490 ,  r cl(large_gid)
eststo: xtreg GPCC GPCP nb_acled Dyear*  if ccode==490 , fe i(gid)  r cl(large_gid)
eststo: reg lGPCC lGPCP nb_acled Dyear*  if ccode==490 ,  r cl(large_gid)
eststo: xtreg lGPCC lGPCP nb_acled Dyear*  if ccode==490 , fe i(gid)  r cl(large_gid)

log using ../results/TableB7.txt, text replace
set linesize 150
pwcorr  GPCC TRMM GPCP
esttab, keep(GPCP TRMM lGPCP lTRMM nb_acled ) pr2 r2 starlevels(* 0.1 ** 0.05 *** 0.01)  b(%4.3f) se(%4.3f) label scalars(meanprob) nogaps nolines nodepvars
log close
eststo clear

*------------------------
* Replicate Table B.8
*------------------------

do ${code}/code_tableB8.do


** CAUTION : REPLICATION OF TABLES B.9 B.10 AND B.11 IS TIME INTENSIVE

*------------------------
* Replicate Table B.9
*------------------------

do ${code}/code_tableB9.do

*------------------------
* Replicate Table B.10
*------------------------

do ${code}/code_tableB10.do
* The previous program modified the datasets. We have to rebuild them.
qui do ${code}/build_databases_baseline_table.do

*------------------------
* Replicate Table B.11
*------------------------

do ${code}/code_tableB11.do
* The previous program modified the datasets. We have to rebuild them.
qui do ${code}/build_databases_baseline_table.do


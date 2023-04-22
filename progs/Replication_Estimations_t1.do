
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



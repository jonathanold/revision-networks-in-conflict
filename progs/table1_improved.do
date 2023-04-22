
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
qui do  "${code}/my_spatial_2sls_JDO"
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

use KRTZ_monadic_AF.dta, clear

*Col 1 - OLS
my_spatial_2sls_jo TotFight TotFight_Enemy TotFight_Allied Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced , end() iv( ) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif_ols  
est sto t1_c1
ivreg2 TotFight TotFight_Enemy TotFight_Allied Dgroup* TE* meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced, $clus first
local r2 = e(r2) 
est resto t1_c1
        estadd local controls = "Reduced"
        estadd local estimator = "OLS"
        estadd local iv = "N/A"
        estadd local KP = "N/A"
        estadd local HJ = "N/A"
        estadd scalar r2 = `r2'
est sto t1_c1


*Col 2 - Reduced IV
my_spatial_2sls_jo TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
est sto t1_c2
ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE_reduced TE* Dgroup*, $clus first
local r2 = e(r2) 
est resto t1_c2
        estadd local controls = "Reduced"
        estadd local estimator = "IV"
        estadd local iv = "Restricted"
estadd scalar KP = e(KPstat)
estadd scalar HJ = e(pValueHansen)
        estadd scalar r2 = `r2'
est sto t1_c2


*Col 3 - Full IV
my_spatial_2sls_jo TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, end(TotFight_Enemy TotFight_Allied) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif
est sto t1_c3
ivreg2 TotFight (TotFight_Enemy TotFight_Allied =rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE TE* Dgroup*, $clus first
local r2 = e(r2) 
est resto t1_c3
        estadd local controls = "Full"
        estadd local estimator = "IV"
        estadd local iv = "Full"
estadd scalar KP = e(KPstat)
estadd scalar HJ = e(pValueHansen)
        estadd scalar r2 = `r2'
est sto t1_c3

*Col 4 - Neutrals
my_spatial_2sls_jo TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
est sto t1_c4
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first
local r2 = e(r2) 
est resto t1_c4
        estadd local controls = "Full"
        estadd local estimator = "IV"
        estadd local iv = "Full"
estadd scalar KP = e(KPstat)
estadd scalar HJ = e(pValueHansen)
        estadd scalar r2 = `r2'
est sto t1_c4

*Col 5 - Battles
use temp_battle, clear
my_spatial_2sls_jo TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
est sto t1_c5
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first
local r2 = e(r2) 
est resto t1_c5
        estadd local controls = "Full"
        estadd local estimator = "IV"
        estadd local iv = "Full"
estadd scalar KP = e(KPstat)
estadd scalar HJ = e(pValueHansen)
        estadd scalar r2 = `r2'
est sto t1_c5

* Col 6 - Only with d+>0 & d->0
use KRTZ_monadic_AF.dta, clear
keep if degree_minus>0
keep if degree_plus>0

my_spatial_2sls_jo TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
est sto t1_c6
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first
local r2 = e(r2) 
est resto t1_c6
        estadd local controls = "Full"
        estadd local estimator = "IV"
        estadd local iv = "Full"
estadd scalar KP = e(KPstat)
estadd scalar HJ = e(pValueHansen)
        estadd scalar r2 = `r2'
est sto t1_c6


*Col 7 - GED coord.
use temp_ged_coord.dta, clear

my_spatial_2sls_jo TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
est sto t1_c7

ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first
local r2 = e(r2) 
est resto t1_c7
        estadd local controls = "Full"
        estadd local estimator = "IV"
        estadd local iv = "Full"
estadd scalar KP = e(KPstat)
estadd scalar HJ = e(pValueHansen)
        estadd scalar r2 = `r2'
est sto t1_c7


*Col 8 - GED union
use temp_superdataset.dta, clear
my_spatial_2sls_jo TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, end(TotFight_Enemy TotFight_Allied TotFight_Neutral) iv(rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) latitude(latitude) longitude(longitude) id(group) time(year) $lag_specif 
est sto t1_c8
ivreg2 TotFight (TotFight_Enemy TotFight_Allied TotFight_Neutral=rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1) meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 Dgroup* $controlsFE, $clus first
local r2 = e(r2) 
est resto t1_c8
        estadd local controls = "Full"
        estadd local estimator = "IV"
        estadd local iv = "Full"
estadd scalar KP = e(KPstat)
estadd scalar HJ = e(pValueHansen)
        estadd scalar r2 = `r2'
est sto t1_c8




#delimit ;
estout 
t1_c1 t1_c2 t1_c3 t1_c4  t1_c5 t1_c6  t1_c7 t1_c8
using "../replication_outputs/tables/table_1.tex" , style(tex) 
eqlabels(" " " ") 
wrap varwidth(45) 
varlabels(TotFight_Enemy "Enemies (TFE)" TotFight_Allied "Allies (TFA)" TotFight_Neutral "Neutral (TFN)")
keep(TotFight_Enemy TotFight_Allied TotFight_Neutral)
order(TotFight_Enemy TotFight_Allied TotFight_Neutral)
        cells(b(star fmt(%9.3f)) se(par)) 
 hlinechar("{hline @1}")
stats(controls estimator iv KP HJ N r2  ,
                fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.2fc %9.0fc %9.3fc )
                labels("\midrule \addlinespace Add. Controls" "Estimator" "Instrum. Var." "Kleibergen-Paap F-stat" "Hansen J (p-value)" "Observations" "R-squared"))
starlevels(* 0.1 ** 0.05 *** 0.01) 
nolabel replace collabels(none) mlabels(none)
note("\bottomrule")
  ; 
#delimit cr   




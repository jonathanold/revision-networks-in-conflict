*-------------------------------------
* POLICIES MASTER FILE
* SECTIONS 5 and 6 and Appendix B.2
*-------------------------------------

* All results are stored in the subfolder \results
* Some results being exported as log file, it is important not to use the "quietly" STATA command

clear all

* Here we select the baseline 
global lag_specif "lag(1000000) dist(150) lagdist(1000000) partial "
global clus "r cl(id)"
global controlsFE  "govern_* foreign_* unpopular_*          D96_* D30_* D41_* D471_*"
global IVBaseline "rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1"
global baseline_specification "  xtivreg TotFight (TotFight_Enemy TotFight_Allied  TotFight_Neutral =  $IVBaseline)  meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE, fe i(group) "

* we also select the relevant monadic and dyadic dataset before building adjency matrices
use KRTZ_monadic_AF.dta, clear
save KRTZ_monadic_ref.dta, replace
use KRTZ_dyadic_AF.dta, clear
save KRTZ_dyadic_ref, replace


*------------------------ 
* SECTION 5.1 - REMOVING ARMED GROUPS
* TABLE 4 AND TABLE 5 (top panel)     
*------------------------ 
do ..\progs\KeyPlayerAnalysis.do

* Estimation of Confidence Intervals 
global gamaselect "gen gamma= _b[ TotFight_Enemy] + _se[ TotFight_Enemy]" 
global betaselect "gen beta= - _b[ TotFight_Allied] + _se[ TotFight_Allied]"
do ..\progs\KeyPlayerAnalysis_plusSD.do
global gamaselect "gen gamma= _b[ TotFight_Enemy] - _se[ TotFight_Enemy]" 
global betaselect "gen beta= - _b[ TotFight_Allied] - _se[ TotFight_Allied]"
do ..\progs\KeyPlayerAnalysis_minusSD.do

*------------------------ 
* SECTION 5.2 - ARMS EMBARGO
*------------------------ 

* For this Section the simulations are performed in Matlab
* The corresponding Matlab code can be found in the subfolder \REPLICATION_FILES\progs\embargo_Matlab_progs

*------------------------ 
* SECTION 5.3 - PACIFICATION POLICIES
* [incl. TABLE 6 AND FIGURES REPORTED IN THE TEXT]     
*------------------------ 

do  ..\progs\Targeted_rewiring.do

* Estimation of Confidence Intervals 
global gamaselect "gen gamma= _b[ TotFight_Enemy] + _se[ TotFight_Enemy]" 
global betaselect "gen beta= - _b[ TotFight_Allied] + _se[ TotFight_Allied]"
do ..\progs\Targeted_rewiring_plusSD.do
global gamaselect "gen gamma= _b[ TotFight_Enemy] - _se[ TotFight_Enemy]" 
global betaselect "gen beta= - _b[ TotFight_Allied] - _se[ TotFight_Allied]"
do  ..\progs\Targeted_rewiring_minusSD


* -----------
* Cleaning temporary files
* -----------
do  ..\progs\cleaning.do



*------------------------ 
* SECTION 6 - ENDOGENOUS NETWORK RECOMPOSITION
* ! COMPUTATION TIME INCREASES QUICKLY WITH THE NUMBER OF MONTE CARLO DRAWS !
*------------------------ 

clear all

******
* SET PARAMETERS
******

* Seed and number of MC draws
set seed 24081972
scalar MC_draws =1000

* Choose Baseline Specification of the structural equation
* col 4 of table 1
global controlsFE  "govern_* foreign_* unpopular_*          D96_* D30_* D41_* D471_*"
global IVBaseline "rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1"
global baseline_specification "  xtivreg TotFight (TotFight_Enemy TotFight_Allied  TotFight_Neutral =  $IVBaseline)  meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 $controlsFE, fe i(group) "

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
use temp_counterfactual, clear
$baseline_specification
scalar beta=- _b[TotFight_Allied]
scalar gama= _b[TotFight_Enemy]

* Select the multinomial logit
* Caution 1 - we take "a=0" as the alternative of reference 
* Caution 2 - We must remove fixed effects of groups with low degree_minus and degree_plus to avoid perfect predictors - VISUAL INSPECTION HERE !!
use temp_counterfactual, clear
bys group: keep if [_n]==1
tab degree_minus
tab degree_plus
table degree_minus degree_plus
gen FixEff= (degree_minus > 0) & (degree_plus>0)
tab FixEff
list group  if FixEff==1
global FixedEffects "Dgroup1 Dgroup2 Dgroup3 Dgroup4 Dgroup5 Dgroup6 Dgroup7 Dgroup8 Dgroup9 Dgroup10 Dgroup11 Dgroup12 Dgroup13 Dgroup14 Dgroup15 Dgroup16 Dgroup17 Dgroup18 Dgroup19 Dgroup20 Dgroup21 Dgroup22 Dgroup23 Dgroup24 Dgroup25 Dgroup26 Dgroup27 Dgroup29 Dgroup30 Dgroup31 Dgroup33 Dgroup34 Dgroup35 Dgroup37 Dgroup38 Dgroup40 Dgroup41 Dgroup42 Dgroup44 Dgroup56 Dgroup61 Dgroup62 Dgroup63 Dgroup69 Dgroup72 Dgroup73"
global network_cov "common_allied common_enemy common_all_en"
global struc_cov "geodist_dyad same_ethnic_greg same_Hutu_Tutsi different_Hutu_Tutsi  zero_Gov zero_For"
global baseline_logit "asclogit link  csf_surplus ,  case(dyad) alternatives(alternative) casevars($network_cov $struc_cov  $FixedEffects)  basealternative(0)  diff  technique(bfgs)" 

******
* TABLE B.12 AND FIGURES B.1 AND B.2
******
global unobs1 "qui replace success=1 if success==0"
global unobs2 "qui replace success=1 if success==0"
global unobs3 "qui replace success=1 if success==0"
do ..\progs\endo_network_Estimation.do
do ..\progs\endo_goodness_of_fit.do



******
* TABLE 5 (bottom panel) FIGURE 4 TABLES B.13 B.14
******

* set conditional draws
global unobs1 "qui replace success=1 if success==0 & (a==-1) & (V_enemity+epsilon_enemity>V_allied+epsilon_allied)& (V_enemity+epsilon_enemity>V_neutral+epsilon_neutral)"
global unobs2 "qui replace success=1 if success==0 & (a==0) & (V_neutral+epsilon_neutral>V_enemity+epsilon_enemity)& (V_neutral+epsilon_neutral>V_allied+epsilon_allied)"
global unobs3 "qui replace success=1 if success==0 & (a==1) & (V_allied+epsilon_allied>V_enemity+epsilon_enemity)& (V_allied+epsilon_allied>V_neutral+epsilon_neutral)"
global exo_endo ""
global remove_violation ""
* Generate the counterfactual networks: Estimation of the multinomial logit and DGP matrix of unobserved MC utility draw
do ..\progs\endo_network_Estimation.do

qui use temp_counterfactual, clear
qui sum group
qui scalar nb_group=r(max)

**
** TABLE B.14 
**
do ..\progs\endo_network_Policy_KP.do
use endo_KeyPlayer_result, clear
saveold endo_KeyPlayer_result_Conditional, replace

use endo_KeyPlayer_result_Conditional, clear
keep if rank<16
drop endo_rank
sort endo_Delta_RD
sort rank
drop degree_plus degree_minus interior rank* multiplier
gen multiplier = endo_Delta_RD / bench_fighting_share
label var name "Group"
label var bench_fighting_share "obs. share in aggregate fight."
label var Delta_RD  "count. change in aggregate fight."
label var multiplier"multiplier"
label var endo_Delta_RD  "count. change in aggregate fight. with rewiring (median)"
label var sd_endo_Delta_RD  "count. change in aggregate fight. with rewiring (M.A.D)"
save tempFig4.dta, replace
export excel using ../results/TABLE_B14.xls, replace first(varl)


**
* TABLE 5 (bottom panel) Removal of Subset of Groups  **
**

do ..\progs\endo_network_Policy_remove_subset_groups.do
use endo_KPresult_foreign, clear
saveold endo_Foreign_Conditional, replace
use endo_KPresult_Large_Groups, clear
saveold endo_Large_Groups_Conditional, replace
use endo_KPresult_Ituri, clear
saveold endo_Ituri_Conditional, replace
use endo_KPresult_RCD_UG_RWA, clear
saveold endo_RCD_UG_RWA_Conditional, replace
use endo_KPresult_FDLR_INTER_HUTU, clear
saveold endo_FDLR_INTER_HUTU_Conditional, replace


global experiments "Foreign Large_groups Ituri RCD_UG_RWA FDLR_INTER_HUTU"
foreach y of global experiments {
use endo_`y'_Conditional, clear
drop if Delta_RD==.
sum Delta_RD, d
scalar median_RD=r(p50)
scalar se_RD =r(sd)
egen MAD_r=mad(Delta_RD)
sum MAD_r
scalar MAD_Delta_RD=r(mean)
sum new_enmities if Delta_RD==median_RD, d
scalar enmities_at_median=r(p50)
sum new_alliances if Delta_RD==median_RD, d
scalar alliances_at_median=r(p50)
sum new_enmities, d
scalar median_enmities=r(p50)
scalar se_enmities =r(sd)
egen MAD_e=mad(new_enmities)
sum MAD_e
scalar MAD_enmities=r(mean)
sum new_alliances, d
scalar median_alliances=r(p50)
scalar se_alliances =r(sd)
egen MAD_a=mad(new_alliances)
sum MAD_a
scalar MAD_alliances=r(mean)
log using ../results/TABLE5_endogenous_recomposition_`y'.txt, text replace
set linesize 150
di "Removing the groups leads to a median (and M.A.D.) change in aggregate fighting of"
di median_RD
di MAD_Delta_RD
di "The creation of new enmities at the median is"
di enmities_at_median
di "The creation of new alliances at the median is"
di alliances_at_median
di "The median (and M.A.D.) creation of new enmities is"
di median_enmities
di MAD_enmities
di "The median (and M.A.D.) creation of new alliances is"
di median_alliances
di MAD_alliances
di "The impact of rewiring on Rent Dissipation is characterized by" 
reg Delta_RD new_enmities new_alliances 
log close		
 }



**
** FIGURE 4 
**

use tempFig4.dta, clear
replace Delta_RD=-Delta_RD * 100
replace endo_Delta_RD=-endo_Delta_RD * 100

replace name="RWANDA" if name=="Military Forces of Rwanda"
replace name=abbrev(name,3)
twoway (scatter endo_Delta_RD Delta_RD, mcolor(black) msymbol(none) mlabel(name) mcolor(black)  xscale(range(0 16))) ///
(scatter endo_Delta_RD Delta_RD , mcolor(black) msymbol(circle) ) ///
 (line Delta_RD Delta_RD, lcolor(gs8)  mlabsize(tiny) mlabcolor(blue)) , /// 
 ytitle(Rent Dissip. - Endogenous Network (pct)) xtitle(Rent Dissipation - Exogenous Network (pct)) title("Reduction in Rent Dissipation with exogenous/endogenous network", size(medium)) legend(off) scheme(s1mono)
graph save "..\results\FIGURE4_left.gph", replace	
graph export "..\results\FIGURE4_left.pdf", as(pdf) replace 

use endo_Foreign_Conditional, clear
sum Delta_RD if mc_draw!=., d
twoway (histogram Delta_RD if mc_draw!=., xline(-0.2679, lc(blue)) xline(-0.4133, lc(red)) bin(20) frequency  fcolor(gs8) lcolor(black) lwidth(medthin) lpattern(solid) scheme(s1mono) xscale(range(-0.45 -0.22)) xlabel(#6) yscale(range(0 175)))  , ///
text( 165 -.225 " exogenous network", color(blue) size(small)) ///
text( 165 -.48 " endogenous network (median)", color(red) size(small)) ///
legend (off) ytitle("# MC draws") xtitle("Change in Rent Dissipation (pct)") title("Effect of Removing Foreign Groups with exogenous/endogenous network", size(medium))
graph save "..\results\FIGURE4_right.gph", replace	
graph export "..\results\FIGURE4_right.pdf", as(pdf) replace 


**
** column 9 TABLE B.3 AND TABLE B.13
**

do ..\progs\instrumented_network.do


* -----------
* Cleaning temporary files
* -----------
do  ..\progs\cleaning.do


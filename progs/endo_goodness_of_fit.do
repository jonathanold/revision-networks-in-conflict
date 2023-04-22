****************************************************
* This program computes basic statistics
* on the goodness of fit of the multinomial logit
****************************************************

**
** FIGURE B.1
**

use temp_baseline, clear
keep base_proba MCref MCref_d alternative a
egen dyad=group(MCref MCref_d)

gen true_minus_base_proba=base_proba if alternative==-1 & a==-1
gen false_minus_base_proba=base_proba if alternative==-1 & a!=-1
gen true_plus_base_proba=base_proba if alternative==1 & a==1
gen false_plus_base_proba=base_proba if alternative==1 & a!=1
collapse (mean) true* false* a, by(dyad)	


twoway (histogram true_minus_base_proba, percent bin(50) fcolor(gs5) lcolor(black)) (histogram false_minus_base_proba, percent bin(50) fcolor(gs12) lcolor(black)), ytitle(Frequency) xtitle(Predicted Probability of Enmity) title(Cross-Dyad Distribution of Predicted Probability of Enmity, size(medlarge)) subtitle(Dark Sample: Observed Enmities  -  Light Sample: Other Dyads, size(medsmall)) legend(off) scheme(s1mono)
graph save "../results/endo_predicted_proba_enmities.gph", replace	
graph export "../results/endo_predicted_proba_enmities.pdf", as(pdf) replace 


twoway (histogram true_plus_base_proba, percent bin(50) fcolor(gs5) lcolor(black)) (histogram false_plus_base_proba, percent bin(50) fcolor(gs12) lcolor(black)), ytitle(Frequency) xtitle(Predicted Probability of Alliance) title(Cross-Dyad Distribution of Predicted Probability of Alliance, size(medlarge)) subtitle(Dark Sample: Observed Alliances  -  Light Sample: Other Dyads, size(medsmall)) legend(off) scheme(s1mono)
graph save "../results/endo_predicted_proba_alliances.gph", replace	
graph export "../results/endo_predicted_proba_alliances.pdf", as(pdf) replace 


**
** FIGURE B.2
**

qui use avgbench_data, clear
qui sort MCref
qui sort MCref year
qui save temp_MC, replace

keep MCref
sort MCref
save trash.dta, replace
rename MCref MCref_d
sort MCref_d
save trash_d.dta, replace

qui use bench_aminus, clear
sort MCref
merge MCref using trash
tab _merge
keep if _merge==3
drop _merge
sort MCref_d
merge MCref_d using trash_d
tab _merge
keep if _merge==3
drop _merge
qui sort MCref MCref_d 
qui save temp_aminus, replace

qui use bench_aplus, clear
sort MCref
merge MCref using trash
tab _merge
keep if _merge==3
drop _merge
sort MCref_d
merge MCref_d using trash_d
tab _merge
keep if _merge==3
drop _merge
qui sort MCref MCref_d
qui save temp_aplus, replace

qui do ../progs/compute_network_related_covariates.do
expand 3
bysort MCref MCref_d: gen alternative=[_n]-2 
keep MCref MCref_d alternative $network_cov
foreach var in $network_cov {
gen counter_`var'=`var'
drop  `var'
}


drop if MCref<MCref_d
sort MCref MCref_d alternative
egen dyad=group(MCref MCref_d)
drop if MCref==MCref_d

sort MCref MCref_d alternative
save temp_counter.dta, replace

* counterfactual observed utilities and probabilities 
* redo the logit estimation to be sure that the predicted values are stored  
use temp_baseline, clear
$baseline_logit
* retrieve the counterfactual covariates and merge them with other covariates
sort MCref MCref_d alternative
merge MCref MCref_d alternative using temp_counter
tab _merge
keep if _merge==3
gen counter_csf_surplus=csf_surplus
drop _merge
foreach var in csf_surplus $network_cov {
rename `var' baseline_`var'
gen `var'= counter_`var'

}
predict counter_proba
predict counter_Xbeta, xb
gen exp_counter_Xbeta=exp(counter_Xbeta)
cap drop test counter_inclusive
bysort MCref MCref_d: egen counter_inclusive=sum(exp_counter_Xbeta)
gen base_link=alternative if link==1
drop link
order MCref MCref_d alternative base* counter* 
keep MCref MCref_d alternative counter_Xbeta counter_proba counter_inclusive base_link base_proba base_Xbeta base_inclusive 
sort MCref MCref_d alternative 
save counter_proba.dta, replace
  
* Generate MC links and network
use MC_draws, clear
sort MCref MCref_d alternative 
merge MCref MCref_d alternative using counter_proba
tab _merge
keep if _merge==3
drop _merge
gen counter_utility=counter_Xbeta+epsilon
sort mcdraw MCref MCref_d alternative
bysort mcdraw MCref MCref_d: egen maxU=max(counter_utility)
gen predicted_link= (counter_utility==maxU)
* we store those values for building future statistics on rewiring (see below)
save endo_network_rewiring.dta, replace

* we now build the counterfactual rewired networks
keep if predicted_link==1
replace predicted_link=alternative
drop alternative
order mcdraw MCref MCref_d base_link predicted_link
save temp_goodness.dta, replace
* we assign the observed network to mcdraw=0 
keep if mcdraw==1
replace mcdraw=0
keep MCref MCref_d base_link mcdraw base*
gen predicted_link=base_link
append using temp_goodness.dta 
sort mcdraw MCref MCref_d
save temp_goodness.dta, replace

clear
set obs 1
gen mcdraw=.
save endo_goodness.dta, replace

foreach d of numlist  0(1) 1000 {
if `d'<MC_draws+1{
di `d'
use temp_goodness, clear
keep if mcdraw==`d'
keep MCref MCref_d predicted_link
sort MCref MCref_d
save good_temp.dta, replace
rename MCref trash
rename MCref_d MCref
rename trash MCref_d
rename predicted_link predicted_link_d
sort MCref MCref_d
save good_temp_d.dta, replace
use temp_aplus.dta, clear 
merge MCref MCref_d using good_temp
drop _merge
sort MCref MCref_d
merge MCref MCref_d using good_temp_d
drop _merge
sort MCref MCref_d
replace aplus=(predicted_link==1) if predicted_link!=.
replace aplus=(predicted_link_d==1) if predicted_link_d!=.
drop predicted*
save temp_aplus.dta, replace
use temp_aminus.dta, clear 
merge MCref MCref_d using good_temp
drop _merge
sort MCref MCref_d
merge MCref MCref_d using good_temp_d
drop _merge
sort MCref MCref_d
replace aminus=(predicted_link==-1) if predicted_link!=.
replace aminus=(predicted_link_d==-1) if predicted_link_d!=.
drop predicted*
save temp_aminus.dta, replace

qui do ../progs/compute_network_related_covariates.do
gen mcdraw=`d'
append using endo_goodness
save endo_goodness.dta, replace

}
}


foreach d of numlist  1001(1) 2000 {
if `d'<MC_draws+1{
di `d'
use temp_goodness, clear
keep if mcdraw==`d'
keep MCref MCref_d predicted_link
sort MCref MCref_d
save good_temp.dta, replace
rename MCref trash
rename MCref_d MCref
rename trash MCref_d
rename predicted_link predicted_link_d
sort MCref MCref_d
save good_temp_d.dta, replace
use temp_aplus.dta, clear 
merge MCref MCref_d using good_temp
drop _merge
sort MCref MCref_d
merge MCref MCref_d using good_temp_d
drop _merge
sort MCref MCref_d
replace aplus=(predicted_link==1) if predicted_link!=.
replace aplus=(predicted_link_d==1) if predicted_link_d!=.
drop predicted*
save temp_aplus.dta, replace
use temp_aminus.dta, clear 
merge MCref MCref_d using good_temp
drop _merge
sort MCref MCref_d
merge MCref MCref_d using good_temp_d
drop _merge
sort MCref MCref_d
replace aminus=(predicted_link==-1) if predicted_link!=.
replace aminus=(predicted_link_d==-1) if predicted_link_d!=.
drop predicted*
save temp_aminus.dta, replace

qui do ../progs/compute_network_related_covariates.do
gen mcdraw=`d'
append using endo_goodness
save endo_goodness.dta, replace

}
}

***
** Comparison Nb of degrees
***

* mean and standard deviations
use endo_goodness, clear
drop if mcdraw==.
bysort mcdraw MCref: keep if [_n]==1

collapse (mean) dplus dminus, by (mcdraw)
gen data=(mcdraw==0)
gen d_dplus=dplus if mcdraw==0
gen d_dminus=dminus if mcdraw==0
egen data_dminus=max(d_dminus)
egen data_dplus=max(d_dplus)


collapse (mean) avg_dplus=dplus avg_dminus=dminus (sd) sd_dplus=dplus sd_dminus=dminus, by(data)
outsheet using "../results/endo_goodness_fit_avg_degrees.xls", replace

* Histograms degrees
use endo_goodness, clear
drop if mcdraw==.
bysort mcdraw MCref: keep if [_n]==1

foreach d of numlist  0(1) 20 {
gen degree_plus_`d'=1 if dplus==`d'
gen degree_minus_`d'=1 if dminus==`d'
gen sem_degree_plus_`d'=1 if dplus==`d'
gen sem_degree_minus_`d'=1 if dminus==`d'
}

gen obs=1
collapse (sum) obs degree_plus_* degree_minus_* sem_degree_plus_* sem_degree_minus_* , by (mcdraw)

gen data=(mcdraw==0)
collapse (mean) degree_plus_* degree_minus_* (sd) sem_degree_plus_* sem_degree_minus_* , by (data)

foreach d of numlist  0(1) 20 {
gen ub_plus_`d'=degree_plus_`d' + 1.96 * sem_degree_plus_`d'
gen lb_plus_`d'=degree_plus_`d' - 1.96 * sem_degree_plus_`d'
gen ub_minus_`d'=degree_minus_`d' + 1.96 * sem_degree_minus_`d'
gen lb_minus_`d'=degree_minus_`d' - 1.96 * sem_degree_minus_`d'
}

drop sem*
sort data
reshape long degree_plus_ degree_minus_ ub_plus_ lb_plus_ ub_minus_ lb_minus_, i(data) j(degree)



keep if degree<16

twoway (connected degree_plus_ degree if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono) xscale(range(0 15))) ///	
(connected degree_plus_ degree if data==0, msymbol(smcircle_hollow) lcolor(gs8)) ///	
(line ub_plus_ degree, lcolor(gs8) lpattern(dash)) ///	
(line lb_plus_ degree, lcolor(gs8) lpattern(dash)), ///  
	   text(1 3 "Data", color(black))  ///  
	   text(20 4 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("# Fighting groups") xtitle("Degrees (+1)") 
graph save "../results/endo_goodness_fit_degplus.gph", replace	
graph export "../results/endo_goodness_fit_graph_degplus.pdf", as(pdf) replace 


twoway (connected degree_minus_ degree if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono) xscale(range(0 15))) ///	
(connected degree_minus_ degree if data==0, msymbol(smcircle_hollow) lcolor(gs8)) ///	
(line ub_minus_ degree, lcolor(gs8) lpattern(dash)) ///	
(line lb_minus_ degree, lcolor(gs8) lpattern(dash)), ///  
	   text(1 3 "Data", color(black))  ///  
	   text(20 4 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("# Fighting groups") xtitle("Degrees (-1)") 
graph save "../results/endo_goodness_fit_degminus.gph", replace	
graph export "../results/endo_goodness_fit_graph_degminus.pdf", as(pdf) replace 



****
** Histogram interior conditions
use endo_goodness, clear
drop if mcdraw==.
bysort mcdraw MCref: keep if [_n]==1

gen interior=1+ beta * dplus - gamma * dminus

foreach dp of numlist  0(1) 20 {
foreach dm of numlist  0(1) 20 {

gen interior_`dp'_`dm'=1 if dplus==`dp'& dminus==`dm'
gen sem_interior_`dp'_`dm'=1 if dplus==`dp'& dminus==`dm'
}
}

gen obs=1
collapse (sum) obs interior_* sem_interior_* , by (mcdraw)

gen data=(mcdraw==0)
collapse (mean) interior_* (sd) sem_interior_* , by (data)

foreach dp of numlist  0(1) 20 {
foreach dm of numlist  0(1) 20 {

gen ub_plus_`dp'_`dm'=interior_`dp'_`dm' + 1 * sem_interior_`dp'_`dm'
gen lb_plus_`dp'_`dm'=max(interior_`dp'_`dm' - 1  * sem_interior_`dp'_`dm',0)
}
}

drop sem*
sort data
global varA "interior_0_ interior_1_ interior_2_ interior_3_ interior_4_ interior_5_  interior_6_ interior_7_ interior_8_ interior_9_"
global varB "interior_10_ interior_11_ interior_12_ interior_13_ interior_14_ interior_15_  interior_16_ interior_17_ interior_18_ interior_19_ interior_20_"
global varC "ub_plus_0_ ub_plus_1_ ub_plus_2_ ub_plus_3_ ub_plus_4_ ub_plus_5_  ub_plus_6_ ub_plus_7_ ub_plus_8_ ub_plus_9_"
global varD "ub_plus_10_ ub_plus_11_ ub_plus_12_ ub_plus_13_ ub_plus_14_ ub_plus_15_  ub_plus_16_ ub_plus_17_ ub_plus_18_ ub_plus_19_ ub_plus_20_"
global varE "lb_plus_0_ lb_plus_1_ lb_plus_2_ lb_plus_3_ lb_plus_4_ lb_plus_5_  lb_plus_6_ lb_plus_7_ lb_plus_8_ lb_plus_9_"
global varF "lb_plus_10_ lb_plus_11_ lb_plus_12_ lb_plus_13_ lb_plus_14_ lb_plus_15_  lb_plus_16_ lb_plus_17_ lb_plus_18_ lb_plus_19_ lb_plus_20_"

reshape long $varA $varB $varC $varD $varE $varF , i(data) j(dminus)

foreach dp of numlist  0(1) 20 {
rename interior_`dp'_ interior_`dp'
rename ub_plus_`dp'_ ub_`dp'
rename lb_plus_`dp'_ lb_`dp'
}

reshape long interior_ ub_ lb_ , i(data dminus) j(dplus)

gen value=1+ beta * dplus - gamma * dminus
sort value
keep if interior_>0
twoway (scatter interior_ value if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono)) ///	
(scatter interior_ value if data==0, msymbol(smcircle_hollow) lcolor(gs8))  ///
(line ub_ value, lcolor(gs8) lpattern(dash)) ///	
(line lb_ value, lcolor(gs8) lpattern(dash)), ///  
	   text(1 3 "Data", color(black))  ///  
	   text(20 4 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("# Fighting groups") xtitle("Degrees (+1)") 

sum value, d
scalar minval=r(min)
scalar maxval=r(max)
global Nbbin "20"

gen bin= ceil($Nbbin * (value-minval)/(maxval-minval))

collapse (sum) interior_ ub_ lb_ (mean)value , by(data bin)
replace ub_=. if ub_==0 & data==0
replace ub_=. if  data==1
replace lb_=. if data==1

twoway (connected interior_ value if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono)) ///	
(connected interior_ value if data==0, msymbol(smcircle_hollow) lcolor(gs8) lstyle(solid))  ///
(line ub_ value, lcolor(gs8) lpattern(dash)) ///	
(line lb_ value, lcolor(gs8) lpattern(dash)), ///  
	   text(6 2 "Data", color(black))  ///  
	   text(5 1 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("# Fighting groups") xtitle("Degrees (+1)") 
graph save "../results/endo_goodness_fit_interior.gph", replace	
graph export "../results/endo_goodness_fit_interior.pdf", as(pdf) replace 



***
** Comparison triadic closures
***
use endo_goodness, clear
drop if mcdraw==.
keep if MCref>MCref_d
keep if aminus==1|aplus==1

foreach d of numlist  0(1) 20 {
gen Common_`d'=1 if common==`d'
gen Common_allied_`d'=1 if common_allied==`d'
gen Common_enemy_`d'=1 if common_enemy==`d'
gen Common_all_en_`d'=1 if common_all_en==`d'
gen sem_Common_`d'=1 if common==`d'
gen sem_Common_allied_`d'=1 if common_allied==`d'
gen sem_Common_enemy_`d'=1 if common_enemy==`d'
gen sem_Common_all_en_`d'=1 if common_all_en==`d'
}

gen obs=1
collapse (sum) obs Common* sem*, by (mcdraw)

 foreach var of varlist Common* sem* {
                replace `var' = `var'/obs
        }



gen data=(mcdraw==0)
collapse (mean) Common* (sd) sem* , by (data)

foreach d of numlist  0(1) 20 {
gen ub_Common_`d'= Common_`d' + 1.96 * sem_Common_`d'
gen lb_Common_`d'= Common_`d' - 1.96 * sem_Common_`d'
gen ub_Common_allied_`d'= Common_allied_`d' + 1.96 * sem_Common_allied_`d'
gen lb_Common_allied_`d'= Common_allied_`d' - 1.96 * sem_Common_allied_`d'
gen ub_Common_enemy_`d'= Common_enemy_`d' + 1.96 * sem_Common_enemy_`d'
gen lb_Common_enemy_`d'= Common_enemy_`d' - 1.96 * sem_Common_enemy_`d'
gen ub_Common_all_en_`d'= Common_all_en_`d' + 1.96 * sem_Common_all_en_`d'
gen lb_Common_all_en_`d'= Common_all_en_`d' - 1.96 * sem_Common_all_en_`d'
}

drop sem*
sort data
reshape long Common_ Common_enemy_ Common_allied_ Common_all_en_ ub_Common_ ub_Common_enemy_ ub_Common_allied_ ub_Common_all_en_ lb_Common_ lb_Common_enemy_ lb_Common_allied_ lb_Common_all_en_ , i(data) j(degree)

twoway (connected Common_ degree if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono) xscale(range(0 15))) ///	
(connected Common_ degree if data==0, msymbol(smcircle_hollow) lcolor(gs8)) ///	
(line ub_Common_ degree, lcolor(gs8) lpattern(dash)) ///	
(line lb_Common_ degree, lcolor(gs8) lpattern(dash)), ///  
	   text(.15 5 "Data", color(black))  ///  
	   text(.01 5 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("share of connected dyads") xtitle("# common neighbors") 
graph save "../results/endo_goodness_fit_common.gph", replace	
graph export "../results/endo_goodness_fit_graph_common.pdf", as(pdf) replace 

twoway (connected Common_enemy_ degree if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono) xscale(range(0 15))) ///	
(connected Common_enemy_ degree if data==0, msymbol(smcircle_hollow) lcolor(gs8)) ///	
(line ub_Common_enemy_ degree, lcolor(gs8) lpattern(dash)) ///	
(line lb_Common_enemy_ degree, lcolor(gs8) lpattern(dash)), ///  
	   text(.15 5 "Data", color(black))  ///  
	   text(.01 2 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("share of connected dyads") xtitle("# common enemies") 
graph save "../results/endo_goodness_fit_common_enemy_.gph", replace	
graph export "../results/endo_goodness_fit_graph_common_enemy_.pdf", as(pdf) replace 


twoway (connected Common_allied_ degree if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono) xscale(range(0 15))) ///	
(connected Common_allied_ degree if data==0, msymbol(smcircle_hollow) lcolor(gs8)) ///	
(line ub_Common_allied_ degree, lcolor(gs8) lpattern(dash)) ///	
(line lb_Common_allied_ degree, lcolor(gs8) lpattern(dash)), ///  
	   text(.15 5 "Data", color(black))  ///  
	   text(.01 2 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("share of connected dyads") xtitle("# common allied") 
graph save "../results/endo_goodness_fit_common_allied_.gph", replace	
graph export "../results/endo_goodness_fit_graph_common_allied_.pdf", as(pdf) replace 


twoway (connected Common_all_en_ degree if data==1  , mcolor(black) msymbol(circle_hollow) lcolor(black) scheme(s1mono) xscale(range(0 15))) ///	
(connected Common_all_en_ degree if data==0, msymbol(smcircle_hollow) lcolor(gs8)) ///	
(line ub_Common_all_en_ degree, lcolor(gs8) lpattern(dash)) ///	
(line lb_Common_all_en_ degree, lcolor(gs8) lpattern(dash)), ///  
	   text(.15 5 "Data", color(black))  ///  
	   text(.01 2 "Monte Carlo", color(gs8)) ///  
	   legend(off) ytitle("share of connected dyads") xtitle("# common antagonistic neighbors") 
graph save "../results/endo_goodness_fit_common_all_en_.gph", replace	
graph export "../results/endo_goodness_fit_graph_common_all_en_.pdf", as(pdf) replace 	

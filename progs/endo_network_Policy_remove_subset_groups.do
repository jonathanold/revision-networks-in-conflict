***
*** Policy 1: drop foreign groups
***

import excel using ..\original_data\coding_characteristics_FZ.xls, clear first
keep Group FOREIGNGROUPS
rename Group name 
rename FOREIGNGROUPS Foreign_FZ
sort name 
save temp_fz, replace
qui use avgbench_data, clear
sort name
merge name using temp_fz
tab _merge
drop if _merge==2
count
drop _merge
erase temp_fz.dta
table Foreign Foreign_FZ
replace Foreign=Foreign_FZ
qui sort MCref
qui drop if Foreign ==1
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


*
* w/o recomposition of the network
*

qui do ..\progs\eq_simul.do
* CAUTION !! THE MCref change after this subroutine. Do Not USE THEM FOR THE PURPOSE OF MERGING
qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
label var Delta_RD  "count. change in aggregate fight."
save exo_KPresult_foreign, replace

*
* with endogenous recomposition of the network
*

* Generate counterfactual covariates
qui do ..\progs\compute_network_related_covariates.do
expand 3
bysort MCref MCref_d: gen alternative=[_n]-2 
keep MCref MCref_d alternative $network_cov
foreach var in $network_cov {
gen counter_`var'=`var'
drop  `var'
}
* must be triangular
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
rename link base_link
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
rename alternative a
keep MCref MCref_d mcdraw a
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace
* finally we need to "square" the matrix with mirrors and and then fill the diagonal
use MC_counter_network, clear
rename MCref stor
rename MCref_d MCref
rename stor MCref_d
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

bysort mcdraw MCref: keep if [_n]==1 
replace MCref_d=MCref
replace a=0
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

gen cond= beta * (a==1) - gama * (a==-1) 
collapse (sum) cond , by (mcdraw MCref) 
replace cond = (1+cond<0)
collapse (sum) cond, by(mcdraw)
rename mcdraw mc_draw
sort mc_draw
save interior_condition_foreign.dta, replace

* MC draws
clear
set obs 1
gen mc_draw=.
save endo_KPresult_foreign, replace

foreach d of numlist  1(1) 1000 {
if `d'<MC_draws+1{
di `d'
use MC_counter_network, clear
keep if mcdraw==`d'
gen aminus= (a==-1)
keep MCref MCref_d aminus 
sort MCref MCref_d
save temp_aminus, replace

use MC_counter_network, clear
keep if mcdraw==`d'
gen aplus= (a==1)
keep MCref MCref_d aplus
sort MCref MCref_d
save temp_aplus, replace


qui do ..\progs\eq_simul.do

* CAUTION !! THE MCref change after this subroutine. Do Not USE THEM FOR THE PURPOSE OF MERGING
qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_endo_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_endo_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
save Foreign_endo_KPresult, replace
label var Delta_RD  "count. change in aggregate fight."
gen mc_draw=`d'
append using endo_KPresult_foreign
save endo_KPresult_foreign, replace

}
}



use endo_KPresult_foreign, clear
sort mc_draw
save endo_KPresult_foreign, replace

* Retrieve basic statistics on rewiring
use endo_network_rewiring, clear
keep MCref MCref_d alternative base_link predicted_link mcdraw
gen base_aminus=1 if base_link==1 & alternative==-1
gen endo_aminus=1 if predicted_link==1 & alternative==-1
gen base_aplus=1 if base_link==1 & alternative==1
gen endo_aplus=1 if predicted_link==1 & alternative==1
collapse (sum) base_link predicted_link base_aminus endo_aminus base_aplus endo_aplus, by(mcdraw)
gen new_enmities=(endo_aminus - base_aminus) 
gen new_alliances=(endo_aplus - base_aplus) 
keep mcdraw new_enmities new_alliances
rename mcdraw mc_draw
 
sort mc_draw
merge mc_draw using endo_KPresult_foreign
tab _merge
drop _merge
append using exo_KPresult_foreign
drop if mc_draw==. & bench_RD==.
replace mc_draw=-1000 if mc_draw==.
sort mc_draw
replace mc_draw=. if mc_draw==-1000
gen policy="EXO netw." if mc_draw==.
replace policy="ENDO netw." if mc_draw!=.
label var new_enmities "avg rewiring: New enmities (pct)" 
label var new_alliances "avg rewiring: New alliances (pct)"
save endo_KPresult_foreign, replace


replace mc_draw=-1000 if mc_draw==.
sort mc_draw
merge mc_draw using interior_condition_foreign.dta
tab _merge
drop _merge
rename cond condition_violation
label var condition_violation "Is interior condition violated? 0/1 "
replace mc_draw=. if mc_draw==-1000
save endo_KPresult_foreign, replace


***
*** large groups
***

qui use avgbench_data, clear
qui sort MCref
sum degree_minus, d
drop if degree_minus >4
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


*
* w/o recomposition of the network
*

qui do ..\progs\eq_simul.do
* CAUTION !! THE MCref change after this subroutine. Do Not USE THEM FOR THE PURPOSE OF MERGING
qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
label var Delta_RD  "count. change in aggregate fight."
save exo_KPresult_Large_Groups, replace


*
* with endogenous recomposition of the network
*

* Generate counterfactual covariates 
qui do ..\progs\compute_network_related_covariates.do
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
use temp_baseline, clear
$baseline_logit
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
rename link base_link
order MCref MCref_d alternative base* counter* 
keep MCref MCref_d alternative counter_Xbeta counter_proba counter_inclusive base_link base_proba base_Xbeta base_inclusive 
sort MCref MCref_d alternative 
save counter_proba.dta, replace
  
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
save endo_network_rewiring.dta, replace

keep if predicted_link==1
rename alternative a
keep MCref MCref_d mcdraw a
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace
use MC_counter_network, clear
rename MCref stor
rename MCref_d MCref
rename stor MCref_d
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

bysort mcdraw MCref: keep if [_n]==1 
replace MCref_d=MCref
replace a=0
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

gen cond= beta * (a==1) - gama * (a==-1) 
collapse (sum) cond , by (mcdraw MCref) 
replace cond = (1+cond<0)
collapse (sum) cond, by(mcdraw)
rename mcdraw mc_draw
sort mc_draw
save interior_condition_foreign.dta, replace

clear
set obs 1
gen mc_draw=.
save endo_KPresult_Large_Groups, replace

foreach d of numlist  1(1) 1000 {
if `d'<MC_draws+1{
di `d'
use MC_counter_network, clear
keep if mcdraw==`d'
gen aminus= (a==-1)
keep MCref MCref_d aminus 
sort MCref MCref_d
save temp_aminus, replace

use MC_counter_network, clear
keep if mcdraw==`d'
gen aplus= (a==1)
keep MCref MCref_d aplus
sort MCref MCref_d
save temp_aplus, replace


qui do ..\progs\eq_simul.do

qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_endo_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_endo_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
save Foreign_endo_KPresult, replace
label var Delta_RD  "count. change in aggregate fight."
gen mc_draw=`d'
append using endo_KPresult_Large_Groups
save endo_KPresult_Large_Groups, replace


}
}



use endo_KPresult_Large_Groups, clear
sort mc_draw
save endo_KPresult_Large_Groups, replace
use endo_network_rewiring, clear
keep MCref MCref_d alternative base_link predicted_link mcdraw
gen base_aminus=1 if base_link==1 & alternative==-1
gen endo_aminus=1 if predicted_link==1 & alternative==-1
gen base_aplus=1 if base_link==1 & alternative==1
gen endo_aplus=1 if predicted_link==1 & alternative==1
collapse (sum) base_link predicted_link base_aminus endo_aminus base_aplus endo_aplus, by(mcdraw)
gen new_enmities=(endo_aminus - base_aminus) 
gen new_alliances=(endo_aplus - base_aplus) 
keep mcdraw new_enmities new_alliances
rename mcdraw mc_draw
 
sort mc_draw
merge mc_draw using endo_KPresult_Large_Groups
tab _merge
drop _merge
append using exo_KPresult_Large_Groups
drop if mc_draw==. & bench_RD==.
replace mc_draw=-1000 if mc_draw==.
sort mc_draw
replace mc_draw=. if mc_draw==-1000
gen policy="EXO netw." if mc_draw==.
replace policy="ENDO netw." if mc_draw!=.
label var new_enmities "avg rewiring: New enmities (pct)" 
label var new_alliances "avg rewiring: New alliances (pct)"
save endo_KPresult__Large_Groups, replace


replace mc_draw=-1000 if mc_draw==.
sort mc_draw
merge mc_draw using interior_condition_foreign.dta
tab _merge
drop _merge
rename cond condition_violation
label var condition_violation "Is interior condition violated? 0/1 "
replace mc_draw=. if mc_draw==-1000
save endo_KPresult_Large_Groups, replace




***
*** ITURI-related groups
***


import excel using ..\original_data\coding_characteristics_FZ.xls, clear first
keep Group ITURI
rename Group name 
destring ITURI, gen(Ituri)
sort name 
save temp_fz, replace
qui use avgbench_data, clear
sort name
merge name using temp_fz
tab _merge
drop if _merge==2
count
drop _merge
erase temp_fz.dta


qui sort MCref
qui drop if Ituri ==1
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


*
* w/o recomposition of the network
*

qui do ..\progs\eq_simul.do
qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
label var Delta_RD  "count. change in aggregate fight."
save exo_KPresult_Ituri, replace

*
* with endogenous recomposition of the network
*

qui do ..\progs\compute_network_related_covariates.do
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

use temp_baseline, clear
$baseline_logit
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
rename link base_link
order MCref MCref_d alternative base* counter* 
keep MCref MCref_d alternative counter_Xbeta counter_proba counter_inclusive base_link base_proba base_Xbeta base_inclusive 
sort MCref MCref_d alternative 
save counter_proba.dta, replace
  
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
save endo_network_rewiring.dta, replace

keep if predicted_link==1
rename alternative a
keep MCref MCref_d mcdraw a
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace
use MC_counter_network, clear
rename MCref stor
rename MCref_d MCref
rename stor MCref_d
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

bysort mcdraw MCref: keep if [_n]==1 
replace MCref_d=MCref
replace a=0
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

gen cond= beta * (a==1) - gama * (a==-1) 
collapse (sum) cond , by (mcdraw MCref) 
replace cond = (1+cond<0)
collapse (sum) cond, by(mcdraw)
rename mcdraw mc_draw
sort mc_draw
save interior_condition_foreign.dta, replace


clear
set obs 1
gen mc_draw=.
save endo_KPresult_Ituri, replace

foreach d of numlist  1(1) 1000 {
if `d'<MC_draws+1{
di `d'
use MC_counter_network, clear
keep if mcdraw==`d'
gen aminus= (a==-1)
keep MCref MCref_d aminus 
sort MCref MCref_d
save temp_aminus, replace

use MC_counter_network, clear
keep if mcdraw==`d'
gen aplus= (a==1)
keep MCref MCref_d aplus
sort MCref MCref_d
save temp_aplus, replace


qui do ..\progs\eq_simul.do

qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_endo_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_endo_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
save Foreign_endo_KPresult, replace
label var Delta_RD  "count. change in aggregate fight."
gen mc_draw=`d'
append using endo_KPresult_Ituri
save endo_KPresult_Ituri, replace

}
}



use endo_KPresult_Ituri, clear
sort mc_draw
save endo_KPresult_Ituri, replace

use endo_network_rewiring, clear
keep MCref MCref_d alternative base_link predicted_link mcdraw
gen base_aminus=1 if base_link==1 & alternative==-1
gen endo_aminus=1 if predicted_link==1 & alternative==-1
gen base_aplus=1 if base_link==1 & alternative==1
gen endo_aplus=1 if predicted_link==1 & alternative==1
collapse (sum) base_link predicted_link base_aminus endo_aminus base_aplus endo_aplus, by(mcdraw)
gen new_enmities=(endo_aminus - base_aminus) 
gen new_alliances=(endo_aplus - base_aplus) 
keep mcdraw new_enmities new_alliances
rename mcdraw mc_draw
 
sort mc_draw
merge mc_draw using endo_KPresult_Ituri
tab _merge
drop _merge
append using exo_KPresult_Ituri
drop if mc_draw==. & bench_RD==.
replace mc_draw=-1000 if mc_draw==.
sort mc_draw
replace mc_draw=. if mc_draw==-1000
gen policy="EXO netw." if mc_draw==.
replace policy="ENDO netw." if mc_draw!=.
label var new_enmities "avg rewiring: New enmities (pct)" 
label var new_alliances "avg rewiring: New alliances (pct)"
save endo_KPresult_Ituri, replace


replace mc_draw=-1000 if mc_draw==.
sort mc_draw
merge mc_draw using interior_condition_foreign.dta
tab _merge
drop _merge
rename cond condition_violation
label var condition_violation "Is interior condition violated? 0/1 "
replace mc_draw=. if mc_draw==-1000
save endo_KPresult_Ituri, replace

***
*** RCD&UG&RWA groups
***

import excel using ..\original_data\coding_characteristics_FZ.xls, clear first
keep Group RCDUGRWA
rename Group name 
destring RCDUGRWA, gen(remove)
sort name 
save temp_fz, replace
qui use avgbench_data, clear
sort name
merge name using temp_fz
tab _merge
drop if _merge==2
count
drop _merge
erase temp_fz.dta

qui sort MCref
qui drop if remove ==1
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


*
* w/o recomposition of the network
*

qui do ..\progs\eq_simul.do
qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
label var Delta_RD  "count. change in aggregate fight."
save exo_KPresult_RCD_UG_RWA, replace

*
* with endogenous recomposition of the network
*

qui do ..\progs\compute_network_related_covariates.do
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

use temp_baseline, clear
$baseline_logit
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
rename link base_link
order MCref MCref_d alternative base* counter* 
keep MCref MCref_d alternative counter_Xbeta counter_proba counter_inclusive base_link base_proba base_Xbeta base_inclusive 
sort MCref MCref_d alternative 
save counter_proba.dta, replace
  
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
save endo_network_rewiring.dta, replace

keep if predicted_link==1
rename alternative a
keep MCref MCref_d mcdraw a
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace
use MC_counter_network, clear
rename MCref stor
rename MCref_d MCref
rename stor MCref_d
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

bysort mcdraw MCref: keep if [_n]==1 
replace MCref_d=MCref
replace a=0
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

gen cond= beta * (a==1) - gama * (a==-1) 
collapse (sum) cond , by (mcdraw MCref) 
replace cond = (1+cond<0)
collapse (sum) cond, by(mcdraw)
rename mcdraw mc_draw
sort mc_draw
save interior_condition_foreign.dta, replace

clear
set obs 1
gen mc_draw=.
save endo_KPresult_RCD_UG_RWA, replace

foreach d of numlist  1(1) 1000 {
if `d'<MC_draws+1{
di `d'
use MC_counter_network, clear
keep if mcdraw==`d'
gen aminus= (a==-1)
keep MCref MCref_d aminus 
sort MCref MCref_d
save temp_aminus, replace

use MC_counter_network, clear
keep if mcdraw==`d'
gen aplus= (a==1)
keep MCref MCref_d aplus
sort MCref MCref_d
save temp_aplus, replace


qui do ..\progs\eq_simul.do

qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_endo_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_endo_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
save Foreign_endo_KPresult, replace
label var Delta_RD  "count. change in aggregate fight."
gen mc_draw=`d'
append using endo_KPresult_RCD_UG_RWA
save endo_KPresult_RCD_UG_RWA, replace

}
}



use endo_KPresult_RCD_UG_RWA, clear
sort mc_draw
save endo_KPresult_RCD_UG_RWA, replace

use endo_network_rewiring, clear
keep MCref MCref_d alternative base_link predicted_link mcdraw
gen base_aminus=1 if base_link==1 & alternative==-1
gen endo_aminus=1 if predicted_link==1 & alternative==-1
gen base_aplus=1 if base_link==1 & alternative==1
gen endo_aplus=1 if predicted_link==1 & alternative==1
collapse (sum) base_link predicted_link base_aminus endo_aminus base_aplus endo_aplus, by(mcdraw)
gen new_enmities=(endo_aminus - base_aminus) 
gen new_alliances=(endo_aplus - base_aplus) 
keep mcdraw new_enmities new_alliances
rename mcdraw mc_draw
 
sort mc_draw
merge mc_draw using endo_KPresult_RCD_UG_RWA
tab _merge
drop _merge
append using exo_KPresult_RCD_UG_RWA
drop if mc_draw==. & bench_RD==.
replace mc_draw=-1000 if mc_draw==.
sort mc_draw
replace mc_draw=. if mc_draw==-1000
gen policy="EXO netw." if mc_draw==.
replace policy="ENDO netw." if mc_draw!=.
label var new_enmities "avg rewiring: New enmities (pct)" 
label var new_alliances "avg rewiring: New alliances (pct)"
save endo_KPresult_RCD_UG_RWA, replace


replace mc_draw=-1000 if mc_draw==.
sort mc_draw
merge mc_draw using interior_condition_foreign.dta
tab _merge
drop _merge
rename cond condition_violation
label var condition_violation "Is interior condition violated? 0/1 "
replace mc_draw=. if mc_draw==-1000
save endo_KPresult_RCD_UG_RWA, replace

***
*** FDLR&INTER&HUTU groups
***

import excel using ..\original_data\coding_characteristics_FZ.xls, clear first
keep Group FDLRINTERHUTU
rename Group name 
rename FDLRINTERHUTU remove 
sort name 
save temp_fz, replace
qui use avgbench_data, clear
sort name
merge name using temp_fz
tab _merge
drop if _merge==2
count
drop _merge
erase temp_fz.dta


qui sort MCref
qui drop if remove ==1
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


*
* w/o recomposition of the network
*

qui do ..\progs\eq_simul.do
qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
label var Delta_RD  "count. change in aggregate fight."
save exo_KPresult_FDLR_INTER_HUTU, replace

*
* with endogenous recomposition of the network
*

qui do ..\progs\compute_network_related_covariates.do
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

use temp_baseline, clear
$baseline_logit
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
rename link base_link
order MCref MCref_d alternative base* counter* 
keep MCref MCref_d alternative counter_Xbeta counter_proba counter_inclusive base_link base_proba base_Xbeta base_inclusive 
sort MCref MCref_d alternative 
save counter_proba.dta, replace
  
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
save endo_network_rewiring.dta, replace

keep if predicted_link==1
rename alternative a
keep MCref MCref_d mcdraw a
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace
use MC_counter_network, clear
rename MCref stor
rename MCref_d MCref
rename stor MCref_d
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

bysort mcdraw MCref: keep if [_n]==1 
replace MCref_d=MCref
replace a=0
append using MC_counter_network
sort mcdraw MCref MCref_d
save MC_counter_network.dta, replace

gen cond= beta * (a==1) - gama * (a==-1) 
collapse (sum) cond , by (mcdraw MCref) 
replace cond = (1+cond<0)
collapse (sum) cond, by(mcdraw)
rename mcdraw mc_draw
sort mc_draw
save interior_condition_foreign.dta, replace

clear
set obs 1
gen mc_draw=.
save endo_KPresult_FDLR_INTER_HUTU, replace

foreach d of numlist  1(1) 1000 {
if `d'<MC_draws+1{
di `d'
use MC_counter_network, clear
keep if mcdraw==`d'
gen aminus= (a==-1)
keep MCref MCref_d aminus 
sort MCref MCref_d
save temp_aminus, replace

use MC_counter_network, clear
keep if mcdraw==`d'
gen aplus= (a==1)
keep MCref MCref_d aplus
sort MCref MCref_d
save temp_aplus, replace


qui do ..\progs\eq_simul.do

qui use simul, clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
save Foreign_endo_KPresult, replace

use avgbench_data, clear
collapse (sum) TotFight
rename TotFight bench_RD
merge using Foreign_endo_KPresult
drop _merge
gen Delta_RD=((counter_RD /bench_RD)-1)
save Foreign_endo_KPresult, replace
label var Delta_RD  "count. change in aggregate fight."
gen mc_draw=`d'
append using endo_KPresult_FDLR_INTER_HUTU
save endo_KPresult_FDLR_INTER_HUTU, replace


}
}



use endo_KPresult_FDLR_INTER_HUTU, clear
sort mc_draw
save endo_KPresult_FDLR_INTER_HUTU, replace

use endo_network_rewiring, clear
keep MCref MCref_d alternative base_link predicted_link mcdraw
gen base_aminus=1 if base_link==1 & alternative==-1
gen endo_aminus=1 if predicted_link==1 & alternative==-1
gen base_aplus=1 if base_link==1 & alternative==1
gen endo_aplus=1 if predicted_link==1 & alternative==1
collapse (sum) base_link predicted_link base_aminus endo_aminus base_aplus endo_aplus, by(mcdraw)
gen new_enmities=(endo_aminus - base_aminus) 
gen new_alliances=(endo_aplus - base_aplus) 
keep mcdraw new_enmities new_alliances
rename mcdraw mc_draw
 
sort mc_draw
merge mc_draw using endo_KPresult_FDLR_INTER_HUTU
tab _merge
drop _merge
append using exo_KPresult_FDLR_INTER_HUTU
drop if mc_draw==. & bench_RD==.
replace mc_draw=-1000 if mc_draw==.
sort mc_draw
replace mc_draw=. if mc_draw==-1000
gen policy="EXO netw." if mc_draw==.
replace policy="ENDO netw." if mc_draw!=.
label var new_enmities "avg rewiring: New enmities (pct)" 
label var new_alliances "avg rewiring: New alliances (pct)"
save endo_KPresult_FDLR_INTER_HUTU, replace


replace mc_draw=-1000 if mc_draw==.
sort mc_draw
merge mc_draw using interior_condition_foreign.dta
tab _merge
drop _merge
rename cond condition_violation
label var condition_violation "Is interior condition violated? 0/1 "
replace mc_draw=. if mc_draw==-1000
save endo_KPresult_FDLR_INTER_HUTU, replace



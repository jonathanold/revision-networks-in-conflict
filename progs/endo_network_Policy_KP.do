
******************************************************
* Key Player Simulation with endogenous rewiring of the network
******************************************************
* Patch for removing the two Rwandas Simultaneously
scalar RWApre=100000
scalar RWApost=100000
qui use avgbench_data, clear
sort MCref
sum MCref if name=="Military Forces of Rwanda (1994-1999)"
scalar RWApre=r(max)
sum MCref if name=="Military Forces of Rwanda (2000-)"
scalar RWApost=r(max)


* Simulate each counterfactual equilibrium
foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
di `kp'
qui use avgbench_data, clear
qui sort MCref
qui drop if MCref==`kp'
qui drop if MCref==RWApost & `kp'==RWApre
qui drop if MCref==RWApre & `kp'==RWApost
qui sort MCref year
qui save temp_MC, replace
qui use bench_aminus, clear
qui drop if MCref==`kp'
qui drop if MCref==RWApost & `kp'==RWApre
qui drop if MCref==RWApre & `kp'==RWApost
qui drop if MCref_d==`kp'
qui drop if MCref_d==RWApost & `kp'==RWApre
qui drop if MCref_d==RWApre & `kp'==RWApost
qui sort MCref MCref_d 
qui save temp_aminus, replace
qui use bench_aplus, clear
qui drop if MCref==`kp'
qui drop if MCref==RWApost & `kp'==RWApre
qui drop if MCref==RWApre & `kp'==RWApost
qui drop if MCref_d==`kp'
qui drop if MCref_d==RWApost & `kp'==RWApre
qui drop if MCref_d==RWApre & `kp'==RWApost
qui sort MCref MCref_d
qui save temp_aplus, replace

* Generate counterfactual covariates
qui do ../progs/compute_network_related_covariates.do
qui expand 3
qui bysort MCref MCref_d: gen alternative=[_n]-2 
qui keep MCref MCref_d alternative $network_cov
foreach var in $network_cov {
qui gen counter_`var'=`var'
qui drop  `var'
}
qui drop if MCref<MCref_d
qui sort MCref MCref_d alternative
qui egen dyad=group(MCref MCref_d)
qui drop if MCref==MCref_d

qui sort MCref MCref_d alternative
qui save temp_counter.dta, replace

* counterfactual observed utilities and probabilities 
* redo the logit estimation to be sure that the predicted values are stored  
qui use temp_baseline, clear
qui $baseline_logit
* retrieve the counterfactual covariates and merge them with other covariates
qui sort MCref MCref_d alternative
qui merge MCref MCref_d alternative using temp_counter
qui tab _merge
qui keep if _merge==3
qui gen counter_csf_surplus=csf_surplus
qui drop _merge
foreach var in csf_surplus $network_cov {
qui rename `var' baseline_`var'
qui gen `var'= counter_`var'

}
qui predict counter_proba
qui predict counter_Xbeta, xb
qui gen exp_counter_Xbeta=exp(counter_Xbeta)
qui cap drop test counter_inclusive
qui bysort MCref MCref_d: egen counter_inclusive=sum(exp_counter_Xbeta)
qui rename link base_link
qui order MCref MCref_d alternative base* counter* 
qui keep MCref MCref_d alternative counter_Xbeta counter_proba counter_inclusive base_link base_proba base_Xbeta base_inclusive 
qui sort MCref MCref_d alternative 
qui save counter_proba.dta, replace
  
* Generate MC links and network
qui use MC_draws, clear
qui sort MCref MCref_d alternative 
qui merge MCref MCref_d alternative using counter_proba
qui tab _merge
qui keep if _merge==3
qui drop _merge
qui gen counter_utility=counter_Xbeta+epsilon
qui sort mcdraw MCref MCref_d alternative
qui bysort mcdraw MCref MCref_d: egen maxU=max(counter_utility)
qui gen predicted_link= (counter_utility==maxU)
* we store those values for building future statistics on rewiring (see below)
qui save endo_network_rewiring_`kp'.dta, replace

* we now build the counterfactual rewired networks
qui keep if predicted_link==1
qui rename alternative a
qui keep MCref MCref_d mcdraw a
qui sort mcdraw MCref MCref_d
qui save MC_counter_network.dta, replace
* finally we need to "square" the matrix with mirrors and and then fill the diagonal
qui use MC_counter_network, clear
qui rename MCref stor
qui rename MCref_d MCref
qui rename stor MCref_d
qui append using MC_counter_network
qui sort mcdraw MCref MCref_d
qui save MC_counter_network.dta, replace

qui bysort mcdraw MCref: keep if [_n]==1 
qui replace MCref_d=MCref
qui replace a=0
qui append using MC_counter_network
qui sort mcdraw MCref MCref_d
qui save MC_counter_network.dta, replace

* MC draws
qui clear
qui set obs 1
qui gen mc_draw=.
qui save endo_KPcounter_simul_`kp', replace

foreach d of numlist  1(1) 1000 {
qui if `d'<MC_draws+1{
qui use MC_counter_network, clear
qui keep if mcdraw==`d'
qui gen aminus= (a==-1)
qui keep MCref MCref_d aminus 
qui sort MCref MCref_d
qui save temp_aminus, replace

qui use MC_counter_network, clear
qui keep if mcdraw==`d'
qui gen aplus= (a==1)
qui keep MCref MCref_d aplus
qui sort MCref MCref_d
qui save temp_aplus, replace

qui do ../progs/eq_simul.do
qui use simul, clear
qui gen mc_draw=`d'
qui append using endo_KPcounter_simul_`kp'
qui save endo_KPcounter_simul_`kp', replace
}
}


}
}


**
** Store equilibrium values for all groups, for all MC draws, for all KP scenarios

qui clear
qui set obs 1
qui gen KP_removal_id=.
qui save endo_KP_all_equilibria, replace

foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
qui use endo_KPcounter_simul_`kp', clear
qui drop if mc_draw==.
qui gen KP_removal_id=`kp'
qui append using endo_KP_all_equilibria 
qui save endo_KP_all_equilibria, replace
}
}



foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
qui use endo_network_rewiring_`kp'.dta, clear
qui keep if predicted_link==1
qui rename alternative a
qui keep MCref MCref_d mcdraw a
qui sort mcdraw MCref MCref_d
qui save MC_counter_network.dta, replace
qui use MC_counter_network, clear
qui rename MCref stor
qui rename MCref_d MCref
qui rename stor MCref_d
qui append using MC_counter_network
qui sort mcdraw MCref MCref_d
qui save MC_counter_network.dta, replace
qui bysort mcdraw MCref: keep if [_n]==1 
qui replace MCref_d=MCref
qui replace a=0
qui append using MC_counter_network
qui sort mcdraw MCref MCref_d
qui save MC_counter_network.dta, replace
qui gen cond= beta * (a==1) - gama * (a==-1) 
qui collapse (sum) cond , by (mcdraw MCref) 
qui replace cond = (1+cond<0)
qui collapse (sum) cond, by(mcdraw)
qui rename mcdraw mc_draw
qui sort mc_draw
qui save interior_condition_`kp'.dta, replace

}
}


**** 
* Keep all Equilibria
**** 
* Display the KP results
qui clear
qui set obs 1
qui gen KP_removal_id=.
qui save endo_KPresult, replace


foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
qui use endo_KPcounter_simul_`kp', clear
qui drop if mc_draw==.
sort mc_draw
merge mc_draw using interior_condition_`kp'
drop _merge
gen interior=1-cond
qui gen KP_removal_id=`kp'
qui append using endo_KPresult 
qui save endo_KPresult, replace
}
}
collapse (sum) EFFORT (mean) interior, by(KP_removal_id mc_draw)
qui sum EFFORT, d
gen trim=.
gen trimQ=.
foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
di `kp'
sum EFFORT if KP_removal_id==`kp', d
scalar bplus= r(mean)+ r(sd)
scalar bminus= r(mean)- r(sd)
replace trim=(bminus<EFFORT)&(EFFORT < bplus) if  KP_removal_id==`kp'
}
}
sort KP_removal_id  EFFORT
by KP_removal_id : gen obs=[_n] 
gen trimMC= (obs< MC_draws * 0.05) | (obs>MC_draws*0.95)
replace trim =1-trim
gen EFFORT_trim=EFFORT 
gen EFFORT_trimMC=EFFORT
replace EFFORT_trim=. if trim==1
replace EFFORT_trimMC=. if trimMC==1

bysort KP_removal_id: egen MAD=mad(EFFORT)

collapse (median) medeff=EFFORT (mean) mad_effort=MAD avgeff=EFFORT avgeff_trim=EFFORT_trim avgeff_trimMC=EFFORT_trimMC (sum) interior (sd) sdeff=EFFORT sdeff_trim=EFFORT_trim sdeff_trimMC=EFFORT_trimMC , by(KP_removal_id)

qui rename avgeff counter_RD
qui rename sdeff sd_counter_RD
qui rename KP_removal_id MCref
qui gen bench_RD=bench_rd
qui save endo_KPresult, replace



qui clear
set obs 1
qui gen MCref=.
qui gen new_enmities =.
qui gen new_alliances=.
qui save endo_network_rewiring_stat_KP, replace

* retrieve basic statistics on rewiring from MC
foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
qui use endo_network_rewiring_`kp'.dta, clear
qui keep MCref MCref_d alternative base_link predicted_link mcdraw
qui gen base_aminus=1 if base_link==1 & alternative==-1
qui gen endo_aminus=1 if predicted_link==1 & alternative==-1
qui gen base_aplus=1 if base_link==1 & alternative==1
qui gen endo_aplus=1 if predicted_link==1 & alternative==1
qui collapse (sum) base_link predicted_link base_aminus endo_aminus base_aplus endo_aplus, by(mcdraw)
qui gen new_enmities= endo_aminus - base_aminus 
qui gen new_alliances= endo_aplus - base_aplus 
qui keep mcdraw new_enmities new_alliances
qui collapse (median) new_enmities new_alliances
qui gen MCref=`kp'
qui append using endo_network_rewiring_stat_KP
qui save endo_network_rewiring_stat_KP, replace
}
}



qui use endo_network_rewiring_stat_KP, clear
qui sort MCref
qui save endo_network_rewiring_stat_KP, replace


use avgbench_data, clear
keep Foreign Government_org group MCref name TotFight
sort MCref
save MC_merging_key.dta, replace

use endo_KPresult, clear
sort MCref
merge MCref using endo_network_rewiring_stat_KP
tab _merge
drop _merge
sort MCref
merge MCref using MC_merging_key
tab _merge
drop _merge
cap drop Delta_RD

gen Delta_RD=((counter_RD /bench_RD)-1)
gen sd_Delta_RD=((sd_counter_RD /bench_RD))

gen median_Delta_RD=((medeff /bench_RD)-1)
gen sd_median_Delta_RD=mad_effort/bench_RD

gen Delta_RD_trim=((avgeff_trim /bench_RD)-1)
gen sd_Delta_RD_trim=((sdeff_trim /bench_RD))

gen Delta_RD_trimMC=((avgeff_trimMC /bench_RD)-1)
gen sd_Delta_RD_trimMC=((sdeff_trimMC /bench_RD))

egen agg_fight=sum(TotFight)
compare agg_fight bench_RD
gen bench_fighting_share=TotFight/agg_fight
order name bench_fighting_share Delta_RD sd_Delta_RD 
drop if Government_org==1 & Foreign==0
drop if MCref==.
gsort Delta_RD
gen rank=[_n]
gsort median_Delta_RD
gen median_rank=[_n]
keep median_rank rank name bench_fighting_share median_Delta_RD sd_median_Delta_RD Delta_RD  sd_Delta_RD Delta_RD_trim sd_Delta_RD_trim Delta_RD_trimMC sd_Delta_RD_trimMC new_enmities new_alliances interior
save endo_KeyPlayer_result, replace

*** Merge with the results of the static KP analysis

** Patch for removing the two Rwandas Simultaneously
use endo_KeyPlayer_result, clear
replace name = "Military Forces of Rwanda" if name == "Military Forces of Rwanda (1994-1999)"
drop if name=="Military Forces of Rwanda (2000-)"
cap drop rank
gsort Delta_RD
gen rank=[_n]
cap drop median_rank
gsort median_Delta_RD
gen median_rank=[_n]
save endo_KeyPlayer_result, replace

use endo_KeyPlayer_result, clear 
keep median_rank name median_Delta_RD sd_median_Delta_RD Delta_RD  sd_Delta_RD Delta_RD_trim sd_Delta_RD_trim Delta_RD_trimMC sd_Delta_RD_trimMC  rank new_enmities new_alliances interior
rename Delta_RD endo_Delta_RD
rename sd_Delta_RD sd_endo_Delta_RD
rename rank endo_rank
label var endo_Delta_RD  "endo. count. change in aggregate fight. (avg)"
label var sd_endo_Delta_RD  "endo. count. change in aggregate fight. (sd)"
label var endo_rank  "endo. KP rank"
label var new_enmities "rewiring: New enmities (median)" 
label var new_alliances "rewiring: New alliances (median)"
label var interior "# MC draws with interior equilibrium"
sort name 
save endo_KeyPlayer_result, replace


use KeyPlayer_result, clear
sort name
merge name using endo_KeyPlayer_result
tab _merge
drop _merge
sort endo_rank
corr rank endo_rank
save endo_KeyPlayer_result, replace



drop  endo_Delta_RD sd_endo_Delta_RD  Delta_RD_trim sd_Delta_RD_trim Delta_RD_trimMC sd_Delta_RD_trimMC  endo_rank
sort median_rank
rename median_Delta_RD endo_Delta_RD 
rename sd_median_Delta_RD sd_endo_Delta_RD
rename  median_rank endo_rank
save endo_KeyPlayer_result, replace


** Build new_alliances and new_enmities at the median

use endo_KP_all_equilibria, clear
drop if mc_draw==.
collapse (sum) EFFORT, by(KP_removal_id mc_draw)
sort KP_removal_id EFFORT
by KP_removal_id: gen rank_eff=[_n]
keep if rank_eff == round(MC_draws/2)
keep KP_removal_id mc_draw
rename KP_removal_id MCref
rename mc_draw mcdraw
sort MCref mcdraw
save temp_patch, replace
 
qui clear
set obs 1
qui gen MCref=.
qui gen new_enmities =.
qui gen new_alliances=.
qui save endo_network_rewiring_stat_KP_auxi, replace
foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
qui use endo_network_rewiring_`kp'.dta, clear
qui keep MCref MCref_d alternative base_link predicted_link mcdraw
qui gen base_aminus=1 if base_link==1 & alternative==-1
qui gen endo_aminus=1 if predicted_link==1 & alternative==-1
qui gen base_aplus=1 if base_link==1 & alternative==1
qui gen endo_aplus=1 if predicted_link==1 & alternative==1
qui collapse (sum) base_link predicted_link base_aminus endo_aminus base_aplus endo_aplus, by(mcdraw)
qui gen new_enmities= endo_aminus - base_aminus 
qui gen new_alliances= endo_aplus - base_aplus 
qui keep mcdraw new_enmities new_alliances
qui gen MCref=`kp'
qui append using endo_network_rewiring_stat_KP_auxi
qui save endo_network_rewiring_stat_KP_auxi, replace
}
}


use MC_merging_key, clear
sort MCref
save MC_merging_key, replace

use endo_network_rewiring_stat_KP_auxi, clear
sort MCref mcdraw
merge MCref mcdraw using temp_patch
tab _merge
keep if _merge==3
drop _merge
keep MCref new_enmities new_alliances
sort MCref
merge MCref using MC_merging_key.dta
keep name new_enmities new_alliances
rename new_enmities new_enmities_at_median
rename new_alliances new_alliances_at_median
label var new_enmities_at_median "New Enmities at median"
label var new_alliances_at_median "New Alliances at median"
replace name = "Military Forces of Rwanda" if name == "Military Forces of Rwanda (1994-1999)"
sort name
save temp_patch, replace

use endo_KeyPlayer_result, replace
sort name
merge name using temp_patch
tab _merge
drop if _merge==2
drop _merge
sort endo_rank
save endo_KeyPlayer_result, replace

cap erase temp_patch.dta
cap erase endo_network_rewiring_stat_KP_auxi.dta
foreach kp of numlist 1(1)150 {
qui capture erase endo_network_rewiring_`kp'.dta
qui capture erase endo_KPcounter_simul_`kp'.dta
qui capture erase interior_condition_`kp'.dta
}


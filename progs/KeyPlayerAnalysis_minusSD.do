
* build adjency matrices
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


******************************************************
* Step 1 - Build the (Benchmark) Observed Sample
******************************************************

use KRTZ_monadic_ref.dta, clear
save temp_counterfactual, replace

*** Check that we replicate our baseline spec w/o clustering in xtivreg format
use temp_counterfactual, clear

$baseline_specification


sum group
scalar nb_group=r(max)

predict RESID, e
predict FE, u
gen stor1=TotFight_Enemy
gen stor2=TotFight_Allied
replace TotFight_Enemy=0
replace TotFight_Allied=0
predict shifter, xb
replace TotFight_Enemy = stor1
replace TotFight_Allied = stor2
gen check= TotFight -( _b[ TotFight_Allied] * TotFight_Allied +  _b[ TotFight_Enemy] * TotFight_Enemy + shifter + FE + RESID)
sum check, d
drop check
** Select the coefficients here : those options are set in the mother program KRTZ_Master_program
$gamaselect
$betaselect
gen scale_correction=1
gen SHIFTER= - shifter * scale_correction
replace FE=FE * scale_correction
replace RESID=RESID * scale_correction
gen hostility=1/(1+beta * degree_plus - gamma * degree_minus) 
tab hostility
tab name if hostility<0
bysort year: egen agg_hostility=sum(hostility)
gen PHI=1-[1/(agg_hostility)]
gen U= PHI * (1- PHI) * hostility
* combine observed/unobserved in one variable
gen TOTAL_SHIFTER=SHIFTER+U-FE-RESID
* separate observed/unobserved variables
rename SHIFTER OBS_SHIFTER
gen EPSILON=-RESID
sum EPSILON, d
gen SD_EPSILON=r(sd)
gen E=U-FE
gen interior=(TotFight>0)
gen Restr_Host = U 
gen Extd_Host = - OBS_SHIFTER + U - E -EPSILON
sum Restr_Host Extd_Host , d
keep Foreign Government_org degree_plus degree_minus Restr_Host Extd_Host hostility interior beta gamma TotFight TotFight_Enemy TotFight_Allied EPSILON  SD_EPSILON E OBS_SHIFTER U TOTAL_SHIFTER hostility degree_plus degree_minus year group name 
order year beta gamma name hostility group degree_plus degree_minus hostility TotFight TotFight_Enemy TotFight_Allied  TOTAL_SHIFTER OBS_SHIFTER U E EPSILON SD_EPSILON Restr_Host Extd_Host interior 
save bench_data, replace
* a test 
reg TotFight TotFight_Enemy TotFight_Allied OBS_SHIFTER U E EPSILON, noc
keep if e(sample)==1
gen RHS= - OBS_SHIFTER + U - E - EPSILON
reg TotFight TotFight_Enemy TotFight_Allied RHS, noc
keep Foreign Government_org  degree_plus degree_minus year beta gamma group name TotFight TotFight_Enemy TotFight_Allied  OBS_SHIFTER  U E EPSILON RHS
sort year group
by year : gen MCref=[_n]
duplicates report group MCref
label var MCref "group id in the Monte Carlo simulation"
sort year MCref
save bench_data, replace
keep if year==2005
keep group MCref
sort group
save MC_merging_key.dta, replace

** build bench networks data
use aminus_ref, clear
sort group
by group: keep if [_n]==1
replace group_d=group
replace aminus=0
tab aminus
sort group group_d
save temp_square, replace
use aminus_ref, clear
append using temp_square
sort group group_d
save bench_aminus, replace
use aplus_ref, clear
sort group
by group: keep if [_n]==1
replace group_d=group
replace aplus=0
tab aplus
sort group group_d
save temp_square, replace
use aplus_ref, clear
append using temp_square
sort group group_d
save bench_aplus, replace
erase temp_square.dta

use MC_merging_key.dta, clear
rename MCref MCref_d
rename group group_d
sort group_d
save temp, replace

use bench_aminus, clear
sort group
merge group using MC_merging_key
tab _merge
drop _merge
sort group_d
merge group_d using temp
tab _merge
drop _merge
drop group group_d
sort MCref MCref_d
save bench_aminus, replace
use bench_aplus, clear
sort group
merge group using MC_merging_key
tab _merge
drop _merge
sort group_d
merge group_d using temp
tab _merge
drop _merge
drop group group_d
sort MCref MCref_d
save bench_aplus, replace


* Generate observed share in total fighting
use bench_data, clear
collapse (sum) TotFight, by(group)
egen AggFight= sum(TotFight)
gen observed_share=TotFight / AggFight
keep group observed_share
sort group
save obs_share.dta, replace

******************************************************
* step 2 - simulation of the benchmark equilibrium 
******************************************************
* we use our subprogram that simulates the equilibrium
use bench_data, clear
save temp_MC, replace
use bench_aminus, clear
save temp_aminus, replace
use bench_aplus, clear
save temp_aplus, replace
global time "1998(1)2010"
qui do ../progs/eq_simul.do
use simul, clear
save bench_simul, replace

* Crucial test : Do we retrieve our data from the simulation based on benchmark values? 
use bench_simul
keep MCref year EFFORT*
sort MCref year
save temp, replace
use bench_data, clear
sort MCref year
merge MCref year using temp
tab _merge 
drop _merge
gen test1=(EFFORT - TotFight)^2
gen test2=(EFFORT_Enemy - TotFight_Enemy)^2
gen test3=(EFFORT_Allied - TotFight_Allied)^2
sum test*, d
drop test*


*********
* TABLE 4
*********
* Benchmark = average data
use bench_data, clear
sort MCref group name year
collapse (mean) Foreign Government_org  degree_plus degree_minus beta gamma TotFight TotFight_Enemy TotFight_Allied OBS_SHIFTER E EPSILON year, by (MCref group name)
replace year=1000
global time "1000"
save avgbench_data, replace

* Simulate the benchmark equilibrium
use avgbench_data, clear
save temp_MC, replace
use bench_aminus, clear
save temp_aminus, replace
use bench_aplus, clear
save temp_aplus, replace
qui do ../progs/eq_simul.do
use simul, clear
save avgbench_simul, replace
collapse(sum) EFFORT
scalar bench_rd = EFFORT

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
qui qui do ../progs/eq_simul.do
qui use simul, clear
qui save KPcounter_simul_`kp', replace
}
}

* Display the KP results
clear
gen MCref=.
gen bench_RD=.
gen counter_RD=.
save KPresult, replace

foreach kp of numlist 1(1)150 {
if `kp'<nb_group + 1 {
qui use KPcounter_simul_`kp', clear
qui collapse (sum) EFFORT
qui rename EFFORT counter_RD
qui gen MCref=`kp'
qui gen bench_RD=bench_rd
qui append using KPresult 
qui save KPresult, replace
qui capture erase KPcounter_simul_`kp'.dta
}
}

use avgbench_data, clear
keep Foreign Government_org group MCref name TotFight degree_plus degree_minus
sort MCref
save MC_merging_key.dta, replace

use KPresult, clear
sort MCref
merge MCref using MC_merging_key
tab _merge
drop _merge
cap drop Delta_RD
gen Delta_RD=((counter_RD /bench_RD)-1)
egen agg_fight=sum(TotFight)
compare agg_fight bench_RD
gen bench_fighting_share=TotFight/agg_fight
order name degree_minus degree_plus bench_fighting_share Delta_RD 
drop if Government_org==1 & Foreign==0
gsort Delta_RD
gen rank=[_n]
gen multiplier= abs(Delta_RD / bench_fighting_share)
keep degree_plus degree_minus rank name bench_fighting_share Delta_RD multiplier
save KeyPlayerminusSD, replace

use KeyPlayerminusSD, clear
keep if name == "Military Forces of Rwanda (1994-1999)"|name=="Military Forces of Rwanda (2000-)"
collapse (sum) bench_fighting_share (mean) Delta_RD
gen multiplier= abs(Delta_RD / bench_fighting_share)
gen name = "Military Forces of Rwanda"
sort name
append using KeyPlayerminusSD
drop rank
drop if name == "Military Forces of Rwanda (1994-1999)"|name=="Military Forces of Rwanda (2000-)"
gsort Delta_RD
gen rank=[_n]
save KeyPlayerminusSD, replace

label var name "Group"
label var degree_plus "d+"
label var degree_minus "d-"
label var bench_fighting_share "obs. share in aggregate fight."
label var Delta_RD  "count. change in aggregate fight."
label var rank "KP rank"
label var multiplier"multiplier"
order rank name degree_minus degree_plus bench_fighting_share  Delta_RD 
keep name Delta_RD 
export excel using ../results/KeyPlayer_result_minusSD.xls, replace first(varl)


* cleaning
cap erase acled_KRTZ_identifiers.dta
cap erase KPresult.dta
cap erase Foreign_KPresult.dta
cap erase avgbench_data.dta
cap erase MC_merging_key.dta
cap erase bench_data.dta
cap erase bench_simul.dta
cap erase bench_aminus.dta
cap erase bench_aplus.dta
cap erase temp_counterfactual.dta
cap erase simul.dta
cap erase temp.dta
cap erase temp_aplus.dta
cap erase temp_aminus.dta
cap erase temp_MC.dta
cap erase avgbench_simul.dta
cap erase aminus_ref.dta
cap erase aplus_ref.dta

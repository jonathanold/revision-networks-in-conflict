************************************************************
* This program builds the network related covariates
* Required Inputs:  avgbench_data.dta, bench_aminus.dta, bench_aplus.dta   
* Subroutine ../progs/compute_network_related_covariates.do
* Output temp_cov.dta
************************************************************

* we extract some scalars
use temp_MC, clear
sum beta
scalar beta_hat=r(max)
sum gamma
scalar gamma_hat=r(max)
sum MCref

* we now create the matrix to be used for the multinomial logit
keep name group MCref year
save temp_cov.dta, replace
rename name name_d
rename group group_d
rename MCref MCref_d
drop year 
cross using temp_cov.dta
save temp_cov.dta, replace
expand 3
bysort MCref MCref_d: gen alternative=[_n]-2
order alternative MCref MCref_d group group_d name name_d 
sort MCref MCref_d alternative
save temp_cov.dta, replace

qui do ../progs/compute_network_related_covariates.do
merge MCref MCref_d using temp_cov.dta
tab _merge
drop _merge
sort MCref MCref_d alternative
save temp_cov.dta, replace

gen link=(a==alternative)
tab link
drop aplus aminus
sort MCref MCref_d alternative
save temp_cov.dta, replace

if a==1{
replace dplus=dplus-1 if alternative==-1|alternative==0
replace dplus_d=dplus_d-1 if alternative==-1|alternative==0
replace dminus=dminus+1 if alternative==-1
replace dminus_d=dminus_d+1 if alternative==-1
}
if a==0{
replace dplus=dplus+1 if alternative==+1
replace dplus_d=dplus_d+1 if alternative==+1
replace dminus=dminus+1 if alternative==-1
replace dminus_d=dminus_d+1 if alternative==-1
}
if a==-1{
replace dplus=dplus+1 if alternative==1
replace dplus_d=dplus_d+1 if alternative==1
replace dminus=dminus-1 if alternative==0|alternative==1
replace dminus_d=dminus_d-1 if alternative==0|alternative==1
}

order MCref MCref_d alternative a link
sort MCref MCref_d alternative

save temp_cov.dta, replace
 

* shape the data for asclogit (triangular)
use temp_cov.dta, clear
sum MCref
scalar nb_group=r(max)
drop if MCref<MCref_d
sort MCref MCref_d alternative
egen dyad=group(MCref MCref_d)
drop if MCref==MCref_d

gen dtotplus=dplus + dplus_d
gen dtotminus=dminus + dminus_d
save temp_cov, replace


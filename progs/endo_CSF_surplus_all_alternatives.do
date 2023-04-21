
************************************************************
* This program builds the CSF surplus for the three alternatives
* Required Inputs:  avgbench_data.dta, bench_aminus.dta, bench_aplus.dta   
* Subroutine ..\progs\eq_simul.do
* Output csf_surplus.dta
************************************************************

use avgbench_data, clear
save temp_MC, replace

* we extract some scalars
sum beta
scalar beta_hat=r(max)
sum gamma
scalar gamma_hat=r(max)
sum MCref
scalar nb_group=r(max)
di nb_group

* we now create the matrix to be used for the multinomial logit
keep name group MCref year
save temp_csf.dta, replace
rename name name_d
rename group group_d
rename MCref MCref_d
drop year 
cross using temp_csf.dta
save temp_csf.dta, replace
expand 3
bysort MCref MCref_d: gen alternative=[_n]-2
gen surplus=.
order alternative surplus MCref MCref_d group group_d name name_d 
save temp_csf.dta, replace

** we now loop on the alternatives for each possible dyads**
foreach g of numlist  1(1) 100 {
if `g'<nb_group+1{
di `g'
foreach g_d of numlist  1(1) 100 {
if `g_d'<nb_group+1 & `g'<`g_d'{
*di `g' `g_d'

* alternative -1 *
qui use bench_aplus, clear
qui replace aplus=0 if (MCref==`g' & MCref_d==`g_d')|(MCref==`g_d' & MCref_d==`g')
qui save temp_aplus, replace
qui gen bdplus=beta_hat * aplus
qui sort MCref MCref_d
qui collapse (sum) bdplus, by (MCref)
qui save temp_share.dta, replace
qui use bench_aminus, clear
qui replace aminus=1 if (MCref==`g' & MCref_d==`g_d')|(MCref==`g_d' & MCref_d==`g')
qui save temp_aminus, replace
qui gen gdminus=gamma_hat * aminus
qui sort MCref MCref_d
qui collapse (sum) gdminus, by (MCref)
qui merge MCref using temp_share
qui cap drop _merge
qui gen Gam=1/(1+bdplus-gdminus)
qui egen GGam=sum(Gam)
qui keep if MCref==`g' | MCref==`g_d' 
qui gen share=Gam/GGam
qui keep MCref share
qui sort MCref
qui save temp_share.dta, replace
qui global time "1000" 
qui do ..\progs\eq_simul.do
qui keep EFFORT year MCref
qui keep if MCref==`g' | MCref==`g_d' 
qui merge MCref using temp_share
qui gen surplus=share-EFFORT
qui collapse (sum) surplus
qui scalar joint=surplus
qui use temp_csf.dta, clear
qui replace surplus=joint if (MCref==`g' & MCref_d==`g_d') & (alternative==-1)
qui save temp_csf.dta, replace


* alternative 0 *
qui use bench_aplus, clear
qui replace aplus=0 if (MCref==`g' & MCref_d==`g_d')|(MCref==`g_d' & MCref_d==`g')
qui save temp_aplus, replace
qui gen bdplus=beta_hat * aplus
qui sort MCref MCref_d
qui collapse (sum) bdplus, by (MCref)
qui save temp_share.dta, replace
qui use bench_aminus, clear
qui replace aminus=0 if (MCref==`g' & MCref_d==`g_d')|(MCref==`g_d' & MCref_d==`g')
qui save temp_aminus, replace
qui gen gdminus=gamma_hat * aminus
qui sort MCref MCref_d
qui collapse (sum) gdminus, by (MCref)
qui merge MCref using temp_share
qui cap drop _merge
qui gen Gam=1/(1+bdplus-gdminus)
qui egen GGam=sum(Gam)
qui keep if MCref==`g' | MCref==`g_d' 
qui gen share=Gam/GGam
qui keep MCref share
qui sort MCref
qui save temp_share.dta, replace
qui global time "1000" 
qui do ..\progs\eq_simul.do
qui keep EFFORT year MCref
qui keep if MCref==`g' | MCref==`g_d' 
qui merge MCref using temp_share
qui gen surplus=share-EFFORT
qui collapse (sum) surplus
qui scalar joint=surplus
qui use temp_csf.dta, clear
qui replace surplus=joint if (MCref==`g' & MCref_d==`g_d') & (alternative==0)
qui save temp_csf.dta, replace


* alternative +1 *
qui use bench_aplus, clear
qui replace aplus=1 if (MCref==`g' & MCref_d==`g_d')|(MCref==`g_d' & MCref_d==`g')
qui save temp_aplus, replace
qui gen bdplus=beta_hat * aplus
qui sort MCref MCref_d
qui collapse (sum) bdplus, by (MCref)
qui save temp_share.dta, replace
qui use bench_aminus, clear
qui replace aminus=0 if (MCref==`g' & MCref_d==`g_d')|(MCref==`g_d' & MCref_d==`g')
qui save temp_aminus, replace
qui gen gdminus=gamma_hat * aminus
qui sort MCref MCref_d
qui collapse (sum) gdminus, by (MCref)
qui merge MCref using temp_share
qui cap drop _merge
qui gen Gam=1/(1+bdplus-gdminus)
qui egen GGam=sum(Gam)
qui keep if MCref==`g' | MCref==`g_d' 
qui gen share=Gam/GGam
qui keep MCref share
qui sort MCref
qui save temp_share.dta, replace
qui global time "1000" 
qui do ..\progs\eq_simul.do
qui keep EFFORT year MCref
qui keep if MCref==`g' | MCref==`g_d' 
qui merge MCref using temp_share
qui gen surplus=share-EFFORT
qui collapse (sum) surplus
qui scalar joint=surplus
qui use temp_csf.dta, clear
qui replace surplus=joint if (MCref==`g' & MCref_d==`g_d') & (alternative==+1)
qui save temp_csf.dta, replace



}
}
}
}


* We now fill the missing values by using "mirror" dyads (from triangular to square matrix) 
use temp_csf, clear
sort MCref MCref_d alternative
save temp_csf, replace
rename MCref trash
rename MCref_d MCref
rename trash MCref_d
rename surplus surplus_d
keep MCref MCref_d surplus_d alternative
sort MCref MCref_d alternative
merge MCref MCref_d alternative using temp_csf
tab _merge
drop _merge
gen csf_surplus= surplus
replace csf_surplus= surplus_d if surplus==.
drop surplus surplus_d
order MCref MCref_d alternative csf_surplus
sort MCref MCref_d alternative
save csf_surplus.dta, replace



************************************************************
* Subroutine that computes Covariates
* input: temp_aplus.dta and temp_aminus.dta
************************************************************

* output data
use temp_aplus, clear
merge MCref MCref_d using temp_aminus
tab _merge
drop _merge
gen a= aplus-aminus
order MCref MCref_d 
sort MCref MCref_d
save temp_ncovariates.dta, replace
sort MCref_d
tab MCref_d, gen(neighbor)
foreach g of var neighbor*{
replace `g'= `g' * a
}
collapse (sum)neighbor* , by (MCref)
sort MCref 
save neighbor, replace
use temp_ncovariates, clear
sort MCref
tab MCref, gen(d_neighbor)
foreach g of var d_neighbor*{
replace `g'= `g' * a
}
collapse (sum)d_neighbor* , by (MCref_d)
sort MCref_d
save d_neighbor, replace


* build covariates
use temp_ncovariates, clear
sort MCref
merge MCref using neighbor
tab _merge
drop _merge
sort MCref_d
merge MCref_d using d_neighbor
tab _merge
drop _merge
order MCref MCref_d 
sort MCref MCref_d
* build degrees
bysort MCref: egen dplus=sum(aplus) 
bysort MCref_d: egen dplus_d=sum(aplus) 
bysort MCref: egen dminus=sum(aminus)
bysort MCref_d: egen dminus_d=sum(aminus)
* build common neighbors
foreach g of numlist  1(1) 100 {
if `g'<nb_group+1{
cap gen joint`g'= (neighbor`g'!=0 & d_neighbor`g'!=0)
cap gen allied_joint`g'= (neighbor`g'==1 & d_neighbor`g'==1)
cap gen enemy_joint`g'= (neighbor`g'==-1 & d_neighbor`g'==-1)
cap gen all_en_joint`g'= (neighbor`g'==-1 & d_neighbor`g'==1|neighbor`g'==1 & d_neighbor`g'==-1)
}
}
egen common=rowtotal(joint*)
egen common_allied=rowtotal(allied_joint*)
egen common_enemy=rowtotal(enemy_joint*)
egen common_all_en=rowtotal(all_en_joint*)
drop joint* allied_joint* enemy_joint* all_en_joint* neighbor* d_neighbor*
sort MCref MCref_d
save temp_ncovariates.dta, replace

* build hereafter the total degree excluding the dyad link
gen total_dminus = dminus + dminus_d - 2 * (a==-1)
gen total_dplus = dplus + dplus_d - 2 * (a==1)
save temp_ncovariates.dta, replace

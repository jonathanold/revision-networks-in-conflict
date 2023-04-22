/*-----------------------------------------------------------------------------

PROGRAM TO ESTIMATE SPATIAL HAC ERRORS IN 2SLS REGRESSION MODEL

[BETA VERSION] This may contain errors. Please notify us any errors you find.

LAST UPDATE: 01/19/2017. We are currently implementing a more comprehensive version of this program (for handling large dataset and with more options).
Future upgrades will be posted on our websites.
 
 ------------------------------------------------------------------------------
 
lagcutoff(#): describes the number of temporal periods at which serial autocorrelation is assumed to vanish.

distcutoff(#): describes the distance cutoff in KILOMETERS at which spatial correlation is assumed to vanish.

LAGDISTcutoff(integer 0): describes the number of temporal periods at which spatial correlation is assumed to vanish.

JDO changed some code
-----------------------------------------------------------------------------*/


capt program drop my_spatial_2sls_jo
program my_spatial_2sls_jo, eclass
	version 12
	syntax varlist [if] [in] [, end(varlist) iv(varlist) latitude(varname) longitude(varname) id(varname) time(varname) LAGcutoff(integer 0) DISTcutoff(real 1) LAGDISTcutoff(integer 0) partial correction]
	local depvar: word 1 of `varlist'
	local regs: list varlist - depvar
	marksample touse
	tempname b V
	
tempfile temp_2sls_conley
tempfile key
tempfile key_d

preserve	
	
qui ivreg2 `depvar' (`end' = `iv') `regs'
qui keep if e(sample)==1
qui sort `id' `time'
qui save `temp_2sls_conley', replace


*** Generate adjacency matrix 
qui {
keep `id' `time'  `latitude' `longitude'

scalar define nsize = _N
gen numID=[_n]
save `key', replace


gen id_d= `id'
gen time_d= `time' 
gen numID_d= numID 
gen latitude_d= `latitude'
gen longitude_d= `longitude'
keep id_d time_d numID_d latitude_d longitude_d
save `key_d', replace

use `key', clear

cross using `key_d'
geodist `latitude' `longitude' latitude_d longitude_d , gen(distance) sphere // sphere
// stop
**** DEFINE CLUSTERING
** Panel clustering (time-series auto-correlation)
gen weight= max(0, 1 - (abs(`time' - time_d))/(`lagcutoff' +1)) if `id' == id_d

** Spatial clustering
replace weight= max(0,1-abs(distance / `distcutoff' )) * max(0, 1 - (abs(`time' - time_d))/(`lagdistcutoff' +1)) if (`id'!=id_d) & (distance<= `distcutoff')  & (`distcutoff'>0)


** Technical stuff: only zeros on the diagonal
replace weight=. if numID==numID_d 
**** END OF CLUSTERING

keep numID numID_d weight
replace weight=0 if weight==.
sort numID numID_d
}


* By defaut we apply no Few Cluster correction to VCV. Hence asymptotics. 
local Nclus= 10000

		if ("`correction'"=="correction"){
 gen nonzero=(weight>0)
 sum nonzero

		local Nclus= 1 / r(mean) 
}


capture mata mata drop adjacency



mata: st_view(W=.,.,.,.)
mata: adjacency = J(st_numscalar("nsize"),st_numscalar("nsize"), 0) 
mata for(i = 1; i <= rows(adjacency); i++) {
    for(j = 1; j<=cols(adjacency); j++) {
                   adjacency[i,j]=W[(i-1)* rows(adjacency)+j,3]
     }
 }
 

 
qui use `temp_2sls_conley', clear

		if ("`partial'"=="partial"){
		qui do  ../progs/nw2sls_partial
		nw2sls_partial `depvar'  `regs', end(`end') iv(`iv')  correc(`Nclus')
		di "Hansen J (p-value)=  " e(pValueHansen)
		di "Hansen J =  " e(Hansen)
		}
		if ("`partial'"==""){
		qui do  ../progs/nw2sls
		nw2sls `depvar'  `regs', end(`end') iv(`iv')
		}


if substr("`end'",1,1)==""{
}
else{
qui do ../progs/KP_stat
qui KP_stat `depvar'  `regs', end(`end') iv(`iv') correc(`Nclus')
di "Kleibergen Paap rk statistic =  " KPstat
ereturn scalar KPstat = KPstat
mata: st_matrix("adja", adjacency)

mata: st_matrix("cluster", cluster)

}





end

** This routine simulates an equilibrium for each year 1998-2010
* Inputs are:
* -  temp_MC.dta; temp_aminus.dta; temp_aplus.dta
* - The global $time that defines the time span (usually 1998(1)2010 or 1000) 
* Output is simuldata.dta

**
** step 1: Build Matrices from input datasets
**

* vectors of observed and unobserved shifters + other coefficients
use temp_MC, clear
scalar beta=beta
scalar gamma=gamma
sum year
keep if year==r(min)
count
scalar dim=r(N)
matrix ID=I(dim)
mkmat E, matrix(E)
 foreach num of numlist $time {
                use temp_MC, clear
				keep if year== `num'
				sort MCref
				mkmat OBS_SHIFTER, matrix(Z_`num')
				mkmat EPSILON, matrix(EPSILON_`num')
				}
* build adjency matrices and store them
use temp_aminus, clear
sort MCref MCref_d
reshape wide aminus, i(MCref) j(MCref_d)
drop MCref
mkmat aminus*, matrix(Aminus)
use temp_aplus, clear
sort MCref MCref_d
reshape wide aplus, i(MCref) j(MCref_d)
drop MCref
mkmat aplus*, matrix(Aplus)
* build vectors of bench lambda and hostility
use temp_aminus, clear
sort MCref
collapse (sum)aminus, by(MCref)
rename aminus dminus
sort MCref 
save temp, replace
use temp_aplus, clear
sort MCref
collapse (sum)aplus, by(MCref)
rename aplus dplus
sort MCref 
merge MCref using temp
tab _merge
drop _merge
gen hostility=1/(1+ beta * dplus - gamma * dminus) 
egen agg_hostility=sum(hostility)
scalar lambda=1-[1/(agg_hostility)]
sort MCref
mkmat hostility, matrix(GAMMA)

**
* step 2: Compute the equilibrium using matrices and then build the simulated Dataset from the equilibrium matrix
**  

* Compute the equilibrium year by year
 foreach num of numlist $time  {
 clear
 matrix EFFORT_`num'=(inv(ID + (beta * Aplus) - (gamma * Aminus))) * (( lambda*(1-lambda)* GAMMA)- Z_`num' -  EPSILON_`num'- E) 
 matrix EFFORT_ENEMY_`num'=Aminus * EFFORT_`num'
 matrix EFFORT_ALLIED_`num'=Aplus * EFFORT_`num'
 matrix U=lambda*(1-lambda)* GAMMA
 svmat EFFORT_`num', names(EFFORT)
 rename EFFORT EFFORT
 svmat EFFORT_ENEMY_`num', names(EFFORT_Enemy)
 rename EFFORT_Enemy EFFORT_Enemy
 svmat EFFORT_ALLIED_`num', names(EFFORT_Allied)
 rename EFFORT_Allied EFFORT_Allied
 svmat Z_`num', names(Z)
 rename Z1 Z
 svmat EPSILON_`num', names(EPSILON)
 rename EPSILON EPSILON
 svmat E, names(E)
 rename E1 E
 svmat U, names(U)
 rename U1 U
 gen MCref=[_n]
 gen year=`num'
 sort MCref year
 save temp`num', replace
                }


clear
foreach num of numlist $time  {
append using temp`num' 
 erase temp`num'.dta
                }
sort MCref year
save simul, replace
		
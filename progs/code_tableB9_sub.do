
 use bench_aminus, clear
 save temp_aminus, replace
 use bench_aplus, clear
 save temp_aplus, replace
 global time "1998(1)2010"
 use bench_data, clear
 save temp_MC, replace


* compute equilibrium
* Invariant parameters
 use temp_MC, clear
 scalar beta_initial=beta_bench
 scalar gamma_initial=gamma_bench
 scalar sd_beta_initial=sd_beta_bench
 scalar sd_gamma_initial=sd_gamma_bench
 sum EPSILON, d
 scalar sd_EPSILON=r(sd)

 use temp_MC, clear
 sum year
 keep if year==r(min)
 count
 scalar dim=r(N)
 matrix ID=I(dim)
 mkmat E, matrix(E)

 foreach num of numlist $time {
                 use temp_MC, clear
				 keep if year== `num'
				 gen raineffect= raincoeff * meanc_rain1 + sqraincoeff * sqmeanc_rain1 
				 sort MCref
				 mkmat OBS_SHIFTER, matrix(Z_`num')
                  mkmat meanc_rain1, matrix(RAIN_`num')
                 mkmat sqmeanc_rain1, matrix(SQRAIN_`num')
                 mkmat raineffect, matrix(RAINEFFECT_`num')
				mkmat EPSILON, matrix(EPSILON_`num')
				}
				
* build observed adjacency matrices and store them
 use temp_aminus, clear
 sort MCref MCref_d
 reshape wide aminus, i(MCref) j(MCref_d)
 drop MCref
 mkmat aminus*, matrix(Aminus_obs)
 use temp_aplus, clear
 sort MCref MCref_d
 reshape wide aplus, i(MCref) j(MCref_d)
 drop MCref
 mkmat aplus*, matrix(Aplus_obs)



* loop on the parameters and store the results
* Maximal Interval for beta and gamma

 clear
 gen beta_est=.
 gen gamma_est=.
 gen gamma_OLSest=.
 gen beta_OLSest=.
 gen beta_data=.
 gen gamma_data=.
 gen sd_beta_data=.
 gen sd_gamma_data=.
 gen proba_mismeasure_allied=. 
 gen proba_mismeasure_ennemy=.
 gen interior=.

 save MC3_result, replace


foreach thousand of numlist 1  {
di `thousand' "000"
foreach mc of numlist 1(1)1000 {

*p_mismeasure_allied
* build real adjency matrices and store them
* build vectors of bench lambda and hostility
  use temp_aminus, clear
 replace aminus=(runiform() < p_mismeasure_ennemy) if aminus==0
 replace aminus=1-((runiform() < p_mismeasure_ennemy)) if aminus==1
  sort MCref MCref_d
  save temp_minus, replace
  reshape wide aminus, i(MCref) j(MCref_d)
  drop MCref
  mkmat aminus*, matrix(Aminus_real)
  use temp_aplus, clear
 replace aplus=(runiform() < p_mismeasure_allied) if aplus==0
 replace aplus=1-((runiform() < p_mismeasure_allied)) if aplus==1
  save temp_plus, replace
  sort MCref MCref_d
  reshape wide aplus, i(MCref) j(MCref_d)
  drop MCref
  mkmat aplus*, matrix(Aplus_real)
  use temp_minus, clear
  sort MCref
  collapse (sum)aminus, by(MCref)
  rename aminus dminus
  sort MCref 
  save temp, replace
  use temp_plus, clear
  sort MCref
  collapse (sum)aplus, by(MCref)
  rename aplus dplus
  sort MCref 
  merge MCref using temp
   drop _merge
  save temp, replace
  use temp, clear
  gen hostility=1/(1+ beta_initial * dplus - gamma_initial * dminus) 
  egen agg_hostility=sum(hostility)
  scalar lambda=1-[1/(agg_hostility)]
  sort MCref
  mkmat hostility, matrix(GAMMA)
  sum hostility
  scalar interioreq=(r(min)>0) 
 
 foreach num of numlist $time {
                 use temp_MC, clear
				 keep if year== `num'
				 sort MCref
				replace EPSILON= rnormal(0, sd_EPSILON) 
				 mkmat EPSILON, matrix(EPSILON_`num')
				}
				
 foreach num of numlist $time  {
  clear
  matrix EFFORT_`num'=(inv(ID + (beta_initial * Aplus_real) - (gamma_initial * Aminus_real))) * ((lambda*(1-lambda)* GAMMA)- RAINEFFECT_`num' - Z_`num' -  EPSILON_`num'- E) 

  matrix EFFORT_ENEMY_`num'=Aminus_obs * EFFORT_`num'
  matrix EFFORT_ALLIED_`num'=Aplus_obs * EFFORT_`num'
 
  svmat EFFORT_`num', names(EFFORT)
  rename EFFORT EFFORT
  svmat EFFORT_ENEMY_`num', names(EFFORT_Enemy)
  rename EFFORT_Enemy EFFORT_Enemy
  svmat EFFORT_ALLIED_`num', names(EFFORT_Allied)
  rename EFFORT_Allied EFFORT_Allied
 
  matrix RAIN_ENEMY_`num'=Aminus_obs * RAIN_`num'
  matrix RAIN_ALLIED_`num'=Aplus_obs * RAIN_`num'
  matrix SQRAIN_ENEMY_`num'=Aminus_obs * SQRAIN_`num'
  matrix SQRAIN_ALLIED_`num'=Aplus_obs * SQRAIN_`num'
 
  svmat RAIN_`num', names(RAIN)
  rename RAIN1 RAIN
  svmat SQRAIN_`num', names(SQRAIN)
  rename SQRAIN1 SQRAIN
 
  svmat RAIN_ALLIED_`num', names(RAIN_Allied)
  rename RAIN_Allied1 RAIN_Allied
  svmat SQRAIN_ALLIED_`num', names(SQRAIN_Allied)
  rename SQRAIN_Allied1 SQRAIN_Allied
 
  svmat RAIN_ENEMY_`num', names(RAIN_Enemy)
  rename RAIN_Enemy1 RAIN_Enemy
  svmat SQRAIN_ENEMY_`num', names(SQRAIN_Enemy)
  rename SQRAIN_Enemy1 SQRAIN_Enemy
 
 
 

 
 
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
 sort year MCref
 merge year MCref using bench_data


bys year: egen AGG_EFF=sum(EFFORT)
gen EFFORT_Neutral= AGG_EFF - EFFORT_Enemy - EFFORT_Allied - EFFORT
 
$countOLS
 gen gamma_OLSest= _b[ EFFORT_Enemy]
 gen beta_OLSest= - _b[ EFFORT_Allied]

$count2SLS
 gen gamma_est= _b[ EFFORT_Enemy]
 gen beta_est= - _b[ EFFORT_Allied]

 
  keep if [_n]==1
  gen beta_data=beta_initial
  gen gamma_data=gamma_initial
  gen sd_beta_data=sd_beta_initial
  gen sd_gamma_data=sd_gamma_initial
  gen proba_mismeasure_allied = p_mismeasure_allied
  gen proba_mismeasure_ennemy = p_mismeasure_ennemy 
  gen interior=interioreq

 keep beta_est gamma_est beta_OLSest gamma_OLSest beta_data gamma_data sd_beta_data sd_gamma_data interior proba_mismeasure_allied proba_mismeasure_ennemy
 append using MC3_result
 save MC3_result, replace

}
}

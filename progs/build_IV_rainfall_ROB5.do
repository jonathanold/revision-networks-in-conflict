
*********************************************************
** Retrieve charact from enemies and from enemies of enemies
*********************************************************
global lag " 0"
global aggregation "collapse (sum)"

use ../original_data/ROB5/MC.dta, clear
 
** Rainfall at the centroid of the fighting group
keep id MCr*
rename MCr10 rain2010
rename MCr09 rain2009
rename MCr08 rain2008
rename MCr07 rain2007
rename MCr06 rain2006
rename MCr05 rain2005
rename MCr04 rain2004
rename MCr03 rain2003
rename MCr02 rain2002
rename MCr01 rain2001
rename MCr00 rain2000
rename MCr99 rain1999
rename MCr98 rain1998
cap rename MCr97 rain1997
cap rename MCr96 rain1996
cap rename MCr95 rain1995
cap drop MCr9510
cap drop MCr11
cap drop MCr9811

sort id
reshape long rain, i(id) j(year)
rename rain meanc_rain_t
* There is an option Here. Lag or not?
replace year=year+ $lag 
label var meanc_rain_t "Rainfall (at the mean-center)"
order id 
sort id year
save temp.dta, replace


use masterdata_DRC, clear
sort id year
merge id year using temp
tab _merge
drop if _merge==2
drop _merge
rename meanc_rain_t meanc_rain0
replace year=year-1
sort id year
merge id year using temp
tab _merge
drop if _merge==2
drop _merge
rename meanc_rain_t meanc_rain1
replace year=year-1
sort id year
merge id year using temp
tab _merge
drop if _merge==2
drop _merge
rename meanc_rain_t meanc_rain2
replace year=year-1
sort id year
merge id year using temp
tab _merge
drop if _merge==2
drop _merge
rename meanc_rain_t meanc_rain3
replace year=year+3
erase temp.dta
save temp_rain, replace
***********************

**
* select the characteristics
use temp_rain, clear
sort group year
keep group year meanc_rain* degree_minus Government_org
rename group group_d
*rename meanc_rain rain_d
rename meanc_rain0 rain_d0
rename meanc_rain1 rain_d1
rename meanc_rain2 rain_d2
rename meanc_rain3 rain_d3
rename degree_minus dmin_d
rename Government_org Gov_d
sort group_d year 
save temp.dta, replace
**

**
* Enemies and Enemies of Enemies
**
use KRTZ_dyadic_base_mt.dta, clear
sort group group_d year
*by group  group_d: keep if [_n]==1 
keep group  group_d enemy year
sort group_d year
merge group_d year using temp
tab _merge
drop _merge
sort group_d
*merge group_d using tempC
*tab _merge
*drop _merge
drop if group==group_d
keep if enemy==1
sort group year 
* collapse (sum) dmin_d Gov_d rain_d, by(group year)
$aggregation dmin_d Gov_d rain_d*, by(group year)
*rename rain_d rain_enemies
rename rain_d0 rain_enemies0
rename rain_d1 rain_enemies1
rename rain_d2 rain_enemies2
rename rain_d3 rain_enemies3
rename dmin_d dmin_enemies
rename Gov_d Gov_enemies
sort group year
save tempA, replace

rename group group_d
sort group_d year
save tempAB, replace

use KRTZ_dyadic_base_mt.dta, clear
sort group group_d year
*by group  group_d: keep if [_n]==1 
keep group  group_d enemy year
sort group_d year
merge group_d year using tempAB
tab _merge
drop _merge
drop if group==group_d
keep if enemy==1
sort group year 
*collapse (sum) dmin_enemies Gov_enemies rain_enemies, by(group year)
$aggregation dmin_enemies Gov_enemies rain_enemies*, by(group year)
rename rain_enemies0 rain_enemies_enemies0
rename rain_enemies1 rain_enemies_enemies1
rename rain_enemies2 rain_enemies_enemies2
rename rain_enemies3 rain_enemies_enemies3
rename dmin_enemies dmin_enemies_enemies
rename Gov_enemies Gov_enemies_enemies
sort group year
save tempB, replace

**
* Allies and Allies of Allies
**
use KRTZ_dyadic_base_mt.dta, clear
sort group group_d year
*by group  group_d: keep if [_n]==1 
keep group  group_d allied year
sort group_d year
merge group_d year using temp
tab _merge
drop _merge
sort group_d
*merge group_d using tempC
*tab _merge
*drop _merge
drop if group==group_d
keep if allied==1
sort group year 
*collapse (sum) dmin_d Gov_d rain_d, by(group year)
$aggregation dmin_d Gov_d rain_d*, by(group year)
rename rain_d0 rain_allies0
rename rain_d1 rain_allies1
rename rain_d2 rain_allies2
rename rain_d3 rain_allies3
rename dmin_d dmin_allies
rename Gov_d Gov_allies
sort group year
save tempC, replace

rename group group_d
sort group_d year
save tempCD, replace

use KRTZ_dyadic_base_mt.dta, clear
sort group group_d year
*by group  group_d: keep if [_n]==1 
keep group  group_d allied year
sort group_d year
merge group_d year using tempCD
tab _merge
drop _merge
drop if group==group_d
keep if allied==1
sort group year 
* collapse (sum) dmin_allies Gov_allies rain_allies, by(group year)
$aggregation dmin_allies Gov_allies rain_allies*, by(group year)
rename rain_allies0 rain_allies_allies0
rename rain_allies1 rain_allies_allies1
rename rain_allies2 rain_allies_allies2
rename rain_allies3 rain_allies_allies3
rename dmin_allies dmin_allies_allies
rename Gov_allies Gov_allies_allies
sort group year
save tempD, replace

**
* Enemies of Allies
**

use KRTZ_dyadic_base_mt.dta, clear
sort group group_d year
*by group  group_d: keep if [_n]==1 
keep group  group_d allied year
sort group_d year
merge group_d year using tempAB
tab _merge
drop _merge
drop if group==group_d
keep if allied==1
sort group year 
* collapse (sum) dmin_enemies Gov_enemies rain_enemies, by(group year)
$aggregation dmin_enemies Gov_enemies rain_enemies*, by(group year)
rename rain_enemies0 rain_enemies_of_allies0
rename rain_enemies1 rain_enemies_of_allies1
rename rain_enemies2 rain_enemies_of_allies2
rename rain_enemies3 rain_enemies_of_allies3
rename dmin_enemies dmin_enemies_of_allies
rename Gov_enemies Gov_enemies_of_allies
sort group year
save tempE, replace


**
* Neutrals
**
use KRTZ_dyadic_base_mt.dta, clear
*gen neutral=0
*replace neutral=1 if enemy==0 & allied==0
sort group group_d year
*by group  group_d: keep if [_n]==1 
keep group  group_d neutral year
sort group_d year
merge group_d year using temp
tab _merge
drop _merge
sort group_d
*merge group_d using tempC
*tab _merge
*drop _merge
drop if group==group_d
keep if neutral==1
sort group year 
* collapse (sum) dmin_d Gov_d rain_d, by(group year)
$aggregation dmin_d Gov_d rain_d*, by(group year)
*rename rain_d rain_enemies
rename rain_d0 rain_neutral0
rename rain_d1 rain_neutral1
rename rain_d2 rain_neutral2
rename rain_d3 rain_neutral3
rename dmin_d dmin_neutral
rename Gov_d Gov_neutral
sort group year
save tempF, replace

***
* Merge with main dataset
***
use temp_rain, clear
sort group year
merge group year using tempA
tab _merge
drop _merge
sort group year
merge group year using tempB
tab _merge
drop _merge
sort group year
merge group year using tempC
tab _merge
* there are _merge==1 because many groups have no allies
replace dmin_allies=0 if _merge==1
replace rain_allies0=0 if _merge==1
replace rain_allies1=0 if _merge==1
replace rain_allies2=0 if _merge==1
replace rain_allies3=0 if _merge==1
replace Gov_allies=0 if _merge==1
replace dmin_allies=0 if dmin_allies==.
replace rain_allies0=0 if rain_allies0==.
replace rain_allies1=0 if rain_allies1==.
replace rain_allies2=0 if rain_allies2==.
replace rain_allies3=0 if rain_allies3==.
replace Gov_allies=0 if Gov_allies==.
drop _merge
sort group year
merge group year using tempD
tab _merge
replace dmin_allies_allies=0 if _merge==1
replace rain_allies_allies0=0 if _merge==1
replace rain_allies_allies1=0 if _merge==1
replace rain_allies_allies2=0 if _merge==1
replace rain_allies_allies3=0 if _merge==1
replace Gov_allies_allies=0 if _merge==1
replace dmin_allies_allies=0 if dmin_allies_allies==.
replace rain_allies_allies0=0 if rain_allies_allies0==.
replace rain_allies_allies1=0 if rain_allies_allies1==.
replace rain_allies_allies2=0 if rain_allies_allies2==.
replace rain_allies_allies3=0 if rain_allies_allies3==.
replace Gov_allies_allies=0 if Gov_allies_allies==.
drop _merge
sort group year
merge group year using tempE
tab _merge
replace dmin_enemies_of_allies=0 if _merge==1
replace rain_enemies_of_allies0=0 if _merge==1
replace rain_enemies_of_allies1=0 if _merge==1
replace rain_enemies_of_allies2=0 if _merge==1
replace rain_enemies_of_allies3=0 if _merge==1
replace Gov_enemies_of_allies=0 if _merge==1
replace dmin_enemies_of_allies=0 if dmin_enemies_of_allies==.
replace rain_enemies_of_allies0=0 if rain_enemies_of_allies0==.
replace rain_enemies_of_allies1=0 if rain_enemies_of_allies1==.
replace rain_enemies_of_allies2=0 if rain_enemies_of_allies2==.
replace rain_enemies_of_allies3=0 if rain_enemies_of_allies3==.
replace Gov_enemies_of_allies=0 if Gov_enemies_of_allies==.
drop _merge

sort group year
merge group year using tempF
tab _merge
* there are _merge==1 because many groups have no allies
replace dmin_neutral=0 if _merge==1
replace rain_neutral0=0 if _merge==1
replace rain_neutral1=0 if _merge==1
replace rain_neutral2=0 if _merge==1
replace rain_neutral3=0 if _merge==1
replace Gov_neutral=0 if _merge==1
replace dmin_neutral=0 if dmin_neutral==.
replace rain_neutral0=0 if rain_neutral0==.
replace rain_neutral1=0 if rain_neutral1==.
replace rain_neutral2=0 if rain_neutral2==.
replace rain_neutral3=0 if rain_neutral3==.
replace Gov_neutral=0 if Gov_neutral==.
drop _merge

label var dmin_enemies "Sum of degrees of enemies"
label var Gov_enemies "Sum of Government_org of enemies"
label var  meanc_rain0 " Current Rainfall (at the mean-center)"
label var  meanc_rain1 " t-1 Rainfall (at the mean-center)"
label var  meanc_rain2 " t-2 Rainfall (at the mean-center)"
label var  meanc_rain3 " t-3 Rainfall (at the mean-center)"
label var rain_enemies0 "Sum of current Rainfall (mean-c) of enemies"
label var rain_enemies1 "Sum of t-1 Rainfall (mean-c) of enemies"
label var rain_enemies2 "Sum of t-2 Rainfall (mean-c) of enemies"
label var rain_enemies3 "Sum of t-3 Rainfall (mean-c) of enemies"
label var dmin_allies "Sum of degrees of allies"
label var Gov_allies "Sum of Government_org of allies"
label var rain_allies0 "Sum of current Rainfall (mean-c) of allies"
label var rain_allies1 "Sum of t-1 Rainfall (mean-c) of allies"
label var rain_allies2 "Sum of t-2 Rainfall (mean-c) of allies"
label var rain_allies3 "Sum of t-3 Rainfall (mean-c) of allies"
label var dmin_enemies_enemies "Sum of degrees of enemies of enemies"
label var Gov_enemies_enemies "Sum of Government_org of enemies of enemies"
label var rain_enemies_enemies0 "Sum of current Rainfall (mean-c) of enemies of enemies"
label var rain_enemies_enemies1 "Sum of t-1 Rainfall (mean-c) of enemies of enemies"
label var rain_enemies_enemies2 "Sum of t-2 Rainfall (mean-c) of enemies of enemies"
label var rain_enemies_enemies3 "Sum of t-3 Rainfall (mean-c) of enemies of enemies"
label var dmin_allies_allies "Sum of degrees of allies of allies"
label var Gov_allies_allies "Sum of Government_org of allies of allies"
label var rain_allies_allies0 "Sum of current Rainfall (mean-c) of allies of allies"
label var rain_allies_allies1 "Sum of t-1 Rainfall (mean-c) of allies of allies"
label var rain_allies_allies2 "Sum of t-2 Rainfall (mean-c) of allies of allies"
label var rain_allies_allies3 "Sum of t-3 Rainfall (mean-c) of allies of allies"
label var dmin_enemies_of_allies "Sum of degrees of enemies of allies"
label var rain_enemies_of_allies0 "Sum of current Rainfall (mean-c) of enemies of allies"
label var rain_enemies_of_allies1 "Sum of t-1 Rainfall (mean-c) of enemies of allies"
label var rain_enemies_of_allies2 "Sum of t-2 Rainfall (mean-c) of enemies of allies"
label var rain_enemies_of_allies3 "Sum of t-3 Rainfall (mean-c) of enemies of allies"
label var dmin_enemies_of_allies "Sum of degrees of enemies of allies"
label var Gov_enemies_of_allies "Sum of Government_org of enemies of allies"

label var dmin_neutral "Sum of degrees of neutral"
label var Gov_neutral "Sum of Government_org of neutral"
label var rain_neutral0 "Sum of current Rainfall (mean-c) of neutral"
label var rain_neutral1 "Sum of t-1 Rainfall (mean-c) of neutral"
label var rain_neutral2 "Sum of t-2 Rainfall (mean-c) of neutral"
label var rain_neutral3 "Sum of t-3 Rainfall (mean-c) of neutral"

erase temp.dta
erase tempA.dta
erase tempB.dta
erase tempC.dta
erase tempD.dta
erase tempE.dta
erase tempAB.dta
erase tempCD.dta
erase tempF.dta

qui tab group, gen(Dgroup)
save temp_rain, replace



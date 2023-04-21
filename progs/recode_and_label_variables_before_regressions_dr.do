*recoding and labeling variables:

drop if group==.
sort group year
tsset group year

replace Government_org=1 if id==7
replace Government_org=1 if id==19
replace Government_org=1 if id==30
replace Government_org=1 if id==398
replace Government_org=1 if id==1025

replace Countrycode=517 if id==471
replace Countrycode=516 if id==1341

*coding additional variables
gen gov_totalfight=Government_org*total_fighting_Africa_exclDRC

tab Countrycode, gen(cdummy)
gen Foreign=0
replace Foreign=1 if Countrycode~=490
replace Foreign=1 if id==1313
replace Foreign=1 if id==2079
replace Foreign=1 if id==2370

gen for_totalfight=Foreign*total_fighting_Africa_exclDRC

gen sqmeanc_rain0=meanc_rain0*meanc_rain0
gen sqrain_enemies0=rain_enemies0*rain_enemies0
gen sqrain_allies0=rain_allies0*rain_allies0
gen sqrain_enemies_enemies0=rain_enemies_enemies0*rain_enemies_enemies0
gen sqrain_enemies_of_allies0=rain_enemies_of_allies0*rain_enemies_of_allies0
gen cubrain_enemies_enemies0=rain_enemies_enemies0*rain_enemies_enemies0*rain_enemies_enemies0
gen cubrain_enemies_of_allies0=rain_enemies_of_allies0*rain_enemies_of_allies0*rain_enemies_of_allies0
gen cubmeanc_rain0=meanc_rain0*meanc_rain0*meanc_rain0
gen cubrain_enemies0=rain_enemies0*rain_enemies0*rain_enemies0
gen cubrain_allies0=rain_allies0*rain_allies0*rain_allies0
gen logmeanc_rain0=log(1+meanc_rain0)
gen lograin_enemies0=log(1+rain_enemies0)
gen lograin_allies0=log(1+rain_allies0)
gen sqmeanc_rain1=meanc_rain1*meanc_rain1
gen sqrain_enemies1=rain_enemies1*rain_enemies1
gen sqrain_allies1=rain_allies1*rain_allies1
gen sqrain_enemies_enemies1=rain_enemies_enemies1*rain_enemies_enemies1
gen sqrain_enemies_of_allies1=rain_enemies_of_allies1*rain_enemies_of_allies1
gen cubrain_enemies_enemies1=rain_enemies_enemies1*rain_enemies_enemies1*rain_enemies_enemies1
gen cubrain_enemies_of_allies1=rain_enemies_of_allies1*rain_enemies_of_allies1*rain_enemies_of_allies1
gen cubmeanc_rain1=meanc_rain1*meanc_rain1*meanc_rain1
gen cubrain_enemies1=rain_enemies1*rain_enemies1*rain_enemies1
gen cubrain_allies1=rain_allies1*rain_allies1*rain_allies1
gen logmeanc_rain1=log(1+meanc_rain1)
gen lograin_enemies1=log(1+rain_enemies1)
gen lograin_allies1=log(1+rain_allies1)
gen sqmeanc_rain2=meanc_rain2*meanc_rain2
gen sqrain_enemies2=rain_enemies2*rain_enemies2
gen sqrain_allies2=rain_allies2*rain_allies2
gen sqrain_enemies_enemies2=rain_enemies_enemies2*rain_enemies_enemies2
gen sqrain_enemies_of_allies2=rain_enemies_of_allies2*rain_enemies_of_allies2
gen cubrain_enemies_enemies2=rain_enemies_enemies2*rain_enemies_enemies2*rain_enemies_enemies2
gen cubrain_enemies_of_allies2=rain_enemies_of_allies2*rain_enemies_of_allies2*rain_enemies_of_allies2
gen cubmeanc_rain2=meanc_rain2*meanc_rain2*meanc_rain2
gen cubrain_enemies2=rain_enemies2*rain_enemies2*rain_enemies2
gen cubrain_allies2=rain_allies2*rain_allies2*rain_allies2
gen logmeanc_rain2=log(1+meanc_rain2)
gen lograin_enemies2=log(1+rain_enemies2)
gen lograin_allies2=log(1+rain_allies2)

gen sqrain_neutral0=rain_neutral0*rain_neutral0
gen sqrain_neutral1=rain_neutral1*rain_neutral1 

gen cubrain_neutral0=rain_neutral0*rain_neutral0*rain_neutral0
gen cubrain_neutral1=rain_neutral1*rain_neutral1*rain_neutral1 

label variable TotFight_Enemy "Tot. Fight. Enemies"
label variable TotFight_Allied "Tot. Fight Allies"
label variable degree_plus "d+ (#Allies)"
label variable degree_minus "d- (#Enemies)"
label variable Government_org "Government Org."
label variable total_fighting_Africa_exclDRC "Fight.w.o.DRC"
label variable gov_totalfight "Gov.Org.*Fi.w.o.DRC"
label variable for_totalfight "For.*Fi.w.o.DRC"
label variable meanc_rain0 "Current Rain"
label variable meanc_rain1 "Rain (t-1)"
label variable meanc_rain2 "Rain (t-2)"
label variable rain_enemies0 "Current Rain Enemies"
label variable rain_allies0 "Current Rain Allies"
label variable rain_enemies1 "Rain (t-1) Enemies"
label variable rain_allies1 "Rain (t-1) Allies"
label variable rain_enemies2 "Rain (t-2) Enemies"
label variable rain_allies2 "Rain (t-2) Allies"
label variable sqmeanc_rain0 "Sq. Curr. Rain"
label variable sqrain_enemies0 "Sq. Curr. Rain Ene."
label variable sqrain_allies0 "Sq. Curr. Rain Alli."
label variable sqmeanc_rain1 "Sq. Rain (t-1)"
label variable sqrain_enemies1 "Sq. Rain (t-1) Ene."
label variable sqrain_allies1 "Sq. Rain (t-1) Alli."
label variable sqmeanc_rain2 "Sq. Rain (t-2)"
label variable sqrain_enemies2 "Sq. Rain (t-2) Ene."
label variable sqrain_allies2 "Sq. Rain (t-2) Alli."  
label variable rain_neutral0 "Current Rain Neutral"
label variable rain_neutral1 "Rain (t-1) Neutral"
label variable sqrain_neutral0 "Sq. Curr. Rain Neu."
label variable sqrain_neutral1 "Sq. Rain (t-1) Neu."
label variable cubrain_neutral0 "Cub. Curr. Rain Neu."
label variable cubrain_neutral1 "Cub. Rain (t-1) Neu."

*create additionnal controls
gen gov_year=Government_org*year
gen for_year=Foreign*year

forvalues i = 1998(1)2011 {
gen govern_`i'=0
replace govern_`i'=1 if Government_org==1 & year==`i'
          }
forvalues i = 1998(1)2011 {
gen foreign_`i'=0
replace foreign_`i'=1 if Foreign==1 & year==`i'
          }
		cap drop unpopular_*
forvalues i = 1998(1)2011 {
gen unpopular_`i'=0
replace unpopular_`i'=1 if  degree_minus>=10 & year==`i' //95% percentil
	}
gen unpopular=0
replace unpopular=1 if degree_minus>=10

gen D96=0
replace D96=1 if id==96 & year>=2001

gen D30=0
replace D30=1 if id==30 & year<2001

gen D41=0
replace D41=1 if id==41 & year<2000

gen D471=0
replace D471=1 if id==471 & year>=2000

forvalues i = 1998(1)2001 {
gen D96_`i'=0
replace D96_`i'=1 if id==96 & year==`i'
          }
forvalues i = 2002(1)2011 {
gen D30_`i'=0
replace D30_`i'=1 if id==30 & year==`i'
          }
forvalues i = 1998(1)1999 {
gen D471_`i'=0
replace D471_`i'=1 if id==471 & year==`i'
          }
forvalues i = 2000(1)2011 {
gen D41_`i'=0
replace D41_`i'=1 if id==41 & year==`i'
          }	


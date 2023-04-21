* label unnamed covariates

cap label var year "year"
cap label var sqrain_enemies_enemies0 "Sq. current Rain of enemies of enemies"
cap label var sqrain_enemies_of_allies0 "Sq. current Rain of enemies of allies" 
cap label var sqrain_enemies_enemies1 "Sq. Rain (t-1) of enemies of enemies"
cap label var sqrain_enemies_of_allies1  "Sq. Rain (t-1) of enemies of allies"
cap label var sqrain_enemies_enemies2 "Sq. Rain (t-2) of enemies of enemies"
cap label var sqrain_neutral0 "Sq. current Rain  of neutral"
cap label var sqrain_enemies_of_allies2 "Sq. Rain (t-2) of enemies of allies"
cap label var lag1TotFight_Enemy "Tot. Fight. Enemies (t-1)"
cap label var lag1TotFight_Allied "Tot. Fight Allies (t-1)"
cap label var Foreign "foreign"
cap label var Government_org "Governmental Organisation"
cap label var latitude "latitude"
cap label var longitude "longitude"
keep id name country actor TE* govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_* TotFight meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 meanc_rain2 sqmeanc_rain2 Dgroup* TotFight_Enemy TotFight_Allied TotFight_Neutral rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 rain_neutral2 rain_enemies2 sqrain_enemies2 rain_allies2 sqrain_allies2 rain_enemies_enemies2 sqrain_enemies_enemies2 rain_enemies_of_allies2 sqrain_enemies_of_allies2 lag1TotFight_Enemy lag1TotFight_Allied  latitude longitude group year degree_minus degree_plus Foreign Government_org
order group id name country actor year TotFight TotFight_Enemy TotFight_Allied TotFight_Neutral degree_minus degree_plus latitude longitude  meanc_rain0 sqmeanc_rain0 meanc_rain1 sqmeanc_rain1 meanc_rain2 sqmeanc_rain2 rain_enemies0 sqrain_enemies0 rain_allies0 sqrain_allies0 rain_enemies1 sqrain_enemies1 rain_allies1 sqrain_allies1 rain_enemies_enemies0 sqrain_enemies_enemies0 rain_enemies_of_allies0 sqrain_enemies_of_allies0 rain_enemies_enemies1 sqrain_enemies_enemies1 rain_enemies_of_allies1 sqrain_enemies_of_allies1 rain_neutral0 sqrain_neutral0 rain_neutral1 sqrain_neutral1 rain_neutral2 rain_enemies2 sqrain_enemies2 rain_allies2 sqrain_allies2 rain_enemies_enemies2 sqrain_enemies_enemies2 rain_enemies_of_allies2 sqrain_enemies_of_allies2 lag1TotFight_Enemy lag1TotFight_Allied TE* Foreign Government_org govern_* foreign_* unpopular_* D96_* D30_* D41_* D471_* Dgroup* 
foreach num of numlist 1998 (1) 2011 {
                display `num'
				cap label var govern_`num' "Dummy for government x (year=`num')"
				cap label var foreign_`num' "Dummy for foreign x (year=`num')"
				cap label var unpopular_`num' "Dummy for large x (year=`num')"
				cap label var D96_`num'  "Dummy for (id=96) x (year=`num')"
				cap label var D30_`num'  "Dummy for (id=30) x (year=`num')"
				cap label var D41_`num' "Dummy for (id=41) x (year=`num')"
				cap label var D471_`num' "Dummy for (id=471) x (year=`num')"
        }

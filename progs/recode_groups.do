// code to change id of several actors


foreach x of var ACTOR1 ACTOR2 ALLY_ACTOR_2 ALLY_ACTOR_1 ALLY_ACTOR_1B ALLY_ACTOR_2B{

replace `x'="RCD: Rally for Congolese Democracy (Kisangani)"	if id_`x'==196
replace id_`x'=71	if id_`x'==196

replace `x'="Military Forces of Democratic Republic of Congo (1997-2001) (Kabila, L.)"	if id_`x'==219 & year<2002
replace id_`x'=30	if id_`x'==219 & year<2002

replace `x'="Military Forces of Democratic Republic of Congo (2001-) (Kabila, J.)"	if id_`x'==219 & year>2001
replace id_`x'=19	if id_`x'==219 & year>2001

replace `x'="Mutiny of Military Forces of Democratic Republic of Congo (2003-)"	if id_`x'==419
replace id_`x'=287	if id_`x'==419

replace `x'="Military Forces of Rwanda (2000-)"	if id_`x'==41 & year>1999
replace id_`x'=471	if id_`x'==41 & year>1999

replace `x'="Military Forces of Democratic Republic of Congo (1997-2001) (Kabila, L.)"	if id_`x'==725
replace id_`x'=30	if id_`x'==725

replace `x'="Military Forces of Democratic Republic of Congo (2001-) (Kabila, J.)"	if id_`x'==866
replace id_`x'=19	if id_`x'==866

replace `x'="RCD: Rally for Congolese Democracy"	if id_`x'==1008
replace id_`x'=146	if id_`x'==1008

replace `x'="Military Forces of Uganda (1986-)"	if id_`x'==1425
replace id_`x'=9	if id_`x'==1425

replace `x'="Military Forces of Democratic Republic of Congo (2001-) (Kabila, J.)"	if id_`x'==1497
replace id_`x'=19	if id_`x'==1497

replace `x'="Munzaya Ethnic Militia (DRC)"	if id_`x'==1504
replace id_`x'=957	if id_`x'==1504

replace `x'="UPPS: Union for Democracy and Social Progress Party (DRC)"	if id_`x'==1622
replace id_`x'=487	if id_`x'==1622

replace `x'="RCD: Rally for Congolese Democracy (Goma)"	if id_`x'==2154
replace id_`x'=33	if id_`x'==2154

replace `x'="Mutiny of Military Forces of Democratic Republic of Congo (1997-2003) (Banyamulenge faction)"	if id_`x'==2371
replace id_`x'=301	if id_`x'==2371

replace `x'="MONUC: United Nations Organisation Mission in Democratic Republic of Congo (1999-2010)"	if id_`x'==703
replace id_`x'=93	if id_`x'==703

replace `x'="FAA/MPLA: Military Forces of Angola (1975-)"	if id_`x'==209
replace id_`x'=7	if id_`x'==209

replace `x'=" "	if id_`x'==1040
replace id_`x'=.	if id_`x'==1040

replace `x'=" "	if id_`x'==1181
replace id_`x'=.	if id_`x'==1181

replace `x'=" "	if id_`x'==1983
replace id_`x'=.	if id_`x'==1983

replace `x'=" "	if id_`x'==2171
replace id_`x'=.	if id_`x'==2171

* now some coding issues spotted 

replace `x'="Bomboma Ethnic Militia"	if id_`x'==1325
replace id_`x'=1124	if id_`x'==1325

replace `x'="Military Forces of Namibia (1990-2005)" if id_`x'==2302 & year<2006
replace id_`x'=200	if id_`x'==2302 & year<2006
replace `x'="Military Forces of Namibia (2006-)" if id_`x'==200 & year>2005
replace id_`x'=2302	if id_`x'==200 & year>2005
replace `x'="Military Forces of Namibia (2006-)" if id_`x'==2302 & year>2005


replace `x'="Military Forces of Rwanda (1994-1999)" if id_`x'==41 & year<2000
replace `x'="Military Forces of Rwanda (1994-1999)" if id_`x'==471 & year<2000
replace id_`x'=41	if id_`x'==471 & year<2000

replace `x'="Military Forces of Rwanda (2000-)" if id_`x'==41 & year>1999
replace id_`x'=471	if id_`x'==41 & year>1999


replace `x'="Military Forces of Sudan (1993-)" if id_`x'==25
replace id_`x'=27	if id_`x'==25

}



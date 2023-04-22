clear all

use ../original_data/all_africa_ext, clear
drop if YEAR==2011
drop if GWNO==490

keep YEAR id_ACTOR1 id_ALLY_ACTOR_1 id_ACTOR2 id_ALLY_ACTOR_2 id_ALLY_ACTOR_1B id_ALLY_ACTOR_2B
gen event=1
save temp, replace

global actors "id_ACTOR1 id_ALLY_ACTOR_1 id_ACTOR2 id_ALLY_ACTOR_2 id_ALLY_ACTOR_1B id_ALLY_ACTOR_2B"
foreach var of global actors {
 use temp, clear
collapse (sum) event, by(`var' YEAR) 
rename event event_`var'
rename `var' id
sort id YEAR
save temp_`var', replace
        }

*

use temp_id_ACTOR1, clear
save temp, replace

global actorsb "id_ALLY_ACTOR_1 id_ACTOR2 id_ALLY_ACTOR_2 id_ALLY_ACTOR_1B id_ALLY_ACTOR_2B"
foreach var of global actorsb {
use temp, clear
sort id YEAR
merge id YEAR using temp_`var'
drop _merge
save temp, replace
        }

*

replace event_id_ACTOR1=0 if event_id_ACTOR1==.
replace event_id_ALLY_ACTOR_1=0 if event_id_ALLY_ACTOR_1==.
replace event_id_ACTOR2=0 if event_id_ACTOR2==.
replace event_id_ALLY_ACTOR_2=0 if event_id_ALLY_ACTOR_2==.
replace event_id_ALLY_ACTOR_1B=0 if event_id_ALLY_ACTOR_1B==.
replace event_id_ALLY_ACTOR_2B=0 if event_id_ALLY_ACTOR_2B==.

gen total_fighting_Africa_exclDRC=event_id_ACTOR1+event_id_ACTOR2+event_id_ALLY_ACTOR_1+event_id_ALLY_ACTOR_2+event_id_ALLY_ACTOR_1B+event_id_ALLY_ACTOR_2B

rename YEAR year

keep id year total_fighting_Africa

sort id year

save total_fighting_Africa_exclDRC, replace
capture erase temp.dta
capture erase temp_id_ACTOR1.dta
global actors "id_ACTOR1 id_ALLY_ACTOR_1 id_ACTOR2 id_ALLY_ACTOR_2 id_ALLY_ACTOR_1B id_ALLY_ACTOR_2B"
foreach var of global actorsb {
erase temp_`var'.dta
        }

 

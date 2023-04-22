 
/*----------------------------------------------------*/
   /* [>   Master file for replication   <] */ 
/*----------------------------------------------------*/


/*
I start with the data files provided by the authors.

Execute this section to:
        * Create necessary directories on local machine
        * Install necesarry programs
        * Initialize programs, ado files
        * Create globals, locals, file paths
        * Run the complete analysis from this file.


* Our measure of fighting intensity is coarse insofar as it does not weigh events by the amount of military force involved. Ideally, we would like to have information about the number of casualties or other measures of physical destruction

*/

 

// Look at Conley SE maximum distance for robustness!!


/*----------------------------------------------------*/
   /* [>   1.  Make and set directories   <] */ 
/*----------------------------------------------------*/

/* [> Set working directory here <] */ 
global main "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Networks in Conflict/github/revision-networks-in-conflict/"
cd "${main}"
cap mkdir ./regressions/
cap mkdir ./progs/
cap mkdir ./results/
cap mkdir ./original_data/
cap mkdir ./github/networks-in-conflict/replication_code
cap mkdir ./replication_outputs
cap mkdir ./replication_outputs/tables
cap mkdir ./replication_outputs/figures

cd "${main}/regressions"

global code     "${main}/progs/"



/*----------------------------------------------------*/
   /* [>   2.  Initialize programs   <] */ 
/*----------------------------------------------------*/
do "${code}/my_spatial_2sls.do"
do "${code}/my_spatial_2sls_JDO.do"
do "${code}/nw2sls.do"
do "${code}/nw2sls_partial.do"

 
 
/*----------------------------------------------------*/
   /* [>   3.  Run files for replication   <] */ 
/*----------------------------------------------------*/
 do "${code}/Replication_Estimations_t1.do"
do "${code}/table1_improved.do"
do "${code}/table1_robustness.do"






clear
capture log close
set more on
********************************************************************************
**Nepal Living Standard Survey 2011                                           **
**Poverty + Education variables                                               **
**Illustrate effect of complex survey design: Weights, Strata, Clusters       **
**Dean Jolliffe                                                               **
********************************************************************************

/*Organizing the files*/
sysdir set PERSONAL "D:\0-ONEDRIVE\OneDrive - WBG\Stata15\0Stata\myado"
sysdir set STBPLUS  "D:\0-ONEDRIVE\OneDrive - WBG\Stata15\0Stata\stbado"


global path1= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\03_Deff/Data" 
              /*Where the original data set is located*/
							
global path2= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\03_Deff/Savedata"
              /*Where the clean data will be placed*/
							
global path3= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\03_Deff/Results" 
              /*Where the results will be placed*/

capture log using "$path3/complex_example.log", replace

display "`c(current_time)' `c(current_date)'"
********************************************************************************

*use "C:\Users\wb524078\OneDrive - WBG\stata_file\03_Deff\Data\poverty_edu.dta",clear 

use "$path1/poverty_educ.dta", clear
saveold "$path1/poverty_educ.dta", version(12) replace
more
summ poor [w=wt_ind]
rename xstra strata
rename xhpsu psu

 * 1. CORRECT FOR WEIGHTING, STRATIFICATION and CLUSTERING;
 quietly svyset, clear
 quietly svyset psu [pw=wt_ind], strata(strata)
 svy: mean poor
	
	more
 estat effects, deff
	
* Could estimate rho from [1+(m-1)rho]=DEFF, or;
loneway poor psu /*Large one-way ANOVA*/
* Not quite right, but reasonable estimate to think about for the next sample;

more

* Say that we are considering going back into the field, 10 years later, and
* our primary purpose is to estimate the national rate of poverty;
* In 1997, our estimate was 26.5%;
* Let's say we decide that we want to have enough power in our new estimate,
* such that if the poverty rate has increased to 29%, we would be able to
* show that this difference is statistically significant from 26.5%;
* (Treating 26.5% as a constant.);

* First, consider the case of SRS in Stata;
*sampsi 0.265 0.29, power(0.9) alpha(0.05) onesample;

more

sampsi 0.265 0.29, power(0.9) alpha(0.05) sd1(0.44) onesample /*sampsi-sample 
                                   size estimates; onesample:one sample test*/
* What happens if 0.29->0.3? power declines? 
*Alpha increases? what if sd were smaller?
more

 *sampclus, obsclus(20) rho(0.11) /* sampclus command didn't work*/
clustersampsi,binomial samplesize p1(0.6) p2(0.7) m(20) rho(0.01) alpha(0.05) ///
 beta(0.9)

* What would happen if rho were higher?;
log close









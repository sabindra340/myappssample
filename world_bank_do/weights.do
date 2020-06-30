clear
capture log close
set more on
********************************************************************************
**Nepal Living Standard Survey 2011                                           **
**Poverty data                                                                **
**Assessing weights                                                           **
**Dean Jolliffe/Hiroki Uematsu/Ganesh Thapa                                   **
********************************************************************************

/*Organizing the files*/

global path1= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\02_Weights/Data" 
              /*Where the original data set is located*/
							
global path2= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\02_Weights/Savedata" 
               /*Where the clean data will be placed*/
							 
global path3= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\02_Weights/Results" 
               /*Where the results will be placed*/

capture log using "$path3/pwt_example.log", replace

display "`c(current_time)' `c(current_date)'"

more
********************************************************************************
*use "C:\Users\wb524078\OneDrive - WBG\stata_file\02_Weights\Data\poverty.dta",clear 
use "$path1/poverty.dta", clear

saveold "$path1/poverty.dta", version(12) replace

describe

more

rename xstra strata                                                  
tab strata
more

tab wt_hh

* interpret one of the weights, what does a weight of 1609 mean?
* This sample household represents 1609 households in the population
* (which are presumed in expectation to look similar to the sample hh) 
* Explain why there are unique values
* All HH within each stratum selected with equal probability
* Within each stratum, further adjustments for trimester and urb/rur
more

tab wt_hh strata if wt_hh<900 /* just looking at one screen of data*/
* Note 3 different weights (mostly) for each stratum
more

egen hid=group(xhpsu xhnum)  /*Creates unique household id*/
sort hid
order hid,before(xhpsu)
l hid xhpsu strata poor  hhsize wt* in 1/10 /*list first 10 observations*/

* Note each line represents one household. Note relationship btwn weights
* 
display  round(293.06*2,1) ", " round(293.06*3,1) ", " round(293.06*4,1) ", " round(293.06*5,1)
more

summ

* How many households in the sample? 5988?

more
codebook hid /*detail summary*/
*what do we learn from unique & missing?
more

* Poor=1 if total consumption < poverty line                  

summarize poor   
			
***;
***;
***    Interpret the mean                                          
***    What is "Std. Dev."?                                        
***    Read the online handouts for an applied discussion on the 
***    difference between standard errors and standard deviations
***    goto gpad_sdxse.pdf;
***    goto streiner_sdxse.pdf (comment on abstract, show equations)
***    When are we interested in sd? (SLR 4)
***    When are we interested in se?

more
	   
summ poor [w=wt_hh]                                        
***;
***;
       * Interpret the mean
       * Do we know how precisely estimated the mean is?                                         
       * What is "Weight"?                                          
***;
***;
more

summ poor [w=wt_ind]                                        
***;
***;
       * Interpret the mean                                         
       * What is "Weight"?                                          
***;
***;
more

summ hhsize [w=wt_hh]                                     
***;
***;
       * Interpret the mean                                          
       * How would you interpret mean if wt_indiv?                   
       * If wt_indiv, will mean change, increase, decrease?         
***;
***;
more
							
summ hhsize [w=wt_ind]                                      
***;
***;
       * Which should you use?                                       
***;
***;
more

svyset [weight=wt_ind], psu(xhpsu) strata(strata) 
							
more
	   
svy: mean poor  
							
summ poor [w=wt_ind]
							
       * Note Estimate and "Std. Error" (later for Deff)            
       * Note equivalence of "Weight" and "Pop size"  
							
more

tab strata
* This tells us the distribution of households in the sample
more
tab strata [aw=wt_hh]
* This tells us the distribution of households in the population
more


  *                                     n_h/sum(n_h)     N_h / sum(N_h)   Ratio
  *  -------------------------------------------------------------------------;
  *  Mountains                            0.07               0.07          1
  *  Urban-Kathmandu                      0.14               0.07          2
  *  Urban-Hill                           0.08               0.05          1.6
  *  Urban-Terai                          0.11               0.09          1.2
  *  Rural Hills -Eastern                 0.06               0.06          1
  *  Rural Hills -Central                 0.08               0.10          0.8
  *  Rural Hills - Western                0.08               0.11          0.73
  *  Rural Hills -Mid and far western     0.09               0.09          1
  *  Rural Terai - Eastern                0.08               0.12          0.67
  *  Rural Terai- Central                 0.08               0.13          0.62
  *  Rural Terai -Western                 0.06               0.06          1
  *  Rural Terai - Mid and Far west       0.07               0.07          1
  * -------------------------------------------------------------------------
  * Over or undersample households in each stratum?                        
  * eg. Urban-Kathmandu(oversampled):more obs in the sample relative 
	*     to population

more

svyset, clear
svyset, srs
svy: mean poor

more


svyset, clear
gen one=1
summ one
svyset [w=one]
svy: mean poor

more
help svy    
log close

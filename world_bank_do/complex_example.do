clear
capture log close
set more on

********************************************************************************
**Nepal Living Standard Survey 2011                                           **
**Poverty + Education variables                                               **
**Illustrate effect of complex survey design: Weights, Strata, Clusters       **
**Dean Jolliffe, Ganesh Thapa, Hiroki Uematsu 09/21/2017                                                   **
********************************************************************************
more

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
use "$path1/poverty_edu.dta", clear
saveold "$path1/poverty_edu.dta", version(12) replace

*use "C:\Users\wb524078\OneDrive - WBG\stata_file\03_Deff\Data\poverty_edu.dta", clear 
svyset, clear
svyset, srs
svydes
more

********************************************************************************
svyset, clear
gen one=1
svyset [w=one]
more
svydes
more


 * 1. UNWEIGHTED & NOT CORRECTED FOR STRATIFICATION AND CLUSTERING;
 
 describe hh_edu poor hhage
 summ hh_edu poor hhage
 
* Last class we looked at how weights change the means (or slope
* coefficients), now we look at how sample design affects variance
* estimates;
* Interpret Std. Dev. Is this what we're interested in?
* Can we get the standard error of the estimate from this output?

more

 display "Assuming SRS, SE mean of hh_edu = "  4.590746 / (5988)^0.5
 display "Assuming SRS, SE mean of hhage = "  14.13213  / (5988)^0.5
 
more

svy: mean hh_edu poor hhage

more

estat effects, deff

*Note DEFF =1. Note means

more

* 2. CORRECT FOR STRATIFICATION
 quietly svyset, clear
 rename xstra strata
 quietly svyset, strata(strata)
 more
 svydes
 
 more


 svy: mean hh_edu poor hhage
 estat effects, deff
 
* Note: No change in means, efficiency gain;
/*HH_EDU*/

  display "Vss/Vsrs = " round((.0557623)^2/(.0593256)^2,0.00001)
  display "SEss/SEsrs = " round(.0557623/.0593256,0.00001)
  display "SQR DEFF= "  round(.88348^0.5, 0.00001)
	
*What's the efficiency gain from stratification for hh_edu? poor?

more

*3. CORRECT FOR STRATIFICATION and CLUSTERING
 rename xhpsu psu 
 quietly svyset psu, strata(strata)
 svydes
 more

 svy: mean hh_edu poor hhage
 estat effects, deff
 
* Note: No change in means, efficiency loss

more

* Compare standard errors from parts 1 and 3;
/*
   Mean  |   SE(1)    SE(3)   Deff  Deff^0.5   SE(3)/SE(1)
---------+------------------------------------------------
 hh_edu  |  .0593   .07859    1.755    1.32     1.32
    poor |  .0050   .00807    2.584    1.61     1.61
   hhage |  .1826   .22642    1.537    1.24     1.24
*----------------------------------------------------------
*/
* Can you explain why the Deff differs?
* Note this comparison works because Deff=1 for base and unweighted

 more

 *4. CORRECTED FOR WEIGHTING, STRATIFICATION and CLUSTERING
 quietly svyset psu [pw=wt_hh], strata(strata)
 svydes
 more
 
*******************************************************************************
 svy: mean hh_edu poor hhage
 estat effects, deff
 
 * Note: using household weights, interpret (20% of what?)
 * Means change slightly.
 * Mean of poor increases -- Over or under sampling of poor households?
 * Mean of hh_edu decreases -- What's the sampling implication?
 * Is there anything we learned in the last lecture about over- and
 * under-sampling of each stratum that helps explain this? 
 
 more
 
*di _n(25)

 svyset, clear
 
 * Let's take another look at differences between weighted and unweighted 
 * sample proportions. 
 
svyset, srs
more

gen urban = 1 if urbrur==1
replace urban = 0 if urbrur==2

*rename urbrur urban
*recode urban (1=1) (2=0)


gen upper = (strata==218) /*Here upper is the Kathmandu city*/
svy: mean upper urban

more

*******************************************************************************
quietly svyset, clear
quietly svyset psu [pw=wt_ind], strata(strata)
svy: mean upper urban
 
*Under sampled urban and upper

di _n(25)

*One last example,let's test for whether poverty is different across urban/rural
*First, we'll weight by individuals, but accidentally forget strata and clusters

 quietly svyset, clear
 svyset [pw=wt_ind]


svy , subpop(urban): mean poor
 
more

svy , subpop(if urban==0): mean poor

display "(Difference / Stnd. Error) = "(0.27432-.15457)/(.0084^2 + 0.0103^2)^0.5


*Now, we'll examine this with corrected standard errors

quietly svyset psu [pw=wt_ind], strata(strata)

svy , subpop(urban): mean poor

svy , subpop(if urban==0): mean poor

display "(Difference / Stnd. Error) = "(0.27432-.15457)/(.0129^2 + 0.0175^2)^0.5
more

*Note no change in means, discuss change in precision
*This is a simplified version of a fully corrected test


display "P-value of test statistic = "(1-normal(9.009))*2
        /*Two tailed distribution*/
				
 ***  "Reject H0 (equality of means) at 99% confidence level"
 
 display _n
 
 display "P-value of test statistic = "(1-normal(5.508))*2
 
 *** "Fail to Reject H0 at 99% confidence level
 
more

*
* Let's repeat this last test, but rely more heavily on Stata
* In this case, the results will provide a test based on a
* test statistic that is correct in the presence of complex design

svy: mean poor, over(urban)

test [poor]0=[poor]1

*How accounting desing effects changes the inferences?
*Simple random sampling
svyset [pw=wt_ind]
svy: mean poor, over(strata)

test [poor]_subpop_6 =[poor]_subpop_10 

*Accounting complex survey design
quietly svyset psu [pw=wt_ind], strata(strata)
svy: mean poor, over(strata)
test [poor]_subpop_6 =[poor]_subpop_10 
*Changes the inferences, fail to reject the null hypothesis
log close







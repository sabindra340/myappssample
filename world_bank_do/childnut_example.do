clear
capture log close
set more on

********************************************************************************
**Nepal Living Standard Survey 2011                                           **
**Child level (<5 age) data                                                   **
**Using summarize and regress to look at HAZ/WHZ                              **
**Missing district-Mustang, Dolpa, Manang, Bajura                             **
**Dean Jolliffe/Hiroki Uematsu/Ganesh Thapa                                   **
********************************************************************************
/*Organizing the files*/
sysdir set PERSONAL "D:\0-ONEDRIVE\OneDrive - WBG\Stata15\0Stata\myado"
sysdir set STBPLUS  "D:\0-ONEDRIVE\OneDrive - WBG\Stata15\0Stata\stbado"

global path1= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\01_intro/Data" 
              /*Where the original data set is located*/
														
global path2= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\01_intro/Savedata" 
             /*Where the clean data will be placed*/
													
global path3= "D:\0-ONEDRIVE\WBG\Ganesh Thapa - stata_file\01_intro/Results" 
             /*Where the results will be placed*/

capture log using "$path3/childnut_example.log", replace

display "`c(current_time)' `c(current_date)'"

********************************************************************************
*use "C:\Users\wb524078\OneDrive - WBG\stata_file\01_intro\Data\NLSS2011_ChildNut.dta",clear 
use "$path1/NLSS2011_ChildNut.dta", clear

replace haz11=. if haz11==1.16 /* inserting two missing values */

saveold "$path1/NLSS2011_ChildNut.dta", version(12) replace

more

gen stunted=1 if haz11<=-2 /*HAZ-Height-for-age Zscore-measures long-term child
                              nutrition outcome; Below cut-off point of -2 
							  indicates that the child is stunted*/ 

replace stunted=0 if haz11>-2

summ stunted haz11
* Note how the number of observations differ, why is that?

summ stunted if haz11==.
* It seems that missing values for haz11 were set to zero for stunted. 
* But if haz11 is missing, we do not know if stunted or not
* In Stata, missing is handled as a very (infinitely) large number
* So, the problem is where we wrote replace stunted=0 if haz>-2, we should have
* written

more

drop stunted

gen stunted=1 if haz11<=-2 /*HAZ-Height-for-age Zscore-measures long-term child
                              nutrition outcomes; Below cut-off point of -2 
															indicates that the child is stunted*/ 

replace stunted=0 if haz11>-2 & haz11~=.

summ haz11 stunted

more

*Alternative syntax for creating dummy variables

gen stunt_child=(haz11<=-2)

replace stunt_child=. if haz11==.

summ stunt* haz*

more

gen wast_child=(whz11<=-2)/*WHZ-Weight for height Zscore-measures short-term 
                           child nutrition outcomes; Below cut-off pont of -2
													 indicates that the child is wasted*/ 

replace wast_child=. if whz11==.

label var stunt_child "If Child has haz11 <=-2, then 1, otherwise 0"

label var wast_child "If Child has whz11 <=-2, then 1, otherwise 0"

order(stunt_child wast_child), after(bmi11)

/*Descriptive statistics*/
summ stunted haz11 whz11 

/*with weight*/
summ stunted haz11 whz11 [w=wt_hh] 

svyset [pweight=wt_hh], psu(xhpsu) strata(xstra)           
        
*We'll cover the svyset command soon   
 
more

svy: regress stunted 

       * Interpret                                                   
       * Population who are stunted is 41.5%                                 
       * Who is in the population? (children under 5 years of age) 
			 * How many children: 2,356 or  2,432,133?                  
       * This is important information to note in empirical work     
       * Why? Informs/constrains inferences + evidence of data quality
       
more	 

svy: regress stunted poor 

       * poor=1 nonpoor=0, Interpret coefficient on poor             
       * What's avg stunting for poor children, for nonpoor children?                                
	     * Constant defines prevalence of stunting for the nonpoor (35.6%)
	     * Coefficient on poor tells difference in prevalence from nonpoor
			 * stunting for poor is 35.6+16.3 =51.9%

       * Next Regression
	     /*Different ethnic group*/
       * Brahmin Chhetry Mongolian Madhesi Unprivileged
	     *Unprivileged omitted								
more

  svy: regress stunted Brahmin Chhetry Mongolian Madhesi 
		
       * Omitted category is Dalit, Interpret coefficients                                        
       * Which ethnicity group has highest prevalence of stunting? Lowest?
   
log close



















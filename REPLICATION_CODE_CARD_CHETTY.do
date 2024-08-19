****Replication Code: CASH-ON-HAND AND COMPETING MODELS OF INTERTEMPORAL BEHAVIOR: NEW EVIDENCE FROM THE LABOR MARKET by David Card Raj Chetty, and Andrea Weber

****Author : Fatemeh Abbasian-Abyaneh
****Date : April 24, 2024

clear
set more off
cd "ENTER YOR PATH OF CHOICE"

* Load the master dataset
use sample_75_02.dta, clear

* Merge with the work history dataset using both file and penr as key variables
merge m:1 file penr using "work_history.dta"

* Check for merge results
tabulate _merge

* Clean up if needed (remove the _merge variable if all matched)
drop _merge

* keep between 1981 and 2001 and drop if recalled to last job
keep if file >= 1980 & file < 2002
drop if pr_recall ==1

* Save the merged dataset as merged.dta
save "merged_data.dta", replace


use "merged_data.dta", clear


* Sort the data by penr in ascending order and then by file in descending order
gsort penr -file

* Now keep the highest file observation for each penr
by penr: keep if _n == 1

* Optionally, save the dataset with the highest file value per penr
save "highest_file_per_penr.dta", replace
use "highest_file_per_penr.dta", clear
* To round to the nearest whole number
gen month_in_previous_job = floor(duration / 31)

 
* Calculate the number eligible for each month_in_previous_job
egen count_eligible = total(eligible30), by(month_in_previous_job)

* Calculate the total number of observations for each month_in_previous_job
egen count_total = count(eligible30), by(month_in_previous_job)

* Generate the fraction of eligible individuals for each month_in_previous_job
gen fraction_eligible = count_eligible / count_total
 
* Drop observations where month_in_previous_job is greater than 60 (fit in the figure)
drop if month_in_previous_job >= 58	| month_in_previous_job <= 12
drop if month_in_previous_job == 35
gsort month_in_previous_job


* plot the fraction eligible for 30 weeks of UI benefits by job tenure
twoway (scatter fraction_eligible month_in_previous_job, msize(small)) ///
       (lfit fraction_eligible month_in_previous_job if month_in_previous_job < 36, lcolor(red)) ///
       (lfit fraction_eligible month_in_previous_job if month_in_previous_job >= 36, lcolor(green)), ///
	xline(35, lcol(red)) ///
    title("Fraction Eligible for Extended UI Benefits by Job Tenure") ///
    ytitle("Fraction Eligible for 30 Weeks of UI Benefits") ///
    xtitle("Previous Job Tenure (Months)") ///
    ylabel(0.4(0.2)1) xlabel(12(6)60) ///
    legend(order(1 "Fraction Eligible" 2 "Best Linear Fit (Month < 36)" 3 "Best Linear Fit (Month > 36)")) ///
	graphregion(color(white)) plotregion(color(white)) ///
    name(FractionEligiblePlot, replace)

graph export "figure2a.png", replace




************************generating figure 2b
use "highest_file_per_penr.dta", clear
* To round to the nearest whole number
gen month_in_previous_job = floor(duration / 31)

gen month_employed_last_5_years = floor(dempl5 / 31)
gen eligible_severance_pay = 0
replace eligible_severance_pay = 1 if month_in_previous_job >= 36

drop if month_in_previous_job >= 60	| month_in_previous_job <= 12

* Collapse data to get the mean of eligible_severance_pay for each month_employed_last_5_years
collapse (mean) eligible_severance_pay, by(month_employed_last_5_years)
drop if month_employed_last_5_years >= 58

* Plot the fraction eligible for severance pay by month employed in the last 5 years

twoway (scatter eligible_severance_pay month_employed_last_5_years, msize(small)) ///
       (lfit eligible_severance_pay month_employed_last_5_years if month_employed_last_5_years < 36, lcolor(blue)) ///
       (lfit eligible_severance_pay month_employed_last_5_years if month_employed_last_5_years >= 36, lcolor(green)), ///
	xline(35.5, lcol(red)) ///
    title("Eligibility for Severance Pay by Past Employment") ///
    xlabel(12(6)60) ///
    ylabel(0(0.1)0.4, format(%9.1f)) ///
    ytitle("Fraction Eligible for Severance Pay") ///
    xtitle("Months Employed in Past Five Years") ///
    legend(order(1 "Fraction Eligible" 2 "Best Linear Fit (Month < 36)" 3 "Best Linear Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
	graphregion(color(white)) plotregion(color(white)) ///
    name(FractionEligibleSeverance, replace)
	
graph export "figure2b.png", replace





**************************generating figure 3
* Count the number of individuals in each tenure-month category
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31) /*ceil will give us a better match*/


* drop if iconstruction==.
drop if month_in_previous_job <= 12 | month_in_previous_job >= 58 // Just like the domain in figure
gsort month_in_previous_job



gen layoff = 1 	
* Tabulate the total number of layoffs for each tenure month category
egen layoffs_by_tenure = sum(layoff), by(month_in_previous_job)

* Assuming that 'layoffs_by_tenure' holds the count for each 'tenure_months' category
* Plot the frequency of layoffs by tenure-month category
twoway  (scatter layoffs_by_tenure month_in_previous_job, msize(small)) ///
		(line layoffs_by_tenure month_in_previous_job, lcolor(blue)), ///
	xline(35.5, lcol(red)) ///
    title("Frequency of Layoffs by Job Tenure") ///
    ytitle("Number of Layoffs") ///
    xtitle("Previous Job Tenure (Months)") ///
    ylabel(0.0(10000)40000) ///
	xlabel(12(6)60) ///
	graphregion(color(white)) plotregion(color(white)) ///
    name(FrequencyLayoffsTenure, replace)
graph export "figure3.png", replace	



**************************generating figure 4a
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31) 


* drop if iconstruction==.
drop if month_in_previous_job <= 12 | month_in_previous_job >= 58 // Just like the domain in figure
gsort month_in_previous_job

* Collapse data to get the mean age for each month_in_previous_job
collapse (mean) age, by(month_in_previous_job)

* Modify age by assuming each month is 31 days
replace age = age*(365/12/31)

* Plot mean of modified age by month_in_previous_job with two separate linear fits
twoway (scatter age month_in_previous_job, msize(small)) ///
       (lfit age month_in_previous_job if month_in_previous_job < 36, lcolor(red)) ///
       (lfit age month_in_previous_job if month_in_previous_job >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Age by Job Tenure") ///
    xlabel(12(6)60) ///
    ylabel(30(1)34) ///
    ytitle("Mean Age") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Linear Fit (Month < 36)" 3 "Linear Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(MeanAgeByMonth, replace)

* Export the graph
graph export "figure4a.png", replace




**************************generating figure 4b
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = ceil(duration / 31) // I have chosen ceil in this part because of its better match to the original figure 

drop if month_in_previous_job <= 12 | month_in_previous_job >= 58 // Just like the domain in figure
gsort month_in_previous_job

gen wage = wage0
* Rescale wage in 1000 Euros per year (Note that each month is 31 days)
replace wage = wage/1000*12*(12*31/365)

* Collapse data to get the mean wage for each month_in_previous_job
collapse (mean) wage, by(month_in_previous_job)




* Plot mean of annual wage by month_in_previous_job with two separate linear fits
twoway (scatter wage month_in_previous_job, msize(small)) ///
       (lfit wage month_in_previous_job if month_in_previous_job < 36, lcolor(red)) ///
       (lfit wage month_in_previous_job if month_in_previous_job >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Wage by Job Tenure") ///
    xlabel(12(6)60) ///
    ylabel(14.5(0.5)17) ///
    ytitle("Mean Annual Wage (Euro × 1000)") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Linear Fit (Month < 36)" 3 "Linear Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(MeanWageByMonth, replace)

* Export the graph
graph export "figure4b.png", replace




**************************generating figure 4c
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job >= 58 // Just like the domain in figure
gsort month_in_previous_job


* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)
// Note: I am not sure that month_of_job_loss and year_of_job_loss are calculated correctly. Thus, I do not use these in my hazard model as covariates (unless I become sure).


* Prepare other covariates
gen age_squared = age*age
gen wage = wage0/1000*12
gen log_wage = log(wage)
gen log_wage_squared = log(wage) * log(wage)
gen years_experience = floor(experience/12/31)
gen years_experience_squared = years_experience * years_experience
generate pr_bluecollar = (pr_etyp==2)


* Fit Cox proportonal hazard model
gen status=1 // We have droped all censored data
stset noneduration, failure(status==1)



stcox age age_squared female education married austrian ///
	bluecollar log_wage log_wage_squared firms years_experience ///
	years_experience_squared last_job last_duration pr_bluecollar last_recall ///
	last_noneduration last_breaks i.industry i.region_residence // I have not used i.month_of_job_loss and i.year_of_job_loss  yet


	
* Check the result
estimates store mymodel_4c
estimates table

* Compute hazard_ratio
predict lp, xb
gen hazard_ratio = exp(lp)

* Collapse data to get the mean hazard_ratio for each month_in_previous_job
collapse (mean) hazard_ratio, by(month_in_previous_job)


* Plot mean of hazard ratio by month_in_previous_job with two separate linear fits
twoway (scatter hazard_ratio month_in_previous_job, msize(small)) ///
       (lfit hazard_ratio month_in_previous_job if month_in_previous_job < 36, lcolor(red)) ///
       (lfit hazard_ratio month_in_previous_job if month_in_previous_job >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Selection on Observables") ///
    xlabel(12(6)60) ///
    ylabel(0.68(0.03)0.77) ///
    ytitle("Mean Predicted Hazard Ratios") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Linear Fit (Month < 36)" 3 "Linear Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(MeanHazardByMonth, replace)

* Export the graph
graph export "figure4c.png", replace




**************************generating figure 5a
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job >= 58 // Just like the domain in figure
gsort month_in_previous_job

* Exclude all observations with a nonemployment duratuion of more than 2 years (2*12*31 days). Also exclude if it is only 1 day
drop if noneduration > 2*12*31 // 2 years
drop if noneduration ==1

* Collapse data to get the mean age for each month_in_previous_job
collapse (mean) noneduration, by(month_in_previous_job)


* Plot mean of nonemployment duratuion by month_in_previous_job with two separate quadratic fits
twoway (scatter noneduration month_in_previous_job, msize(small)) ///
       (qfit noneduration month_in_previous_job if month_in_previous_job < 36, lcolor(red)) ///
       (qfit noneduration month_in_previous_job if month_in_previous_job >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Effect of Severance Pay on Nonemployment Durations") ///
    xlabel(12(6)60) ///
    ylabel(145(5)165) ///
    ytitle("Mean Nonemployment Duratuion (days)") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Q Fit (Month < 36)" 3 "Q Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(MeanNonedurationByMonth, replace)

* Export the graph
graph export "figure5a.png", replace
/// This figure was not very close to the original figure




**************************generating figure 5b
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job >= 58 // Just like the domain in figure
gsort month_in_previous_job


* Restricted samples
keep if month_employed_last_5_years - month_in_previous_job >=1


* Exclude all observations with a nonemployment duratuion of more than 2 years (2*12*31 days). Also exclude if it is only 1 day
drop if noneduration > 2*12*31 // 2 years
drop if noneduration ==1

* Collapse data to get the mean age for each month_in_previous_job
collapse (mean) noneduration, by(month_in_previous_job)


* Plot mean of nonemployment duratuion by month_in_previous_job with two separate quadratic fits
twoway (scatter noneduration month_in_previous_job, msize(small)) ///
       (qfit noneduration month_in_previous_job if month_in_previous_job < 36, lcolor(red)) ///
       (qfit noneduration month_in_previous_job if month_in_previous_job >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Effect of Severance Pay: Restricted Sample") ///
    xlabel(12(6)60) ///
    ylabel(140(5)160) ///
    ytitle("Mean Nonemployment Duratuion (days)") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Q Fit (Month < 36)" 3 "Q Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(MeanNonedurRestricted, replace)

* Export the graph
graph export "figure5b.png", replace





**************************generating figure 6a
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent


* Prepare other covariates
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)
//dummies fot J==13 to J==58
tabulate month_in_previous_job, generate(month_)
forval i = 13/58 {
    local j = `i' - 12  // Calculate the offset index since month_ starts at 13 but dummy starts at 1
    rename month_`j' J_`i'
}


* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox J_13-J_34 J_36-J_58 ///
	  E MW MW_2 MW_3 ///
	  MW_E MW_2_E MW_3_E

* Check the result
estimates store mymodel_6a
estimates table

* Store the results in matrices
matrix b = e(b)
matrix list b  // To see the stored coefficients

clear

set obs 46
gen month = 13
forval i = 1/45 {
    replace month = month[_n-1] + 1 if _n == `i' + 1
}
gen coefficient = .
matrix list b

* Assuming b[1,1] starts at month 13 and skips the reference category if any
forval i = 1/22 {
    local index = `i' + 1  // Adjust index if reference category is not the first one
    replace coefficient = b[1,`i'] if month == `i' + 12
}
forval i = 23/45 {
    local index = `i' + 1  // Adjust index if reference category is not the first one
    replace coefficient = b[1,`i'] if month == `i' + 13
}

* reference category:
replace coefficient = 0 if month == 35


* Plot Average Daily Job Finding Hazard by month_in_previous_job with two separate quadratic fits
twoway (scatter coefficient month, msize(small)) ///
       (qfit coefficient month if month < 36, lcolor(red)) ///
       (qfit coefficient month if month >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Effect of Severance Pay on Job Finding Hazards") ///
    xlabel(12(6)60) ///
    ylabel(-0.2(0.1)0.1) ///
    ytitle("Average Daily Job Finding Hazard in First 20 Weeks") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Q Fit (Month < 36)" 3 "Q Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(Hazard6a, replace)

* Export the graph
graph export "figure6a.png", replace




**************************generating figure 6b
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent


* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)
// Note: I am not sure that month_of_job_loss and year_of_job_loss are calculated correctly. Thus, I do not use these in my hazard model as covariates (unless I become sure).



* Prepare other covariates
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)
gen age_squared = age*age
gen wage = wage0/1000*12
gen log_wage = log(wage)
gen log_wage_squared = log(wage) * log(wage)
//dummies fot J==13 to J==58
tabulate month_in_previous_job, generate(month_)
forval i = 13/58 {
    local j = `i' - 12  // Calculate the offset index since month_ starts at 13 but dummy starts at 1
    rename month_`j' J_`i'
}


* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox J_13-J_34 J_36-J_58 ///
	  E MW MW_2 MW_3 ///
	  MW_E MW_2_E MW_3_E ///
	  female bluecollar married austrian age age_squared ///
	  log_wage log_wage_squared i.month_of_job_loss i.year_of_job_loss
	  

* Check the result
estimates store mymodel_6b
estimates table

* Store the results in matrices
matrix b = e(b)
matrix list b  // To see the stored coefficients

clear

set obs 46
gen month = 13
forval i = 1/45 {
    replace month = month[_n-1] + 1 if _n == `i' + 1
}
gen coefficient = .
matrix list b

* Assuming b[1,1] starts at month 13 and skips the reference category if any
forval i = 1/22 {
    local index = `i' + 1  // Adjust index if reference category is not the first one
    replace coefficient = b[1,`i'] if month == `i' + 12
}
forval i = 23/45 {
    local index = `i' + 1  // Adjust index if reference category is not the first one
    replace coefficient = b[1,`i'] if month == `i' + 13
}

* reference category:
replace coefficient = 0 if month == 35


* Plot Average Daily Job Finding Hazard by month_in_previous_job with two separate quadratic fits
twoway (scatter coefficient month, msize(small)) ///
       (qfit coefficient month if month < 36, lcolor(red)) ///
       (qfit coefficient month if month >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Job Finding Hazards Adjusted for Covariates") ///
    xlabel(12(6)60) ///
    ylabel(-0.2(0.1)0.1) ///
    ytitle("Average Daily Job Finding Hazard in First 20 Weeks") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Q Fit (Month < 36)" 3 "Q Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(Hazard6b, replace)

* Export the graph
graph export "figure6b.png", replace



**************************generating figure 6c
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent
gen S = (month_in_previous_job>=36)


* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)
// Note: I am not sure that month_of_job_loss and year_of_job_loss are calculated correctly. Thus, I do not use these in my hazard model as covariates (unless I become sure).


* Prepare other covariates
gen JT =  month_in_previous_job
gen JT_2 = JT * JT
gen JT_3 = JT * JT * JT
gen JT_S = S * (JT-36)
gen JT_2_S = S * (JT-36) * (JT-36)
gen JT_3_S = S * (JT-36) * (JT-36) * (JT-36)
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)
//end of job tenure: Equals 1 in the three months before the end of each tenure year (21-23, 33-35, 45-47, and 57-59)
gen end_of_job_tenure = 0
replace end_of_job_tenure = 1 if month_in_previous_job>=21 & month_in_previous_job<=23
replace end_of_job_tenure = 1 if month_in_previous_job>=33 & month_in_previous_job<=35
replace end_of_job_tenure = 1 if month_in_previous_job>=45 & month_in_previous_job<=47
replace end_of_job_tenure = 1 if month_in_previous_job>=57 & month_in_previous_job<=59


* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox end_of_job_tenure S E ///
	  JT JT_2 JT_3 ///
	  JT_S JT_2_S JT_3_S ///
	  MW MW_2 MW_3 ///
	  MW_E MW_2_E MW_3_E

	  
	  
* Check the result
estimates store mymodel_6a
estimates table

* Coeficient estimate on the indicator is: .01721218 (change it for new code or new data). Now we repeat every thing done in 6a again
***********************still in 6c
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent


* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)
// Note: I am not sure that month_of_job_loss and year_of_job_loss are calculated correctly. Thus, I do not use these in my hazard model as covariates (unless I become sure).



* Prepare other covariates
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)
gen age_squared = age*age
gen wage = wage0/1000*12
gen log_wage = log(wage)
gen log_wage_squared = log(wage) * log(wage)
//dummies fot J==13 to J==58
tabulate month_in_previous_job, generate(month_)
forval i = 13/58 {
    local j = `i' - 12  // Calculate the offset index since month_ starts at 13 but dummy starts at 1
    rename month_`j' J_`i'
}


* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox J_13-J_34 J_36-J_58 ///
	  E MW MW_2 MW_3 ///
	  MW_E MW_2_E MW_3_E ///
	  female bluecollar married austrian age age_squared ///
	  log_wage log_wage_squared i.month_of_job_loss i.year_of_job_loss
	  

* Check the result
estimates store mymodel_6b
estimates table

* Store the results in matrices
matrix b = e(b)
matrix list b  // To see the stored coefficients

clear

set obs 46
gen month = 13
forval i = 1/45 {
    replace month = month[_n-1] + 1 if _n == `i' + 1
}
gen coefficient = .
matrix list b

* Assuming b[1,1] starts at month 13 and skips the reference category if any
forval i = 1/22 {
    local index = `i' + 1  // Adjust index if reference category is not the first one
    replace coefficient = b[1,`i'] if month == `i' + 12
}
forval i = 23/45 {
    local index = `i' + 1  // Adjust index if reference category is not the first one
    replace coefficient = b[1,`i'] if month == `i' + 13
}

* reference category:
replace coefficient = 0 if month == 35


* adjusting seasonality (Note that .01721218 can be different for each new data and should be adjusted each time!)
replace coefficient = coefficient - .01721218 if ///
		inlist(_n, 21-12, 22-12, 23-12, 33-12, 34-12, 35-12, 45-12, 46-12, 47-12, 57-12, 58-12, 59-12)



* Plot Average Daily Job Finding Hazard by month_in_previous_job with two separate quadratic fits
twoway (scatter coefficient month, msize(small)) ///
       (qfit coefficient month if month < 36, lcolor(red)) ///
       (qfit coefficient month if month >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Effect of Severance Pay Adjusted for Tenure Seasonality") ///
    xlabel(12(6)60) ///
    ylabel(-0.2(0.1)0.1) ///
    ytitle("Average Daily Job Finding Hazard in First 20 Weeks") ///
    xtitle("Previous Job Tenure (Months)") ///
    legend(order(1 "Age" 2 "Q Fit (Month < 36)" 3 "Q Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(Hazard6c, replace)

* Export the graph
graph export "figure6c.png", replace



**************************generating figure 7
use "merged_data.dta", clear

* Sort the data by penr in ascending order and then by file in descending order
gsort penr -file

* Keeping individuals who have more than 1 unemployment spell
bysort penr: egen file_count = count(file)
keep if file_count > 1
drop file_count

* Now keep the highest file observation for each penr
by penr: keep if _n == 1 | _n ==2


gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job >= 58 // Just like the domain in figure

* Restricted samples
keep if month_employed_last_5_years - month_in_previous_job >=1


* Exclude all observations with a nonemployment duratuion of more than 2 years (2*12*31 days). Also exclude if it is only 1 day
drop if noneduration > 2*12*31 // 2 years
drop if noneduration == 1


* Clear previous by-group settings
bysort penr: gen first_month_in_previous_job = month_in_previous_job if _n == 2
bysort penr: gen second_noneduration = noneduration if _n == 1

* Carry forward these values to use them in the calculations
by penr: egen min_first_month_in_previous_job = min(first_month_in_previous_job)
by penr: egen max_second_noneduration = max(second_noneduration)

* Keep only unique records for each person
bysort penr: keep if _n == 1


* Collapse the data to get the mean of second_noneduration for each first_month_in_previous_job
collapse (mean) max_second_noneduration, by(min_first_month_in_previous_job)


* Plotting the mean of second noneduration for each value of first month_in_previous_job
twoway (scatter max_second_noneduration min_first_month_in_previous_job, msize(small)) ///
       (qfit max_second_noneduration min_first_month_in_previous_job if min_first_month_in_previous_job < 36, lcolor(red)) ///
       (qfit max_second_noneduration min_first_month_in_previous_job if min_first_month_in_previous_job >= 36, lcolor(green)), ///
       xline(35.5, lcolor(red)) ///
    title("Placebo Test: Lagged Job Tenure and Nonemployment Durations", size(medium)) ///
    xlabel(12(6)60) ///
    ylabel(145(5)170, labsize(vsmall)) ///
    ytitle("Mean Nonemployment Duratuion (days)", size(small)) ///
    xtitle("Previous Job Tenure (Months)", size(small)) ///
    legend(order(1 "Age" 2 "Q Fit (Month < 36)" 3 "Q Fit (Month >= 36)" 4 "Cutoff at Month 36")) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(MeanNonedurRestricted, replace)

* Export the graph
graph export "figure7.png", replace



**************************end of figures
**************************table 2

//Column 1:
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* Restricted samples
keep if month_employed_last_5_years - month_in_previous_job >=1

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent
gen S = (month_in_previous_job>=36)

* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)


* Prepare other covariates
gen JT =  month_in_previous_job
gen JT_2 = JT * JT
gen JT_3 = JT * JT * JT
gen JT_S = S * (JT-36)
gen JT_2_S = S * (JT-36) * (JT-36)
gen JT_3_S = S * (JT-36) * (JT-36) * (JT-36)
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)



* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox S JT JT_2 JT_3 ///
	  JT_S JT_2_S JT_3_S ///
	  , nohr
	  

* Check the result
estimates store mymodel_column1
estimates table

estimates use mymodel_column1
display "Sample size: " e(N)



//Column 2:
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* Restricted samples
keep if month_employed_last_5_years - month_in_previous_job >=1

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent
gen S = (month_in_previous_job>=36)

* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)


* Prepare other covariates
gen JT =  month_in_previous_job
gen JT_2 = JT * JT
gen JT_3 = JT * JT * JT
gen JT_S = S * (JT-36)
gen JT_2_S = S * (JT-36) * (JT-36)
gen JT_3_S = S * (JT-36) * (JT-36) * (JT-36)
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)



* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox E MW MW_2 MW_3 ///
	  MW_E MW_2_E MW_3_E, nohr
	  

* Check the result
estimates store mymodel_column2
estimates table



//Column 3:
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* We have full samples

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent
gen S = (month_in_previous_job>=36)

* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)


* Prepare other covariates
gen JT =  month_in_previous_job
gen JT_2 = JT * JT
gen JT_3 = JT * JT * JT
gen JT_S = S * (JT-36)
gen JT_2_S = S * (JT-36) * (JT-36)
gen JT_3_S = S * (JT-36) * (JT-36) * (JT-36)
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)
gen age_squared = age*age
gen wage = wage0/1000*12
gen log_wage = log(wage)
gen log_wage_squared = log(wage) * log(wage)



* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox S E ///
	  JT JT_2 JT_3 ///
	  JT_S JT_2_S JT_3_S ///
	  MW MW_2 MW_3 ///
	  MW_E MW_2_E MW_3_E, nohr
	  

* Check the result
estimates store mymodel_column3
estimates table



//Column 4:
use "highest_file_per_penr.dta", clear
gen month_in_previous_job = floor(duration / 31)
gen month_employed_last_5_years = floor(dempl5 / 31)

drop if month_in_previous_job <= 12 | month_in_previous_job > 58 // based on specification of eq (14) 
gsort month_in_previous_job

* We have full samples

* S: eligibility for severance pay
* E: eligibility for extended benefits
//We have E: eligible30. We also compute it by column month_employed_last_5_years and drop inconsistent result
gen E = (month_employed_last_5_years>=36)
keep if E == eligible30 // about 7000 observations are inconsistent
gen S = (month_in_previous_job>=36)

* Compute  month_of_job_loss and year_of_job_loss
egen min_startdate = min(ustart) // We set it for our first day
gen day_nonemployment = ustart - min_startdate
gen year_of_job_loss = floor(day_nonemployment/12/31)
gen month_of_job_loss = floor(mod(day_nonemployment, 12*31) /31)


* Prepare other covariates
gen JT =  month_in_previous_job
gen JT_2 = JT * JT
gen JT_3 = JT * JT * JT
gen JT_S = S * (JT-36)
gen JT_2_S = S * (JT-36) * (JT-36)
gen JT_3_S = S * (JT-36) * (JT-36) * (JT-36)
gen MW = month_employed_last_5_years
gen MW_2 = MW * MW
gen MW_3 = MW * MW * MW
gen MW_E = E * (MW-36)
gen MW_2_E = E * (MW-36) * (MW-36)
gen MW_3_E = E * (MW-36) * (MW-36) * (MW-36)
gen age_squared = age*age
gen wage = wage0/1000*12
gen log_wage = log(wage)
gen log_wage_squared = log(wage) * log(wage)



* Fit Cox proportonal hazard model
gen status = 1
replace status = 0 if noneduration >= 140
stset noneduration, failure(status==1)

stcox S E ///
	  JT JT_2 JT_3 ///
	  JT_S JT_2_S JT_3_S ///
	  MW MW_2 MW_3 ///
	  MW_E MW_2_E MW_3_E ///
	  female bluecollar married austrian age age_squared ///
	  log_wage log_wage_squared i.month_of_job_loss i.year_of_job_loss ///
	  , nohr
	  
	  

* Check the result
estimates store mymodel_column4
estimates table


*Table 2 can be derived complitely now.




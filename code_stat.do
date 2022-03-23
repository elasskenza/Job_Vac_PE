cd "C:\Users\elass.k\Nextcloud2\Job_vac_Pole_emploi\same"


local vac=2012
while `vac'<=2021{
	
import sas using "offres_`vac'.sas7bdat", clear

	rename *, lower
	keep salmenest trcsalsta trimstat idtpof
	replace salmenest=. if salmenest==0
	gen miss_sal=missing(salmenest)
	gen year=`vac'
	duplicates drop *, force
	duplicates tag idtpof trimstat, gen(nb)
	tab nb
	/* No driven by duplicates */
	bys  trimstat: gen freq_vac_trim=_N
	bys trimstat miss_sal: gen freq_miss=_N 
	replace freq_miss=. if miss_sal==0
	bys trimstat: egen freq_miss_all=max(freq_miss)
	bys trimstat: egen freq_vac_all=max(freq_vac_trim)
	bys trimstat: gen percent_miss=freq_miss_all/freq_vac_all
	keep year trimstat percent_miss freq_vac_all freq_miss_all
	duplicates drop *, force
	save C:\Users\elass.k\Nextcloud2\Job_vac_PE\vac_`vac'.dta, replace	
		
local vac=`vac'+1
}


****************


clear *

cd "C:\Users\elass.k\Nextcloud2\Job_vac_PE"

use "vac_2012.dta", clear

local vac=2013
while `vac'<=2021{
	append using vac_`vac'.dta
local vac=`vac'+1
}

gen yq = yq(year, trimstat)
format yq %tq

replace percent_miss=percent_miss*100

twoway line  percent_miss yq, xtitle("Year - quarter") ytitle("% of missing wages in vac") ylabel(0(5)70) xlabel(208(4)248) xline(221, lwidth(thin) lcolor(red))
	graph export "C:\Users\elass.k\Nextcloud2\Job_vac_PE\Percent_miss.png", as(png) width(1000) height(600) replace

twoway (line freq_vac_all yq, color(plr1) legend(label( 1 "Total number of vacancies") position(6)) ) (line freq_miss_all yq,color (plb1) legend(label( 2 "Number of missing wages in vacancies") position(6) col(2))) ,  xtitle("Year - quarter") ytitle("Number of vacancies and missing wages") ylabel(0(100000)800000)  xlabel(208(8)248) xline(221, lwidth(thin) lcolor(red))
	graph export "C:\Users\elass.k\Nextcloud2\Job_vac_PE\num_vac.png", as(png) width(1000) height(600) replace
	
save "C:\Users\elass.k\Nextcloud2\Job_vac_PE\all_stat.dta", replace	
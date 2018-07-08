** CRRC Blog -- What predicts foreign policy preferences in Georgia?   
** Caucasus Barometer 2017 - Georgia
** http://caucasusbarometer.org/en/cb2017ge/codebook/
///////////////////////////////////////////////////////////////////////////////

clear all
use "CB_2017_Georgia_public_17.11.17.dta" 

// Recode

** stratum
recode STRATUM(1=2 "Capital")(2=1 "Urban")(3=3 "Rural"), gen(stra)
lab var stra "Settlement type"

** gender
recode RESPSEX (1=0 "Male")(2=1 "Female"), gen(female)
lab var female "Gender"

** age groups
recode AGE (18/37=1 "18-37")(38/57=2 "38-57")(58/100=3 ">58"), gen(agegr20)
lab var agegr20 "Age groups {1=58/100}"

gen age=AGE
lab var age "Age"

** education
recode RESPEDU (1/5=0 "Less than tertiary")(6/8=1 "Tertiary")(else=.), gen(persedu)
lab var persedu "Highest level of education achieved"

gen edu=EDUYRS
mvdecode edu, mv(-9/-1)
lab var edu "Education (years)"

** employment
recode EMPLSIT (1/4 7/8=0 "No")(5/6=1 "Yes")(else=.), gen(emplsit)
lab var emplsit "Employed?"

gen empl=.
replace empl=3 if emplsit==1
replace empl=2 if emplsit==0 & INTSTJOB==1&JOBSTART==1
replace empl=1 if emplsit==0 & (INTSTJOB==-2|INTSTJOB==-1|INTSTJOB==0|JOBSTART==-2|JOBSTART==-1|JOBSTART==0)
lab var empl "Employment status"
lab define empl 1 "No labor force" 2 "Unemployed" 3 "Employed"
lab values empl empl

** Current standing of the HH
gen currung10=CURRUNG
replace currung10=. if CURRUNG==-9|CURRUNG==-3|CURRUNG==-2|CURRUNG==-1
lab var currung10 "Current HH rung"

** debts
recode FOODDBT (1/4=1)(5=0)(else=.), gen(fooddbt)	
lab var fooddbt "HH borrowed money to buy food? {0=never}"
recode UTILDBT (1/4=1)(5=0)(else=.), gen(utildbt)	
lab var utildbt "HH borrowed money to pay for utilities? {0=never}"

gen borrow=.
replace borrow=1 if fooddbt==1|utildbt==1
replace borrow=0 if fooddbt==0&utildbt==0
lab var borrow "Has HH borrowed money?"
lab define borrow 0 "Not borrowed" 1 "Borrowed"
lab values borrow borrow

** income and expenditure
recode MONYTOT(-2/-1=1 "DK/RA")(5/8=2 "<$250")(4=3 "$251-$400")(1/3=4 ">$400")(else=.), gen(monytot)
recode SPENDMO(-2/-1=1 "DK/RA")(5/8=2 "<$250")(4=3 "$251-$400")(1/3=4 ">$400")(else=.), gen(spendmo)
recode PERSINC(-2/-1=1 "DK/RA")(5/8=2 "<$250")(4=3 "$251-$400")(1/3=4 ">$400")(else=.), gen(persinc)
lab var persinc "Personal income"
lab var monytot "HH income"
lab var spendmo	"HH spending"

** internet use
recode FRQINTR(1/4=1 "Yes")(-1 5 6=0 "No")(else=.), gen(inter)
lab var inter "Do you use the internet?"

** attitude to government
recode GOVTROL (1 2 -1 5=0 "Parent")(3 4=1 "Employee")(else=.), gen(govatt)
lab var govatt "Government as a parent VS Government as an employee"

******************************************************************************

** recode democracy questions

recode CNTRDEM (3/4=4 "A democracy")(2=3 "A democracy w major problems")(1=2 "Not a democracy")(-1=1 "DK")(else=.), gen(demoge)
lab var demoge "How much of a democracy is Georgia today?"

recode ATTDEM(1=4 "Democracy prefearable")(2=3 "Nondemocracy acceptable")(3=2 "It does not matter")(-1=1 "DK")(else=.), gen(demo4)
lab var demo4 "Attitudes to democracy"

recode ATTDEM(1=3 "Democracy prefearable")(2/3=2 "It does not matter")(-1=1 "DK")(else=.), gen(demo3)
lab var demo3 "Attitudes to democracy"

recode ATTDEM(1=1 "Democracy prefearable")(-1 2 3=0 "It does not matter")(else=.), gen(demo2)
lab var demo2 "Attitudes to democracy"

** recode EU/EEU support

recode EUSUPP(1/2=3 "Don't support")(3=2 "Neutral")(4/5=1 "Support")(-1=4 "DK")(else=.), gen(eu)
//recode p28_geo(1/2=3 "Don't support")(3=2 "Neutral")(4/5=1 "Support")(-1=4 "DK")(else=.), gen(eeu)
lab var eu "Support Georgia's membership in the EU?"
//lab var eeu "Support Georgia's membership in the EEU?"

** recode RAND questions on neutrality

recode RAND1(1/2=1 "Detrimental")(-1 3 4=0 "Not detrimental")(else=.), gen(rand1_r)
lab var rand1_r "Tensions between Russia and the West are detrimental to country"

recode RAND2(1/2=1 "Neutrality")(-1 3 4=0 "No neutrality")(else=.), gen(rand2_r)
lab var rand2_r "Neutrality VS Alignment with a block"

recode RAND3G(2=1 "EU")(1=2 "EEU")(3=3 "Both") (4=4 "None")(-1=5 "DK")(else=.), gen(rand3_r)
lab var rand3_r "What would be the best choice for future development of Georgia?"

recode RAND4G(2=1 "NATO")(1=2 "CTO")(3=3 "Both") (4=4 "None")(-1=5 "DK")(else=.), gen(rand4_r)
lab var rand4_r "What would be the best choice for Georgia to ensure its security?"

recode RAND5(-1=6 "DK")(-9/-2=.), gen(rand5_r)
lab var rand5_r "Which of the following countries should be the model for country?"


*******************************************************************************
order ID STRATUM stra age agegr20 female ///
emplsit ///
empl ///
edu ///
persedu ///
currung10  ///
borrow ///
monytot ///
spendmo ///
persinc ///
inter ///
govatt ///
demoge demo* ///
eu ///
rand*


// MODELS
////////////////////////////////////////////////////////////////////////////////

svyset PSU [pweight=INDWT], strata(SUBSTRATUM) fpc(NPSUSS) singleunit(certainty) || ID, fpc(NHHPSU) || _n, fpc(NADHH)

** Chart 1. Predicted probabilities -- RAND1 (Tensions btw Russia and the West detrimental)
*******************************************************************************************

** EU vs EAEU
qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand1_r, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand1_r, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand1_r, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand1_r, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins rand1_r, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(EU) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(EAEU) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(EU, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("Tensions detrimental?") ///
graphregion(color(white)) ///
order(1.rand1_r 0.rand1_r) ///
coeflabels(1.rand1_r="Yes" 0.rand1_r="No", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("EU vs EAEU", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

** NATO vs CSTO
qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand1_r, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand1_r, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand1_r, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand1_r, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins rand1_r, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(NATO) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(CSTO) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(NATO, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("") ///
graphregion(color(white)) ///
order(1.rand1_r 0.rand1_r) ///
coeflabels(1.rand1_r="Yes" 0.rand1_r="No", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("NATO vs CSTO", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

graph combine EU NATO, ///
title("What would be the best choice for Georgia?", color(dknavy*.9) tstyle(size(large)) span) ///
subtitle("Predicted probabilities, 95% Confidence Intervals" "CRRC Caucasus Barometer 2017, Georgia", color(dknavy*.8) tstyle(size(msmall)) span) ///
graphregion(color(white))

graph export "Chart_1_GE.png", width(3000) replace

** Chart 2. Marginal effects of support to democracy
*******************************************************************************

** EU vs EAEU
qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins demo2, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins demo2, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins demo2, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins demo2, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins demo2, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(EU) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(EAEU) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(EU, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("Support democracy?") ///
graphregion(color(white)) ///
order(1.demo2 0.demo2) ///
coeflabels(1.demo2="Yes" 0.demo2="No", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("EU vs EAEU", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

** NATO vs CSTO
qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins demo2, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins demo2, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins demo2, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins demo2, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins demo2, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(NATO) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(CSTO) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(NATO, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("Support democracy?") ///
graphregion(color(white)) ///
order(1.demo2 0.demo2) ///
coeflabels(1.demo2="Yes" 0.demo2="No", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("NATO vs CSTO", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

graph combine EU NATO, ///
title("What would be the best choice for Georgia?", color(dknavy*.9) tstyle(size(large)) span) ///
subtitle("Predicted probabilities, 95% Confidence Intervals" "CRRC Caucasus Barometer 2017, Georgia", color(dknavy*.8) tstyle(size(msmall)) span) ///
graphregion(color(white))

graph export "Chart_2_GE.png", width(3000) replace


** Additional charts
*******************************************************************************

** Chart 3. Predicted probabilities -- RAND2 (Neutrality vs alignment)
*******************************************************************************

** EU vs EAEU
qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand2_r, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand2_r, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand2_r, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand2_r, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins rand2_r, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(EU) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(EAEU) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(EU, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("") ///
graphregion(color(white)) ///
order(1.rand2_r 0.rand2_r) ///
coeflabels(1.rand2_r="Neutrality" 0.rand2_r="No neutrality", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("EU vs EAEU", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

** NATO vs CSTO
qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand2_r, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins rand2_r, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand2_r, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins rand2_r, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins rand2_r, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(NATO) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(CSTO) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(NATO, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("") ///
graphregion(color(white)) ///
order(1.rand2_r 0.rand2_r) ///
coeflabels(1.rand2_r="Neutrality" 0.rand2_r="No neutrality", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("NATO vs CSTO", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

graph combine EU NATO, ///
title("What would be the best choice for Georgia?", color(dknavy*.9) tstyle(size(large)) span) ///
subtitle("Predicted probabilities, 95% Confidence Intervals" "CRRC Caucasus Barometer 2017, Georgia", color(dknavy*.8) tstyle(size(msmall)) span) ///
graphregion(color(white))

graph export "Chart_3_GE.png", width(3000) replace

** Chart 4. Marginal effects of attitudes to government
*******************************************************************************

** EU vs EAEU
qui svy: mlogit rand3_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins govatt, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand3_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins govatt, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand3_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins govatt, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand3_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins govatt, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand3_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins govatt, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(EU) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(EAEU) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(EU, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("Government is people's ...") ///
graphregion(color(white)) ///
order(1.govatt 0.govatt) ///
coeflabels(1.govatt="Employee" 0.govatt="Parent", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("EU vs EAEU", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

** NATO vs CSTO
qui svy: mlogit rand4_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins govatt, predict(outcome(1)) post
estimates store m1

qui svy: mlogit rand4_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2) 
qui: margins govatt, predict(outcome(2)) post
estimates store m2

qui svy: mlogit rand4_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins govatt, predict(outcome(3)) post
estimates store m3

qui svy: mlogit rand4_r i.govatt i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
qui: margins govatt, predict(outcome(4)) post
estimates store m4

//qui svy: mlogit rand4_r i.demo2 i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo i.borrow i.rand1_r i.rand2_r, base (2)
//qui: margins govatt, predict(outcome(5)) post
//estimates store m5

coefplot ///
(m1, label(NATO) lpatt(solid)lcol(ebblue)msym(T)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue)lwidth(medthick))) ///
(m2, label(CSTO) lpatt(solid)lcol(maroon)msym(D)mcol(maroon)ciopts(lpatt(solid)lcol(maroon)lwidth(medthick))) ///
(m3, label(Both) lpatt(solid)lcol(lavender)msym(S)mcol(lavender)ciopts(lpatt(solid)lcol(lavender)lwidth(medthick))) ///
(m4, label(None) lpatt(solid)lcol(sand)msym(O)mcol(sand)ciopts(lpatt(solid)lcol(sand)lwidth(medthick))), ///
name(NATO, replace) ///
nobaselevels drop(_cons) ///
mlabel format(%12.2f) mlabposition(12) mlabgap(*2) ///
xlabel(none) ///
xtitle("Probability") levels(95) ///
ytitle("Government is people's ...") ///
graphregion(color(white)) ///
order(1.govatt 0.govatt) ///
coeflabels(1.govatt="Employee" 0.govatt="Parent", ///
wrap(30) notick labcolor(black*.8) labsize(small) labgap(2)) /// 
title("NATO vs CSTO", color(dknavy*.9) tstyle(size(medium))) ///
subtitle("", color(dknavy*.8) tstyle(size(medium))) ///
legend(pos(6) rows(1) width(100))

graph combine EU NATO, ///
title("What would be the best choice for Georgia?", color(dknavy*.9) tstyle(size(large)) span) ///
subtitle("Predicted probabilities, 95% Confidence Intervals" "CRRC Caucasus Barometer 2017, Georgia", color(dknavy*.8) tstyle(size(msmall)) span) ///
graphregion(color(white))

graph export "Chart_4_GE.png", width(3000) replace

************************************************************************************

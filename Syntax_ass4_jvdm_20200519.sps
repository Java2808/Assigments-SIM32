* Encoding: UTF-8.

* Dataset A

FREQUENCIES VARIABLES=pain sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /ORDER=ANALYSIS.

MIXED pain BY sex WITH age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED RESID.

DESCRIPTIVES VARIABLES=FXPRED_1
  /STATISTICS=MEAN STDDEV VARIANCE MIN MAX.

* Dataset B

DATASET ACTIVATE DataSet4.
RECODE sex ('male'=0) ('female'=1) (MISSING=SYSMIS) INTO Female.
EXECUTE.

COMPUTE predictfromA=2.56 - 0.19 * Female - 0.03 * age - 0.02 * STAI_trait + 0.06 * pain_cat + 0.23 
    * cortisol_serum + 0.46 * cortisol_saliva - 0.22 * mindfulness.
EXECUTE.

Square of residuals dataset A

DATASET ACTIVATE DataSet3.
COMPUTE Resqare=RESID_1 * RESID_1.
EXECUTE.

* res sum of squares

DATASET ACTIVATE DataSet4.
COMPUTE res_ssq=(pain - predictfromA) * (pain - predictfromA).
EXECUTE.

* rename res_ssq into res_sq
* Get the mean for pain in dataset B en compute pain - mean

DESCRIPTIVES VARIABLES=pain
  /STATISTICS=MEAN.

COMPUTE tss_sq=(pain - 5.2) * (pain - 5.2).
EXECUTE.

* rest is manually
* Now I see that I shouldn't have taken cortison saliva, do everything again

DATASET ACTIVATE DataSet3.
MIXED pain BY sex WITH age STAI_trait pain_cat cortisol_serum mindfulness
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=sex age STAI_trait pain_cat cortisol_serum mindfulness | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED RESID.

DESCRIPTIVES VARIABLES=FXPRED_2
  /STATISTICS=MEAN STDDEV VARIANCE MIN MAX.

DATASET ACTIVATE DataSet4.
COMPUTE predictfromA=3.80 - 0.30 * Female - 0.05 * age + 0.001 * STAI_trait + 0.04 * pain_cat + 
    0.61 * cortisol_serum - 0.26 * mindfulness.
EXECUTE.

COMPUTE res_sq=(pain - predictfromA) * (pain - predictfromA).
EXECUTE.

DESCRIPTIVES VARIABLES=res_sq tss_sq
  /STATISTICS=SUM.

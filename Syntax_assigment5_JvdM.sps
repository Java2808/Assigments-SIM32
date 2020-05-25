* Encoding: UTF-8.
* Recoding

DATASET ACTIVATE DataSet6.
RECODE sex ('male'=0) ('female'=1) INTO female.
EXECUTE.

*restructured data

* random intercept model

MIXED pain WITH age female STAI_trait pain_cat cortisol_serum mindfulness time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age female STAI_trait pain_cat cortisol_serum mindfulness time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED RESID.

* random slope model


MIXED pain WITH age female STAI_trait pain_cat cortisol_serum mindfulness time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age female STAI_trait pain_cat cortisol_serum mindfulness time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED RESID.

* Warning in output: Warnings:
* Iteration was terminated but convergence has not been achieved. The MIXED procedure continues despite this warning. Subsequent results produced are based on the last iteration. Validity of the model fit is uncertain.


MIXED pain WITH age female STAI_trait pain_cat cortisol_serum mindfulness time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age female STAI_trait pain_cat cortisol_serum mindfulness time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(ID)
  /SAVE=PRED RESID.

* Plot pain ratings (y) over time (x) for each participant separately, separate lines for observed pain, pred intercept, pred slope

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time pain data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: pain=col(source(s), name("pain"), unit.category())
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line of pain by time by data_type"))
  ELEMENT: line(position(time*pain), color.interior(data_type), missing.wings())
END GPL.


SPLIT FILE OFF.


DATASET ACTIVATE DataSet9.
COMPUTE time_squared=time * time.
EXECUTE.

* New random intercept model with time squared

MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness female time time_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness female time time_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(ID)
  /SAVE=PRED RESID.

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

* Compare pain and predicted pain graphs


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time pain data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: pain=col(source(s), name("pain"), unit.category())
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line of pain by time by data_type"))
  ELEMENT: line(position(time*pain), color.interior(data_type), missing.wings())
END GPL.

SPLIT FILE OFF.

* diagnostics


SPLIT FILE OFF.

SAVE OUTFILE='C:\Users\janet\OneDrive - Lund University\Courses\Quantitative '+
    'methods\Multivariate\Databases\lab_5_assignment_JM_timesquare2_dataset.sav'
  /COMPRESSED.
GET
  FILE='C:\Users\janet\OneDrive - Lund University\Courses\Quantitative methods\Multivariate\Createddatabases\lab_5_assignment_JM_timesquare_dataset.sav'.
DATASET NAME DataSet12 WINDOW=FRONT.


DATASET ACTIVATE DataSet12.


* Influential outliers

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time pain ID MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: pain=col(source(s), name("pain"), unit.category())
  DATA: ID=col(source(s), name("ID"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("ID"))
  GUIDE: text.title(label("Multiple Line of pain by time by ID"))
  ELEMENT: line(position(time*pain), color.interior(ID), missing.wings())
END GPL.

EXAMINE VARIABLES=pain BY ID
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*One outlier:ID_11

* Linearity

GRAPH
  /SCATTERPLOT(BIVAR)=PRED_rndint_tsq WITH RESID_rndint_tsq
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=time_squared WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=age WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=STAI_trait WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=pain_cat WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=mindfulness WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=time WITH pain
  /MISSING=LISTWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=time_squared WITH pain
  /MISSING=LISTWISE.

*No problems with linearity
* Normality (before looking at ex 20, see later for new test)

EXAMINE VARIABLES=RESID_rndint_tsq
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* no problems with normality

* multicollinearity

CORRELATIONS
  /VARIABLES=age STAI_trait pain_cat cortisol_serum mindfulness female time_squared
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* No problems with multicollinearity

* test model with centering time and square


DESCRIPTIVES VARIABLES=time
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE time_centered=time - 2.50.
EXECUTE.

COMPUTE time_centered_square=time_centered * time_centered.
EXECUTE.


MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness female time_centered 
    time_centered_square
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness female time_centered 
    time_centered_square | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED RESID.


* Graphs with pain and all predicted values from three models (observed pain, predicted from random intercept, from random slope and from random intercept time_square

DATASET ACTIVATE DataSet13.

* Plottint the three models for each participant

DATASET ACTIVATE DataSet12.
SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time pain data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: pain=col(source(s), name("pain"), unit.category())
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line of pain by time by data_type"))
  ELEMENT: line(position(time*pain), color.interior(data_type), missing.wings())
END GPL.

* Run the final model again

GET
  FILE='C:\Users\janet\OneDrive - Lund University\Courses\Quantitative methods\Multivariate\Createddatabases\lab_5_assignment_JM_timesquare_dataset.sav'.
DATASET NAME DataSet14 WINDOW=FRONT.
DATASET ACTIVATE DataSet12.
DATASET ACTIVATE DataSet12.

SAVE OUTFILE='C:\Users\janet\OneDrive - Lund University\Courses\Quantitative '+
    'methods\Multivariate\Createddatabases\lab_5_assignment_JM_timesquare_datatype_dataset.sav'
  /COMPRESSED.
DATASET ACTIVATE DataSet14.
DATASET CLOSE DataSet12.
MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness female time time_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1)
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness female time time_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(ID)
  /SAVE=PRED RESID.


*normality according ex 20 (the earlier test I did before lab 25-05)

MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness female time time_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1)
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness female time time_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC) SOLUTION
 
* Make new dataset and paste values predictions.

DATASET ACTIVATE DataSet15.
EXAMINE VARIABLES=VAR00001
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* heteroscedasticity (squared of residuals is computed earlier), checking for constant variance of residuals across clusters

DATASET ACTIVATE DataSet14.
SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Res_squared_rndint_tsq
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 ID_dummy_8 
    ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 ID_dummy_16 
    ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20.


* See if homoscedasticity disappears with omitting the outlier from the analysis

USE ALL.
COMPUTE filter_$=(ID ~= "ID_11").
VARIABLE LABELS filter_$ 'ID ~= "ID_11" (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Res_squared_rndint_tsq
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 ID_dummy_8 
    ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 ID_dummy_16 
    ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20.

* Correlations again

CORRELATIONS
  /VARIABLES=age STAI_trait pain_cat cortisol_serum mindfulness female time pain time_squared
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* There is high correlation between time and time squared of course.
* Select all cases again

FILTER OFF.
USE ALL.
EXECUTE.

* Centering is done earlier

CORRELATIONS
  /VARIABLES=age STAI_trait pain_cat cortisol_serum mindfulness female pain time_centered 
    time_centered_square
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* Random intercept model with time centered square

MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness female time_centered 
    time_centered_square
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness female time_centered 
    time_centered_square | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC).





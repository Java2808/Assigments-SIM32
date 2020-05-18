* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=Survived Pclass Sex Age SibSp Parch Embarked
  /ORDER=ANALYSIS.

RECODE Sex ('male'=0) ('female'=1) (MISSING=SYSMIS) INTO Female.
EXECUTE.

RECODE Embarked (MISSING=SYSMIS) ('C'=0) ('Q'=0) ('S'=1) INTO Embarked_rec.
EXECUTE.

DESCRIPTIVES VARIABLES=Age
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=Age
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass COUNT()[name="COUNT"] Survived
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Pclass by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Pclass*COUNT), color.interior(Survived),
    shape.interior(shape.square))
END GPL.

* Rename embarked_rec to Southampton

* Chart Builder.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Southampton COUNT()[name="COUNT"] Survived
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Southampton=col(source(s), name("Southampton"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Southampton"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Southampton by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Southampton*COUNT), color.interior(Survived),
    shape.interior(shape.square))
END GPL.


* Correlations

CORRELATIONS
  /VARIABLES=Survived Pclass Age SibSp Parch Female Southampton
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* Recoding

RECODE SibSp (0=0) (1=1) (MISSING=SYSMIS) (2 thru Highest=2) INTO Sibspouse_binned.
EXECUTE.

RECODE Parch (0=0) (1=1) (MISSING=SYSMIS) (2 thru Highest=2) INTO Parch_binned.
EXECUTE.
RECODE SibSp (0=0) (1=1) (MISSING=SYSMIS) (2 thru Highest=2) INTO Sibspouse_binned.
RECODE Parch (0=0) (1=1) (MISSING=SYSMIS) (2 thru Highest=2) INTO Parch_binned.

* Check interaction effect of sibspouse on relation age and survival

UNIANOVA Age BY Survived Sibspouse_binned
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(Sibspouse_binned*Survived) TYPE=LINE ERRORBAR=NO MEANREFERENCE=NO YAXIS=AUTO
  /CRITERIA=ALPHA(0.05)
  /DESIGN=Survived Sibspouse_binned Survived*Sibspouse_binned.


* Check interaction effect of parch on relation age and survival

UNIANOVA Age BY Survived Parch_binned
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(Parch_binned*Survived) TYPE=LINE ERRORBAR=NO MEANREFERENCE=NO YAXIS=AUTO
  /CRITERIA=ALPHA(0.05)
  /DESIGN=Survived Parch_binned Survived*Parch_binned.


* Run log regression

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Pclass Age Female Southampton Sibspouse_binned Parch_binned
  /CONTRAST (Pclass)=Indicator
  /CONTRAST (Sibspouse_binned)=Indicator
  /CONTRAST (Parch_binned)=Indicator
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).



RECODE Pclass (MISSING=SYSMIS) (1=0) (2=1) (3=0) INTO Secondclass.
EXECUTE.

RECODE Pclass (MISSING=SYSMIS) (1=0) (3=1) (2=0) INTO Thirdclass.
EXECUTE.

RECODE Sibspouse_binned (MISSING=SYSMIS) (2=0) (1=1) (0=0) INTO Sibspouse_1.
EXECUTE.

RECODE Sibspouse_binned (MISSING=SYSMIS) (0=0) (2=1) (1=0) INTO Sibspouse_2.
EXECUTE.

RECODE Parch_binned (MISSING=SYSMIS) (0=0) (1=1) (2=0) INTO Parch_1.
EXECUTE.

RECODE Parch_binned (MISSING=SYSMIS) (0=0) (2=1) (1=0) INTO Parch_2up.
EXECUTE.

RECODE Pclass (MISSING=SYSMIS) (1=0) (2=1) (3=0) INTO Secondclass.
RECODE Pclass (MISSING=SYSMIS) (1=0) (3=1) (2=0) INTO Thirdclass.
RECODE Sibspouse_binned (MISSING=SYSMIS) (2=0) (1=1) (0=0) INTO Sibspouse_1.
RECODE Sibspouse_binned (MISSING=SYSMIS) (0=0) (2=1) (1=0) INTO Sibspouse_2.
RECODE Parch_binned (MISSING=SYSMIS) (0=0) (1=1) (2=0) INTO Parch_1.
RECODE Parch_binned (MISSING=SYSMIS) (0=0) (2=1) (1=0) INTO Parch_2up.
RECODE Parch_binned (MISSING=SYSMIS) (0=0) (2=1) (1=0) INTO Parch_2up.
NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Age Female Southampton Secondclass Thirdclass
    Sibspouse_1 Sibspouse_2 Parch_1 Parch_2up
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001)
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC
  /SAVE PREDCAT ACPROB.

* b-coefficients same as in logistic regr but + and - do sometimes switch, probably something wrong in reference-categories.

* Use the dummies instead

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age Female Southampton Secondclass Thirdclass Sibspouse_1 Sibspouse_2 Parch_1
    Parch_2up
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

* However, must be possible so I try again with the 'categorical' box after googling a bit

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age Female Southampton Secondclass Thirdclass Sibspouse_1 Sibspouse_2 Parch_1
    Parch_2up
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

* Now the b-values are the same
* renamed subspouse2 to subspouse_2up




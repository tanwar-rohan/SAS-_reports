LIBNAME mydata '/home/u63207986/New Folder';

DATA labs;
    SET mydata.labs;
RUN;

data labs_subset;
set labs;
keep INVID SUBJID LBNRHI LBNRLO LBNORM LBRN LBRU LBTEST TRT visid;
run;
proc sql;
    select count(distinct cats (INVID, SUBJID) )into :Total from labs_subset where TRT <> " ";
    select count(distinct cats (INVID, SUBJID) )into :TRTX from labs_subset where strip (upcase(TRT)) = "TRT X ";
    select count(distinct cats (INVID, SUBJID) )into :TRTY from labs_subset where strip (upcase(TRT)) = "TRT Y ";
quit;

%put &total &TRTX &TRTY;


/* 
TOTAL
*/

proc sort data=labs_subset;
by lbtest subjid;
run;

proc sql;
create table TRTTb1 as
    select *, min(visid) as mvisit, lbrn as base from labs_subset group by lbtest having visid=min(visid);
quit;


data TRTTb2;
set TRTTb1;
if visid= mvisit then base = lbrn;
by lbtest subjid;
run;

proc sort data=TRTTb2;
by lbtest subjid;
run;
proc sql;
create table TRTTb3 as select lbtest,subjid,base from TRTTb2 where base is not null;
quit;

proc sort data=TRTTb3;
by lbtest subjid;
run;

data TRTTb4;
merge TRTTb3 labs_subset;
by lbtest subjid;
run;

proc sql;
create table TRTTb5 as select *,(base-lbrn)as CHG from TRTTb4 ;
quit;

proc sort data=TRTTb5;
by LBTEST visid ;
run;

proc means data=TRTTb5 mean median std min max ;
  by LBTEST visid;
  var BASE ;
  output out=FT1 mean=mean median=median std=STD min=min max=max; 
run;

proc sort data=FT1;
by visid ;
run;

data FT1;
set FT1(drop=_TYPE_ );
run;
data fT2;
set fT1;
if lbtest="ALBUMIN" then lbtest="BT_ALBUMIN";
if lbtest="ALKALINE PHOSPHATASE" then lbtest="BT_ALKALINE";
if lbtest="ALT/SGPT" then lbtest="BT_ALT"; 
if lbtest="AST/SGOT" then lbtest="BT_AST";
run;

proc transpose data=FT2 out=TRTTb6;
id lbtest;
by visid;
run;

proc means data=TRTTb5 mean median std min max ;
  by LBTEST visid;
  var CHG ;
  output out=FtC1 mean=mean median=median std=STD min=min max=max; 
run;
proc sort data=FtC1;
by visid ;
run;

data FtC1;
set FtC1(drop=_TYPE_ );
run;

data FtC1;
set FtC1;
if visid=1 then _freq_=" ";
run;

data FtC2;
set FtC1;
if visid=1 then do ;
    if mean = 0 then mean = " " ;
    if median = 0 then median = " ";
    if STD = 0 then STD = " " ;
    if min = 0 then min = " " ;
    if max = 0 then max = " " ;
    end;
run;

data ftC3;
set ftC2;
if lbtest="ALBUMIN" then lbtest="CT_ALBUMIN";
if lbtest="ALKALINE PHOSPHATASE" then lbtest="CT_ALKALINE";
if lbtest="ALT/SGPT" then lbtest="CT_ALT"; 
if lbtest="AST/SGOT" then lbtest="CT_AST";
run;

proc transpose data=FtC3 out=TRTtC1;
id lbtest;
by visid;
run;

proc sort data=TRTtC1;
by visid _name_;
run;
proc sort data=TRTtB6;
by visid _name_;
run;

data TRTtF1;
merge TRTtB6 TRTtC1;
by visid _name_;
run;


/*
TRT X
*/

proc sql;
create table TRTX as
select LBRN,LBTEST,visid,SUBJID
from labs_subset
where TRT in ('TRT X')
order by TRT;
quit;

proc sort data=TRTX;
by lbtest subjid;
run;

proc sql;
create table TRTXb1 as
    select *, min(visid) as mvisit from TRTX group by lbtest having visid=min(visid);
quit;


data TRTXb2;
set TRTXb1;
if visid= mvisit then base = lbrn;
by lbtest subjid;
run;

proc sql;
create table TRTXb3 as select lbtest,subjid,base from TRTXb2 where base is not null;
quit;

proc sort data=TRTXb3;
by lbtest subjid;
run;

data TRTXb4;
merge TRTXb3 TRTX;
by lbtest subjid;
run;

proc sql;
create table TRTXb5 as select *,(base-lbrn)as CHG from TRTXb4 ;
quit;

proc sort data=TRTXb5;
by LBTEST visid ;
run;

proc means data=TRTXb5 mean median std min max ;
  by LBTEST visid;
  var BASE ;
  output out=Fx1 mean=mean median=median std=STD min=min max=max; 
run;

proc sort data=Fx1;
by visid ;
run;

data Fx1;
set Fx1(drop=_TYPE_ );
run;
data fx2;
set fx1;
if lbtest="ALBUMIN" then lbtest="BX_ALBUMIN";
if lbtest="ALKALINE PHOSPHATASE" then lbtest="BX_ALKALINE";
if lbtest="ALT/SGPT" then lbtest="BX_ALT"; 
if lbtest="AST/SGOT" then lbtest="BX_AST";
run;

proc transpose data=Fx2 out=TRTxb6;
id lbtest;
by visid;
run;

proc means data=TRTxb5 mean median std min max ;
  by lbtest visid;
  var CHG ;
  output out=FxC1 mean=mean median=median std=STD min=min max=max; 
run;

proc sort data=FxC1;
by visid ;
run;

data FxC1;
set FxC1(drop=_TYPE_ );
run;

data FxC1;
set FxC1;
if visid=1 then _freq_=" ";
run;

data FxC2;
set FxC1;
if visid=1 then do ;
    if mean = 0 then mean = " " ;
    if median = 0 then median = " ";
    if STD = 0 then STD = " " ;
    if min = 0 then min = " " ;
    if max = 0 then max = " " ;
    end;
run;

data fxC3;
set fxC2;
if lbtest="ALBUMIN" then lbtest="CX_ALBUMIN";
if lbtest="ALKALINE PHOSPHATASE" then lbtest="CX_ALKALINE";
if lbtest="ALT/SGPT" then lbtest="CX_ALT"; 
if lbtest="AST/SGOT" then lbtest="CX_AST";
run;

proc transpose data=FxC3 out=TRTxC1;
id lbtest;
by visid;
run;

proc sort data=TRTxC1;
by visid _name_;
run;
proc sort data=TRTxB6;
by visid _name_;
run;

data TRTxF1;
merge TRTxB6 TRTxC1;
by visid _name_;
run;


/*
TRT Y
*/

proc sql;
create table TRTY as
select LBRN,LBTEST,visid,SUBJID
from labs_subset
where TRT in ('TRT Y')
order by TRT;
quit;

proc sort data=TRTY;
by lbtest subjid;
run;

proc sql; create table YT1 as
select lbtest,subjid, min(visid) as mvisit from TRTY _NAME_ group by lbtest, subjid;
quit;

data TRTYb1;
merge YT1 TRTY;
by lbtest subjid;
run;

data TRTYb2;
set TRTYb1;
if visid= mvisit then base = lbrn;
by lbtest subjid;
run;

proc sql;
create table TRTYb3 as select lbtest,subjid,base from TRTYb2 where base is not null;
quit;


proc sort data=TRTYb3;
by lbtest subjid;
run;

data TRTYb4;
merge TRTYb3 TRTY;
by lbtest subjid;
run;

proc sql;
create table TRTYb5 as select *,(base-lbrn)as CHG from TRTYb4 ;
quit;

proc sort data=TRTYb5;
by LBTEST visid ;
run;

proc means data=TRTYb5 mean median std min max;
  by LBTEST visid;
  var BASE ;
  output out=FY1 mean=mean median=median std=STD min=min max=max; 
run;
proc sort data=FY1;
by visid ;
run;

data FY1;
set FY1(drop=_TYPE_ );
run;

data fY2;
set fY1;
if lbtest="ALBUMIN" then lbtest="BY_ALBUMIN";
if lbtest="ALKALINE PHOSPHATASE" then lbtest="BY_ALKALINE";
if lbtest="ALT/SGPT" then lbtest="BY_ALT"; 
if lbtest="AST/SGOT" then lbtest="BY_AST";
run;

proc transpose data=FY2 out=TRTYb6;
id lbtest;
by visid;
run;

proc means data=TRTYb5 mean median std min max ;
  by LBTEST visid;
  var CHG ;
  output out=FYC1 mean=mean median=median std=STD min=min max=max; 
run;

proc sort data=FYC1;
by visid ;
run;

data FYC1;
set FYC1(drop=_TYPE_ );
run;

data FYC1;
set FYC1;
if visid=1 then _freq_=" ";
run;

data FYC2;
set FYC1;
if visid=1 then do ;
    if mean = 0 then mean = " " ;
    if median = 0 then median = " ";
    if STD = 0 then STD = " " ;
    if min = 0 then min = " " ;
    if max = 0 then max = " " ;
    end;
run;

data fYC3;
set fYC2;
if lbtest="ALBUMIN" then lbtest="CY_ALBUMIN";
if lbtest="ALKALINE PHOSPHATASE" then lbtest="CY_ALKALINE";
if lbtest="ALT/SGPT" then lbtest="CY_ALT"; 
if lbtest="AST/SGOT" then lbtest="CY_AST";
run;

proc transpose data=FYC3 out=TRTYC1;
id lbtest;
by visid;
run;

proc sort data=TRTYC1;
by visid _name_;
run;
proc sort data=TRTYB6;
by visid _name_;
run;

data TRTYF1;
merge TRTYB6 TRTYC1;
by visid _name_;
run;

/*
FINAL
*/

data Final;
merge TRTXF1 TRTYF1 TRTtF1;
by visid _name_;
run;

/*ALBUMIN*/
proc sql;
create table ALBUMIN as 
select visid,_NAME_,
BX_ALBUMIN as BTRTX,
CX_ALBUMIN as CTRTX,
BY_ALBUMIN as BTRTY,
CY_ALBUMIN as CTRTY,
BT_ALBUMIN as TTRTX,
CT_ALBUMIN as TTRTY 
from Final;
quit;

proc sql;
create table test1 as select "ALBUMIN" as TEST from ALBUMIN;
quit;

data ALBUMIN1;
merge test1 ALBUMIN;
run;

/*ALKALINE*/
proc sql;
create table ALKALINE as 
select visid,_NAME_,
BX_ALKALINE as BTRTX,
CX_ALKALINE as CTRTX,
BY_ALKALINE as BTRTY,
CY_ALKALINE as CTRTY,
BT_ALKALINE as TTRTX,
CT_ALKALINE as TTRTY 
from Final;
quit;

proc sql;
create table test2 as select "ALKALINE" as TEST from ALKALINE;
quit;

data ALKALINE1;
merge test2 ALKALINE;
run;

/*ALT*/
proc sql;
create table ALT as 
select visid,_NAME_,
BX_ALT as BTRTX,
CX_ALT as CTRTX,
BY_ALT as BTRTY , 
CY_ALT as CTRTY,
BT_ALT as TTRTX,
CT_ALT as TTRTY 
from Final;
quit;


proc sql;
create table test3 as select "ALT" as TEST from ALT;
quit;

data ALT1;
merge test3 ALT;
run;

/*AST*/
proc sql;
create table AST as 
select visid,_NAME_,
BX_AST as BTRTX,
CX_AST as CTRTX,
BY_AST as BTRTY,
CY_AST as CTRTY,
BT_AST as TTRTX,
CT_AST as TTRTY 	
from Final;
quit;

proc sql;
create table test4 as select "AST" as TEST from AST;
quit;

data AST1;
merge test4 AST;
run;


data Fin;
length test $10.;
set ALBUMIN1 ALKALINE1 AST1 ALT1;
run;

data fin1;
set fin;
if _NAME_="_FREQ_" then _NAME_="n";
run;

/*
custom sort
*/

proc format; 
value $delayfmt 
'n' = 1 
'mean' = 2 
'STD' = 3
'median'= 4
'min'= 5
'max'= 6;
run;

data fin2;
set fin1;
neworder=put(_NAME_, delayfmt.);
run;

proc sort data=fin2;
by test visid neworder;
run;



data fin3;
set fin2;
BTRT_X=round(BTRTX,.01);
BTRT_Y=round(BTRTY,.01);
TTRT_X=round(TTRTX,.01);
CTRT_X=round(CTRTX,.01);
CTRT_Y=round(CTRTY,.01);
TTRT_Y=round(TTRTY,.01);
run;



proc report data=Fin3 out=Fin4 ;
define test/group;
define visid/group;
break before test/skip;
break before visid/skip;
run;

data Fin5;
set Fin4;
if visid = . and _name_=" " then do _name_= test;
BTRT_X=.;
BTRT_Y=.;
TTRT_X=.;
CTRT_X=.;
CTRT_Y=.;
TTRT_Y=.;
end;
run;

data Fin6;
set Fin5;
if _name_=" " and visid = 1 then do _name_= "baseline";
BTRT_X=.;
BTRT_Y=.;
TTRT_X=.;
CTRT_X=.;
CTRT_Y=.;
TTRT_Y=.;
end;
else if _name_=" " and visid ne . then do _name_= cat("visit",visid);
BTRT_X=.;
BTRT_Y=.;
TTRT_X=.;
CTRT_X=.;
CTRT_Y=.;
TTRT_Y=.;
end;
run;

/* 
-----------------------------------------------
 Create the table layout by using PROC REPORT.
-----------------------------------------------
*/

options ps=69 ls=89 orientation=landscape nocenter pagno=1;
ods listing;
filename case "/home/u63207986/New Folder/FQLABA1.txt";

proc printto file=case new;
run;
title;

proc report data=fin6 out=fin7 nowd headline headskip spacing=0 nocenter missing split="@" ;
    columns (_NAME_
	
	( "TRT X@ ___(N=%cmpres(&TRTX))___" BTRT_X    CTRT_X)
    ( "TRT Y@ (N=%cmpres(&TRTY))@" BTRT_Y    CTRT_Y)
    ( "Total@ (N=%cmpres(&TOTAL))@" TTRT_X    TTRT_Y));

 	define _name_/ width= 16 "@Laboratory Test @  visit";
    define BTRT_X/ width= 12 "baseline @ "  ;
    define CTRT_X/ width= 12 "@Change from baseline  "  ;
	define BTRT_Y/ width= 10 "baseline @ "  ;
    define CTRT_Y/ width= 12 "@Change from @ baseline "  ;
    define TTRT_X/ width= 10 "baseline @ "  ;
	define TTRT_Y/ width= 12 "@Change from @ baseline"  ;
	
title1 justify=LEFT " ";
title2 justify=LEFT "Case Study 5";
title3 justify=LEFT"Laboratory Analysis";
title4 justify=LEFT"Descriptive Statistics and Change from Baseline in LAB Parameters";
title5 justify=LEFT"All Randomized Patients";

footnote1 justify=LEFT"Abbreviations: N = total number of randomized patients under each treatment arm;";
footnote2 justify=LEFT"               n = number of patients in the specified category.";
footnote3 justify=LEFT"Program location:/home/u63207986/New Folder/FQLABA1.sas .";
footnote4 justify=LEFT"Output location:/home/u63207986/New Folder/FQLABA1.txt .";
footnote5 justify=LEFT"Data location:/home/u63207986/New Folder/ .";
footnote6 justify=LEFT "________________________________________________________________________________________";

proc printto;
run;

ods listing close;


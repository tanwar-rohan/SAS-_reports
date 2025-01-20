LIBNAME mydata '/home/u63207986/New Folder';
DATA events;
    SET mydata.events;
RUN;
DATA subjinfo;
    SET mydata.subjinfo;
RUN;


/* Step 2: Count of patients by TRT */

proc sql;
    create table filtered_SUBJINFO as
    select INVID, SUBJID, TRT
    from SUBJINFO
    where TRT <> " "
    order by INVID, SUBJID;
quit;


proc sql;
    select count(distinct cats (INVID, SUBJID) )into :Total from filtered_SUBJINFO where TRT <> " ";
    select count(distinct cats (INVID, SUBJID) )into :TRTX from filtered_SUBJINFO where strip (upcase(TRT)) = "TRT X ";
    select count(distinct cats (INVID, SUBJID) )into :TRTY from filtered_SUBJINFO where strip (upcase(TRT)) = "TRT Y ";
quit;

%put &total &TRTX &TRTY;


DATA filtered_events (keep= invid subjid socterm pterm TEAEFLG_AU) ;
set events;
if strip(lowcase(TEAEFLG_AU))='y';
run;

proc sort data=filtered_events; 
by invid subjid;
run;

data filtered_data;
merge filtered_SUBJINFO (in=a) filtered_events(in=b);
if a and b;
by invid subjid;
run;


/* Step 3: Count of patients having TEAEFLG_AU = “Y” by SOCTERM, PTERM, TRT */
proc sql;
    create table teae_count as
    select TRT, SOCTERM, PTERM, count(distinct cats (INVID, SUBJID)) as n
    from filtered_data
    group by SOCTERM, PTERM, TRT;
quit;

/* Step 4: Percentage for Subjects with >= 1 TEAE are computed using number of patients by TRT */
proc sql;
    create table teae_percentage as
    select TRT, count(distinct SUBJID) as teae_n
    from filtered_data group by TRT; 
quit;
proc sql;
	select sum(teae_n) into :ATot from teae_percentage where TRT <> " ";
    select teae_n as TRTX into :ATRTX from teae_percentage where strip (upcase(TRT)) = "TRT X ";
    select teae_n as TRTY into :ATRTY from teae_percentage where strip (upcase(TRT)) = "TRT Y ";
quit;
%put &ATot &ATRTX &ATRTY;


proc sql;
CREATE TABLE teae_per (
    N VARCHAR(255),
    TRTX INT,
    TRTY INT,
    TOTAL INT
);

INSERT INTO teae_per (N, TRTX, TRTY, TOTAL)
VALUES ('Subjects with >= 1 TEAE', &ATRTX, &ATRTY, &ATot);
quit;

proc transpose data=teae_per out=F1;
by N;
var TRTX TRTY TOTAL;
run;

data F1;
set F1 (rename=(COL1=TEAE  _NAME_=TRT));
keep TEAE TRT;
run;

%put &total &TRTX &TRTY;

data F1;
set F1;
  if Strip(lowcase(TRT))="trtx" then pct = strip(put(TEAE,best.))||" (" || strip(put(TEAE/&TRTX*100,8.2))||") ";
  if Strip(lowcase(TRT))="trty" then pct = strip(put(TEAE,best.))||" (" || strip(put(TEAE/&TRTY*100,8.2))||") ";
  if Strip(lowcase(TRT))="total" then pct = strip(put(TEAE,best.))||" (" || strip(put(TEAE/&total*100,8.2))||") ";
run;

proc transpose data=F1 out=fin2;
id TRT;
var pct;
run;

data fin2;
set fin2;
if Strip(lowcase(_name_))="pct" then param ="Subjects with >= 1 TEAE";
run;



/* Step 5: Percentages of System Organ Class are computed from Subjects with >= 1 TEAE */
proc sql;
CREATE TABLE soc_percentage AS
SELECT TRT, SOCTERM,
       COUNT(DISTINCT SUBJID) AS soc_n
FROM filtered_data 
WHERE TRT IS NOT NULL
GROUP BY TRT, SOCTERM;
quit;

proc sql;
CREATE TABLE soc_tot AS
SELECT TRT, SOCTERM, 
       COUNT(DISTINCT SUBJID) AS soc_n
FROM filtered_data 
WHERE TRT IS NOT NULL
GROUP BY TRT, SOCTERM;
quit;

data soc_tot;
set soc_tot;
if Strip(lowcase(TRT))="trt x" then TRT ="total";
if Strip(lowcase(TRT))="trt y" then TRT ="total";
run;

proc sql;
create table soc_tot1 as
SELECT TRT, SOCTERM, SUM(soc_n) AS soc_n 
FROM soc_tot 
GROUP BY TRT, SOCTERM;
quit;

proc sort data=soc_percentage;
by SOCTERM;
run;

proc sort data=soc_tot;
by SOCTERM;
run;

proc Sql;
create table soc_f as
SELECT TRT, SOCTERM, soc_n 
FROM soc_percentage
UNION 
SELECT TRT, SOCTERM, soc_n 
FROM soc_tot1;
quit;


data soc_f1;
set soc_f;
  if Strip(lowcase(TRT))="trt x" then soc_p = strip(put(soc_n,best.))||" (" || strip(put(soc_n/&ATRTX*100,8.2))||") ";
  if Strip(lowcase(TRT))="trt y" then soc_p = strip(put(soc_n,best.))||" (" || strip(put(soc_n/&ATRTX*100,8.2))||") ";
  if Strip(lowcase(TRT))="total" then soc_p = strip(put(soc_n,best.))||" (" || strip(put(soc_n/&Atot*100,8.2))||") ";
run;


data soc_f2;
set soc_f1;
  if Strip(lowcase(TRT))="trt x" then TRT = strip("TRTX");
  if Strip(lowcase(TRT))="trt y" then TRT = strip("TRTY");
run;

proc sort data=soc_f2;
by SOCTERM;
run;
proc transpose data=soc_f2 out=soc_f3;
id TRT;
var soc_p;
by SOCTERM;
run;

data soc_f4;
set soc_f3 (drop=_name_);
run;




/* Step 6: Percentages of preferred terms are computed from the total count of preferred terms in the corresponding System Organ Class */
proc sql;
CREATE TABLE pt_n AS
SELECT TRT, SOCTERM, PTERM,
       COUNT(DISTINCT SUBJID) AS pt_n  
FROM filtered_data
WHERE TRT IS NOT NULL AND SOCTERM IS NOT NULL
GROUP BY TRT, SOCTERM, PTERM;
quit;

proc sql;
CREATE TABLE pt_TOT AS
SELECT TRT, SOCTERM, PTERM,
       COUNT(DISTINCT SUBJID) AS pt_n  
FROM filtered_data
WHERE TRT IS NOT NULL AND SOCTERM IS NOT NULL
GROUP BY TRT, SOCTERM, PTERM;
quit;

data pt_tot;
set pt_tot;
if Strip(lowcase(TRT))="trt x" then TRT ="total";
if Strip(lowcase(TRT))="trt y" then TRT ="total";
run;

proc sql;
create table pt_tot1 as
SELECT TRT, SOCTERM,pterm, SUM(pt_n) AS pt_n 
FROM pt_tot 
GROUP BY SOCTERM,pterm;
quit;

proc sort data=pt_n;
by SOCTERM pterm;
run;

proc sort data=pt_tot1;
by SOCTERM pterm;
run;

proc Sql;
create table pt_f as
SELECT * 
FROM pt_n
UNION 
SELECT *
FROM pt_tot1;
quit;

proc sort data=pt_f out=pt_f1;
by TRT socterm;
run;
proc sort data=soc_f1;
by TRT socterm;
run;

data pt_f1;
merge pt_f1 soc_f1;
by TRT socterm;
run;


data pt_f2;
set pt_f1;
  if Strip(lowcase(TRT))="trt x" then pt_p = strip(put(pt_n,best.))||" (" || strip(put(pt_n /soc_n*100,8.2))||") ";
  if Strip(lowcase(TRT))="trt y" then pt_p = strip(put(pt_n,best.))||" (" || strip(put(pt_n /soc_n*100,8.2))||") ";
  if Strip(lowcase(TRT))="total" then pt_p = strip(put(pt_n,best.))||" (" || strip(put(pt_n /soc_n*100,8.2))||") ";
run;

data pt_f2;
set pt_f2;
  if Strip(lowcase(TRT))="trt x" then TRT = strip("TRTX");
  if Strip(lowcase(TRT))="trt y" then TRT = strip("TRTY");
  if Strip(lowcase(TRT))="total" then TRT = strip("TOTAL");
run;


proc sort data=pt_f2;
by SOCTERM pterm TRT;
run;
proc transpose data=pt_f2 out=pt_f3;
id TRT;
var pt_p;
by SOCTERM PTERM;
run;

data pt_f4;
set pt_f3 (drop=_name_);
run;

proc sql;
create table pt_f5 as
select SOCTERM, TRTX, TRTY, total, PTERM from pt_f4;
quit;

proc Sql;
create table soc_pt_fin as
SELECT * 
FROM pt_f5
UNION 
SELECT *
FROM soc_f4;
quit;


proc sql;
create table soc_pt_fin1 as
select distinct SOCTERM,PTERM, TRTX, TRTY, total from soc_pt_fin group by SOCTERM,pterm;
quit;

data soc_pt_fin2;
set soc_pt_fin1;
if Strip(lowcase(pterm))="" then PTERM = strip(SOCTERM);
else do PTERM = cat('  ',pterm); 
end;
run;


proc sql;
create table soc_pt_fin3 as 
select PTERM, TRTX,TRTY,TOTAL from soc_pt_fin2;
quit;

data fin3;
length param $55;
set fin2 (drop=_NAME_);
run;

proc sql;
create table fin4 as
select param, TRTX, TRTY, TOTAL from fin3;
quit;

data soc_pt_fin4;
length param $55;
set soc_pt_fin3 (rename= (pterm=param));
run;

data Final;
set fin4 soc_pt_fin4;
run;






/* report*/

/* Step 8: Create the table layout by using PROC REPORT */
options ps=69 ls=89 orientation=portrait nocenter pagno=1;
ods listing;
filename case "/home/u63207986/New Folder/FQTEAA11.txt";

proc printto file=case new;
run;

title;

proc report data=Final out =Final3 nowd headline headskip spacing=0 nocenter missing split="@" ;
    columns (Param
	("TRT X@ (N=%cmpres(&TRTX))@" TRTX)
    ("TRT Y@ (N=%cmpres(&TRTY))@" TRTY)
    ("Total@ (N=%cmpres(&TOTAL))@" TOTAL));

 define Param/ width= 52 "System Organ class@     Preferred Term" flow;
    define TRTX/ width= 11 "n  %" center ;
    define TRTY/ width= 11 "n  %" center;
    define TOTAL/ width= 11 "n  %" center;
	


title1 justify=LEFT  "________________________________________________________________________________________";
title2 "    ";
title3 justify=LEFT"Case Study 3";
title4 justify=LEFT"Treatment Emergent Adverse Events (TEAEs) by System Organ Class and Preferred Term";
title5 justify=LEFT"All Randomized Patients";
title6 justify=LEFT"________________________________________________________________________________________";

footnote1 justify=LEFT "________________________________________________________________________________________";
footnote2 justify=LEFT"Abbreviations: N = number of randomized subjects within each group;";
footnote3 justify=LEFT"n = number of subjects with treatment-emergent adverse event within each group;";
footnote4 justify=LEFT"TEAE = treatment emergent adverse event";
footnote5 justify=LEFT"Program location:/home/u63207986/New Folder/FQTEAA1.sas.";
footnote6 justify=LEFT"Output location:/home/u63207986/New Folder/FQTEAA11.txt.";
footnote7 justify=LEFT"Data location:/home/u63207986/New Folder/.";
footnote8 justify=LEFT "________________________________________________________________________________________";
run;



proc printto;
run;

ods listing close;








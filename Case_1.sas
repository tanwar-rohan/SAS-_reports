   
data randomized_subj;
set SUBJINFO;
where not missing(TRT);
AGEYR=round(AGEYR);
run;

proc sql;
    select count(distinct cats (INVID, SUBJID) )into :Total from randomized_subj where TRT <> " ";
    select count(distinct cats (INVID, SUBJID) )into :TRTX from randomized_subj where strip (upcase(TRT)) = "TRT X ";
    select count(distinct cats (INVID, SUBJID) )into :TRTY from randomized_subj where strip (upcase(TRT)) = "TRT Y ";
quit;

%put &total &TRTX &TRTY;

/*GENDER*/
proc freq data=randomized_subj ;
tables SEXlnm*TRT /nocol norow nopercent nocum  out=G2;
run;

proc transpose data=g2 out=g3;
by SEXlnm;
run;

data g4;
set g3(rename=(COL1=TRTX  COL2=TRTY));
if _NAME_='PERCENT' then delete;
keep SEXlnm TRTX TRTY ;
run;

Proc sql;
create table G5 as
SELECT *, SUM(TRTX+TRTY) AS total 
FROM G4 
group by SEXlnm;
quit;
proc transpose data=g5 out=temp;
id SEXlnm;
run;
proc sql ;
create table GT1 as 
SELECT *, SUM(male+female) AS total 
FROM temp
group by _NAME_;
quit;

proc transpose data=GT1 out=GT2;
id _NAME_;
run;
proc SQl ;
create table GT3 as select * from GT2 where _name_ ="total";
quit;
data GT4;
   length _name_ $20;
   set GT3;
   if _name_ ="total" then _name_ ="tot";
run;
data GT4;
  set GT4(rename=(_name_=sexlnm));
run;

data G6;
set GT4 G5;
run;


data G7;
set G6;
  if Strip(lowcase(SEXlnm))="male" then do PTRTX = strip(put(TRTX,best.))||" (" || strip(put(TRTX/&TRTX*100,8.2))||") ";
  PTRTY = strip(put(TRTY,best.))||" (" || strip(put(TRTY/&TRTY*100,8.2))||") ";
  Ptotal = strip(put(total,best.))||" (" || strip(put(total/&total*100,8.2))||") ";
  end;
  if Strip(lowcase(SEXlnm))="female" then do PTRTX = strip(put(TRTX,best.))||" (" || strip(put(TRTX/&TRTX*100,8.2))||") ";
  PTRTY = strip(put(TRTY,best.))||" (" || strip(put(TRTY/&TRTY*100,8.2))||") ";
  Ptotal = strip(put(total,best.))||" (" || strip(put(total/&total*100,8.2))||") ";
  end;
  if Strip(lowcase(SEXlnm))="tot" then do PTRTX = strip(put(TRTX,best.));
  PTRTY = strip(put(TRTY,best.));
  Ptotal = strip(put(total,best.));
  end;
run;

proc SQL;
create table Final_G1 as
select SEXlnm as  Variable,PTRTX,PTRTY,Ptotal from G7;
quit;
data Final_G2;
   set Final_G1;
   if Variable ="tot" then Variable ="No. Patients";
run;
proc sql;
CREATE TABLE T1 (Variable VARCHAR(20));
INSERT INTO T1 (Variable)
VALUES ('Sex: No. (%)');
quit;

data Final_G3;
set T1 Final_G2;
run;




/*Race*/
proc freq data=randomized_subj ;
tables RACE*TRT /nocol norow nopercent nocum noprint out=r1;
proc transpose data=r1 out=r2;
  by race;
run;
data r2;
set r2(rename=(COL1=TRTX  COL2=TRTY));
if _NAME_='PERCENT' then delete;
keep race TRTX TRTY ;
run;
Proc sql;
create table r3 as
SELECT *, SUM(TRTX+TRTY) AS total 
FROM r2 
group by race;
quit;

proc transpose data=r3 out=temp1;
id race;
run;

proc sql ;
create table RT1 as 
SELECT *, SUM(Asian+Caucasian+Hispanic) AS total 
FROM temp1
group by _NAME_;
quit;

proc transpose data=RT1 out=RT2;
id _NAME_;
run;
proc SQl ;
create table RT3 as select * from RT2 where _name_ ="total";
quit;
data RT4;
   length _name_ $20;
   set RT3;
   if _name_ ="total" then _name_ ="tot";
run;
data RT4;
   set RT4(rename=(_name_=Race));
run;

data R6;
length Race $20;
set RT4 R3;
run;

data R7;
set R6;
  if Strip(lowcase(race))="tot" then do PTRTX = strip(put(TRTX,best.));
  PTRTY = strip(put(TRTY,best.));
  Ptotal = strip(put(total,best.));
  end;
  else do PTRTX = strip(put(TRTX,best.))||" (" || strip(put(TRTX/&TRTX*100,8.2))||") ";
  PTRTY = strip(put(TRTY,best.))||" (" || strip(put(TRTY/&TRTY*100,8.2))||") ";
  Ptotal = strip(put(total,best.))||" (" || strip(put(total/&total*100,8.2))||") ";
  end;
run;

proc SQL;
create table Final_R1 as
select race as  Variable,PTRTX,PTRTY,Ptotal from R7;
quit;
data Final_R2;
   set Final_R1;
   if Variable ="tot" then Variable ="No. Patients";
run;
proc sql;
CREATE TABLE T2 (Variable VARCHAR(20));
INSERT INTO T2 (Variable)
VALUES ('Origin: No. (%)');
quit;

data Final_R3;
set T2 Final_R2;
run;




/*age*/
proc means data=randomized_subj  mean median std min max noprint ;
  class TRT;
  var AGEYR;
  output out=a1 mean= median= std= min= max= /autoname;
run;

data a2;
  set a1(rename=(AGEYR_Mean=MEAN  AGEYR_Median=Median  AGEYR_StdDev=SD	AGEYR_Max=Maximum	AGEYR_Min=Minimum));
  if missing(TRT) then delete;
  keep TRT MEAN	Median SD Minimum Maximum;
run;


proc transpose data=a2 out=a3;
  by TRT;
run;

proc sql;
create table age_TRTX as select _NAME_ as age,COL1 as TRTX from a3 where TRT="TRT X";
create table age_TRTY as select _NAME_ as age,COL1 as TRTY from a3 where TRT="TRT Y";
Quit;

data a4;
merge age_TRTX age_TRTY;
run;


data a6;
set a4;
if TRTX ne"" then total=TRTX+TRTY;
run;

proc SQL;
create table Final_a1 as
select age as  Variable,TRTX as PTRTX,TRTY as PTRTY,total as Ptotal from a6;
quit;
	
data AT4;
  set RT4(rename=(Race=Variable));
run;

data AT5;
   set AT4;
   if Variable ="tot" then Variable ="No. Patients";
run;

data Final_a2;
  set Final_a1(rename=(PTRTX=TRTX PTRTY=TRTY Ptotal=total));
run;


data Final_a4;
set Final_a2;
  TRTX=round(TRTX,.01);
  TRTY=round(TRTY,.01);
  total=round(total,.01);
run;

data Final_a5;
set Final_a4; 
  PTRTX = strip(put(TRTX,8.2));
  PTRTY = strip(put(TRTY,8.2));
  Ptotal = strip(put(total,8.2));
run;

data AT6;
set AT5; 
  PTRTX = strip(put(TRTX,best.));
  PTRTY = strip(put(TRTY,best.));
  Ptotal = strip(put(total,best.));
run;

proc sql;
create table Final_a6 as
select Variable,PTRTX,PTRTY,Ptotal from Final_a5;
quit;

proc sql;
CREATE TABLE T3 (Variable VARCHAR(20));
INSERT INTO T3 (Variable)
VALUES ('Age: yrs.');
quit;


DATA FIN1;
set Final_G3 Final_R3 T3 AT6 Final_a6;
run; 


data FIN2;
set FIN1;
if Strip(lowcase(Ptotal))="" then Variable = strip(Variable);
else do Variable = cat('     ',Variable); 
end;
run;


/* Create the listing layout using PROC REPORT */


options ps=69 ls=89 orientation=landscape nocenter pagno=1;
ods listing;
filename case "/home/u63207986/New Folder/FQDEMA11.txt";



proc report data=fin2 out=fin3 nowd headline headskip spacing=0 nocenter missing split="@"  ;
    columns (("Variable"Variable)
	("TRT X@ (N=%cmpres(&TRTX))@" PTRTX)
    ("TRT Y@ (N=%cmpres(&TRTY))@" PTRTY)
    ("Total@ (N=%cmpres(&TOTAL))@" PTOTAL));

 	define Variable/ width= 30 " " flow;
    define PTRTX/    width= 18 " " right;
    define PTRTY/    width= 18 " " right;
    define PTOTAL/   width= 18 " " right;


title1  "  ";
title2 justify=LEFT"Case Study 2";
title3 justify=LEFT"Baseline Characteristics";
title4 justify=LEFT"All Randomized Patients";
title5 justify=LEFT"________________________________________________________________________________________";

footnote1 justify=LEFT "________________________________________________________________________________________";
footnote2 justify=LEFT"Abbreviations: SD = standard deviation.";                            
footnote3 justify=LEFT"Program location:/home/u63207986/New Folder/FQDEMA1.sas.";
footnote4 justify=LEFT"Output location:/home/u63207986/New Folder/FQDEMA11.txt.";
footnote5 justify=LEFT"Data location:/home/u63207986/New Folder/.";
footnote6 justify=LEFT "________________________________________________________________________________________";
run;





ods listing close;



/* create a dataset with the number of patients by TRT */
proc sql;
create table TRT as
select TRT, count (distinct SUBJID) as P_NO
from SUBJINFO
where TRT in ('TRT X','TRT Y')
group by TRT;
quit;

proc sql;
    select P_NO into :TRTX from TRT where strip (upcase(TRT)) = "TRT X ";
    select P_NO into :TRTY from TRT where strip (upcase(TRT)) = "TRT Y ";
quit;



/* add records for Not completed subjects per visit in the DISPOSIT dataset */
Proc sql ;
create table notcomplete_1 as
SELECT DSLNM, VISID, TRT,SUBJID
FROM DISPOSIT
WHERE DSLNM ne 'Completed' and TRT is not null;
quit;

/* 
---------------------------------------------------------------------
 TRT X
---------------------------------------------------------------------
*/

proc sql;
create table TRTX as
select *
from notcomplete_1
where TRT in ('TRT X')
group by TRT;
quit;

proc tabulate data=TRTX out=TRTX1;
class DSLNM VISID;
table DSLNM,VISID;
run;

data TRTX2;
set TRTX1;
if VISID ne " " then vis = 'Visit'||strip(put(visid,best.));
run;

proc transpose data=TRTX2 out=TRTX3;
by DSLNM;
id VIS;
var N;
run;

data TRTX4; 
set TRTX3(drop=_NAME_);
run;

proc sql;
create table TRTX5 as
select DSLNM,Visit3,Visit4,Visit5,Visit6,Visit7 from TRTX4;
quit;

proc sql;
create table TRTX6 as
select "Not completed" as DSLNM,sum(Visit3)as Visit3, sum(Visit4)as Visit4,sum(Visit5)as Visit5,sum(Visit6)as Visit6,sum(Visit7)as Visit7 from TRTX5;
quit;

data TRTX7;
length DSLNM $30;
set TRTX6 TRTX5;
run;

data TRTX8;
set TRTX7;
  if Strip(lowcase(Visit3)) <> " " then Pvisit3 = strip(put(Visit3,best.))||" (" || strip(put(visit3/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit4)) <> " " then Pvisit4 = strip(put(Visit4,best.))||" (" || strip(put(visit4/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit5)) <> " " then Pvisit5 = strip(put(Visit5,best.))||" (" || strip(put(visit5/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit6)) <> " " then Pvisit6 = strip(put(Visit6,best.))||" (" || strip(put(visit6/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit7)) <> " " then Pvisit7 = strip(put(Visit7,best.))||" (" || strip(put(visit7/&TRTX*100,8.2))||") ";
run;

proc sql;
create table FINX as
select DSLNM,PVisit3,PVisit4,PVisit5,PVisit6,PVisit7 from TRTX8;
quit;


/* 
---------------------------------------------------------------------
 TRT Y
---------------------------------------------------------------------
*/

proc sql;
create table TRTY as
select *
from notcomplete_1
where TRT in ('TRT Y')
group by TRT;
quit;

proc tabulate data=TRTY out=TRTY1;
class DSLNM VISID;
table DSLNM,VISID;
run;

data TRTY2;
set TRTY1;
if VISID ne " " then vis = 'Visit'||strip(put(visid,best.));
run;

proc transpose data=TRTY2 out=TRTY3;
by DSLNM;
id VIS;
var N;
run;

data TRTY4; 
set TRTY3(drop=_NAME_);
run;

proc sql;
create table TRTY5 as
select DSLNM,Visit3,Visit4,Visit5,Visit6,Visit7 from TRTY4;
quit;

proc sql;
create table TRTY6 as
select "Not completed" as DSLNM,sum(Visit3)as Visit3, sum(Visit4)as Visit4,sum(Visit5)as Visit5,sum(Visit6)as Visit6,sum(Visit7)as Visit7 from TRTY5;
quit;

data TRTY7;
length DSLNM $30;
set TRTY6 TRTY5;
run;

data TRTY8;
set TRTY7;
  if Strip(lowcase(Visit3)) <> " " then Pvisit3 = strip(put(Visit3,best.))||" (" || strip(put(visit3/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit4)) <> " " then Pvisit4 = strip(put(Visit4,best.))||" (" || strip(put(visit4/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit5)) <> " " then Pvisit5 = strip(put(Visit5,best.))||" (" || strip(put(visit5/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit6)) <> " " then Pvisit6 = strip(put(Visit6,best.))||" (" || strip(put(visit6/&TRTX*100,8.2))||") ";
  if Strip(lowcase(Visit7)) <> " " then Pvisit7 = strip(put(Visit7,best.))||" (" || strip(put(visit7/&TRTX*100,8.2))||") ";
run;

proc sql;
create table finy as
select DSLNM,PVisit3,PVisit4,PVisit5,PVisit6,PVisit7 from TRTY8;
quit;




/* report*/


options ps=69 ls=89 orientation=portrait nocenter pagno=1;
ods listing;
filename case "/home/u63207986/New Folder/FQDISA11.txt";

proc printto file=case new;
run;

title;
title1 justify=LEFT  "________________________________________________________________________________________";
title2 "    ";
title3 justify=LEFT  "Case Study 4";
title4 justify=LEFT"Summary of Study Disposition by Visit";
title5 justify=LEFT"All Randomized Patients";
title6 justify=LEFT"________________________________________________________________________________________";

proc report data=FINX out =FINALX nowd headline headskip spacing=0 nocenter missing split="@" ;
    columns (("Treatment: TRT X (N=%cmpres(&TRTX))@" DSLNM)
	("visit 3@" Pvisit3)
	("visit 4@" Pvisit4)
	("visit 5@" Pvisit5)
	("visit 6@" Pvisit6)
	("visit 7@" Pvisit7));

 define DSLNM/ width= 30 "Patient Disposition" left;
    define Pvisit3/ width= 10 "n (%)" center ;
    define Pvisit4/ width= 10 "n (%)" center;
    define Pvisit5/ width= 10 "n (%)" center;
	define Pvisit6/ width= 10 "n (%)" center;
	define Pvisit7/ width= 10 "n (%)" center;
	
footnote1 justify=LEFT "________________________________________________________________________________________";
footnote2 justify=LEFT"Abbreviations:  N = total number of randomized patients under each treatment arm;";
footnote3 justify=LEFT"                n = number of patients in the specified category.";
footnote4 justify=LEFT"          ";
footnote5 justify=LEFT"Program location:/home/u63207986/New Folder/FQDISA11.sas.";
footnote6 justify=LEFT"Output location:/home/u63207986/New Folder/FQDISA11.txt.";
footnote7 justify=LEFT"Data location:/home/u63207986/New Folder/.";
footnote8 justify=LEFT "________________________________________________________________________________________";

	run;
	

proc report data=FINY out =FINALY nowd headline headskip spacing=0 nocenter missing split="@" ;
    columns (("Treatment: TRT Y (N=%cmpres(&TRTY))@" DSLNM)
	("visit 3@" Pvisit3)
	("visit 4@" Pvisit4)
	("visit 5@" Pvisit5)
	("visit 6@" Pvisit6)
	("visit 7@" Pvisit7));

 define DSLNM/ width= 30 "Patient Disposition" left;
    define Pvisit3/ width= 10 "n (%)" center ;
    define Pvisit4/ width= 10 "n (%)" center;
    define Pvisit5/ width= 10 "n (%)" center;
	define Pvisit6/ width= 10 "n (%)" center;
	define Pvisit7/ width= 10 "n (%)" center;
	
footnote1 justify=LEFT "________________________________________________________________________________________";
footnote2 justify=LEFT"Abbreviations:  N = total number of randomized patients under each treatment arm;";
footnote3 justify=LEFT"                n = number of patients in the specified category.";
footnote4 justify=LEFT"          ";
footnote5 justify=LEFT"Program location:/home/u63207986/New Folder/FQDISA11.sas.";
footnote6 justify=LEFT"Output location:/home/u63207986/New Folder/FQDISA11.txt.";
footnote7 justify=LEFT"Data location:/home/u63207986/New Folder/.";
footnote8 justify=LEFT "________________________________________________________________________________________";

run;


proc printto;
run;

ods listing close;


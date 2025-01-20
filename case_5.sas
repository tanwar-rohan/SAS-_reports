/* Subset the SUBJINFO dataset */
data random_subj;
   set subjinfo;
    where not missing(TRT);
run;

/* Subset and merge the DISPOSIT and EVENTS datasets */
data disposit_ae;
   set DISPOSIT;
   where DS=2;
run;

/* Sort the datasets */
proc sort data=disposit;
   by INVID SUBJID VISID AEID;
run;

proc sort data=events;
   by INVID SUBJID VISID AEID;
run;

/* Merge the subsetted DISPOSIT dataset with the EVENTS dataset */
data disposit_events;
   merge disposit EVENTS;
   by INVID SUBJID VISID AEID;
run;
data disposit_events;
   set disposit_events;
   where DS=2;
run;
/* Merge with the randomized subject dataset */
proc sort data=random_subj;
   by subjid ;
run;

proc sort data=disposit_events;
   by subjid ;
run;

data final_data;
   merge random_subj disposit_events;
   by subjid ;
   AGEYR = round(AGEYR);
   VISID = round(VISID);
run;
data final_data1;
   set final_data;
   where DS=2 and trt <> "";
run;
/* Sort the final dataset */
proc sort data=final_data1;
   by TRT INVID SUBJID PTERM;
   
proc sql;
create table final_data2 as
select TRT, INVID, SUBJID, AGEYR, Sexlnm, VISID, PTERM, AESTDT from final_data1;
quit;


data final_data3;
set final_data2;
VIS=int(VISID);run;

data final_data4;
set final_data3;
INV = strip(put(INVID,best.));
AGE = strip(put(AGEYR,best.));
SUBJ = strip(put(SUBJID,best.));
VISI=strip(put(VIS,best.));
run;

/* Create the listing layout using PROC REPORT */

/* report*/

/* Step 8: Create the table layout by using PROC REPORT */
options ps=69 ls=89 orientation=landscape nocenter pagno=1;
ods listing;
filename case "/home/u63207986/New Folder/LSDISA11.txt";

proc printto file=case new;
run;

title;

proc report data=final_data4 out=final_d2 nowd headline headskip spacing=0 nocenter missing split="@" ;
    columns (TRT INV SUBJ AGE Sexlnm VISI PTERM AESTDT);

 	define TRT/ width= 6 "Trt*a" left;
    define INV/ width= 5"Inv." center ;
    define SUBJ/ width= 8 "Patient"  center ;
    define AGE/ width= 6 "Age*b"  center ;
	define Sexlnm/ width= 7 "Sex" left;
	define VISI/ width= 6 "Visit"  center ;
	define PTERM/ width= 40 "Preferred @ Term" left;
	define AESTDT/ width= 11 "Event Onset@Date" left;
	



title1  "  ";
title2 justify=LEFT  "Case Study 1";
title3 justify=LEFT"Listing of Adverse Events Reported as Reason for Discontinuation";
title4 justify=LEFT"All Randomized Patients";
title5 justify=LEFT"________________________________________________________________________________________";

footnote1 justify=LEFT "________________________________________________________________________________________";
footnote2 justify=LEFT"Abbreviations: *a - Drug taken at Event Onset : *b - Age at Study Admission";                            
footnote3 justify=LEFT"Program location:/home/u63207986/New Folder/LSDISA1.sas.";
footnote4 justify=LEFT"Output location:/home/u63207986/New Folder/LSDISA11.txt.";
footnote5 justify=LEFT"Data location:/home/u63207986/New Folder/.";
footnote6 justify=LEFT "________________________________________________________________________________________";
run;



proc printto;
run;

ods listing close;




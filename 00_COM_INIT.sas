options dmssynchk mprint symbolgen mlogic minoperator mindelimiter = "," source source2;

/*当月の指定*/
%let yyyymm   = 202011;

/* 開始時期から終了時期を指定*/
%let start_ym = 202006;
%let end_ym   = 202106; 

/*開始時期を1として開始時期からどれだけ月が経過したかを指定*/
%let elapsed  = 6;


%let exec_dir = /folders/myshortcuts/SASUniversityEdition/Project/03_家計簿;


libname INPUT  "&exec_dir./INPUT";
libname OUTPUT "&exec_dir./OUTPUT";
libname TEMP   "&exec_dir./TEMPORALLY";

filename PGM  "/folders/myshortcuts/SASUniversityEdition/Project/99_Read_EXCEL_CSV";
%include PGM(Read_Excel_CSV.sas);


data _null_;
	start_ym =  input("&start_ym", yymmn6.);
	end_ym =  input("&end_ym", yymmn6.);
	
	term = intck("MONTH", start_ym, end_ym);
	call symputx("TERM", term);
	do i = 0 to term;
		ymlist = put(intnx("MONTH",start_ym, i), yymmn6.);
		call symput(compress("YMLIST"||i+1), ymlist);
		
		put ymlist=;
	end;
run;








/*engineはdefaultでvalidvarname = anyなのでbaseに合わせてv7とする*/

options dmssynchk validvarname = v7 mprint symbolgen;

%macro make_ds(csvfile  =,
			   dsname   =,
			   mainfile =,
			   range	=);
			   
/*パラメーターdsnameのライブラリ名が省略されていた場合、workをつける*/

	%if %index(&dsname, .) = 0 %then %do;
		%let dsname = work.&dsname.;
	%end;

/*変数情報のデータを読み込みマクロ変数化*/

	data _null_;
		infile "&csvfile." dsd missover firstobs = 2;
		length col_name $32
		   	   col_type $1
		   	   col_lenght
		       col_label $256; /*ラベルの最大の長さを指定*/
		input  col_name $
		       col_type $
		       col_lenght 
		   	   col_label $;
		cnt + 1 ;/*初期値+カウントしてくれる*/
	
		call symputx("col_name"||compress(put(_N_,best.)),col_name);
		call symputx("col_label"||compress(put(_N_,best.)),col_label);
		call symputx("col_length"||compress(put(_N_,best.)),col_length);
		call symputx("col_type"||compress(put(_N_,best.)),col_type);
		call symputx("col_cnt", cnt);
	run;

/*メインデータの読み込み*/

	proc import
		out = &dsname
		datafile = "&mainfile"
		dbms = xlsx replace;
		getnames = no;
		range = "&range";
	run;

/*上で読み込んだ&dsnameの変数名をディクショナリテーブルから取ってきてマクロ変数化*/

	proc sql noprint;
		select name, type into
		   	:main_colnm1- :main_colnm&col_cnt,
		   	:main_coltype1- :main_coltype&col_cnt
		   
		from dictionary.columns
		where libname = "%upcase(%scan(&dsname,1,.))" and
		      memname = "%upcase(%scan(&dsname,2,.))";
	quit;

/*作成したメインデータのデータセットをセットして変数の属性を当てる*/

	data &dsname(keep = &col_name1 -- &&col_name&col_cnt);
		set &dsname;
	
		%do i = 1 %to &col_cnt;
	
			attrib &&col_name&i
		       	   lenght =
				%if &&col_type&i = C %then %do;
					$ /*変数情報が存在するデータのみ残す*/
				%end;
			
					&&col_length&i label = "&&col_label&i";
				
				%if &&col_name&i = 
					&&col_type&i = C and &&main_coltype&i = num %then %do;
					put(&&main_colnm&i,&&col_length&i...);
				%end;
			
				%else %if &&col_type&i = N and &&main_coltype&i = char %then %do;
					input(&&main_colnm&i, 32.);
				%end;
			
				%else %if &&col_type&i = C and &&main_coltype&i = char %then %do;
					compress(left(&&main_colnm&i));
				%end;
			
				%else %if &&col_type&i = N and &&main_coltype&i = num %then %do;
					&&main_colnm&i;
				%end;
		%end;
	run;

%mend make_ds;



	
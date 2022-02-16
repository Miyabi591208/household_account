
***店舗コードとリンクする店舗マスタを作成予定***;

%macro house_hold();

data WORK.household_account_pre;
	set INPUT.household_account;
	where ym ^= "";
	yyyymm = compress(substr(ym, 1,6),);
run;


data INPUT.household_account_renew;
	length mm $4.;
	set WORK.household_account_pre;
	%do i = 1 %to &elapsed.;
		if yyyymm = compress("&&ymlist&i.") then mm = "mm&i.";
	%end;
run;


data INPUT.store_master;
	set INPUT.store_master;
	where store_cd ^= "";
run;

****カテゴリ大ごとの月別支出を表示****;
proc summary data = INPUT.household_account_renew nway missing;
	var cost;
	class store_cd cate_main yyyymm mm;
	output out = WORK.cate_main_sum sum=;
run;

proc sort data = WORK.cate_main_sum;
	by store_cd ;
run;


proc transpose data = WORK.cate_main_sum 
			   out = OUTPUT.household_t_cate_m(drop = _NAME_ _LABEL_ ) ;
	 var cost;
	 by  store_cd ; 
	 id  cate_main mm;
run;

data WORK.temp_cate_m;
	attrib 
	  %do i = 1 %to &elapsed.;
	  		Shoppingmm&i length = 8
	  		Outingmm&i   length = 8
	  %end;
	;
run;

data household_t_cate_m_pre;
	merge temp_cate_m 
		  OUTPUT.household_t_cate_m;
run;

data household_t_cate_m_pre;
	merge household_t_cate_m_pre
		  INPUT.store_master;
	by store_cd;
run;



data OUTPUT.household_t_cate_m_comp;
	attrib
			store_cd 	 length = $4  label = "店舗コード"
			store_nm 	 length = $50 label = "店舗名"
			pref_nm 	 length = $20 label = "都道府県名"
			city_nm 	 length = $20 label = "市区町村名"
			
		%do i = 1 %to &elapsed.;
			Shoppingmm&i length = 8   label = "買い物_M&i."
			Outingmm&i	 length = 8   label = "外出_M&i."
		%end;
	;
	
	set household_t_cate_m_pre;
run;
	
			

proc export data = OUTPUT.household_t_cate_m_comp
			file = "/folders/myshortcuts/SASUniversityEdition/Project/03_家計簿/Processed_ExcelData/cate_main_month.xlsx"
			dbms = xlsx replace label;
run;


****カテゴリ小ごとの月別支出を表示****;
proc summary data = INPUT.household_account_renew nway missing;
	var cost;
	class store_cd cate_sub yyyymm mm;
	output out = WORK.cate_sub_sum sum=;
run;

proc sort data = WORK.cate_sub_sum;
	by store_cd;
run;


proc transpose data = WORK.cate_sub_sum 
			   out = OUTPUT.household_t_cate_s(drop = _NAME_ _LABEL_ ) ;
	 var cost;
	 by  store_cd ; 
	 id  cate_sub mm;
run;

data WORK.temp_cate_s;
	attrib 
	  %do i = 1 %to &elapsed.;
	  		Diningmm&i       length = 8
	  		Dining_outmm&i   length = 8
	  		Aquariummm&i     length = 8
	  		HotSpringmm&i    length = 8
	  		Poolmm&i   		 length = 8
	  		Foodmm&i   	     length = 8
	  %end;
	;
run;

data household_t_cate_s_pre;
	merge temp_cate_s 
		  OUTPUT.household_t_cate_s;
run;

data household_t_cate_s_pre;
	merge household_t_cate_s_pre
		  INPUT.store_master;
	by store_cd;
run;


data OUTPUT.household_t_cate_s_comp;
	attrib
			store_cd 		 length = $4  label = "店舗コード"
			store_nm 		 length = $50 label = "店舗名"
			pref_nm 		 length = $20 label = "都道府県名"
			city_nm 		 length = $20 label = "市区町村名"
			
		%do i = 1 %to &elapsed.;
			Diningmm&i 		 length = 8  label = "内食_M&i."
	  		Dining_outmm&i   length = 8  label = "外食_M&i."
	  		Aquariummm&i   	 length = 8	 label = "水族館_M&i."
	  		HotSpringmm&i    length = 8  label = "温泉_M&i."
	  		Poolmm&i   		 length = 8	 label = "プール_M&i."
	  		Foodmm&i   		 length = 8	 label = "食料品_M&i."
		%end;
	;
	
	set household_t_cate_s_pre;
run;


proc export data = OUTPUT.household_t_cate_s_comp
			file = "/folders/myshortcuts/SASUniversityEdition/Project/03_家計簿/Processed_ExcelData/cate_sub_month.xlsx"
			dbms = xlsx replace label;
run;


****詳細ごと月別支出を表示(カテゴリ大 Shoppingに限定して表示)****;
data WORK.household_account_detail;
	set INPUT.household_account_renew;
	where cate_main = "Shopping" and cate_sub = "Food";
run;


proc summary data = WORK.household_account_detail nway missing;
	var cost;
	class store_cd detail yyyymm mm;
	output out = WORK.detail_sum sum=;
run;


proc sort data = WORK.detail_sum out = WORK.for_transpose;
	by  store_cd;
run;


proc transpose data = WORK.for_transpose
			   out = OUTPUT.household_t_detail(drop = _NAME_ _LABEL_ ) ;
	 var cost;
	 by  store_cd; 
	 id detail mm;
run;

data WORK.temp_detail;
	attrib 
	  %do i = 1 %to &elapsed.;
	  		Meatmm&i.       length = 8
	  		Fishmm&i.       length = 8
	  		Vegetablemm&i.  length = 8
	  		Confectmm&i.    length = 8 
	  		Alcoholmm&i.    length = 8
	  		Drinkmm&i.      length = 8
	  		DryMixturemm&i. length = 8
	  		Condimentmm&i.  length = 8
	  %end;
	;
run;

data household_detail_pre;
	merge temp_detail 
		  OUTPUT.household_t_detail;
run;

data household_detail;
	merge household_detail_pre(in = in1)
		  INPUT.store_master;
	by store_cd;
	if in1;
run;


data OUTPUT.household_detail_comp;
	attrib
			store_cd 		 length = $4  label = "店舗コード"
			store_nm 		 length = $50 label = "店舗名"
			pref_nm 		 length = $20 label = "都道府県名"
			city_nm 		 length = $20 label = "市区町村名"
			
		%do i = 1 %to &elapsed.;
			Meatmm&i.       length = 8	label = "肉類_M&i."
	  		Fishmm&i.       length = 8	label = "魚介類_M&i."
	  		Vegetablemm&i.  length = 8	label = "野菜類_M&i."
	  		Confectmm&i.    length = 8	label = "菓子類_M&i." 
	  		Alcoholmm&i.    length = 8	label = "酒類_M&i."
	  		Drinkmm&i.      length = 8	label = "飲料_M&i."
	  		DryMixturemm&i. length = 8	label = "粉類_M&i."
	  		Condimentmm&i.  length = 8	label = "調味料_M&i."
		%end;
	;
	
	set household_detail;
run;




proc export data = OUTPUT.household_detail_comp
			file = "/folders/myshortcuts/SASUniversityEdition/Project/03_家計簿/Processed_ExcelData/Detail_month.xlsx"
			dbms = xlsx replace label;
run;

%mend;

%house_hold;


	

***** 202006 - 管理開始　H.Saito *****;

%macro house_hold(type);

	data WORK.household_account_pre;
		set INPUT.household_account;
		where ym ^= "";
		yyyymm = compress(substr(ym, 1,6),);
	run;
	
	proc sort data = WORK.household_account_pre;
		by store_cd yyyymm;
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
	
	proc sort data = INPUT.store_master;
		by store_cd;
	run;

****カテゴリ大, カテゴリ小, 詳細ごとの月別支出を表示****;


  %if &type. = detail %then %do;
	data WORK.household_account_detail;
		set INPUT.household_account_renew;
		where cate_main = "Shopping" and cate_sub = "Food";
	run;
  %end;


	proc summary data = %if &type. in(cate_main, cate_sub) %then %do;
							INPUT.household_account_renew
						%end;
						%else %do;
                    		WORK.household_account_detail
                    	%end; 
                    		nway missing;
		var cost;
		class store_cd &type. yyyymm mm;
		output out = WORK.&type._sum sum=;
	run;



	proc sort data = WORK.&type._sum out = WORK.&type._for_transpose;
		by store_cd ;
	run;


	proc transpose data = WORK.&type._for_transpose 
			   	   out  = TEMP.household_t_&type.(drop = _NAME_ _LABEL_ ) ;
	 	var cost;
	 	by  store_cd ; 
	 	id  &type. mm;
	run;
	
	proc sort data = WORK.&type._sum out = WORK.&type._for_transpose2;
		by store_cd yyyymm;
	run;

	proc transpose data = WORK.&type._for_transpose2 
			   	   out  = TEMP.household_t_&type._2(drop = _NAME_ _LABEL_ ) ;
	 	var cost;
	 	by  store_cd yyyymm; 
	 	id  &type.;
	run;

	data WORK.temp_&type.;

		%if &type. = cate_main %then %do;
	  		%do i = 1 %to &elapsed.;
	  			Shoppingmm&i    = .;
	  			Outingmm&i      = .;
	  		%end;
		%end;
	
		%if &type. = cate_sub %then %do;
			%do i = 1 %to &elapsed.;
	  			Diningmm&i      = .;
	  			Dining_outmm&i  = .;
	  			Aquariummm&i    = .;  
	  			HotSpringmm&i   = .; 
	  			Poolmm&i        = .;  		 
	  			Foodmm&i        = .;
	  			Sundriesmm&i.   = .;
	  			Sportmm&i.      = .;
	  		%end;
		%end;
	
		%if &type. = detail %then %do;
			%do i = 1 %to &elapsed.;
	  			Meatmm&i.       = .;       
	  			Fishmm&i.       = .;      
	  			Vegetablemm&i.  = .;  
	  			Confectmm&i.    = .;   
	  			Alcoholmm&i.    = .;   
	  			Drinkmm&i.      = .;   
	  			DryMixturemm&i. = .; 
	  			Condimentmm&i.  = .;
	  			Processedmm&i.  = .; 
	  		%end;
		%end;	 
		;
	run;

	data WORK.temp_&type._2;

		%if &type. = cate_main %then %do;
	  			Shopping    = .;
	  			Outing      = .;
		%end;
	
		%if &type. = cate_sub %then %do;
	  			Dining      = .;
	  			Dining_out  = .;
	  			Aquarium    = .;  
	  			HotSpring   = .; 
	  			Pool        = .;  		 
	  			Food        = .;
	  			Sundries    = .;
	  			Sport       = .;
		%end;
	
		%if &type. = detail %then %do;
	  			Meat       = .;       
	  			Fish       = .;      
	  			Vegetable  = .;  
	  			Confect    = .;   
	  			Alcohol    = .;   
	  			Drink      = .;   
	  			DryMixture = .; 
	  			Condiment  = .;
	  			Processed  = .; 
		%end;	 
		;
	run;
	  
	data WORK.household_t_&type._pre;
		merge WORK.temp_&type. 
		  	  TEMP.household_t_&type.;
	run;
	
	data WORK.household_t_&type._pre_2;
		merge WORK.temp_&type._2 
		  	  TEMP.household_t_&type._2;
	run;


	data WORK.household_&type.;
		merge WORK.household_t_&type._pre(in = in1)
		  	  INPUT.store_master;
		by store_cd;
		if in1;
	run;
	
	data WORK.household_&type._2;
		merge WORK.household_t_&type._pre_2(in = in1)
		  	  INPUT.store_master;
		by store_cd;
		if in1;
	run;
	

	proc sort data = WORK.household_account_pre
			  out  = WORK.household_account_pre2;
		by store_cd;
	run;
	
	
	data WORK.household_3;
		merge WORK.household_account_pre2(in = in1)
			  INPUT.store_master;
		by store_cd;
		if in1;
	run;
	
	data WORK.household_3;
		set WORK.household_3;
/* 		where detail ^= "" ; */
	run;


**** 欠損値を0に変換 ****;	
	data  WORK.household_&type.(drop = i);
		set WORK.household_&type.;
		array all1 _numeric_;
			do i = 1 to dim(all1);
				if all1[i] = . then all1[i] = 0;
			end;
	run;
	
	data  WORK.household_&type._2(drop = i);
		set WORK.household_&type._2;
		array all2 _numeric_;
			do i = 1 to dim(all2);
				if all2[i] = . then all2[i] = 0;
			end;
	run;
	

	data  WORK.household_3(drop = i);
		set WORK.household_3;
		array all3 _numeric_;
			do i = 1 to dim(all3);
				if all3[i] = . then all3[i] = 0;
			end;
	run;



	data OUTPUT.household_&type._comp;
		attrib
				store_cd 		 length = $4  label = "店舗コード"
				store_nm 		 length = $50 label = "店舗名"
				pref_nm 		 length = $20 label = "都道府県名"
				city_nm 		 length = $20 label = "市区町村名"
			
		%if &type. = cate_main %then %do;
			%do i = 1 %to &elapsed.;
				Shoppingmm&i 	 length = 8   label = "買い物_M&i."
				Outingmm&i	 	 length = 8   label = "外出_M&i."
			%end;
		%end;
		
		%if &type. = cate_sub %then %do;
			%do i = 1 %to &elapsed.;
				Diningmm&i 		 length = 8   label = "内食_M&i."
	  			Dining_outmm&i   length = 8   label = "外食_M&i."
	  			Aquariummm&i   	 length = 8	  label = "水族館_M&i."
	  			HotSpringmm&i    length = 8   label = "温泉_M&i."
	  			Poolmm&i   		 length = 8	  label = "プール_M&i."
	  			Foodmm&i   		 length = 8	  label = "食料品_M&i."
	  			Sundriesmm&i   	 length = 8	  label = "雑貨_M&i."
	  			Sportmm&i.   	 length = 8	  label = "運動_M&i."
			%end;	
		%end;
	
		%if &type. = detail %then %do;
			%do i = 1 %to &elapsed.;
				Meatmm&i.        length = 8	  label = "肉類_M&i."
	  			Fishmm&i.        length = 8	  label = "魚介類_M&i."
	  			Vegetablemm&i.   length = 8	  label = "野菜類_M&i."
	  			Confectmm&i.     length = 8	  label = "菓子類_M&i." 
	  			Alcoholmm&i.     length = 8	  label = "酒類_M&i."
	  			Drinkmm&i.       length = 8	  label = "飲料_M&i."
	  			DryMixturemm&i.  length = 8	  label = "粉類_M&i."
	  			Condimentmm&i.   length = 8	  label = "調味料_M&i."
	  			Processedmm&i.   length = 8	  label = "加工食品_M&i."
			%end;
		%end;
		;
	
		set household_&type.;
	run;

	
	data OUTPUT.household_&type._comp_2;
		attrib
				store_cd 		 length = $4  label = "店舗コード"
				store_nm 		 length = $50 label = "店舗名"
				pref_nm 		 length = $20 label = "都道府県名"
				city_nm 		 length = $20 label = "市区町村名"
				yyyymm			 label  = "活動年月"  
			
		%if &type. = cate_main %then %do;
				Shopping 	 length = 8   label = "買い物"
				Outing	 	 length = 8   label = "外出"
		%end;
		
		%if &type. = cate_sub %then %do;
				Dining 		 length = 8   label = "内食"
	  			Dining_out   length = 8   label = "外食"
	  			Aquarium   	 length = 8	  label = "水族館"
	  			HotSpring    length = 8   label = "温泉"
	  			Pool   		 length = 8	  label = "プール"
	  			Food   		 length = 8	  label = "食料品"
	  			Sundries   	 length = 8	  label = "雑貨"
	  			Sport   	 length = 8	  label = "運動"
		%end;
	
		%if &type. = detail %then %do;
				Meat        length = 8	  label = "肉類"
	  			Fish        length = 8	  label = "魚介類"
	  			Vegetable   length = 8	  label = "野菜類"
	  			Confect     length = 8	  label = "菓子類" 
	  			Alcohol     length = 8	  label = "酒類"
	  			Drink       length = 8	  label = "飲料"
	  			DryMixture  length = 8	  label = "粉類"
	  			Condiment   length = 8	  label = "調味料"
	  			Processed   length = 8	  label = "加工食品"
		%end;
		;
	
		set household_&type._2;
	run;
	

	data OUTPUT.household_comp_3(drop = ym);
		attrib
				store_cd 		 label = "店舗コード"
				store_nm 		 label = "店舗名"
				pref_nm 		 label = "都道府県名"
				city_nm 		 label = "市区町村名"
				yyyymm			 label  = "活動年月" 
				cate_main		 label  = "カテゴリ大"
				cate_sub		 label  = "カテゴリ小"
				detail			 label  = "詳細項目"
				cost			 label  = "支出"
				;
	
		set household_3;
		
				if cate_main = "Shopping" 	 then 	cate_main  = "買い物";
				if cate_main = "Outing"	  	 then 	cate_main  = "外出";
				if cate_main = "Other"	  	 then 	cate_main  = "その他";
				if cate_sub  = "Dining" 	 then 	cate_sub   = "内食";
	  			if cate_sub  = "Dining_out"  then 	cate_sub   = "外食";
	  			if cate_sub  = "Aquarium" 	 then  	cate_sub   = "水族館";
	  			if cate_sub  = "HotSpring"   then 	cate_sub   = "温泉";
	  			if cate_sub  = "Pool"   	 then 	cate_sub   = "プール";
	  			if cate_sub  = "Food" 		 then   cate_sub   = "食料品";
	  			if cate_sub  = "Sundries"    then 	cate_sub   = "雑貨";
	  			if cate_sub  = "Sport" 		 then   cate_sub   = "運動";
	  			if cate_sub  = "Other"		 then   cate_sub   = "その他";
				if detail    = "Meat" 		 then   detail 	   = "肉類";
	  			if detail    = "Fish" 		 then   detail     = "魚介類";
	  			if detail    = "Vegetable"   then 	detail 	   = "野菜類";
	  			if detail    = "Confect" 	 then   detail 	   = "菓子類"; 
	  			if detail    = "Alcohol" 	 then   detail 	   = "酒類";
	  			if detail    = "Drink" 		 then   detail 	   = "飲料";
	  			if detail    = "DryMixture"  then  	detail 	   = "粉類";
	  			if detail    = "Condiment"   then 	detail 	   = "調味料";
	  			if detail    = "Processed"   then 	detail 	   = "加工食品";
	  			if detail    = "Other"   	 then 	detail 	   = "買い物以外";
	run;


	proc export data = OUTPUT.household_&type._comp
				file = "/folders/myshortcuts/SASUniversityEdition/Project/03_家計簿/Processed_ExcelData/&type._month.xlsx"
				dbms = xlsx replace label;
	run;
	
	proc export data = OUTPUT.household_&type._comp_2
				file = "/folders/myshortcuts/SASUniversityEdition/Project/03_家計簿/Processed_ExcelData/&type._monthly.xlsx"
				dbms = xlsx replace label;
	run;
	

	proc export data = OUTPUT.household_comp_3
				file = "/folders/myshortcuts/SASUniversityEdition/Project/03_家計簿/Processed_ExcelData/House_hold_account&yyyymm..xlsx"
				dbms = xlsx replace label;
	run;


%mend;

%house_hold(cate_main);
%house_hold(cate_sub);
%house_hold(detail);





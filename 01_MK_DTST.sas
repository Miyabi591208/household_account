
/*データセット作成*/

%macro a(csv =, ds =, file =, sheet =, range =, tp = );
	%make_ds(csvfile = &exec_dir./CSV_for_read_Raw/&csv..csv,
			 dsname = INPUT.&ds.,
			 mainfile = &exec_dir./Rawdata/&file..&tp.,
			 range = &sheet.&&range,
			 type = &tp.
			 );
%mend a;


%a(csv = house_hold, ds = household_account, file = 家計簿_&yyyymm., sheet = 家計簿_支出履歴, range = $A2:F, tp = xlsx);
%a(csv = store_master, ds = store_master, file = 家計簿_&yyyymm., sheet = 店舗マスター, range = $A2:D, tp = xlsx);

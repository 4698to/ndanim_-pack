--languages = #("中文", "English", "Japanese", "Korean")
global currentLang;
(
global currentLang_languages = #("zh-CN", "en-US")
sys_lang = findItem currentLang_languages ((sysinfo.getmaxlanguage())[5]);if sys_lang == 0 do (sys_lang = 1);
------------ 中文 ------------------------ 
currentLang_languages[1] = #()
currentLang_languages[1][1] = "NDBox翻译工具"
currentLang_languages[1][2] = "MXS翻译工具"
currentLang_languages[1][3] = "新脚本翻译项目"
currentLang_languages[1][4] = "打开翻译项目"
currentLang_languages[1][5] = "保存项目"
currentLang_languages[1][6] = "工作脚本："
currentLang_languages[1][7] = "工作项目："
currentLang_languages[1][8] = "语言筛选器："
currentLang_languages[1][9] = "重载"
currentLang_languages[1][10] = "添加多种语言"
currentLang_languages[1][11] = "定时器筛选器"
currentLang_languages[1][12] = "格式 KEY"
currentLang_languages[1][13] = "粘贴 KEY"
currentLang_languages[1][14] = "复制 OriginText"
currentLang_languages[1][15] = "粘贴到"
currentLang_languages[1][16] = "方案A"
currentLang_languages[1][17] = "替换脚本文件中的字符串以生成新版本"
currentLang_languages[1][18] = "导出语言"
currentLang_languages[1][19] = "方案B"
currentLang_languages[1][20] = "将语言列表保存到脚本文件。不支持组UI控件的标题。"
currentLang_languages[1][21] = "语言列表全局变量名："
currentLang_languages[1][22] = "方案C"
currentLang_languages[1][23] = "生成文本资源文件"
currentLang_languages[1][24] = "脚本名称："
currentLang_languages[1][25] = "MaxRoot路径中的脚本安装路径："
currentLang_languages[1][26] = "获取安装路径"
currentLang_languages[1][27] = "导出多种语言"
currentLang_languages[1][28] = "导出完成！"
currentLang_languages[1][29] = "成功！"
currentLang_languages[1][30] = "打开 ms本"
currentLang_languages[1][31] = "加载脚本完成！"
currentLang_languages[1][32] = "打开 翻译项目"
currentLang_languages[1][33] = "保存 翻译项目"
currentLang_languages[1][34] = "请设置全局变量名"
currentLang_languages[1][35] = "请选择语言"
currentLang_languages[1][36] = "生成 多语音 版本"
currentLang_languages[1][37] = "生成 翻译 版本"
currentLang_languages[1][38] = "在MaxRoot路径中获取脚本安装路径"
currentLang_languages[1][39] = "没有文本键！"
currentLang_languages[1][40] = "放弃！"
currentLang_languages[1][41] = "重新加载脚本完成！"

------------ English ------------------------ 
currentLang_languages[2] = #()
currentLang_languages[2][1] = "NDBox Translate Tools"
currentLang_languages[2][2] = "MXS 翻译工具"
currentLang_languages[2][3] = "New Script Translates Project"
currentLang_languages[2][4] = "Open Translates Project"
currentLang_languages[2][5] = "Save Project"
currentLang_languages[2][6] = "Work Script:"
currentLang_languages[2][7] = "Work Project:"
currentLang_languages[2][8] = "Languages Filter:"
currentLang_languages[2][9] = "RELOAD"
currentLang_languages[2][10] = "Add Mult Language"
currentLang_languages[2][11] = "Timer Filter"
currentLang_languages[2][12] = "Key To Title Case"
currentLang_languages[2][13] = "Paste To Key"
currentLang_languages[2][14] = "Copy Origin Text"
currentLang_languages[2][15] = "Paste To"
currentLang_languages[2][16] = "Plan A"
currentLang_languages[2][17] = "Replace the strings in the script file to generate a new version"
currentLang_languages[2][18] = "Export Languages"
currentLang_languages[2][19] = "Plan B"
currentLang_languages[2][20] = "Save language list to script file. Caption for Group UI Control is not supported."
currentLang_languages[2][21] = "Language list global variable name:"
currentLang_languages[2][22] = "Plan C"
currentLang_languages[2][23] = "Generate text resource files"
currentLang_languages[2][24] = "Script Name:"
currentLang_languages[2][25] = "Script Install Path In MaxRoot Path:"
currentLang_languages[2][26] = "Get Install Path"
currentLang_languages[2][27] = "Export Mult Language"
currentLang_languages[2][28] = "Export done!"
currentLang_languages[2][29] = "Success!"
currentLang_languages[2][30] = "打开 ms 脚本"
currentLang_languages[2][31] = "load Script done!"
currentLang_languages[2][32] = "打开 翻译项目"
currentLang_languages[2][33] = "保存 翻译项目"
currentLang_languages[2][34] = "Please set the global variable name"
currentLang_languages[2][35] = "please select language"
currentLang_languages[2][36] = "生成 多语音 版本"
currentLang_languages[2][37] = "生成 翻译 版本"
currentLang_languages[2][38] = "Get Script Install Path In MaxRoot Path"
currentLang_languages[2][39] = "No Text Keys !"
currentLang_languages[2][40] = "abandon!"
currentLang_languages[2][41] = "Reload Script done!"

global currentLang = currentLang_languages[sys_lang];
);
--Warn => group Plan A  | Unable to process
--Warn => group Plan B  | Unable to process
--Warn => group Plan C  | Unable to process

--Add the code to your script
/*
dropdownlist switch_language "" items:#("zh-CN", "en-US")
on switch_language selected arg do
(
	global currentLang = currentLang_languages[arg];

----rollout panle  
	try(destroyDialog rolloutName)catch();
	createDialog rolloutName

----rolloutFloater panle  
	try(removeRollout rolloutName rolloutFloaterName )catch();
	addRollout rolloutName rolloutFloaterName
)
*/
------------ Translates End ------------------------;
/*
# coding: utf-8 
# @Date    : 2024-08-17 12:55:57
# @Author  : 4698to (738746223@qq.com)
# @Link    : sundaybox.cc
# @99U     : 199505
*/

try(closeRolloutFloater fTranslates) catch()
global fTranslates = newRolloutFloater currentLang[1] 1400 1200
global _rTranslatesUI


rollout _rTranslatesUI currentLang[2] 
(
	local languages = #("中文","English","Japanese","Korean")
	local languages_code = #("zh-CN","en-US","ja-JP","ko-KR")

	local work_space = (getFilenamePath  (getThisScriptFilename())) + ".TranslatesWork.ini"

	local word_languageList_name = "currentLang"

	group ""(
	button btn_new_script_transl currentLang[3] align:#left across:4
	button btn_open_project currentLang[4] 

	button btn_save_project currentLang[5] align:#left
	dropdownlist switch_language "" items:#("zh-CN", "en-US")


	edittext ddlInstalledScript "Work Script: " enabled: false
	edittext ddlSecType "Work Project: " enabled: false
	
		on switch_language selected arg do
		(
			global currentLang = currentLang_languages[arg];

		----rollout panle  
			--try(destroyDialog rolloutName)catch();
			--createDialog rolloutName

		----rolloutFloater panle  
			try(removeRollout _rTranslatesUI fTranslates )catch();
			addRollout _rTranslatesUI fTranslates
		)
	)

	group ""(
	label lab_filter "Languages Filter: " across: 4 align: #left
	dropdownlist edtFilter "" items:#("None","中文","Japanese","Korean") width:140 align: #left offset: [-245, -2]
	button btnReloadFilter currentLang[9] width:75 align: #left offset: [-435,0]
	button btnAddMultLanguage currentLang[10] align: #right enabled:false--offset: [180, 0]
	)
	
	
	--dotNetControl lbxTranslatesUI "system.windows.forms.listView" height: 700 width: 1390 offset: [-13, 0]
	dotNetControl lbxTranslatesUI "System.Windows.Forms.DataGridView" height: 700 width: 1390 offset: [-13, 0]


	timer trmFilter currentLang[11] active: false interval: 300
	button btn_key_initial_capitalization currentLang[12] across:7
	button btn_paste_to_Key currentLang[13] 
	button btn_copy currentLang[14] 
	button btn_paste_zh "Paste To "
	button btn_paste_en "Paste To " 
	button btn_paste_jp "Paste To " 
	button btn_paste_Ko "Paste To "

	group "Plan A" (
		label lab_a currentLang[17] across:3
		dropdownlist btn_language "" items:languages width:100 offset: [320, 0] 

		button btnExportLanguages currentLang[18] width:140 align: #right
		-- Group body.
	)
	group "Plan B" (
		label lab_b currentLang[20] offset:[90, 0]  across:4
		edittext  edit_list_name currentLang[21] text:word_languageList_name offset:[-250, 40] 
		MultiListBox btn_set_language "" items:languages width:100 height:6 offset: [95, 0] 

		button btnExportLanguagesList currentLang[18] width:140 align: #right
		-- Group body.
	)
	group "Plan C" (
		label lab_c currentLang[23] across:5 align:#left 
		edittext edit_script_name currentLang[24] width:240 offset:[-100,0] --readOnly:true 
		edittext edit_script_install_path currentLang[25] width:540 offset:[-100,0] 
		button btn_get_install_path currentLang[26] width:100 offset:[10,0]  align:#right
		button btn_GenerateMultLanguage currentLang[27] width:140 align: #right
		-- Group body.
	)
	local current_project_path = undefined
	
	local current_script_path = undefined
	
	local current_script_install_path = undefined

	local current_script_install_name = undefined


	local TextInfo = dotnetObject "System.Globalization.CultureInfo" "en-US"
	local Encoding = (dotNetClass "System.Text.Encoding").UTF8


	fn GetRelativePath basePath targetPath =
	(
		local xPath = dotNetObject "System.String" basePath
		result = xPath.Replace targetPath ""
		result
	)

	fn regex_string inp_str old_s new_s = 
	(
		rgx = dotNetClass "System.Text.RegularExpressions.Regex" 
		result = rgx.Replace inp_str old_s new_s
		result
	)
	--去掉双引号
	fn regex_str inp_str =
	(
		rgx = dotNetClass "System.Text.RegularExpressions.Regex" 
		result = rgx.Replace inp_str "\"" ""
		result
	)
	--检测是否有中文
	fn contains_chinese s = 
	(
		rgx = dotNetObject "System.Text.RegularExpressions.Regex" "[\u4e00-\u9fa5]"
		return (rgx.IsMatch s) 
	)
	--检测是否有日文
	fn contains_japanese s = 
	(
		rgx = dotNetObject "System.Text.RegularExpressions.Regex" "[\u0800-\u4e00]"
		return (rgx.IsMatch s) 
	)
	--检测是否有韩文
	fn contains_korea s = 
	(
		rgx = dotNetObject "System.Text.RegularExpressions.Regex" "[\uac00-\ud7ff]"
		return (rgx.IsMatch s) 
	)
	-- 去掉非字母或非数字的
	fn regex_unchar inp_str = 
	(
		rgx = dotNetClass "System.Text.RegularExpressions.Regex" 
		result = rgx.Replace inp_str "[^a-zA-Z0-9]" ""
		result
	)
	fn updataToLbxListId lv_body = 
	(
		for i = 1 to lv_body.Rows.count do 
		(
			row = lv_body.Rows.item[i - 1]
			row.cells.item[0].value = i as string
			row.cells.item[0].ReadOnly = true
		)
	)
	fn get_dataview_col_data lv_body index_col =
	(
		temp_value = #()
		for i = 1 to lv_body.Rows.count do 
		(
			row = lv_body.Rows.item[i - 1]
			value = row.cells.item[index_col].value
			if value == undefined do (value = "")
			append temp_value value
		)
		temp_value
	)
	fn paste_to_languages index_col = 
	(
		clip = dotNetClass "System.Windows.Forms.Clipboard"
		textline = FilterString (clip.GetText()) "\n"
		for i = 1 to textline.count do 
		(
			row = lbxTranslatesUI.Rows.item[(i-1)]
			row.cells.item[index_col].value = textline[i]
		)
	)
	fn get_dataview_col_text lv_body index_col =
	(
		copy_txt = StringStream ""
		for i = 0 to lv_body.Rows.count - 1 do 
		(
			row = lv_body.Rows.item[i]
			temp_value = row.cells.item[index_col].value
			format "%\n" temp_value to:copy_txt
		)
		clip = dotNetClass "System.Windows.Forms.Clipboard"
		clip.SetText (copy_txt as string)
	)
	fn context_copyKey = 
	(
		--row = lbxTranslatesUI.CurrentCell.RowIndex 
		col = lbxTranslatesUI.CurrentCell.ColumnIndex 

		get_dataview_col_text lbxTranslatesUI col
		
	)
	fn context_pasteKey = 
	(
		col = lbxTranslatesUI.CurrentCell.ColumnIndex 

		paste_to_languages col
	)
	fn ToTitleCaseSingle index_row index_col = 
	(
		row = lbxTranslatesUI.Rows.item[index_row]
		if row != undefined do 
		(
			temp_value = row.cells.item[index_col].value
			if temp_value != undefined and temp_value != "" do 
			(
				new_value = TextInfo.TextInfo.ToTitleCase temp_value
				row.cells.item[index_col].value = new_value
			)
		)
	)
	fn context_TitleCaseSingle = 
	(
		row = lbxTranslatesUI.CurrentCell.RowIndex 
		col = lbxTranslatesUI.CurrentCell.ColumnIndex 
		ToTitleCaseSingle row col
	)
	fn ToTitleCase index_col = 
	(
		for i = 0 to lbxTranslatesUI.Rows.count - 1 do 
		(
			row = lbxTranslatesUI.Rows.item[i]
			temp_value = row.cells.item[index_col].value
			
			if temp_value != undefined and temp_value != "" do 
			(
				new_value = TextInfo.TextInfo.ToTitleCase temp_value
				row.cells.item[index_col].value = new_value
			)
		)
	)

	fn context_TitleCase = 
	(
		col = lbxTranslatesUI.CurrentCell.ColumnIndex 

		ToTitleCase col
	)
	fn context_remove_row = 
	(
		lbxTranslatesUI.EndEdit()
		row = lbxTranslatesUI.CurrentCell.RowIndex 
		if row >= 0 and row < lbxTranslatesUI.Rows.Count do (
			lbxTranslatesUI.Rows.RemoveAt row
		)
		lbxTranslatesUI.EndEdit()

		updataToLbxListId lbxTranslatesUI
	)
	fn newlist_columns lv_body str_ size_ =
	(
		
		local myCol1 = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
		myCol1.SortMode = (dotNetClass "System.Windows.Forms.DataGridViewColumnSortMode").NotSortable
		myCol1.headerText = str_
		myCol1.width = size_
		lv_body.columns.add myCol1

		
		contextMenu = dotNetObject "System.Windows.Forms.ContextMenuStrip"
		contextMenu.Items.Add("Column - Copy All") 
		contextMenu.Items.Add("-") 
		contextMenu.Items.Add("Column - Paste All") 
		contextMenu.Items.Add("-") 
		contextMenu.Items.Add("Column - ToTitleCase All") 
		contextMenu.Items.Add("-") 
		contextMenu.Items.Add("Column - ToTitleCase Single") 
		contextMenu.Items.Add("-") 
		contextMenu.Items.Add("Row - Delete Row") 


		dotnet.addEventHandler contextMenu.Items.item[0] "Click" context_copyKey
		dotnet.addEventHandler contextMenu.Items.item[2] "Click" context_pasteKey
		dotnet.addEventHandler contextMenu.Items.item[4] "Click" context_TitleCase
		dotnet.addEventHandler contextMenu.Items.item[6] "Click" context_TitleCaseSingle
		dotnet.addEventHandler contextMenu.Items.item[8] "Click" context_remove_row


		dotNet.setLifetimeControl contextMenu.Items.item[0] #dotnet
		dotNet.setLifetimeControl contextMenu.Items.item[2] #dotnet
		dotNet.setLifetimeControl contextMenu.Items.item[4] #dotnet
		dotNet.setLifetimeControl contextMenu.Items.item[6] #dotnet
		dotNet.setLifetimeControl contextMenu.Items.item[8] #dotnet



		lv_body.ContextMenuStrip = contextMenu
	)
	fn setup_list lv_body =
	(

		lv_body.backcolor = lv_body.backcolor.fromargb 225 225 225
		lv_body.EditMode =(dotNetClass "System.Windows.Forms.DataGridViewEditMode").EditOnEnter
		lv_body.ColumnHeadersHeightSizeMode =(dotNetClass "System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode").DisableResizing
		lv_body.AutoSizeColumnsMode = (dotNetClass "System.Windows.Forms.DataGridViewAutoSizeColumnsMode").Fill
		lv_body.RowHeadersVisible = false
		lv_body.SelectionMode = (dotNetClass "System.Windows.Forms.DataGridViewSelectionMode").CellSelect
		lv_body.AllowUserToResizeRows = false
		lv_body.AllowUserToAddRows = false
		lv_body.MultiSelect = False
		
	)
	fn setup_translates_ui = 
	(
		
		setup_list lbxTranslatesUI
		
		align = dotNetClass "HorizontalAlignment"
	
		names = #("KEY","Origin Text",&languages[1],&languages[2],&languages[3],&languages[4])--getTranslatesNames()
		columnsWidth = (lbxTranslatesUI.width - 35 - 18) / (names.count + 1)
		
		newlist_columns lbxTranslatesUI "#" 35
		
		for n in names do newlist_columns lbxTranslatesUI (n) columnsWidth
		lbxTranslatesUI.rowCount = 38
		
	)
	fn addTextToLbxList lbx rows = 
	(
		lbx.rowCount = rows.count 
		for i = 1 to rows.count do
		(
			row = lbx.Rows.item[i - 1]
			row.cells.item[0].value = (i as string)
			row.cells.item[0].tag = 0
			row.cells.item[0].ReadOnly = true
			
			row.cells.item[1].value = ""
			row.cells.item[1].tag = 1
			row.cells.item[1].ReadOnly = false

			row.cells.item[2].value = rows[i]
			row.cells.item[2].tag = 2
			row.cells.item[2].ReadOnly = false
		)
	)
	fn addToLbxList lbx rows = 
	(				
		
		lbx.rowCount = rows.count 
		--lbxRows = #()	
		i = 1
		
		for x in rows do(
			row = lbx.Rows.item[i - 1]
					
			row.cells.item[0].value = (i as string)
			row.cells.item[0].tag = 0
			row.cells.item[0].ReadOnly = true
			
			row.cells.item[1].value = x[1]
			row.cells.item[1].tag = 1
			row.cells.item[1].ReadOnly = false
			
			row.cells.item[2].value = x[2]
			row.cells.item[2].tag = 2
			row.cells.item[2].ReadOnly = true

			row.cells.item[3].value = x[3]
			row.cells.item[4].value = x[4]

			row.cells.item[5].value = x[5]
			row.cells.item[6].value = x[6]
			
			--format "% - % \n" x[1] x[2]
			--append lbxRows li		
			i += 1
		)
		
	)
	fn updataToLbxList lbx rows = 
	(
		origin_texts = get_dataview_col_data lbx 2 

		lbx.BeginEdit true 
		for i in rows do 
		(
			text_index = findItem origin_texts i 
			if text_index == 0 do 
			(
				count_index = lbx.Rows.Count + 1 
				count_index = count_index as string 
				lbx.Rows.Add #(count_index,"",i)
			)

		)
		updataToLbxListId lbx
		lbx.EndEdit()
	)

	fn save_to_ini ingfile section_string key_list key_value_list = 
	(
		for i = 1 to key_list.count do 
		(
			setIniSetting ingfile section_string key_list[i] key_value_list[i]

		)
	)
	fn get_dataview_row_ids lv_body = 
	(
		ids = #()
		for i = 1 to lbxTranslatesUI.Rows.count do 
		(
			append ids ( i as string )
		)
		ids 
	)
	fn get_dataview_row_col_data lv_body index_row index_col =
	(
		temp_value = ""
		if index_row <= lv_body.Rows.count and index_row >= 0 and index_col >= 0 then
		(
			row = lv_body.Rows.item[index_row]
			
			temp_value = row.cells.item[index_col].value
			if temp_value == undefined do ( temp_value = "" )
		)else(
			
		)
		temp_value
	)

	
	fn open_project ingfile = 
	(
		

		script_path	= getIniSetting ingfile "MXS" "Path"
		if doesFileExist script_path then  
		(
			current_script_path = script_path
			ddlInstalledScript.text = current_script_path
			edit_script_name.text = (getFilenameFile script_path)

		)else(
			ddlInstalledScript.text = ""
			edit_script_name.text = ""
		)

		temp_name = getIniSetting ingfile "MXS" "ScriptName"
		if temp_name != "" do (
			current_script_install_name = temp_name
			edit_script_name.text = temp_name
		)

		temp_install_path = getIniSetting ingfile "MXS" "ScriptInstallPath"
		if temp_install_path != "" do 
		(
			current_script_install_path = temp_install_path
			edit_script_install_path.text = temp_install_path
		)

		temp_name = getIniSetting ingfile "MXS" "VariableName" ; temp_name = regex_unchar temp_name
		if temp_name.count >= 4 do 
		(
			word_languageList_name = temp_name
		)
		edit_list_name.text = word_languageList_name

		rows = #()
			row = #()		
			key_count = getIniSetting ingfile "MXS" "Count"
			if key_count != "" then (key_count = key_count as integer)else(key_count = 0)
			
			for f=1 to key_count do 
			(
				id = (f as string)
				origin_text = getIniSetting ingfile "ID_Origin" id 
				val_key = getIniSetting ingfile "ID_KEY" id

				zh = getIniSetting ingfile languages_code[1] id
				en = getIniSetting ingfile languages_code[2] id
				jp = getIniSetting ingfile languages_code[3] id
				ko = getIniSetting ingfile languages_code[4] id

				--format "% - % \n" f origin_text

				row = #( val_key,origin_text,zh,en,jp,ko)
				append rows row

			)
		
		current_project_path = ingfile 
		if doesFileExist current_project_path then (
			ddlSecType.text = current_project_path
		)else(
			ddlSecType.text = ""
		)	
		
		addToLbxList lbxTranslatesUI rows
	)
	fn save_project ingfile = 
	(
		if doesFileExist ingfile do 
		(
			try( deleteFile ingfile )catch()
		)
		--files = getTranslateFiles()
		if current_script_path != undefined do 
		(
			setIniSetting ingfile "MXS" "Path" current_script_path
		)


		current_script_install_name = edit_script_name.text
		if current_script_install_name != undefined do
		(
			setIniSetting ingfile "MXS" "ScriptName" current_script_install_name
		) 

		current_script_install_path = edit_script_install_path.text
		if current_script_install_path != undefined do 
		(
			setIniSetting ingfile "MXS" "ScriptInstallPath" current_script_install_path
		)

		temp_name = regex_unchar edit_list_name.text 
		edit_list_name.text = temp_name
		
		if temp_name.count >= 4 do (
			word_languageList_name = temp_name
		)
		setIniSetting ingfile "MXS" "VariableName" word_languageList_name

		ids = get_dataview_row_ids lbxTranslatesUI 
		origins = get_dataview_col_data lbxTranslatesUI 2 
		
		for i = origins.count to 1 by - 1 do 
		(
			if origins[i].count < 1 do 
			(
				deleteItem origins i 
				deleteItem ids i 
			)
		)

		setIniSetting ingfile "MXS" "Count" (ids.count as string)
		save_to_ini ingfile "ID_Origin" ids origins
		
		keys = get_dataview_col_data lbxTranslatesUI 1 
		save_to_ini ingfile "ID_KEY" ids keys

		zhs = get_dataview_col_data lbxTranslatesUI 3 
		save_to_ini ingfile languages_code[1] ids zhs

		ens = get_dataview_col_data lbxTranslatesUI 4 
		save_to_ini ingfile languages_code[2] ids ens

		jps = get_dataview_col_data lbxTranslatesUI 5
		save_to_ini ingfile languages_code[3] ids jps

		kos = get_dataview_col_data lbxTranslatesUI 6
		save_to_ini ingfile languages_code[4] ids kos

		
			
		current_project_path = ingfile
		if doesFileExist current_project_path then (
			ddlSecType.text = current_project_path
		)else(
			ddlSecType.text = ""
		)
		messageBox currentLang[28] title: currentLang[29] beep: false
		--shellLaunch d ""
	)
	fn set_read_only index_col is_read_only = 
	(
		for i = 1 to lbxTranslatesUI.Rows.count do 
		(
			row = lbxTranslatesUI.Rows.item[i-1]
			row.cells.item[index_col].ReadOnly = is_read_only
		)
	)
	
	fn contains_text str_content text_ str_match_index = 
	(
		text_count = text_.count + 1 
		find_substring = str_content.Substring (str_match_index - text_count) text_count
		find_substring = filterString find_substring ";	\r\n "
		find_index = findString find_substring[1] text_
		--format "%- % \n" find_substring str_match.Index
		find_index
	)
	fn contains_dotnet str_content str_match_index = 
	(
		find_index1 = contains_text str_content "dotNetClass" str_match_index
		find_index2 = contains_text str_content "dotNetObject" str_match_index
		
		if find_index2 == undefined and find_index1 == undefined then 
		(
			 
		)else(find_index1 = 1)
		find_index1
	)
	fn contains_dotnet_ui str_content = 
	(
		find_index = findString str_content "System.Windows."
		find_index
	)
	fn contains_group str_content str_match_index = 
	(
		find_index2 = undefined
		--查找 group 
		find_index1 = contains_text str_content "group" str_match_index
		if find_index1 != undefined do 
		(
			find_index2 = contains_text str_content "GroupBox" str_match_index
			--放过 groupbox 
			if find_index2 == undefined then
			(
				find_index2 = find_index1
			)else(
				find_index2 = undefined
			)
		)

		find_index2
	)
	fn filter_string str_content = 
	(
		if edtFilter.selection == 1 do  
		(
			return true 
		)
		if edtFilter.selection == 2 do
		(
			return (contains_chinese str_content)
		)
		if edtFilter.selection == 3 do 
		(
			return (contains_japanese str_content)
		)
		if edtFilter.selection == 4 do 
		(
			return (contains_korea str_content)
		)
		true 
	)
	fn open_script_text script_path is_reload = 
	(

		content = (dotnetclass "System.IO.File").ReadAllText script_path Encoding 
		
		content = dotNetObject "System.String" content

		--匹配 双引号内容
		pattern = "\".*?\""
		rgx = dotNetClass "System.Text.RegularExpressions.Regex"

		matches = rgx.Matches content pattern


		
		string_list = #()
		for i = 0 to matches.count - 1 do 
		(
			--过滤语言
			if filter_string (matches.item[i].Value) do 
			(
				
				--format "Found: % = % \n" matches.item[i].Value matches.item[i].Index
				
				find_dotnet_ui = contains_dotnet_ui matches.item[i].Value
				if find_dotnet_ui != undefined do ( 
					--format "Dotnet UI -> %\n" matches.item[i].Value
					continue
				)
				
				string_value = regex_str matches.item[i].Value
				
				if string_value.count > 1 do 
				(

					find_group = contains_group content matches.item[i].Index

					if find_group != undefined  do 
					(
						format "Warn => group %  | Unable to process | open_script_text \n" matches.item[i].Value --matches.item[i].Index
					) 

					find_dotnet = contains_dotnet content matches.item[i].Index
					
					if find_dotnet == undefined do (
						append string_list string_value
					)
				)
				
			)

		)
		content = undefined
		
		string_list = makeUniqueArray string_list
		
		if is_reload then 
		(
			updataToLbxList lbxTranslatesUI string_list 	
		)else(
			_rTranslatesUI.lbxTranslatesUI.Rows.Clear()

			addTextToLbxList lbxTranslatesUI string_list 
		)

		current_script_path = script_path
		ddlInstalledScript.text = script_path

		current_project_path = undefined 
		ddlSecType.text = ""

		
	)	
	fn get_word = 
	(
		temp_word = getIniSetting work_space "Work" "Path"
		if temp_word != "" and doesFileExist temp_word do 
		(
			open_project temp_word
		)
	)
	fn save_word = 
	(
		if current_project_path != undefined do (
			setIniSetting work_space "Work" "Path" current_project_path
		)

	)
	fn init = 
	(
		setup_translates_ui() 
		
		get_word()
	)
	fn get_select_language = 
	(
		temp_id = #()
		temp_code = #()
		for i in btn_set_language.selection do 
		(
			append temp_code languages_code[i]
			append temp_id i
		)
		#(temp_id,temp_code)
	)
	fn create_languae_list language_index = 
	(
		col_index = language_index + 2 

		language_script = StringStream ""

		format "------------ % ------------------------ \n" (btn_set_language.items[language_index]) to:language_script

		format "%_languages[%] = #()\n" word_languageList_name language_index to:language_script
		id = 0 
		for i = 0 to lbxTranslatesUI.Rows.count - 1 do 
		(
			--row = lbxTranslatesUI.Rows.item[i]
			origin_text = get_dataview_row_col_data lbxTranslatesUI i 2 
			if origin_text.count >= 1 do 
			( 
				id += 1 
				l_value = get_dataview_row_col_data lbxTranslatesUI i col_index 
				if l_value.count >= 2 then  
				(

				)else(
					l_value = origin_text
				)
				format "%_languages[%][%] = \"%\"\n" word_languageList_name language_index id l_value to:language_script
			)

		)
		language_script as string
	)

	fn create_new_script_to_id origin_script new_script = 
	(
		content = (dotnetclass "System.IO.File").ReadAllText origin_script Encoding
		content = dotnetObject "System.String" content

		--选择的语言 的 序号 
		selected_language_index = get_select_language()
		
		selected_language_name = selected_language_index[2]
		selected_language_index = selected_language_index[1]

		if selected_language_index.count == 0 do (
			return false 
		)

		language_script = StringStream ""
		--format "languages_list =%\n" (get_select_language()) to:language_script
		format "--languages = %\nglobal %;\n(\n" btn_set_language.items word_languageList_name to:language_script
		format "global %_languages = %\n" word_languageList_name selected_language_name to:language_script
		format "sys_lang = findItem %_languages ((sysinfo.getmaxlanguage())[5]);if sys_lang == 0 do (sys_lang = 1);\n" word_languageList_name to:language_script

		for o in selected_language_index do 
		(
			text_ = create_languae_list o 
			format "%\n" text_ to:language_script 
		)


		format "global % = %_languages[sys_lang];\n);\n" word_languageList_name word_languageList_name to:language_script
		

		--(dotnetclass "System.IO.File").WriteAllText new_script (language_script as string) Encoding

		for i = 0 to lbxTranslatesUI.Rows.count - 1 do 
		(
			row = lbxTranslatesUI.Rows.item[i]
			id = i + 1 
			id_text = word_languageList_name +"[" + (id as string)  + "]"

			origin_text = get_dataview_row_col_data lbxTranslatesUI i 2 
			if origin_text.count < 1 do (continue)

			origin_text = "\"" + origin_text + "\""

			find_index = content.IndexOf origin_text
			if find_index >= 0 do 
			(
				find_group = contains_group content find_index
				
				if find_group == undefined then (
					content = dotnetObject "System.String" (content.Replace origin_text id_text)
					format "% -> % => % \n" i origin_text id_text
				)else(
					format "--Warn => group %  | Unable to process\n" origin_text
					format "--Warn => group %  | Unable to process\n" (regex_str origin_text) to:language_script --matches.item[i].Index
				)
			)
			
			
		)
		format "\n--Add the code to your script\n" to:language_script

		format "/*\ndropdownlist switch_language \"\" items:%\n" selected_language_name to:language_script
		format "on switch_language selected arg do\n(\n	global % = %_languages[arg];\n" word_languageList_name word_languageList_name to:language_script
		format "\n----rollout panle  \n"  to:language_script
		format "	try(destroyDialog rolloutName)catch();\n	createDialog rolloutName\n"  to:language_script
		format "\n----rolloutFloater panle  \n"  to:language_script
		format "	try(removeRollout rolloutName rolloutFloaterName )catch();\n	addRollout rolloutName rolloutFloaterName\n)\n*/\n"  to:language_script

		format "------------ Translates End ------------------------;\n" to:language_script

		language_script = language_script as string
		content = content.Insert 0 language_script  

		(dotnetclass "System.IO.File").WriteAllText new_script content Encoding
		content = undefined

		messageBox currentLang[28] title: currentLang[29] beep: false
	)
	--直接替换字符的翻译版本
	fn create_new_script origin_script new_script = 
	(
		
		content = (dotnetclass "System.IO.File").ReadAllText origin_script Encoding
		content = dotnetObject "System.String" content

		language_index = btn_language.selection + 2

		for i = 0 to lbxTranslatesUI.Rows.count - 1 do 
		(
			row = lbxTranslatesUI.Rows.item[i]
			temp_value = row.cells.item[1].value
			origin_text = get_dataview_row_col_data lbxTranslatesUI i 2 
			if origin_text.count >= 1 do 
			(
				
				--新的语言文本
				new_text = get_dataview_row_col_data lbxTranslatesUI i language_index 
				if new_text.count >= 1 do (
					content = dotnetObject "System.String" (content.Replace origin_text new_text)
				)
			)
		)
		
		(dotnetclass "System.IO.File").WriteAllText new_script content Encoding
		content = undefined
		messageBox currentLang[28] title: currentLang[29] beep: false
	)

	fn create_new_script_TextKey origin_script new_script = 
	(
		
		content = (dotnetclass "System.IO.File").ReadAllText origin_script Encoding
		content = dotnetObject "System.String" content
		
		key_index = 0 

		for i = 0 to lbxTranslatesUI.Rows.count - 1 do 
		(
			row = lbxTranslatesUI.Rows.item[i]
			key_value = row.cells.item[1].value
			
			if key_value.count >= 2 do 
			(
				key_index += 1

				origin_text = get_dataview_row_col_data lbxTranslatesUI i 2 

				origin_text = "\"" + origin_text + "\""

				--新的语言文本
				new_text = "~" + key_value + "~"
				
				content = dotnetObject "System.String" (content.Replace origin_text new_text)
				
				--format "% -> % => % == > %\n" i temp_value origin_text new_text
			)
		)
		if key_index > 0 then 
		(
			(dotnetclass "System.IO.File").WriteAllText new_script content Encoding
			format "%\n" new_script
			content = undefined

			return true 
		)else(
			return false
		)
	)
	fn create_language_resource_by_TextKey new_language_file language_index = 
	(
		
		--content = (dotnetclass "System.IO.File").ReadAllText origin_script Encoding
		--content = dotnetObject "System.String" content
		language_resource = StringStream ""

		keys_ = #()
		keys_language_text = #()

		key_index = 0 
		for i = 0 to lbxTranslatesUI.Rows.count - 1 do 
		(
			row = lbxTranslatesUI.Rows.item[i]
			key_value = row.cells.item[1].value
			--如果没有 TextKey 放弃
			if key_value.count >= 2 do 
			(
				key_index += 1

				find_old_key = findItem keys_ key_value
				if find_old_key > 0 then 
				(
					-- 如果有相同的 key ,就用同一个KEY的第一个文本
					language_text = keys_language_text[find_old_key]
				)else(
				
					--新的语言文本
					language_text = get_dataview_row_col_data lbxTranslatesUI i language_index 
					 
					if language_text.count >= 1 then 
					(
						
					)else(
						--如果翻译文本为空，就使用原始文本
						language_text = get_dataview_row_col_data lbxTranslatesUI i 2
					)

					append keys_ key_value
					append keys_language_text language_text

				)
				format "%	=	\"%\"\n" key_value language_text to:language_resource
			)
		)
		if key_index > 0 then 
		(
			language_resource = language_resource as string
			(dotnetclass "System.IO.File").WriteAllText new_language_file language_resource Encoding
			language_resource = undefined
			return true
		)else(
			return false
		)
		
	)
	on _rTranslatesUI open do 
	(
		
		btn_paste_zh.text = ("Paste To " + languages[1])
		btn_paste_en.text = ("Paste To " + languages[2])
		btn_paste_jp.text = ("Paste To " + languages[3])
		btn_paste_Ko.text = ("Paste To " + languages[4])

		init()
	)

	on _rTranslatesUI close do 
	(
		save_word()
	)
	on btn_new_script_transl pressed do 
	(
		d = getFilenamePath (getThisScriptFilename())	
		local textfile = getOpenFileName caption:currentLang[30] types:"ms (*.ms)|*.ms|mcr (*.mcr)|*.mcr|" filename:d
		if textfile != undefined do 
		(
			open_script_text textfile false
			messageBox currentLang[31] title: currentLang[29] beep: false

		)
	)
	on btn_open_project pressed do 
	(
		d = getFilenamePath (getThisScriptFilename())	
		local textfile = getOpenFileName caption:currentLang[32] types:"ingProject (*.ingProject)|*.ingProject|" filename:d
		
		if textfile != undefined do
		(
			open_project textfile
		)
	)
	on btn_save_project pressed do 
	(
		if current_project_path == undefined then 
		(
			if current_script_path != undefined then (
				d = (getFilenamePath current_script_path) + (getFilenameFile current_script_path)
			)else(
				d = getFilenamePath (getThisScriptFilename())	
			)
				
			local textfile = getSaveFileName caption:"保存 翻译项目 " types:"ingProject (*.ingProject)|*.ingProject|" filename:d
			if textfile != undefined do (
				save_project textfile;save_word()
			)
			
		)else(
			save_project current_project_path;save_word()
		)
	)
	on btn_copy pressed do 
	(
		get_dataview_col_text lbxTranslatesUI 2 
		
	)
	--首字母 大转换
	on btn_key_initial_capitalization pressed do 
	(
		for i = 0 to lbxTranslatesUI.Rows.count - 1 do 
		(
			row = lbxTranslatesUI.Rows.item[i]
			temp_value = row.cells.item[1].value
			
			if temp_value != undefined and temp_value != "" do 
			(
				new_value = TextInfo.TextInfo.ToTitleCase temp_value
				row.cells.item[1].value = (regex_unchar new_value)
			)
		)
	)
	on btn_paste_to_Key pressed do 
	(
		paste_to_languages 1 
		set_read_only 1 false

	)
	on btn_paste_zh pressed do 
	(
		paste_to_languages 3 
	)
	on btn_paste_en pressed do 
	(
		paste_to_languages 4 
	)
	on btn_paste_jp pressed do 
	(
		paste_to_languages 5 
	)
	on btn_paste_Ko pressed do 
	(
		paste_to_languages 6

	)
	
	
	on btnExportLanguagesList pressed do 
	(


		temp_name = regex_unchar edit_list_name.text 
		edit_list_name.text = temp_name
		if temp_name.count < 4 do (
			messageBox currentLang[34] 
			return false
		) 
		word_languageList_name = temp_name
		
		select_langua = get_select_language()
		if select_langua[1].count < 1 do (
			messageBox currentLang[35]
			return false 
		)
		
		if doesFileExist current_script_path then 
		(
			test_file = (getFilenamePath current_script_path) + (getFilenameFile current_script_path) + "_MultLang " + (getFilenameType current_script_path)
			local textfile = getSaveFileName caption:"生成 多语音 版本 " types:"ms (*.ms)|*.ms|All Files (*.*)|*.*|" filename:test_file
			if textfile != undefined do 
			(
				create_new_script_to_id current_script_path textfile
			)
			
		)

	)
	
	on btnExportLanguages pressed do 
	(
		if doesFileExist current_script_path then 
		(
			
			test_file = (getFilenamePath current_script_path) + (getFilenameFile current_script_path) + "_ "+ btn_language.selected + (getFilenameType current_script_path)

			local textfile = getSaveFileName caption:"生成 翻译 版本 " types:"ms (*.ms)|*.ms|All Files (*.*)|*.*|" filename:test_file
			if textfile != undefined do 
			(
				create_new_script current_script_path textfile
			)
			
		)

		--exportLanguages()
	)
	on btn_get_install_path pressed do (
		
		path_ = getdir #scripts
		
		install_path = getSavePath caption:currentLang[38] initialDir:path_
		if install_path != undefined do 
		(
			current_script_install_path = GetRelativePath install_path (getdir #maxroot)
			edit_script_install_path.text = current_script_install_path
		)
	)

	on btn_GenerateMultLanguage pressed do 
	(
		if current_project_path != undefined do 
		(
			d = getFilenamePath current_project_path + "Translate\\"
			for i=1 to languages_code.count do 
			(
				new_dir = d + (languages_code[i]) +"\\"+edit_script_install_path.text
				try(
					makeDir new_dir
					format "makeDir => %\n" new_dir
					new_language_file = new_dir + "\\" + current_script_install_name +".ms.res"
					language_index = i + 2 
					haskey = create_language_resource_by_TextKey new_language_file language_index
					if not haskey do (
						messageBox currentLang[39] title: currentLang[40] beep: false
						return false
					)
				)catch()
				
			)
			if doesFileExist current_script_path do 
			( 
				new_dir = d + current_script_install_path 
				makeDir new_dir 

				new_script = new_dir +"\\" + current_script_install_name + (getFilenameType current_script_path)
				haskey = create_new_script_TextKey current_script_path new_script
				if haskey then (
					messageBox d title: currentLang[29] beep: false
				)else(

				)
			)
		)
	)


	on btnReloadFilter pressed do (
		if doesFileExist current_script_path do 
		(
			open_script_text current_script_path true 
			messageBox currentLang[41] title: currentLang[29] beep: false
		)
	)
	
	
	on lbxTranslatesUI MouseDoubleClick s a do (
		
	)
	on lbxTranslatesUI CellClick sender arg do
	(
		/* npc_SelectedCells = sender.SelectedCells
		selceted_rowindex = arg.rowindex
		--Columnindex 列数 ，rowindex 行数
		temp_text = get_dataview_row_col_data sender arg.rowindex arg.Columnindex
		if temp_text != undefined do
		(
			format "% = % : %\n" temp_text arg.rowindex arg.Columnindex
		) */
		
	)
	on lbxTranslatesUI MouseUp do	
	(		
		
		/* pos = lbxTranslatesUI.mousePosition
		format "pos % - % \n" pos.x pos.y 
		
		row = lbxTranslatesUI.CurrentCell.RowIndex 
		col = lbxTranslatesUI.CurrentCell.ColumnIndex 
		format "sel % - % \n" row col 

		hit = lbxTranslatesUI.HitTest pos.x pos.y 

		format "Hit % - % \n" hit.RowIndex hit.ColumnIndex */
	)
)

rollout _rAbout "About" 
(
	label lbl0 currentLang[1]
	label lbl2 "4698to (738746223@qq.com)"
	label lblDummy ""
	hyperlink hyperLink1 "https://sundaybox.cc" address: "https://sundaybox.cc/pages/50d3fa" align: #center
)
addRollout _rTranslatesUI fTranslates rolledUp: false
addRollout _rAbout fTranslates rolledUp: true
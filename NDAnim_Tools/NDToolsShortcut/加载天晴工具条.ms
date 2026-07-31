/*
QQ:738746223

天晴工具盒里的 加载 天晴工具条
*/
------------------------------------------------------
try(DestroyDialog mergaNDToolsBar)
catch()

rollout mergaNDToolsBar "天晴动作脚本工具条 【0.2】" width:420 height:320
(
	group "启动项设置 - 【取消设置】 需重启3ds Max后生效"
	(
		checkbox btn_set_auto_updata "启动3dsMax时 自动检查更新" across:2
		HyperLink lbl_auto_updata "详细" address:"https://sundaybox.cc/supportHelp/" color:(color 0 255 255) hoverColor:(color 0 255 255)  align:#right


		checkbox btn_set_time_linetools "时间轴 自定义工具栏" across:2
		HyperLink lbl_time_linetools "详细" address:"https://sundaybox.cc/pages/a93a52/" color:(color 0 255 255) hoverColor:(color 0 255 255)  align:#right


		checkbox btn_set_load_selectionSets "合并导入选择集" across:2
		HyperLink lbl_load_selectionSets "详细" address:"https://sundaybox.cc/pages/07f0d7/" color:(color 0 255 255) hoverColor:(color 0 255 255)  align:#right

		checkbox btn_set_fix_MaxSp4_save_bug "修复Max2015 sp4保存路径问题" across:2
		HyperLink lbl_MaxSp4_save_bug "详细" address:"https://sundaybox.cc/pages/c5caa2/" color:(color 0 255 255) hoverColor:(color 0 255 255)  align:#right


	)
	group "" (
	    -- Group body.
		button btn_fix_ui "加载工具条" width:114 height:28 tooltip:"修复工具栏" across:3
		button btn_uninstall "移除工具条" width:114 height:28 enabled:true Tooltip:"不用,可卸载"
		button btn_open_updatatest "打开更新提示" width:114 height:28
	)
    imgTag ndtools_vx_pic "ndtools_vx_pic" transparent:(color 0 255 0) width:392 height:126 

	HyperLink lbl_01 "sundaybox.cc" address:"https://sundaybox.cc" color:(color 0 255 255) hoverColor:(color 0 255 255)  align:#center

	--label la01 ""
	----------------------------------------------------------------------------------------------------------------------
	local startup_path = (getdir #startupScripts) + "\\"
	local target_path = (getDir #scripts) + @"\NDTools\Startup\"
	local target_flies = #("TimeLine_Tools_Bar.ms","NDtools_2015_StartupND.ms","save&loadSelectionSets.mse","Max2015sp3_open_save.ms","NDTools.ms")

	fn test_startup =
	(
		_flie = startup_path + target_flies[1]
		btn_set_time_linetools.checked = doesfileexist _flie
		
		_flie = startup_path + target_flies[2]
		btn_set_auto_updata.checked = doesfileexist _flie
		
		_flie = startup_path + target_flies[3]
		btn_set_load_selectionSets.checked = doesfileexist _flie

		_flie = startup_path + target_flies[4]
		btn_set_fix_MaxSp4_save_bug.checked = doesfileexist _flie
		
		--删除旧的
		old_startup = #("NDtools_2015_Startup.mse","TimeLine_Tools_Bar_v3.1_bate.mse","NDtools_2015_StartupND.mse")
		for file_ in old_startup do 
		(
			old_ = startup_path + file_
			if doesfileexist old_ do (try(deleteFile old_) catch())
		)
	)
	fn set_startup state startup_file target_flie =
	(
		if doesfileexist target_flie then
		(
			if doesfileexist startup_file do 
			(
				try(deleteFile startup_file)catch(format "删除失败 % \n" startup_file)
			)
			if state and (not doesfileexist startup_file) do
			(
				try(
					copyFile target_flie startup_file
					format "copy % -> %\n" target_flie startup_file
				)catch()
				try(
					filein startup_file
				)catch()
			)
		)else(
			messageBox "未正确安装 【天晴 盒子】 F11 查看具体细节...\n" 
			format "不存在 -> %\n" target_flie
		)
	)
	
	fn deleteUIXMLNode UIxml =
	(

		local xmlDoc = (dotNetObject "system.xml.xmlDocument")
		xmlDoc.load UIxml
		--先删除旧的工具栏
		local temp_dele_node = #()
		local UIwindow = xmldoc.getElementsByTagName("Window")
		for i=1 to UIwindow.count do
		(
			local temp = UIwindow.ItemOf[(i - 1)]
			if temp != undefined do
			(
				local WindowName = temp.GetAttribute("name")
				--format "i:: % N::% \r\n" i WindowName
				if WindowName == "NDTools01" or WindowName == "NDTools02" do
				(
					--temp.ParentNode.RemoveChild(temp)
					append temp_dele_node temp
				)
				if WindowName == "NDTools02" do
				(
					append temp_dele_node temp
					--temp.ParentNode.RemoveChild(temp)
				)
				if WindowName == "ND_Animation_Layers" do
				(
					append temp_dele_node temp
					--temp.ParentNode.RemoveChild(temp)
				)

			)
		)
		for i in temp_dele_node do
		(
			if i != undefined do (
				try (i.ParentNode.RemoveChild(i))catch()
			)
		)
		xmlDoc.save UIxml;cui.loadConfig UIxml
		xmlDoc = undefined;CUIWindows = undefined ;
	)

	fn uninstall_ND =
	(

		for files in target_flies do
		(
			thefile = startup_path + files
			if doesFileExist thefile do
			(
				try (deleteFile thefile)catch()
			)
		)
		TQAnimationTool = (getDir #scripts) + "\\TQAnimationTool.ini"
		if doesfileexist TQAnimationTool do
		(
			try(deleteFile TQAnimationTool)catch()
		)
		/*
		try(
			(dotnetClass "System.IO.Directory").Delete ((getDir #maxroot) + @"UI_ln\Icons\cstoolIcons") true
			(dotnetClass "System.IO.Directory").Delete ((getDir #scripts) + @"\NDTools") true
		)catch(messageBox "好像是没安装天晴动作脚本工具组")
		*/
	)
	
	
	
	--------------------------------------------------------------------------------
	on btn_set_time_linetools changed arg do 
	(
		startup_ = startup_path + target_flies[1]
		_flie =  target_path + target_flies[1]
		set_startUp arg startup_ _flie
	)

	on btn_set_auto_updata changed arg do
	(
		
		startup_ = startup_path + target_flies[2]
		_flie = target_path + target_flies[2]
		set_startup arg startup_ _flie
	)
	
	on btn_set_load_selectionSets changed arg do
	(
		startup_ = startup_path + target_flies[3]
		_flie = target_path + target_flies[3]
		set_startup arg startup_ _flie
	)

	on btn_set_fix_MaxSp4_save_bug changed arg do
	(
		startup_ = startup_path + target_flies[4]
		_flie = target_path + target_flies[4]
		set_startup arg startup_ _flie
	)


	on mergaNDToolsBar open do
	(
		test_startup()
		imgPath = (getDir #scripts) + @"\NDTools\vx6.png"
		if not doesFileExist imgPath do 
		(
			imgPath = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\vx6.png"
		)
		if doesFileExist imgPath do (
			ndtools_vx_pic.bitmap = openBitmap imgPath
		)
	)
	
	
	on btn_uninstall pressed do
	(
		is_uninstall = queryBox "是否移除? \r\n" title:"移除天晴工具条"
		if is_uninstall do (
			try(
				--从UI配置中删除工具栏
				deleteUIXMLNode (cui.getConfigFile())
			)catch(format "错误:% \n" "deleteUIXMLNode")
			
			--删除 NDTools 文件夹 
			--uninstall_ND()
			
			messageBox "删除完成"
		)

	)
	on btn_fix_ui pressed do
	(
		tools_install = ((getdir #maxroot)+"scripts\\NDTools\\tools_install.ms")
		NDTools_ms = target_path +"NDTools.ms"
		startuo_ndtools = startup_path +"NDTools.ms"

		if doesFileExist startuo_ndtools do 
		(
			deleteFile startuo_ndtools
		)

		if doesFileExist NDTools_ms then 
		(
			try (
				copyFile NDTools_ms startuo_ndtools
				filein NDTools_ms
			)catch(format "缺少：NDTools.ms\n")
			
			if doesFileExist tools_install then (
				try (
					filein tools_install
					messageBox "完成，如果下次工具条不见了，再次加载即可         	"
				)catch()
			)else(
				messageBox tools_install title:"缺少：tools_install.ms - 无法加载"
			)
		)else(
			messageBox NDTools_ms title:"缺少：NDTools.ms - 无法加载"
		)
	)
	on btn_open_updatatest pressed do 
	(
		startup_file = startup_path + target_flies[2]
		if doesFileExist startup_file then  
		(
			if NDBoxDownload_updata_rollout != undefined and try_test_ndboxUp_init != undefined then 
			(
				try_test_ndboxUp_init.try_get_up_data()
				try_test_ndboxUp_init.test_type = "1"

				
				createDialog NDBoxDownload_updata_rollout
				NDBoxDownload_updata_rollout.backen = try_test_ndboxUp_init
				NDBoxDownload_updata_rollout.show_msg()
			)else(
				filein startup_file
			)
		)else(
			messageBox "请先勾选启动3dsMax时 自动检查更新"
		)
	)
)
createDialog  mergaNDToolsBar


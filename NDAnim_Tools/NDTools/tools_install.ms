/*
--2020.01.01 4.43
----Maxscript
--author:4698to
--E-Mail:738746223@qq.com
--99U:199505
--添加天晴工具栏

2023-11-27
添加检测 C3 ，如没有就到合并相关工具栏

*/
(
	try (filein ((getdir #startupScripts) +"\\NDTools.ms"))catch(print "缺少：NDTools.ms")
	
	is_c3_ok = false
	c3 = (getdir #maxroot) + @"\plugins\C3SkinCharacter.dle"
	if doesFileExist c3 do 
	(
		is_c3_ok = true 
	)

	fn removetoolsbar_xml UIxml =
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
				if WindowName == "NDTools01" or WindowName == "NDTools02" do
				(
					append temp_dele_node temp
				)
				if WindowName == "NDTools03" do
				(
					append temp_dele_node temp
				)
				if WindowName == "ND_Animation_Layers" do
				(
					append temp_dele_node temp
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
	fn merge_ndtools_XMl xmlNodes UIxml=
	(
		--local UIxml = cui.getConfigFile()
		local xmlDoc = (dotNetObject "system.xml.xmlDocument")
		xmlDoc.load UIxml

		------------------------------------------------------------
		CUIWindows  = xmldoc.getElementsByTagName("CUIWindows")
		if CUIWindows != undefined do
		(
			for i=1 to xmlNodes.count do
			(
				local temp = xmlNodes.itemof[(i - 1)]
				local newnode = xmlDoc.ImportNode temp true
				local WindowName = temp.GetAttribute("name")
				--format "i:: % N::% \r\n" i WindowName
				if WindowName == "NDTools03" then (
					
					if is_c3_ok do 
					(
						CUIWindows.ItemOf[0].AppendChild newnode
					)
				)else(
					CUIWindows.ItemOf[0].AppendChild newnode
				)
			)
		)
		xmlDoc.save UIxml
		------------------------------------------------------------
		--cui.saveConfigAs ((getdir #ui) + "NDTools_Updata_temp2.cuix")
		xmlDoc = undefined ; CUIWindows = undefined ;--UIxml = undefined
	)
	fn install_ndtools_Toolbar =
	(
		--cui.saveConfigAs ((getdir #ui) + "NDTools_Updata_temp.cuix")
		local temp_cuix = cui.getConfigFile()
		removetoolsbar_xml temp_cuix --先删除旧的工具栏
		--local temp_path = (getdir #ui)+"NDTools_Updata_node.cuix" --下载来的更新的
		local temp_path = (getdir #maxroot)+"scripts\\NDTools\\NDTools_Updata_node.cuix"

		local xmlDoc_local = dotNetObject "system.xml.xmlDocument"
		xmlDoc_local.load temp_path

		local UIxmlwindow = xmlDoc_local.getElementsByTagName("Window")
		if UIxmlwindow != undefined do (

			merge_ndtools_XMl UIxmlwindow temp_cuix --然后合并新的
		)
		UIxmlwindow = undefined ;xmlDoc_local = undefined--default_UI = undefined
	)
	--删除旧的Ui配置
	fn try_delete_ui_file =
	(
		ClearFiles = getfiles ((getdir #ui)+"NDTools4*")
		for o in ClearFiles do
		(
			try(deleteFile o) catch()
		)
	)
	--cui.saveConfigAs ((getdir #ui) + "NDTools_Updata_temp.cuix")
	colorman.reInitIcons() -- 重新加载图标

	try_delete_ui_file()

	install_ndtools_Toolbar() --删除旧的工具栏,合并新工具栏
	cui.loadConfig (cui.getConfigFile())  -- 重新加载UI配置

	cui.showToolbar "NDTools02" -- 显示工具栏
	cui.showToolbar "NDTools01"
	cui.showToolbar "ND_Animation_Layers"
	if is_c3_ok do 
	(
		cui.showToolbar "NDTools03"
	)
)
/*
actionMan.saveKeyboardFile (getdir #ui+"NDTools4.46.kbdx") -- 保存快捷键

try (filein (getdir #startupScripts +"\\"+"NDTools.ms"))catch()
try (cui.loadConfig (getdir #ui+"NDTools4.46.cuix"))catch()

colorman.reInitIcons()

actionMan.loadKeyboardFile (getdir #ui+"NDTools4.46.kbdx") -- 加载快捷键
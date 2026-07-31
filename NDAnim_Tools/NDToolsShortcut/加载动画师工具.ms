/*
QQ:738746223

天晴工具盒里的 加载 BulletScripts

2025-02-24

*/
------------------------------------------------------
try(DestroyDialog BulletScriptsBar)
catch()

rollout BulletScriptsBar "动画师工具条1.0.1" width:300 height:130
(
	group "是否启动Max时加载工具 - 更改需重启Max后生效"
	(
		--checkbox btn_Security "子弹 - 非官方是杀毒检测" 
		checkbox btn_1 "" align:#center
		checkbox btn_2 "" align:#center
		checkbox btn_3 "" align:#center
		checkbox btn_4 "" align:#center

	)
	
	HyperLink lbl_01 "bullet4869.notion.site" address:"https://bullet4869.notion.site/176edaf7094b4c889abc8c96eea48240" color:blue hoverColor:(color 0 255 255)  align:#center across:2
	HyperLink lbl_02 "sundaybox.cc" address:"sundaybox.cc" color:blue hoverColor:(color 0 255 255)  align:#center
	----------------------------------------------------------------------------------------------------------------------
	local check_files = #(),check_files_path=#()
	
	fn test_startup =
	(
		--btn_Security.checked = doesfileexist check_files[1]
		for i = 1 to 4 do 
		(
			BulletScriptsBar.controls[i+1].checked = doesfileexist ((getdir #startupScripts) +"\\"+ check_files[(i)])
			BulletScriptsBar.controls[i+1].caption = check_files[(i)]
		)
	)
	fn set_startup state startup_file_name =
	(
		startup_file = (getdir #startupScripts) + "\\" + startup_file_name
		target_flie = (getDir #scripts) + "\\BulletScripts\\Startup\\" + startup_file_name

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
					filein target_flie
					format "copy % -> %\n" target_flie startup_file
				)catch()
			)
		)else(
			messageBox target_flie title:"不存在" 
			format "不存在 -> %\n" target_flie 
		)
	)
	
	--------------------------------------------------------------------------------
	/* on btn_Security changed arg do
	(
		set_startup arg check_files[1] check_files[4]
	) */
	on btn_1 changed arg do 
	(
		set_startup arg check_files[1] 
		test_startup()
	)
	on btn_2 changed arg do 
	(
		set_startup arg check_files[2]
		test_startup()

	)
	on btn_3 changed arg do 
	(
		set_startup arg check_files[3]
		test_startup()

	)
	on btn_4 changed arg do 
	(
		set_startup arg check_files[4]
		test_startup()

	)
	on BulletScriptsBar open do
	(
		
		check_files[1] = "BsCleanVirusStartup.ms"
		check_files[2] = "BsKeyToolsMacro.ms"
		check_files[3] = "BsKeyToolsMenuBar.ms"
		check_files[4] = "BulletKeyTools.ms"

		--check_files_path = getFiles (((getDir #scripts) + "\\BulletScripts\\Startup\\")+ "*.ms")
		
		test_startup()
	)

)
createDialog  BulletScriptsBar


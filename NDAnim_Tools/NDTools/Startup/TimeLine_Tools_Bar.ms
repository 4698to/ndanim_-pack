/*
---------------------------------------

/*2017-12-26
JiRts_Anim_Tools_Bar v_Joe.10

2018-1-20
joe_JiRts_Anim_Tools_Bar_v3.1_bate
---------------------------------------
2023-11-26
v3.2_bate


2025-03-25

*/



global atimeline_toolsbar_roll
global roll_about
if atimeline_toolsbar_roll != undefined do (
	try(
		cui.unRegisterDialogBar atimeline_toolsbar_roll
		destroydialog atimeline_toolsbar_roll
	)catch()

)


-- 工具条最小长度是 1800
rollout atimeline_toolsbar_roll "JiRts_Anim_Tools_Bar v_Joe.12" width:1800 height:34
(
						  --1,2  , 3 ,4  ,5  ,6  ,7  ,8   ,9
	local btn_pos_start = #(0,130,340,610,840,920,970,1265,1425)

	button	btn_close				"!"				pos:[0,5]		width:8		height:24   toolTip:"关闭工具栏"
	button	btn_ReStartMax			"<"			pos:[8,5]		width:24	height:24	toolTip:"重启MAX"
	button btn_ReSet				">"			pos:[32,5]		width:24	height:24	toolTip:"重置MAX"
	button	btn_RunSpt				"助"			    pos:[56,5]		width:24	height:24	toolTip:"Updates"

	----------------------------------------------------------------------------------------------------------------------------
	--预留按键                 --按键上显示的字符   位置             宽            高           鼠标提示    false不启用按键  true 启用
	button btn_A_customize_01         "..."           pos:[110,5]     width:40    height:20   toolTip:"..."   enabled:false
	button btn_A_customize_02         "..."           pos:[150,5]     width:40    height:20   toolTip:"..."   enabled:false
	button btn_A_customize_03         "..."           pos:[190,5]     width:40    height:20   toolTip:"..."   enabled:false
	button btn_A_customize_04         "..."           pos:[230,5]     width:40    height:20   toolTip:"..."   enabled:false
	button btn_A_customize_05         "..."           pos:[270,5]     width:40    height:20   toolTip:"..."   enabled:false

	----------------------------------------------------------------------------------------------------------------------------

	button  btn_B_customize_01 "..." pos:[340,5] width:40 height:20 enabled:false
	button	btn_B_customize_02 "..." pos:[380,5] width:40 height:20 enabled:false
	button	btn_B_customize_03 "..." pos:[420,5] width:40 height:20 enabled:false
	button 	btn_B_customize_04 "..." pos:[460,5] width:40 height:20 enabled:false
	button  btn_B_customize_05 "..." pos:[500,5] width:40 height:20 enabled:false
	button  btn_B_customize_06 "..." pos:[540,5] width:40 height:20 enabled:false
	----------------------------------------------------------------------------------------------------------------------------

	button	btn_C_customize_01 "..." pos:[610,5] width:40	height:20	toolTip:"" enabled:false
	button	btn_C_customize_02 "..." pos:[650,5] width:40	height:20	toolTip:"" enabled:false
	button	btn_C_customize_03 "..." pos:[690,5] width:40	height:20	toolTip:"" enabled:false
	button	btn_C_customize_04 "..." pos:[730,5] width:40	height:20	toolTip:"" enabled:false
	button	btn_C_customize_05 "..." pos:[770,5] width:40	height:20	toolTip:"" enabled:false
	----------------------------------------------------------------------------------------------------------------------------


	checkbox	chb_Lock ""	pos:[840,5]	width:20 height:24	checked:true	toolTip:"锁定对象变换轴"
	label	lbl1 "锁定"			pos:[860,8]		width:30	height:24
	----------------------------------------------------------------------------------------------------------------------------
	button	btn_Boxmode	"[ Box ]" pos:[920,5] width:50	height:20	toolTip:"显示为外框"

	----------------------------------------------------------------------------------------------------------------------------
	checkbutton btn_UHmesh "{ Mesh }" pos:[btn_pos_start[7],5] width:50 height:20 toolTip:""
	checkbutton btn_UHhelp "{ Help }" pos:[(btn_pos_start[7]+50),5] width:50 height:20 toolTip:""
	checkbutton btn_UHbone "{ Bone }" pos:[(btn_pos_start[7]+100),5] width:50 height:20 toolTip:""
	checkbutton	btn_UHCS "[ Bip ]" pos:[(btn_pos_start[7]+150),5]	width:50 height:20	highlightColor:	(color 214 148 25)	toolTip:"隐藏显示BIP"
	checkbutton	btn_UHBN "[ Bone ]"	pos:[(btn_pos_start[7]+200),5] width:50	height:20	highlightColor:	(color 214 148 25)	toolTip:"隐藏显示Bone"
	----------------------------------------------------------------------------------------------------------------------------

	spinner	sp_start "Start:" pos:[btn_pos_start[8],8]	width:50	height:20	range:[-1e+008,1e+008,0]	type:#integer scale:1
	spinner	sp_end "End:"	pos:[(btn_pos_start[8]+83),8]	width:50	height:20	range:[-1e+008,1e+008,100]	type:#integer scale:1
	----------------------------------------------------------------------------------------------------------------------------
	
	checkbutton	ckb_speed1		"1/4x"			pos:[btn_pos_start[9],5]	width:30	height:20	highlightColor:	(color 102 84 204)
	checkbutton	ckb_speed2		"1/2x"			pos:[(btn_pos_start[9]+30),5]	width:30	height:20	highlightColor:	(color 192 192 255)
	checkbutton	ckb_speed3		"1x"			pos:[(btn_pos_start[9]+60),5]	width:30	height:20	highlightColor:	(color 255 229 8)
	checkbutton	ckb_speed4		"2x"			pos:[(btn_pos_start[9]+90),5]	width:30	height:20	highlightColor:	(color 244 165 112)
	checkbutton	ckb_speed5		"4x"			pos:[(btn_pos_start[9]+120),5]	width:30	height:20	highlightColor:	(color 216 34 13)

	local btn_group_customize_A =#(),btn_group_customize_B =#(),btn_group_customize_C =#(),msefile_
	local roll_width = (dotnetClass "System.Windows.Forms.Screen").PrimaryScreen.Bounds.Width
	local INIDataPath = (getDir #Scripts) + "\\TQAnimationTool.ini"
	local root_path = undefined

	-------------------------------
	--设置定向以脚本保存目录
	fn set_customize_path = 
	(
		the_path = getSavePath caption:"选择脚本文件夹" initialDir:root_path
		if the_path != undefined do 
		(
			setINISetting INIDataPath "TimeLine_Tools" "Path" the_path
			root_path = the_path
			return true 
		)
		false
	)
	fn get_customize_path = 
	(
		if doesFileExist INIDataPath then  
		(
			the_path = getINISetting INIDataPath "TimeLine_Tools" "Path"
			if doesFileExist the_path then 
			(
				root_path = the_path 
			)else(
				root_path = (getdir #scripts) +"\\NDTools\\TimeLine_Tools"
			)
		)else(
			root_path = (getdir #scripts) +"\\NDTools\\TimeLine_Tools"
		)
	)
	fn find_scripts =
	(
		print(root_path)
		msefile_ =#()
		join msefile_ (getFiles (root_path +"\\*.mse"))
		join msefile_ (getFiles (root_path +"\\*.ms"))

		btn_group_customize_A =#()
		btn_group_customize_B =#()
		btn_group_customize_C =#()

		for i in msefile_ do
		(
			name_ = getFilenameFile i
			if name_.count > 2 do
			(
				case name_[1] of (
					("A"):(append btn_group_customize_A i)
					("B"):(append btn_group_customize_B i)
					("C"):(append btn_group_customize_C i)
				)
			)

		)
		--"A#1#name#toolTip"
		--第一个字符是分组
		--第二个数字是组中排序
		--第三个是显示的名字
		--第四个是显示的按钮提示
	)
	
	fn set_button_UI =
	(
		for o =5 to 20 do
		(
			atimeline_toolsbar_roll.controls[o].text = ""
			atimeline_toolsbar_roll.controls[o].toolTip = ""
			atimeline_toolsbar_roll.controls[o].enabled = false
		)		
				--atimeline_toolsbar_roll.controls.count
				--A 5 - 9
				temp_list = #() 
				for o =1 to btn_group_customize_A.count do
				(
					name_ = getFilenameFile btn_group_customize_A[o]
					fullname = filterString name_ "#"

					if fullname.count < 4 do (
						deleteItem btn_group_customize_A o
						continue
					)

					index_ = fullname[2] as integer
					if classof index_ == Integer do
					(
						temp_list[index_] = btn_group_customize_A[o]
						if index_ <= 5 do
						(
							btn_index = index_ + 4
							atimeline_toolsbar_roll.controls[btn_index].text = (fullname[3] as string)
							atimeline_toolsbar_roll.controls[btn_index].toolTip = (fullname[4] as string)
							atimeline_toolsbar_roll.controls[btn_index].enabled = true
						)
					)
				)
				btn_group_customize_A = deepCopy temp_list 
				-- B 10 - 15
				temp_list = #() 
				for o =1 to btn_group_customize_B.count do
				(
					name_ = getFilenameFile btn_group_customize_B[o]
					fullname = filterString name_ "#"
					if fullname.count < 4 do (
						deleteItem btn_group_customize_B o
						continue
					)

					index_ = fullname[2] as integer
					if classof index_ == Integer do
					(
						temp_list[index_] = btn_group_customize_B[o]
						if index_ <= 6 do
						(
							btn_index = index_ + 9
							atimeline_toolsbar_roll.controls[btn_index].text = (fullname[3] as string)
							atimeline_toolsbar_roll.controls[btn_index].toolTip = (fullname[4] as string)
							atimeline_toolsbar_roll.controls[btn_index].enabled = true

						)
					)
				)
				btn_group_customize_B = deepCopy temp_list 
				-- C 16 - 20
				temp_list = #() 
				for o =1 to btn_group_customize_C.count do
				(
					name_ = getFilenameFile btn_group_customize_C[o]
					fullname = filterString name_ "#"
					if fullname.count < 4 do (
						deleteItem btn_group_customize_C o
						continue
					)
					index_ = fullname[2] as integer
					if classof index_ == Integer do
					(
						temp_list[index_] = btn_group_customize_C[o]
						if index_ <= 5 do
						(
							btn_index = index_ + 15
							atimeline_toolsbar_roll.controls[btn_index].text = (fullname[3] as string)
							atimeline_toolsbar_roll.controls[btn_index].toolTip = (fullname[4] as string)
							atimeline_toolsbar_roll.controls[btn_index].enabled = true

						)
					)
				)
				btn_group_customize_C = deepCopy temp_list 

	)
	fn initial =
	(
		atimeline_toolsbar_roll.sp_start.value = animationRange.start as time
		atimeline_toolsbar_roll.sp_end.value = animationRange.End as time

	)
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	on atimeline_toolsbar_roll open do
	(
		try(
			callbacks.addScript #animationRangeChange "atimeline_toolsbar_roll.initial()" id:#atimeline_toolsbar_roll
		)catch()
		get_customize_path()
		find_scripts()
		set_button_UI()
	)
	on atimeline_toolsbar_roll close do
	(
		callbacks.removeScripts #animationRangeChange id:#atimeline_toolsbar_roll
	)
	-----------------------------------------------------------------
	-----------------------------------------------------------------

	on chb_Lock changed theState do
	(
		if chb_Lock.checked == true then
		(
			for i = 1 to selection.count do
			(
				setTransformLockFlags selection[i] #{ 1,2,3,4,5,6,7,8,9}
			)
		)
		else
		(
			for i = 1 to selection.count do
			(
				setTransformLockFlags selection[i] #{ }
			)
		)
	)

	-----------------------------------------------------------------
	-----------------------------------------------------------------

	on btn_close pressed do
	(
		callbacks.removeScripts #animationRangeChange id:#atimeline_toolsbar_roll

		try(cui.UnRegisterDialogBar atimeline_toolsbar_roll)catch()
		try(destroyDialog atimeline_toolsbar_roll)catch()
	)

	on btn_ReStartMax pressed do
	(
		if checkForSave() then
		(
			shellLaunch (getdir #maxroot+"\\3dsmax.exe") (maxfilepath+maxfilename)
			quitmax #noPrompt

		)else()
	)


	on btn_RunSpt pressed do
	(
		try(destroyDialog roll_about)catch()
		CreateDialog roll_about
	)
	on btn_ReSet pressed do
	(
		max reset file
	)
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	on btn_Boxmode pressed do
	(
		if selection.count > 0 do
		(
			try(
				max box mode selected
			)catch()
		)
	)
	on btn_UHmesh changed state do
	(
		hideByCategory.geometry = state
	)
	on btn_UHhelp changed state do
	(
		hideByCategory.helpers = state
	)
	on btn_UHbone changed state do 
	(
		hideByCategory.Bones = state
	)
	/*

	on btn_UHCAT changed state do
	(
		if state then (
			CATBone_All = for i in objects where (classof i==CATBone or classof i== HubObject ) collect i
			hide CATBone_All
		)
		else(
			CATBone_All = for i in objects where (classof i==CATBone or classof i== HubObject ) collect i
			unhide CATBone_All
		)
	)*/
	on btn_UHCS changed state do
	(
		if state then
		(
			--CS_All=for i in objects where (classof i==Biped_Object or classof i == Dummy) collect i
			local CS_All=for i in objects where (classof i==Biped_Object ) collect i
			hide CS_All
		)
		else
		(
			--CS_All=for i in objects where (classof i==Biped_Object or classof i == Dummy) collect i
			local CS_All=for i in objects where (classof i==Biped_Object ) collect i
			unhide CS_All
		)
	)
	on btn_UHBN changed state do
	(
		if state then
		(
			Bn_All=for i in objects where (classof i==BoneGeometry ) collect i
			hide Bn_All
		)
		else
		(
			Bn_All=for i in objects where (classof i==BoneGeometry ) collect i
			unhide Bn_All
		)
	)
	-----------------------------------------------------------------
	-----------------------------------------------------------------
	on sp_start changed val do
	(
		if val >= sp_end.value then
		(
			sp_start.value = animationRange.start
			sp_end.value = animationRange.End
			return false
		)else(
			animationRange = interval sp_start.value sp_end.value
		)
	)
	on sp_end changed val do
	(
		if sp_end.value <= sp_start.value then
		(
			sp_start.value = animationRange.start
			sp_end.value = animationRange.End
			return false
		)else(
			animationRange = interval sp_start.value sp_end.value
		)

	)

	-----------------------------------------------------------------
	-----------------------------------------------------------------
	on ckb_speed1 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed2.state = false
			ckb_speed3.state = false
			ckb_speed4.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 1
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed2 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed3.state = false
			ckb_speed4.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 2
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed3 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed2.state = false
			ckb_speed4.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 3
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed4 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed2.state = false
			ckb_speed3.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 4
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed5 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed2.state = false
			ckb_speed3.state = false
			ckb_speed4.state = false
			timeConfiguration.playbackSpeed = 5
			playAnimation immediateReturn:true
		)
	)
	-----------------------------------------------------------------
	-----------------------------------------------------------------

	/*
	预留按键
		在 3ds MAX 2015 英文版下的安装路径
		#Scripts ：
			D:\Program Files\Autodesk\3ds Max 2015\scripts\NDTools\TimeLine_Tools\
	*/
	-----------------------------------------------------------------
	fn pressed_btn group_id id_ =
	(
		case group_id of (
			(1):(try(
					if doesFileExist btn_group_customize_A[id_] do (
						filein btn_group_customize_A[id_]
					)
				)catch()
				)
			(2):(
				try(
					if doesFileExist btn_group_customize_B[id_] do (
						filein btn_group_customize_B[id_]
					)
					)catch()
				)
			(3):(try(
					if doesFileExist btn_group_customize_C[id_] do (
						filein btn_group_customize_C[id_]
					))catch()
				)
		)
	)
	on btn_B_customize_01 pressed do
	(
		pressed_btn 2 1
	)
	on btn_B_customize_02 pressed do
	(
		pressed_btn 2 2
	)
	on btn_B_customize_03 pressed do
	(
		pressed_btn 2 3
	)
	on btn_B_customize_04 pressed do
	(
		pressed_btn 2 4

	)
	on btn_B_customize_05 pressed do
	(
		pressed_btn 2 5
	)
	on btn_B_customize_06 pressed do
	(
		pressed_btn 2 6
	)
	-----------------------------------------------------------------
	on btn_C_customize_01 pressed do
	(
		pressed_btn 3 1
	)
	on btn_C_customize_02 pressed do
	(
		pressed_btn 3 2
	)
	on btn_C_customize_03 pressed do
	(
		pressed_btn 3 3
	)
	on btn_C_customize_04 pressed do
	(
		pressed_btn 3 4
	)
	on btn_C_customize_05 pressed do
	(
		pressed_btn 3 5
	)
	-----------------------------------------------------------------

	on btn_A_customize_01 pressed do
	(
		pressed_btn 1 1
	)
	on btn_A_customize_02 pressed do
	(
		pressed_btn 1 2
	)
	on btn_A_customize_03 pressed do
	(
		pressed_btn 1 3
	)
	on btn_A_customize_04 pressed do
	(
		pressed_btn 1 4
	)
	on btn_A_customize_05 pressed do
	(
		pressed_btn 1 5
	)
	-----------------------------------------------------------------

)
rollout roll_about "About" width:210
(
		label lab_dw "V_Joe.12 by Joe -2022/06/30"
		hyperlink lbl_01 "检查更新" address:"https://sundaybox.cc/pages/a93a52/" align:#Center
		button btn_openpath "打开脚本目录" width:90 height:22 across:2
		button btn_setpath "设置脚本目录" width:90
		button btn_doup "更新按钮" across:2 width:90 height:22
		button btn_units "卸载"		width:90 height:22 --align:#Center
		
		on btn_openpath pressed do 
		(
			try(
				if atimeline_toolsbar_roll != undefined and atimeline_toolsbar_roll.open do
				(
					if not doesFileExist atimeline_toolsbar_roll.root_path do 
					(
						makeDir atimeline_toolsbar_roll.root_path
					)
					ShellLaunch "explorer.exe" atimeline_toolsbar_roll.root_path
				)
			)catch()
		)
		on btn_units pressed do
		(
			file_path = getSourceFileName()
			if doesFileExist file_path do 
			(
				if (queryBox file_path title:"确定删除？") do (
				try(
					print(file_path)
					deleteFile file_path
					cui.unRegisterDialogBar atimeline_toolsbar_roll
					destroydialog atimeline_toolsbar_roll 
					--filein (getdir #userScripts + "\\joe_scripts\\joe_Unist_JiRts_Anim_Toolbar.ms")
				)catch(format "删除错误: %\n" file_path )
				)
			)
		)
		on btn_doup pressed do
		(
			try(
				if atimeline_toolsbar_roll != undefined and atimeline_toolsbar_roll.open do
				(
					atimeline_toolsbar_roll.find_scripts()
					atimeline_toolsbar_roll.set_button_UI()
				)
			)catch()
		)
		on btn_setpath pressed do 
		(
			try(
				if atimeline_toolsbar_roll != undefined and atimeline_toolsbar_roll.open do
				(
					if atimeline_toolsbar_roll.set_customize_path() do
					(
						atimeline_toolsbar_roll.find_scripts()
						atimeline_toolsbar_roll.set_button_UI()
					)
				)
			)catch()
		)
)
--根据屏幕分辨率 来设置工具条的长度
createdialog atimeline_toolsbar_roll (atimeline_toolsbar_roll.roll_width) 30 lockHeight:true style:#(#style_titlebar,#style_resizing,#style_sysmenu)
cui.RegisterDialogBar atimeline_toolsbar_roll style:#(#cui_dock_horz)
cui.DockDialogBar atimeline_toolsbar_roll #cui_dock_bottom
--cui.getExpertMode()
--updateToolbarButtons()


-- D:\Program Files\Autodesk\3ds Max 2022\stdplugs\stdscripts\TrackViewUtility.ms

plugin TrackViewUtility CurrentLinkEditorUtility
name:"ScriptControllerEditor"
category:"Scripted TV Utilities"
classID:#(0x294e1bd3, 0x5df45da3)
(
--genClassID()
	

	
	/* global Track_View_HWND = undefined ,test_setect_trackview
	current_name = "Track View - Curve Editor"
	currentTrackview = trackviews.current

	if currentTrackview != undefined then 
	(
		current_name = currentTrackview.getName()
		Track_View_HWND = currentTrackview.ui.hwnd
	)else(
		for child in (windows.getChildrenHWND (windows.getDesktopHWND())) do
		(
			--if child[4] == "#32770" and child[5] == current_name do 
			if child[5] == current_name do 
			(
				global Track_View_HWND
				Track_View_HWND = child[1]
			)
		)
	)

	if Track_View_HWND == undefined do 
	(
		messageBox "no find Curve Editor"
	) 
	try(DestroyDialog test_setect_trackview)catch() */

	rollout test_setect_trackview "曲线编辑器快速连接 - Script_Controller - v.3" width:450 height:470
	(
		group "主驱"
		(
			edittext lab_02 "" readOnly:true align:#center
			edittext script_variables_name "变量名:" text:"AU" width:190 across:2
			button btn_get_b "拾取 选中曲线" width:150 height:22 align:#right tooltip:"拾取 曲线编辑器 中 选中曲线"
			
		)
		
		group "被驱" (
			edittext lab_01 "" readOnly:true 
			label lab_type "" across:3 align:#left offset:[10,3]
			edittext lab_classid "" width:150 offset:[-40,3] readOnly:true
			button btn_get_a "拾取 选中曲线" width:150 height:22 align:#right tooltip:"拾取 曲线编辑器 中 选中曲线"
			

			label lab_03 "已有变量：" align:#left 
			edittext script_controller_text "" text:"" fieldwidth:420 height:50 align:#cenger readOnly:true
		
			label lab_04 "表达式 " align:#left 
			edittext edit_script_text "" text:"if AU > 0 then (AU*100.0)else(0)" fieldwidth:420 height:50 align:#cenger
			label lab_05 "高版本 Max 旋转是弧度制 ，角度转弧度 degToRad "
		)
		group "历史"
		(
			--edittext edit_script_text_history "" text:"" fieldwidth:420 height:90 align:#cenger
			dotNetControl edit_script_text_history "System.Windows.Forms.Textbox"  fieldwidth:420 height:90 align:#cenger --visible:false
		)
		button btn_close "清除历史" width:60 height:22 across:4 align:#right
		HyperLink btn_Help_web "Help" address:"https://sundaybox.cc/pages/ade81d/"  align:#center-- offset:[0,10]
		--button btn_create_reactor "创建反应" width:110 height:22 
		button btn_do "创建表达式" width:150 height:22 align:#left offset:[50,0]
		

		local master_a = undefined , master_b = undefined ,node_a ,node_b 
		local ok_classid = #(1348826747,1233584870)
		local history_txt = #()
		local history_file = (getdir #userScripts)  + @"\script_controller_text.ini"

		fn history_open add_string =
		(
			edit_script_text_history.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
			edit_script_text_history.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
			edit_script_text_history.MultiLine = true
			--edit_script_text_history.ReadOnly = true
			--edit_script_text_history.WordWrap = true
			edit_script_text_history.Text =""
		)
		fn get_history = 
		(
			s_txt = getINISetting history_file "scripts" "controller"
			history_open s_txt
 		)
 		fn set_history = 
 		(
 			if edit_script_text_history.Text.count >0 do (
 			setINISetting history_file "scripts" "controller" edit_script_text_history.Text
 			)
 		)


		fn test_controller_ok controller = 
		(
			cc_ok = false
			if controller != undefined do 
			(
				if (finditem ok_classid controller.classid[1]) != 0 do(cc_ok = true )
			)
			cc_ok
		)
		fn getImmediateDependents node = 
		(
			for d in (refs.dependents node) where finditem (refs.dependson d) node != 0 collect d
		)
		fn getControllerSubAnim node =
		(
			subs = #()
			for d in (getImmediateDependents node) do for k=1 to d.numsubs where d[k] == node do append subs d[k]
			subs
		)
		fn find_track_tiew_select_track = 
		(
			select_track = undefined
			track_view = trackviews.getTrackView((trackviews.numTrackViews()))
			if track_view != undefined do 
			(
				select_num = track_view.numSelTracks()
				for i = 1 to select_num do 
				(
					select_track = track_view.getSelected(i)
				)
			)
			select_track
		)
		on btn_get_a pressed do 
		(	
			master_a = find_track_tiew_select_track()
			if master_a != undefined do 
			(

				lab_01.text = (exprForMAXObject master_a explicitNames:true)
				master_a = getControllerSubAnim master_a
				master_a = master_a[1] 
				if master_a == undefined or master_a.controller == undefined do (
					lab_classid.text =""
					lab_type.text = ""
					return false
				)

				lab_classid.text = master_a.controller.classid as string 
				lab_type.text = (classOf master_a.controller) as string 
				format "% -> % \n" lab_type.text lab_classid.text 

				if test_controller_ok master_a.controller then
				(
					print( "test ok ")
					text_ = StringStream ""

					index = master_a.controller.NumVariables() 
					for i=5 to index do 
					(
						Variable_name = master_a.controller.getname i 

						var_type = master_a.controller.GetType Variable_name
						format "% - % \n" i var_type
						if var_type != #unknown and var_type != #constant then
						(
							try(
								master = master_a.controller.GetTarget i
								format "Target % :: % -> % \r\n" (i - 5 + 1 ) Variable_name (exprForMAXObject master explicitNames:true) to:text_ 
							)catch(

								master = "undefined"
							)
							--master 可能是控制器，可能是节点对象
							
						)else(
							format "Target % :: % -> \r\n" (i - 5 + 1 ) Variable_name  to:text_ 

						)
					)
					script_controller_text.text = text_

					edit_script_text.text = master_a.controller.script

				)else(

					script_controller_text.text = ""
					edit_script_text.text = "if AU > 0 then (AU*100.0)else(0)"
				)	
			)
		)

		on btn_get_b pressed do 
		(	
			master_b = find_track_tiew_select_track()
			if master_b != undefined do 
			(
				lab_02.text = (exprForMAXObject master_b)
				master_b = getControllerSubAnim master_b 
				master_b = master_b[1] 
			)
		)
		on btn_do pressed do 
		(
			if master_a != undefined and master_b != undefined do 
			(
				if script_variables_name.text.count < 1 do return false 
				if edit_script_text.text.count < 1 do return false 

				ok_id = #(1348826747,1233584870)
				if (finditem ok_id master_a.controller.classid[1]) != 0 do 
				(
					if master_a.controller.VariableExists script_variables_name.text then 
					(
						master_a.controller.SetTarget script_variables_name.text master_b 
					)else(
						master_a.controller.AddTarget script_variables_name.text master_b 
					)
					master_a.controller.script = edit_script_text.text
					edit_script_text_history.Text += "\n" + edit_script_text.text

					messageBox "更新表达式"
				)
				--Position_XYZ 
				if master_a.controller.classid[1] == 294616578 do 
				(
					the_anim = position_script()
					master_a.controller = the_anim
					the_anim.AddTarget script_variables_name.text master_b 
					the_anim.script = edit_script_text.text 
					edit_script_text_history.Text += "\n" + edit_script_text.text

					messageBox "创建表达式 -position_script"

				)
				--distance 
				--radToDeg
				--DegToRad 
				--bezier_float 
				if master_a.controller.classid[1] == 294616578 or master_a.controller.classid[1] == 8199 do 
				(
					the_anim = Float_Script()
					master_a.controller = the_anim
					the_anim.AddTarget script_variables_name.text master_b 
					the_anim.script = edit_script_text.text 
					edit_script_text_history.Text += "\n" + edit_script_text.text
					messageBox "创建表达式 - Float_Script"

				)
			)
		)
		on test_setect_trackview open do 
		(
			--history_open ""
			get_history()
		)
		on test_setect_trackview close do 
		(
			set_history()
		)

	)

-- 	if Track_View_HWND != undefined then (

-- 		CreateDialog test_setect_trackview parent:Track_View_HWND
-- 	)else(
-- 		CreateDialog test_setect_trackview
-- 	)

	on Init val do
	(
		--Create a dialog from the Rollout, make it child of the Track View
		createDialog test_setect_trackview parent:(val.ui.hwnd)
		--Register the dialog as Dialog Bar, make it child of the Track View
		cui.registerDialogBar test_setect_trackview parent:val.ui.hwnd
	)
)
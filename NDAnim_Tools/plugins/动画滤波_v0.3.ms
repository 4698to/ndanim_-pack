
plugin TrackViewUtility NDToolsAnimFilter
name:"NDTools Anim Filter"
category:"NDTools Utilities"
classID:#(0x5177f4f9, 0x5c081d6b)
(

	fn test_ClassLibrary4 = 
	(
		atest = undefined
		local dll_file = ((getDir #scripts)+ @"\NDTools\AnimFilter\ClassLibrary4.dll")
		if doesFileExist dll_file then (
			assembly = (dotnetClass "System.Reflection.Assembly").Load ((dotnetClass "System.IO.File").ReadAllBytes dll_file)
			atest = assembly.createInstance "ClassLibrary4.Class1"
		)else(
			messageBox @"缺少\NDTools\AnimFilter\ClassLibrary4.dll" title:"不可用"
		)
		return atest
	)
	fn getSelectedControllers _currentTrackView =
	(
		numControllers = _currentTrackView.numSelTracks()
		theControllers = #()
		
		for i in 1 to numControllers do
		(
			currentController = (_currentTrackView.getSelected i)
			append theControllers currentController
		)
		theControllers
	)
	local currentTrackview = trackviews.current

	rollout test_anim_filter "动画曲线过滤-0.3" width:400 height:200
	(
		group "" (
		slider sp "xx" range:[0,100,0] type:#integer width:380 enabled:false across:2 Align:#Left

		label lab01 "738746223@qq.com" Align:#Right 
		checkbox chk_select_key "仅作用选择帧" across:2
		spinner sp_coefficient "数值因子:" range:[0.01,10,1] type:#float 
		dropdownlist dp_type "" items:#("平滑 (高斯)","降噪 (巴特沃斯滤波)","减帧 (道格拉斯抽稀)","平滑 (高斯-迭代)")
		button btn_test "预览" height:25 width:122 across:3
		button btn_ok "确定" height:25 width:122 enabled:false
		button btn_undo "撤销" height:25 width:122 enabled:false
		hyperLink help "Help" address:"https://sundaybox.cc/pages/15637e/" across:2 Align:#Left offset:[0,2]
		button btn_set_TrackView "T" height:20 width:20 Align:#right tooltip:"曲线编辑器透明"
		)
		local select_anim_handle = #()
		local select_anim_backups = #()
		local select_anim_ctr_backups = #()
		local select_anim_ctr_keyValue = #()
		local atest = undefined
		local is_opacity = false
		fn set_ui_enabled is_enabled = 
		(
			sp.enabled = is_enabled
			btn_ok.enabled = is_enabled 
			btn_undo.enabled = is_enabled
			sp.text = sp.value as string 
		)
		fn reset_data = 
		(
			free select_anim_handle
			free select_anim_backups
			free select_anim_ctr_backups
			free select_anim_ctr_keyValue 

			select_anim_handle = #()
			select_anim_backups = #()
			select_anim_ctr_backups = #()
			select_anim_ctr_keyValue = #()
		)
		on btn_set_TrackView pressed do 
		(
			if is_opacity then (
				atest.set_track_viwe (trackviews.current.ui.hwnd) 255
				is_opacity = false
			)else(
				atest.set_track_viwe (trackviews.current.ui.hwnd) 80
				is_opacity = true
			)
			/* if Track_View_HWND != undefined do (
				atest.set_track_viwe Track_View_HWND 80
			) */
		)
		on btn_test pressed do 
		(
			--打开曲线编辑器窗口
			--track_view = trackviews.getTrackView(1)
			track_view = trackviews.current
			if track_view != undefined do (
				reset_data()
				--拿到曲线编辑器上选中的曲线数量
				select_num = track_view.numSelTracks()
				max_num = 2 
				--循环
				for i = 1 to select_num do 
				(

					--拿到曲线
					ctr = track_view.getSelected(i)
					--曲线类型判断
					if ctr.classid[1] == 8199 or ctr.classid[1] == 8208 do 
					(
						if select_anim_handle.count > 2 do (exit )
						append select_anim_ctr_backups (exprForMAXObject ctr)
						append select_anim_backups (copy ctr)
						handle = GetHandleByAnim ctr 
						--handle = dotNetObject "System.UIntPtr" handle
						append select_anim_handle handle
					)
				)
				case dp_type.selection of 
				(
					--高斯模糊B
					(1):(
						
						if select_anim_handle.count > 0 then (
							for i = 1 to select_anim_handle.count do 
							(
								handle = select_anim_handle[i] 

								ctrkey = atest.get_key_value_samples handle chk_select_key.state

								append select_anim_ctr_keyValue ctrkey
							)
							sp.range = [2,20,2]
							set_ui_enabled true 

						)else (
							set_ui_enabled false
						)
					)
					--巴特沃斯滤波
					(2):(
						for i = 1 to select_anim_handle.count do 
						(

							handle = select_anim_handle[i] 
							ctrkey = atest.get_key_value_samples handle false 
							append select_anim_ctr_keyValue ctrkey
						)
						if select_anim_handle.count > 0 then (
							sp.range = [0,250,1]
							set_ui_enabled true 
						)else (
							set_ui_enabled false
						)
					)
					--道格拉斯抽稀
					(3):(

						if select_anim_handle.count > 0 then (
							for i = 1 to select_anim_handle.count do 
							(

								handle = select_anim_handle[i] 
								ctrkey = atest.get_key_value_samples handle false
								append select_anim_ctr_keyValue ctrkey
							)

							sp.range = [0,100,0]
							set_ui_enabled true 
						)else (
							set_ui_enabled false
						)
						
					)
					--高斯平滑-迭代
					(4):(
						if select_anim_handle.count > 0 then (
							sp.range = [-50,50,0]
							set_ui_enabled true 

						)else (
							set_ui_enabled false
						)
					)
				)
			)

		)
		on btn_undo pressed do 
		(
			global ctr_backups_999192 = undefined
			for i = 1 to select_anim_ctr_backups.count do 
			(
				global ctr_backups_999192 = select_anim_backups[i]
				ctr_string = select_anim_ctr_backups[i]
				ctr_string += " = ctr_backups_999192"
				execute ctr_string
			)
			
			reset_data()

			set_ui_enabled false
			
			global ctr_backups_999192 = undefined

		)
		on btn_ok pressed do 
		(
			reset_data()
			set_ui_enabled false
		)
		on sp changed val do
		(
			
			case dp_type.selection of 
			(
				(1):(
					--scale_value = val * 0.01 -- B
					scale_value = val  --C 

					scale_value *= sp_coefficient.value
					sp.text = (scale_value as string )
					for i = 1 to select_anim_handle.count do
					(
						--方案B
						--atest.gaussian_smooth_data_B select_anim_handle[i] scale_value select_anim_ctr_keyValue[i]
						atest.gaussian_smooth_data_C select_anim_handle[i] select_anim_ctr_keyValue[i] (ceil scale_value)

						format "% -> % \r\n" select_anim_handle[i] scale_value
					)
				)
				(2):(
					scale_value =abs(250 - val ) 
					scale_value *= sp_coefficient.value
					sp.text = (scale_value as string )
					for i = 1 to select_anim_handle.count do
					(
						atest.Butterworth_test select_anim_handle[i] 30.0 scale_value select_anim_ctr_keyValue[i]  
						--format "% => %\r\n" select_anim_handle[i] (scale_value)
					)
				)
				(3):(
					scale_value = val*0.0001 * sp_coefficient.value
					sp.text = (scale_value as string )
					for i = 1 to select_anim_handle.count do
					(
						atest.douglaspeucker_testB select_anim_handle[i] scale_value select_anim_ctr_keyValue[i] 
						--format "% => %\r\n" select_anim_handle[i] (scale_value)
					)
				)
				(4):(
					scale_value = abs(((val + 50) / 100.0) * 2 ) as integer
					sp.text = (scale_value as string )
					for i = 1 to select_anim_handle.count do
					(
						atest.gaussian_smooth select_anim_handle[i] 0.5 chk_select_key.state
						
					)
				)
			) 
			
		)
		on dp_type selected arg do
		(
			case arg of 
			(
				(1):(
					btn_test.text = "预览"
					sp.range = [2,20,2]
				)
				(2):(
					btn_test.text = "预览"
					sp.range = [0,250,1]
				)
				(3):(
					btn_test.text = "预览"
					sp.range = [0,100,0]
				)
				(4):(
					btn_test.text = "预览"
					sp.range = [-50,50,0]
					)
				(default):(
					btn_test.text = "预览"
				)
			)
		) 
	)


	on Init val do
	(
		--Create a dialog from the Rollout, make it child of the Track View
		createDialog test_anim_filter parent:(val.ui.hwnd)
		--Register the dialog as Dialog Bar, make it child of the Track View
		cui.registerDialogBar test_anim_filter parent:val.ui.hwnd maxSize:[440,200]
		test_anim_filter.atest = test_ClassLibrary4()
	)
)

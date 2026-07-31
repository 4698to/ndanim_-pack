
-- D:\Program Files\Autodesk\3ds Max 2022\stdplugs\stdscripts\TrackViewUtility.ms

plugin TrackViewUtility ReactionControllerLinkEditorUtility
name:"ReactionControllerEditor"
category:"Scripted TV Utilities"
classID:#(0x2ebed4bb, 0x14cb5535)
(
--genClassID()
	

	
	/* global Track_View_HWND = undefined ,ReactionControllerTrackview
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
	try(DestroyDialog ReactionControllerTrackview)catch()  */

	rollout ReactionControllerTrackview "曲线编辑器快速连接 - ReactionConroller - v.1" width:450 height:380
	(
		group "主驱 driver"
		(
			edittext lab_02 "" readOnly:true align:#center
			button btn_get_driver "拾取 选中曲线" width:150 height:22 align:#right tooltip:"拾取 曲线编辑器 中 选中曲线"
		)
		
		group "被驱 driven A" (
			--edittext edit_info_text "" text:"" fieldwidth:420 height:100 readOnly:true align:#cenger
			dotNetControl edit_info_text "System.Windows.Forms.Textbox"  fieldwidth:420 height:100 align:#cenger --visible:false

			edittext lab_01 "" readOnly:true 
			label lab_type "" across:3 align:#left offset:[10,3]
			edittext lab_classid "" width:150 offset:[-40,3] readOnly:true
			button btn_get_driven "拾取 选中曲线" width:150 height:22 align:#right tooltip:"拾取 曲线编辑器 中 选中曲线"
			
		)
		
		
		HyperLink btn_Help_web "Help" address:"https://sundaybox.cc/pages/ade81d/" across:2 align:#center-- offset:[0,10]
		
		button btn_do "创建反应" width:150 height:22 align:#left offset:[60,0]
		
		group "被驱 driven B"
		(
			edittext lab_012 "" readOnly:true 
			label lab_type2 "" across:3 align:#left offset:[10,3]
			edittext lab_classid2 "" width:150 offset:[-40,3] readOnly:true
			button btn_get_driven2 "复制 A 的状态" width:150 height:22 align:#right tooltip:"复制 被驱A 控制器的所有状态给 被驱B"
		)

		local master_a = undefined , master_b = undefined ,node_a ,node_b 
		local driver_react = #(),driver_react_info = undefined

		local ok_classid = #(713503979,2059782884,1904049439)
		local history_txt = #()
		local history_file = (getdir #userScripts)  + @"\script_controller_text.ini"

		struct states_struct
		(
			name,
			index,
			value,
			driven_value,
			controller,
			fn type = 
			(
				return (classOf driven_value)

			)

		    -- Struct body.
		)
		fn textbox_open =
		(
			edit_info_text.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
			edit_info_text.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
			edit_info_text.MultiLine = true
			edit_info_text.ReadOnly = true
			--edit_script_text_history.WordWrap = true
			edit_info_text.Text =""
		)

		fn find_states_by_index index = 
		(
			find = undefined 
			for i in driver_react do 
			(
				if index == i.index do 
				(
					find = i
					exit() 
				)
			)
			find 
		)
		fn find_states_by_name name = 
		(
			find = undefined 
			for i in driver_react do 
			(
				if name == i.name do 
				(
					find = i
					exit() 
				)
			)
			find 
		)

		fn find_state_index_by_name controller name_ = 
		(
			_count = getReactionCount controller
			id = 0 
			for i = 1 to _count do 
			(
				if (getReactionName controller i) == (name_ as name) do 
				(
					id = i 
				)

			) 
			id 
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
		on btn_get_driven2 pressed do 
		(
			master_a = find_track_tiew_select_track()
			if master_a != undefined do 
			(

				lab_012.text = (exprForMAXObject master_a explicitNames:true)
				master_a = getControllerSubAnim master_a
				master_a = master_a[1] 
				if master_a == undefined or master_a.controller == undefined do (
					lab_classid2.text =""
					lab_type2.text = ""
					return false
				)

				lab_classid2.text = master_a.controller.classid as string 
				lab_type2.text = (classOf master_a.controller) as string 
				format "% -> % \n" lab_type2.text lab_classid2.text 

				if test_controller_ok master_a.controller then
				(
					is_copy = queryBox driver_react_info title:"确定复制反应状态"
					
					if is_copy do 
					(
						id = 1 
						for i= driver_react.count to 1 by -1 do 
						(
							driver_react[i].index = id 
							id += 1
						)
						--radToDeg
						index = master_a.controller.getCount()
						-- 然后可以复制创建
						if index < driver_react.count do 
						(
							new_count = driver_react.count - index 
							for i=1 to new_count do 
							(
								createReaction master_a.controller 
							)
						)
						 
						for i in driver_react do 
						(
							setReactionName master_a.controller i.index i.name 
							--format "% , %  -> %\n" i i.index i.name
						)
						for i=1 to driver_react.count do 
						(
							--改名或者是改 反应 值 之后顺序会变，所以得每次修改都要重新搜索
							st = driver_react[i]
							id = find_state_index_by_name master_a.controller st.name
							if id > 0 do (
								setReactionValue master_a.controller id st.value
							)
							id = find_state_index_by_name master_a.controller st.name
							if id > 0 do 
							(
								setReactionState master_a.controller id st.driven_value
							)
							--format "% , %  -> %\n" i id st.name
						)
						messageBox ("复制成功 " + (driver_react.count as string) + " 个状态")
					)
				)else(
					messageBox "不支持的控制器类型"
				)	
			)
		)

		on btn_get_driven pressed do 
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
				format "% -> % \r\n" lab_type.text lab_classid.text 

				if test_controller_ok master_a.controller then
				(
					
					text_ = StringStream ""
					--radToDeg
					index = master_a.controller.getCount()
					driver_react = #()
					
					state_type = master_a.controller.getType() 
					-- driver 状态 类型
					format "%\r\n" state_type to:text_ 

					for i=1 to index do 
					(
						_state = states_struct()
						_state.index = i 

						state_name = master_a.controller.getName i
						-- driver 状态名
						_state.name = state_name

						state_value = master_a.controller.getValue i
						_state.value = state_value

						
						
						value_ = master_a.controller.getState i 
						_state.driven_value = value_
						--控制器状态值 driven 
						append driver_react _state
						format "% -> % -> % \r\n" state_name state_value value_ to:text_
					)
					driver_react_info = text_ as string 
					edit_info_text.text = driver_react_info
				)else(
					edit_info_text.text = "非反应控制器，请创建 反应"
				)	
			)
		)

		on btn_get_driver pressed do 
		(	
			master_b = find_track_tiew_select_track()
			if master_b != undefined do 
			(
				lab_02.text = (exprForMAXObject master_b explicitNames:true)
				master_b = getControllerSubAnim master_b 
				master_b = master_b[1] 
			)
		)
		on btn_do pressed do 
		(
			if master_a != undefined and master_b != undefined do 
			(
				
				--rot xyz
				rot_ok = #(4465427,825760018,8224,8225,8210,2275860263)
				if (finditem rot_ok master_a.controller.classid[1]) != 0 do 
				(
					the_anim = Rotation_Reactor()
					master_a.controller = the_anim
					reactTo master_a.controller master_b.controller

					messageBox "更新 反应 Rotation_Reactor"
					return false 
				)
				--Position_XYZ 
				pos_ok = #(294616578,1348826747,8211,8217,8209,2275860261,8200,4465426)
				if (finditem pos_ok master_a.controller.classid[1]) != 0 do 
				(
					the_anim = PositionReactor()
					master_a.controller = the_anim
					reactTo master_a.controller master_b.controller

					messageBox "创建 反应 -PositionReactor"
					return false 

				)
				scale_ok = #(294616065,2089761322,4465429,8214,2275860264,8208)
				if (finditem scale_ok master_a.controller.classid[1]) != 0 do 
				(
					the_anim = Scale_Reactor()
					master_a.controller = the_anim
					reactTo master_a.controller master_b.controller
					
					messageBox "创建 反应 - Scale_Reactor"
					return false 


				)

				--bezier_float ,float_script,
				float_ok = #(1233584870,8199,8213,294616578,2275860260)
				if (finditem float_ok master_a.controller.classid[1]) != 0 do 
				(
					the_anim = FloatReactor()
					master_a.controller = the_anim
					reactTo master_a.controller master_b.controller
					
					messageBox "创建 反应 - FloatReactor"
					return false 
				)

				reactor_ok = #(1904049439)
				if (finditem reactor_ok master_a.controller.classid[1]) != 0 do 
				(
					createReaction master_a.controller
					messageBox "创建 状态 - FloatReactor"

				)
			)
		)
		on ReactionControllerTrackview open do 
		(
			textbox_open()
		)
		on ReactionControllerTrackview close do 
		(
		)

	)

	/* if Track_View_HWND != undefined then (

		CreateDialog ReactionControllerTrackview parent:Track_View_HWND
	)else(
		CreateDialog ReactionControllerTrackview
	)
 */
	on Init val do
	(
		--Create a dialog from the Rollout, make it child of the Track View
		createDialog ReactionControllerTrackview parent:(val.ui.hwnd)
		--Register the dialog as Dialog Bar, make it child of the Track View
		cui.registerDialogBar ReactionControllerTrackview parent:val.ui.hwnd
	)
)
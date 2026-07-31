try()catch()
try(destroyDialog AnimationEvent)catch()
rollout AnimationEvent "AnimationEvent" width:270 height:450
(
	local Event_name = #("skill_start","Attack_Effet","skill_over","Hit_start","Hit_over","")
	local Event_int = #(0,0,0,0,0,0,0,0,0)
	local Event_list = #(),event_list_text = "" ,root_node = undefined 

	group ""(
		hyperlink bt_info "帮助" address:"https://sundaybox.cc/pages/5e4cde/" across:2 align:#left
		button btn_pick "+"  Align:#right offset:[0,-5] tooltip:"拾取根骨骼上的信息"
		edittext event_text "" fieldWidth:250 height:150 offset:[-7,-2]
	)
	group "标记动画通知"
	(
		edittext edit_event_name "Name:" text:Event_name[1] fieldWidth:95 across:3
		spinner sp_intParameter "int:" width:60 type:#integer offset:[40,0]
		button btn_add "+" Align:#right

		edittext edit_event_name_1 "Name:" text:Event_name[2] fieldWidth:95 across:3
		spinner sp_intParameter_1 "int:" width:60 type:#integer offset:[40,0]
		button btn_add_1 "+" Align:#right

		edittext edit_event_name_2 "Name:" text:Event_name[3] fieldWidth:95 across:3
		spinner sp_intParameter_2 "int:" width:60 type:#integer offset:[40,0]
		button btn_add_2 "+" Align:#right

		edittext edit_event_name_3 "Name:" text:Event_name[4] fieldWidth:95 across:3
		spinner sp_intParameter_3 "int:" width:60 type:#integer offset:[40,0]
		button btn_add_3 "+" Align:#right

		edittext edit_event_name_4 "Name:" text:Event_name[5] fieldWidth:95 across:3
		spinner sp_intParameter_4 "int:" width:60 type:#integer offset:[40,0]
		button btn_add_4 "+" Align:#right

		edittext edit_event_name_5 "Name:" text:Event_name[6] fieldWidth:95 across:3
		spinner sp_intParameter_5 "int:" width:60 type:#integer offset:[40,0]
		button btn_add_5 "+" Align:#right

		button btn_do "保存到选中骨骼" width:250 height:22
	)
	label lab_01 "选中根骨骼创建, 名字不有中文和特殊符号"
	label lab_02 "首字母不可用数字"
	fn update_ui index =
	(
		v_index = (index-1)*3+8
		Event_int[index] = AnimationEvent.Controls[v_index].value
		Event_name[index] = AnimationEvent.Controls[(v_index-1)].text 
	)
	fn get_UserPropBuffer = 
	(
		v_event_list_text = filterString event_list_text "\r\n"
		v_text = ""
		for i = 1 to v_event_list_text.count do 
		(
			v_text += v_event_list_text[i]
			--if i != v_event_list_text.count do (
			v_text += "\r\n"
			--)
		)
		v_text
	)
	fn add_new_event index = 
	(
		index_frame = sliderTime.frame - animationRange.start.frame 
		frmae_count = animationRange.end.frame - animationRange.start.frame + 1 
		evnet_time = index_frame / frmae_count 
		
		update_ui index 
		
		v_event_name = "@" + Event_name[index] + "=" + evnet_time as string 
		
		if Event_int[index] != 0 do (
			v_event_name += "#"
			v_event_name += Event_int[index] as string
		)
		if event_list_text.count > 0 do (event_list_text += "\r\n" )
		
		event_list_text += v_event_name
		event_text.text = event_list_text
	)
	on event_text changed tex do 
	(
		event_list_text = tex
	)
	on btn_do pressed do 
	(
		if isValidNode root_node do 
		(
			v_text = get_UserPropBuffer()
			setUserPropBuffer root_node v_text
			format "setUserPropBuffer -> % \r\n" root_node.name 
			format "%\r\n" v_text
		)
	)
	on btn_pick pressed do 
	(
		if selection.count > 0 then 
		(
			root_node = selection[1]
			event_list_text = getUserPropBuffer root_node 
			event_text.text = event_list_text
			
			btn_do.text ="保存到选中骨骼 [" + root_node.name +"]" 

		)else(
			root_node = undefined
			btn_do.text = "保存到选中骨骼"
		)
	)
	on btn_add pressed do 
	(
		add_new_event 1 
	)
	on btn_add_1 pressed do 
	(
		add_new_event 2 
	)
	on btn_add_2 pressed do 
	(
		add_new_event 3 
	)
	on btn_add_3 pressed do 
	(
		add_new_event 4 
	)
	on btn_add_4 pressed do 
	(
		add_new_event 5 
	)
	on btn_add_5 pressed do 
	(
		add_new_event 6 
	)
)

createDialog AnimationEvent
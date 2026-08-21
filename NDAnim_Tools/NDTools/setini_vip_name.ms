--2020.12.26
--99U:199505
--e-mail:738746223@qq.com

try(destroyDialog set_vip_name)catch()
rollout set_vip_name "设置" width:210 height: 130
(

    group "设置制作人" (
    	label lab_01 "阁下尊姓大名"
        edittext ed_name "" width:120 across:2 --height:35
        button btn_set "确定" width:50 height:20 offset:[16,-2]
    )

    group "Bone Biped 选择模式" (
    	radiobuttons rad_select_mode "" labels:#("筛选","直选")
        -- Group body.
    )
    local TQ_anim_set = (getdir #maxroot+"scripts\\TQAnimationTool.ini")
    on btn_set pressed do
    (
        if TQ_anim_set != undefined and ed_name.text != "" do (setINISetting TQ_anim_set "VIP_name" "制作人" ed_name.text)
    )
    on set_vip_name open do
    (
        if TQ_anim_set != undefined do 
        (
        	ed_name.text = getINISetting TQ_anim_set "VIP_name" "制作人" 
        	
        	select_mode = getINISetting TQ_anim_set "VIP_select" "mode"
			if select_mode.count > 1 do (
				if select_mode == "true" do (rad_select_mode.state = 1)
				if select_mode == "false" do (rad_select_mode.state = 2)
				
			)

        )
    )
    on rad_select_mode changed arg do 
    (
    	if arg == 1 then 
    	(
    		setINISetting TQ_anim_set "VIP_select" "mode" "true"
    		global vip_select_mode = true 
    	)else(
    		setINISetting TQ_anim_set "VIP_select" "mode" "false"
    		global vip_select_mode = false 
    	)
    )

)
createDialog set_vip_name
(

	global vip_select_mode
	if vip_select_mode == undefined do (
		local TQ_anim_set = (getdir #maxroot+"scripts\\TQAnimationTool.ini")
		vip_select_mode = getINISetting TQ_anim_set "VIP_select" "mode"
		if vip_select_mode.count > 1 then (
			vip_select_mode  = vip_select_mode as booleanClass
		)else(
			vip_select_mode = true
		)
	)

	CS_All = #()
	if vip_select_mode then (
		if selection.count > 0 then
		(
			for i in selection do
			(
				if i.classid[1] == 37157 do (
					try(
				   		if i.ishidden == false and i.transform.controller.classid[1] != 12305 do (append CS_All i)
				   )catch(
				   		if i.ishidden == false and i.controller.classid[1] != 12305 do (append CS_All i)
				   )
				)
			)
		)else(

			for i in objects do
			(
				if i.classid[1] == 37157 do (
					try(
					   if i.ishidden == false and i.transform.controller.classid[1] != 12305 do
					   (append CS_All i)
					)catch(
					   	if i.ishidden == false and i.controller.classid[1] != 12305 do
					   	(append CS_All i)
					)
				)
			)
		)
	)else(
		for i in objects do
		(
			if i.classid[1] == 37157 do (
				try(
			   		if i.ishidden == false and i.transform.controller.classid[1] != 12305 do
			   		(append CS_All i)
			   )catch(
			   		if i.ishidden == false and i.controller.classid[1] != 12305 do
			   		(append CS_All i)
			   )
			)
		)
	)
	select CS_All
)
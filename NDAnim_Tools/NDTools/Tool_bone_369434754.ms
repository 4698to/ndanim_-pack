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

	Bn_All = #()
	if vip_select_mode then (
		if selection.count > 0 then
		(
			Bn_All = for i in selection where (classof i==BoneGeometry and i.ishidden==false ) collect i;
		)else (
			Bn_All = for i in objects where (classof i==BoneGeometry and i.ishidden==false ) collect i;

		)
	)else(
		Bn_All = for i in objects where (classof i==BoneGeometry and i.ishidden==false ) collect i;
	)
	select Bn_All
)
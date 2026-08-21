--https://gitee.com/to4698/ND_tools/tree/master/XX_NDtools
--738746223@qq.com
-- 2021.2.11
try(destroyDialog create_bone_chain)catch()

rollout create_bone_chain_tools "其他工具" width:200 height:150
(
	label lab_01 "仅对Bone有效,锁定解锁选中的Bone"
	group "锁定曲线" (
		button btn_lockedTracks_p "锁位置" width:65 height:25 across:3 
		button btn_lockedTracks_r "锁旋转" width:65 height:25
		button btn_lockedTracks_s "锁缩放" width:65 height:25
	)
	group "解锁曲线" (
		button btn_unlockedTracks_p "解位置" width:65 height:25 across:3
		button btn_unlockedTracks_r "解旋转" width:65 height:25
		button btn_unlockedTracks_s "解缩放" width:65 height:25
	)
	fn lockedTracksMan_anim pt types is_locked =
	(
		if types == 0 do 
		(
			--Path_Constraint
			if pt.position.controller.classid[1] == 8209 do 
			(
				for i = 2 to 4 do 
				(
					objtm_anim = pt.position.controller[i]
					if objtm_anim.controller == undefined do 
					(
						objtm_anim.controller = bezier_float ()
					)					
					lockedTracksMan.setLocks is_locked #(objtm_anim) #(pt) 1 true
				)
			)
		)
		--位置
		if types == 1 do
		(
			lockedTracksMan.setLocks is_locked #(pt.position.controller) #(pt) 1 true
		)
		--旋转
		if types == 2 do
		(
			lockedTracksMan.setLocks is_locked #(pt.rotation.controller) #(pt) 1 true
		)
		--缩放
		if types == 3 do
		(
			lockedTracksMan.setLocks is_locked #(pt.scale.controller) #(pt) 1 true
		)
	)

	on btn_lockedTracks_p pressed do
	(
		for i in selection do 
		(
			--BoneGeometry
			if i.classid[1] == 683634317 do 
			(
				lockedTracksMan_anim i 1 true
			) 
		)
	)
	on btn_lockedTracks_r pressed do
	(
		for i in selection do 
		(
			--BoneGeometry
			if i.classid[1] == 683634317 do 
			(
				lockedTracksMan_anim i 2 true
			) 
		)
	)
	on btn_lockedTracks_s pressed do
	(
		for i in selection do 
		(
			--BoneGeometry
			if i.classid[1] == 683634317 do 
			(
				lockedTracksMan_anim i 3 true
			) 
		)
	)

	on btn_unlockedTracks_p pressed do
	(
		for i in selection do 
		(
			--BoneGeometry
			if i.classid[1] == 683634317 do 
			(
				lockedTracksMan_anim i 1 false
			) 
		)
	)
	on btn_unlockedTracks_r pressed do
	(
		for i in selection do 
		(
			--BoneGeometry
			if i.classid[1] == 683634317 do 
			(
				lockedTracksMan_anim i 2 false
			) 
		)
	)
	on btn_unlockedTracks_s pressed do
	(
		for i in selection do 
		(
			--BoneGeometry
			if i.classid[1] == 683634317 do 
			(
				lockedTracksMan_anim i 3 false
			) 
		)
	)
)

rollout create_bone_chain_info "统计信息" width:200 height:150
(

	label lab_01 "等待移除的：？" across:2
	label lab_02 "新增：？" 
	button btn_get_remove_bones "统计" width:35 height:25

	button btn_get_remove "选择待移除骨骼" width:100 height:25 across:2
	button btn_get_new "选择新增骨骼" width:100 height:25
	
	button btn_dele_all_remove "删除所有待删骨骼" width:200 height:25
	
	button btn_remove_new_name "删除新增骨骼命名前缀" width:200 height:25
		

	local remove_list = #()
	local meger_list = #()
	local new_chai_list = #()
	
	fn get_bones_change =
	(
		remove_list = #()
		meger_list = #()
		new_chai_list = #()
		for i in objects do 
		(
			if matchPattern i.name pattern:"Remove_*" do 
			(
				append remove_list i 
			)	
			if matchPattern i.name pattern:"MergeBone_*" do 
			(
				append meger_list i 
			)
			if matchPattern i.name pattern:"NewChai_*" do 
			(
				append new_chai_list i 
			)
		)
		lab_01.text = "等待移除的：" + (remove_list.count as string )
		new_count = new_chai_list.count + meger_list.count
		lab_02.text = "新增：" + (new_count as string )
	)
	fn replace_obj_name _obj replace_name = 
	(
		newname = dotNetObject "System.String" _obj.name
		newname_ = newname.replace replace_name ""
		_obj.name = newname_
	)
	on btn_get_remove_bones pressed do 
	(
		get_bones_change()
	)
	on btn_get_remove pressed do 
	(
		get_bones_change()
		select remove_list
	)
	on btn_get_new pressed do 
	(
		get_bones_change()
		select meger_list
		selectmore new_chai_list
	)
	on btn_dele_all_remove pressed do 
	(
		get_bones_change()
		msg = "是否确定删除所有待删骨骼？共" + (remove_list.count as string ) + " 根"
		if queryBox msg beep:false do (
			try(
				undo "remove_all_list" on (
					delete remove_list
				)
			)catch()
		)
	)
	on btn_remove_new_name pressed do 
	(
		get_bones_change()
		undo "new_bone_names" on (
			for i in meger_list do 
			(
				replace_obj_name i "MergeBone_"
			)
			for i in new_chai_list do 
			(
				replace_obj_name i "NewChai_"
			)
			_count = meger_list.count + new_chai_list.count 
			msg = "共修改 " + (_count as string) + "个骨骼的命名,注意检查是否有 Bone 重名"
			messageBox msg 
		)
	)
)
rollout create_bone_chain "骨骼链编辑" width:200 height:350
(
	group "" (
		label lab_02 "1. 先按骨骼顺序选中骨骼链" Align:#left 
		label lab_03 "2. 然后使用 分配、合并 功能" Align:#left
	)
	edittext edit_name "Bone名前缀：" text:"Bone_" fieldWidth:85 height:20 

	spinner spn2 "骨骼数量:"  fieldWidth:57 height:16 range:[1,100,10] type:#integer scale:1 Align:#left 
	spinner spn_gradient "渐变系数:" fieldWidth:57 height:16 range:[0.1,1.0,0.8] type:#float scale:0.1 Align:#left tooltip:"控制骨骼长度渐变效果，0.1=强烈渐变，1.0=无渐变" 
	
	checkbox check_change_child "新骨骼接受旧骨骼子级" checked:true
	checkbox check_remoe_old_bone "删除旧骨骼"  

	--button btn_reset "撤销" width:120 height:25  tooltip:"删除"
	label lab_04 ""
	group "分配骨骼链" (
		button bnt_reconstruct_chain "重新分配骨骼链" width:120 height:25 
	)
	group "骨骼融合" (
		checkbox check_frist_bone "以第一节为准"
		button btn_merge_bone "合并骨骼"  width:120 height:25 tooltip:"合并选择骨骼"
	)
	label lab_help "738746223@qq.com"
	local the_curve = undefined
	local merge_bones = #()
	local cumulative_distances=#()
	
	fn classofobj obj =
	(
		if classof obj == line or classof obj == SplineShape then
		(
			return true

		)else(
		   return false

		)
		
	)
	fn change_name_tag _objs _name = 
	(
		for i in _objs do
		(
			if not (matchPattern i.name pattern:(_name+"*")) then (
				i.name = _name + i.name 
			)
		)
	)
	fn change_name_remove _objs = 
	(
		change_name_tag _objs "Remove_"
	)
	fn change_name_merge _objs = 
	(
		change_name_tag _objs "MergeBone_"
	)

	fn change_children_new_parent _obj _new_parnet = 
	(
		for i in _obj.children do 
		(
			i.parent = _new_parnet 
		)

	)
	
	fn createBoneform_tm tmlist is_end_bone width height =
	(
		local t_bones = #()
		for s=1 to tmlist.count do
		(
			start_tm = tmlist[s]
			end_tm = tmlist[s + 1]
			if s < tmlist.count then
			(
				local t_b = BoneSys.createBone start_tm.pos end_tm.pos start_tm.row3
				if edit_name.text.count > 0 do 
				(
					t_b.name = uniquename(edit_name.text)
				) 
				t_b.width = width * 1.2 
				t_b.height = height* 1.2 
				append t_bones t_b
			)else(
				if is_end_bone do (
					local t_b_p = t_bones[(t_bones.count)]
					local t_b = BoneSys.createBone tmlist[s].pos (tmlist[s].pos * 1.1) t_b_p.dir
					if edit_name.text.count > 0 do 
					(
						t_b.name = uniquename("End_"+edit_name.text)
					) 
					t_b.transform = t_b_p.transform

					in coordSys Local move t_b [t_b_p.length,0,0]

					t_b.width = width* 1.2 
					t_b.height = height* 1.2 
					t_b.taper = 90
					t_b.length= (t_b.width + t_b.height)/2
					t_b.name= uniquename "end"
					append t_bones t_b
				)
			)
			if s > 1 then
			(
				if isValidNode t_bones[s] do (t_bones[s].parent = t_bones[s - 1])
				
			)
		)
		return t_bones
	)
	
	
	
	
	-- 球面线性插值
	fn squad_slerp2 q1 q2 t =
	(
	    local _dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w
	    if _dot < 0 then
	    (
	        --q1 = for i in 1 to 4 collect -q1[i]
	        q1 = q1 * -1.0
	        _dot = _dot * -1.0
	    )

	    local DOT_THRESHOLD = 0.9995
	    if _dot > DOT_THRESHOLD then
	    (
	        -- 如果角度非常小，使用线性插值
	        --local result = for i in 1 to 4 collect (q1[i] + t * (q2[i] - q1[i]))
	        --return normalize result

	        result = slerp q1 q2 t 
	        return result
	    )
	    --format "_dot -> %\n" _dot

	    local theta_0 = degtorad (acos _dot) --(clamp _dot -1.0 1.0)
	    --local sin_theta_0 = sin theta_0
	    sin_theta_0 = sin (acos _dot)

	    --format "theta_0 -> % ,%\n" theta_0 sin_theta_0


	    local theta = theta_0 * t
	    local sin_theta = sin (radtodeg theta)
	    local cos_theta = cos (radtodeg theta)
	    --format "sin_theta -> %, %\n" sin_theta cos_theta

	    local s0 = cos_theta - _dot * sin_theta / sin_theta_0
	    local s1 = sin_theta / sin_theta_0
	    --format "s0 -> %, %\n" s0 s1 
	    
	    q3 = quat 0 0 0 1 
	    q3.x = q1.x * s0 + q2.x * s1  
	    q3.y = q1.y * s0 + q2.y * s1
	    q3.z = q1.z * s0 + q2.z * s1
	    q3.w = q1.w * s0 + q2.w * s1

	    --不等同于 (q1 * s0 + q2 *s1) 

	    return (normalize q3) 

	)

	fn find_refine_bone_length_index cumulative_distances target_distance =
	(
		-- 找到目标距离在累积距离中的位置
		local segment_index = 1
		for j = 1 to cumulative_distances.count do
		(
			if target_distance <= cumulative_distances[j] then
			(
				segment_index = j
				return segment_index
			)
		)
	)

	fn refine_matrix3 tmlist _count _sun_lenght gradient_factor =
	(
		--从矩阵列表中 tmlist ，基于平均长度混合权重创建 count 个矩阵
		if tmlist.count < 2 do return tmlist -- 如果输入矩阵少于2个，直接返回
		if _count <= 1 do 
		(
			-- 当只需要1个矩阵时，使用第一个和最后一个矩阵进行混合
			local tm1 = tmlist[1]
			local tm2 = tmlist[tmlist.count]
			
			-- 插值位置
			local pos1 = tm1[4]
			local pos2 = tm2[4]
			local new_pos = pos1 --(pos1 + pos2) * 0.5 -- 中点
			
			-- 插值旋转（四元数插值）
			local rot1 = tm1.rotationPart as quat
			local rot2 = tm2.rotationPart as quat
			local new_rot = slerp rot1 rot2 0.5 -- 中点插值
			
			-- 构造新矩阵
			local new_tm = matrix3 (new_rot as matrix3).row1 (new_rot as matrix3).row2 (new_rot as matrix3).row3 new_pos
			return #(new_tm)
		)
		
		-- 计算渐变长度：一节比一节短
		-- 使用等比数列，第一根骨骼最长，最后一根最短
		local gradient_lengths = #()
		local total_gradient_length = 0.0
		
		-- 计算等比数列的长度
		for i = 1 to _count do
		(
			local length_factor = pow gradient_factor (i - 1)
			append gradient_lengths length_factor
			total_gradient_length += length_factor
		)
		
		-- 根据总长度调整每个骨骼的实际长度
		local scale_factor = _sun_lenght / total_gradient_length
		for i = 1 to gradient_lengths.count do
		(
			gradient_lengths[i] = gradient_lengths[i] * scale_factor
		)
		
		format "渐变长度: %\n" gradient_lengths
		
		-- 计算原始矩阵之间的累积距离
		local cumulative_distances = #()
		local total_distance = 0.0
		for i = 1 to (tmlist.count - 1) do
		(
			local dist = distance tmlist[i][4] tmlist[i + 1][4]
			total_distance += dist
			append cumulative_distances total_distance
		)
		format "%\n" cumulative_distances

		/* target_distance_list = #()
		-- 为每个目标位置计算混合权重
		for i = 1 to (_count) do
		(
			-- 计算当前目标位置在总距离中的位置
			local target_distance = i * average_length
			append target_distance_list target_distance 
		)
		format "%\n" target_distance_list */

		local result_matrices = #()
		local target_distance = 0 
		format "Bone count -> % , tmlist count -> % , cumulative_distances.count -> %\n" _count tmlist.count cumulative_distances.count
		-- 为每个目标位置计算混合权重
		for i = 0 to (_count) do
		(
			format "New TM -> %\n" i 
			
			-- 计算当前目标位置在总距离中的位置（使用渐变长度）
			if i == 0 then
			(
				target_distance = 0
			)else(
				-- 累积渐变长度
				target_distance = 0
				for j = 1 to i do
				(
					target_distance += gradient_lengths[j]
				)
			)   
			/* 
				target_distance = average_length  
			 */
			-- 找到目标距离在累积距离中的位置
			local segment_index = 1
			for j = 1 to cumulative_distances.count do
			(
				format "	try -> % , % ,%\n" target_distance cumulative_distances[j] (target_distance - cumulative_distances[j])
				if target_distance <= cumulative_distances[j] do
				(
					segment_index = j 
					format "	target_distance1 -> % -> %\n" target_distance j 
					exit
				)
				if (abs(target_distance - cumulative_distances[j]) < 0.001) do (
					segment_index = j 
					format "	target_distance2 -> % -> %\n" target_distance j 
				)
			)
			
			--format "segment % :: % -> % \n" i target_distance segment_index  
			-- 确保不超出范围
			--segment_index = amin#(segment_index, tmlist.count - 1)
			
			-- 计算在段内的插值参数
			local segment_start_dist = if segment_index > 1 then cumulative_distances[segment_index - 1] else 0.0
			local segment_end_dist = cumulative_distances[segment_index]
			local segment_length = segment_end_dist - segment_start_dist
			
			local local_t = if segment_length > 0.0001 then(
				(target_distance - segment_start_dist) / segment_length )else( 0.0)
			
			-- 限制插值参数在 [0, 1] 范围内
			local_t = amax#(0.0, amin#(1.0, local_t))
			

			-- 获取两个矩阵
			local tm1 = tmlist[segment_index]
			local tm2 = tmlist[segment_index + 1]
			
			-- 插值位置
			local pos1 = tm1.pos -- 矩阵的平移部分
			local pos2 = tm2.pos 
			local new_pos = pos1 + (pos2 - pos1) * local_t
			format "	local_t: % -> % ,% \n" local_t segment_index (segment_index + 1)
			-- 插值旋转（四元数插值）
			local rot1 = tm1.rotation--Part as quat
			local rot2 = tm2.rotation--Part as quat
			local new_rot = squad_slerp2 rot1 rot2 local_t -- 球面线性插值
			
			new_tm = new_rot as matrix3 
			new_tm.pos = new_pos
			-- 构造新矩阵
			--local new_tm = matrix3 (new_rot as matrix3).row1 (new_rot as matrix3).row2 (new_rot as matrix3).row3 new_pos
			append result_matrices new_tm
		)
		
		result_matrices -- 返回结果矩阵列表
	)
	/* on btn_reset pressed do
	(
		try(delete test_bone)catch()

	) */
	on bnt_reconstruct_chain pressed do 
	(
		merge_bones = selection as Array
		
		bonestm = #()
		start_bone = merge_bones[1]

		end_bone = merge_bones[merge_bones.count]

		--所有骨骼的长度
		sun_lenght = 0 
		for i in merge_bones do 
		(
			append bonestm i.transform 
			sun_lenght += i.length
			
		)
		

		end_tm = PreTranslate end_bone.transform ([end_bone.length,0,0])
		append bonestm end_tm
 
		new_tms = refine_matrix3 bonestm spn2.value sun_lenght spn_gradient.value 
		undo "new_bone_chai" on (

			
			new_merge_bones = createBoneform_tm new_tms true start_bone.width start_bone.height
			
			new_merge_bones[1].parent = start_bone.parent 
			for i in new_merge_bones do 
			(
				i.name = uniquename (start_bone.name + "_")
			)
			change_name_remove merge_bones
			change_name_tag new_merge_bones "NewChai_"
		)
	)
	on btn_merge_bone pressed do 
	(
		
		merge_bones = selection as Array
		
		if merge_bones.count > 1 then 
		(
			bonestm = #()
			start_bone = merge_bones[1]
			append bonestm (start_bone.transform)
			
			end_bone = merge_bones[merge_bones.count]
			end_tm = PreTranslate end_bone.transform ([end_bone.length,0,0])
			
			append bonestm end_tm
			
	 		undo "ff_merger_bone" on 
	 		(
	 			if check_frist_bone.state then (
	 				--以第一节为准的合并
					new_merge_bone = copy start_bone 
					new_merge_bone.length = distance start_bone.pos end_tm.pos 
					new_merge_bone.parent = start_bone.parent
					new_merge_bone.name = "MergeBone_" + start_bone.name 
				)else(
					-- 重新创建的合并
					new_merge_bones = createBoneform_tm bonestm false start_bone.width start_bone.height
					new_merge_bone = new_merge_bones[1]
					change_name_merge #(new_merge_bone)
					new_merge_bone.name ="MergeBone_" + (uniquename (start_bone.name ))

				)
				
				

				new_merge_bone.parent = start_bone.parent
				try(
				if check_change_child.state do (
					if isValidNode new_merge_bone do (
						for i in merge_bones do 
						(
							
							for o in i.children do 
							(
								if findItem merge_bones o ==0 do (
									o.parent = new_merge_bone
								)
							)
						)
					)
				)
				
				change_name_remove merge_bones

				if check_remoe_old_bone.state do
				(
					try(delete merge_bones)catch()
					
				)
				)catch()
			)
		)else(
			messageBox "请选择多根连续骨骼"
		)
	)
)

--createDialog create_bone_chain
try(
	closeRolloutFloater create_bone_chainFloater
)
catch()

create_bone_chainFloater = newRolloutFloater "骨骼链编辑" 240 500
addRollout create_bone_chain create_bone_chainFloater 
addRollout create_bone_chain_info create_bone_chainFloater
addRollout create_bone_chain_tools create_bone_chainFloater

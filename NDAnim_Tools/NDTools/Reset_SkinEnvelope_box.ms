
try(DestroyDialog Reset_SkinEnvelope_box)catch()
rollout Reset_SkinEnvelope_box "重置骨骼封套.v42" height:200 width:230
(
	checkbox env_type "固定点状封套" across:2
	spinner env_size "长度:" range:[0.001,5,0.1] type:#float scale:0.01 Align:#left 
	
	checkbox name_filter_state "名字过滤" across:2
	edittext name_filter "" text:"_L_" Align:#left 
	button btn_reset_bone_size "重置骨骼大小" toolTip:"重置选中骨骼大小" height:22 width:100 across:2
	button Reset_Env "重置封套"  toolTip:"选取模型重置封套" height:22 width:100

	group "蒙皮中镜像骨骼检测" (
		edittext edit_find_str "查找字符：" text:"_R_" Align:#left width:160 across:2
		button btn_swap_mirror "交换" height:22 width:40 toolTip:"交换查找字符和镜像字符" offset:[0,-2] align:#right
		edittext edit_mirror_str "镜像字符：" text:"_L_" Align:#left width:160

		
		button btn_find_mirror "镜像检测" height:22 width:100
	)
	progressBar 'progressBar' "ProgressBar"   --进度条
	
	fn get_bone_envelope _length = 
	(
		if env_type.state do 
		(
			_length = env_size.value
		)
		_length
	)
	fn set_bone_size boneobj = -- 按骨骼类型重置骨骼大小
	(
		case (classof boneobj) of
		(
			BoneGeometry :
			(
				boneobj.width = env_size.value
				boneobj.height = env_size.value
				boneobj.length = env_size.value
			)
			Biped_Object :
			(
				-- biped 骨骼大小由系统控制,暂不处理
			)
			(Box):(
				boneobj.width = env_size.value
				boneobj.height = env_size.value
				boneobj.length = env_size.value
			)
			(Point):(
				boneobj.size = env_size.value
			)
		)
	)
	fn replace_string str1 str2 str3 = 
	(
		start_index = findString str1 str2
		
		if start_index == undefined then (
			return undefined
		)else(
	    	end_index = str2.count
	    	return (replace str1 start_index end_index str3)
	    )
	)
	on btn_swap_mirror pressed do
	(
		local tmp = edit_find_str.text
		edit_find_str.text = edit_mirror_str.text
		edit_mirror_str.text = tmp
	)
	on btn_find_mirror pressed do 
	(
		if selection.count == 1 then 
		(
			objSkin = selection[1].modifiers[#Skin]
			if not isValidObj objSkin do (
				messageBox "选中物体没有 skin "
				return false
			)
			
			skin_BoneNum = skinOps.getNumberBones objSkin
			skin_Bones = #()
			for i=1 to skin_BoneNum do
			(
				Bone_Name = skinOps.GetBoneName objSkin i 1 ---获取ID骨骼名称
				append skin_Bones Bone_Name
			)
			
			find_state = stringStream ""
			find_names = #()
			for i = 1 to skin_Bones.count do 
			(
				Bone_Name = skin_Bones[i]
				mirror_name = replace_string Bone_Name edit_find_str.text edit_mirror_str.text 
				if mirror_name != undefined do 
				(
					index = findItem skin_Bones mirror_name 
					if index == 0 do (
						append find_names mirror_name
						--format "% 缺失 => % \n" Bone_Name mirror_name to:find_state
						format "%\n" mirror_name to:find_state

					)
				)
				progressBar.value = ((i as float) / (skin_BoneNum as float)) * 100
			)
			if find_names.count > 0 then (
				messageBox (find_state as string) title:"蒙皮中缺少以下镜像骨骼"
				format "蒙皮中缺少以下镜像骨骼：\n%\n建议将缺少骨骼添加到蒙皮中\n" (find_state as string) 
			)else(
				messageBox "蒙皮中的镜像骨骼配对正常" 
			)

		)else(
			messageBox "选中 一个 蒙皮模型再试"
		)
	)
	on btn_reset_bone_size pressed do 
	(
		if selection.count == 1 then 
		(
			objSkin = selection[1].modifiers[#Skin]
			if not isValidObj objSkin do (
				--messageBox "选中物体没有 skin "
				for i in selection do (
					set_bone_size i
				)
				return false
			)
			
			skin_BoneNum = skinOps.getNumberBones objSkin
			for i=1 to skin_BoneNum do
			(
				Bone_Name = skinOps.GetBoneName objSkin i 1 ---获取ID骨骼名称
				
				if name_filter_state.state do 
				(
					index = findString Bone_Name name_filter.text 
					if index == undefined do (Continue)
				)

				if Bone_Name != undefined do
				(
					boneobj = getNodeByName Bone_Name
				)
				set_bone_size boneobj
				progressBar.value = ((i as float) / (skin_BoneNum as float)) * 100
			)
			progressBar.value = 0
		)else(
			for i in selection do (
				set_bone_size i
			)
			--messageBox "选中 一个 蒙皮模型再试"
		)
	)
	on Reset_Env pressed do
	(
		if selection.count == 1 then 
		(
			objSkin = selection[1].modifiers[#Skin]
			if not isValidObj objSkin do (
				messageBox "选中物体没有 skin "
				return false
			)
			
			skin_BoneNum = skinOps.getNumberBones objSkin
			for i=1 to skin_BoneNum do
			(
				Bone_Name = skinOps.GetBoneName objSkin i 1 ---获取ID骨骼名称
				
				if name_filter_state.state do 
				(
					index = findString Bone_Name name_filter.text 
					if index == undefined do (Continue)
				)

				if Bone_Name != undefined do
				(
					boneobj = getNodeByName Bone_Name
				)
				case (classof boneobj ) of
				(
					BoneGeometry :
					(
						Bone_length = get_bone_envelope boneobj.length ---获取骨骼长度
						skinOps.setEndPoint objSkin i [0,0,0]   ---重置当前ID骨骼结束封套点
						skinOps.setStartPoint objSkin i [(Bone_length * 0.8),0,0]  ---重置当前ID骨骼开始封套点
					)
					Biped_Object :
					(
						skinOps.SetStartPoint objSkin i [0,0.01,0.01]
						skinOps.SetEndPoint objSkin i [1,0.01,0.01]  
						if (findString Bone_Name "Pelvis") != undefined do
						(
							skinOps.SetStartPoint objSkin 1 [-0.0087,0.00196,0.5]	
							skinOps.SetEndPoint objSkin 1 [-0.0087,0.00196,-0.5]
						)
					)
					(Box):(
						Bone_length = get_bone_envelope boneobj.height 
						skinOps.setEndPoint objSkin i [0,0,0] 
						skinOps.setStartPoint objSkin i [0,0,(Bone_length * 0.8)] 
						)
					(Point):(
						Bone_length = get_bone_envelope boneobj.size  
						skinOps.setEndPoint objSkin i [0,0,0] 
						skinOps.setStartPoint objSkin i [0,0,(Bone_length * 1.1)] 
						)
					(Dummy):(
						-- dummy 只有 boxsize 一个属性 [x,y,z]
						-- 所以需要根据 boxsize 来设置骨骼长度
						Bone_length = get_bone_envelope boneobj.boxsize  
						skinOps.setEndPoint objSkin i [0,0,0] 
						skinOps.setStartPoint objSkin i [0,0,(Bone_length * 1.1)] 
						)
				)
				progressBar.value = ((i as float) / (skin_BoneNum as float)) * 100
			)
			progressBar.value = 0
		)else(
			messageBox "选中 一个 蒙皮模型再试"
		)
	)
)
createdialog Reset_SkinEnvelope_box




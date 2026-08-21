try(
	DestroyDialog BoneRigRootmotiontools
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\UE4_Moyu_back_tools_bone_v5.mse"
	if doesFileExist scriptfile then 
	(
		/* msg = "将选中多个物体的帧位统一成第一个选中的一样 \n"
		yes_no = queryBox msg title:"无UI脚本" */
		
		--if yes_no do (
			filein scriptfile
			createDialog BoneRigRootmotiontools
		--)
	)else(
		format "No find - %" scriptfile 
	)
)
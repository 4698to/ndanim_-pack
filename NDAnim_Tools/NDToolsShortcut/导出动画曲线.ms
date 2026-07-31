try(
	DestroyDialog export_anim_Curves
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\Ue4_Animation_Curves_v4.mse"
	if doesFileExist scriptfile then 
	(
		/* msg = "将选中多个物体的帧位统一成第一个选中的一样 \n"
		yes_no = queryBox msg title:"无UI脚本" */
		
		--if yes_no do (
			filein scriptfile
			createDialog export_anim_Curves
		--)
	)else(
		format "No find - %" scriptfile 
	)
)
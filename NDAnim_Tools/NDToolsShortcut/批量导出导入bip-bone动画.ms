try(
	DestroyDialog autoSaveLoadAni_rollout
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\charactorAniTool\\autoSaveLoadAni.mse"
	if doesFileExist scriptfile then 
	(
		/* msg = "将选中多个物体的帧位统一成第一个选中的一样 \n"
		yes_no = queryBox msg title:"无UI脚本" */
		
		--if yes_no do (
			filein scriptfile
			createDialog autoSaveLoadAni_rollout
		--)
	)else(
		format "No find - %" scriptfile 
	)
)
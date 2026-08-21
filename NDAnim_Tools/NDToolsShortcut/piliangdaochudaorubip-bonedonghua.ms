--piliangdaochudaorubip-bonedonghua.ms
--批量导出导入bip-bone动画.ms
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
			try(createDialog autoSaveLoadAni_rollout)catch()
		--)
	)else(
		format "No find - %" scriptfile 
	)
)
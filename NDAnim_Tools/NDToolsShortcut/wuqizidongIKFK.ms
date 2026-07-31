--wuqizidongIKFK.ms
--武器自动 IK FK.ms
try(
	DestroyDialog create_WP_ik_rollout
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\WP_IK_rollout.mse"
	if doesFileExist scriptfile then 
	(
		/* msg = "将选中多个物体的帧位统一成第一个选中的一样 \n"
		yes_no = queryBox msg title:"无UI脚本" */
		
		--if yes_no do (
			filein scriptfile
			try(createDialog create_WP_ik_rollout)catch()
		--)
	)else(
		format "No find - %" scriptfile 
	)
)
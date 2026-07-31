try(
	DestroyDialog CreatDummy_rollout
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\Sele_Point_rollout.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog CreatDummy_rollout
	)else(
		format "No find - %" scriptfile 
	)
)
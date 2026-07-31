--fuzhuwuti.ms
--辅助物体.ms
try(
	DestroyDialog CreatDummy_rollout
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\Sele_Point_rollout.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog CreatDummy_rollout)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
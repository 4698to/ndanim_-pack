try(
	--DestroyDialog CreatDummy_rollout
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\convert_stretch_scale.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
	)else(
		format "No find - %" scriptfile 
	)
)
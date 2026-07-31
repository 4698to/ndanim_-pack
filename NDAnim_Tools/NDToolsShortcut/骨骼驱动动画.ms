try(
	DestroyDialog driver_bonepose
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\driver_bonepose_v02.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog driver_bonepose
	)else(
		format "No find - %" scriptfile 
	)
)
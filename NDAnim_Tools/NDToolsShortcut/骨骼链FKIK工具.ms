try(
	DestroyDialog bone_spline_tool
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\bonelinkFKIK.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog bone_spline_tool
	)else(
		format "No find - %" scriptfile 
	)
)
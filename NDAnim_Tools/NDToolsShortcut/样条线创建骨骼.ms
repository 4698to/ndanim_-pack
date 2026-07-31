try(
	DestroyDialog createbone_spline
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\create_spline_bone.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog createbone_spline
	)else(
		format "No find - %" scriptfile 
	)
)
try(
	DestroyDialog bone_spline_tool_ceate
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\createspline.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog bone_spline_tool_ceate
	)else(
		format "No find - %" scriptfile 
	)
)
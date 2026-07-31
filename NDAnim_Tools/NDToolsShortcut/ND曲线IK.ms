try(
	DestroyDialog newSpineIK_Curve
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\cgjoy-Spline_IK40.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog newSpineIK_Curve
	)else(
		format "No find - %" scriptfile 
	)
)
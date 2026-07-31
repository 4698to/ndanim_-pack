--NDquxianIK.ms
--ND曲线IK.ms
try(
	DestroyDialog newSpineIK_Curve
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\cgjoy-Spline_IK40.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog newSpineIK_Curve)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
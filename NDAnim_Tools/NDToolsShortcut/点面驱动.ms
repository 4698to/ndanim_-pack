try(
	DestroyDialog AttachToface
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\polygon_controls_v2.3.1.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog AttachToface
	)else(
		format "No find - %" scriptfile 
	)
)
try(
	DestroyDialog C3DisplacementTool
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\C3DisplacementTool.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog C3DisplacementTool
	)else(
		format "No find - %" scriptfile 
	)
)
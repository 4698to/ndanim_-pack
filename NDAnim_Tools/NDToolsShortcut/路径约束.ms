try(
	DestroyDialog newPath_Constraint
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\path_constraint_v4.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog newPath_Constraint
	)else(
		format "No find - %" scriptfile 
	)
)
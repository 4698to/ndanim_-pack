try(
	DestroyDialog FBXTools
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\FBXTools.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog FBXTools
	)else(
		format "No find - %" scriptfile 
	)
)
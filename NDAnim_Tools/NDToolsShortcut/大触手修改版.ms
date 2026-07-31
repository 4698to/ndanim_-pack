try(
	DestroyDialog Tentacle_Modify
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\Tentacle_Modify.mse"
	if doesFileExist scriptfile then 
	(
		
		filein scriptfile
		if Tentacle_Modify !=undefined do (
			try(createDialog Tentacle_Modify)catch()
		)
	)else(
		format "No find - %" scriptfile 
	)
)
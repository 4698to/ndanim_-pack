try(
	DestroyDialog PointAnimationCovert
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\PointAnimationCovert.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		createDialog PointAnimationCovert
	)else(
		format "No find - %" scriptfile 
	)
)
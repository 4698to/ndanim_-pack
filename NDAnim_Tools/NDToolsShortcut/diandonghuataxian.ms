--diandonghuataxian.ms
--点动画塌陷.ms
try(
	DestroyDialog PointAnimationCovert
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\PointAnimationCovert.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog PointAnimationCovert)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
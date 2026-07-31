--gugequdongdonghua.ms
--骨骼驱动动画.ms
try(
	DestroyDialog driver_bonepose
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\driver_bonepose_v02.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog driver_bonepose)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
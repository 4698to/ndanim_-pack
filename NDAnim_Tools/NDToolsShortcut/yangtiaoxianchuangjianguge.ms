--yangtiaoxianchuangjianguge.ms
--样条线创建骨骼.ms
try(
	DestroyDialog createbone_spline
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\create_spline_bone.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog createbone_spline)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
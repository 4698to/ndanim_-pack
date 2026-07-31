--gugelianFKIKgongju.ms
--骨骼链FKIK工具.ms
try(
	DestroyDialog bone_spline_tool
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\bonelinkFKIK.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		if bone_spline_tool != undefined do 
		(
			createDialog bone_spline_tool
		)
	)else(
		format "No find - %" scriptfile 
	)
)
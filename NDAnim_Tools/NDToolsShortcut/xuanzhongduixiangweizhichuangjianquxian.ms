--xuanzhongduixiangweizhichuangjianquxian.ms
--选中对象位置创建曲线.ms
try(
	DestroyDialog bone_spline_tool_ceate
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\createspline.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog bone_spline_tool_ceate)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
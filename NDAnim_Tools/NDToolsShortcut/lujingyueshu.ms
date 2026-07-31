--lujingyueshu.ms
--路径约束.ms
try(
	DestroyDialog newPath_Constraint
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\path_constraint_v4.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog newPath_Constraint)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
--C3_weiyifuzhu.ms
--C3_位移辅助.ms
try(
	DestroyDialog C3DisplacementTool
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\C3DisplacementTool.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		if C3DisplacementTool != undefined do (
			createDialog C3DisplacementTool
		)
	)else(
		format "No find - %" scriptfile 
	)
)
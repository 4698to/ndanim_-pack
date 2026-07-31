--FBXgongju.ms
--FBX工具.ms
try(
	DestroyDialog FBXTools
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\FBXTools.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog FBXTools)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
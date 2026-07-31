--yundonglujing_BYdongjianyun.ms
--运动路径_BY东见云.ms
/* try(
	DestroyDialog CreatDummy_rollout
)catch() */

(
	scriptfile = (getdir #scripts) + "\\NDTools\\cgjoy-运动路径_BY东见云.ms"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog CreatDummy_rollout)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
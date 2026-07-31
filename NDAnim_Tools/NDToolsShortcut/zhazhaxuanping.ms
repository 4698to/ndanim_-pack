--zhazhaxuanping.ms
--渣渣渲屏.ms
/* try(
	DestroyDialog CreatDummy_rollout
)catch() */

(
	scriptfile = (getdir #scripts) + "\\NDTools\\渣渣渲屏_v22.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
	)else(
		format "No find - %" scriptfile 
	)
)
--dianmianqudong.ms
--点面驱动.ms
try(
	DestroyDialog AttachToface
)catch()

(
	scriptfile = (getdir #scripts) + "\\NDTools\\polygon_controls_v2.3.1.mse"
	if doesFileExist scriptfile then 
	(
		filein scriptfile
		try(createDialog AttachToface)catch()
	)else(
		format "No find - %" scriptfile 
	)
)
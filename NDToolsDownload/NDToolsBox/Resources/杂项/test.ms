
	rollout joeSpeedTrajedit_rollout "" width:254 height:40
	(

	--bDisplayAll = false
	---开关按钮
	button btn_DisplayAll "" pos:[1,4] width:34 height:34 tooltip:joeSpeedTrajEdit_Globals.DisplayAll_tooltip
	---logo图标
	bitmap bmp_Titlebmp pos:[35,1] width:255 height:40 bitmap:joeSpeedTrajEdit_Globals.bmp_Title
	---关于按钮
	button btn_About "" pos:[152,4] width:34 height:34 images:#(joeSpeedTrajEdit_Globals.bmp_About, undefined, 1, 1, 1, 1, 1) tooltip:"左键关于信息，右键随机轨迹颜色"

	
	---新建轨迹
	button btn_New "" pos:[186,4] width:34 height:17 images:#(joeSpeedTrajEdit_Globals.bmp_New, undefined, 1, 1, 1, 1, 1) tooltip:"左键改变点标形状，右键恢复默认"
	button btn_New_Pivot "" pos:[186,21] width:34 height:17 images:#(joeSpeedTrajEdit_Globals.bmp_New_Pivot, undefined, 1, 1, 1, 1, 1) tooltip:"新建轨迹"
	
	---退出按钮
	button btn_Exit "" pos:[220,4] width:34 height:34 images:#(joeSpeedTrajEdit_Globals.bmp_Exit, undefined, 1, 1, 1, 1, 1) tooltip:"EXIT"
	-- 窗口移动功能
	on joeSpeedTrajedit_rollout mousemove pos do joeSpeedTrajEdit_Globals.MoveWindow joeSpeedTrajedit_rollout
	on joeSpeedTrajedit_rollout lbuttondown pos do joeSpeedTrajEdit_Globals.IsReadyToMove joeSpeedTrajedit_rollout pos
	on joeSpeedTrajedit_rollout lbuttonup pos do joeSpeedTrajEdit_Globals.LetGoTheWindow()	
	
	----改变点标形状功能
	on btn_New pressed do
	(
		print(btn_New.tooltip)
		if dotShape == "smallDiamond" do (dotShape = "hollowBox")
		if (findItem KeyP_shape dotShape)!= 0 do 
		(	
			if (findItem KeyP_shape dotShape)==KeyP_shape.count then 
			(
				dotShape=KeyP_shape[1]
				
			)
			else 
			(
				index = (findItem KeyP_shape dotShape) +1
				dotShape = KeyP_shape[index]
			)
		)
	)
	on btn_New rightClick  do
	(
		dotShape = "smallDiamond"
	)
	----打开界面是刷新图标
	on joeSpeedTrajedit_rollout open do 
	(
		--joeSpeedTrajEdit_Globals.UpdateBitmaps()
		--try(unregisterRedrawViewsCallback joeMotionSpeedPathCallBackFn_exc)catch()
		--registerRedrawViewsCallback joeMotionSpeedPathCallBackFn_exc

		--try(unRegisterTimeCallback joeSpeed_refreshDT_byTime_new_fn)catch()		
		--try (registerTimeCallback joeSpeed_refreshDT_byTime_new_fn) catch ()
		--try (joeSpeed_refreshDT_byTime_new_fn())	 catch ()
		
	)
	--退出窗口功能
	on btn_Exit pressed do
	(
		try(unRegisterTimeCallback joeSpeed_refreshDT_byTime_new_fn)catch()
		try unregisterRedrawViewsCallback joeMotionSpeedPathCallBackFn_exc catch()
		joeSpeedTrajEdit_Globals.UpdateBitmaps()
		joeSpeedTrajEdit_Globals = undefined

		DestroyDialog joeSpeedTrajedit_rollout
		gc()  ---内存管理	
		
	)
	on btn_Exit rightClick do
	(
		if joeSpeedTrajEdit_DTrajs_camRef  then 
		(	
			joeSpeedTrajEdit_DTrajs_camRef = false
			print "画面路径关闭<――~"
			joeSpeedTrajEdit_Rollout.btn_Exit.images = #(joeSpeedTrajEdit_Globals.bmp_About, undefined, 1, 1, 1, 1, 1)
			
		)
		else (
			joeSpeedTrajEdit_DTrajs_camRef = true
			cc = getActiveCamera()
			if cc!=undefined then
			(print cc.name +"画面路径开启，相机――>~")
			else (print	("画面路径开启，无相机――>~"))	
			joeSpeedTrajEdit_Rollout.btn_Exit.images = #(joeSpeedTrajEdit_Globals.bmp_About, undefined, 2, 1, 1, 1, 1)	
		)		
		gc()  ---内存管理
		
	)
	
	
	---关于按钮功能
	on btn_About pressed do
	(
		messagebox joeSpeedTrajEdit_Globals.About_tooltip 

	)
	on btn_About rightClick do
	(
		--print "随机颜色"
		fn HSV_to_RGB hsv = 
		(
			hsv /= 255
			h = hsv.x*6
			i = h as integer
			k = if (mod i 2) == 1 then (h-i) else (1-h+i)
			m = hsv.z*(1-hsv.y)
			n = hsv.z*(1-hsv.y*k)
			case i of
			(
					1: [n, hsv.z, m]*255
					2: [m, hsv.z, n]*255
					3: [m, n, hsv.z]*255
					4: [n, m, hsv.z]*255
					5: [hsv.z, m, n]*255
			  default: [hsv.z, n, m]*255
			)
		)	
		try(
		joeSpeedTrajEdit_UpdateRollout()
		
		for i = 1 to joeSpeedTrajEdit_DTrajs.count do 
		(
			dtrajs = joeSpeedTrajEdit_DTrajs[i]
			if dtrajs == undefined do (continue)
			if not IsValidNode dtrajs.node do (continue)
			bufferColorA =  HSV_to_RGB [(random 0 255),(random 90 255),255]  as color
			bufferColorB =  HSV_to_RGB [(random 0 255),(random 90 255),255]  as color
			execute ("joeSpeedTrajedit_rollout.col_Dot"+i as string+".color = bufferColorA")
			execute ("joeSpeedTrajedit_rollout.col_Spline"+i as string+".color = bufferColorB")
			dtrajs.col_Start = color 255 0 0
			dtrajs.colEnd = color 0 255 0

			dtrajs.col_Start = bufferColorA
			dtrajs.colEnd = bufferColorB

		)
		
		)catch()		
	)
	------切换界面大小
	on btn_DisplayAll pressed do
	(
		if keyboard.shiftPressed then
		(
		    i=1
			for i = 1 to joeSpeedTrajEdit_DTrajs.count do 
			(
				dtrajs = joeSpeedTrajEdit_DTrajs[i]
				dtrajs.timelong = not dtrajs.timelong
				if dtrajs.timelong then (
					execute ("joeSpeedTrajedit_rollout.time_FBONOff"+(i as string)+".state = true ;")
				)execute(
					execute ("joeSpeedTrajedit_rollout.time_FBONOff"+(i as string)+".state = false ;")
				)
				
				if not dtrajs.timelong then
				(
					execute ("joeSpeedTrajedit_rollout.btn_Range"+(i as string)+".pressed()")
				)
				try (joeSpeed_refreshDT_byTime_new_fn())	 catch ()
			)
		
		)
		else if  keyboard.controlPressed then
		(
			for i = 1 to joeSpeedTrajEdit_DTrajs.count do 
			(
				(execute ("joeSpeedTrajedit_rollout.btn_Move"+(i as string)+".pressed()"))
				try (joeSpeed_refreshDT_byTime_new_fn())catch ()
			)
		)
		else if  keyboard.altPressed then
		(
			for i = 1 to joeSpeedTrajEdit_DTrajs.count do 
			(
				
				execute ("joeSpeedTrajedit_rollout.isGradual"+(i as string)+".checked = not joeSpeedTrajedit_rollout.isGradual"+(i as string)+".checked")
				execute ("(joeSpeedTrajEdit_DTrajs["+(i as string)+"]).isGradual = joeSpeedTrajedit_rollout.isGradual"+(i as string)+".checked")
				try (joeSpeed_refreshDT_byTime_new_fn())	 catch ()
			)
		)
		else (joeSpeedTrajEdit_Globals.ToggleDisplayAll())
	)
	
	on btn_DisplayAll rightClick do
	(
		for i = 1 to joeSpeedTrajEdit_DTrajs.count do (joeSpeedTrajEdit_Globals.ToggleDisplay  i)
	)
	
	
	on btn_New_Pivot pressed do (joeSpeedTrajEdit_Globals.NewTraj true;joeSpeed_refreshDT_byTime_new_fn())
	
	
	
	)
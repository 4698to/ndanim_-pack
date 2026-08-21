-- 名称：轨迹插件终极版重置版
-- 作者:东见云
-- 版本：v1.0
-- 3dsmax：2014+
-- 功能：动画轨迹
-- 联系方式：yun7928903@163.com
/*
-- coding: utf-8 
-- @Date    : 2025-04-01 16:38:22
-- @Author  : 4698to (738746223@qq.com)
-- @Link    : sundaybox.cc
-- @Version : 
*/

---尝试关闭回调
try(unRegisterTimeCallback joeSpeed_refreshDT_byTime_new_fn)catch()
try unregisterRedrawViewsCallback joeMotionSpeedPathCallBackFn_exc catch()
----尝试关闭界面
try DestroyDialog  joeSpeedTrajEdit_rollout catch ()
	
function joeSpeedTrajEdit_UpdateRollout = () -- Proto放报错初始化	

---定义相对用的相机	
global joeSpeedTrajEdit_DTrajs_camRef = false

---定义所有轨迹	
global joeSpeedTrajEdit_DTrajs  
if joeSpeedTrajEdit_DTrajs == undefined do joeSpeedTrajEdit_DTrajs = #()
-----轨迹点标显隐用
global joeSpeedTrajEdit_DTrajs_dot 
if joeSpeedTrajEdit_DTrajs_dot == undefined do joeSpeedTrajEdit_DTrajs_dot = #()
-----轨迹显隐用
global joeSpeedTrajEdit_DTrajs_vis
if joeSpeedTrajEdit_DTrajs_vis == undefined do joeSpeedTrajEdit_DTrajs_vis = #()
-----实时开关用
global joeSpeedTrajEdit_DTrajs_timeLong
if joeSpeedTrajEdit_DTrajs_timeLong == undefined do joeSpeedTrajEdit_DTrajs_timeLong = #()

global joeSpeedTrajEdit_DTrajs_timetype 
if joeSpeedTrajEdit_DTrajs_timetype == undefined do joeSpeedTrajEdit_DTrajs_timetype = #()


global joeSpeedTrajEdit_DTrajs_speedtype 
if joeSpeedTrajEdit_DTrajs_speedtype == undefined do joeSpeedTrajEdit_DTrajs_speedtype = #()

-----播放开关用
global joeSpeedTrajEdit_DTrajs_play
if joeSpeedTrajEdit_DTrajs_play == undefined do joeSpeedTrajEdit_DTrajs_play = #()


-----关键帧显隐用
global joeSpeedTrajEdit_DTrajs_keyVis
if joeSpeedTrajEdit_DTrajs_keyVis == undefined do joeSpeedTrajEdit_DTrajs_keyVis = #()


-----开始颜色用
global joeSpeedTrajEdit_DTrajs_colStart
if joeSpeedTrajEdit_DTrajs_colStart == undefined do joeSpeedTrajEdit_DTrajs_colStart = #()


-----结束颜色用
global joeSpeedTrajEdit_DTrajs_colEnd
if joeSpeedTrajEdit_DTrajs_colEnd == undefined do joeSpeedTrajEdit_DTrajs_colEnd = #()

-----渐变颜色开关用
global joeSpeedTrajEdit_DTrajs_isGradual
if joeSpeedTrajEdit_DTrajs_isGradual == undefined do joeSpeedTrajEdit_DTrajs_isGradual = #()
 
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

----获取选择的帧
selKeyArray = #()  ---初始化不可少
fn getAnimProp_yunEdit obj =
(   
try 
(
	local keytest  = #()
	if classof obj != SubAnim then
	( selKeyArray = #() )
	if classof obj ==Biped_Object  then
	(	
		if (obj.controller != undefined) do
		(
			cs_Bone =  (for o in objects where classOf o == Biped_Object  OR (try(classOf o.transform.controller == BipSlave_Control)catch(false)) collect o)	
			if obj.name==(cs_Bone[1].controller.rootName) then 				
			(
				for k in obj.controller[1].keys do	(appendIfUnique  selKeyArray k.time)
				for k in obj.controller[2].keys do	(appendIfUnique  selKeyArray k.time)
				for k in obj.controller[3].keys do	(appendIfUnique  selKeyArray k.time)			
			)
			else if (keyTest = obj.controller.keys) != undefined and keyTest.count > 0 do
			(
				keytest = obj.controller.keys
				for k in 1 to keyTest.count  do ( appendIfUnique  selKeyArray keytest[k].time )
			)
		)
	)
	---非bip物体
	else 
	(
		--迭代至最底层
		if obj.numSubs > 0 then ( for i = 1 to obj.numSubs do ( getAnimProp_yunEdit obj[i] ) )
		---最底层
		else
		(
			if (obj.controller != undefined) do
			(	
				keytest = obj.keys	
				if keyTest!= undefined and keyTest.count > 0 do
				(	for k in 1 to keyTest.count  do ( appendIfUnique  selKeyArray keytest[k].time )) 
			)
		)
	)	
	
		sort selKeyArray
		makeUniqueArray  selKeyArray
)
catch()

	return selKeyArray	
)


----场景内物体是否存在检查函数
function joeSpeedTrajEdit_CheckExsitError  = 
(
	for i in  joeSpeedTrajEdit_DTrajs do 
	(	
		if (isvalidnode i)==false do 
		(
			joeSpeedTrajEdit_DTrajs = #()
			joeSpeedTrajEdit_DTrajs_dot = #()
			joeSpeedTrajEdit_DTrajs_vis = #()
			joeSpeedTrajEdit_DTrajs_timeLong = #()
			joeSpeedTrajEdit_DTrajs_timetype = #()
			joeSpeedTrajEdit_DTrajs_speedtype = #()

			joeSpeedTrajEdit_DTrajs_play = #()
			joeSpeedTrajEdit_DTrajs_keyVis = #()
			joeSpeedTrajEdit_DTrajs_colStart = #()
			joeSpeedTrajEdit_DTrajs_colEnd = #()
			joeSpeedTrajEdit_DTrajs_isGradual = #()

		)
	)
)
joeSpeedTrajEdit_CheckExsitError()

---如果有不相等就都归零
if joeSpeedTrajEdit_DTrajs.count!=joeSpeedTrajEdit_DTrajs_dot.count or
joeSpeedTrajEdit_DTrajs_dot.count!=joeSpeedTrajEdit_DTrajs_vis.count or 
joeSpeedTrajEdit_DTrajs_vis.count!=joeSpeedTrajEdit_DTrajs_timeLong.count or 
joeSpeedTrajEdit_DTrajs_timeLong.count!=joeSpeedTrajEdit_DTrajs_play.count or 
joeSpeedTrajEdit_DTrajs_play.count!=joeSpeedTrajEdit_DTrajs_keyVis.count or 
joeSpeedTrajEdit_DTrajs_keyVis.count!=joeSpeedTrajEdit_DTrajs_colStart.count or 
joeSpeedTrajEdit_DTrajs_colStart.count!=joeSpeedTrajEdit_DTrajs_colEnd.count or 
joeSpeedTrajEdit_DTrajs_colEnd.count!=joeSpeedTrajEdit_DTrajs_isGradual.count do

(
	joeSpeedTrajEdit_DTrajs = #()
	joeSpeedTrajEdit_DTrajs_dot = #()
	joeSpeedTrajEdit_DTrajs_vis = #()
	joeSpeedTrajEdit_DTrajs_timeLong = #()
	joeSpeedTrajEdit_DTrajs_timetype = #()
	joeSpeedTrajEdit_DTrajs_speedtype = #()


	joeSpeedTrajEdit_DTrajs_play =  #()
	joeSpeedTrajEdit_DTrajs_keyVis = #()
	joeSpeedTrajEdit_DTrajs_colStart = #()
	joeSpeedTrajEdit_DTrajs_colEnd = #()
	joeSpeedTrajEdit_DTrajs_isGradual = #()

)
animationRange.start.frame
------实时改变函数
Fn joeSpeed_refreshDT_byTime_new_fn  = 
(	
	if joeSpeedTrajEdit_DTrajs_timeLong.count > 0 then
	(
		for i = joeSpeedTrajEdit_DTrajs_timeLong.count to 1 by -1 do
		(	
			if joeSpeedTrajEdit_DTrajs_timeLong[i] do
			(
				if joeSpeedTrajEdit_DTrajs_timetype[i] == 0 do 
				( 
					execute ("joeSpeedTrajEdit_Rollout.spn_Start"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame - joeSpeedTrajEdit_Rollout.time_FB"+ (i as string)+".value")
					execute ("joeSpeedTrajEdit_Rollout.spn_End"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame + joeSpeedTrajEdit_Rollout.time_FB"+ (i as string)+".value")	
				)

				if joeSpeedTrajEdit_DTrajs_timetype[i] == 1 do 
				(
					execute ("joeSpeedTrajEdit_Rollout.spn_Start"+ (i as string)+".value = animationRange.start.frame")
					execute ("joeSpeedTrajEdit_Rollout.spn_End"+ (i as string)+".value= animationRange.end.frame")	

				)
			)
		)
	)
			
)



-----点标性状控制
KeyP_shape = #("hollowBox","plusSign","asterisk","xMarker","bigBox","circle","triangle","diamond","smallHollowBox","smallCircle","smallTriangle")
global dotShape = "smallDiamond"
---实例变量
global joeSpeedTrajEdit_Globals	
-- 图标位置
global pathIcons = ((getDir #scripts) + "\\BulletScripts\\Res")

-----封装处
(
----实例结构
struct joeSpeedTrajEdit_Globals_Struct
(
	bmp_Background = openbitmap (pathIcons + "\DTools\DTrajEdit\BackGround.bmp"),
	bmp_Title = openbitmap (pathIcons + "\DTools\DTrajEdit\Title.bmp"),
	bmp_New = openbitmap (pathIcons + "\DTools\DTrajEdit\New_Poly.bmp"),
	bmp_New_Pivot = openbitmap (pathIcons + "\DTools\DTrajEdit\New_Pivot.bmp"),
	bmp_About = openbitmap (pathIcons + "\DTools\DTrajEdit\About.bmp"),
	bmp_Exit = openbitmap (pathIcons + "\DTools\DTrajEdit\Exit.bmp"),
	bmp_Display = openbitmap (pathIcons + "\DTools\DTrajEdit\Display.bmp"),
	bmp_DisplayAll = openbitmap (pathIcons + "\DTools\DTrajEdit\DisplayAll.bmp"),
	bmp_Display_ON = openbitmap (pathIcons + "\DTools\DTrajEdit\Display_ON.bmp"),
	bmp_DisplayAll_ON = openbitmap (pathIcons + "\DTools\DTrajEdit\DisplayAll_ON.bmp"),
	bmp_Delete = openbitmap (pathIcons + "\DTools\DTrajEdit\Delete.bmp"),
	bmp_Range= openbitmap (pathIcons + "\DTools\DTrajEdit\Range.bmp"),
	bmp_Dot = openbitmap (pathIcons + "\DTools\DTrajEdit\Dot.bmp"),
	bmp_Dot_ON = openbitmap (pathIcons + "\DTools\DTrajEdit\Dot_ON.bmp"),
	bmp_Move = openbitmap (pathIcons + "\DTools\DTrajEdit\Move.bmp"),
	
	WindowToCursorOffset = [0,0],
	
	function MoveWindow _rlWindow =
	(
		if this.WindowToCursorOffset != [0,0] then
		(
			SetDialogPos _rlWindow (mouse.pos + this.WindowToCursorOffset)
		)
	),

	function IsReadyToMove _rlWindow _pPos =
	(
		this.WindowToCursorOffset = ((GetDialogPos _rlWindow) - mouse.pos )
		setSysCur #move
	),

	function LetGoTheWindow =
	(
		this.WindowToCursorOffset = [0,0]
	),
	
	
	
	---切大小界面 图标
	bDisplayAll = false,
	function ToggleDisplayAll =
	(
		this.bDisplayAll = not(this.bDisplayAll)		
		joeSpeedTrajEdit_Globals.UpdateBitmaps()
	),
	---切大小界面  + 刷新图标
	function UpdateBitmaps =
	(
		--bDisplayAll = not(bDisplayAll)
		try
		(
			if not(this.bDisplayAll) then
			(
				execute ("joeSpeedTrajEdit_rollout.btn_DisplayAll.images = #(joeSpeedTrajEdit_Globals.bmp_DisplayAll, undefined, 1, 1, 1, 1, 1)")
				joeSpeedTrajEdit_rollout.width = 254
				if joeSpeedTrajEdit_DTrajs.count > 0 do
				(joeSpeedTrajEdit_rollout.height = 43+34*(joeSpeedTrajEdit_DTrajs.count))
			--joeSpeedTrajEdit_rollout.height = 40
			)
			else
			(
				execute ("joeSpeedTrajEdit_rollout.btn_DisplayAll.images = #(joeSpeedTrajEdit_Globals.bmp_DisplayAll_ON, undefined, 1, 1, 1, 1, 1)")
				joeSpeedTrajEdit_rollout.width = 37+40
				joeSpeedTrajEdit_rollout.height = 40
			)
		)
		catch()
	),
	----新建轨迹
	function NewTraj _bPivot =
	(			
		local nParent	
		----分类型用的暂时无用
		if _bPivot do
		(
			---检查是否选择了一个物体
			if selection.count == 1 then   
			(
				nParent = selection[1]
			)				
		)			
		setWaitCursor()				
		
		
		-----真正创建轨迹
		if IsValidNode nParent then
		(
			
			if (findItem joeSpeedTrajEdit_DTrajs nParent)== 0 do
			(
			appendIfUnique joeSpeedTrajEdit_DTrajs nParent
			append joeSpeedTrajEdit_DTrajs_dot true
			append joeSpeedTrajEdit_DTrajs_vis true
			append joeSpeedTrajEdit_DTrajs_timeLong true
			append joeSpeedTrajEdit_DTrajs_timetype 0 -- 当前帧两边范围 
			append joeSpeedTrajEdit_DTrajs_speedtype false 

			append joeSpeedTrajEdit_DTrajs_play false
			append joeSpeedTrajEdit_DTrajs_keyVis true				
			append joeSpeedTrajEdit_DTrajs_colStart red
			append joeSpeedTrajEdit_DTrajs_colEnd green				
			append joeSpeedTrajEdit_DTrajs_isGradual false
			)
			
		)
		else
		(
			messagebox "来选一个嘛...  ." title:"joeSpeedTrajEdit"				
		)
		----界面重生
		joeSpeedTrajEdit_UpdateRollout()
	),
	fn NewTarjTimeLine = 
	(
		local nParent = undefined
		
		---检查是否选择了一个物体
		if selection.count > 0 do 
		(
			nParent = selection[1]
		)			
					
		-----真正创建轨迹
		if IsValidNode nParent then
		(
			
			if (findItem joeSpeedTrajEdit_DTrajs nParent)== 0 do
			(
				appendIfUnique joeSpeedTrajEdit_DTrajs nParent
				append joeSpeedTrajEdit_DTrajs_dot true
				append joeSpeedTrajEdit_DTrajs_vis true
				append joeSpeedTrajEdit_DTrajs_timeLong true
				append joeSpeedTrajEdit_DTrajs_timetype 1 -- 时间轴范围 
				append joeSpeedTrajEdit_DTrajs_speedtype false 

				append joeSpeedTrajEdit_DTrajs_play false
				append joeSpeedTrajEdit_DTrajs_keyVis true				
				append joeSpeedTrajEdit_DTrajs_colStart red
				append joeSpeedTrajEdit_DTrajs_colEnd green				
				append joeSpeedTrajEdit_DTrajs_isGradual false
			)
			
		)
		else
		(
			messagebox "来选一个嘛...  ." title:"joeSpeedTrajEdit"				
		)
		----界面重生
		joeSpeedTrajEdit_UpdateRollout()
	),
	---删除轨迹
	function DeleteTraj _i =
	(
		if IsValidNode joeSpeedTrajEdit_DTrajs[_i] do 
		(	
			deleteitem joeSpeedTrajEdit_DTrajs _i
			deleteItem joeSpeedTrajEdit_DTrajs_dot  _i
			deleteItem joeSpeedTrajEdit_DTrajs_vis  _i
			deleteItem joeSpeedTrajEdit_DTrajs_timeLong  _i 
			
			try(deleteItem joeSpeedTrajEdit_DTrajs_timetype _i)catch()
			deleteItem joeSpeedTrajEdit_DTrajs_speedtype _i 

			deleteItem joeSpeedTrajEdit_DTrajs_play  _i 
			deleteItem joeSpeedTrajEdit_DTrajs_keyVis  _i 
			deleteItem joeSpeedTrajEdit_DTrajs_colStart  _i 
			deleteItem joeSpeedTrajEdit_DTrajs_colEnd  _i 
			deleteItem joeSpeedTrajEdit_DTrajs_isGradual  _i 
		)		
		joeSpeedTrajEdit_UpdateRollout()
	),
	---切换点标显隐
	function ToggleDot  _i =
	(
		try
		(					
			if (not joeSpeedTrajEdit_DTrajs_dot[_i]) then
			(
				execute ("joeSpeedTrajEdit_Rollout.btn_Dot" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Dot, undefined, 1, 1, 1, 1, 1)")
				joeSpeedTrajEdit_DTrajs_dot[_i] = true
			)
			else
			(
				execute ("joeSpeedTrajEdit_Rollout.btn_Dot" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Dot_ON, undefined, 1, 1, 1, 1, 1)")
				joeSpeedTrajEdit_DTrajs_dot[_i] = false
			)
		)			
		catch()
	),
	---切换轨迹显隐
	function ToggleDisplay _i=
	(
		try
		(					
			if (not joeSpeedTrajEdit_DTrajs_vis[_i]) then
			(
				execute ("joeSpeedTrajEdit_Rollout.btn_Display" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Display, undefined, 1, 1, 1, 1, 1)")
				joeSpeedTrajEdit_DTrajs_vis[_i] = true
			)
			else
			(
				execute ("joeSpeedTrajEdit_Rollout.btn_Display" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Display_ON, undefined, 1, 1, 1, 1, 1)")
				joeSpeedTrajEdit_DTrajs_vis[_i] = false
			)
		)			
		catch()
	),
	---切换关键帧显隐
	function ToggleKeyVis  _i =
	(
		try
		(					
			if (not joeSpeedTrajEdit_DTrajs_keyVis[_i]) then
			(
				execute ("joeSpeedTrajEdit_Rollout.btn_Move" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Move, undefined, 1, 1, 1, 1, 1)")
				joeSpeedTrajEdit_DTrajs_keyVis[_i] = true
			)
			else
			(
				execute ("joeSpeedTrajEdit_Rollout.btn_Move" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Move, undefined, 4, 1, 1, 1, 1)")
				joeSpeedTrajEdit_DTrajs_keyVis[_i] = false
			)
		)			
		catch()
	),
	fn ToggleSpeedType _i = 
	(
		try
		(					
			if joeSpeedTrajEdit_DTrajs_speedtype[_i] != undefined do 
			(
				if joeSpeedTrajEdit_DTrajs_speedtype[_i] then 
				(
					execute ("joeSpeedTrajEdit_Rollout.btn_Move" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Move, undefined, 1, 1, 1, 1, 1)")

				)else(
					execute ("joeSpeedTrajEdit_Rollout.btn_Move" + _i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Move, undefined, 4, 1, 1, 1, 1)")
				)
				joeSpeedTrajEdit_DTrajs_speedtype[_i] = not joeSpeedTrajEdit_DTrajs_speedtype[_i]

			)
		)			
		catch()
	)	
)


------生成轨迹函数  物体 显示 开点 开始色 结束色 开始帧数 结束帧数 点形状 播放是否显示 关键帧开关 是否颜色渐变
------计算 xyz 平面速度
fn joeMotionSpeedPathCallBackFn_xyz  obj vis isdot col_Start col_End tStart tEnd dotShape isPlay keyVis isGradual =
(
	--是否播放
	playCheck = true  --默认画曲线
	if isPlay and isAnimPlaying() then (playCheck = false )  ---隐藏被勾选切在播放就不画了
	
	--if vis and  not isAnimPlaying()  do
	---画轨迹
	if vis and playCheck do
	(	
	
		---获取数据 
			
		if  currentTime.frame  > tStart and currentTime.frame < tEnd then
		(
			tNow = currentTime.frame
		)			
		else (tNow = tStart+1 )
		
		-- 帧率
		timeframerate = framerate as float

		framesA = #()
		arrA = #()  --帧数  的位置
		framesA_speed = #()

		start_pos = [0,0,0]
		p1 = [0,0,0]

		at time (tStart-1) (start_pos = obj.transform.pos)


		--当前帧的前面
		for i = tStart to tNow do 
		(
			at time i (
				p1 = obj.transform.pos
			)	
			dist = distance [p1.x,p1.y,p1.z] [start_pos.x,start_pos.y,start_pos.z]

			append framesA_speed ([p1.x,p1.y,dist*timeframerate])
			append arrA p1 
			
			start_pos = p1 
			append framesA i

		)

		framesB = #()
		arrB = #()
		framesB_speed = #()
		--start_pos = framesA_speed[(framesA_speed.count)]

		at time (tNow-1) (start_pos = obj.transform.pos)
		--当前帧的后面
		for i = tNow to tEnd do 
		(
			at time i (
				p1 = obj.transform.pos
			)	
				--dist = normalize ([start_pos.x,start_pos.y,0] - [p1.x,p1.y,0])
			dist = distance [p1.x,p1.y,p1.z] [start_pos.x,start_pos.y,start_pos.z]

			append framesB_speed ([p1.x,p1.y,dist*timeframerate])

			append arrB p1 
			
			start_pos = p1 

			append framesB i
		)
		--当前位置和速度线的连线
		speed_current = #()
		speed_current[1] = framesB_speed[1]
		speed_current[2] = arrB[1]
		
		speed_current_color = #()
		speed_current_color[1] = 
		----------------------------------------------------
		

		arrColorA = #()   --颜色
		arrColorA_reverse = #()
		
		--渐变颜色
		/* if isGradual then		
		(
			rd = col_Start.red/framesA.count  
			gd = col_Start.green /framesA.count
			bd = col_Start.blue /framesA.count
			ad = 255.0/framesA.count
			
			for vT = 1.0 to framesA.count do
			(
				col = (color (col_Start.red - rd*vT ) (col_Start.green - gd*vT ) (col_Start.blue - bd*vT ) )				
				col.alpha = (col_Start.alpha - ad*vT )
				col.alpha = 255.0
				append arrColorA  col			
			)	
			arrColorA_reverse = for i = arrColorA.count to 1 by -1 collect arrColorA[i]
		)
		else(
		
		) */
		for vT in framesA do (append arrColorA_reverse col_Start)
		
			
		speed_current_color = #()
		speed_current_color[1] = arrColorA_reverse[1]
		speed_current_color[2] = arrColorA_reverse[arrColorA_reverse.count]


		
		----------------------------------------------------
		 
		arrB = #()
		arrColorB = #()
	
		
		
		
		--渐变
		/* if isGradual then
		(
			rd = col_End.red/framesB.count  
			gd = col_End.green /framesB.count
			bd = col_End.blue /framesB.count
			
			for vT = 1 to framesB.count do 
			(append arrColorB  (color (col_End.red - rd*vT ) (col_End.green - gd*vT ) (col_End.blue - bd*vT ))	)
		)
		else(
		
		) */
		for vT in framesB do (	append arrColorB col_End )	
		
		
		-- reset
		gw.setTransform(Matrix3 1)	
		
		marker_shape = dotShape as name 

		
		--生成前半段
		for i = 1 to framesA_speed.count do
		(			
			framesA_speed[i] = gw.wTransPoint framesA_speed[i] 
			
			gw.wMarker framesA_speed[i] marker_shape color:arrColorA_reverse[i]
		)

		speed_current[1] = gw.wTransPoint speed_current[1]
		speed_current[2] = gw.wTransPoint speed_current[2]
		gw.wtext speed_current[1] (framesB_speed[1].z as string) color:yellow

		
		gw.wPolyline speed_current false rgb:speed_current_color	

				

		gw.wPolyline framesA_speed false rgb:arrColorA_reverse	
		
		----生成后半段
		for i = 1 to framesB_speed.count do
		(
			framesB_speed[i] = gw.wTransPoint framesB_speed[i] 
			
			gw.wMarker framesB_speed[i] marker_shape color:arrColorB[i] 
		)
		gw.wPolyline framesB_speed false  rgb:arrColorB
		
		
		--at time (currentTime) (posRescue= obj.transform.pos)
		--gw.wMarker posRescue #smallDiamond color:col_End

		
		-- Update the viewports	 
		gw.enlargeUpdateRect #whole 
		gw.updateScreen()
	)
)

------生成轨迹函数  物体 显示 开点 开始色 结束色 开始帧数 结束帧数 点形状 播放是否显示 关键帧开关 是否颜色渐变
------只计算 xy 平面速度
fn joeMotionSpeedPathCallBackFn  obj vis isdot col_Start  col_End tStart tEnd dotShape isPlay keyVis isGradual =
(
	--是否播放
	playCheck = true  --默认画曲线
	if isPlay and isAnimPlaying() then (playCheck = false )  ---隐藏被勾选切在播放就不画了
	
	--if vis and  not isAnimPlaying()  do
	---画轨迹
	if vis and playCheck do
	--if vis do
	(	
	
		---获取数据 
			
		if  currentTime.frame  > tStart and currentTime.frame < tEnd then
		(
			tNow = currentTime.frame
		)			
		else (tNow = tStart+1 )
		
		-- 帧率
		timeframerate = framerate as float

		framesA = #()
		arrA = #()  --帧数  的位置
		framesA_speed = #()

		start_pos = [0,0,0]
		p1 = [0,0,0]

		at time (tStart-1) (start_pos = obj.transform.pos)


		--当前帧的前面
		for i = tStart to tNow do 
		(
			at time i (
				p1 = obj.transform.pos
			)	
			dist = distance [p1.x,p1.y,0] [start_pos.x,start_pos.y,0]

			append framesA_speed ([p1.x,p1.y,dist*timeframerate])
			append arrA p1 
			
			start_pos = p1 
			append framesA i

		)

		framesB = #()
		arrB = #()
		framesB_speed = #()
		--start_pos = framesA_speed[(framesA_speed.count)]

		at time (tNow-1) (start_pos = obj.transform.pos)
		--当前帧的后面
		for i = tNow to tEnd do 
		(
			at time i (
				p1 = obj.transform.pos
			)	
				--dist = normalize ([start_pos.x,start_pos.y,0] - [p1.x,p1.y,0])
			dist = distance [p1.x,p1.y,0] [start_pos.x,start_pos.y,0]

			append framesB_speed ([p1.x,p1.y,dist*timeframerate])

			append arrB p1 
			
			start_pos = p1 

			append framesB i
		)
		--当前位置和速度线的连线
		speed_current = #()
		speed_current[1] = framesB_speed[1]
		speed_current[2] = arrB[1]
		
		speed_current_color = #()
		speed_current_color[1] = 
		----------------------------------------------------
		

		arrColorA = #()   --颜色
		arrColorA_reverse = #()
		
		--渐变颜色
		/* if isGradual then		
		(
			rd = col_Start.red/framesA.count  
			gd = col_Start.green /framesA.count
			bd = col_Start.blue /framesA.count
			ad = 255.0/framesA.count
			
			for vT = 1.0 to framesA.count do
			(
				col = (color (col_Start.red - rd*vT ) (col_Start.green - gd*vT ) (col_Start.blue - bd*vT ) )				
				col.alpha = (col_Start.alpha - ad*vT )
				col.alpha = 255.0
				append arrColorA  col			
			)	
			arrColorA_reverse = for i = arrColorA.count to 1 by -1 collect arrColorA[i]
		)
		else(
			
		) */
		for vT in framesA do (append arrColorA_reverse col_Start)
			
		speed_current_color = #()
		speed_current_color[1] = arrColorA_reverse[1]
		speed_current_color[2] = arrColorA_reverse[arrColorA_reverse.count]


		
		----------------------------------------------------
		 
		arrB = #()
		arrColorB = #()
	
		
		
		
		--渐变
		/* if isGradual then
		(
			rd = col_End.red/framesB.count  
			gd = col_End.green /framesB.count
			bd = col_End.blue /framesB.count
			
			for vT = 1 to framesB.count do 
			(append arrColorB  (color (col_End.red - rd*vT ) (col_End.green - gd*vT ) (col_End.blue - bd*vT ))	)
		)
		else(
		

		) */
		for vT in framesB do (	append arrColorB col_End )	
		-- reset
		gw.setTransform(Matrix3 1)	
		
		marker_shape = dotShape as name 

		
		--生成前半段
		for i = 1 to framesA_speed.count do
		(			
			framesA_speed[i] = gw.wTransPoint framesA_speed[i] 
			
			gw.wMarker framesA_speed[i] marker_shape color:arrColorA_reverse[i]
		)

		speed_current[1] = gw.wTransPoint speed_current[1]
		speed_current[2] = gw.wTransPoint speed_current[2]
		gw.wtext speed_current[1] (framesB_speed[1].z as string) color:yellow

		
		gw.wPolyline speed_current false rgb:speed_current_color	

				

		gw.wPolyline framesA_speed false rgb:arrColorA_reverse	
		
		----生成后半段
		for i = 1 to framesB_speed.count do
		(
			framesB_speed[i] = gw.wTransPoint framesB_speed[i] 
			
			gw.wMarker framesB_speed[i] marker_shape color:arrColorB[i] 
		)
		gw.wPolyline framesB_speed false  rgb:arrColorB
		
		
		--at time (currentTime) (posRescue= obj.transform.pos)
		--gw.wMarker posRescue #smallDiamond color:col_End

		
		-- Update the viewports	 
		gw.enlargeUpdateRect #whole 
		gw.updateScreen()
	)
)
function joeMotionSpeedPathCallBackFn_exc =
(
	----放报错判断
	if joeSpeedTrajEdit_DTrajs.count > 0 do
	(
		----全局变量整理
		joeSpeedTrajEdit_CheckExsitError()
		

		-----检查结束开启轨迹   i = 1
		for i = joeSpeedTrajEdit_DTrajs.count to 1 by -1 do
		(			
			col_start = Execute ("joeSpeedTrajedit_rollout.col_Dot" + (i as string) + ".color")
			col_end = Execute ("joeSpeedTrajedit_rollout.col_Spline" + (i as string) + ".color")
			
			tStart = Execute ("joeSpeedTrajedit_rollout.spn_Start" + (i as string) + ".value")
			tEnd = Execute ("joeSpeedTrajedit_rollout.spn_End" + (i as string) + ".value")
			if joeSpeedTrajEdit_DTrajs_dot.count > 0 do ( isdot = joeSpeedTrajEdit_DTrajs_dot[i] )			
			if joeSpeedTrajEdit_DTrajs_vis.count > 0 do ( vis = joeSpeedTrajEdit_DTrajs_vis[i] )
			if joeSpeedTrajEdit_DTrajs_Play.count > 0 do ( isPlay = joeSpeedTrajEdit_DTrajs_Play[i] )
			if joeSpeedTrajEdit_DTrajs_keyVis.count> 0 do ( keyVis = joeSpeedTrajEdit_DTrajs_keyVis[i] )			
			if joeSpeedTrajEdit_DTrajs_isGradual.count> 0 do ( isGradual = joeSpeedTrajEdit_DTrajs_isGradual[i] )
			

			if joeSpeedTrajEdit_DTrajs[i] != undefined and
			col_start != undefined	and
			col_end != undefined and 
			tStart != undefined and 
			tEnd != undefined and
			vis != undefined and
			dotShape != undefined and
			isPlay != undefined and
			keyVis != undefined and
			isGradual != undefined and
			isdot != undefined do			
			(	
				----创建轨迹的 核心代码
				if joeSpeedTrajEdit_DTrajs_speedtype[i] then 
				(
					try (
						(joeMotionSpeedPathCallBackFn_xyz joeSpeedTrajEdit_DTrajs[i] vis isdot col_start col_end tStart tEnd dotShape isPlay keyVis isGradual)
					)catch()
				)
				else 
				(
					try (
						(joeMotionSpeedPathCallBackFn joeSpeedTrajEdit_DTrajs[i] vis isdot col_start col_end tStart tEnd dotShape isPlay keyVis isGradual)
					)catch()
				)
			)
		)
	)
)
------生成轨迹函数结束e



------实时改变函数
Fn joeSpeed_refreshDT_byTime_new_fn  = 
(	
	if joeSpeedTrajEdit_DTrajs_timeLong.count > 0 then
	(
		for i = joeSpeedTrajEdit_DTrajs_timeLong.count to 1 by -1 do
		(	
			if joeSpeedTrajEdit_DTrajs_timeLong[i] do
			(
				if joeSpeedTrajEdit_DTrajs_timetype[i] == 0 do (
					execute ("joeSpeedTrajEdit_Rollout.spn_Start"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame - joeSpeedTrajEdit_Rollout.time_FB"+ (i as string)+".value")
					execute ("joeSpeedTrajEdit_Rollout.spn_End"+ (i as string)+".value=(currentTime as integer)/TicksPerFrame + joeSpeedTrajEdit_Rollout.time_FB"+ (i as string)+".value")	
				)
				if joeSpeedTrajEdit_DTrajs_timetype[i] == 1 do 
				(
					--execute ("joeSpeedTrajEdit_Rollout.spn_Start"+ (i as string)+".value = animationRange.start.frame")
					--execute ("joeSpeedTrajEdit_Rollout.spn_End"+ (i as string)+".value= animationRange.end.frame")	
				)
			)
		)
	)
			
)




---实例化
(joeSpeedTrajEdit_Globals = joeSpeedTrajEdit_Globals_Struct())

-----界面出生函数
global joeSpeedTrajEdit_Rollout
function joeSpeedTrajEdit_UpdateRollout =
(


	
	
	
	local szExecute = "
	rollout joeSpeedTrajEdit_rollout \"\" width:254 height:40
	(\n
	--bDisplayAll = false
	---开关按钮
	button btn_DisplayAll \"\" pos:[1,4] width:34 height:34 tooltip:\"1，左键大小如意\n2，右键开关轨迹显示\n3，shift+左键开关实时更新轨迹长度\n（关闭则按时间轴长度显示）\n4，ctrl+左键开关显示关键帧数\n5,alt+左键开关颜色渐变\"
	---logo图标
	bitmap bmp_Titlebmp pos:[35,1] width:255 height:40 bitmap:joeSpeedTrajEdit_Globals.bmp_Title
	---关于按钮
	button btn_About \"\" pos:[152,4] width:34 height:34 images:#(joeSpeedTrajEdit_Globals.bmp_About, undefined, 1, 1, 1, 1, 1) tooltip:\"左键关于信息，右键随机轨迹颜色\"

	
	---新建轨迹
	button btn_New \"\" pos:[186,4] width:34 height:17 images:#(joeSpeedTrajEdit_Globals.bmp_New, undefined, 1, 1, 1, 1, 1) tooltip:\"新建轨迹,时间轴范围\"
	button btn_New_Pivot \"\" pos:[186,21] width:34 height:17 images:#(joeSpeedTrajEdit_Globals.bmp_New_Pivot, undefined, 1, 1, 1, 1, 1) tooltip:\"新建轨迹,左键改变点标形状\"
	
	---退出按钮
	button btn_Exit \"\" pos:[220,4] width:34 height:34 images:#(joeSpeedTrajEdit_Globals.bmp_Exit, undefined, 1, 1, 1, 1, 1) tooltip:\"EXIT\"
	-- 窗口移动功能
	on joeSpeedTrajEdit_rollout mousemove pos do joeSpeedTrajEdit_Globals.MoveWindow joeSpeedTrajEdit_rollout
	on joeSpeedTrajEdit_rollout lbuttondown pos do joeSpeedTrajEdit_Globals.IsReadyToMove joeSpeedTrajEdit_rollout pos
	on joeSpeedTrajEdit_rollout lbuttonup pos do joeSpeedTrajEdit_Globals.LetGoTheWindow()	
	
	----改变点标形状功能
	on btn_New_Pivot rightClick do
	(
		if dotShape == \"smallDiamond\" do (dotShape = \"hollowBox\")
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
	on btn_New pressed do
	(
		--dotShape = \"smallDiamond\"
		joeSpeedTrajEdit_Globals.NewTarjTimeLine();joeSpeed_refreshDT_byTime_new_fn()

	)
	----打开界面是刷新图标
	on joeSpeedTrajEdit_rollout open do 
	(
		joeSpeedTrajEdit_Globals.UpdateBitmaps()
		try unregisterRedrawViewsCallback joeMotionSpeedPathCallBackFn_exc catch()
		registerRedrawViewsCallback joeMotionSpeedPathCallBackFn_exc

		try(unRegisterTimeCallback joeSpeed_refreshDT_byTime_new_fn)catch()		
		try (registerTimeCallback joeSpeed_refreshDT_byTime_new_fn) catch ()
		try (joeSpeed_refreshDT_byTime_new_fn())	 catch ()
		
	)
	--退出窗口功能
	on btn_Exit pressed do
	(
		try(unRegisterTimeCallback joeSpeed_refreshDT_byTime_new_fn)catch()
		try unregisterRedrawViewsCallback joeMotionSpeedPathCallBackFn_exc catch()
		joeSpeedTrajEdit_Globals.UpdateBitmaps()
		joeSpeedTrajEdit_Globals = undefined

		DestroyDialog joeSpeedTrajEdit_rollout
		gc()  ---内存管理	
		
	)
	on btn_Exit rightClick do
	(
		if joeSpeedTrajEdit_DTrajs_camRef  then 
		(	
			joeSpeedTrajEdit_DTrajs_camRef = false
			print \"画面路径关闭<――~\"
			joeSpeedTrajEdit_Rollout.btn_Exit.images = #(joeSpeedTrajEdit_Globals.bmp_About, undefined, 1, 1, 1, 1, 1)
			
		)
		else (
			joeSpeedTrajEdit_DTrajs_camRef = true
			cc = getActiveCamera()
			if cc!=undefined then
			(print cc.name +\"画面路径开启，相机――>~\")
			else (print	(\"画面路径开启，无相机――>~\"))	
			joeSpeedTrajEdit_Rollout.btn_Exit.images = #(joeSpeedTrajEdit_Globals.bmp_About, undefined, 2, 1, 1, 1, 1)	
		)		
		gc()  ---内存管理
		
	)
	
	
	---关于按钮功能
	on btn_About pressed do
	(
		messagebox \"DtraijEdit 2.07  速度曲线版 \nEricDLegare.com|sundaybox.cc\nProgramming:Eric D Legare | 东见云 | Joe\n2025-04-01 \nIcons：Simon Dubuc\n \"

	)
	on btn_About rightClick do
	(
		--print \"随机颜色\"
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
		for i=1 to joeSpeedTrajEdit_DTrajs_colEnd.count do
		(
				bufferColorA =  HSV_to_RGB [(random 0 255),(random 90 255),255]  as color
				bufferColorB =  HSV_to_RGB [(random 0 255),(random 90 255),255]  as color
				execute (\"joeSpeedTrajEdit_rollout.col_Dot\"+i as string+\".color = bufferColorA\")
				execute (\"joeSpeedTrajEdit_rollout.col_Spline\"+i as string+\".color = bufferColorB\")
				
				joeSpeedTrajEdit_DTrajs_colStart[i] = color 255 0 0
				joeSpeedTrajEdit_DTrajs_colEnd[i]   = color 0 255 0

				joeSpeedTrajEdit_DTrajs_colStart[i] = bufferColorA
				joeSpeedTrajEdit_DTrajs_colEnd[i] = bufferColorB
		)
		
		)catch()		
	)
	------切换界面大小
	on btn_DisplayAll pressed do
	(
		if keyboard.shiftPressed then
		(
		    i=1
			for i = 1 to 	joeSpeedTrajEdit_DTrajs_timeLong.count do 
			(
				joeSpeedTrajEdit_DTrajs_timeLong[i] = not joeSpeedTrajEdit_DTrajs_timeLong[i]
				execute (\"joeSpeedTrajEdit_rollout.time_FBONOff\"+(i as string)+\".state = joeSpeedTrajEdit_DTrajs_timeLong[i]\")
				if not joeSpeedTrajEdit_DTrajs_timeLong[i] then
				(execute (\"joeSpeedTrajEdit_rollout.btn_Range\"+(i as string)+\".pressed()\"))
				try (joeSpeed_refreshDT_byTime_new_fn())	 catch ()
			)
		
		)
		else if  keyboard.controlPressed then
		(
			for i = 1 to 	joeSpeedTrajEdit_DTrajs_timeLong.count do 
			(
				(execute (\"joeSpeedTrajEdit_rollout.btn_Move\"+(i as string)+\".pressed()\"))
				try (joeSpeed_refreshDT_byTime_new_fn())	 catch ()
			)
		)
		else if  keyboard.altPressed then
		(
			for i = 1 to joeSpeedTrajEdit_DTrajs_timeLong.count do 
			(
				
				execute (\"joeSpeedTrajEdit_rollout.isGradual\"+(i as string)+\".checked = not joeSpeedTrajEdit_rollout.isGradual\"+(i as string)+\".checked\")
				execute (\"joeSpeedTrajEdit_DTrajs_isGradual[\"+(i as string)+\"] = joeSpeedTrajEdit_rollout.isGradual\"+(i as string)+\".checked\")
				try (joeSpeed_refreshDT_byTime_new_fn())	 catch ()
			)
		)
		else (joeSpeedTrajEdit_Globals.ToggleDisplayAll())
	)
	
	on btn_DisplayAll rightClick do
	(
		for i = 1 to 	joeSpeedTrajEdit_DTrajs_vis.count do (joeSpeedTrajEdit_Globals.ToggleDisplay  i)
	)
	
	
	on btn_New_Pivot pressed do (joeSpeedTrajEdit_Globals.NewTraj true;joeSpeed_refreshDT_byTime_new_fn())
	
	
	
	"
	----加轨迹后新建的界面
	local vSpacing = 34

	if joeSpeedTrajEdit_DTrajs.count > 0 do
	(
		joeSpeedTrajEdit_CheckExsitError()
		for i = joeSpeedTrajEdit_DTrajs.count to 1 by -1 do
		(
			if IsValidNode joeSpeedTrajEdit_DTrajs[i] do   ----真实存在
			(
				
				---帧范位置控制
				local vStartPos = ([202,44+(vSpacing*(i-1))] as string) 
				local vEndPos = ([202,61+(vSpacing*(i-1))] as string)  	
			
				local vDotCol = ([89,61+(vSpacing*(i-1))] as string) 
					
				--修改！！！！！！
				local vtimeFB = ([52,61+(vSpacing*(i-1))] as string) 	
				local vtimeFBOnOff = ([2,61+(vSpacing*(i-1))] as string)
				---播放复选框位置
				local vplayFBOnOff = ([19,61+(vSpacing*(i-1))] as string)

				
				-----------------
				local vColGradual = ([36,61+(vSpacing*(i-1))] as string) 
				local vSplineCol = ([104,61+(vSpacing*(i-1))] as string) 
				local vMovePos = ([124,61+(vSpacing*(i-1))] as string) 
				local vDotPos = ([140,61+(vSpacing*(i-1))] as string) 
				local vDisplayPos = ([156,61+(vSpacing*(i-1))] as string) 
				local vDeletePos = ([172,61+(vSpacing*(i-1))] as string) 
				local vRangePos = ([188,61+(vSpacing*(i-1))] as string) 
											
						
					
				---标头
				local vNamePos = ([-3,44+(vSpacing*(i-1))] as string)				
				szExecute += ("edittext edt_Name" + (i as string) + " \"\" pos:" + vNamePos + " width:206 height:16 text:\"" + joeSpeedTrajEdit_DTrajs[i].name + "\"\n")						
				szExecute += ("on edt_Name" + (i as string) + " entered val do joeSpeedTrajEdit_DTrajs[" + (i as string) + "].name val\n")	
				szExecute += "\n"	
				---轨迹长度范围	
				szExecute += ("spinner spn_Start" + (i as string) + " \"\" pos:" + vStartPos + " width:52 height:16 type:#integer range:[-99999,99999," + (((animationRange.start as string) as integer) as string) +"]\n")
				szExecute += ("spinner spn_End" +   (i as string) + " \"\" pos:" + vEndPos +   " width:52 height:16 type:#integer range:[-99999,99999," + (((animationRange.end   as string) as integer) as string) +"]\n")
				szExecute += ("on spn_Start" + (i as string) + " changed val do 
				(
					if (spn_End" + (i as string) + ".value - 1) <= val then spn_End" + (i as string) + ".value = (val + 2)
					joeSpeedTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked = false
					joeSpeedTrajEdit_DTrajs_timeLong["+ (i as string)+"] = false
				)\n")
				
				szExecute += ("on spn_End" + (i as string) + " changed val do 
				(
					if (spn_Start" + (i as string) + ".value + 1) >= val then spn_Start" + (i as string) + ".value = (val - 2)
					joeSpeedTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked = false
					joeSpeedTrajEdit_DTrajs_timeLong["+ (i as string)+"] = false
				)\n")
				szExecute += "\n"
				
				----填充当前时间到帧范围
				szExecute += ("button btn_Range" + (i as string) + " \"\" pos:" + vRangePos + " width:16 height:16 images:#(joeSpeedTrajEdit_Globals.bmp_Range, undefined, 1, 1, 1, 1, 1)  tooltip:\"Reset the RANGE to the Active Time Segment\"\n")
				szExecute += ("on btn_Range" + (i as string) + " pressed do ( spn_Start" + (i as string)+".value=((animationRange.start as string) as integer);spn_End" + (i as string)+".value=((animationRange.end as string) as integer))\n")

				----删除轨迹
				szExecute += ("button btn_Delete" + (i as string) + " \"\" pos:" + vDeletePos + " width:16 height:16 images:#(joeSpeedTrajEdit_Globals.bmp_Delete, undefined, 1, 1, 1, 1, 1)  tooltip:\"DELETE Trajectory\" \n")
				szExecute += ("on btn_Delete" + (i as string) + " pressed do joeSpeedTrajEdit_Globals.DeleteTraj " + (i as string) + " \n")
				szExecute += "\n"

				----隐藏轨迹
				szExecute += ("button btn_Display" + (i as string) + " \"\" pos:" + vDisplayPos + " width:16 height:16  tooltip:\"隐藏轨迹\" \n")
				szExecute += ("on btn_Display" + (i as string) + " pressed do joeSpeedTrajEdit_Globals.ToggleDisplay " + (i as string)+"  \n")
				szExecute += "\n"
				
				----隐藏点标
				szExecute += ("button btn_Dot" + (i as string) + " \"\" pos:" + vDotPos + " width:16 height:16 enabled:false tooltip:\"隐藏点标记\" \n")
				szExecute += ("on btn_Dot" + (i as string) + " pressed do joeSpeedTrajEdit_Globals.ToggleDot " + (i as string)+"  \n")
				szExecute += "\n"
				
				----经过后颜色
				szExecute += ("colorpicker col_Spline" + (i as string) + " \"\" pos:" + vSplineCol + " width:20 height:16 color:" + "joeSpeedTrajEdit_DTrajs_colStart[" + (i as string)+"]" +" title:\"Trajectory\" \n")
				szExecute += ("on col_Spline" + (i as string) + " changed new_col do (joeSpeedTrajEdit_DTrajs_colStart[" + (i as string)+"] =  new_col)")				
				szExecute += "\n"
				
				----经过前颜色	
				szExecute += ("colorpicker col_Dot" + (i as string) + " \"\" pos:" + vDotCol + " width:20 height:16 color:" + "joeSpeedTrajEdit_DTrajs_colEnd[" + (i as string)+"]" + " title:\"Spacing Dots\" \n")
				szExecute += ("on col_Dot" + (i as string) + " changed new_col do (joeSpeedTrajEdit_DTrajs_colEnd[" + (i as string)+"] =  new_col)")	
				szExecute += "\n"
				
				----是否启用颜色渐变  i =1 
				szExecute += ("checkbox isGradual" + (i as string) + " \"\" pos:" + vColGradual + " width:16 height:16 checked:" + (joeSpeedTrajEdit_DTrajs_isGradual[i] as string)+ " enabled:false tooltip:\"开关颜色渐变\" \n")

				szExecute +=  ("on isGradual" + (i as string) + " changed theState do (				
				joeSpeedTrajEdit_DTrajs_isGradual["+ (i as string)+"] = theState
				if theState do 
				(	try (joeSpeed_refreshDT_byTime_new_fn())	 catch ())
				)\n")
				
				szExecute += "\n"
				
				-- 修改添加帧范围选项
				szExecute += ("spinner time_FB" + (i as string) + " \"\" pos:" + vtimeFB + " width:42 height:16 type:#integer range:[1,999,20]\n")					
				szExecute += ("on time_FB" + (i as string) + " changed val do (
				joeSpeedTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked = true
				joeSpeedTrajEdit_DTrajs_timeLong["+ (i as string)+"] = joeSpeedTrajEdit_Rollout.time_FBONOff"+ (i as string)+".checked 
				joeSpeed_refreshDT_byTime_new_fn()
				) \n")					
					
				szExecute += ("checkbox time_FBONOff" + (i as string) + " \"\" pos:" + vtimeFBOnOff + " width:16 height:16 checked:" + (joeSpeedTrajEdit_DTrajs_timeLong[i] as string)+ "  tooltip:\"开关实时刷新轨迹长度\" \n")
				szExecute += ("on time_FBONOff" + (i as string) + " changed theState do (				
				joeSpeedTrajEdit_DTrajs_timeLong["+ (i as string)+"] = theState
				if theState do 
				(	try (joeSpeed_refreshDT_byTime_new_fn())	 catch ())
				)\n")
				
				----是否在播放是隐藏  i =1 
				szExecute += ("checkbox play_FBONOff" + (i as string) + " \"\" pos:" + vplayFBOnOff + " width:16 height:16 checked:" + (joeSpeedTrajEdit_DTrajs_play[i] as string)+ "  tooltip:\"开关在播放时隐藏已保证帧率\" \n")
				szExecute += ("on play_FBONOff" + (i as string) + " changed theState do (				
				joeSpeedTrajEdit_DTrajs_play["+ (i as string)+"] = theState			
				)\n")
				szExecute += "\n"
				----------
				
				----修改为关键帧开关 (原先移动移动轨迹)
				szExecute += ("button btn_Move" + (i as string) + " \"\" pos:" + vMovePos + " width:16 height:16 images:#(joeSpeedTrajEdit_Globals.bmp_Move, undefined, 1, 1, 1, 1, 1)  tooltip:\"是否计算 Z 轴移动\" \n")
				
				--szExecute += ("on btn_Move" + (i as string) + " pressed do joeSpeedTrajEdit_Globals.ToggleKeyVis " + (i as string)+"  \n")
				szExecute += ("on btn_Move" + (i as string) + " pressed do joeSpeedTrajEdit_Globals.ToggleSpeedType " + (i as string)+"  \n")

				szExecute += "\n"
				
				-------根据当前帧实时刷新帧范围

				
				szExecute += "\n"
				
				
			)
		)
		
	)
	szExecute += ")"


	local vOriginalPos = if joeSpeedTrajEdit_rollout != undefined  then (GetDialogPos joeSpeedTrajEdit_rollout) else [0,0]
	
	
	----尝试关闭界面
	try DestroyDialog  joeSpeedTrajEdit_rollout catch ()
	
	
	Execute szExecute
	
	
	if vOriginalPos != [0,0] then
		(	createDialog  joeSpeedTrajEdit_rollout 205 (43 + (joeSpeedTrajEdit_DTrajs.count * vSpacing)) pos:vOriginalPos style:#(#style_border) bitmap:joeSpeedTrajEdit_Globals.bmp_Background bmpstyle:#bmp_tile fgcolor:green	)
	else
		(	createDialog  joeSpeedTrajEdit_rollout 205 (43 + (joeSpeedTrajEdit_DTrajs.count * vSpacing)) style:#(#style_border) bitmap:joeSpeedTrajEdit_Globals.bmp_Background bmpstyle:#bmp_tile fgcolor:green )
	
			
	----轨迹和点标处理
	if joeSpeedTrajEdit_DTrajs.count > 0 do
	(		
		for i = joeSpeedTrajEdit_DTrajs.count to 1 by -1 do
		(
			try
			(					
				if  joeSpeedTrajEdit_DTrajs_dot[i]  then
				(
					execute ("joeSpeedTrajEdit_Rollout.btn_Dot" + i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Dot, undefined, 1, 1, 1, 1, 1)")
					
				)
				else
				(
					execute ("joeSpeedTrajEdit_Rollout.btn_Dot" + i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Dot_ON, undefined, 1, 1, 1, 1, 1)")
				)
			)			
			catch()			
			try
			(					
				if joeSpeedTrajEdit_DTrajs_vis[i]  then
				(
					execute ("joeSpeedTrajEdit_Rollout.btn_Display" + i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Display, undefined, 1, 1, 1, 1, 1)")
				)
				else
				(
					execute ("joeSpeedTrajEdit_Rollout.btn_Display" + i as string + ".images = #(joeSpeedTrajEdit_Globals.bmp_Display_ON, undefined, 1, 1, 1, 1, 1)")
				)
			)			
			catch()
		)
	)
	----------图标处理结束-----
	

-- 	setDialogPos joeSpeedTrajEdit_rollout [247,225]
			
-- 	return szExecute
)

joeSpeedTrajEdit_UpdateRollout()

)

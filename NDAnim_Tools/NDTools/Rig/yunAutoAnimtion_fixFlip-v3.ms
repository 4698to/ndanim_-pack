-- 名称：自己动动画
-- 作者:东见云
-- 版本：v1.0
-- 3dsmax：2016
-- 功能：名称：自己动动画
-- 联系方式：yun7928903@163.com
/*
1.3 更新曲线控制方式

*/
--自定义摆动属性UI

-- 	    genClassID()

boneSineAniUsePos = attributes boneSineAniUsePos
attribid:#(0x764520ba, 0x2bbba0c9)
version:1
(
	local const = 0.25 * (1.0 - 0.25) -- THE MAGIC NUMBER        
	local CoordsPreset 			= #([0,0,0], [100,100,0])
	local inTangents_PresetA 	= #([0,0,0], [-25,-25,0])
	local outTangents_PresetA 	= #([25,25,0], [0,0,0])
	
	local inTangents_PresetB 	= #([0,-71.25,0], [-68.75,0,0])
	local outTangents_PresetB 	= #([0,71.25,0], [68.75,0,0])
	
	local inTangents_PresetC 	= #([-68.75,0.625,0], [0,-68.75,0])
	local outTangents_PresetC 	= #([68.75,-0.625,0], [0,68.75,0])
	
	local inTangents_PresetD 	= #([-59.375,0,0], [-59.375,0,0])
	local outTangents_PresetD 	= #([59.375,0,0], [59.375,0,0])

	 
				--曲线
	parameters pblock rollout:params
	( 	
		Coords			type:#point3Tab tabsizevariable:true   	animatable:false
		inTangents		type:#point3Tab tabsizevariable:true 	animatable:false
		outTangents		type:#point3Tab tabsizevariable:true 	animatable:false	
		
		beziers			type:#intTab  tabsizevariable:true 	animatable:false	
		corners 			type:#intTab  tabsizevariable:true 	animatable:false	
		--Curve			type:#float  default:0.0   invisibleintv:true	
		Curve			type:#float  default:0.0    
		 
		Input_Float		type:#float animatable:true 		
		Toolname 		type:#string 	default:"Ease Controller"  invisibleinTV:true
		
		wave_nodes type:#maxObjecttab tabSizeVariable:true tabsize:0 animatable:false
		percentValues_z type:#floatTab tabsizevariable:true animatable:false	
		percentValues_y type:#floatTab tabsizevariable:true animatable:false	
		percentValues_x type:#floatTab tabsizevariable:true animatable:false	
		curve_name type:#integer default:1 animatable:false UI:curve_type
	)
	

	rollout params "Float Controller" height:410 
	(
		local isloaded 		= false		
		local MouseDWN 		= false
		local MousePrevPOS 	= [0,0]
		local PrevSEL 		= [0,0]
		local CurrentPT 	= 0		

		--dotNetControl 	CustomCurve 	"System.Windows.Forms.PictureBox" 	width:180 height:180
		radiobuttons curve_type "类型" labels:#("X","Y","Z") columns:3 enabled:false offsets:#([30,-16], [15,-16],[5,-16]) 
		CurveControl cct_ "" x_range:[0,1] y_range:[0,1] numCurves:1 uiFlags:#(#drawgrid,#upperToolbar,#showReset,#xvalue,#constrainY,#autoScroll,#lowerToolbar) height:200 commandMode:#move_xy

		button Reset_BTN "R"  Height:20 width:20 align:#left offset:[-10,0] tooltip:"重置默认曲线" across:4
		button Copy_BTN 	"复制" 	width:35 align:#left enabled:false	offset:[-10,0]
		button Paste_BTN 	"粘贴" 	width:35 enabled:false	offset:[-2,0]
		button btn_set "更新" width:35 tooltip:"更新后参数生效"
		--button Presets_BTN 	"预设"	width:50 						offset:[7,0]	

		local select_root = undefined
		fn point2_to_point3 value2 = 
		(
			p = [0,0,0]
			p.x = value2.x 
			p.y = value2.y 
			p  
		)

		fn bool_to_int value2 = 
		(
			p = if value2 then(1)else(0) 
			p 
		)
		fn create_curve = 
		(
			try(
			cct_.curves[1].numPoints = 2
			cct_.curves[1].animatable = false
			
			cct_.curves[1].points[1].value = [0,0]
			cct_.curves[1].points[2].value = [1,1]

			--cct_.curves[1].points[1].bezier = false
			--cct_.curves[1].points[1].corner = true

			--cct_.curves[1].points[2].bezier = false
			--cct_.curves[1].points[2].corner = true

			
			cct_.curves[1].style= #insideFrame

			)catch()
		)
		fn load_curve =
		(
			is_ok = false 
			if isValidObj select_root do 
			(
			try(
				if select_root.Coords.count > 0 then
				(
					_Coords = select_root.Coords
					_inTangents = select_root.inTangents
					_outTangents = select_root.outTangents
					_bezier = select_root.beziers
					_corner = select_root.corners

					--cct_.curves[1].color =_curve[o].color
					cct_.curves[1].numPoints = _Coords.count
					cct_.curves[1].animatable = false
					
					for i =1 to _Coords.count do
					(
						cct_.curves[1].points[i].value = [(_Coords[i].x), (_Coords[i].y)] 

						cct_.curves[1].points[i].inTangent = [(_inTangents[i].x) , (_inTangents[i].y)]
						cct_.curves[1].points[i].outTangent = [(_outTangents[i].x) , (_outTangents[i].y)]

						is_bezier = if _bezier[i] == 1 then(true)else(false)
						is_corner = if _corner[i] == 1 then(true)else(false) 
						cct_.curves[1].points[i].bezier = is_bezier
						cct_.curves[1].points[i].corner = is_corner
					)
					is_ok = true 
				)else(
					create_curve()
				)
					cct_.scrollValues = [-16,-35]
					cct_.zoomValues =[160,113]

				)catch()
			)
			is_ok
		)
		fn save_curve = 
		(
			if isValidObj select_root do 
			(
				select_root.Coords = #()
				select_root.inTangents = #()
				select_root.outTangents = #()


				for i = 1 to cct_.curves[1].points.count do
				(
					p = point2_to_point3 (cct_.curves[1].points[i].value)
					append select_root.Coords p 

					intang = point2_to_point3 (cct_.curves[1].points[i].inTangent)
					append select_root.inTangents intang  

					outTang = point2_to_point3 ( cct_.curves[1].points[i].outTangent)
					append select_root.outTangents outTang

					append select_root.beziers (bool_to_int (cct_.curves[1].points[i].bezier))
					append select_root.corners (bool_to_int (cct_.curves[1].points[i].corner))

				)
			)
		)
		fn getCurveValue float_x = 
		(
			return (getValue cct_.curves[1] 0 float_x)
		)
		fn get_percentValue index = 
		(
			--不管什么曲线 都保存在 X
			
			if select_root.percentValues_x.count > 0 do (
				return select_root.percentValues_x[index] 
			)
			if select_root.percentValues_y.count > 0 do (
				return select_root.percentValues_y[index] 
			)
			if select_root.percentValues_z.count > 0 do (
				return select_root.percentValues_z[index] 
			)
			/* if curve_type.state == 3 do 
			(
				return select_root.percentValues_z[index] 
			)
			if curve_type.state == 2 do 
			(
				return select_root.percentValues_y[index] 
			)
			if curve_type.state == 1 do 
			(
				return select_root.percentValues_x[index] 
			) */
		)
		--将贝塞尔曲线参数设置到位置控制器中
		on btn_set pressed do 
		(
			if isValidObj select_root do (
				for i= 1 to select_root.wave_nodes.count do 
				(
					
					p = select_root.wave_nodes[i]
					if p != undefined and isValidNode p.node do 
					(

						ctr = p.node.position.controller[curve_type.state].controller
						v = get_percentValue i 
						if v != undefined do (
							x = getCurveValue v 
							ctr.setConstant "curveVV" x 
							format "%, %, %\n" p.node.name v x 
						)
					) 
					
				)
				save_curve()
			)
		) 
		on params open do
		(
			select_root = $.modifiers[#Attribute_Holder]
			load_curve()
		)	

		on params close do
		(
			--save_curve()
		)

		
	)
	on create do
	(
		
	)
	

	parameters boneSineAniUsePos rollout: boneSineAniUsePos
	(
		range type:#float UI:range defult:15.0
		loop type:#float UI:loop defult:0

		speedV type:#float UI:speedV defult:12.0
		offsetV type:#float UI:offsetV defult:4.0
		rangeAdd type:#float UI:rangeAdd defult:3

		frameFix type:#float UI:frameFix defult:0.0	               


		setsInfo type:#string default:""
		boneInfo type:#string default:""    

			
			
		--记录骨骼链长度（个数）
		boneCount type:#integer  defult:1
		---记录骨骼链长度比
		--bonelongPercent type:#string default:""  
		bonelongPercent type:#floatTab tabsizevariable:true animatable:false	
		
	)
	Rollout boneSineAniUsePos "自己动"		
	(
		group "摆动"
		(
			spinner speedV "速度Z:" width:150 Height:16 Align:#Center Offset:[0,0] Type:#float Range:[-1000,1000,12.0] enabled:false
			
			button setLoopbt  "按时间轴循环:"  width:100 Height:20 Align:#Center Offset:[0,0] 
			spinner loop "循环:" width:150 Height:16 Align:#Center Offset:[0,0] Type:#float Range:[-10000,10000,0] scale:1 

			spinner range "幅度:" width:150 Height:16 Align:#Center Offset:[0,0] Type:#float Range:[-1000,1000,15.0]
			spinner offsetV "滞后:" width:150 Height:16 Align:#Center Offset:[0,0] Type:#float Range:[-10000,10000,4.0]
			spinner rangeAdd "增益:" width:150 Height:16 Align:#Center Offset:[0,0] Type:#float Range:[-1000,1000,3.0]		
			spinner frameFix "帧位:" width:150 Height:16 Align:#Center Offset:[0,0] Type:#float Range:[-1000,1000,0]

		)
 
		group "塌陷"
		(
			radioButtons rdoRangeType "" labels:#("Time Line","Range") default:1 columns:2
			label lbStart "Start :"　across:2 enabled:false
			spinner spnStart "" align:#left width:60 range:[-9999,9999,0] type:#integer enabled:false
			label lbEnd "End :"　across:2 enabled:false
			spinner spnEnd "" align:#left width:60 range:[-9999,9999,0] type:#integer enabled:false
		)                
		
		button resetToV  "默认" tooltip: "左键恢复预设，右键对帧位" across:2
		button collapseToOri "塌陷↑" tooltip: "恢复成原始骨骼,选择需要塌陷的骨骼链" across:2
		button resetToOpen  "开(?′ヮ′)?" tooltip: "打开表达式动画" across:2
		button resetToZero  "?(ˊ?ˋ*)?关" tooltip: "关闭表达式动画" across:2

		
		label aboutsplide	"~~~~~~~~~~~~~~"
		label aboutYun "written  by：东见云"
		
		on  setLoopbt pressed do
		(
			animationRange.end.frame - animationRange.start.frame
			loop.value = animationRange.end.frame - animationRange.start.frame
		)
		
		-- 打开时固定执行
		on boneSineAniUI open do
		(
			
		if animButtonState == true then	(max tool animmode;set animate off	)

			speedV.value = (6.28319 / (loop.value / 114.592))				
			speedV_Y.value = (6.28319 / (loop_Y.value / 114.592))		
			if startTime == undefined then (
				global startTime
				
			)
			startTime = (animationRange.start as string) as integer
			if endTime == undefined then (
				global endTime
				
			)
			endTime = (animationRange.end as string) as integer
			
			spnStart.value = startTime
			spnEnd.value = endTime

			if boneSineTimeRangeType != undefined then 
			(
			rdoRangeType.state = boneSineTimeRangeType
			case boneSineTimeRangeType of (
				1:(
					lbStart.enabled = false
					lbEnd.enabled = false
					spnStart.enabled = false
					spnEnd.enabled = false
				)
				2:(
					lbStart.enabled = true
					lbEnd.enabled = true
					spnStart.enabled = true
					spnEnd.enabled = true
				)
			)
		)
			
		)
		---速度改变同步周期用
		on loop changed val do(
			speedV.value = (6.28319 / (val / 114.592))		
		)
		on loop_Y changed val do (
			speedV_Y.value = (6.28319 / (val / 114.592))				
		)
		---塌陷切换开关范围帧数
		on rdoRangeType changed val do 		(
			case val of (
				1:(
					lbStart.enabled = false
					lbEnd.enabled = false
					spnStart.enabled = false
					spnEnd.enabled = false
				)
				2:(
					lbStart.enabled = true
					lbEnd.enabled = true
					spnStart.enabled = true
					spnEnd.enabled = true
				)
			)
			if boneSineTimeRangeType == undefined then (
				global boneSineTimeRangeType
			)
			boneSineTimeRangeType = val
		)
		---时间轴控制
		on spnStart changed val do			(
			if spnEnd.value < val then (
				spnEnd.value = val
			)
			if startTime == undefined then (
				global startTime
			)
			startTime = val
		)
		---动画的ikfk切换的配置块儿的 小弟
		on spnEnd changed val do 
		(
			if spnStart.value > val then (
				spnStart.value = val
			)
			if endTime == undefined then (
				global endTime
			)
			endTime = val
		)
		---塌陷
		on  collapseToOri pressed do
		(
			undo on
			(
				
				tStart = (animationRange.start as string) as integer
				--if  $.modifiers[1].boneSineAniUI.rdoRangeType.state == 2 then
				if rdoRangeType.state == 2 then
				(tStart = spnStart.value )
				
				tEnd = (animationRange.end as string) as integer
				if rdoRangeType.state == 2 then
				(tEnd = spnEnd.value )
				
				--创建变量 tNow 等于当前时间轴 所选择帧	
				tNow = (currentTime as string) as integer
				--创建变量 TimeLength = （时间轴最后一帧 - 时间轴第一帧 ） + 1  用来获取总帧数
				TimeLength = (tEnd - tStart) + 1
				--创建数组变量 frames  等于 空
				frames = #()		
				--循环 i 等于起始帧 到 结尾帧 每次循环 添加到数组 frames +1 
				for i = tStart to tEnd do append frames i						
				boneN = execute( $.modifiers[1].boneInfo)					 
				sel=#()
				for i in boneN do (append sel (getnodebyname i) )
				--sel = selection as array
				if sel.count<1 then (messageBox  "骨骼重命名就会看到我喔~~~" )
				else
				(
					TM_record = #()	
					--print TM_record
					---记录空间矩阵
					for frame in frames do 
					(	
						--frame = frames[2]
						--sliderTime = frame					
						at time	frame				
						(
						--obj = 	sel[1]
						TM_buffer = #()	
						for obj in sel do (	append TM_buffer obj.transform	)
						append 	TM_record TM_buffer
						)
					)
					---恢复控制器
					for i in sel do(	i.pos.controller = Position_XYZ ();	i.rotation.controller = Euler_XYZ ())
					---恢复动画
					animate on
					(
						for f = 1 to frames.count do 
						(	
							at time (frames[f] as time)				
							(
								for i =1 to sel.count do (	sel[i].transform = TM_record[f][i]	)
							)
						)
						
					)
				)
			try (delete $) catch(print "未选择控制")
				
			)
		)
		
		
		
		---关闭
		on  resetToZero pressed do (
			with animate off(				
				if speedV.value!=0 and speedV_Y.value!=0 then
				(
				buffer = #()
				append buffer $.modifiers[1].speedV
				append buffer $.modifiers[1].speedV_Y
				$.modifiers[1].setsInfo = buffer	as string						
				$.modifiers[1].speedV = 0
				$.modifiers[1].speedV_Y = 0
				redrawViews()
				)

				$.modifiers[1].loop = 114.592 * (6.28319 / $.modifiers[1].speedV  )	
				$.modifiers[1].loop_Y = 114.592 * (6.28319 / $.modifiers[1].speedV_Y  )						
			)
		)
		--打开
		on  resetToOpen pressed do(
			with animate off(
				try	(	
					bufferGet =execute( $.modifiers[1].setsInfo )
					$.modifiers[1].speedV = bufferGet[1]
					$.modifiers[1].speedV_Y = bufferGet[2]					

	
					$.modifiers[1].loop = 114.592 * (6.28319 / $.modifiers[1].speedV  )	
					$.modifiers[1].loop_Y = 114.592 * (6.28319 / $.modifiers[1].speedV_Y  )
					
					print "表达式动画已打开"		
					redrawViews()		
				)catch()
			)
		)
		--预设
		on  resetToV pressed do	(
			with animate off(
			redrawViews()
			print "表达式动画已打开"						
			)
		)
		--帧位
		on  resetToV rightclick  do (
			frameFix.value = (animationRange.start.frame as integer) 				
		)
		
	)
)



	
Global yun_autoAnim_tool 		--界面
Global iniPosTest_yun_autoAnim    --位置
if iniPosTest_yun_autoAnim==undefined then (iniPosTest_yun_autoAnim = [200,200])
Global switchAnimButtonMouState_yun_autoAnim = false  ---鼠标状态
Global posAnimButtonMouMove_yun_autoAnim     = [0,0]   ---事变移动

ctrl_masterGrp =#()   --控制器储存
selectExpressionBones = undefined --骨骼储存
waveLoc = #()   --中间物储存


try(destroyDialog yun_autoAnim_tool)catch()
rollout yun_autoAnim_tool "自己动动画1.3" width:400 height:490 --width:218 height:43
(
		
		-----一键
		--label split1 "︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵"  pos:[5,39] width:218 height:10

		

		button btn_get_ccCurve "拾取限制曲线" width:135 height:22 across:2
		button btn_updata_ccCurve "更新限制曲线" width:135 height:22

		label lab_curve_name ""  across:2 

		radiobuttons curve_type "类型" labels:#("X","Y","Z") columns:3 enabled:false offsets:#([30,-16], [15,-16],[5,-16]) 
		CurveControl cct_ "" x_range:[0,1] y_range:[0,1] numCurves:1 uiFlags:#(#drawgrid,#upperToolbar,#showReset,#xvalue,#constrainY,#autoScroll,#lowerToolbar,#scrollBars) width:380 height:280 commandMode:#move_xy

		    -- Group body.
		group "设置" (
		editText prefixTx "前缀："  text:""  width:130 height:22  labelOnTop: false bold:true align:#left across:4--readOnly:false 

		checkbox axisSet_X "X"  width:40 height:15 checked:false tooltip:"x" offset:[130,0]
		checkbox axisSet_Y "Y"   width:30 height:15 checked:true tooltip:"y" offset:[100,0]
		checkbox axisSet_Z "Z"   width:30 height:15 checked:true tooltip:"z" align:#right
		)
		button btn_Sets1 "创建"  width:135 height:35   tooltip:"左键解君愁，右键赐惊喜" across:2
		button ctrlZ "撤销" width:135 height:35 tooltip:"恢复所有"

		------详细设置	
		--button btn_Sets2 "^O^"  width:35 height:35   tooltip:"左键解君愁，右键赐惊喜" across:2
		--label lab_2  width:35 height:50 
		

		group "调试" (
		    -- Group body.
		
		button creatCrl "1>加控制器"  width:80 height:20   tooltip:"" across:3
		button creathierarchy "2>加中间层"  width:80 height:20   tooltip:""
		button creathExp "2>加表达式"  width:80 height:20   tooltip:""
		--label split2 "︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵︵"  pos:[5,130] width:218 height:10
	
		)
		local select_root = undefined 
		fn getCurveValue curve_name float_x = 
		(
			return (getValue cct_.curves[curve_name] 0 float_x)
		)
		fn get_percentValue curve_name index = 
		(
			if select_root.percentValues_x.count > 0 do (
				return select_root.percentValues_x[index] 
			)
			if select_root.percentValues_y.count > 0 do (
				return select_root.percentValues_y[index] 
			)
			if select_root.percentValues_z.count > 0 do (
				return select_root.percentValues_z[index] 
			)
			/* if curve_name == 3 do 
			(
				return select_root.percentValues_z[index] 
			)
			if curve_name == 2 do 
			(
				return select_root.percentValues_y[index] 
			)
			if curve_name == 1 do 
			(
				return select_root.percentValues_x[index] 
			) */
		)
		---按层级排序
		fn sortArrayByHeirarchy objectArray =
		( 
			sortedArray=#()
			childArray=#()
			-- first find roots and put them at left
			for obj in objectArray do(
			if (finditem objectArray obj.parent) == 0 
			  then append sortedArray obj
			  else append childArray obj  
			)
			-- now insert children on immediate right of their parents
			-- repeat scan until child array is empty
			while childArray.count > 0  do(
			i=1
			while i <= childArray.count do(
			  parentIdx = finditem sortedArray childArray[i].parent
			  if parentIdx != 0 then(
				insertItem childArray[i] sortedArray (parentIdx+1) 
				deleteItem childArray i
			 ) 
			  else(
				 i += 1  
			  )
			)
			)
			sortedArray
		)

		---创建主要控制器
		fn creatAutoAnimMainCtrl  prefix  boneChain r p =
		(  --r,p是控制器大小和位置
			
			try (delete (getnodebyname prefix )) catch()
			ctrl_master = undefined
			ctrl_master =  text size:r kerning:0 leading:0 pos:p isSelected:off	
			ctrl_master.text =  prefix
			ctrl_master.name = prefix
			
			--位置调整
			ctrl_master.rotation	= (quat 0.707107 0 0 0.707107)
			ctrl_master.pos = p
			--ctrl_master.pos.z = r	

			---属性创建
			addmodifier ctrl_master (EmptyModifier())
			add_attribute = custattributes.add ctrl_master.modifiers[1] boneSineAniUsePos
			-- 初始化
			ctrl_master.modifiers[1].range = 2.3
			--ctrl_master.modifiers[1].loop =	(animationRange.end.frame as float) - (animationRange.start.frame as float)		
			ctrl_master.modifiers[1].loop  = 160	
			ctrl_master.modifiers[1].speedV = 8.8	
			ctrl_master.modifiers[1].offsetV = 100		
			ctrl_master.modifiers[1].rangeAdd = 20		
			ctrl_master.modifiers[1].frameFix = 0.0	
			
			--记录骨骼名
			boneInfoName = #()
			for i in boneChain do	(	append boneInfoName i.name	)
			ctrl_master.modifiers[1].boneInfo = boneInfoName as string
			
			--获取骨骼百分比长度
			distanceRec = #()
			disAll = 0	
			append distanceRec 0
				
			--	boneChain = selection as Array
				
			for i = 1 to boneChain.count-1 do(
				dis = length(boneChain[i+1].transform.pos - boneChain[i].transform.pos)
				disAll += dis
				append distanceRec disAll
			)
			longthPer = #()
			perDD = 0
			for i=1  to  boneChain.count do(append  longthPer (distanceRec[i]/disAll))

			/* strfix = "#("	
			for i=1 to longthPer.count do (		
				strfix+= (longthPer[i] as string)
				if i<longthPer.count then(strfix += ", ")
			)
			strfix += ")" */	

			--execute strfix
			ctrl_master.modifiers[1].boneCount = longthPer.count
			ctrl_master.modifiers[1].bonelongPercent = longthPer
				
			return ctrl_master
		)	


	---加表达式动画 axisSet  --1,2,3对应xyz的位移
	fn makeExpAnim axisSet ctrl_master objs percentValue  = (	
		--ctrl_master  =  $WaveEXP	
		for  i = 1  to objs.count do	
		(
			boneTar = objs[i]
			
			boneTar.pos.controller = Position_XYZ () 		
			boneTar.pos.controller[axisSet].value =	0	
			
			posPPScript = float_script()
			boneTar.pos.controller[axisSet].controller = posPPScript
			
			posPPScript.AddNode  "this" ctrl_master	
			posPPScript.AddTarget "range"  ctrl_master.modifiers[1].boneSineAniUsePos[#range]
			posPPScript.AddTarget "loop"  ctrl_master.modifiers[1].boneSineAniUsePos[#loop]
			posPPScript.AddTarget "offsetV"  ctrl_master.modifiers[1].boneSineAniUsePos[#offsetV]
			posPPScript.AddTarget "rangeAdd" ctrl_master.modifiers[1].boneSineAniUsePos[#rangeAdd]
			posPPScript.AddTarget "frameFix" ctrl_master.modifiers[1].boneSineAniUsePos[#frameFix]	
			posPPScript.AddConstant  "boneper" percentValue[i]

			--posPPScript.AddConstant  "boneCount"  (objs.count-1)
			try (
				--curve_value = ctrl_master.modifiers[1].params.getCurveValue percentValue[i]
				curve_value = getCurveValue 1 percentValue[i]
			)catch(
				curve_value = percentValue[i]
			)
			format "% , % , % \n" boneTar.name curve_value percentValue[i]
			posPPScript.AddConstant "curveVV" curve_value
			
			_script = "[0,0,0];"
			
			--_script = "curveVV = at time (boneper * 100  - 100000f) this.modifiers[#Attribute_Holder].Curve.controller.value;\n" 
			--_script += "curveVV = this.modifiers[1].params.getCurveValue boneper;\n"
			
			_script +="sin( (6.28319 / (loop / 114.592)) * ((F)  + frameFix  + (offsetV*1 * boneper   * -1))) * (curveVV*100.0*rangeAdd *0.01+ range);\n"	
			posPPScript.script = _script	

			origin = NodeTransformMonitor node:boneTar forwardTransformChangeMsgs:false
			append ctrl_master.modifiers[1].wave_nodes origin

		)
		ctrl_master.modifiers[1].percentValues_x = percentValue

		--if axisSet == 3 do (ctrl_master.modifiers[1].percentValues_z = percentValue)
		--if axisSet == 2 do (ctrl_master.modifiers[1].percentValues_y = percentValue)
		--if axisSet == 1 do (ctrl_master.modifiers[1].percentValues_x = percentValue)
		
	)
	-- 如果数字不足三位，在数字前面补0，直到达到三位数
	fn formatNumberToThreeDigits num =
	(
	    numStr = num as string 
	    while (numStr.count < 3) do
	    (     numStr = "0" + numStr )
	    return numStr
	)

	-----maxscript natural numeric sort自然数字排序
	fn getSHLWAPI = 
	(
		source =  "using System;\n"
		source += "using System.Runtime.InteropServices;\n"
		source += "class SHLWAPI\n"
		source += "{\n"
		source += "	[DllImport(\"shlwapi.dll\", CharSet = CharSet.Auto)]\n"
		source += "	public static extern int StrCmpLogicalW(string lpszStr, string lpszComp);\n"
		source += "}\n"

		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
					
		compilerParams.GenerateInMemory = on
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
		compilerResults.CompiledAssembly.CreateInstance "SHLWAPI"
	)


	-- 数组倒序
	fn ReverseListFN arr =
	(
		if arr == undefined do exit;
		if (mod arr.count 2 ) == 0 then (
			for i =1 to (arr.count / 2 ) do
			(
				local atemp = arr[i]
				index = arr.count - (i - 1)

				arr[i] = arr[index]
				arr[index] = atemp
			)
		)else(
			endindex = (arr.count - 1 )	* 0.5
			for i= 1 to endindex do
			(
				local atemp = arr[i]
				index = arr.count - (i - 1)

				arr[i] = arr[index]
				arr[index] = atemp
			)
		)
	)
	------创建locator，obj是字符串传入
	fn yunDummyCheckCreate obj  =
	(
		yunSel = getNodeByName obj
		--判断有没有这个名称的虚拟体 有的话则选择删除 没有则正常创建
		if yunSel != undefined then (	delete yunSel	)	
		Dummy_Anim = point pos:[0,0,0] isSelected:off
		Dummy_Anim.name = obj
		Dummy_Anim.cross = on
		Dummy_Anim.axistripod = off	
		Dummy_Anim.Box = off
		return Dummy_Anim

	)

	-- -objA被objB位置约束
	fn yunPosconstraintAcurity objA objB = 
	(
		objA.pos.controller = Position_XYZ ()	
		--objA.pos.controller = position_list ()	
		posPP =Position_Constraint() 
		objA.pos.controller = posPP
		--objA.pos.controller.Available.controller=posPP
		posPP.appendTarget objB 100
		posPP.relative=true	
		--objA.pos.controller.Available.controller = Position_XYZ ()
		--objA.pos.controller.setActive 2
	)

	-- -objA被objB旋转约束
	fn yunRotconstraintAcurity objA objB = 
	(
		objA.rotation.controller = Euler_XYZ ()	
		--objA.rotation.controller = rotation_list  ()	
		rotPP =Orientation_Constraint() 
		objA.rotation.controller = rotPP	
		--objA.rotation.controller.Available.controller=rotPP
		rotPP.appendTarget objB 100
		rotPP.relative=true	
		--objA.rotation.controller.Available.controller = Local_Euler_XYZ ()
		--objA.rotation.controller.setActive 2
	)

		fn point2_to_point3 value2 = 
		(
			p = [0,0,0]
			p.x = value2.x 
			p.y = value2.y 
			p  
		)

		fn bool_to_int value2 = 
		(
			p = if value2 then(1)else(0) 
			p 
		)
		fn create_curve = 
		(

			colors = #(red, green, blue)
			
				for i =1 to 1 do
				(
					--tempcc = cct_.curves[i]
					cct_.curves[i].color = colors[i]
					cct_.curves[i].numPoints = 2
					cct_.curves[i].animatable = false
					cct_.curves[i].points[1].value = [0,0]

					cct_.curves[i].points[1].bezier = false
					cct_.curves[i].points[1].corner = true

					cct_.curves[i].points[2].bezier = false
					cct_.curves[i].points[2].corner = true


					cct_.curves[i].points[2].value = [1,1]
					cct_.curves[i].style= #insideFrame
				)

			cct_.scrollValues = [-20,-45]
			cct_.zoomValues =[310,200]
		)
		fn load_curve =
		(
			is_ok = false 

			if isValidObj select_root do 
			(

				if select_root.Coords.count > 0 then
				(
					Coords = select_root.Coords
					inTangents = select_root.inTangents
					outTangents = select_root.outTangents
					bezier = select_root.beziers
					corner = select_root.corners
					--index = select_root.curve_name
					index = 1

					--cct_.curves[1].color =_curve[o].color
					cct_.curves[index].numPoints = Coords.count
					cct_.curves[index].animatable = false
					
					for i =1 to Coords.count do
					(
						cct_.curves[index].points[i].value = [(Coords[i].x), (Coords[i].y)] 

						cct_.curves[index].points[i].inTangent = [(inTangents[i].x) , (inTangents[i].y)]
						cct_.curves[index].points[i].outTangent = [(outTangents[i].x) , (outTangents[i].y)]

						is_bezier = if bezier[i] == 1 then(true)else(false)
						is_corner = if corner[i] == 1 then(true)else(false) 
						cct_.curves[index].points[i].bezier = is_bezier
						cct_.curves[index].points[i].corner = is_corner
					)
					is_ok = true
				)else(
					--create_curve()
				)
				
			)
			is_ok
		)
		fn save_curve modifier_root = 
		(
			if isValidObj modifier_root then 
			(
				modifier_root.Coords = #()
				modifier_root.inTangents = #()
				modifier_root.outTangents = #()

				--index = modifier_root.curve_name
				index = 1

				for i = 1 to cct_.curves[index].points.count do
				(
					p = point2_to_point3 (cct_.curves[index].points[i].value)
					append modifier_root.Coords p 

					intang = point2_to_point3 (cct_.curves[index].points[i].inTangent)
					append modifier_root.inTangents intang  

					outTang = point2_to_point3 ( cct_.curves[index].points[i].outTangent)
					append modifier_root.outTangents outTang

					append modifier_root.beziers (bool_to_int (cct_.curves[index].points[i].bezier))
					append modifier_root.corners (bool_to_int (cct_.curves[index].points[i].corner))

				)
				return true 
			)else(
				return false 
			)
		)
		
		fn set_value root_modifi curve_name = 
		(
			msg = StringStream ""

			if isValidObj root_modifi do 
			(
				format "Name, percentValue, curveVV\n" to:msg

				for i= 1 to root_modifi.wave_nodes.count do 
				(
					
					p = root_modifi.wave_nodes[i]
					if p != undefined and isValidNode p.node do 
					(
						ctr = p.node.position.controller[curve_name].controller
						--v = get_percentValue curve_name i
						v = get_percentValue 1 i

						if v != undefined then ( 
							--x = getCurveValue curve_name v 
							x = getCurveValue 1 v 

							ctr.setConstant "curveVV" x 
							format "%, %, %\n" p.node.name v x to:msg
						)else()

					) 
					
				)
			)
			msg 
		)
		on btn_get_ccCurve pressed do 
		(
			if selection.count > 0 do 
			(
				temp_select_root = selection[1].modifiers[#Attribute_Holder]
				if (isProperty temp_select_root #curve_name) then 
				(
					curve_type.state = temp_select_root.curve_name
					select_root = temp_select_root
					if load_curve() then  
					(
						lab_curve_name.text = selection[1].name
						messageBox "加载成功！"
					)else(
						lab_curve_name.text = ""
					)

				)else(
					lab_curve_name.text = ""

					format "% => %\n" selection[1].name (exprForMAXObject temp_select_root)
				)
			)
		)
		on btn_updata_ccCurve pressed do 
		(
			if selection.count > 0 do 
			(
				temp_select_root = selection[1].modifiers[#Attribute_Holder]
				if (isProperty temp_select_root #curve_name) then 
				(
					select_root = temp_select_root
					if (save_curve select_root) do
					(
						msg = set_value select_root select_root.curve_name
						--select_root.params.btn_set.pressed()
						select_root.params.load_curve()
						messageBox (msg as string)
					)

				)else(
					format "% => %\n" selection[1].name (exprForMAXObject temp_select_root)
				)
			)
		)
		--恢复所有		
		on ctrlZ pressed do 
		(
			max create mode

			if selectExpressionBones ==undefined or not isValidNode(selectExpressionBones[1]) then (
				if selection.count >1 then (
					selectExpressionBones = #()
					selectExpressionBones	= selection as array
				)
				else(
					return false
					messageBox "重开过后请选择骨骼链"

				)				
			)
			
			try	(	
				
				allText = for i in objects where (classof i == SplineShape) collect i
				for i in allText do(					
					i.modifiers[#Attribute_Holder].boneSineAniUsePos.range = 0
					i.modifiers[#Attribute_Holder].boneSineAniUsePos.offsetV = 0
					i.modifiers[#Attribute_Holder].boneSineAniUsePos.rangeAdd = 0
					
				)
				for i in selectExpressionBones do  --	i = selectExpressionBones[3]
				(
					tm = i.transform
					i.rotation.controller = Euler_XYZ ()					
					i.pos.controller = Position_XYZ ()
					i.transform = tm				
				)
				
				for i in waveLoc do  --	i = selectExpressionBones[3]
				(
					tm = i.transform
					i.rotation.controller = Euler_XYZ ()					
					i.pos.controller = Position_XYZ ()
					i.transform = tm				
				)
						
				
				
				for i=1 to LayerManager.count-1 do
				(
					layerGet = LayerManager.getLayer i
					--print layerGet.name
					if layerGet.name=="autoAnim" then
					(
						layer = ILayerManager.getLayerObject i
						layerNodes = refs.dependents layer
						layer.Nodes &theNodesTemp
						for obj in theNodesTemp do   -- 		obj=theNodesTemp[1]
						(
							if not (( (classof obj) == Scene  or 
							(classof obj) == Layer_Manager  or
							(classof obj) == skin  or
							(classof obj) == DummyClass ) ) then		
							(
								if obj.name!=undefined then(
									
									obj.rotation.controller = Euler_XYZ ()					
									obj.pos.controller = Position_XYZ ()
									obj.pos.controller[1].controller = bezier_float ()	
									obj.pos.controller[2].controller = bezier_float ()	
									obj.pos.controller[3].controller = bezier_float ()	
									delete   obj									
									)
							)
						)
					)
				)
				LayerManager.deleteLayerByName "autoAnim"
			
			)catch()

			ctrl_masterGrp =#()   --控制器储存
			selectExpressionBones = undefined --骨骼储存
			waveLoc = #()   --中间物储存
			
		)
		
		---一键执行
		on btn_Sets1 pressed do
		(	
			ctrl_masterGrp =#()   --控制器储存
			selectExpressionBones = undefined --骨骼储存
			waveLoc = #()   --中间物储存		
			yun_autoAnim_tool.creatCrl.pressed()

			if selection.count>1 then	(	
				yun_autoAnim_tool.creathierarchy.pressed()
				redrawViews()
				yun_autoAnim_tool.creathExp.pressed()
			)
		)
		--1>加控制器
		on creatCrl pressed do 
		(
			ctrl_masterGrp =#()   --控制器储存
			selectExpressionBones = undefined --骨骼储存
			waveLoc = #()   --中间物储存
			if selection.count>1 then	(	
				animate off (
					---获取选择					
					selectExpressionBones  = sortArrayByHeirarchy (selection as array)
					----根据骨骼大小调整控制器大小
					r = 1/5
					p = [0,0,0]	
					if selectExpressionBones.count > 0 and classof(selectExpressionBones[1])==BoneGeometry then 
					(r = selectExpressionBones[1].length;p = selectExpressionBones[1].transform.pos)			
					
					-- 前缀设定
					prefix = "antoAnim"
					if yun_autoAnim_tool.prefixTx.text=="" then(prefix = selectExpressionBones[1].name)
					else (prefix =  yun_autoAnim_tool.prefixTx.text )	
										
					--检查重复
					--ctrlCheck = getnodebyname (prefix+"EXP")
					--if (ctrlCheck!=undefined) then	
					--(messageBox "已经存在同名控制，请删除或改前缀")		
					--else (
						--开始创建
						if   yun_autoAnim_tool.axisSet_X.checked then(
							CC =  creatAutoAnimMainCtrl (prefix + "_X") selectExpressionBones  r [p.x,p.y,(p.z+3*r)]
							append ctrl_masterGrp CC
							ctrl_masterGrp[1] = CC
							CC.modifiers[#Attribute_Holder].boneSineAniUsePos.frameFix = 40
							CC.modifiers[#Attribute_Holder].curve_name = 1 
							
							save_curve CC.modifiers[#Attribute_Holder]


							CC.wireColor = red
						)
						if   yun_autoAnim_tool.axisSet_Y.checked then(
							CC =  creatAutoAnimMainCtrl (prefix + "_Y") selectExpressionBones  r [p.x,p.y,(p.z+2*r)]
							append ctrl_masterGrp CC
							ctrl_masterGrp[2] = CC
							CC.modifiers[#Attribute_Holder].boneSineAniUsePos.frameFix = 80
							CC.modifiers[#Attribute_Holder].curve_name = 2 
							save_curve CC.modifiers[#Attribute_Holder]


							CC.wireColor = green
						)
						if   yun_autoAnim_tool.axisSet_Z.checked then(
							CC =  creatAutoAnimMainCtrl (prefix + "_Z") selectExpressionBones  r [p.x,p.y,(p.z+1*r)]
							append ctrl_masterGrp CC
							ctrl_masterGrp[3] = CC
							CC.modifiers[#Attribute_Holder].curve_name = 3
							save_curve CC.modifiers[#Attribute_Holder]


							CC.wireColor = blue
						)		
					--)	
				)							
				select selectExpressionBones
			)else (	messageBox "未选2个以上物体";)	
			
			layerCheck = layerManager.getLayerFromName "autoAnim"
			if layerCheck ==undefined then (layerCheck = layerManager.newLayerFromName "autoAnim") 	
			for i in ctrl_masterGrp do (layerCheck.addnode i )   --加导层中
			
			
			
		)
		--2>加中间层
		on creathierarchy pressed do (		
			max create mode						
		undo on(				
			sel = selection as array
			animBones = #()			
			layerCheck = layerManager.getLayerFromName "autoAnim"
				
			maxOps.cloneNodes sel cloneType:#copy newNodes:&animBones	
			for i in animBones do (layerCheck.addnode i )  --加到层里	
			for i=1 to animBones.count do (animBones[i].name = sel[i].name+"_Anim")	
				
			
			rootLoc = yunDummyCheckCreate ("RootLoctor_AutoAnim")
			layerCheck.addnode rootLoc   --加到层里	
			waveLoc = #()  
			for i in animBones do 	(
				animate off(	
					nameLoc = (i.name+"_Master")
					nameWave = (i.name+"_Wave")					
					yunDummyCheckCreate nameLoc
					yunDummyCheckCreate nameWave						
					waveObj = getNodeByName nameWave
					append waveLoc waveObj
					masterObj = getNodeByName nameLoc					
					waveObj.centermarker = off
					waveObj.cross = off
					waveObj.axistripod = on
					waveObj.Box = off
					waveObj.wireColor = color 252 252 0					
					masterObj.centermarker = on
					masterObj.cross = off
					masterObj.axistripod = off
					masterObj.Box = off
					masterObj.wireColor = color 175 175 175					
					waveObj.parent =  masterObj
					masterObj.parent = rootLoc					
					layerCheck.addnode waveObj   --加到层里	
					layerCheck.addnode masterObj   --加到层里						
					
					masterObj.transform = i.transform					
					--层级link给复制的骨骼
					masterObj.Transform.controller = Link_Constraint ()
					masterObj.transform.controller.AddTarget i ((sliderTime as string) as integer)
					
					in coordsys parent waveObj.rotation = (quat 0 0 0 0)		
					in coordsys parent waveObj.pos = [0,0,0]
				)
			)		
			
			
			
			if ::SHLWAPI == undefined do SHLWAPI = getSHLWAPI()
			try (qsort waveLoc SHLWAPI.StrCmpLogicalW )catch()
			try (qsort selectExpressionBones SHLWAPI.StrCmpLogicalW )catch()
			--ReverseListFN waveLoc
			--print waveLoc
			--删除原先骨骼动画并吸附
			
			select selectExpressionBones
			macros.run "Animation Tools" "DeleteSelectedAnimation"		
			for i in selectExpressionBones do (  --		i =selectExpressionBones[4]
				PP = getNodeByName (i.name+"_Anim"+"_Wave")
				--print PP
				if PP!=undefined then(	
					--蒙皮骨骼link给loc
					i.Transform.controller =  prs ()
					yunPosconstraintAcurity  i PP
					yunRotconstraintAcurity  i PP
				)
			)
			redrawViews()
			
			)
			/*
			-->加注释约束
			presetTarget_axis = 0  
			presetTarget_axisFlip = false			
			for s = 1 to waveLoc.count do   --- 	s=2
			(
				if s > 1 do (
						--print waveLoc[s]
						local t_b = waveLoc[s]
						t_b.rotation.controller = Euler_XYZ ()
						t_b.rotation.controller = rotation_list()
						t_b.rotation.controller.Available.controller = LookAt_Constraint()
						lst = t_b.rotation.controller
						lst.SetActive 2
						
						try (lookat_target = waveLoc[(s - 1)])catch()		---直接看下下一个即可无层级问题
						if lookat_target != undefined do (
						lst.LookAt_Constraint.controller.appendtarget lookat_target 50
						lst.LookAt_Constraint.controller.lookat_vector_length = 0
							
						lst.LookAt_Constraint.controller.upnode_world = true
							
						lst.LookAt_Constraint.controller.target_axis = presetTarget_axis
						lst.LookAt_Constraint.controller.target_axisFlip = presetTarget_axisFlip
							
						--lst.LookAt_Constraint.controller.pickUpNode = twist_help[s]		--上方向								
						--lst.LookAt_Constraint.controller.StoUP_axis = rooCtl.modifiers[#Attribute_Holder]._source_axis-1
						--lst.LookAt_Constraint.controller.upnode_axis = rooCtl.modifiers[#Attribute_Holder].alignedtoUpnodeaxis-1
						--lst.LookAt_Constraint.controller.StoUP_axisFlip = rooCtl.modifiers[#Attribute_Holder]._source_axis_filp
						--lst.LookAt_Constraint.controller.StoUP_axis = rooCtl.modifiers[#Attribute_Holder]._source_axis-1
					)
				)
			)*/
		)
		
		--3>加表达式
		on creathExp pressed do 
		(
			
				
			
			-->加脚本自己动
			max create mode	
			if yun_autoAnim_tool.axisSet_X.checked then(
				percentValue =  ctrl_masterGrp[1].modifiers[1].boneSineAniUsePos.bonelongPercent 
				makeExpAnim 1 ctrl_masterGrp[1] waveLoc	percentValue			
			)
			if yun_autoAnim_tool.axisSet_Y.checked then(
				percentValue =  ctrl_masterGrp[2].modifiers[1].boneSineAniUsePos.bonelongPercent
				makeExpAnim 2 ctrl_masterGrp[2] waveLoc percentValue
			)
			if yun_autoAnim_tool.axisSet_Z.checked then(
				percentValue =  ctrl_masterGrp[3].modifiers[1].boneSineAniUsePos.bonelongPercent
				makeExpAnim 3 ctrl_masterGrp[3] waveLoc percentValue
			)	
			redrawViews()
			-->加注视脚本
			scriptString = "posThis=posThisCtrl.value\n"+
				"posTarget=posTargetCtrl.value * targetParent.transform * inverse nodeParent.transform\n"+
				"vector=posTarget-posThis\n"+
				"axis=normalize (cross vector [1,0,0])\n"+
				"angle=acos (dot (Normalize vector) [1,0,0])\n"+
				"(Quat angle axis)\n"
			
			for i=1 to waveLoc.count-1 do  --	i=2
			(
				waveLoc[i].rotation.controller= Euler_XYZ ()
				waveLoc[i].rotation.controller= rotation_list()	
				
				quatScriptCtrl = rotation_script()
				--waveLoc[i].rotation.controller[1].controller = quatScriptCtrl
				waveLoc[i].rotation.controller.Available.controller =quatScriptCtrl
				waveLoc[i].rotation.controller.Available.controller =Euler_XYZ ()
				
				quatScriptCtrl.addNode "nodeParent" waveLoc[i].parent
				quatScriptCtrl.addNode "targetParent" waveLoc[i+1].parent
				quatScriptCtrl.addObject "posTargetCtrl" waveLoc[i+1].position.controller
				quatScriptCtrl.addObject "posThisCtrl" waveLoc[i].position.controller
				quatScriptCtrl.script=scriptString
				
			)			
			redrawViews()
			
			
		
		

		)
	
		
	
			
		---展开1
		on btn_Sets1 rightclick do
		(
			if yun_autoAnim_tool.height==43 then (yun_autoAnim_tool.height=135;btn_Sets2.text =  "⊙▽⊙")
			else (yun_autoAnim_tool.height=43;btn_Sets2.text =  "^O^")
		)
		---展开3
		on btn_Sets2 rightclick do
		(
			if yun_autoAnim_tool.height==135 then (yun_autoAnim_tool.height=250;btn_Sets2.text =  "⊙▽⊙")
			else (yun_autoAnim_tool.height = 135;btn_Sets2.text =  "^O^")
		)
	
	
		-- 窗口移动功能
		on yun_autoAnim_tool mousemove pos do UI_make.MoveWindow yun_autoAnim_tool
		on yun_autoAnim_tool lbuttondown pos do UI_make.IsReadyToMove yun_autoAnim_tool pos
		on yun_autoAnim_tool lbuttonup pos do UI_make.LetGoTheWindow()	
	
--关闭时记录位置
	on yun_autoAnim_tool close do -- 关闭记忆浮动窗口位置
	(
        iniPosTest_yun_autoAnim   = (GetDialogPos yun_autoAnim_tool)
	)
---中间按下关闭窗口
	on yun_autoAnim_tool mbuttondown pos do 
	(
		try (destroydialog yun_autoAnim_tool) catch ()
	)
-- 左键鼠标位置
	on yun_autoAnim_tool lbuttondown posMou do
	(
		posAnimButtonMouMove_yun_autoAnim = posMou
		switchAnimButtonMouState_yun_autoAnim = on
	)
---左键弹起
	on yun_autoAnim_tool lbuttonup posMou do
	(
		switchAnimButtonMouState_yun_autoAnim = off
	)
	
--移动鼠标则移动窗口
	on yun_autoAnim_tool mouseMove pos do
	(
		if switchAnimButtonMouState_yun_autoAnim == on then
		(
			SetDialogPos yun_autoAnim_tool (mouse.screenpos - posAnimButtonMouMove_yun_autoAnim)			
		)
	)
	on yun_autoAnim_tool open do 
	(
		create_curve()
	)
)

Createdialog yun_autoAnim_tool -- pos:iniPosTest_yun_autoAnim --style:#() 

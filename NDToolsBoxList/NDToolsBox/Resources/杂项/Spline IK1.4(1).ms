try(destroydialog rollout_title) catch()

rollout rollout_title "SplineIK v1.4" width:190 height:295
(
	subrollout sub_broken "" width:190 height:300 pos:[0,0]
)

rollout SplineIK "SplineIK v1.4" width:185 height:193
(
	label lbl1 "控制器颜色" pos:[25,14] width:63 height:18
	colorPicker cp1 "" pos:[91,13] width:60 height:16 enabled:true color:(color 14 254 2)
	label lbl2 "间隔" pos:[60,39] width:27 height:15  toolTip:"两个控制器之间骨骼的数量" align:#left
	spinner spn1 "" pos:[95,38] width:56 height:16 range:[1,100,1] scale:1 toolTip:"两个控制器之间骨骼的数量" align:#left
	label lbl3 "骨骼大小" pos:[38,63] width:52 height:16
	spinner spn2 "" pos:[95,63] width:56 height:16 range:[0.01,100,5] scale:0.01 
	label lbl4 "骨骼拉伸" pos:[17,90] width:52 height:16
	checkbox chk1 "Checkbox" pos:[75,92] width:14 height:12 checked:true  enabled:false
	label lbl5 "YZ轴旋转" pos:[101,90] width:48 height:18	toolTip:"勾选后曲线将不自动平滑，控制器可控制骨骼3个方向的旋转，龙蛇骨架可勾选，锁链不建议勾选" align:#left
	checkbox chk2 "Checkbox" pos:[157,92] width:14 height:12 	toolTip:"勾选后曲线将不自动平滑，控制器可控制骨骼3个方向的旋转，龙蛇骨架可勾选，锁链不建议勾选" align:#left
	label lbl6 "FK" pos:[76,112] width:19 height:16	toolTip:"龙蛇骨架建议勾选" align:#left
	checkbox chk3 "Checkbox" pos:[98,113] width:14 height:12		toolTip:"龙蛇骨架建议勾选" align:#left
	button btn1 "确认" pos:[53,132] width:88 height:32 toolTip:"样条曲线点数即控制器个数" align:#left
	hyperLink lianjie "作者:子墨[z.ven]" address:"https://www.cgjoy.com/forum.php?mod=viewthread&tid=223735" color:(color 7 254 254) hoverColor:(color 0 255 255) visitedColor:(color 7 254 254)  pos:[50,175] width:95 height:19
	hyperLink lianjie2 "QQ交流群:330875128" address:"(右键点击复制群号)" color:(color 7 254 254) hoverColor:(color 0 255 255) visitedColor:(color 7 254 254)  pos:[44,192] width:110 height:19

		on btn1 pressed  do
	(
		undo on(	
			a=selection as array
				if (superclassof a[1]!=Shape) then(
				messagebox"请选择样条曲线"
				)else(	
					num=spn1.value-1
				for i in selection do(				
				global	ctrl=#()		
				global	bonee=#()
				global	Points=#()					
				global	bonee2=#()
				global	bonee3=#() 				
				global	xnt1=#()			
				global	g=#()  		---------------(ii为样条线的点，i为样条线)
				global	g3=#() 
				ds=numknots i    -----------------以整数形式返回样条线的点数
				kontArray = #{1..ds} as array      -----------样条线点数构成一个数组
				setKnotSelection i 1 kontArray keep:true      ------------选择指定样条线里的点
				for ii = 1 to kontArray.count do setKnotType i 1 ii #smooth     --------设置样条线点的类型为平滑
				if  (chk2.checked==true) do(
					for ii = 1 to kontArray.count do setKnotType i 1 ii #bezier
					)
				updateshape $    ---------------更新样条线
				addmodifier i (spline_ik_control()) 		 -----添加spline_ik_control，样条线IK
				i.spline_ik_control.createhelper(ds)		------根据样条线点数创建虚拟体
				i.spline_ik_control.helper_size=spn2.value*2.5 		-----设置虚拟体的大小 
				$Point*.wirecolor=cp1.color				-------所有名字带Point的物体颜色为画板设置的颜色，Point就是创建出的虚拟体
				i.spline_ik_control.nolinking()			-------------虚拟体无链接关系
				i.spline_ik_control.helper_axistripod=true 		
				i.spline_ik_control.drawontop=false  	---------设置样条线IK 的参数
				ctrl=$Point* as array		----给创建出的虚拟体赋值ctrl
				for ii=1 to ctrl.count do(          
					ctrl[ii].name=uniquename "Ctrl"        ------重命名
					ctrl[ii].scale.controller = ScaleXYZ ()     --------给ctrl添加缩放XYZ
				)
				-------------------ds  样条线的点数          num  间隔里的数字-1
				for ii=1.0 to ((ds-1)*num)+ds do(				 ----这里是虚拟体的数量   ((ds-1)*num)
				xnt1[ii]=Dummy	boxsize:[spn2.value*0.75,spn2.value*0.75,spn2.value*0.75]	
				xnt1[ii].position.controller = path_constraint()     ----给创建的虚拟体路径约束
				xnt1[ii].position.controller.path =i			-----给虚拟体添加路径为样条线
				bfb=(ii-1)/(((ds-1)*num)+ds-1)*100        ----------路径约束的路径值   算法太烧脑了，自己推算推不出来
				xnt1[ii].position.controller.percent = bfb	     ------设定每个虚拟体的路径值
				xnt1[ii].name=uniquename "xnt" 		----改名字
				)
				cs=0
				for ii=1 to ds-1 do(
					for iii=1 to spn1.value do (
					xnt1[((cs*spn1.value)+iii)].rotation.controller = Orientation_Constraint ()
					xnt1[((cs*spn1.value)+iii)].rotation.controller.appendTarget ctrl[ii] (((spn1.value-iii+1)/spn1.value)*100)
					xnt1[((cs*spn1.value)+iii)].rotation.controller.appendTarget ctrl[ii+1] (100-(((spn1.value-iii+1)/spn1.value)*100))
					)     --------给虚拟体添加方向约束，目标为样条线IK的虚拟体
					cs+=1
				)
				for ii=1 to ((ds-1)*num)+ds-1 do(
				Points[ii]=Point pos:xnt1[ii].pos size:(spn2.value*0.1)
-- 				Points[ii].dir =i.dir 
				in coordsys local move Points[ii] [0,0,(spn2.value*0.25)]
				Points[ii].Box = off
				Points[ii].axistripod = off
				Points[ii].cross = on
				Points[ii].parent=xnt1[ii]
				Points[ii].name=uniquename "targets" 
				Points[ii].wirecolor=color 14 254 2
				)         -----------------注视约束上方向节点的虚拟体

				for ii=1 to ((ds-1)*num)+ds do (						
					if ii<((ds-1)*num)+ds then(
					bonee[ii]=BoneSys.createBone xnt1[ii].pos xnt1[ii+1].pos [0,0,1]   ---------创建bone ，位置是xnt1到xnt2
					bonee[ii].width = spn2.value     ----bone的大小是spn2的参数
					bonee[ii].height = spn2.value
				--	bonee[ii].wirecolor = color 177 88 27
						if ii==1 then(
							g[1]=bonee[ii]
							)
					)else(  ---------ii大于等于点数后，创建一个末端骨骼
					bonee[ii]=BoneSys.createBone xnt1[ii].pos (xnt1[ii].pos*1.1)   [0,0,1] --bonee[ii-1].dir   末端的初始位置等于xnt位置，结束位置是虚拟体间距的十分之一
					bonee[ii].transform =bonee[ii-1].transform   ---末端的位置是上节骨骼的位置
					in coordSys Local move bonee[ii] [bonee[ii-1].length,0,0]  --移动末端骨骼，距离是上节骨骼的长度
					bonee[ii].width = spn2.value	
					bonee[ii].height = spn2.value
				--	bonee[ii].wirecolor = color 177 88 27
					bonee[ii].taper= 90
					bonee[ii].length= (bonee[ii].width+bonee[ii].height)/2   -----------末端的长度为骨骼宽度与高度相加除以2
					)
					if ii>1 then(						
					bonee[ii].parent=bonee[ii-1]   ---改链接关系
					) 
					bonee[ii].name=uniquename "Skinbone"
					setInheritanceFlags bonee[ii] #{1,2,3,4,5,6}    ----锁定继承关系
					setTransformLockFlags bonee[ii]  #{1,2,3,4,5,6,7,8,9}     ---------锁定移动旋转缩放
				)
				for ii=1 to ((ds-1)*num)+ds-1 do (
					bonee[ii].rotation.controller = lookat_constraint()		   
					bonee[ii].rotation.controller.appendtarget xnt1[ii+1]  50 		
					bonee[ii].rotation.controller.lookat_vector_length = 0      				
					bonee[ii].rotation.controller.relative=true  
					bonee[ii].rotation.controller.upnode_world = off 
					bonee[ii].rotation.controller.upnode_ctrl = 0 
					bonee[ii].rotation.controller.pickUpNode = Points[ii] 
				) 
					md=((ds-1)*num)+ds
					bonee[md].rotation.controller=orientation_Constraint() 
					bonee[md].rotation.controller.appendTarget ctrl[ds] 50	
					bonee[md].rotation.controller.relative=true   	 		
				
				if  (chk1.checked==true) do(
					for ii=1 to ((ds-1)*num)+ds do (
					bonee[ii].position.controller = position_constraint()    
					bonee[ii].position.controller.appendTarget xnt1[ii] 50   
					)
				) 
				
				cs=0
				for ii=1 to ds-1 do(
					for iii=1 to spn1.value do (
		 				ex2= Scale_Expression ()
						bonee[((cs*spn1.value)+iii)].scale.controller =ex2
						ex2.AddScalarTarget "A" ctrl[ii].scale.controller.X_Scale.controller
						ex2.AddScalarTarget "B" ctrl[ii].scale.controller.Z_Scale.controller
						ex2.AddScalarTarget "C" ctrl[ii+1].scale.controller.X_Scale.controller
						ex2.AddScalarTarget "D" ctrl[ii+1].scale.controller.Z_Scale.controller
					--	ex2.AddScalarTarget "E" ctrl[ii].scale.controller.Y_Scale.controller
					--	ex2.AddScalarTarget "FF" ctrl[ii+1].scale.controller.Y_Scale.controller
						aa=((spn1.value-iii+1)/spn1.value)as string
						bb=(1-((spn1.value-iii+1)/spn1.value))as string
						ex2.setExpression ("[ 1,"+aa+"*A"+"+"+bb+"*C"+","+aa+"*B"+"+"+bb+"*D"+" ]")
					--	ex2.setExpression ("[ "+aa+"*E"+"+"+bb+"*FF"+","+aa+"*A"+"+"+bb+"*C"+","+aa+"*B"+"+"+bb+"*D"+" ]")
					)
					cs+=1
				)
		 		ex2= Scale_Expression ()
				bonee[bonee.count].scale.controller =ex2				
		 		ex2.AddScalarTarget "A" ctrl[ds].scale.controller.X_Scale.controller
		 		ex2.AddScalarTarget "B" ctrl[ds].scale.controller.Z_Scale.controller
				ex2.AddScalarTarget "C" ctrl[ds].scale.controller.Y_Scale.controller
				ex2.setExpression ("[ C,"+"A"+","+"B ]")
					
				r=Dummy pos:g[1].pos boxsize:[spn2.value*2.2,spn2.value*2.2,spn2.value*2.2]
				r.name=uniquename"Root"

				for i7 in ctrl do(
				attachobjects r i7 move:false	
				)			
	/*   		for i2=1 to bonee2.count do(
					bonee2[i2].parent=r	
				)  */			
				g[1].parent=r		
				
				if  (chk3.checked==true) do(
					for ii=1 to ctrl.count do (						
					if ii<ctrl.count then(
					bonee3[ii]=BoneSys.createBone ctrl[ii].pos ctrl[ii+1].pos [0,0,1]
					bonee3[ii].width = spn2.value*1.7
					bonee3[ii].height = spn2.value*1.7
					bonee3[ii].wirecolor = color 28 89 177
						if ii==1 then(
							g3[1]=bonee3[ii]
							)
					bonee3[ii].name=uniquename "FK"
					bonee3[ii].boxmode = on
					)else(
					bonee3[ii]=BoneSys.createBone ctrl[ii].pos (ctrl[ii].pos*1.1) bonee3[ctrl.count-1].dir  
					
					bonee3[ii].transform =bonee3[ctrl.count-1].transform
					in coordSys Local move bonee3[ii] [bonee3[ctrl.count-1].length,0,0]
						
					bonee3[ii].width = spn2.value*1.7
					bonee3[ii].height = spn2.value*1.7
					bonee3[ii].wirecolor = color 28 89 177
					bonee3[ii].taper= 90
					bonee3[ii].length= (bonee[ii].width+bonee3[ii].height)/2
					bonee3[ii].name=uniquename "FK"
					bonee3[ii].boxmode = on
					)
					if ii>1 then(						
					bonee3[ii].parent=bonee3[ii-1]  
					)	
					)
					g3[1].parent=r  
					
					for ii=1 to bonee3.count do(
						bonee3[ii].setSkinPose()
					)				
					
					for i8=1 to ctrl.count do(
					attachobjects bonee3[i8] ctrl[i8] move:false	
					)
				) 
				g[1].parent=ctrl[1]
				
				r.setSkinPose()
				for ii=1 to ctrl.count do(
					ctrl[ii].setSkinPose()
				)
				for ii in xnt1 do(
					deletekeys ii #allkeys   
				)
				)
				
				global tc1
				global tc2
				global tc3
				global tc4
				global tc5

				tt1 = layerManager.getLayerFromName"Help"  	
				if  tt1 ==undefined then (
				tc1=LayerManager.newLayerFromName "Help" 
				)else(
				tc1=LayerManager.getLayerFromName"Help"
				)
				
				tt2 = layerManager.getLayerFromName"Skinbone"  	
				if  tt2 ==undefined then (
				tc2=LayerManager.newLayerFromName "Skinbone" 
				)else(
				tc2=LayerManager.getLayerFromName"Skinbone"
				)

				tt3 = layerManager.getLayerFromName"Line"  	
				if  tt3 ==undefined then (
				tc3=LayerManager.newLayerFromName "Line" 
				)else(
				tc3=LayerManager.getLayerFromName"Line"
				)
				
				tt4 = layerManager.getLayerFromName"Ctrl"  	
				if  tt4 ==undefined then (
				tc4=LayerManager.newLayerFromName "Ctrl" 
				)else(
				tc4=LayerManager.getLayerFromName"Ctrl"
				)
				
				if  (chk3.checked==true) do(				
					tt5 = layerManager.getLayerFromName"FK"
					if tt5==undefined then (
					tc5=LayerManager.newLayerFromName"FK"
					)else(
					tc5=LayerManager.getLayerFromName"FK"
					)
				)
				
				for n in Points do tc1.addNode n
				for n in xnt1 do tc1.addNode n
				for n in $Line* do tc3.addNode n
				for n in bonee do tc2.addNode n				
				for n in Ctrl do tc4.addNode n
				for n in $Root* do tc4.addNode n	
				if  (chk3.checked==true) do(
				for n in $FK* do tc5.addNode n
				)
				tc1.on = false 	
				clearSelection()	
			)	
		)
	)
	on lianjie2 rightClick do(
	setClipBoardText "330875128"
	)
)
rollout rollout_wzys "位置约束" width:181 height:54
(
	button btn6 "位置约束" pos:[40,12] width:101 height:29  toolTip:"依次选择，将中间的物体位置约束给两端的物体" align:#left
	on btn6 pressed  do
(
	yswt=selection as array
    global sl=yswt.count
	if (sl<3) then(
		messagebox"至少选择3个物体"
		)else(
			for i=1 to sl-1 do(
				if i>1 then(
				yslb=position_list ()
				yswt[i].pos.controller = yslb
				wzys =Position_Constraint() 	
				yswt[i].pos.controller.Available.controller= wzys
				wzys.appendTarget yswt[1] (100-(((i-1.0)/(sl-1.0))*100))
				wzys.appendTarget yswt[sl] (((i-1.0)/(sl-1.0))*100)
				wzys.relative=true		
				yswt[i].pos.controller.Available.controller = Position_XYZ ()
				yslb.setActive 3	
				)
			)
		)
	)
)

createdialog rollout_title
AddSubRollout rollout_title.sub_broken SplineIK
AddSubRollout rollout_title.sub_broken rollout_wzys

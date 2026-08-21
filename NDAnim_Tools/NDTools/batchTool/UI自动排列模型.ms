try(destroyDialog form)catch()
rollout form "自动排列模型-myl" --窗体控件
(
  	group "参数设置："
  	(
	 	spinner tx1 "每行数量" range:[0,9999,5] type:#integer align:#left fieldwidth:50 tooltip:"每行模型数量" scale:1
	 	spinner tx2 "移动间距" range:[0,9999,10] type:#integer align:#left fieldwidth:50 tooltip:"模型排列距离" scale:1
	)
  	group "模型选取方式："
  	(
	  	RadioButtons RImport "" labels:#("自动全选", "手动选取") default:1 columns:2)
  	button btn "点击排列" width:80 height:20 across:2
  	button btn2 "随机打乱" width:80 height:20 --按钮控件
  	
  	fn distance_y a b = 
  	(
  		distance [0,a.y,0] [0,b.y,0]
  	)
  	on btn2 pressed do
  	(
  		gm = geometry as Array 
  		for i =1 to gm.count do 
  		(

  		)
	  	for a in geometry do (
	  		a.pos = [random -66 66,random -66 66,0]
	  	)
	) 
  	on btn pressed do
  	(
		
		/*全选模型坐标归零*/
		gm = undefined 
		if RImport.state == 1 do 
		(
			gm = geometry as Array
		)
		if RImport.state == 2 do 
		(
		   if Selection.count <= 1 then
		   (
		  		MessageBox ("未选中模型或仅选中一个模型,无法排列!\n请重新选取模型") title:"警告!" beep:false;return false
		   )else(
		   		gm = selection as Array 
		   )
		)
		if gm == undefined do return false 

		--for a in gm do a.pos = [x,y,z]
		/*将选中模型以固定间距沿XY轴移动*/
		
		row = ceil ((gm.count as float) / (tx1.value as float))
		index = 0 
		
		local max_y_all = #()
		local global_offset = 0 
		for i = 1 to row do
		(	
			--列
			max_y = #()
			row_offset_y = 0 
			if i > 1 do (
				temp_max_y = max_y_all[(i-1)]
				row_offset_y = amax temp_max_y
				global_offset += row_offset_y
			)

			for o = 1 to tx1.value do 
			(
				-- 行
				index += 1  -- 当前的 模型

				curr_mesh = gm[index]
				if not isValidNode curr_mesh do (return false)

				curr_mesh.transform = Matrix3 1 
				curr_meshBox = nodeLocalBoundingBox curr_mesh 
				
				max_y[o] = distance_y curr_meshBox[1] curr_meshBox[2] 

				curr_pos = curr_meshBox[1]
				curr_pos.x *= -1 
				curr_pos.y *= -1 
				curr_pos.z = 0
				curr_mesh.pos = curr_pos

				if o > 1 then
				(
					up_mesh = gm[(index - 1)] -- 这一行的第二个开始
					if isValidNode up_mesh do 
					(
						up_meshBox = nodeLocalBoundingBox up_mesh
						curr_pos = curr_mesh.pos 

						curr_pos.x += up_meshBox[2].x + tx2.value

						curr_mesh.pos = curr_pos
						format "% -> % \n" up_mesh.name curr_mesh.name
					)
				)
				curr_pos = curr_mesh.pos 
				curr_pos.y += global_offset + tx2.value
				curr_pos.z = 0
				curr_mesh.pos = curr_pos
				
			)
			append max_y_all max_y
		)
		/*取消选择*/
		--deselect geometry
	)
)
createdialog form 200 170
--将脚本自动添加到max自定义UI中
if getSourceFileName != undefined then
(
	str = "macroScript MyTools2 category:\"My Tools\" buttontext:\"自动排列模型\" tooltip:\"自动排列模型\"\n" \
	+ "(\n" \
	+ "    fileIn \"" + getSourceFileName() + "\"\n" \
	+ ")\n"
	execute str
)

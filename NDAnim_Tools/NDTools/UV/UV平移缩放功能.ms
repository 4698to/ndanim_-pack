rollout unnamedRollout "UV缩放工具，先点击创建box再和需要的模型合并，再选中物体情况下点击缩放uv" width:700 height:600
(
	button btn1 "第一步创建box" pos:[29,17] width:108 height:54
	button btn2 "uv缩小1/4并移到左上角" pos:[5,100] width:150 height:100
	button btn3 "uv缩小1/16移到左上角" pos:[5,200] width:150 height:100
	button btnX "X轴缩小1/2并移到左边" pos:[200,5] width:150 height:100
	button btnY "Y轴缩小1/2并移到下边" pos:[400,5] width:150 height:100
	button btnScaleX50 "X轴缩小50%" pos:[200,100] width:150 height:100
	button btnScaleX75 "X轴缩小75%" pos:[400,100] width:150 height:100
	button btnScaleY50 "Y轴缩小50%" pos:[200,200] width:150 height:100
	button btnScaleY75 "Y轴缩小75%" pos:[400,200] width:150 height:100
	button btnMove1XUp "X轴上移动0.1" pos:[400,300] width:150 height:100
	button btnMove1XDown "X轴下移动0.1" pos:[400,500] width:150 height:100
	button btnMove1YRight "Y轴左移动0.1" pos:[300,400] width:150 height:100
	button btnMove1YLeft "Y轴右移动0.1" pos:[500,400] width:150 height:100
	on btn1 pressed  do
		Box lengthsegs:1 widthsegs:1 heightsegs:1 length:2 width:2 height:2 mapcoords:on pos:[2,2,0] isSelected:on
	on btn2 pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 0.5 0.5 [0,0,0]
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [0,0.5,0]
		)
	on btn3 pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 0.25 0.25 [0,0,0]
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [0,0.25,0]
		)
	on btnX pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 0.5 1 [0,0,0]
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [0,0,0]
		)
	on btnY pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 1 0.5 [0,0,0]
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [0,0.5,0]
		)
	on btnScaleX50 pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 0.5 1 [0,0,0]
		)
	on btnScaleX75 pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 0.75 1 [0,0,0]
		)
		on btnScaleY50 pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 1 0.5 [0,0,0]
		)
	on btnScaleY75 pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 1 0.75 [0,0,0]
		)
	on btnMove1XUp pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [0,0.1,0]
		)
	on btnMove1XDown pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [0,-0.1,0]
		)
	on btnMove1YRight pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [-0.1,0,0]
		)
	on bbtnMove1YLeft pressed  do
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		macros.run "Modifier Stack" "SubObject_3"
		max select all
		$.modifiers[#unwrap_uvw].unwrap2.MoveSelected [0.1,0,0]
		)
	
)
createDialog unnamedRollout
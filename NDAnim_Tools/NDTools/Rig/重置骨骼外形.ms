/*
-- coding: utf-8 
-- @Date    : 2024-05-22 18:02:09
-- @Author  : 4698to (738746223@qq.com)
-- @Link    : sundaybox.cc
-- @Version : 
*/
try(destroyDialog ResetBonebaseobject)catch()

rollout ResetBonebaseobject	 "重置骨骼外形 -v.2" 
(	
	
	group "重置骨骼外形"
	(
		button Ret_bone "重置骨骼属性"  toolTip:"选中的Bone骨骼初始化" 
		label lab_01 "Bone骨骼转多边形之后还原"
	)	
	
	
	fn get_bone_box b = 
	(
		l_w_h = [0,0,0] 
		bbox = nodeGetBoundingBox b b.transform
		l_w_h.x = bbox[2].x 
		l_w_h.y = bbox[2].y - bbox[1].y
		l_w_h.z = bbox[2].z - bbox[1].z
		l_w_h
	)


	on Ret_bone pressed do
	(
		if selection.count ==0 then
		(
			messagebox "至少需要选择一节Bone" beep:false
		)
		else
		(   
			animate false 
			(
				origin_bone = boneSys.createBone [0,0,0] [5,0,0] [1,0,0]
				undo "bbbb" off(
					for i =1 to selection.count do
					(   
						b_l_w_h = get_bone_box selection[i]
						selection[i].baseobject = copy origin_bone.baseobject	
						selection[i].length = b_l_w_h.x 
						selection[i].height = b_l_w_h.y 
						selection[i].width = b_l_w_h.z 
						selection[i].sidefins=false
						selection[i].frontfin=false
						selection[i].backfin=false
					) 
				)
				delete origin_bone
			)
		)			
	)


		
)
createdialog ResetBonebaseobject 200 80 
	
	


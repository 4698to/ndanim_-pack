-- 738746223@qq.com
-- 99U : 199505

try(destroyDialog fast_copyAnimationController) catch()
rollout fast_copyAnimationController "快速复制动画(内存版本)"
(
  	button 		btn_copy "C"  pos:[39,8] width:23 across:4 height:23 tooltip:"复制 动画/POSE" Align:#left
	button 		btn_paste "P" pos:[69,8] width:23 height:23 tooltip:"粘帖 动画/POSE" Align:#center
	button 		btn_del "D" pos:[108,8] width:23 height:23 tooltip:"删除 复制的动画" Align:#right
	button 		btn_delAll "D+" pos:[138,8] width:23 height:23 tooltip:"删除 所有已复制的动画/POSE"
	

	dropDownList 	ddl_listAni "已复制的动画：（非CS物体）" pos:[8,40] width:186 height:41 items:#()
	checkbox  chek_prs_p "位置" across:3 
	checkbox  chek_prs_r "旋转"
	checkbox  chek_prs_s "缩放"
	local temp_prs_controller =#()
	local temp_names = #()
	local ddl_listAni_items = #()
	Function fn_invertMaskBitmap bitmapFileName_str bk_color =
	(
		try
		(
			local i_bitmap = openBitMap bitmapFileName_str;
			local invertBitmap = bitmap i_bitmap.width i_bitmap.height;

			for y in 0 to (i_bitmap.height - 1) do
			(
				for x in 0 to (i_bitmap.width - 1) do
				(
					local i_color = (getPixels i_bitmap [x,y] 1)[1];

					i_color = color (i_color.r as integer) (i_color.g as integer) (i_color.b as integer);
					if i_color == bk_color then setPixels invertBitmap [x,y] #(white);
					else setPixels invertBitmap [x,y] #(BLACK);
				)
			)
			return invertBitmap;
		)
		catch()
	)
	fn copyObjAniTracks =
	(
		temp_prs = #()
		temp_prs_nodename = #()
		for i in selection do
		(
			classtype = classof i.transform.controller
			if classtype == prs or classtype == Link_Constraint or classtype == transform_script do
			(
				append temp_prs (copy i.transform.controller)
				--append temp_prs (copy i.rotation.controller)

				--append temp_prs (copy i.transform.controller.Rotation.controller)

				append temp_prs_nodename i.name
			)

		)
		append temp_prs_controller temp_prs
		append temp_names temp_prs_nodename
	)
	on fast_copyAnimationController open do
	(
		local 	CopyPasteAni_Name = "CopyPasteAni";
		local 	CopyPasteAni_FilePath = (GetDir #maxRoot) + "Coo!ToolsData\\AnimatorTools\\" + CopyPasteAni_Name + "\\";

		if doesFileExist (CopyPasteAni_FilePath + "CopyPasteAni_Icon.bmp") do
		(
			local icon_bmp = openBitMap (CopyPasteAni_FilePath + "CopyPasteAni_Icon.bmp");
			local n = icon_bmp.width / 16;

			mask_bmp = fn_invertMaskBitmap (CopyPasteAni_FilePath + "CopyPasteAni_icon.bmp") white;
			btn_del.images = #(icon_bmp,mask_bmp,n,9,9,10,10);
			btn_copy.images = #(icon_bmp,mask_bmp,n,13,13,14,14);
			btn_paste.images = #(icon_bmp,mask_bmp,n,15,15,16,16);
			btn_delAll.images = #(icon_bmp,mask_bmp,n,11,11,12,12);
		)
		freeSceneBitmaps();
	)

	on btn_copy pressed do
	(
		copyObjAniTracks()
		if temp_prs_controller.count != 0 do
		(
			ddl_listAni_items = #()
			for i =1 to temp_names.count do
			(
				local item_str = ""

				item_str +="Anim_" + i as string +":"
				item_str += temp_names[i][1]
				if temp_names[i].count > 1 do (
					item_str += " --> "
					item_str += temp_names[i][(temp_names[i].count)]
				)
				append ddl_listAni_items item_str
			)
			ddl_listAni.items = ddl_listAni_items
			ddl_listAni.selection = ddl_listAni_items.count

		)

	)
	on btn_paste pressed do
	(
		if temp_prs_controller.count != 0 do
		(
			temp_controller = temp_prs_controller[ddl_listAni.selection]
			temp_name = temp_names[ddl_listAni.selection]
			undo "copy_anim" true (
    			for i in selection do
    			(
    				index = findItem temp_name i.name
    				if index > 0 do
    				(
    					if i.transform.controller.classid[1] == 8197 do (
	    					if chek_prs_p.state do (
	    						i.transform.controller[1].controller = copy (temp_controller[index][1].controller)
	    					)
	    					if chek_prs_r.state do (
								i.transform.controller[2].controller = copy (temp_controller[index][2].controller)
							)
							if chek_prs_s.state do (
								i.transform.controller[3].controller = copy (temp_controller[index][3].controller)
							)
						)
						if i.transform.controller.classid[1] == -2025855132 do 
						(
							i.transform.controller[1][1].controller = copy (temp_controller[index][1][1].controller)
							i.transform.controller[1][2].controller = copy (temp_controller[index][1][2].controller)
							i.transform.controller[1][3].controller = copy (temp_controller[index][1][3].controller)
						)
						--i.transform.controller = copy temp_controller[index]
    					--i.rotation.controller = copy temp_controller[index]
    					--i.transform.controller.Rotation.controller = copy (temp_controller[index])--.position.controller
    				)
    			)
            )
		)
	)
	on btn_del pressed do
	(
		if temp_prs_controller.count > 0 do
		(
			deleteItem temp_prs_controller ddl_listAni.selection
			deleteItem temp_names ddl_listAni.selection
			deleteItem ddl_listAni_items ddl_listAni.selection
			ddl_listAni.items = ddl_listAni_items

			if ddl_listAni_items.count > 0 do
			(
				ddl_listAni.selection = ddl_listAni_items.count
			)
		)
	)
	on btn_delAll pressed do
	(
		free temp_prs_controller
		temp_prs_controller = #()
		free temp_names
		temp_names =#()
		free ddl_listAni_items
		ddl_listAni_items = #()
		ddl_listAni.items = ddl_listAni_items
	)
)

createDialog fast_copyAnimationController 200 130



(
	
messagebox ("Thank you for using it.\n"+"This script is a demo version") title:"P_SkinWeightTool"
	
global P_WT_Rollout

try (destroydialog P_WT_Rollout) catch()	



	local OBJ, OBJ__, pre_ring,ttest
	
fn Dialog_modal text1 text2=
(
	theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" text2
	theobj.text =text1
	DialogResult = theObj.Showmodal()

	return theobj.InstanceName 
)

fn makeFiveCharacters inputString =
(
    case inputString.count of
    (
        0: inputString += "00000"
        1: inputString += "0000"
        2: inputString += "000"
        3: inputString += "00"
        4: inputString += "0"
		default: inputString = substring inputString 1 5
    )
    return inputString
)






rollout unnamedRollout3434 "Attach Skin Objects" width:152 height:72
(
	local mode=1
	local skinobj, bone_list
	Button 'btn1' "Select Skin Objects\n And press this button" pos:[16,9] width:120 height:48 align:#left
	on btn1 pressed do
	(
			max modify mode
			if $selection.count<=1 do (Messagebox "Select Only Skin Objects"; DestroyDialog unnamedRollout3434; return 0)
			for i in $selection do 
			(
			if i.modifiers[#Skin]==undefined do (Messagebox "Select Only Skin Objects"; DestroyDialog unnamedRollout3434; return 0)	
			)
			sele=selection as array
			new_sele=#()
			for i in sele do
			(
				ii=copy i
				select ii
				append new_sele ii
			)
			
			converttopoly new_sele[1]
			
			for i=2 to new_sele.count do
			(
				polyop.attach new_sele[1] new_sele[i]
			)
			
			ddd=new_sele[1]
			select ddd
			addmodifier ddd (Skin_Wrap())
			ddd.modifiers[#Skin_Wrap].meshlist=sele
			ddd.modifiers[#Skin_Wrap].falloff = 10
			ddd.modifiers[#Skin_Wrap].threshold = 0.01
			ddd.modifiers[#Skin_Wrap].weightAllVerts = on
			ddd.modifiers[#Skin_Wrap].engine = 0
			select ddd
			
		messagebox "Click To Convert To Skin" 
		DestroyDialog unnamedRollout3434
	)
)

rollout Advanced_Feature "Advanced_Feature" width:344 height:416
(
	local Ref_v=#()
	local Tar_v=#()
	
	fn findNearestVertex refVertices targetVertex =
	(
		closestDist = undefined 
		closestVertex = undefined 

		for refVertex in refVertices do
		(
			dist = distance (polyop.getvert OBJ__ refVertex) (polyop.getvert OBJ__ targetVertex)

			if closestDist == undefined or dist < closestDist do
			(
				closestDist = dist
				closestVertex = refVertex
			)
		)

		closestVertex
	)

	dotNetControl 'edtDescription' "System.Windows.Forms.Textbox" pos:[16,152] width:312 height:112 align:#left
	GroupBox 'grp1' "Copy Weights from Closest Vertices" pos:[8,8] width:328 height:264 align:#left
	
	button 'btn3' "Load From Selection" pos:[16,104] width:104 height:32 align:#left
	button 'btn5' "Load From Selection" pos:[152,104] width:104 height:32 align:#left
	label 'lbl5' "-->" pos:[128,56] width:16 height:16 align:#left
	button 'btn14' "Run" pos:[264,48] width:64 height:40 align:#left
	label 'lbl23' "0 vertices selected" pos:[24,56] width:88 height:32 align:#left
	GroupBox 'grp7' "Reference" pos:[16,32] width:104 height:64 align:#left
	GroupBox 'grp8' "Target" pos:[152,32] width:104 height:64 align:#left
	
	label 'lbl24' "0 vertices selected" pos:[160,56] width:88 height:32 align:#left
	on Advanced_Feature open do
	(
		edtDescription.text="When applied, it copies the weight of a selected vertex \nfrom nearby vertices. Useful for even weight distribution in thin cloth.\n"+
		" (Weight value of the [Target] group changes. [Ref] group does not change) (Vertices registered in the target are \nautomatically excluded from the reference.)\n"+
		" (The [distance] used as the reference is based on the distance visible on the screen at the current frame.)"
		
		edtDescription.ReadOnly = true
		edtDescription.Multiline = true
		edtDescription.WordWrap = true
		edtDescription.BackColor = (dotNetClass "System.Drawing.Color").Black
		edtDescription.ForeColor = (dotNetClass "System.Drawing.Color").White
		edtDescription.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").None
	)
	on btn3 pressed do
	(
		Ref_v=skinOps.getSelectedVertices OBJ 
		lbl23.text=(Ref_v.count as string) +" vertices selected"
	)
	on btn5 pressed do
	(
		Tar_v=skinOps.getSelectedVertices OBJ 
		lbl24.text=(Tar_v.count as string) +" vertices selected"
	)
	on btn14 pressed do
	(
		if (Ref_v==#()) or (Tar_v==#()) do (messageBox "Please select reference and target Vertices"; return false)
		
			
		if (classof OBJ__.baseobject) == Editable_Poly do MOD_poly=1
		for i=selection[1].modifiers.count to 1 by -1 do 
		(
			if classof (selection[1].modifiers[i])==skin do MOD_skin=selection[1].modifiers[i]
			if classof (selection[1].modifiers[i])==Edit_Poly do MOD_poly=selection[1].modifiers[i]
		)
		
		if MOD_poly==false then (messagebox "This feature can only be used when Edit poly or Editable poly is active..")
		
		Ref_vv = #() 
		for vertexID in Ref_v do
		(	if findItem Tar_v vertexID == 0 do append Ref_vv vertexID	)
		if Ref_vv.count==0 do return false
			undo on (
		for targetVertex in Tar_v do
		(
			closestRefVertex = findNearestVertex Ref_vv targetVertex
			skinOps.SelectVertices OBJ closestRefVertex
			skinOps.copyWeights OBJ
			skinOps.SelectVertices OBJ targetVertex			
			skinOps.pasteWeights OBJ
		)
		)
	)
)


rcmenu MyRCmenu
(
	menuItem m1 "--" enabled:false
	menuItem m2 "--" enabled:false
	menuItem m3 "--" enabled:false
	menuItem m4 "--" enabled:false
	menuItem m5 "--" enabled:false
	menuItem m6 "--" enabled:false
	menuItem m7 "--" enabled:false
	menuItem m8 "--" enabled:false
	menuItem m9 "--" enabled:false
	menuItem m10 "--" enabled:false
   
   on MyRCmenu open do 
   (
	   OBJ=selection[1].modifiers[Skin]
	   m1.text="--"
	   m2.text="--"
	   m3.text="--"
	   m4.text="--"
	   m5.text="--"
	   m6.text="--"
	   m7.text="--"
	   m8.text="--"
	   m9.text="--"
	   m10.text="--"
		ab=skinOps.GetBoneNode OBJ (skinOps.GetSelectedBone OBJ)
		ab_children=#()
		for i in (skinOps.GetBoneNodes OBJ) do 
		(
			for ii in ab.children do 
			(
				if i.name==ii.name do 
				(
					appendIfUnique ab_children i
				)
			)
		)
		
		local reversedArray = #()

		for i = ab_children.count to 1 by -1 do
		(
			append reversedArray ab_children[i]
		)
		ab_children=reversedArray
		
	   try(
	   m1.text=ab_children[1].name; m1.enabled=true
	   m2.text=ab_children[2].name; m2.enabled=true
	   m3.text=ab_children[3].name; m3.enabled=true
	   m4.text=ab_children[4].name; m4.enabled=true
	   m5.text=ab_children[5].name; m5.enabled=true
	   m6.text=ab_children[6].name; m6.enabled=true
	   m7.text=ab_children[7].name; m7.enabled=true
	   m8.text=ab_children[8].name; m8.enabled=true
	   m9.text=ab_children[9].name; m9.enabled=true
	   m10.text=ab_children[10].name; m10.enabled=true
	   )catch()
   )
	on m1 picked do
		(skinOps.SelectBone OBJ m1.text)
	on m2 picked do
		(skinOps.SelectBone OBJ m2.text)
	on m3 picked do
		(skinOps.SelectBone OBJ m3.text)
	on m4 picked do
		(skinOps.SelectBone OBJ m4.text)
	on m5 picked do
		(skinOps.SelectBone OBJ m5.text)
	on m6 picked do
		(skinOps.SelectBone OBJ m6.text)
	on m7 picked do
		(skinOps.SelectBone OBJ m7.text)
	on m8 picked do
		(skinOps.SelectBone OBJ m8.text)
	on m9 picked do
		(skinOps.SelectBone OBJ m9.text)
	on m10 picked do
		(skinOps.SelectBone OBJ m10.text)
)


	rollout ttest "Edit Curve" width:200 height:88
	(
			
		button 'btn3' "Reset" pos:[136,8] width:56 height:24 align:#left
		button 'btn4' "Close" pos:[136,40] width:56 height:40 align:#left
		spinner 'spn2' "" pos:[48,8] width:75 height:16 range:[0,100,1] scale:0.01 align:#left
		spinner 'spn3' "" pos:[48,32] width:75 height:16 range:[0.001,10,0.001] scale:0.01 align:#left
		spinner 'spn4' "" pos:[48,56] width:75 height:16 range:[0.001,10,0.001] scale:0.01 align:#left
		label 'lbl1' "Value" pos:[8,8] width:32 height:16 align:#left
		label 'lbl2' "Pinch" pos:[8,32] width:32 height:16 align:#left
		label 'lbl3' "Bubble" pos:[8,56] width:32 height:16 align:#left


		fn changedvalue=
			(
				for i = 1 to skin_vert_arr.count do (
				tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i]

				a__ = distance tar_ viewpoint_xy
				b__ = distance tar_ lastpoint_xy

				weight = 1.0 - a__ / distance__
					
					
					
				a=spn2.value
				b=spn3.value
				x=weight
				x=(1 - exp(b * x)) / (1 - exp(b))
				b=spn4.value
				curve_value=(1 - exp(-b * x)) / (1 - exp(-b))
					curve_value=curve_value*a
				if curve_value<0 do curve_value=0
				skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (curve_value+skin_vert_arr[i][2])
				
			)
			)
		
		
		fn changedvalue_circle=
			(
				--skinOps.bakeSelectedVerts skin_
				for i = 1 to skin_vert_arr.count do
					(
						
						tar_ =( closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i])
						a=spn2.value
						b=spn3.value
						x=tar_
						x=(1 - exp(b * x)) / (1 - exp(b))
						b=spn4.value
						curve_value=(1 - exp(-b * x)) / (1 - exp(-b))
							curve_value=curve_value*a
							--curve_value=10
						skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (curve_value+skin_vert_arr[i][2])
					)
			)
			
		on ttest close do
		(
			
			   _mode = undefined
			   bone_ = undefined
			   skin_vert_arr = undefined
			   skin_vert_screen_arr = undefined
			   lastpoint_xy = undefined
			   viewpoint_xy = undefined
			   distance__ = undefined
			   closestPointOnLine2D = undefined
			   GW_displayObjectNames = undefined
			   get_verts_screen_position = undefined
			if (skinOps.isWeightToolOpen skin_)==false and open__==true do (skinOps.WeightTool skin_)
			   open__ = undefined
			   skin_ = undefined
		
		)
		on btn3 pressed do
		(
			spn2.value=1
			spn3.value=0.001
			spn4.value=0.001
			if _mode==#circle then (changedvalue_circle())
			else (changedvalue())
		)
		on btn4 pressed do
		(
			DestroyDialog ttest
			
		)
		on spn2 changed arg do
		(
			if _mode==#circle then (changedvalue_circle())
			else (changedvalue())
		)
		on spn3 changed arg do
		(
			if _mode==#circle then (changedvalue_circle())
			else (changedvalue())
		)
		on spn4 changed arg do
		(
			if _mode==#circle then (changedvalue_circle())
			else (changedvalue())
		)
	)
rollout P_WT_Rollout "P_SkinWeight Tool" width:184 height:784
(
	local SelectedVertex
	local SelectedBone
	local arr, arr2, arr3
	local last_vert_weight
	local save_vertices
	local sld_before_arg
	local objectsExceptBones = #()
	
	
	function select_bones mode_:false=
(
	global lastpoint_xyz
	tool objPick
	(
		local OBJ=$.modifiers[#Skin]
		local selectedObjects, objectPositions, currentObjectIndex
		local before_viewport
		local bonesArray, boneName, node
		local mode__=mode_
		
		fn getSkinBones  =
		(
			bonesArray = #()
			for i=1 to (skinOps.GetNumberBones ($selection[1].modifiers[#Skin])) do 
			(
				boneName = skinOps.GetBoneName ($selection[1].modifiers[#Skin]) i 1
				node = getNodeByName boneName
				append bonesArray node
			)
			return bonesArray
		)
		
		fn gwDrawText o=
		(	
			
			objCenter = o.center

			objName = o.name

			gw.setTransform (matrix3 1)
			textPos = [objCenter.x, objCenter.y, objCenter.z]
			text_color=(color 255 255 255)
			gw.wText  lastpoint_xyz objName size:10 color:text_color 

		)
		
		fn cbDrawBBox =
		(
			gwDrawText selectedObjects[currentObjectIndex] 
			
			gw.enlargeUpdateRect #whole
		)
		fn MouseTransform =
		(
			local ray = mapScreenToWorldRay mouse.pos
			local transformMatrix= matrixFromNormal ray.dir
			transformMatrix.pos = ray.pos
			transformMatrix
		)
		fn Select_Object =
		(
			transformMatrix = MouseTransform ()
			
			arrDist = for p in objectPositions collect (p * inverse transformMatrix)
			arrDist = for p in arrDist collect length (p * [1,1,0])
			currentObjectIndex = finditem arrDist (amin arrDist)
			for i=1 to (skinOps.GetNumberBones OBJ) do
			(
				if (skinOps.GetBoneName OBJ i 1) == selectedObjects[currentObjectIndex].name do (skinOps.SelectBone OBJ i; exit)
			)
			
			redrawviews()
		)
		

		on freeMove do
		(
			lastpoint_xyz=[viewPoint.x+30, viewPoint.y+30, 0]
			Select_Object ()
		)
		
		on mousePoint arg do if arg == 2 do
		(
			#stop
		)
		
		on start do
		(
			lastpoint_xyz=[0, 0, 0]
			before_viewport=#(viewport.GetRenderLevel(),viewport.GetShowEdgeFaces(),subobjectlevel,displayColor.shaded )
			if mode__==true do 
			(
			viewport.SetRenderLevel #flat
			viewport.SetShowEdgeFaces false
			subobjectlevel=1
			--displayColor.shaded =#object
			)
			bonesArray = #()
			for i=1 to (skinOps.GetNumberBones (OBJ)) do 
			(
				boneName = skinOps.GetBoneName (OBJ) i 1
				node = getNodeByName boneName
				append bonesArray node
			)
			
			selectedObjects = bonesArray
			objectPositions = for o in selectedObjects collect
			(
				 o.center
			)
			Select_Object ()
			registerRedrawViewsCallback cbDrawBBox
			redrawviews ()
		)
		
		on stop do
		(
			try(
			if mode__==true do 
			(
			viewport.SetRenderLevel before_viewport[1]
			viewport.SetShowEdgeFaces  before_viewport[2]
			subobjectlevel= before_viewport[3]
			displayColor.shaded =before_viewport[4]
			)
			
			unregisterRedrawViewsCallback cbDrawBBox
			lastpoint_xyz=undefined
			)
			catch()
			redrawviews ()
		)
	)
	
	if ((skinOps.GetNumberBones (selection[1].modifiers[skin]))!=0) do
	(
		stopTool objPick
		startTool objPick
	)

)
	fn check_editpoly=
	(
		if skinOps.GetSelectedBone OBJ==0 do return false
		if (classof OBJ__.baseobject) == Editable_Poly do return true
		
		MOD_poly=false
		MOD_skin=false
		
		for i=1 to OBJ__.modifiers.count do 
		(
			if classof (OBJ__.modifiers[i])==skin do MOD_skin=i
			if (classof (OBJ__.modifiers[i])==Edit_Poly) do MOD_poly=i
		)
		
		if MOD_poly==false or (MOD_poly<MOD_skin)do( (messagebox "This feature can only be used when the skin modifier is on top of an Edit Poly or an Editable Poly"); return false)
		return true
	)
	
	fn compareNestedArrays arr1 arr2 =
	(
		if (arr1 as string)==(arr2 as string) do return true
		return false
		/*
		if arr1.count != arr2.count then return false

		for i = 1 to arr1.count do
		(
			if isKindOf arr1[i] Array and not compareNestedArrays arr1[i] arr2[i] or
			   not isKindOf arr1[i] Array and arr1[i] != arr2[i] do return false
		)
		return true*/
	)
		
	fn mergeUniqueArrays arr1 arr2 =
	(
		f = false
		for i in arr1 do for ii in arr2 where i == ii do (f = true; exit)
		if f do
		(
			arr = #()
			for i in arr1 do appendIfUnique arr i
			for i in arr2 do appendIfUnique arr i
			return arr
		)
		false
	)


	fn splitIntersection arr =
	(
		for aa=1 to 20 do 
		(
			arr2=arr
			for i = 1 to arr.count do 
			(
				for ii = i + 1 to arr.count do
				(
					a = (mergeUniqueArrays arr[i] arr[ii])
					if a != false do (arr[i] = a; arr[ii] = #();)
				)
			)
			arr=  for subArr in arr where subArr.count != 0 collect subArr
			if ((arr as string)==(arr2 as string)) == true do (return arr)
		)
	)

	
	
	function draw_feature mode__:#line=
	(
	skinOps.bakeSelectedVerts $.modifiers[skin]


	global skin_=$.modifiers[skin]
	global open__=false
	global _mode=mode__

	global bone_=skinOps.GetSelectedBone skin_
	global skin_vert_arr=#()
	global skin_vert_screen_arr=#()
	global lastpoint_xy=[0,0,0]
	global viewpoint_xy=[0,0,0]
	global distance__=0

	global closestPointOnLine2D
	global GW_displayObjectNames
	global get_verts_screen_position	
		
	fn closestPointOnLine2D a b c = 
	(
		c=[c.x,c.y,0]
		AB = b - a
		AC = c - a
		if _mode==#circle do
		(   
		ab_length = length ab
			ac_length = length ac
			if (ac_length>ab_length) do return 0
			return (1-(ac_length / ab_length))
		)
		dot_product = dot AB AC
		AB_length = length AB
		distance_ = abs(dot_product) / AB_length
		x_perp = a.x + (b.x - a.x) * dot_product / (AB_length * AB_length)
		y_perp = a.y + (b.y - a.y) * dot_product / (AB_length * AB_length)
		[x_perp, y_perp]
	)


	fn calculatePointA point1 point2 =
	(
		midPoint = (point1 + point2) / 2.0
		
		directionVector = point2 - point1
		
		pointA = midPoint + directionVector * 0.25
		
		pointA
	)




	 fn GW_displayObjectNames=
	   (
										completeredraw()
										gw.settransform(viewport.gettm())
											
									   -- gw.wtext [viewpoint_xy[1]+20,viewpoint_xy[2]+20,0] "testafsf" color:yellow
										gw.setColor #line red
										gw.wPolyline #( viewpoint_xy,  lastpoint_xy) true
										gw.enlargeUpdateRect #whole
										gw.updatescreen()
	   )

	function get_verts_screen_position=
	(
		gw.setTransform(Matrix3 1)
		for i in skin_vert_arr do
		(
			viewPosW = gw.wTransPoint $.verts[i[1]].pos
			append skin_vert_screen_arr [viewPosW[1],viewPosW[2]]
		)
	)
	 tool AssignSkinVertexWeightTool2
					(
						
						on mousePoint clickno do (                 
													
										if clickno > 1 then 
											(    unregisterRedrawViewsCallback GW_displayObjectNames; 
												
												
												return  #stop  )   
							viewpoint_xy=[viewPoint.x,viewPoint.y,0]
							get_verts_screen_position()
							
						)
						on mouseAbort clickno do (
							unregisterRedrawViewsCallback GW_displayObjectNames;  
							
							return  #stop  
						)
					   on mouseMove clickno do 
						(
						   if _mode==#Circle then
						   (
									lastpoint_xy = [viewPoint.x, viewPoint.y, 0]
									distance__ = distance viewpoint_xy lastpoint_xy
									for i = 1 to skin_vert_arr.count do
									(
										tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i]
										skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (tar_+skin_vert_arr[i][2])
									)
							)
						   else 
							(
								lastpoint_xy = [viewPoint.x, viewPoint.y, 0]
								distance__ = distance viewpoint_xy lastpoint_xy

								for i = 1 to skin_vert_arr.count do (
								tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i]

								a__ = distance tar_ viewpoint_xy
								b__ = distance tar_ lastpoint_xy

								weight = 1.0 - a__ / distance__
								if weight<0 do weight=0
								skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (weight+skin_vert_arr[i][2])
								)
							)
						)
							on stop do
							(
								CreateDialog ttest  200 88 (mouse.screenpos.x-170) (mouse.screenpos.y-10)
							)
					)


			skin_vert_arr=#()
			skin_vert_screen_arr=#()
				for i=1 to (skinOps.GetNumberVertices skin_) do
				(
					a=skinOps.isVertexSelected skin_  i
					if a==true do (
						vv=0
								for ii=1 to (skinOps.GetVertexWeightCount skin_ i) do 
								(
									if 	((skinOps.GetVertexWeightBoneID skin_ i ii)==bone_) do 
									(
										vv=(skinOps.GetVertexWeight skin_ i ii )
									)
								)
						append skin_vert_arr [i,vv]
						)
				)
				if skin_vert_arr.count==0 do (messageBox "Select Vertices!"; return false)
				if (skinOps.isWeightToolOpen skin_)==true do (open__=true; skinOps.closeWeightTool skin_)
				get_verts_screen_position()
				unregisterRedrawViewsCallback GW_displayObjectNames;  
				registerRedrawViewsCallback GW_displayObjectNames  
										
				startTool AssignSkinVertexWeightTool2 prompt:"Set Vertex Weight"
							
	)
	
	
	
	fn hide_fn type vertices unselect:false=
	(
		if skinOps.GetSelectedBone OBJ==0 do return false
		
		MOD_poly=false
		MOD_skin=false
		
		for i=1 to OBJ__.modifiers.count do 
		(
			if classof (OBJ__.modifiers[i])==skin do MOD_skin=i
			if (classof (OBJ__.modifiers[i])==Edit_Poly) do MOD_poly=i
		)
		if MOD_poly==false or (MOD_poly<MOD_skin) then
		( 
			if (classof OBJ__.baseobject) == Editable_Poly then MOD_poly=1
			else ((messagebox "This feature can only be used when the skin modifier is on top of an Edit Poly or an Editable Poly"); return false)
		) 
		else (MOD_poly=OBJ__.modifiers[MOD_poly];MOD_skin=OBJ__.modifiers[MOD_skin];)
				
		if type==#unhide and MOD_poly!=1 do (MOD_poly.ButtonOp #UnhideAllFace; MOD_poly.ButtonOp #UnhideAllVertex; return true)
		if type==#unhide and MOD_poly==1 do (OBJ__.baseobject.unhideAll #Face; OBJ__.baseobject.unhideAll #Vertex; return true)
		
		if MOD_poly==1 and type==#face do  
			(
				if unselect==true do 
				(
					numVerts=polyOp.getNumVerts OBJ__.baseobject
					allVerts = #{1..numVerts}
					vertices = allVerts - (vertices as BitArray)
				)
				polyop.setHiddenFaces OBJ__.baseobject (polyop.getFacesUsingVert OBJ__.baseobject vertices); return true
			)
		if MOD_poly==1 and type==#vertices do  
			(
				if unselect==true do 
				(
					numVerts=polyOp.getNumVerts OBJ__.baseobject
					allVerts = #{1..numVerts}
					vertices = allVerts - (vertices as BitArray)
				)
				(polyop.setHiddenVerts OBJ__.baseobject vertices); return true
			)
		
		modPanel.setCurrentObject MOD_poly
		subobjectLevel = 1
		if type==#vertices do  ((MOD_poly.SetSelection #Vertex #{}); MOD_poly.Select #Vertex (vertices as BitArray); if unselect==true do (max select invert); MOD_poly.ButtonOp #HideVertex)
		if type==#face do ((MOD_poly.SetSelection #Vertex #{}); MOD_poly.Select #Vertex (vertices as BitArray);
											MOD_poly.ConvertSelection #Vertex #Face; subobjectLevel = 4; if unselect==true do (max select invert);MOD_poly.ButtonOp #HideFace)
		subobjectLevel = 0
		modPanel.setCurrentObject MOD_skin
		subobjectLevel =	1
	)
	
	function find_next_ring direction:true=
	(
			if (check_editpoly ()==false) do return false
			try(
				M = OBJ
				skin_=M
					
				arr=skinOps.getSelectedVertices M 
				arrj=skinOps.getSelectedVertices M 
					
				skinOps.growSelection M
				arr2=skinOps.getSelectedVertices M 

				arr3=#()
				for val in arr do
				(
					if findItem arr2 val == 0 do
					(
						append arr3 val
					)
				)

				for val in arr2 do
				(
					if findItem arr val == 0 do
					(
						append arr3 val
					)
				)

				skinOps.SelectVertices M arr3

				Varr=#()
				for i in arr3 do 
				(
					skinOps.SelectVertices M i
					skinOps.growSelection M
					arr4=skinOps.getSelectedVertices M
					
					b_arr=#()
					for val in arr4 do
					(
						if findItem arr3 val != 0 do
						(
							append b_arr val
						)
					)
					append Varr (b_arr)
				)
				result=splitIntersection Varr
				
				arr3_island1=result[1]
				arr3_island2=result[2]
				a=direction
					if pre_ring==undefined then
					(
						if a==true then
							(skinOps.SelectVertices M arr3_island1; pre_ring=#(arrj,false))
						else 
							(skinOps.SelectVertices M arr3_island2; pre_ring=#(arrj,true))
					)
					else
					(
						resultA= ((sort pre_ring[1] as string)==(sort arr3_island1 as string))
						resultB= ((sort pre_ring[1] as string)==(sort arr3_island2 as string))
							if a==pre_ring[2] and (resultA==true or resultB==true) then 
							(
								skinOps.SelectVertices M pre_ring[1];  pre_ring=#(arrj,not a)
							)
							else
							(
								resultA= ((sort pre_ring[1] as string)==(sort arr3_island1 as string))
								if resultA==true then 
									(
										(skinOps.SelectVertices M arr3_island2; pre_ring=#(arrj,not a))
									)
								else
									(
										(skinOps.SelectVertices M arr3_island1; pre_ring=#(arrj,not a))
									)
							)
					)
				)catch()
	)
	
	function select_element=
	(
		for i=1 to 20 do 
			(
				A = ((skinOps.getSelectedVertices OBJ))
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				B = ((skinOps.getSelectedVertices OBJ) as array)
				if A.count==B.count do (exit)
			)
	)
	button 'b_grow' "+" pos:[48,96] width:40 height:32 toolTip:"RightClick : Select Element" align:#left
	button 'b_shrink' "-" pos:[8,96] width:40 height:32 toolTip:"RightClick : Deselect All" align:#left 
 
	button 'b_Loop' "Loop" pos:[136,96] width:40 height:32 toolTip:"RightClick : Select Element" align:#left 
 
	button 'b_next' "в╕" pos:[96,64] width:40 height:32 toolTip:"Next Ring" align:#left 
 
	button 'b_previous' "в║" pos:[136,64] width:40 height:32 toolTip:"Previous Ring" align:#left 
 
	button 'b_Ring' "Ring" pos:[96,96] width:40 height:32 toolTip:"RightClick : Select Element" align:#left 
 
	button 'b_Load' "Element" pos:[48,64] width:40 height:32 toolTip:"Load Vertices Selection" iconName:":/CommandPanel/Motion/BipedRollout/MotionFlow/LoadFile" align:#left

	button 'b_parent' "Parent" pos:[64,24] width:40 height:32 toolTip:"Select Parent Bone" align:#left 
	button 'b_child' "Child" pos:[104,24] width:40 height:32 toolTip:"Select Child Bone" align:#left 
	button 'b_mirror' "Mirror" pos:[144,24] width:32 height:32 toolTip:"Select Mirror Bone" iconName:":/CommandPanel/Motion/BipedRollout/Mirror" iconSize:[20,20] align:#left 
	button 'b_save' "Save" pos:[8,64] width:40 height:32 toolTip:"Save Vertices Selection" iconName:":/CommandPanel/Motion/BipedRollout/MotionMixer/BatchSave" align:#left
	button 'b_selectBones' "SelectBone" pos:[8,24] width:56 height:32 toolTip:"Select Bone\nRightclick : Select Mode" align:#left iconName:":/MainUI/SelectInvert"
	
	
	button 'b_DrawLine' "Draw Line" pos:[16,416] width:72 height:32 align:#left
	button 'b_DrawCircle' "Draw Circle" pos:[96,416] width:72 height:32 align:#left
	button 'b_Hammer' "Hammer" pos:[16,448] width:72 height:32 toolTip:"Rightclick : Hammer x 5" align:#left 
 
	button 'b_Average' "Average" pos:[96,448] width:56 height:32 align:#left
	listbox 'lbx_1' "" pos:[16,296] width:152 height:8 align:#left
	button 'b_0' "0" pos:[8,136] width:24 height:24 align:#left
	button 'b_1' ".1" pos:[32,136] width:24 height:24 align:#left
	button 'b_25' ".25" pos:[56,136] width:24 height:24 align:#left
	button 'b_5' ".5" pos:[80,136] width:24 height:24 align:#left
	button 'b_75' ".75" pos:[104,136] width:24 height:24 align:#left
	button 'b_9' ".9" pos:[128,136] width:24 height:24 align:#left
	button 'b_100' "1" pos:[152,136] width:24 height:24 align:#left
	button 'b_Set_Weight' "Set Weight" pos:[8,160] width:48 height:32 align:#left
	button 'b_Scale_Weight' "Scale Weight" pos:[8,192] width:48 height:32 align:#left
	button 'b_Copy' "Copy" pos:[8,264] width:40 height:24 align:#left
	button 'b_Paste' "Paste" pos:[48,264] width:40 height:24 align:#left
	button 'b_PastePos' "PastePos" pos:[88,264] width:48 height:24 align:#left
	button 'b_Blend' "Blend" pos:[136,264] width:40 height:24 align:#left
	spinner 'spn_weight' "" pos:[60,164] width:48 height:16 range:[0,0.5,1] type:#float scale:0.05 align:#left
	spinner 'spn_scale' "" pos:[60,196] width:48 height:16 range:[0.001,0.95,5] type:#float scale:0.05 align:#left
	button 'b_Plus' "+" pos:[112,160] width:32 height:32 align:#left
	button 'b_Minus' "-" pos:[144,160] width:32 height:32 align:#left
	button 'b_plus2' "+" pos:[112,192] width:32 height:32 align:#left
	button 'b_minus2' "-" pos:[144,192] width:32 height:32 align:#left
	slider 'sld1' "" pos:[8,224] width:178 height:25 range:[-1,1,0] align:#left

	Timer 'SecTme' "Tme" pos:[168,600] width:24 height:24 interval:100 align:#left 

	button 'b_vertex' "Vert" pos:[16,608] width:32 height:32 iconName:"Common\\Vertex" iconSize:[20,20] align:#left
	button 'b_face' "Face" pos:[56,608] width:32 height:32 iconName:"Common\\Face" iconSize:[20,20] align:#left
	button 'b_element' "Elem" pos:[96,608] width:32 height:32 iconName:"Common/Element" iconSize:[20,20] align:#left
	button 'b_unhide' "Unhide" pos:[136,608] width:32 height:32 iconName:":/EditUVW/UnhideAll" iconSize:[20,20] align:#left
	button 'b_objcolor' "ObjColor" pos:[16,568] width:72 height:32 align:#left
	button 'b_mtlcolor' "MtlColor" pos:[96,568] width:72 height:32 align:#left
	button 'b_CustomSet' "Turn off Cross Sections" pos:[16,536] width:152 height:24 align:#left 
 
	button 'bones_list_Add' "+" pos:[8,704] width:40 height:24 align:#left
	button 'bones_list_remove' "-" pos:[48,704] width:40 height:24 align:#left
	button 'bones_Change' "Change" pos:[8,736] width:56 height:40 align:#left
	button 'bones_pick_Add' "+" pos:[96,704] width:40 height:24 align:#left
	button 'bones_pick_remove' "-" pos:[136,704] width:40 height:24 align:#left
	label 'lb_List' "List" pos:[44,688] width:32 height:16 align:#left
	label 'lb_Pick' "Pick" pos:[120,688] width:32 height:16 align:#left
	button 'b_Removezero' "Remove Zero Bone" pos:[120,736] width:56 height:40 align:#left
	button 'b_skinattach' "Skin Attach" pos:[64,736] width:56 height:40 align:#left
	button 'b_Advanced' "Advanced Feature" pos:[16,488] width:152 height:24 align:#left
 
 
	label 'lbl3' "---------- Select + Weight----------" pos:[8,8] width:184 height:16 align:#left
	label 'lbl5' "---------- Display ----------" pos:[32,520] width:128 height:16 align:#left
	label 'lbl7' "---------- Bones ----------" pos:[32,672] width:120 height:16 align:#left
	label 'lbl55' "Hide Selection (Rclick:Unselection)" pos:[8,648] width:168 height:16 align:#left

	
	button 'btn146' "в╕" pos:[152,448] width:16 height:16 align:#left
	button 'btn147' "в║" pos:[152,464] width:16 height:16 align:#left
	

	fn All_Button_able mode=
	(
		if mode==false then 
		(
			if b_grow.enabled==false do return true
		    for ctrl in P_WT_Rollout.controls do
			(
					ctrl.enabled = false 
			)
		)
		else if b_grow.enabled==false then 
		(
		    for ctrl in P_WT_Rollout.controls do
			(
					ctrl.enabled = true 
			)
		)
	)
	
	on P_WT_Rollout open do
	(
		try(
		OBJ=selection[1].modifiers[Skin]
		OBJ__=selection[1]
		spn_weight.value=OBJ.weightTool_weight
		spn_scale.value=OBJ.weightTool_scale)catch()
		SelectedVertex=#()
		SelectedBone=undefined
		arr=#()
		sld_before_arg=0
	)
	on P_WT_Rollout close do 
	(
		P_WT_Rollout=undefined
	)
	
	on lbl5 pressed do 
	(
		print P_WT_Rollout.height
	)
	
	on lbl7 pressed do 
	(
		
	)
	on b_grow pressed do
	(
		undo on 
		(skinOps.growSelection OBJ)
	)
	on b_grow rightClick do
	(
		undo on 
		(select_element())
	)
	on b_shrink pressed do
	(
		undo on 
		(skinOps.shrinkSelection OBJ)
	)
	on b_shrink rightClick do
	(
		undo on 
		(actionMan.executeAction 0 "40043" )
	)
	on b_Loop pressed do
	(
		undo on 
		(skinOps.loopSelection OBJ)
	)
	on b_Loop rightClick do
	(
		undo on 
		(select_element())
	)
	on b_next pressed do
	(
		undo on
		(
			find_next_ring()
		)
	)
	on b_previous pressed do
	(
		undo on
		(
			find_next_ring direction:false
		)
	)
	on b_Ring pressed do
	(
		undo on 
		(skinOps.ringSelection OBJ)
	)
	on b_Ring rightClick do
	(
		undo on 
		(select_element())
	)
	on b_Load pressed do
	(
		if (save_vertices!=undefined) do 
			(
			undo on 
				(
					skinOps.SelectVertices OBJ save_vertices
				)
			)
	)
	on b_SelectBones pressed do 
	(
		select_bones()
	)
	on b_SelectBones rightclick do 
	(
		select_bones mode_:true
	)
	on b_parent pressed do
	(
		if skinOps.GetSelectedBone OBJ==0 do return false
		skinOps.selectParent OBJ
	)
	on b_child pressed do
	(
		if skinOps.GetSelectedBone OBJ==0 do return false
		a=skinOps.GetBoneNode OBJ (skinOps.GetSelectedBone OBJ)
		a_children=#()
		for i in (skinOps.GetBoneNodes OBJ) do 
		(
			for ii in a.children do 
			(
				if i.name==ii.name do 
				(
					appendIfUnique a_children i
				)
			)
		)
		if a_children.count>1 do 
		(
		   PopupMenu MyRcmenu 
	   )
	   if a_children.count==1 do skinOps.SelectBone OBJ (a_children[1].name)
	)
	on b_mirror pressed do
	(
		if skinOps.GetSelectedBone OBJ==0 do return false
		rf=OBJ.ref_frame
		currentFrame = sliderTime
		disableSceneRedraw()
		sliderTime = rf
		arr=skinOps.GetBoneNodes OBJ
		now_name=skinops.GetBoneName OBJ (skinOps.GetSelectedBone OBJ) 1
		matching_nodes=undefined
			
			p1=#("Left","L_","_L"," L ","L)","L]","L-")
			p2=#("Right","R_","_R"," R ","R)","R]","R-")
			
		for i = 1 to p1.count do
		(
			if findString now_name p1[i] != undefined do
			(
				a=substituteString now_name p1[i] p2[i]
				matching_nodes = for node in arr where node.name == a collect node
			)
			if findString now_name p2[i] != undefined do
			(
				a=substituteString now_name p2[i] p1[i]
				matching_nodes = for node in arr where node.name == a collect node
			)
		)
		if matching_nodes!=undefined do 
			(
				sliderTime=currentFrame
				enableSceneRedraw()
				CompleteRedraw()
				skinOps.selectBoneByNode OBJ matching_nodes[1]; 
				return true
			)
		arr = skinOps.GetBoneNodes OBJ
		now_ = skinOps.GetBoneNode OBJ (skinOps.GetSelectedBone OBJ)
		
		closestBone=undefined
		closestDistance = 9999999
		for i in arr do
		(
			myCoord = i.boundingBox.center
			target = [(selection[1].pos.x) -  myCoord.x, myCoord.y, myCoord.z] 
			
			local distance_ = distance now_.boundingBox.center target
			if distance_ < closestDistance then
			(
				closestDistance = distance_
				closestBone = i
			)
		)
		if closestBone != undefined then skinOps.selectBoneByNode OBJ closestBone
		sliderTime=currentFrame
		enableSceneRedraw()
		CompleteRedraw()
	)
	on b_save pressed do
	(
		save_vertices=skinOps.getSelectedVertices OBJ
	)
	on b_DrawLine pressed do
	(
			draw_feature()
	)
	on b_DrawCircle pressed do
	(
			draw_feature mode__:#circle
	)
	on b_Hammer pressed do
	(
		skinOps.bakeSelectedVerts OBJ
		(
			if selection.count == 1 do
			(
				numskinverts=skinOps.GetNumberVertices OBJ
				skinvertarr=#()
				undo on
				(
					for i= 1 to numskinverts do
					(
						if (skinOps.IsVertexSelected OBJ i)==1 do append skinvertarr i
					)
					skinOps.Hammer OBJ skinvertarr
				)
			)
		)
	)
	on b_Hammer rightClick do
	(
		skinOps.bakeSelectedVerts OBJ
		(
			if selection.count == 1 do
			(
				numskinverts=skinOps.GetNumberVertices OBJ
				skinvertarr=#()
				undo on
				(
					for ii=1 to 5 do 
					(
						for i= 1 to numskinverts do
						(
							if (skinOps.IsVertexSelected OBJ i)==1 do append skinvertarr i
						)
						skinOps.Hammer OBJ skinvertarr
					)
				)
			)
		)
	)

	on b_Average pressed do
	(
		M=OBJ
		Mvert_arr=#()
		for i=1 to (skinOps.GetNumberVertices M) do
		(	a=skinOps.isVertexSelected M  i
			if a==true do (	append Mvert_arr i )
		)

		arr=#()
		for i in Mvert_arr do 
		(	a=skinOps.GetVertexWeightCount M i
			for ii=1 to a do 
			(	append arr #((skinOps.GetVertexWeightBoneID M i ii),(skinOps.GetVertexWeight M i ii)))
		)

		index_=#()
		for ii in arr do 
		(		check_=false
				for iii=1 to index_.count do 
				(	if index_[iii][1]==ii[1] do check_=iii	)
				if check_==false do
				(	append index_ ii	)
				if check_!=false do 
				(	index_[check_][2]=index_[check_][2]+ii[2]	)
		)
		for i in index_ do 
		(	i[2]=(i[2]/Mvert_arr.count) )
		newarr1 = #()
		newarr2 = #()

		for subArr in index_ do
		(	if subArr[2]!=0 do 
			(
			append newarr1 subArr[1]

			append newarr2 subArr[2]
			)
		)
		skinOps.bakeSelectedVerts M

		for i in Mvert_arr do 
		(
			skinOps.SetVertexWeights M i newarr1 newarr2
		)
	)
	on lbx_1 selected arg do
	(
		arr_=lbx_1.selection
		skinOps.SelectBone obj arr[lbx_1.selection]
	)
	on b_0 pressed do
	(
		skinOps.setWeight OBJ 0
	)
	on b_1 pressed do
	(
		skinOps.setWeight OBJ 0.1
	)
	on b_25 pressed do
	(
		skinOps.setWeight OBJ 0.25
	)
	on b_5 pressed do
	(
		skinOps.setWeight OBJ 0.5
	)
	on b_75 pressed do
	(
		skinOps.setWeight OBJ 0.75
	)
	on b_9 pressed do
	(
		skinOps.setWeight OBJ 0.9
	)
	on b_100 pressed do
	(
		skinOps.setWeight OBJ 1
	)
	on b_Set_Weight pressed do
	(
		skinOps.setWeight OBJ (OBJ.weightTool_weight )
	)
	on b_Scale_Weight pressed do
	(
		skinOps.scaleWeight OBJ (OBJ.weightTool_scale )
	)
	on b_Copy pressed do
	(
		skinOps.copyWeights OBJ
	)
	on b_Paste pressed do
	(
		skinOps.pasteWeights OBJ
	)
	on b_PastePos pressed do
	(
		skinOps.pasteWeightsByPos OBJ (OBJ.weightTool_tolerance)
	)
	on b_PastePos rightClick do
	(
		val=Dialog_modal  ("Set Paste-Pos Tolerance") ((OBJ.weightTool_tolerance) as string)
		try(val=val as float) catch()
		if (isKindOf val float)==true do (OBJ.weightTool_tolerance=val)
	)
	on b_Blend pressed do
	(
		skinOps.blendSelected OBJ
	)
	on b_Plus pressed do
	(
		skinOps.addWeight OBJ 0.05
	)
	on b_Minus pressed do
	(
		skinOps.addWeight OBJ -0.05
	)
	on b_plus2 pressed do
	(
		skinOps.scaleWeight OBJ 1.05
	)
	on b_minus2 pressed do
	(
		skinOps.scaleWeight OBJ 0.95
	)
	on sld1 changed arg do
	(  
			undo off
		(
		val=arg-sld_before_arg
		skinOps.AddWeight OBJ val
		sld_before_arg=arg
		)
	)
	on sld1 buttondown do
	(
		skinOps.bakeSelectedVerts OBJ
	)
	on sld1 buttonup do
	(
		sld1.value=0
		sld_before_arg=0
		setFocus P_WT_Rollout
	)
	on sld1 rightClick do
	(
		a=(GetDialogPos P_WT_Rollout)+[192/2,385]
		
		local pos = dotNetObject "System.Drawing.Point" (a.x+3) (a.y-110)
		(dotNetClass "System.Windows.Forms.Cursor").Position = pos
	)
	on SecTme tick do
	(
		if  classof(modpanel.getCurrentObject())!=skin then (All_Button_able false; return false)
		else (All_Button_able true)
		if selection[1]!=OBJ__ do (OBJ__=selection[1]; OBJ=modpanel.getCurrentObject();)
			
		local newVertices = ((skinOps.getSelectedVertices OBJ) as array)
		local newBone = (skinOps.GetSelectedBone OBJ)
		local check_bone_change=false
		local arraysEqual = true
			
		if newBone!=SelectedBone do 
			(
				SelectedBone=newBone
				check_bone_change=true
			)
			
		
		if SelectedVertex.count != newVertices.count then
		(
			arraysEqual = false
		)
		else
		(
			
			for i = 1 to SelectedVertex.count do
			(
				if SelectedVertex[i] != newVertices[i] do
				(
					arraysEqual = false
					exit
				)
			)
			
			if newVertices.count !=0 do 
			(
				try (vert_weight=(skinOps.GetVertexWeight obj (newVertices[1]) 1)) catch(vert_weight=#(0))
				if vert_weight!=last_vert_weight do
				(
					last_vert_weight=vert_weight
					arraysEqual = false
				)
			)
		)
		
		
		
		if not arraysEqual do
		(
			
			SelectedVertex = newVertices 
			a= skinOps.getSelectedVertices OBJ
			arr=#()
			for ii in a do 
			(
				for i=1 to (skinOps.GetVertexWeightCount obj ii) do 
				(
					appendIfUnique arr (skinOps.GetVertexWeightBoneID obj ii i)
				)
			)
			newArr = #()
			
			local iii=1
			for i in arr do
			(
				if i==0 do exit
				local weight
				try
				(
					weight = (skinOps.GetVertexWeight obj SelectedVertex[1] iii) as string
					weight=makeFiveCharacters weight
				)
				catch
				(
					weight = "-------"
				)
				local boneName = skinOps.GetBoneName obj i 1
				append newArr ((weight as string) + " : " + boneName)
				iii+=1
			)
	
			lbx_1.items =newArr
			
			lbx_1.selection=0
			for i=1 to arr.count do (if arr[i]==newBone do (lbx_1.selection=i; exit))
			
			check_bone_change=false
		)
		
		if check_bone_change==true do 
		(
			lbx_1.selection=0
			for i=1 to arr.count do (if arr[i]==newBone do (lbx_1.selection=i; exit))
		)
	)
	on b_vertex pressed do
	(
		undo on 
		(
		hide_fn #vertices (skinOps.getSelectedVertices OBJ)
		enableSceneRedraw()
		skinOps.SelectVertices OBJ #{}
		)
	)
	on b_vertex rightClick do
	(
		undo on 
		(
		v=(skinOps.getSelectedVertices OBJ)
		hide_fn #vertices v unselect:true
		skinOps.SelectVertices OBJ v
		enableSceneRedraw()
		redrawViews()
		)
	)
	on b_face pressed do
	(
		undo on 
		(
		hide_fn #face (skinOps.getSelectedVertices OBJ)
		enableSceneRedraw()
		skinOps.SelectVertices OBJ #{}
		)
	)
	on b_face rightClick do
	(
		undo on 
		(
		v=(skinOps.getSelectedVertices OBJ)
		skinOps.growSelection OBJ
		hide_fn #face (skinOps.getSelectedVertices OBJ) unselect:true
		skinOps.SelectVertices OBJ v
		enableSceneRedraw()
		redrawViews()
		)
	)
	on b_element pressed do
	(
		undo on 
		(
			for i=1 to 20 do 
			(
				A = ((skinOps.getSelectedVertices OBJ))
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				B = ((skinOps.getSelectedVertices OBJ) as array)
				if A.count==B.count do (exit)
			)
			hide_fn #face (skinOps.getSelectedVertices OBJ)
			enableSceneRedraw()
			skinOps.SelectVertices OBJ #{}
		)
	)
	on b_element rightClick do
	(
		undo on 
		(
			old = ((skinOps.getSelectedVertices OBJ) as array)
			for i=1 to 20 do 
			(
				A = ((skinOps.getSelectedVertices OBJ) as array)
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				skinOps.growSelection OBJ
				B = ((skinOps.getSelectedVertices OBJ) as array)
				if A.count==B.count do (exit)
			)
			hide_fn #face (skinOps.getSelectedVertices OBJ) unselect:true
			enableSceneRedraw()
			skinOps.SelectVertices OBJ old
		)
	)
	on b_unhide pressed do
	(
		undo on 
		(
		hide_fn #unhide 1
		enableSceneRedraw()
		)
	)
	on b_unhide rightclick do
	(
		undo on 
		(
		hide_fn #unhide 1
		enableSceneRedraw()
		)
	)
	on b_objcolor pressed do
	(
		displayColor.shaded = #object
	)
	on b_mtlcolor pressed do
	(
		displayColor.shaded = #material
	)
	on b_CustomSet pressed do
	(
		if b_CustomSet.text=="Turn off Cross Sections" then
		(
		OBJ.showNoEnvelopes = on
		OBJ.filter_cross_sections = off
		b_CustomSet.text="Turn on Cross Sections" 
		)
		else 
		(
		OBJ.showNoEnvelopes = off
		OBJ.filter_cross_sections = on
		b_CustomSet.text="Turn off Cross Sections" 
		)
	)
	on bones_list_Add pressed do
	(
		objectsExceptBones = for obj2 in objects where findItem (skinOps.GetBoneNodes OBJ) obj2 == -1 and obj2 != OBJ collect obj2
		fn shape_filt obj3 = findItem objectsExceptBones obj3 != -1
		theShapes = selectByName title:"Add Bone" filter:shape_filt single:false
		if theShapes==undefined do return false
		for i=1 to (theShapes.count) do 
		(
			skinOps.addbone  OBJ theShapes[i] -1
		)
	)
	on bones_list_remove pressed do
	(
		macros.run "Skin Modifier" "multiRemove"
	)
	on bones_Change pressed do
	(
		if skinOps.GetSelectedBone OBJ==0 do return false
		now_bone=(skinOps.GetBoneName OBJ (skinOps.GetSelectedBone OBJ) 1)
		messagebox "This feature does not support UNDO. Please use with caution."
		text___="["+now_bone+"]     (currently selected bone)\n"+
		"   бщ бщ бщ бщ бщ бщ бщ \n[another bone you select next] \n\n(The replacement bone can be either a registered bone or an unregistered one)\n\n"+
		"Continue?"
		if (queryBox text___)==false do return false
		
		fn shape_filt obj3 = (obj3 != OBJ__ and obj3 != (skinOps.GetBoneNode OBJ (skinOps.GetSelectedBone OBJ)))
		To_Object = selectByName title:"To : " filter:shape_filt single:true showHidden:true
		if To_Object!=undefined do 
			(
				next_bone=To_Object.name
				final_text="Delete bone ["+now_bone+"] and transfer its weights to bone ["+next_bone+"].\nProceed?"
				if (queryBox final_text)==false do return false
				undo on (skinOps.replaceBone OBJ (skinOps.GetSelectedBone OBJ) To_Object)
			)
	)
	on bones_pick_Add pressed do
	(
		rollout Add_Bone "Add Bone(Pick)" width:152 height:72
		(
			local bone_list
			Button 'btn1' "Select bone\n And press this button" pos:[16,9] width:120 height:48 align:#left
			on btn1 pressed do
			(
					destroydialog Add_Bone
			)
			on Add_Bone close do 
			(
				OBJ__.xray = off
				unfreeze OBJ__
				bone_list=selection as array
				select OBJ__
				max modify mode
				subObjectLevel= 1
				if bone_list.count==0 do (destroydialog Add_Bone; 
					return 0)
				for i in bone_list do
					(
					skinOps.addbone (OBJ) i -1
					)
			)
		)
		OBJ__.xray = on
		freeze OBJ__
		deselect OBJ__
		macros.run "Selection" "SmartSelect"
		createdialog Add_Bone
	)
	on bones_pick_remove pressed do
	(	
		arr=(skinOps.GetBoneNodes OBJ)
		if arr.count==0 do return false
			max create mode
		arr2=#()
		arr3=#()
		for obj in arr do
		(
			isHidden2 = obj.isHidden;     isFrozen2 = obj.isFrozen
			append arr2 #(obj, isHidden2, isFrozen2)
			append arr3 #(obj.layer, obj.layer.ishidden)
		)
		if (IsolateSelection.IsolateSelectionModeActive()==true) do
		(IsolateSelection.ExitIsolateSelectionMode())
		select arr
		IsolateSelection.EnterIsolateSelectionMode()
		for i in arr do 
		(
			i.isHidden=false; i.isFrozen=false
		)
		select arr
		IsolateSelection.ExitIsolateSelectionMode()
		IsolateSelection.EnterIsolateSelectionMode()
		deselect $
		
		rollout Remove_Bone "Remove_Bone(Pick)" width:208 height:112
		(
			button 'btn1' "Select all bones to remove, then press this button." pos:[16,16] width:176 height:80 align:#left
			
			on btn1 pressed do 
			(
				old_select = for obj in selection collect obj
				
				if selection.count!=0 do deselect $
				for i=1 to arr2.count  do
				(
					arr2[i][1].ishidden=arr2[i][2]
					arr2[i][1].isfrozen=arr2[i][3]
				)
				for i in arr3 do 
				(
					i[1].ishidden=i[2]
				)
				IsolateSelection.ExitIsolateSelectionMode()
				select OBJ__
				max modify mode
				subObjectLevel= 1
				if old_select.count!=0 do 
				(
					for ii=1 to old_select.count do 
					(
						for i=1 to (skinOps.GetNumberBones OBJ ) do 
						(
							if (skinOps.GetBoneName OBJ i 1) == old_select[ii].name do 
								(
									try(skinOps.removebone OBJ i)catch(print "fail")
									exit
								)
						)
					)
				)
				DestroyDialog Remove_Bone
			)
			on Remove_Bone close do 
			(
				if selection.count!=0 do deselect $
				for i=1 to arr2.count  do
				(
					arr2[i][1].ishidden=arr2[i][2]
					arr2[i][1].isfrozen=arr2[i][3]
				)
				for i in arr3 do 
				(
					i[1].ishidden=i[2]
				)
				IsolateSelection.ExitIsolateSelectionMode()
				select OBJ__
				max modify mode
				subObjectLevel= 1
			)
		)
		macros.run "Selection" "SmartSelect"
		CreateDialog Remove_Bone
	)
	on b_Removezero pressed do
	(
		messagebox "This feature does not support UNDO. Please use with caution."
		if (queryBox "Do you want to continue removing all bones that do not have a weight value assigned to any vertex?")==true do 
			(skinOps.removeUnusedBones OBJ)
	)
	on b_skinattach pressed do
	(
		CreateDialog unnamedRollout3434
		max create mode
	)
	on b_Advanced pressed do
	(
		CreateDialog Advanced_Feature
	)
	on btn146 pressed do
	(
		undo on
		(
			find_next_ring()
		)
	)
	on btn147 pressed do
	(
		undo on
		(
			find_next_ring direction:false
		)
	)
	
    on P_WT_Rollout resized pt do 
    (
        P_WT_Rollout.width = 184
    )
)
	if selection.count==0 or (selection[1].modifiers[Skin]==undefined )then ()
	 (CreateDialog P_WT_Rollout  style:#(#style_resizing,#style_titlebar, #style_border, #style_sysmenu)) 
		
/*
	local MOD_poly=false
	local MOD_skin=false
	
	else 
	(
		if (classof selection[1].baseobject) == Editable_Poly do MOD_poly=1
		for i=selection[1].modifiers.count to 1 by -1 do 
		(
			if classof (selection[1].modifiers[i])==skin do MOD_skin=selection[1].modifiers[i]
			if classof (selection[1].modifiers[i])==Edit_Poly do MOD_poly=selection[1].modifiers[i]
		)
		
		if MOD_poly==false then (messagebox "This feature can only be used when Edit poly or Editable poly is active..")
	)

*/
)


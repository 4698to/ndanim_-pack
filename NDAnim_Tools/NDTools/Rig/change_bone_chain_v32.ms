--https://gitee.com/to4698/ND_tools/tree/master/XX_NDtools
--738746223@qq.com
-- 2021.2.11
try(destroyDialog create_bone_chain)catch()

global create_bone_chainFloater
global ND_BoneChainController

rollout create_bone_chain_tools "其他工具" width:200 height:150
(
	label lab_01 "仅对Bone有效,锁定解锁选中的Bone"
	group "锁定曲线" (
		button btn_lockedTracks_p "锁位置" width:65 height:25 across:3
		button btn_lockedTracks_r "锁旋转" width:65 height:25
		button btn_lockedTracks_s "锁缩放" width:65 height:25
	)
	group "解锁曲线" (
		button btn_unlockedTracks_p "解位置" width:65 height:25 across:3
		button btn_unlockedTracks_r "解旋转" width:65 height:25
		button btn_unlockedTracks_s "解缩放" width:65 height:25
	)
	fn lockedTracksMan_anim pt types is_locked = (
		if types == 0 and pt.position.controller.classid[1] == 8209 do for i = 2 to 4 do (
			local objtm_anim = pt.position.controller[i]
			if objtm_anim.controller == undefined do objtm_anim.controller = bezier_float()
			lockedTracksMan.setLocks is_locked #(objtm_anim) #(pt) 1 true
		)
		if types == 1 do lockedTracksMan.setLocks is_locked #(pt.position.controller) #(pt) 1 true
		if types == 2 do lockedTracksMan.setLocks is_locked #(pt.rotation.controller) #(pt) 1 true
		if types == 3 do lockedTracksMan.setLocks is_locked #(pt.scale.controller) #(pt) 1 true
	)
	fn setSelectedLocks types is_locked = for obj in selection where obj.classid[1] == 683634317 do lockedTracksMan_anim obj types is_locked
	on btn_lockedTracks_p pressed do setSelectedLocks 1 true
	on btn_lockedTracks_r pressed do setSelectedLocks 2 true
	on btn_lockedTracks_s pressed do setSelectedLocks 3 true
	on btn_unlockedTracks_p pressed do setSelectedLocks 1 false
	on btn_unlockedTracks_r pressed do setSelectedLocks 2 false
	on btn_unlockedTracks_s pressed do setSelectedLocks 3 false
)

rollout create_bone_chain_info "统计信息" width:200 height:150
(
	label lab_01 "等待移除的：？" across:2
	label lab_02 "新增：？"
	button btn_get_remove_bones "统计" width:35 height:25
	button btn_get_remove "选择待移除骨骼" width:100 height:25 across:2
	button btn_get_new "选择新增骨骼" width:100 height:25
	button btn_dele_all_remove "删除所有待删骨骼" width:200 height:25
	button btn_remove_new_name "删除新增骨骼命名前缀" width:200 height:25
	local remove_list = #()
	local meger_list = #()
	local new_chai_list = #()
	fn get_bones_change = (
		remove_list=#(); meger_list=#(); new_chai_list=#()
		for obj in objects do (
			if matchPattern obj.name pattern:"Remove_*" do append remove_list obj
			if matchPattern obj.name pattern:"MergeBone_*" do append meger_list obj
			if matchPattern obj.name pattern:"NewChai_*" do append new_chai_list obj
		)
		lab_01.text="等待移除的："+(remove_list.count as string)
		lab_02.text="新增："+((new_chai_list.count+meger_list.count) as string)
	)
	fn replace_obj_name obj replace_name = (obj.name=(dotNetObject "System.String" obj.name).replace replace_name "")
	on btn_get_remove_bones pressed do get_bones_change()
	on btn_get_remove pressed do (get_bones_change(); select remove_list)
	on btn_get_new pressed do (get_bones_change(); select meger_list; selectmore new_chai_list)
	on btn_dele_all_remove pressed do (
		get_bones_change()
		if queryBox ("是否确定删除所有待删骨骼？共"+(remove_list.count as string)+" 根") beep:false do try(undo "remove_all_list" on delete remove_list)catch()
	)
	on btn_remove_new_name pressed do (
		get_bones_change()
		undo "new_bone_names" on (
			for obj in meger_list do replace_obj_name obj "MergeBone_"
			for obj in new_chai_list do replace_obj_name obj "NewChai_"
			messageBox ("共修改 "+((meger_list.count+new_chai_list.count) as string)+"个骨骼的命名,注意检查是否有 Bone 重名")
		)
	)
)

struct ND_BoneChainController_v1 (
	floater=undefined, model=undefined, faces=undefined, bones=#(), debugShapes=#(), endpointSectionPlanes=#(), interventionPlanes=#(), previewControlIndices=#(), previewIntervention=false, previewProfiles=#(), previewFractions=#(), previewProfileFractions=#(), previewStartRatio=0.1, previewEndRatio=0.9, ratioSyncing=false, previewMode=1, previewChainCount=8, previewSpreadAlongV=true, previewAxisLength=1.0, previewBoneSize=0.01, previewBoneName="Bone_", sectionDebugMaterial=undefined, updating=false, modelPreviewActive=false, reconstructPreviewActive=false, reconstructSource=#(), reconstructMatrices=#(), reconstructLength=0.0, reconstructParent=undefined, reconstructWidth=0.0, reconstructHeight=0.0, reconstructStartName="",
	fn setSource sourceModel sourceFaces = 
	(
		this.model=sourceModel; this.faces=copy sourceFaces; 
		true
	),
	fn beginUpdate = 
	(
		_is_ok = false 
		if this.updating or this.model==undefined or this.faces==undefined or not isValidNode this.model then( 
			_is_ok = false 
		)else (this.updating=true; _is_ok = true)
		_is_ok
	),
	fn clearPreview =
	(
		for node in this.bones where isValidNode node do delete node
		for node in this.debugShapes where isValidNode node do delete node
		this.bones=#()
		this.debugShapes=#()
		this.endpointSectionPlanes=#()
		this.interventionPlanes=#()
		this.previewControlIndices=#()
		this.previewIntervention=false
		this.previewProfiles=#()
		this.previewFractions=#()
		this.previewProfileFractions=#()
		this.modelPreviewActive=false
		true
	),
	fn finishUpdate newBones = 
	(
		if classof newBones == Array then (this.bones = newBones) else (this.bones = #());
		this.updating =false;
		true
	),
	fn cancelUpdate = (this.updating=false; false),
	fn get_model_selected_faces model_node = (
		if not (isKindOf model_node.baseObject Editable_Poly) do (return undefined)
		local _faces=#{1..(polyOp.getNumFaces model_node)}
		local currentSubObjectLevel=subObjectLevel
		if currentSubObjectLevel==undefined do return _faces
		if currentSubObjectLevel<=0 do return _faces
		case currentSubObjectLevel of (
			1: _faces=polyOp.getFacesUsingVert model_node (polyOp.getVertSelection model_node)
			2: _faces=polyOp.getFacesUsingEdge model_node (polyOp.getEdgeSelection model_node)
			3: _faces=polyOp.getFacesUsingEdge model_node (polyOp.getBorderSelection model_node)
			4: _faces=polyOp.getFaceSelection model_node
			5: _faces=polyOp.getElementsUsingFace model_node (polyOp.getFaceSelection model_node)
			default: _faces=polyOp.getFaceSelection model_node
		)
		_faces
	),
	fn make_selected_faces_mesh model_node selected_faces = (
		if selected_faces==undefined or selected_faces.numberSet==0 do (return undefined)
		local vertex_map = for i=1 to (polyOp.getNumVerts model_node) collect 0; 
		local _verts=#(); local _faces=#()
		for fi in selected_faces do (
			local remapped=#()
			for vi in (polyOp.getFaceVerts model_node fi) do (
				if vertex_map[vi]==0 do (
					append _verts (polyOp.getVert model_node vi);
					vertex_map[vi]= _verts.count
				); 
				append remapped vertex_map[vi]
			)
			for i=2 to remapped.count-1 do (append _faces [remapped[1],remapped[i],remapped[i+1]])
		)
		if _faces.count==0 do (return undefined)
		local subset=mesh vertices:_verts faces:_faces; 
		subset.transform=model_node.transform
		#(subset,for v in _verts collect (v*model_node.transform),_faces)
	),
	fn get_skirt_axis_basis model_node vertices = (
		local mean=[0,0,0]; for p in vertices do mean+=p; mean/=vertices.count
		local axis=normalize model_node.transform.row3
		if length axis<0.0001 do return undefined
		local bv=model_node.transform.row1-axis*(dot model_node.transform.row1 axis)
		if length bv<0.0001 do (
			local ref=if abs(dot axis [0,1,0])>0.95 then [1,0,0] else [0,1,0]
			bv=cross axis ref
		)
		bv=normalize bv
		local bw=normalize(cross axis bv)
		if dot bw model_node.transform.row2<0 do (bv=-bv; bw=-bw)
		#(mean,axis,bv,bw)
	),
	fn get_main_axis_basis vertices = (
		local mean=[0,0,0]; for p in vertices do mean+=p; mean/=vertices.count
		local xx=0.0; local yy=0.0; local zz=0.0; local xy=0.0; local xz=0.0; local yz=0.0
		for p in vertices do (local d=p-mean; xx+=d.x*d.x; yy+=d.y*d.y; zz+=d.z*d.z; xy+=d.x*d.y; xz+=d.x*d.z; yz+=d.y*d.z)
		local start=[0,0,0]; local maxSq=0.0
		for p in vertices do (local d=p-mean; local ds=dot d d; if ds>maxSq do (maxSq=ds; start=d))
		if maxSq<=0.000001 do return undefined
		local axis=normalize start
		for i=1 to 32 do (local n=[xx*axis.x+xy*axis.y+xz*axis.z,xy*axis.x+yy*axis.y+yz*axis.z,xz*axis.x+yz*axis.y+zz*axis.z]; if length n>0.0001 do axis=normalize n)
		if axis.z<0 or (abs axis.z<0.05 and axis.x<0) do axis=-axis
		local ref=[0,0,1]; if abs(dot axis ref)>0.95 do ref=[0,1,0]
		local v=normalize(cross axis ref); #(mean,axis,v,normalize(cross axis v))
	),
	fn get_slice_profile projected_vertices triangle_faces planePoint planeNormal frameV frameW = (
		local points=#()
		for face in triangle_faces do for e=1 to 3 do (
			local n=if e==3 then 1 else e+1
			local p1=projected_vertices[face[e] as integer]
			local p2=projected_vertices[face[n] as integer]
			local d1=dot (p1-planePoint) planeNormal
			local d2=dot (p2-planePoint) planeNormal
			if abs d1<0.0001 and abs d2<0.0001 then (
				append points #(dot (p1-planePoint) frameV,dot (p1-planePoint) frameW)
				append points #(dot (p2-planePoint) frameV,dot (p2-planePoint) frameW)
			) else if ((d1<=0 and d2>=0) or (d1>=0 and d2<=0)) and abs(d1-d2)>0.0001 do (
				local hit=p1+(p2-p1)*(d1/(d1-d2))
				append points #(dot (hit-planePoint) frameV,dot (hit-planePoint) frameW)
			)
		)
		if points.count==0 do return undefined
		local minv=points[1][1]; local maxv=minv; local minw=points[1][2]; local maxw=minw
		for p in points do (minv=amin #(minv,p[1]); maxv=amax #(maxv,p[1]); minw=amin #(minw,p[2]); maxw=amax #(maxw,p[2]))
		#((minv+maxv)*0.5,(minw+maxw)*0.5,(maxv-minv)*0.5,(maxw-minw)*0.5,points)
	),
	fn get_profile_major_axis profile frameV frameW = (
		if profile==undefined or profile[5].count<3 do return undefined
		local centerX=0.0; local centerY=0.0
		for p in profile[5] do (centerX+=p[1]; centerY+=p[2])
		centerX/=profile[5].count; centerY/=profile[5].count
		local xx=0.0; local yy=0.0; local xy=0.0
		for p in profile[5] do (
			local x=p[1]-centerX; local y=p[2]-centerY
			xx+=x*x; yy+=y*y; xy+=x*y
		)
		local anisotropy=sqrt((xx-yy)^2+(2.0*xy)^2)
		if anisotropy<amax #((xx+yy)*0.05,0.0001) do return undefined
		local angle=0.5*(atan2 (2.0*xy) (xx-yy))
		local axis=frameV*(cos angle)+frameW*(sin angle)
		if length axis>0.0001 then normalize axis else undefined
	),
	fn create_chains_from_profiles profiles mode chainCount spreadAlongV size namePrefix fractions = (
		local all=#()
		if mode!=1 and profiles.count>0 do (
			local totalV=0.0; local totalW=0.0
			for profile in profiles do (totalV+=profile[6]; totalW+=profile[7])
			spreadAlongV=(totalV>=totalW)
		)
		for c=1 to chainCount do (
			local angle=(c-1)*360.0/chainCount
			local joints=#()
			local tag=if mode==1 then "Skirt_" else "Ribbon_"
			local radialDirection=undefined
			if mode==1 then (
				joints=this.get_skirt_chain_points profiles angle
				local mid=profiles[(ceil (profiles.count/2.0)) as integer]
				radialDirection=normalize(mid[2]*(cos angle)+mid[3]*(sin angle))
			) else (
				local offsetRatio=if chainCount==1 then 0.0 else -0.7+1.4*((c-1) as float)/(chainCount-1)
				joints=this.get_ribbon_chain_points profiles offsetRatio spreadAlongV
			)
			joints=this.resample_points_by_arc_length joints fractions
			if mode!=1 do (
				if this.previewIntervention and this.previewProfileFractions.count==profiles.count then (
					radialDirection=#()
					for fraction in fractions do (
						local profileFraction=this.previewProfileFractions[1]+fraction*(this.previewProfileFractions[this.previewProfileFractions.count]-this.previewProfileFractions[1])
						local profileSegment=profiles.count-1
						for p=1 to this.previewProfileFractions.count-1 where profileFraction<=this.previewProfileFractions[p+1] do (profileSegment=p; exit)
						local startFraction=this.previewProfileFractions[profileSegment]
						local endFraction=this.previewProfileFractions[profileSegment+1]
						local t=if endFraction-startFraction>0.0001 then ((profileFraction-startFraction)/(endFraction-startFraction)) else 0.0
						local startDirection=if spreadAlongV then profiles[profileSegment][2] else profiles[profileSegment][3]
						local endDirection=if spreadAlongV then profiles[profileSegment+1][2] else profiles[profileSegment+1][3]
						local sectionDirection=startDirection*(1.0-t)+endDirection*t
						local startNormal=profiles[profileSegment][9]
						local endNormal=profiles[profileSegment+1][9]
						local sectionNormal=startNormal*(1.0-t)+endNormal*t
						if length sectionDirection>0.0001 and length sectionNormal>0.0001 then (
							append radialDirection (normalize(normalize sectionDirection*0.75+normalize sectionNormal*0.25))
						) else append radialDirection (if length sectionDirection>0.0001 then normalize sectionDirection else sectionNormal)
					)
				) else (
					local midIndex=(ceil (joints.count/2.0)) as integer
					local midProfile=profiles[(ceil (profiles.count/2.0)) as integer]
					radialDirection=joints[midIndex]-midProfile[1]
					if length radialDirection<0.0001 do radialDirection=if spreadAlongV then midProfile[2] else midProfile[3]
				)
			)
			local chainBones=this.create_model_chain joints size (namePrefix+tag+(c as string)) radialDirection
			for bone in chainBones do append all bone
		)
		all
	),
	fn applyEndpointPlaneToProfile profile sectionPlane = (
		local oldWidth=amax #(profile[6],0.0001); local oldLength=amax #(profile[7],0.0001)
		local widthScale=length sectionPlane.transform.row1
		local lengthScale=length sectionPlane.transform.row2
		local row1=normalize sectionPlane.transform.row1
		local row2=normalize sectionPlane.transform.row2
		local row3=normalize sectionPlane.transform.row3
		local newWidth=amax #(sectionPlane.width*widthScale*0.5,0.001)
		local newLength=amax #(sectionPlane.length*lengthScale*0.5,0.001)
		local contour=#()
		if profile[8]!=undefined do for point in profile[8] do append contour #(point[1]*(newWidth/oldWidth),point[2]*(newLength/oldLength))
		profile[1]=sectionPlane.transform.pos
		profile[2]=row1
		profile[3]=row2
		profile[6]=newWidth
		profile[7]=newLength
		profile[8]=contour
		profile[9]=row3
		profile
	),
	fn get_editable_profiles = (
		local edited=#()
		for profile in this.previewProfiles do append edited (for value in profile collect value)
		if this.previewIntervention and this.interventionPlanes.count==3 and this.previewControlIndices.count==3 then 
		(
			local controlProfiles=#(); local controlIndices=this.previewControlIndices
			for c=1 to 3 do (
				local index=controlIndices[c]
				local profile=for value in edited[index] collect value
				if isValidNode this.interventionPlanes[c] do this.applyEndpointPlaneToProfile profile this.interventionPlanes[c]
				append controlProfiles profile
			)
			for i=1 to edited.count do (
				local segment=if i<=controlIndices[2] then 1 else 2
				local aIndex=controlIndices[segment]; local bIndex=controlIndices[segment+1]
				local t=(this.previewProfileFractions[i]-this.previewProfileFractions[aIndex])/(this.previewProfileFractions[bIndex]-this.previewProfileFractions[aIndex])
				t=t*t*(3.0-2.0*t)
				local original=edited[i]; local a=controlProfiles[segment]; local b=controlProfiles[segment+1]
				local baseA=this.previewProfiles[aIndex]; local baseB=this.previewProfiles[bIndex]
				original[1]+=(a[1]-baseA[1])*(1.0-t)+(b[1]-baseB[1])*t
				local tangent=original[9]+((a[9]-baseA[9])*(1.0-t)+(b[9]-baseB[9])*t)
				if length tangent>0.0001 do tangent=normalize tangent
				local frameV=original[2]+((a[2]-baseA[2])*(1.0-t)+(b[2]-baseB[2])*t)
				frameV=frameV-tangent*(dot frameV tangent)
				if length frameV>0.0001 then (frameV=normalize frameV) else (frameV=original[2])
				local frameW=normalize(cross tangent frameV)
				if dot frameW original[3]<0 do (frameV=-frameV; frameW=-frameW)
				original[2]=frameV; original[3]=frameW; original[9]=tangent
				for field in #(4,5,6,7) do original[field]+=(a[field]-baseA[field])*(1.0-t)+(b[field]-baseB[field])*t
				local scaleV=original[6]/amax #(this.previewProfiles[i][6],0.0001)
				local scaleW=original[7]/amax #(this.previewProfiles[i][7],0.0001)
				local contour=#()
				if this.previewProfiles[i][8]!=undefined do for point in this.previewProfiles[i][8] do append contour #(point[1]*scaleV,point[2]*scaleW)
				original[8]=contour
			)
		) else if this.endpointSectionPlanes.count==2 then (
			if isValidNode this.endpointSectionPlanes[1] do this.applyEndpointPlaneToProfile edited[1] this.endpointSectionPlanes[1]
			if isValidNode this.endpointSectionPlanes[2] do this.applyEndpointPlaneToProfile edited[edited.count] this.endpointSectionPlanes[2]
		)
		edited
	),
	fn resample_points_by_arc_length points fractions = (
		if points.count<2 or points.count!=fractions.count do throw "骨骼路径与密度采样数据不匹配"
		local cumulative=#(0.0); local totalLength=0.0
		for i=2 to points.count do (totalLength+=distance points[i-1] points[i]; append cumulative totalLength)
		if totalLength<0.0001 do throw "调整后的骨骼路径长度不足，无法重新分配节数"
		local result=#()
		for fraction in fractions do (
			local target=totalLength*fraction; local segment=points.count-1
			for i=1 to cumulative.count-1 where target<=cumulative[i+1] do (segment=i; exit)
			local segmentLength=cumulative[segment+1]-cumulative[segment]
			local t=if segmentLength>0.0001 then (target-cumulative[segment])/segmentLength else 0.0
			append result (points[segment]+(points[segment+1]-points[segment])*t)
		)
		result
	),
	fn get_profile_radius profile angle = (
		local contour=profile[8]
		if contour==undefined or contour.count<2 do return (sqrt ((cos angle*profile[6])^2+(sin angle*profile[7])^2))
		local lowerAngle=undefined; local upperAngle=undefined; local lowerRadius=0.0; local upperRadius=0.0; local lowerGap=360.0; local upperGap=360.0
		for point in contour do (
			local dy=point[1]; local dz=point[2]
			local pointAngle=atan2 dz dy; local delta=pointAngle-angle
			while delta>180 do delta-=360
			while delta< -180 do delta+=360
			local radius=sqrt (dy*dy+dz*dz)
			if delta<=0 do (
				local gap=abs delta
				if gap<lowerGap-2.0 then (lowerGap=gap; lowerAngle=delta; lowerRadius=radius)
				else if abs(gap-lowerGap)<=2.0 do lowerRadius=amax #(lowerRadius,radius)
			)
			if delta>=0 do (
				local gap=abs delta
				if gap<upperGap-2.0 then (upperGap=gap; upperAngle=delta; upperRadius=radius)
				else if abs(gap-upperGap)<=2.0 do upperRadius=amax #(upperRadius,radius)
			)
		)
		if lowerAngle==undefined do return upperRadius
		if upperAngle==undefined do return lowerRadius
		if abs(lowerAngle)+abs(upperAngle)<0.0001 do return ((lowerRadius+upperRadius)*0.5)
		(lowerRadius*upperAngle+upperRadius*abs lowerAngle)/(abs lowerAngle+upperAngle)
	),
	fn get_skirt_chain_points profiles angle = (
		local joints=#()
		for profile in profiles do (
			local radius=this.get_profile_radius profile angle
			append joints (profile[1]+profile[2]*(cos angle*radius)+profile[3]*(sin angle*radius))
		)
		joints
	),
	fn get_ribbon_chain_points profiles offsetRatio spreadAlongV = (
		local joints=#()
		for profile in profiles do (
			local lateral=offsetRatio*(if spreadAlongV then profile[6] else profile[7])
			local transverse=0.0
			local contour=profile[8]
			if contour!=undefined and contour.count>0 do (
				local minGap=1e9; local minTrans=1e9; local maxTrans=-1e9
				local tolerance=amax #((if spreadAlongV then profile[6] else profile[7])*0.12,0.001)
				for point in contour do (
					local lateralValue=if spreadAlongV then point[1] else point[2]
					local gap=abs(lateralValue-lateral)
					if gap<minGap do minGap=gap
				)
				for point in contour do (
					local lateralValue=if spreadAlongV then point[1] else point[2]
					if abs(lateralValue-lateral)<=minGap+tolerance do (
						local transverseValue=if spreadAlongV then point[2] else point[1]
						minTrans=amin #(minTrans,transverseValue)
						maxTrans=amax #(maxTrans,transverseValue)
					)
				)
				if minTrans<1e9 and maxTrans> -1e9 do transverse=(minTrans+maxTrans)*0.5
			)
			local point=profile[1]
			if spreadAlongV then (point+=profile[2]*lateral+profile[3]*transverse) else (point+=profile[3]*lateral+profile[2]*transverse)
			append joints point
		)
		if joints.count>2 do (
			local smoothed=for point in joints collect point
			for i=2 to joints.count-1 do smoothed[i]=(joints[i-1]+joints[i]*2+joints[i+1])/4
			joints=smoothed
		)
		joints
	),

	fn create_model_chain points size chain_name radial_direction = (
		local result=#(); local parent=undefined; local previousUp=undefined
		if points.count<2 do return result
		for i=1 to points.count-1 do (
			if distance points[i] points[i+1]>0.000001 do 
			(
				local dir=normalize(points[i+1]-points[i]); 
				local drivenDirection=undefined
				if isKindOf radial_direction Array then (
					local directionIndex=amin #(i,radial_direction.count)
					if directionIndex>0 do drivenDirection=radial_direction[directionIndex]
				) else drivenDirection=radial_direction
				local up=undefined
				if drivenDirection==undefined and previousUp!=undefined do (
					local transportedUp=previousUp-dir*(dot previousUp dir)
					if length transportedUp>0.0001 do up=normalize transportedUp
				)
				if up==undefined and drivenDirection!=undefined then (
					local yAxis=drivenDirection-dir*(dot drivenDirection dir)
					if length yAxis>0.0001 do (
						if isKindOf radial_direction Array then up=normalize yAxis else up=normalize(cross dir (normalize yAxis))
					)
				)
				if up==undefined do (
					local reference=if previousUp!=undefined then previousUp else [0,0,1]
					local projectedReference=reference-dir*(dot reference dir)
					if length projectedReference<0.0001 do (
						reference=if abs(dot dir [0,1,0])<0.95 then [0,1,0] else [0,0,1]
						projectedReference=reference-dir*(dot reference dir)
					)
					up=normalize projectedReference
				)
				if drivenDirection==undefined and previousUp!=undefined and dot up previousUp<0 do up=-up
				previousUp=up
				local bone=undefined
				try (
					bone=BoneSys.createBone points[i] points[i+1] up
					append result bone
					bone.name = uniquename (chain_name+"_"+(i as string));
					bone.width=size; 
					bone.height=size
					if parent!=undefined do bone.parent=parent
					parent=bone
				) catch (
					local err = getCurrentException()
					if result.count>0 do for createdBone in result where isValidNode createdBone do delete createdBone
					messageBox ("创建骨骼段 "+(i as string)+" 失败："+(err as string))
					return #()
				)
			)
		)
		if result.count>0 do (
			local lastPoint=points[points.count]
			local lastBone=result[result.count]
			local tailLength=amax #(size,lastBone.length*0.25)
			try (
				local tailBone=BoneSys.createBone lastPoint (lastPoint+normalize(lastBone.dir)*0.1) lastBone.dir
				append result tailBone
				tailBone.transform=lastBone.transform
				in coordSys Local move tailBone [lastBone.length,0,0]
				tailBone.length=tailLength
				tailBone.name=uniquename (chain_name+"_End")
				tailBone.width=size
				tailBone.height=size
				tailBone.taper=90
				tailBone.parent=lastBone
			) catch (
				local err=getCurrentException()
				for createdBone in result where isValidNode createdBone do delete createdBone
				messageBox ("创建尾骨失败："+(err as string))
				return #()
			)
		)
		result
	),
	fn create_bones_from_model ui model_node selected_faces segment_control density_control mode_control skirt_control debug_control section_debug_control intervention_control start_ratio_control end_ratio_control name_control = (
		local data=this.make_selected_faces_mesh model_node selected_faces
		if data==undefined do (messageBox "当前子对象层级没有有效选面，请选择面、元素，或相关的点/边/边界。"; return false)
		local sample=data[1]; local all=#(); local stage="初始化"
		try (
			local verts=data[2]; local tris=data[3]; local bounds=undefined
			stage="读取模型包围盒"
			bounds=nodeGetBoundingBox sample (matrix3 1)
			if bounds==undefined do (delete sample; messageBox "无法读取所选区域的包围盒。"; return false)
			stage="估算选区主轴"
			local basis=if mode_control.state==1 and debug_control.state==1 then this.get_skirt_axis_basis model_node verts else this.get_main_axis_basis verts
			if basis==undefined do (delete sample; messageBox "选区网格范围无效，无法估算骨骼链方向。"; return false)
			local origin=basis[1]; local axis=basis[2]; local bv=basis[3]; local bw=basis[4]
			local projected=#()
			for p in verts do (
				local d=p-origin; 
				append projected [dot d axis,dot d bv,dot d bw]
			)
			local umin=projected[1].x; 
			local umax=umin; 
			local vmin=projected[1].y; 
			local vmax=vmin; 
			local wmin=projected[1].z; 
			local wmax=wmin
			for p in projected do (
				umin=amin #(umin,p.x); umax=amax #(umax,p.x); vmin=amin #(vmin,p.y); 
				vmax=amax #(vmax,p.y); wmin=amin #(wmin,p.z); wmax=amax #(wmax,p.z)
			)
			local axislen=umax-umin; local fv=(vmin+vmax)*0.5; local fw=(wmin+wmax)*0.5; local frv=(vmax-vmin)*0.5; local frw=(wmax-wmin)*0.5
			if axislen<=0.001 do (delete sample; messageBox "所选区域沿主轴方向的长度不足，无法创建骨骼链。"; return false)
			local count=segment_control.value as integer
			local startRatio=if intervention_control.state then start_ratio_control.value/100.0 else 0.1
			local endRatio=if intervention_control.state then end_ratio_control.value/100.0 else 0.9
			if endRatio<startRatio+0.01 do throw "结束截面位置需比起点至少大 1%"
			if intervention_control.state and count<2 do throw "干预模式至少需要 2 节骨骼，才能显示起点、中点和终点三个截面"
			local ratio=pow 2.0 (-(density_control.value as float)/100.0); local weights=#(); local total=0.0
			for i=1 to count do (local weight=pow ratio (i-1); append weights weight; total+=weight)
			local fractions=#(0.0); local accumulated=0.0; for weight in weights do (accumulated+=weight; append fractions (accumulated/total))
			local profileInset=startRatio
			local profileSpan=endRatio-startRatio
			local profileFractions=for fraction in fractions collect (profileInset+fraction*profileSpan)
			stage="计算网格截面"
			local raw=#()
			for fraction in profileFractions do (
				local u=umax-axislen*fraction
				local p=this.get_slice_profile projected tris [u,fv,fw] [1,0,0] [0,1,0] [0,0,1]
				append raw p
			)
			local validRawCount=0
			for p in raw where p!=undefined do validRawCount+=1
			if validRawCount==0 do throw "全局采样未与模型相交，无法建立中心线"
			if raw[1]==undefined or raw[raw.count]==undefined do throw "头尾参考截面未与模型相交，无法可靠计算端点截面"
			for i=2 to raw.count-1 where raw[i]==undefined do (
				local nearest=undefined; local nearestDistance=raw.count+1
				for j=1 to raw.count where raw[j]!=undefined do (local d=abs(i-j); if d<nearestDistance do (nearest=j; nearestDistance=d))
				raw[i]=raw[nearest]
			)
			if raw.count<2 do throw ("截面采样点不足："+(raw.count as string))
			local centerline=#()
			for i=1 to raw.count do append centerline [umax-axislen*profileFractions[i],fv+raw[i][1],fw+raw[i][2]]
			for pass=1 to 3 do (
				local nextLine=#()
				for i=1 to centerline.count do (
					if i==1 or i==centerline.count then append nextLine centerline[i]
					else append nextLine ((centerline[i-1]+centerline[i]*2+centerline[i+1])/4)
				)
				centerline=nextLine
			)
			local endpointFitCount=amin #(centerline.count,4)
			local startTangent=normalize(centerline[endpointFitCount]-centerline[1])
			local endTangent=normalize(centerline[centerline.count]-centerline[centerline.count-endpointFitCount+1])
			if dot startTangent [1,0,0]<0 do startTangent=-startTangent
			if dot endTangent [1,0,0]<0 do endTangent=-endTangent
			local localFrames=#()
			local rawProfiles=#()
			for i=1 to centerline.count do (
				local tangent=if i==1 then startTangent else if i==centerline.count then endTangent else [1,0,0]
				local blendWeight=0.0
				if i>1 and i<centerline.count do (
					local localTangent=normalize(centerline[i+1]-centerline[i-1])
					if dot localTangent [1,0,0]<0 do localTangent=-localTangent
					local edgeT=amin #((i-1) as float,(centerline.count-i) as float)/amax #((centerline.count-1) as float,1.0)*2.0
					edgeT=amax #(0.0,amin #(edgeT,1.0))
					blendWeight=edgeT*edgeT*(3.0-2.0*edgeT)
					local blendedTangent=(1.0-blendWeight)*[1,0,0]+blendWeight*localTangent
					if length blendedTangent>0.0001 do tangent=normalize blendedTangent
				)
				local frameV=if i==1 then [0,1,0] else localFrames[i-1][1]-tangent*(dot localFrames[i-1][1] tangent)
				local globalV=[0,1,0]-tangent*(dot [0,1,0] tangent)
				if length globalV>0.0001 do (
					globalV=normalize globalV
					frameV=frameV*blendWeight+globalV*(1.0-blendWeight)
				)
				if length frameV<0.0001 do frameV=cross tangent [0,1,0]
				frameV=normalize frameV
				local frameW=normalize(cross tangent frameV)
				local samplePoint=centerline[i]
				local p=this.get_slice_profile projected tris samplePoint tangent frameV frameW
				if i==1 and p!=undefined do (
					local profileAxis=this.get_profile_major_axis p frameV frameW
					if profileAxis!=undefined do (
						if dot profileAxis frameV<0 do profileAxis=-profileAxis
						frameV=normalize(profileAxis-tangent*(dot profileAxis tangent))
						frameW=normalize(cross tangent frameV)
						p=this.get_slice_profile projected tris samplePoint tangent frameV frameW
					)
				)
				append localFrames #(frameV,frameW,tangent)
				if p==undefined do (
					if i==1 or i==centerline.count do throw ("固定端点截面未与模型相交：第 "+(i as string)+" 个截面")
					for step=1 to 10 while p==undefined do (
						local offset=axislen*0.005*step
					local candidateA=samplePoint+tangent*offset
					p=this.get_slice_profile projected tris candidateA tangent frameV frameW
					if p!=undefined then samplePoint=candidateA else (
						local candidateB=samplePoint-tangent*offset
						p=this.get_slice_profile projected tris candidateB tangent frameV frameW
						if p!=undefined do samplePoint=candidateB
					)
					)
				)
				if p==undefined do throw ("第 "+(i as string)+" 个局部截面未与模型相交")
				centerline[i]=samplePoint
				append rawProfiles p
			)
			local localRaw=#()
			for p in rawProfiles do append localRaw p
			local _smooth=#()
			for p in localRaw do append _smooth #(p[1],p[2],p[3],p[4],p[5])
			for pass=1 to 2 do (
				local _next=#()
				for i=1 to _smooth.count do (
					local p=_smooth[i]
					if i==1 or i==_smooth.count then append _next p
					else (local a=_smooth[i-1]; local b=_smooth[i+1]; append _next #((a[1]+2*p[1]+b[1])/4,(a[2]+2*p[2]+b[2])/4,(a[3]+2*p[3]+b[3])/4,(a[4]+2*p[4]+b[4])/4,p[5]))
				)
				_smooth=_next
			)
			local profiles=#()
			for i=1 to _smooth.count do (
				local p=_smooth[i]; local contour=#()
				if p[5]!=undefined do for q in p[5] do append contour #(q[1]-p[1],q[2]-p[2])
				local frameVWorld=axis*localFrames[i][1].x+bv*localFrames[i][1].y+bw*localFrames[i][1].z
				local frameWWorld=axis*localFrames[i][2].x+bv*localFrames[i][2].y+bw*localFrames[i][2].z
				local tangentWorld=axis*localFrames[i][3].x+bv*localFrames[i][3].y+bw*localFrames[i][3].z
				local center=centerline[i]+localFrames[i][1]*p[1]+localFrames[i][2]*p[2]
				local centerWorld=origin+axis*center.x+bv*center.y+bw*center.z
				append profiles #(centerWorld,frameVWorld,frameWWorld,p[1],p[2],p[3],p[4],contour,tangentWorld)
			)

			this.previewProfiles=#()
			for profile in profiles do append this.previewProfiles (for value in profile collect value)
			this.previewFractions=for value in fractions collect value
			this.previewProfileFractions=for value in profileFractions collect value
			this.previewStartRatio=startRatio
			this.previewEndRatio=endRatio
			this.previewMode=mode_control.state
			this.previewIntervention=intervention_control.state
			this.previewControlIndices=#()
			if this.previewIntervention do (
				if profiles.count<3 do throw "干预模式至少需要 2 节骨骼，才能提供起点、中点、终点三个控制截面"
				append this.previewControlIndices 1
				local middleIndex=2; local middleGap=abs(profileFractions[2]-0.5)
				for i=3 to profileFractions.count-1 do if abs(profileFractions[i]-0.5)<middleGap do (middleIndex=i; middleGap=abs(profileFractions[i]-0.5))
				append this.previewControlIndices middleIndex
				append this.previewControlIndices profiles.count
			)
			this.previewChainCount=skirt_control.value as integer
			this.previewSpreadAlongV=(frv>=frw)
			this.previewAxisLength=axislen
			this.previewBoneName=name_control
			this.endpointSectionPlanes=#()
			this.interventionPlanes=#()
			for i=1 to profiles.count do (
				local p=profiles[i]
				local controlIndex=if this.previewIntervention then findItem this.previewControlIndices i else 0
				local isControl=(controlIndex>0)
				if section_debug_control.state or i==1 or i==profiles.count or isControl do (
					local planeName="ND_SectionSamplePlane"
					if isControl then (
						if controlIndex==1 then (planeName="ND_SectionStart")
						else if controlIndex==2 then (planeName="ND_SectionMiddle")
						else (planeName="ND_SectionEnd")
					) else (
						if i==1 then (planeName="ND_SectionStart")
						else if i==profiles.count then (planeName="ND_SectionEnd")
					)
					local sectionPlane=plane name:(uniquename planeName) width:(amax #(p[6]*2,0.001)) length:(amax #(p[7]*2,0.001)) widthsegs:1 lengthsegs:1
					sectionPlane.transform=matrix3 p[2] p[3] p[9] p[1]
					sectionPlane.wirecolor=if isControl then (if controlIndex==2 then (color 255 220 0) else (color 255 160 0)) else (color 0 255 255)
					append this.debugShapes sectionPlane
					if i==1 or i==profiles.count do (append this.endpointSectionPlanes sectionPlane)
					if isControl do (append this.interventionPlanes sectionPlane)
				)
			)
			local size=(amin #(axislen/2,amax #(frv,frw)/count))*0.08; 
			if size<0.001 do (size=0.001)
			this.previewBoneSize=size
			if profiles.count!=fractions.count or profiles.count<2 do throw ("骨骼点数据数量不匹配：profiles="+(profiles.count as string)+"，fractions="+(fractions.count as string))
			stage="创建骨骼链"
			all=this.create_chains_from_profiles profiles mode_control.state skirt_control.value (frv>=frw) size name_control fractions
			if all.count==0 do format "没有生成骨骼，请确认选区长度和骨骼节数设置。\n"
			select this.endpointSectionPlanes[1]
			delete sample
			all
		) catch (err = getCurrentException()
			if isValidNode sample do delete sample
			for node in all where isValidNode node do delete node
			messageBox ("创建骨骼链失败（"+stage+"）："+(err as string))
			false
		)
	),
	fn classofobj obj = (classof obj==line or classof obj==SplineShape),
	fn change_name_tag objs tag = (for obj in objs do if not(matchPattern obj.name pattern:(tag+"*")) do obj.name=tag+obj.name),
	fn change_name_remove objs = this.change_name_tag objs "Remove_",
	fn change_name_merge objs = this.change_name_tag objs "MergeBone_",
	fn change_children_new_parent obj new_parent = (for child in obj.children do child.parent=new_parent),
	fn createBoneform_tm tmlist is_end_bone width height name_control = (
		local result=#()
		for i=1 to tmlist.count do (
			if i<tmlist.count then (local b=BoneSys.createBone tmlist[i].pos tmlist[i+1].pos tmlist[i].row3; if name_control.count>0 do b.name=uniquename name_control; b.width=width*1.2; b.height=height*1.2; append result b)
			else if is_end_bone do (
				local prev=result[result.count]; 
				local b=BoneSys.createBone tmlist[i].pos (tmlist[i].pos*1.1) prev.dir;
				b.transform=prev.transform;
				in coordSys Local move b [prev.length,0,0];
				b.width=width*1.2; b.height=height*1.2; b.taper=90; b.length=(b.width+b.height)/2; b.name=uniquename "end"; append result b
			)
			if i>1 and i<=result.count do result[i].parent=result[i-1]
		)
		result
	),
	fn squad_slerp2 q1 q2 t = (
		local dotValue=q1.x*q2.x+q1.y*q2.y+q1.z*q2.z+q1.w*q2.w
		if dotValue<0 do (q1=q1*-1.0; dotValue=-dotValue)
		if dotValue>0.9995 do return (slerp q1 q2 t)
		local theta0=degtorad(acos dotValue)
		local sinTheta0=sin(acos dotValue)
		local theta=theta0*t
		local sinTheta=sin(radtodeg theta)
		local cosTheta=cos(radtodeg theta)
		local s0=cosTheta-dotValue*sinTheta/sinTheta0
		local s1=sinTheta/sinTheta0
		local q3=quat 0 0 0 1
		q3.x=q1.x*s0+q2.x*s1; q3.y=q1.y*s0+q2.y*s1; q3.z=q1.z*s0+q2.z*s1; q3.w=q1.w*s0+q2.w*s1
		normalize q3
	),
	fn find_refine_bone_length_index distances target = (
		for i=1 to distances.count do if target<=distances[i] do return i
		undefined
	),
	fn refine_matrix3 tmlist count total_length gradient = (
		if tmlist.count<2 do return tmlist
		local lengths=#(); local total=0.0
		for i=1 to count do (local v=pow gradient (i-1); append lengths v; total+=v)
		for i=1 to lengths.count do lengths[i]*=total_length/total
		local distances=#(); local dist=0.0
		for i=1 to tmlist.count-1 do (dist+=distance tmlist[i][4] tmlist[i+1][4]; append distances dist)
		local result=#()
		for i=0 to count do (
			local target=0.0; for j=1 to i do target+=lengths[j]
			local index=this.find_refine_bone_length_index distances target
			if index==undefined or index>=tmlist.count do index=tmlist.count-1
			local startDistance=if index>1 then distances[index-1] else 0.0
			local segmentLength=distances[index]-startDistance
			local t=if segmentLength>0.0001 then amax #(0.0,amin #(1.0,(target-startDistance)/segmentLength)) else 0.0
			local a=tmlist[index]; local b=tmlist[index+1]
			local rot=this.squad_slerp2 a.rotation b.rotation t
			local tm=rot as matrix3; tm.pos=a.pos+(b.pos-a.pos)*t; append result tm
		)
		result
	),
	fn clearReconstructPreview = (
		for bone in this.bones where isValidNode bone do delete bone
		this.bones=#()
		this.reconstructPreviewActive=false
		true
	),
	fn updateReconstructButtonLabels ui = (
		if this.reconstructSource.count>0 then (
			ui.bnt_reconstruct_chain.text="预览("+(this.reconstructSource.count as string)+")"
			ui.btn_reconstruct_done.text="确定("+(this.bones.count as string)+")"
		) else (
			ui.bnt_reconstruct_chain.text="预览"
			ui.btn_reconstruct_done.text="确定"
		)
		true
	),
	fn updateReconstructPreview ui = (
		if not this.reconstructPreviewActive or this.reconstructMatrices.count<2 do return false
		for bone in this.bones where isValidNode bone do delete bone
		this.bones=#()
		local refined=this.refine_matrix3 this.reconstructMatrices ui.spn2.value this.reconstructLength ui.spn_gradient.value
		local newBones=this.createBoneform_tm refined true this.reconstructWidth this.reconstructHeight ("Preview_"+this.reconstructStartName+"_")
		if newBones.count==0 do return false
		newBones[1].parent=this.reconstructParent
		for bone in newBones do bone.name=uniquename ("Preview_"+this.reconstructStartName+"_")
		this.bones=newBones
		this.reconstructPreviewActive=true
		this.updateReconstructButtonLabels ui
		select newBones
		redrawViews()
		true
	),
	fn reconstructChain ui = (
		if this.reconstructPreviewActive then return this.updateReconstructPreview ui
		local chain=selection as Array
		if chain.count<2 then (messageBox "请按顺序选择至少两根连续骨骼。"; return false)
		local matrices=#(); local total=0.0; local start=chain[1]; local endBone=chain[chain.count]
		for bone in chain do (append matrices bone.transform; total+=bone.length)
		append matrices (PreTranslate endBone.transform [endBone.length,0,0])
		this.reconstructSource=for bone in chain collect bone
		this.reconstructMatrices=matrices
		this.reconstructLength=total
		this.reconstructParent=start.parent
		this.reconstructWidth=start.width
		this.reconstructHeight=start.height
		this.reconstructStartName=start.name
		this.reconstructPreviewActive=true
		this.updateReconstructPreview ui
	),
	fn commitReconstructChain ui = (
		if not this.reconstructPreviewActive or this.bones.count==0 then (messageBox "请先预览骨骼链。"; return false)
		local newBones=this.bones
		for i=1 to newBones.count do newBones[i].name=uniquename (this.reconstructStartName+"_")
		newBones[1].parent=this.reconstructParent
		this.change_name_remove this.reconstructSource
		this.change_name_tag newBones "NewChai_"
		this.bones=#()
		this.reconstructPreviewActive=false
		this.reconstructSource=#()
		this.reconstructMatrices=#()
		this.reconstructLength=0.0
		this.reconstructParent=undefined
		this.updateReconstructButtonLabels ui
		select newBones
		redrawViews()
		true
	),
	fn cancelReconstructChain ui = (
		local source=this.reconstructSource
		this.clearReconstructPreview()
		this.reconstructSource=#()
		this.reconstructMatrices=#()
		this.reconstructLength=0.0
		this.reconstructParent=undefined
		this.updateReconstructButtonLabels ui
		if source.count>0 do select source
		redrawViews()
		true
	),
	fn mergeChain ui = (
		local chain=selection as Array
		if chain.count<=1 then (messageBox "请选择多根连续骨骼"; return false)
		local start=chain[1]; local endBone=chain[chain.count]; local endTM=PreTranslate endBone.transform [endBone.length,0,0]
		undo "ff_merger_bone" on (
			local merged=undefined
			if ui.check_frist_bone.state then (merged=copy start; merged.length=distance start.pos endTM.pos; merged.parent=start.parent; merged.name="MergeBone_"+start.name)
			else (local made=this.createBoneform_tm #(start.transform,endTM) false start.width start.height ui.edit_name; merged=made[1]; this.change_name_merge #(merged); merged.name="MergeBone_"+(uniquename start.name))
			merged.parent=start.parent
			if ui.check_change_child.state and isValidNode merged do for bone in chain do for child in bone.children where (findItem chain child)==0 do child.parent=merged
			this.change_name_remove chain
			if ui.check_remoe_old_bone.state do delete chain
		)
	),
	fn updateInterventionRatios ui isStart value = (
		if this.ratioSyncing do return false
		this.ratioSyncing=true
		if isStart and value>=ui.spn_intervention_end.value do ui.spn_intervention_end.value=amin #(100,value+1)
		if not isStart and value<=ui.spn_intervention_start.value do ui.spn_intervention_start.value=amax #(0,value-1)
		this.ratioSyncing=false
		if this.modelPreviewActive do this.updateModelPreview ui resetControlPlanes:true
		true
	),
	fn updateModelPreview ui resetControlPlanes:false = (
		if not this.beginUpdate() do return false
		local savedControlPlanes=#()
		local oldControlPlanes=if this.previewIntervention then this.interventionPlanes else this.endpointSectionPlanes
		for planeNode in oldControlPlanes where isValidNode planeNode do append savedControlPlanes #(planeNode.transform,planeNode.width,planeNode.length)
		local oldInterventionMode=this.previewIntervention
		with redraw off (
			this.clearPreview()
			local is_valid=this.create_bones_from_model ui this.model this.faces ui.spn_model_segments ui.sld_chain_density ui.rb_model_chain ui.spn_skirt_count ui.chk_skirt_axis_debug ui.chk_section_debug ui.chk_intervention ui.spn_intervention_start ui.spn_intervention_end "Bone_"
			this.finishUpdate is_valid
			this.modelPreviewActive=(this.bones.count>0)
			local newControlPlanes=if this.previewIntervention then this.interventionPlanes else this.endpointSectionPlanes
			if this.modelPreviewActive and oldInterventionMode==this.previewIntervention and savedControlPlanes.count==newControlPlanes.count do (
				for i=1 to newControlPlanes.count do (
					local savedTransform=savedControlPlanes[i][1]
					local savedPosition=savedTransform.row4
					if resetControlPlanes and this.previewIntervention and i!=2 do savedPosition=newControlPlanes[i].transform.row4
					savedTransform.row4=savedPosition
					newControlPlanes[i].transform=savedTransform
					newControlPlanes[i].width=savedControlPlanes[i][2]
					newControlPlanes[i].length=savedControlPlanes[i][3]
				)
				local editedProfiles=this.get_editable_profiles()
				local adjustedBones=this.create_chains_from_profiles editedProfiles this.previewMode this.previewChainCount this.previewSpreadAlongV this.previewBoneSize this.previewBoneName this.previewFractions
				for node in this.bones where isValidNode node do delete node
				this.bones=adjustedBones
				if newControlPlanes.count>0 do select newControlPlanes[1]
			)
		)
		redrawViews()
		true
	),
	fn updateModelChainCountLabel ui = (
		ui.spn_skirt_count.text=(if ui.rb_model_chain.state==1 then "裙摆骨骼条数: " else "飘带骨骼条数: ")+(ui.spn_skirt_count.value as string)
	),
	fn updateModelControls ui = (
		this.updateModelChainCountLabel ui
		if this.modelPreviewActive do this.updateModelPreview ui
	),
	fn createModelChain ui = (
		if this.modelPreviewActive then (
			local editedProfiles=this.get_editable_profiles()
			local newBones=this.create_chains_from_profiles editedProfiles this.previewMode this.previewChainCount this.previewSpreadAlongV this.previewBoneSize this.previewBoneName this.previewFractions
			if newBones.count==0 then (messageBox "未能根据调整后的截面刷新骨骼预览。"; false)
			else (
				for node in this.bones where isValidNode node do delete node
				this.bones=newBones
				select this.endpointSectionPlanes[1]
				redrawViews()
				true
			)
		) else (
			local sourceModel=undefined; local sourceFaces=undefined
			if selection.count==1 and isKindOf selection[1].baseObject Editable_Poly then (
				sourceModel=selection[1]
				sourceFaces=this.get_model_selected_faces sourceModel
			)
			if sourceModel==undefined or sourceFaces==undefined or sourceFaces.numberSet==0 then (
				if this.model!=undefined and isValidNode this.model and this.faces!=undefined and this.faces.numberSet>0 then (
					sourceModel=this.model
					sourceFaces=this.faces
				) else (
					messageBox "请选择一个 Editable Poly 模型，并选中有效面、元素或子对象区域。"
					return false
				)
			)
			this.setSource sourceModel sourceFaces
			this.updateModelPreview ui
			if this.modelPreviewActive do ui.btn_create_model_chain.text="混合调整预览"
		)
	),
	fn commitModelChain ui = (
		if this.bones.count==0 then (messageBox "请先选择模型生成骨骼链预览。"; false)
		else (
			local editedProfiles=this.get_editable_profiles()
			local oldBones=this.bones
			local newBones=this.create_chains_from_profiles editedProfiles this.previewMode this.previewChainCount this.previewSpreadAlongV this.previewBoneSize this.previewBoneName this.previewFractions
			if newBones.count==0 then (messageBox "未能根据调整后的首尾截面重建骨骼链。"; false)
			else (
				for node in oldBones where isValidNode node do delete node
				for node in this.debugShapes where isValidNode node do delete node
				this.bones=newBones
				this.debugShapes=#()
				this.endpointSectionPlanes=#()
				this.interventionPlanes=#()
				this.previewControlIndices=#()
				this.previewIntervention=false
				this.previewProfiles=#()
				this.previewFractions=#()
				this.previewProfileFractions=#()
				this.modelPreviewActive=false
				ui.btn_create_model_chain.text="选择模型创建骨骼链"
				this.model=undefined
				this.faces=undefined 
				ui.rb_model_chain.enabled=true
				ui.chk_skirt_axis_debug.enabled=(ui.rb_model_chain.state==1)
				ui.chk_section_debug.enabled=true
				ui.spn_skirt_count.enabled=true
				ui.spn_model_segments.enabled=true
				ui.sld_chain_density.enabled=true
				ui.btn_create_model_chain.enabled=true
				ui.btn_create_done.enabled=true
				this.updateModelChainCountLabel ui
				select newBones
				this.bones=#()
				true
			)
		)
	),
	fn cancel_createModelChain ui = (
		for node in this.bones where isValidNode node do delete node
		for node in this.debugShapes where isValidNode node do delete node
		this.model=undefined
		this.faces=undefined 
		this.bones=#()
		this.debugShapes=#()
		this.endpointSectionPlanes=#()
		this.interventionPlanes=#()
		this.previewControlIndices=#()
		this.previewIntervention=false
		this.previewProfiles=#()
		this.previewFractions=#()
		this.previewProfileFractions=#()
		this.modelPreviewActive=false
		ui.btn_create_model_chain.text="选择模型创建骨骼链"
	),
	fn closeFloater = 
	(
		local old= if floater!=undefined then floater else create_bone_chainFloater;
		if old!=undefined do(
			try(closeRolloutFloater old)catch();
		)
		floater = undefined;
		create_bone_chainFloater=undefined; true
	),
	fn createFloater mainRollout infoRollout toolsRollout modelRollout = 
	(
		this.closeFloater(); 
		this.clearPreview()
		this.reconstructPreviewActive=false
		this.reconstructSource=#()
		this.reconstructMatrices=#()
		this.reconstructLength=0.0
		this.reconstructParent=undefined
		this.bones=#()
		floater=newRolloutFloater "骨骼链编辑" 260 850; 
		create_bone_chainFloater=floater;
		addRollout modelRollout floater; 
		addRollout mainRollout floater; 
		addRollout infoRollout floater; 
		addRollout toolsRollout floater; 
		modelRollout.rb_model_chain.enabled=true
		modelRollout.chk_skirt_axis_debug.enabled=(modelRollout.rb_model_chain.state==1)
		modelRollout.chk_section_debug.enabled=true
		modelRollout.spn_skirt_count.enabled=true
		modelRollout.spn_model_segments.enabled=true
		modelRollout.sld_chain_density.enabled=true
		modelRollout.btn_create_model_chain.enabled=true
		modelRollout.btn_create_done.enabled=true
		this.updateModelChainCountLabel modelRollout
		floater
	)
)

global ND_BoneChainController = ND_BoneChainController_v1()

rollout create_bone_chain_model "模型骨骼链" width:240 height:280
(
	label lab_model_chain_help "以模型走势采样；可调整首尾截面，或开启干预模式调整首/中/尾三个截面" height:30
	radiobuttons rb_model_chain labels:#("裙摆模式", "飘带模式") columns:2
	checkbox chk_skirt_axis_debug "Debug：局部Z轴（关闭=PCA）" checked:true
	checkbox chk_section_debug "Debug：显示截面采样平面（青色）" checked:false
	checkbox chk_intervention "启用截面干预" checked:false
	
	spinner spn_intervention_start "起点:" range:[1,99,5] type:#integer scale:1 fieldWidth:42 across:2 enabled:false align:#left tooltip:"	%比例"
	spinner spn_intervention_end "终点:" range:[1,100,95] type:#integer scale:1 fieldWidth:42 Align:#right enabled:false align:#right tooltip:"	%比例"
	
	spinner spn_skirt_count "裙摆/飘带骨骼条数:" range:[1,64,6] type:#integer scale:1 fieldWidth:48
	spinner spn_model_segments "每条骨骼节数:" range:[1,50,8] type:#integer scale:1 fieldWidth:48
	--label lab_chain_density_help "头部较短  ←  均匀  →  尾部较短" height:18
	slider sld_chain_density "骨骼链密度:" range:[-100,100,0] type:#integer ticks:9
	--label lab_density_value "长度渐变：均匀" height:18
	button btn_cancel "取消" width:40 height:26 Align:#left across:3 
	button btn_create_model_chain "选择模型创建骨骼链" width:130 height:26 Align:#center
	button btn_create_done "完成" width:40 height:26 Align:#right

	on rb_model_chain changed state do (
		spn_skirt_count.enabled=true
		spn_skirt_count.value=if state==2 then 1 else 6
		chk_skirt_axis_debug.enabled=(state==1)
		ND_BoneChainController.updateModelControls create_bone_chain_model
	)
	on chk_skirt_axis_debug changed state do ND_BoneChainController.updateModelControls create_bone_chain_model
	on chk_section_debug changed state do ND_BoneChainController.updateModelControls create_bone_chain_model
	on chk_intervention changed state do (spn_intervention_start.enabled=state; spn_intervention_end.enabled=state; ND_BoneChainController.updateModelControls create_bone_chain_model)
	on spn_intervention_start changed value do ND_BoneChainController.updateInterventionRatios create_bone_chain_model true value
	on spn_intervention_end changed value do ND_BoneChainController.updateInterventionRatios create_bone_chain_model false value
	on spn_skirt_count changed value do ND_BoneChainController.updateModelControls create_bone_chain_model
	on spn_model_segments changed value do ND_BoneChainController.updateModelControls create_bone_chain_model
	on sld_chain_density changed value do (
		local d=value as integer; 
		if d<0 then (sld_chain_density.text="骨骼链密度 "+(abs d as string)+"%") 
		else if d>0 then (sld_chain_density.text="长度渐变：尾部较短 "+(d as string)+"%") 
		else (sld_chain_density.text="长度渐变：均匀"); 
		ND_BoneChainController.updateModelControls create_bone_chain_model
	)
	on btn_create_model_chain pressed do ND_BoneChainController.createModelChain create_bone_chain_model
	on btn_create_done pressed do ND_BoneChainController.commitModelChain create_bone_chain_model
	on btn_cancel pressed do ND_BoneChainController.cancel_createModelChain create_bone_chain_model
)

rollout create_bone_chain "骨骼链编辑" width:240 height:530
(
	group "原骨骼链编辑" (label lab_02 "1. 先按骨骼顺序选中骨骼链" Align:#left; label lab_03 "2. 然后使用 分配、合并 功能" Align:#left)
	edittext edit_name "Bone名前缀：" text:"Bone_" fieldWidth:85 height:20
	spinner spn2 "骨骼数量:" fieldWidth:57 height:16 range:[1,100,10] type:#integer scale:1 Align:#left
	spinner spn_gradient "渐变系数:" fieldWidth:57 height:16 range:[0.1,1.0,0.8] type:#float scale:0.1 Align:#left tooltip:"控制骨骼长度渐变效果，0.1=强烈渐变，1.0=无渐变"
	checkbox check_change_child "新骨骼接受旧骨骼子级" checked:true
	checkbox check_remoe_old_bone "删除旧骨骼"
	label lab_04 ""
	group "重新分配骨骼链" (
		button bnt_reconstruct_chain "预览" width:70 height:25 across:3
		button btn_reconstruct_done "确定" width:70 height:25
		button btn_reconstruct_cancel "取消" width:70 height:25
	)
	group "骨骼融合" (checkbox check_frist_bone "以第一节为准"; button btn_merge_bone "合并骨骼" width:120 height:25 tooltip:"合并选择骨骼")
	label lab_help "738746223@qq.com"
	on spn2 changed value do if ND_BoneChainController.reconstructPreviewActive do ND_BoneChainController.updateReconstructPreview create_bone_chain
	on spn_gradient changed value do if ND_BoneChainController.reconstructPreviewActive do ND_BoneChainController.updateReconstructPreview create_bone_chain
	on bnt_reconstruct_chain pressed do ND_BoneChainController.reconstructChain create_bone_chain
	on btn_reconstruct_done pressed do ND_BoneChainController.commitReconstructChain create_bone_chain
	on btn_reconstruct_cancel pressed do ND_BoneChainController.cancelReconstructChain create_bone_chain
	on btn_merge_bone pressed do ND_BoneChainController.mergeChain create_bone_chain
)

ND_BoneChainController.createFloater create_bone_chain create_bone_chain_info create_bone_chain_tools create_bone_chain_model

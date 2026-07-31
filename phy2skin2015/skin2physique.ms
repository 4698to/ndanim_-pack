/*
-- coding: utf-8 
-- @Date    : 2026-03-20 16:28:45
-- @Author  : 4698to (738746223@qq.com)
-- @Link    : sundaybox.cc
-- @Version : v0.1
*/




	--global TRI_Tools
	

------------------------------------
-- CREATES DIALOG AND KILLS EXISTING
------------------------------------

	--if TRI_Tools != undefined do	( closerolloutfloater TRI_Tools )
	--TRI_Tools = newrolloutfloater "ES Tools" 190 250
	
--****************************
-- ANIM TOOL GO!!!!!!!!!
--****************************
try(DestroyDialog TRIphytools )catch()

rollout TRIphytools "skin-phy互通工具v0.1" width:190 height:290
(
	group "skin 转 phy" (
		
		button btnRun "转换选中skin模型" width:120
	)
	group "Physique 工具"
	(
		button savePhy "保存顶点权重" width:120 across:2 align:#left
		button savePhyHelp "?" width:20 align:#right
		button loadPhyData "加载 Physique 数据" width:120 across:2 align:#left
		button loadPhyDataHelp "?" width:20 align:#right
	)

	group "Skin 工具"
	(
		button saveSkin "保存顶点权重" width:120  across:2 align:#left
		button saveSkinHelp "?" width:20 align:#right
		button loadSkinData "加载 Skin 数据" width:120 across:2 align:#left
		button loadSkinDataHelp "?" width:20 align:#right		
		button Extract "烘焙 Skin 到网格" width:120 across:2 align:#left
		button ExtractHelp "?" width:20 align:#right
		button ImportWts "导入 Skin 权重" width:120 across:2 align:#left
		button ImportWtsHelp "?" width:20 align:#right
	)
	
	on savePhyHelp pressed do messagebox "将模型的 PHYSIQUE 权重保存到外部临时文件。\n\n1. 在 Editable_Poly 或 Editable Mesh 下仅选择要保存的顶点（不是 Physique 子对象模式）。\n2. 点击本按钮。\n3. 之后可将权重加载到 PHYSIQUE 或 SKIN。" Title:"帮助"
	on loadPhyDataHelp pressed do messagebox  "选择一个带 PHYSIQUE 修改器的模型来加载已保存权重。\n\n1. 选择模型。\n2. 关闭重复链接（duplicate links）。\n3. 不需要进入子对象模式。\n4. 点击按钮后，顶点会按刚体（绿色）方式加载，不受保存时状态影响。" Title:"帮助"
	on saveSkinHelp pressed do messagebox "将选中模型的 SKIN 权重保存到外部临时文件。\n\n1. 在 Editable_Poly 或 Editable Mesh 下仅选择要保存的顶点（不是 Skin 子对象模式）。\n2. 点击本按钮。\n3. 之后可将权重加载到 PHYSIQUE 或 SKIN。" Title:"帮助"
	on loadSkinDataHelp pressed do messagebox  "选择一个带 SKIN 修改器的模型来加载已保存权重。\n\n1. 选择模型。\n2. 不需要进入子对象模式。" Title:"帮助"
	on ExtractHelp pressed do messagebox  "将当前网格的 Skin 权重烘焙为一个网格副本，之后可把权重回灌到修改过拓扑的模型。\n\n1. 选择一个带 SKIN 修改器的已绑定模型。\n2. 如果模型是 PHYSIQUE，请先转换为 SKIN。\n3. 点击按钮进行烘焙。\n4. 不要修改烘焙网格的名称。" Title:"帮助"
	on ImportWtsHelp pressed do messagebox  "把烘焙网格中的顶点权重导入到带 Skin 修改器的模型。\n\n1. 给目标模型添加 SKIN 修改器。\n2. 在 SKIN 面板中先添加骨骼。\n3. 同时选择烘焙模型和未加权模型。\n4. 点击按钮。\n5. 在导入对话框中选择 Match By Name。\n6. 点击 OK。\n7. 检查权重是否正确导入。\n8. 若失败，可尝试对两个模型都执行 Reset XForm。" Title:"帮助"


	
	fn _findModifierByClass node theClass =
	(
	    for m in node.modifiers do
	    (
	        if (isKindOf m theClass) do return m
	    )
	    undefined
	)

	fn _getSkinMod node =
	(
	    -- Skin 在 maxscript 里通常叫 Skin
	    local skinMod = undefined
	    for m in node.modifiers do
	    (
	        if (classof m == Skin or isKindOf m Skin) do (skinMod = m; exit)
	    )
	    skinMod
	)

	fn _getPhysiqueMod node =
	(
	    local phyMod = physiqueOps.getPhysiqueModifier node
	    phyMod  

	)

	fn _getRootBoneFromSkin skinMod =
	(
	    local nBones = skinOps.getNumberBones skinMod
	    local boneNodes = #()
	    for i = 1 to nBones do
	    (
	        local bn = skinOps.GetBoneName skinMod i 0
	        local nodeRef = (getNodeByName bn)
	        append boneNodes nodeRef
	    )

	    -- 取“骨骼集合中，父节点不在集合内”的那个作为 root
	    local root = undefined
	    for i = 1 to boneNodes.count do
	    (
	        local bn = boneNodes[i]
	        if bn != undefined then
	        (
	            local p = bn.parent
	            if (p == undefined) then (root = bn; exit)
	            else
	            (
	                if (findItem boneNodes p) == 0 do (root = bn; exit)
	            )
	        )
	    )
	    if root == undefined and boneNodes.count > 0 do root = boneNodes[1]
	    root
	)

	fn ConvertOneNode_SkinToPhysique theNode =
	(
	    if theNode == undefined then return false

	    -- 1) 先收集 skin 信息（在复制之前）
	    local skinMod = _getSkinMod theNode
	    if skinMod == undefined then
	    (
	        format "跳过：% 没找到 Skin\n" theNode.name
	        return false
	    )

	    local nBones = skinOps.getNumberBones skinMod
	    if nBones <= 0 then
	    (
	        format "跳过：% Skin bone 数为 0\n" theNode.name
	        return false
	    )

	    local rootBone = _getRootBoneFromSkin skinMod
	    if rootBone == undefined then
	    (
	        format "跳过：% 未能推断 rootBone\n" theNode.name
	        return false
	    )
	    format "root_bone_node -> %\n" rootBone.name 

	    -- 预建 boneId -> boneNode 映射（skinOps 的 boneId 通常是 1..nBones）
	    local boneNodeById = #()
	    for i = 1 to nBones do
	    (
	        local bn = skinOps.GetBoneName skinMod i 0
	        local nodeRef = (getNodeByName bn)
	        boneNodeById[i] = nodeRef
	    )

	    local vertCount = skinOps.getNumberVertices skinMod
	    format "收集 Skin：% 顶点=% bones=% root=%\n" theNode.name vertCount nBones rootBone.name

	    -- weightsPerVertex[v] = #( #(boneId, weight), #(boneId, weight), ... )
	    local weightsPerVertex = #()
	    for v = 1 to vertCount do weightsPerVertex[v] = #()

	    for v = 1 to vertCount do
	    (
	        local wCount = skinOps.getVertexWeightCount skinMod v
	        if wCount == undefined or wCount <= 0 then continue

			local boneIdArray = #()
			local weightArray = #()
	        for wi = 1 to wCount do
	        (
	            local boneId = skinOps.getVertexWeightBoneId skinMod v wi
	            local w = skinOps.getVertexWeight skinMod v wi
				append boneIdArray boneId
				append weightArray w
	        )
	        weightsPerVertex[v] = #(boneIdArray, weightArray)
	    )

	    -- 2) 复制原模型，后续只对副本添加 Physique 并写权重
	    local newNode = copy theNode
	    newNode.name = uniqueName (theNode.name + "_physique")
	    format "创建副本：% -> %\n" theNode.name newNode.name
		new_skinMod = _getSkinMod newNode
		deleteModifier newNode new_skinMod

	    local phyMod = _getPhysiqueMod newNode
	    if phyMod == undefined do
	    (
	        try
	        (
	            phyMod = Physique()
	            addModifier newNode phyMod
	        )
	        catch
	        (
	            format "失败：% 无法创建 Physique()（请确认该版本是否有 Physique 修改器类）\n" newNode.name
	            return false
	        )
	    )

	    -- 绑定/初始化（使用收集到的 rootBone）
	    local ok1 = false
	    local ok2 = false
	    -- modifier(phyMod) 在 MaxScript 里是可选参数：只传 node/rootNode，避免参数个数错误
	    
	    ok1 = physiqueOps.attachToNode newNode rootBone
	    ok2 = physiqueOps.initialize newNode rootBone
	    

		--return false 


	    if (not ok1) or (not ok2) then
	    (
	        format "警告：% attach/initialize 可能失败 (attach=% init=%)\n" newNode.name ok1 ok2
	    )

	    --physiqueOps.setInitialPose newNode true
	    

	    -- 3) 写入每个顶点的骨权重
	    local pb = undefined
	    try
	    (
	        pb = progressbar title:("Skin->Physique: " + newNode.name) message:"写入顶点权重" total:vertCount
	    ) catch()
		--先选中副本，方便查看
		select newNode
		modPanel.setCurrentObject phyMod

	    for v = 1 to vertCount do
	    (
	        --if pb != undefined do progressbar.update pb (v as integer) (v as integer)

	        local wArr = weightsPerVertex[v]
	        if wArr == undefined or wArr.count == 0 then continue

	        --try (physiqueOps.lockVertex newNode v) catch()
	        local BonesArray = wArr[1]
	        local WeightsArray = wArr[2]

			firstBoneId = BonesArray[1]
			firstBoneNode = boneNodeById[firstBoneId]
			physiqueOps.setvertexbone newNode v firstBoneNode clear:true weight:0
	        for i = 1 to BonesArray.count do
	        (
	            local bnode = boneNodeById[BonesArray[i]]
	            local w = WeightsArray[i]
	            physiqueOps.setvertexbone newNode v bnode weight:w
	        )

	        --try (physiqueOps.unlockVertex newNode v) catch()
	    )

	    format "完成转换：% \n" newNode.name
	    true
	)
	on savePhy pressed do
	(
		if selection.count != 0 then
		(
			if selection.count == 1 then
			(
				Selected_Object = selection[1]

				msfilename = (getDir #temp )+ "\\ferril3.ms"

				Encoding = (dotNetClass "System.Text.Encoding").UTF8
				local FileIO = dotNetClass "System.IO.File"
				local fileText = ""
				local nl = "\n"
				-- if filters.Is_EditPoly() then
				-- 	sel = polyOp.getVertSelection $
				-- else sel = sel = getVertSelection $
				if (classof Selected_Object.baseobject) == Editable_Poly then
				(
					All_Vertices = polyop.getNumVerts Selected_Object
				)
				else
				(
					All_Vertices = getNumVerts Selected_Object
				)
				for v = 1 to All_Vertices do
				(		
					weightArray = #()
					_boneArray = #()

					for b = 1 to physiqueOps.getVertexBoneCount $ v do
					(
							_bone = physiqueOps.getVertexBone $ v b
							_bone = "$'" + _bone.name + "'"	
							weight = physiqueOps.getVertexWeight $ v b
							append weightArray weight
							append _boneArray _bone

							if b == physiqueOps.getVertexBoneCount $ v do
							(
								fileText += (v as string) + nl
								fileText += (weightArray as string) + nl
								fileText += (_boneArray as string) + nl
							)
					)
				)
				FileIO.WriteAllText msfilename fileText Encoding
				messagebox "已将顶点权重保存到临时文件。" Title:"已保存"
			)
			else messagebox "请仅在一个物体上选择顶点！" Title:"错误"
		)
		else messagebox "请先选择一个物体。" Title:"错误"
	)
	
	on loadPhyData pressed do
	(
		if selection.count != 0 then
		(
			Selected_Object = undefined
			if selection.count == 1 then
			(
				Selected_Object = selection[1]
				
				--Load the Data
				msfilename = (getDir #temp )+ "\\ferril3.ms"

				local FileIO = dotNetClass "System.IO.File"
				Encoding = (dotNetClass "System.Text.Encoding").UTF8

				local dotnetLines = FileIO.ReadAllLines msfilename Encoding
				local msLines = #()

				-- 过滤空行（兼容文件末尾换行）
				for ln in dotnetLines do
				(
					if ln != undefined do
					(
						ln = trimRight ln
						if ln != "" do append msLines ln
					)
				)

				local idx = 1
				while (idx + 2) <= msLines.count do
				(
					a = msLines[idx] --点 序号  ID
					b = msLines[idx + 1] -- 权重数组
					c = msLines[idx + 2] -- 骨骼数组

					Vert = execute a -- 1
					WeightsArray = execute b -- #(0.7, 0.3)
					BonesArray = execute c -- #("$'Bone001'","$'Bone002'")

					--Clear the weights (This is Physique specific)
					physiqueops.setvertexbone Selected_Object Vert (execute(BonesArray[1])) clear:true weight:0

					--Now Load the weights
					for i = 1 to BonesArray.count do
					(
						physiqueops.setvertexbone Selected_Object Vert (execute(BonesArray[i])) weight:WeightsArray[i]
					)

					idx += 3
				)
				messagebox "已从临时文件加载顶点权重。" Title:"已加载"
				slidertime = slidertime + 1
				slidertime = slidertime - 1
				--max views redraw
			)
			else messagebox "请只选择一个物体来加载保存的权重！" Title:"错误"
		)
		else messagebox "请先选择一个物体。" Title:"错误"
	)
	
	on saveSkin pressed do
	(
		if selection.count != 0 then
		(
			Selected_Object = undefined
			if selection.count == 1 then
			(
				Selected_Object = selection[1]
				subobjectlevel = 0
				msfilename = (getDir #temp )+ "\\ferril3.ms"
				Encoding = (dotNetClass "System.Text.Encoding").UTF8
				local FileIO = dotNetClass "System.IO.File"
				local fileText = ""
				local nl = "\n"
				if (classof selected_object.baseobject) == Editable_Poly then
				(
					All_Vertices = polyop.getNumVerts Selected_Object
				)
				else
				(
					All_Vertices = getNumVerts Selected_Object
				)
				-- if filters.Is_EditPoly() then
				-- 	sel = polyOp.getVertSelection $
				-- else sel = getVertSelection $
				SkinBody = _getSkinMod Selected_Object
				if SkinBody == undefined then
				(
					messagebox "请选择一个带 Skin 修改器的模型。" Title:"错误"
					return false
				)
				--All_Vertices = skinOps.GetNumberVertices SkinBody
				modPanel.setCurrentObject SkinBody
				
				for v=1 to All_Vertices do
				(
					weights = #()
					_bones = #()
		
					for b = 1 to skinOps.GetVertexWeightCount SkinBody v do
					(
						weight = skinOps.GetVertexWeight SkinBody v b
						_boneID = skinOps.GetVertexWeightBoneID SkinBody v b
						_bone = skinOps.GetBoneName SkinBody _boneID 1
						_bone = "$'" + _bone + "'"	
							
						if weight != 0 then
							(
							append weights weight
							append _bones _bone
							)
						else continue
					)
					
					fileText += (v as string) + nl
					fileText += (weights as string) + nl
					fileText += (_bones as string) + nl
				)

				FileIO.WriteAllText msfilename fileText Encoding
				messagebox "已将顶点权重保存到临时文件。" Title:"已保存"
			)
			else messagebox "请仅在一个物体上选择顶点！" Title:"错误"
		)
		else messagebox "请先选择一个物体。" Title:"错误"
	)
	
	on loadSkinData pressed do
	(
		if selection.count != 0 then
		(
			Selected_Object = undefined

			if selection.count == 1 then
			(
				Selected_Object = selection[1]

				SkinBody = _getSkinMod Selected_Object
				if SkinBody == undefined then
				(
					messagebox "请选择一个带 Skin 修改器的模型。" Title:"错误"
					return false
				)
				msfilename = (getDir #temp )+ "\\ferril3.ms"

				local FileIO = dotNetClass "System.IO.File"
				local Encoding = (dotNetClass "System.Text.Encoding").UTF8
				local dotnetLines = FileIO.ReadAllLines msfilename Encoding
				local msLines = #()
				for ln in dotnetLines do
				(
					if ln != undefined do
					(
						ln = trimRight ln
						if ln != "" do append msLines ln
					)
				)

				NameArray = #()
				NumBones = skinOps.GetNumberBones SkinBody
				for nb = 1 to NumBones do
				(
					BoneName = skinOps.GetBoneName SkinBody nb 0
					BoneName = "$'" + BoneName + "'"
					append NameArray BoneName
				)

				local idx = 1
				while (idx + 2) <= msLines.count do
				(
					a = execute msLines[idx]
					b = execute msLines[idx + 1]
					c = execute msLines[idx + 2]

					boneIDarray = #()
					for i = 1 to c.count do
					(
						BoneID = findItem NameArray c[i]
						append boneIDarray BoneID
					)

					skinOps.ReplaceVertexWeights SkinBody a boneIDarray b
					idx += 3
				)
			)
			else messagebox "请仅在一个物体上选择顶点！" Title:"错误"
		)
		else messagebox "请先选择一个物体。" Title:"错误"
	)
	
	on Extract pressed do
	(
		if selection.count == 1 do (
			sele_a = selection[1]
			try(skinUtils.ExtractSkinData sele_a)catch(messagebox "必须先选择一个带 Skin 修改器的模型。" Title:"错误")
		)
	)
	
	on ImportWts pressed do
	(
		if selection.count == 2 do
		(
			sel_a = selection[1]
			sel_b = selection[2]
			if matchpattern sel_a.name pattern:"SkinData" then(
				skinUtils.ImportSkinData sel_b sel_a
			)
			else (skinUtils.ImportSkinData sel_a sel_b)
		)
	)

	on btnRun pressed do
	(
	    local nodes = for o in selection collect o
	    if nodes.count == 0 do 
	    (
	        messageBox "请先选择带 Skin 的模型"
	        return false
	    )

	    for n in nodes do
	    (
	        ConvertOneNode_SkinToPhysique n  
	    )
	)

)
	
	--addRollout TRIphytools TRI_Tools
	createDialog TRIphytools

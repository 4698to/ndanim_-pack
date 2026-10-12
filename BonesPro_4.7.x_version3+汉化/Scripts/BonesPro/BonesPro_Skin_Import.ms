include "$Scripts\\BonesPro\\BonesPro.ms"

fn Skin_Import UI =
(
	local result = GetBonesPro()
	if result == undefined do
		return false
	
	local REF = result[1]
	local BP = result[2]
	if not BP.enabled do
	(
		if UI do messagebox "The BonesPro modifier is currently disabled. To allow correct data conversion with Skin the BonesPro modifier needs to be enabled." title:"Skin Export/Import"
		return false
	)
	if UI and (BP.num_bones() > 0 ) and not (querybox "Importing Skin modifier data will overwrite the current BonesPro mesh deformation. Do you want to continue the import?" title:"Skin Import") do
		return false
	
	local skinmod = undefined
	for m in REF.modifiers do
		if (iskindof m Skin) and m.enabled do
		(
			skinmod = m
			exit
		)
	if skinmod == undefined do
	(
		if UI do messagebox "Error:\nNo Skin modifier found on the object's modifier stack." title:"Skin Import"
		return false
	)
	
	--Skin modifier/skinOps utilities requires Modify tab to be active in the command panel (from MAXScript Help)
	setCommandPanelTaskMode mode:#modify
	modPanel.setCurrentObject skinmod node:REF ui:true
	
	local nodes = #()
	for b = 1 to skinops.GetNumberBones skinmod do
	(
		local name = skinops.GetBoneName skinmod b 0
		for obj in objects do
			if findItem nodes obj == 0 do
				if obj.name == name do
					append nodes obj
	)
	
	--If any exception occurs the viewport will remain disabled
	disablesceneredraw()
	BP.assign_bones nodes
	if BP.num_bones() > 0 do
	(
		--Disable all affecting options
		BP.soft_selection = false
		BP.use_edge_distance = false
		BP.use_dual_quaternion = false
		BP.bone_select_none()	
		local bones = #()
		local verts = getNumVerts REF
		for v = 1 to verts do
		(
			local number = skinops.GetVertexWeightCount skinmod v
			bones.count = number
			for b = 1 to number do
			(
				bones[b] = skinops.GetVertexWeightBoneID skinmod v b
				with undo off BP.set_bone_selected bones[b] true
			)
			for b = 1 to number do
				with undo off BP.set_force bones[b] v ((skinops.GetVertexWeight skinmod v b) * 100)
			BP.bone_select_none()
		)
		for b = 1 to BP.num_bones() do
			with undo off BP.set_bone_strength b (BP.get_bone_strength b)
		setSaveRequired true
	)
	enablesceneredraw()
	
	skinmod.enabled = false
	if UI do modPanel.setCurrentObject BP node:REF ui:true
	return true
)

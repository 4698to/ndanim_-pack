include "$Scripts\\BonesPro\\BonesPro.ms"

fn Skin_Export UI =
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
	local bones = #()
	local nodes = #()				
	local skinmod = skin()
	
	--Skin modifier/skinOps utilities requires Modify tab to be active in the command panel (from MAXScript Help)
	setCommandPanelTaskMode mode:#modify
	modPanel.setCurrentObject BP node:REF ui:true
	addmodifier REF skinmod before:(modPanel.getModifierIndex REF BP - 1) --(finditem REF.modifiers BP - 1)
	setSaveRequired true
	
	for b = 1 to BP.num_bones() do
	(
		local name = BP.get_bone_name b
		for obj in objects do
			if findItem nodes obj == 0 do
				if obj.name == name do
				(
					append bones b
					append nodes obj
					try
						skinops.addbone skinmod obj 0 --*exception* may occur when certain modifiers are above (i.e. TurboSmooth)
					catch
					(
						if UI do messagebox "Skin export failed." title:"Skin Export"
						return false
					)
				)
	)
	
	if bones.count > 0 do
	(
		--BonesPro does keep exact number of vertices it uses, but API hasn't been exposed by developer
		local verts = getNumVerts REF
		local weights = #()
		weights.count = bones.count
		for v = 1 to verts do
		(
			for b = 1 to bones.count do
				weights[b] = BP.get_weight b v
			with undo off 
				skinops.setvertexweights skinmod v bones weights
		)
	)
	BP.enabled = false
	return true		
)
fn GetBonesPro = 
(
	if selection.count == 0 do 
		return undefined
	
	local REF = selection[1]
	if REF == undefined do
		return undefined
	
	--If it is a user who clicked button then getCurrentObject should return BonesPro modifier immediatly
	--Or else it is external call i.e. from maxscript hence will be traversing modifiers, trying to get first enabled
	local BP = modPanel.getCurrentObject()
	if (BP == undefined) or not (iskindof BP BonesPro) do 
		for M in REF.modifiers do
			if (iskindof M BonesPro) and M.enabled do
			(
				BP = M
				exit
			)
	if (BP == undefined) or not (iskindof BP BonesPro) do 
		return undefined
			
	return #(REF,BP)
)
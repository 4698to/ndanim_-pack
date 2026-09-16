-- 2019-08-11
--99U:199505
--E-mail:738746223@qq.com
--UTF8
-- 开启物体材质在视口中的贴图显示
-- Standard：dxShaderManager.getViewportManager + activateDxStdMat
-- 其它：showTextureMap（需指定贴图通道）

fn ND_SetDxStdMat mat onOff =
(
	if classof mat != Standardmaterial do return false
	try
	(
		local mgr = dxShaderManager.getViewportManager mat
		if mgr != undefined do
		(
			mgr.activateDxStdMat onOff
			return true
		)
	)
	catch()
	-- try (mat.DirectX_Manager.dxStdMat = onOff) catch()
	-- try (enableHardwareMaterial mat onOff) catch()
	false
)

fn ND_GetPreferredViewportMap mat =
(
	if mat == undefined do return undefined

	local props = #(
		#diffuseMap, #base_color_map, #baseColorMap,
		#texmap_diffuse, #diffuse, #albedo_shader, #color_map
	)
	for p in props do
	(
		local tex = try (getProperty mat p) catch undefined
		if tex != undefined and (superclassof tex == textureMap) do
			return tex
	)

	local n = try (getNumSubTexmaps mat) catch 0
	for i = 1 to n do
	(
		local tex = getSubTexmap mat i
		if tex != undefined do return tex
	)
	undefined
)

fn ND_ShowMap_OnMat mat =
(
	if mat == undefined do return false

	local nMtl = try (getNumSubMtls mat) catch 0
	for i = 1 to nMtl do
		ND_ShowMap_OnMat (getSubMtl mat i)

	if classof mat == Standardmaterial then
	(
		ND_SetDxStdMat mat false
	)
	else
	(
		try (enableHardwareMaterial mat true) catch()
		local tex = ND_GetPreferredViewportMap mat
		if tex != undefined then
			try (showTextureMap mat tex true) catch()
		else
			try (showTextureMap mat true) catch()
	)

	true
)

for i in geometry where i.material != undefined do
	ND_ShowMap_OnMat i.material

try (completeRedraw()) catch()

-- 2019-08-11
--99U:199505
--E-mail:738746223@qq.com
--UTF8
-- 关闭物体材质在视口中的贴图显示
-- Standard：dxShaderManager.getViewportManager + activateDxStdMat
-- 其它：showTextureMap

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

fn ND_UnshowMap_OnMat mat =
(
	if mat == undefined do return false

	local nMtl = try (getNumSubMtls mat) catch 0
	for i = 1 to nMtl do
		ND_UnshowMap_OnMat (getSubMtl mat i)

	if classof mat == Standardmaterial then
	(
		ND_SetDxStdMat mat true
	)
	else
	(
		try (enableHardwareMaterial mat false) catch()
		try (showTextureMap mat false) catch()
		local n = try (getNumSubTexmaps mat) catch 0
		for i = 1 to n do
		(
			local tex = getSubTexmap mat i
			if tex != undefined do
				try (showTextureMap mat tex false) catch()
		)
	)

	true
)

for i in geometry where i.material != undefined do
	ND_UnshowMap_OnMat i.material

try (completeRedraw()) catch()

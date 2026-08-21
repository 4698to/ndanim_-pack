/*
2026-07-21 新增 C3特效组工具入口
*/

fn SRFindMenuItem theMenu theTitle = 
(
	local theItem=undefined
	for i=1 to theMenu.numItems() do
	(
		local theCurrItem=theMenu.getitem i
		if theCurrItem!=undefined and theCurrItem.gettitle()==theTitle then(
			theItem=theCurrItem
		)
	)
	theItem
)



macroScript NDBoxTool_01 category:"NDBoxTool_01" buttonText: "天晴动作工具栏"
(
	file_path = (getDir #scripts) + "\\NDToolsShortcut\\加载天晴工具条.ms"
	if doesFileExist file_path then (
		filein file_path
	)else(
		messageBox file_path title:"缺少"
	)
)

/* macroScript NDBoxTool_02 category:"NDBoxTool_02" buttonText: "上传分享反馈"
(
	file_path = (getDir #scripts) + "\\NDToolsShortcut\\upload_ndBox.ms"
	if doesFileExist file_path then (
		filein file_path
	)else(
		messageBox file_path title:"缺少"
	)
) */
macroScript NDBoxTool_03 category:"NDBoxTool_03" buttonText: "Bip动画库"
(
	file_path = (getDir #scripts) + "\\NDTools\\charactorAniTool\\BipedManager.ms"
	if doesFileExist file_path then (
		filein file_path
	)else(
		messageBox file_path title:"缺少"
	)
)
if ((menuMan.findMenu "NDBox") != undefined) then
(
	theFileMenu = menuMan.findMenu "NDBox"
	
	if (SRFindMenuItem theFileMenu "Bip动画库") == undefined do 
	(
		SeparatorItem = menuMan.createSeparatorItem()
		theFileMenu.addItem SeparatorItem (theFileMenu.numItems() + 1 )

		Action = menuMan.createActionItem "NDBoxTool_03" "NDBoxTool_03"
		theFileMenu.addItem Action (theFileMenu.numItems() + 1 )
	)

	if (SRFindMenuItem theFileMenu "天晴动作工具栏") == undefined do 
	(
		SeparatorItem = menuMan.createSeparatorItem()
		theFileMenu.addItem SeparatorItem (theFileMenu.numItems() + 1 )

		Action = menuMan.createActionItem "NDBoxTool_01" "NDBoxTool_01"
		theFileMenu.addItem Action (theFileMenu.numItems() + 1 )
	)

	/* if (SRFindMenuItem theFileMenu "上传分享反馈") == undefined do 
	(
		Action = menuMan.createActionItem "NDBoxTool_02" "NDBoxTool_02"
		theFileMenu.addItem Action (theFileMenu.numItems() + 1 )
	) */

	menuMan.updateMenuBar()
)







colorman.reInitIcons()



/*
--2021-1.1
2023-11-26
带C3工具的内部版本
*/
macroScript anim_layer_deletelayer
category:"MAX Script Tools"
tooltip:"清理动画层"
buttonText:"清理动画层"
icon:#("deletelayer", 1)
(
	filein ((getdir #maxroot)+"scripts\\NDTools\\deletelayer.mse")
)


-- 2020-03-15
macroScript helpTool
category:"NDTool"
tooltip:"动作组工具文档"
buttonText:"打开文档页面"
icon:#("help", 1)
(
	--动作组工具文档页面
	ShellLaunch "explorer.exe" "https://sundaybox.cc/"
)

-----------------批量工具
macroScript BatchTool
category:"NDTools"
tooltip:"批量工具"
buttonText:"批量工具"
(
	filein (getdir #maxroot+"scripts\\NDTools\\BatchToolDialog.mse")
)
--------------------贴图路径清理
macroScript ClearMissingBipMaps
category:"MAX Script Tools"
tooltip:"贴图路径清理"
buttonText:"贴图路径清理"
(
	filein (getdir #maxroot+"scripts\\NDTools\\MapPathCleanUp.mse")
)

--------------------AlignTool
macroScript AlignTool
category:"MAX Script Tools"
tooltip:"AlignTool"
buttonText:"AlignTool"
(
	filein (getdir #maxroot+"scripts\\NDTools\\AlignTool.mse")
)
--------------------骨骼动画镜像工具
macroScript AnimationMirror
category:"MAX Script Tools"
tooltip:"骨骼动画镜像工具"
buttonText:"AnimationMirror"
(
	filein (getdir #maxroot+"scripts\\NDTools\\AnimationMirror.mse")
)
--------------------柔体计算工具2
macroScript SpringTools
category:"MAX Script Tools"
tooltip:"柔体计算工具集合"
buttonText:"Spring Tools"
(
	filein (getdir #maxroot+"scripts\\NDTools\\SoftBodyToolGroup.mse")
)
--------------------模型检查修改工具_V1.02
macroScript CheckObjForSkin
category:"MAX Script Tools"
tooltip:"模型检查修改工具"
buttonText:"模型检查修改工具"
(
	filein (getdir #maxroot+"scripts\\NDTools\\CheckObjForSkin.mse")
)
--------------------BipedSelectionTools
macroscript cstools
category:"MAX Script Tools"
tooltip:"Biped Selection Tools"
buttontext:"Biped Selection Tools"
--icon:#("JJTools", 14)
(
	filein (getdir #maxroot+"scripts\\NDTools\\cstools.ms")
)
--------------------绑点镜像
macroscript MirrorWeights
category:"MAX Script Tools"
buttontext:"蒙皮权重工具"
tooltip:"蒙皮权重工具"
icon:#("NDweight", 1)
(
	fileIn (getDir #maxroot+"scripts\\NDTools\\ChangSkinWeight_v2.4.0.mse")
)
--------------------BoneSpring1.5
macroScript BoneSpring
category:"NDTools"
tooltip:"Bone Spring1.5"
buttonText:"Bone Spring1.5"
(
	filein (getdir #maxroot+"scripts\\NDTools\\BoneSpring1.5.mse")
)
--------------------可破坏物件
macroScript breakableObj_BB
category:"NDTools"
tooltip:"breakableObj"
buttonText:"可破坏物件"
(
	filein ((getdir #maxroot)+"scripts\\NDTools\\FractureVoronoi.mse")
)
--------------------角色动画工具
macroScript RescaleWU
category:"NDTools"
tooltip:"角色工具"
buttonText:"角色工具"
icon:#("BBToolsOld",15)
(
	filein ((getdir #maxroot)+"scripts\\NDTools\\RescaleWU.mse")
)
--------------------过滤选择_all
macroScript SetSelectFilter_all
category:"MAX Script Tools"
tooltip:"?过滤选择_all"
buttonText:"all"
icon:#("UVWUnwrapView", 10)
(
	filein ((getdir #maxroot)+"scripts\\NDTools\\SetSelectFilter_all.mse")
)
--------------------过滤选择_bone
macroScript SetSelectFilter_bone
category:"MAX Script Tools"
tooltip:"过滤选择_bone"
buttonText:"bone"
icon:#("Systems", 1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\SetSelectFilter_bone.mse")
)

--------------------过滤选择 相机
macroScript SetSelectFilter_Camera
category:"MAX Script Tools"
tooltip:"过滤选择_相机"
buttonText:"Camera"
icon:#("NDcamera", 1)
(
	SetSelectFilter 5
)
--------------------过滤选择_geo
macroScript SetSelectFilter_geometry
category:"MAX Script Tools"
tooltip:"过滤选择_Geo"
buttonText:"geo"
icon:#("UVWUnwrapTools2", 23)
(
	filein (getdir #maxroot+"scripts\\NDTools\\SetSelectFilter_geometry.mse")
)
--------------------过滤选择_helpers
macroScript SetSelectFilter_helpers
category:"MAX Script Tools"
tooltip:"过滤选择_helpers"
buttonText:"helpers"
icon:#("Helpers", 1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\SetSelectFilter_helpers.mse")
)
--------------------调用动画工具
macroScript animation_tools
category:"NDTools"
tooltip:"动画工具"
buttonText:"animation tools"
icon:#("BBToolsOld", 5)
(
	filein (getdir #maxroot+"scripts\\NDTools\\animation_tools_BB.mse")
)
--------------------动画轨迹工具组
macroScript AnimationToolGroup
category:"NDTools"
tooltip:"animation tools Group"
buttonText:"动画轨迹工具组"
icon:#("BBToolsTwo", 16)
(
	filein (getdir #maxroot+"scripts\\NDTools\\AnimationToolGroup.mse")
	)
--------------------动画复制工具
macroScript CopyAnimation
category:"MAX Script Tools"
tooltip:"动画复制工具"
buttonText:"动画复制工具"
icon:#("BBToolsOld", 6)
(
	filein (getdir #maxroot+"scripts\\NDTools\\CopyAnimation.mse")
)



macroScript CopyAnimation_New
category:"MAX Script Tools"
tooltip:"暴力帧拷贝黏贴"
buttonText:"暴力帧拷贝黏贴"
icon:#("BBToolsOld", 17)
(

	filein (getdir #maxroot+"scripts\\NDTools\\baoli_copy_anim_tools.mse")
)

--------------------C3分段导出工具
macroScript Export_skin_C3
category:"NDTools"
internalcategory:"NDTools"
tooltip:"AllC3Exporter"
buttonText:"C3分段导出工具"
--Icon:#("BBToolsOld",2)
Icon:#("NDC3",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\C3S3\\AllC3Exporter.mse")
)
-------------------S3导出工具
macroScript S3_BatExp
category:"NDTools"
internalcategory:"NDTools"
tooltip:"S3_BatExp"
buttonText:"S3导出工具"
--Icon:#("BBToolsOld",3)
Icon:#("NDS3",1)

(
	filein (getdir #maxroot+"scripts\\NDTools\\C3S3\\S3_BatExp.ms")
)
--------------------KeyTools
macroScript KeyTools
category:"NDTools"
internalcategory:"NDTools"
tooltip:"C3 打Key"
buttonText:"C3 Key"
--Icon:#("BBToolsOld",11)
Icon:#("NDkey",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\C3S3\\KeyTool2.1.mse")
)

macroScript C3Scence_socket
category:"NDTools"
internalcategory:"NDTools"
tooltip:"C3挂点"
buttonText:"C3挂点"
--Icon:#("BBToolsOld",11)
Icon:#("CHAdeMO",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\C3S3\\C3socket.mse")
)

-------------------------------------------------------------------
macroScript c3efftoolkit 
category:"NDTools" 
internalcategory:"NDTools"
buttonText:"C3_Eff"
toolTip:"C3_Eff_ToolKit"
Icon:#("Particles",1)
(
	local sFile = (GetDir #scripts) + "/C3_Eff_ToolKit_V1.0.mse"
	if (doesFileExist sFile) then (fileIn sFile)
	else (messageBox "Unable to locate the script.")
)
-------------------------------------------------------------------

/*
------------------C3批量导出工具
macroscript C3BatchExp
category:"MAX Script Tools"
buttonText:"BatchExpC3"
toolTip:"Batch C3 Tools"
--Icon:#("Maintoolbar", 49)
--silentErrors:truemacroscript C3BatchExp
(
	filein (getdir #maxroot+"scripts\\NDTools\\C3S3\\BatchExpC3.mcr")
)
*/
/*
------------------Skin To Physique绑点信息互导工具
macroscript Skin2Physique
category:"MAX Script Tools"
buttonText:"Skin2Physique"
toolTip:"Skin To Physique绑点信息互导工具"
--Icon:#("Maintoolbar", 49)
--silentErrors:truemacroscript C3BatchExp
(
	filein (getdir #maxroot+"scripts\\NDTools\\PhyToSkin.mse")
)
*/
--C3场景旋转工具
macroScript C3ScenceRota
category:"NDTools"
internalcategory:"NDTools"
buttonText:"C3ScenceRota"
toolTip:"C3场景旋转工具"
Icon:#("NDrotation",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\C3S3\\C3ScenceRota.mse")
)
--自定义工具集合
macroScript CustomScriptDialog
category:"NDTools"
buttonText:"CustomScriptDialog"
toolTip:"自定义工具集合"
(
	filein (getdir #maxroot+"scripts\\NDTools\\CustomScriptDialog.mse")
)
----------------打开MAX文件所在位置
macroScript OpenMaxPath
category:"NDTools"
internalcategory:"NDTools"
tooltip:"用文件浏览器打开MAX文件所在的目录"
buttonText:"OpenMAXPath"
--Icon:#("NDTools",2)
(
	ShellLaunch "explorer.exe" maxFilePath

)
----------------解决max2015中文乱码
macroscript ChangeLanguageCN
category:"MAX Script Tools"
buttonText:"ChangeLanguageCN"
toolTip:"Change Language Chinese"
--Icon:#("Maintoolbar", 49)
--silentErrors:truemacroscript C3BatchExp
(
	filein (getdir #maxroot+"scripts\\NDTools\\ChangeLanguageCN.mse")
)

----------------附着于PhysX工具条 选中Dynamic物体
macroscript SelectDynamic
category:"PhysX"
buttonText:"SelectDynamic"
toolTip:"选中所有的 Dynamic 物体"
(
	max select none
	sel = #()
	for c in geometry where (c.modifiers["MassFX Rigid Body"] != undefined) do
		(if c.modifiers["MassFX Rigid Body"].type == 1 do sel += c)
		select sel
)
----------------附着于PhysX工具条 选中Kinematic物体
macroscript SelectKinematic
category:"PhysX"
buttonText:"SelectKinematic"
toolTip:"选中所有的 Kinematic 物体"
(
	max select none
	sel = #()
	for c in geometry where (c.modifiers["MassFX Rigid Body"] != undefined) do
		(if c.modifiers["MassFX Rigid Body"].type == 2 do sel += c)
		select sel
)
----------------附着于PhysX工具条 选中Static物体
macroscript SelectStatic
category:"PhysX"
buttonText:"SelectDStatic"
toolTip:"选中所有的 Static 物体"
(
	max select none
	sel = #()
	for c in geometry where (c.modifiers["MassFX Rigid Body"] != undefined) do
		(if c.modifiers["MassFX Rigid Body"].type == 3 do sel += c)
		select sel
)
----------------附着于PhysX工具条 删除选中物体的MassFX编辑器
macroscript DeleteMassFXModifier
category:"PhysX"
buttonText:"Delete MassFX Modifier"
toolTip:"删除选中物体上的 MassFX 编辑器"
(
	for c in selection where c.modifiers["MassFX Rigid Body"] != undefined do deletemodifier c c.modifiers["MassFX Rigid Body"]
	redrawviews()
)


macroScript save_auto_name
category:"MAX Script Tools"
tooltip:"另保存"
buttonText:"保存"
icon:#("Sample",1)
(
	try (filein (getdir #maxroot+"scripts\\NDTools\\Save_FilePath_vip.ms"))catch()
)
----------------
macroScript auto_exportfbx
category:"MAX Script Tools"
tooltip:"导出FBX"
buttonText:"导出FBX"
icon:#("export",1)
(

	filein (getdir #maxroot+"scripts\\NDTools\\auto_export_FBX.mse")

)
----------------------------------------------------------------
macroScript collapse_select
category:"MAX Script Tools"
tooltip:"塌陷动画"
buttonText:"塌陷"
icon:#("layerscollaps",1)
(

	filein (getdir #maxroot+"scripts\\NDTools\\Set_Trajectories_collapse.mse")


)
----------------------------------------------------------------
macroScript select_anim_layer_node
category:"MAX Script Tools"
tooltip:"选择有动画层对象"
buttonText:"选择动画层"
icon:#("selectlayers",1)
(


	filein (getdir #maxroot+"scripts\\NDTools\\select_obj_anim_layer.mse")


)
----------------------------------------------------------------
----------------------------------------------------------------

	macroScript collapse_anim_layer_down
	category:"MAX Script Tools"
	tooltip:"以动画层帧为准塌陷"
	buttonText:"塌陷动画层下"
	icon:#("layerdown",1)
	(
		filein (getdir #maxroot+"scripts\\NDTools\\collapse_layers_max_min_down.mse")

	)
macroScript collapse_anim_layer_up_down
category:"MAX Script Tools"
tooltip:"上下层相加"
buttonText:"塌陷动画层上下相加"
icon:#("layer",1)
(

	filein (getdir #maxroot+"scripts\\NDTools\\collapse_layers_max_min_up_and_down.mse")

)
----------------------------------------------------------------
----------------------------------------------------------------
macroScript collapse_anim_layer_up
category:"MAX Script Tools"
tooltip:"以基础层帧为准塌陷"
buttonText:"塌陷动画层上"
icon:#("layerup",1)
(

	   filein (getdir #maxroot+"scripts\\NDTools\\collapse_layers_max_min_up.mse")

)
----------------------------------------------------------------
----------------------------------------------------------------
macroScript keys_simplify_curve
category:"MAX Script Tools"
tooltip:"自动删帧"
buttonText:"自动减帧"
icon:#("CurvedLine",1)
(

	filein (getdir #maxroot+"scripts\\NDTools\\simplify_curve.mse")

)
macroScript Tool_CS_369434754
category:"MAX Script Tools"
tooltip:"选择Biped"
buttonText:"选择Biped"
icon:#("NDToolsskeleton",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\Tool_CS_369434754.ms")
)

macroScript Tool_bone_369434754
category:"MAX Script Tools"
tooltip:"选择Bone"
buttonText:"选择Bone"
icon:#("NDToolsbone",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\Tool_bone_369434754.ms")
)

macroScript Tool_rig_01
category:"MAX Script Tools"
tooltip:"绑定约束工具组"
buttonText:"绑定约束工具组"
icon:#("NDTools_arm",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\yueshu_bang_ding_v1.7_9.mse")
)

macroScript Tool_show_01
category:"MAX Script Tools"
tooltip:"显示贴图"
buttonText:"显示贴图"
icon:#("deliciousmap",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\show_map.ms")
)
macroScript Tool_show_02
category:"MAX Script Tools"
tooltip:"不显示贴图"
buttonText:"不显示贴图"
icon:#("undeliciousmap",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\unshow_map.ms")
)

macroScript Tool_show_03
category:"MAX Script Tools"
tooltip:"显示Shaded模式"
buttonText:"显示Shaded模式"
icon:#("NDVisualStyleModeShaded",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\Shaded_mode_oth.ms")
)
macroScript Tool_show_04
category:"MAX Script Tools"
tooltip:"显示Clay模式"
buttonText:"显示Clay模式"
icon:#("NDVisualStyleModeClay",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\Shaded_mode_Clay.ms")
)

macroScript Tool_coordsys_01
category:"MAX Script Tools"
tooltip:"Local 坐标系"
buttonText:"Local 坐标系"
icon:#("coordsyslocal",1)
(

	toolMode.coordsys #local
)

macroScript Tool_coordsys_02
category:"MAX Script Tools"
tooltip:"world 坐标系"
buttonText:"world 坐标系"
icon:#("coordsysworld",1)
(
	toolMode.coordsys #world

)
macroScript Tool_Security_Essentials
category:"MAX Script Tools"
tooltip:"杀毒清理"
buttonText:"清理"
icon:#("Security_Essentials",1)
(
	filein (getdir #maxroot+"scripts\\NDTools\\Security_Essentials0.2.mse")
)

----------------------------------------------------------------

	/* try
	(
		if doesFileExist ((getDir #Scripts)+"\\NDTools\\Export_skin_C3_BB.mse") do
		(
			deletefile ((getDir #Scripts)+"\\NDTools\\Export_skin_C3_BB.mse")
		)
		if doesFileExist ((getDir #Scripts)+"\\NDTools\\skin2physique.ms") do
		(
			deletefile ((getDir #Scripts)+"\\NDTools\\skin2physique.ms")
		)
	)
	catch() */
----------------------------------------------------------------
	/*
	try (
		ClearFiles = getfiles ((getDir #maxroot)+"\\en-US\\UI\\NDTools*")
		for o in ClearFiles do
		(
			try(
				if (getFilenameFile o) != "NDTools4.3" do (deleteFile o)
			)catch()
		--	try deleteFile o catch()
		)
	)
	catch()*/
----------------------------------------------------------------

	--解决视口 Disabled 的问题	打开max和存储Max文件的时候 针对当前视口执行一次
	fn CloseViewDisabled =
	(
		NumView = viewport.numViews --取得初始窗口类型 是单窗口还是多窗口
		if NumView == 1 do (actionMan.executeAction 0 "50026") --如果是单窗口 变为多窗口

		InitialViewPort =  viewport.activeViewport
		for i= 1 to viewport.numViews do
		(
			viewport.activeViewport = i
			if not viewport.IsEnabled() do (actionMan.executeAction 0 "40126")
		)
		viewport.activeViewport = InitialViewPort

		if NumView == 1 do (actionMan.executeAction 0 "50026" )--恢复回原来的窗口类型
	)


	callbacks.removescripts id:#PoseDisableFile
	callbacks.removescripts id:#PoseDisableSave
	callbacks.addscript #filePostOpen "CloseViewDisabled()" id:#PoseDisableFile
	callbacks.addscript #filePreSave "CloseViewDisabled()" id:#PoseDisableSave

	fn PreOpenReset =
	(
		resetMaxFile #noPrompt
	)

	callbacks.removescripts id:#PreOpenReset
	callbacks.addscript #filePreOpen "PreOpenReset()" id:#PreOpenReset
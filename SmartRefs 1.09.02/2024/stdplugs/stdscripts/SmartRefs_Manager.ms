--this query works even if quiet mode is on
function SRQueryBox theMsg title:"SmartRefs" theBeep:false=
(
	local theReturn=false
	local theQuietMode=GetQuietMode()
	if (theQuietMode) then
		SetQuietMode false
	theReturn=queryBox theMsg title:title beep:theBeep
	if (theQuietMode) then
		SetQuietMode true
	theReturn
)

function SRSetIniInt key value=
(
	local iniFile=(getMAXIniFile())
	SetINISetting iniFile "SmartRefs" key ((value as integer) as string)
)

function SRGetIniInt key default=
(
	local iniFile=(getMAXIniFile())
	local theValue=GetINISetting iniFile "SmartRefs" key 
	if (theValue=="") then 
		theValue=default
	else
	(
		theValue=theValue as integer
		if (theValue==undefined) then
			theValue=default
	)
	theValue
)

function SRSetIniBool key value=
(
	if value then
		SRSetIniInt key 1
	else
		SRSetIniInt key 0
)

function SRGetIniBool key default=
(
	theValue=SRGetIniInt key default
	if (theValue!=0) then
		theValue=true
	else
		theValue=false
	theValue	
)


rollout SmartRefs_AdvancedReset "SmartRefs Advanced Reset" width:298 height:408
(
	--local functions
	local Initialize
	local Finalize
	local RefreshUI
	
	GroupBox 'UISelectionGroup' "Selection:" pos:[19,10] width:256 height:59 align:#left
	GroupBox 'UICategoryGroup' "Category:" pos:[18,77] width:258 height:124 align:#left
	GroupBox 'UIParametersGroup' "Parameters:" pos:[18,209] width:259 height:143 align:#left
	radiobuttons 'UISelection' "" pos:[43,28] width:123 height:32 labels:#("Selected References", "Selected Nodes") columns:1 align:#left
	--Category controls
	checkbox 'UICategoryAll' "All" pos:[45,97] width:70 height:19 align:#left
	checkbox 'UIGeometry' "Geometry" pos:[45,121] width:70 height:19 align:#left
	checkbox 'UIShapes' "Shapes" pos:[45,139] width:70 height:19 align:#left
	checkbox 'UILights' "Lights" pos:[45,157] width:70 height:19 align:#left
	checkbox 'UICameras' "Cameras" pos:[45,175] width:70 height:19 align:#left
	checkbox 'UIHelpers' "Helpers" pos:[157,121] width:70 height:19 align:#left
	checkbox 'UISpaceWarps' "Space Warps" pos:[157,139] width:85 height:19 align:#left
	checkbox 'UIParticleSystems' "Particle Systems" pos:[157,157] width:96 height:19 align:#left
	checkbox 'UIBoneObjects' "Bone Objects" pos:[157,175] width:85 height:19 align:#left
	--Parameters controls
	checkbox 'UIParametersAll' "All" pos:[45,229] width:77 height:19 align:#left
	checkbox 'UIBaseObject' "Base Object" pos:[45,253] width:77 height:19 align:#left
	checkbox 'UIModifiers' "Modifiers" pos:[45,271] width:70 height:19 align:#left
	checkbox 'UITransform' "Transform" pos:[45,289] width:70 height:19 align:#left
	checkbox 'UIMaterial' "Material" pos:[45,307] width:107 height:19 align:#left
	checkbox 'UIObjectProperties' "Object Properties" pos:[45,325] width:102 height:19 align:#left
	checkbox 'UIParenting' "Parenting" pos:[157,253] width:70 height:19 align:#left
	checkbox 'UIName' "Name" pos:[157,271] width:85 height:19 align:#left
	checkbox 'UILayer' "Layer" pos:[157,289] width:99 height:19 align:#left
	checkbox 'UIDeletedNodes' "Deleted Nodes" pos:[157,307] width:99 height:19 align:#left
	--Buttons
	button 'UIReset' "Reset" pos:[19,363] width:120 height:33 align:#left
	button 'UIClose' "Close" pos:[156,363] width:120 height:33 align:#left
	
	local CategoryControls=#(UIGeometry,UIShapes,UILights,UICameras,UIHelpers,UISpaceWarps,UIParticleSystems,UIBoneObjects)
	local ParametersControls=#(UIBaseObject,UIModifiers,UITransform,UIMaterial,UIObjectProperties,UIParenting,UIName,UILayer,UIDeletedNodes)
	
	function Initialize=
	(
		--load controls state
		UISelection.state=SRGetIniInt "AdvReset_Selection" 1
		for theControl in categoryControls do
			theControl.checked=SRGetIniBool ("AdvReset_"+theControl.name) 1
		for theControl in parametersControls do
			theControl.checked=SRGetIniBool ("AdvReset_"+theControl.name) 1	
		--refresh ui
		RefreshUI()
	)
	function Finalize=
	(
		--save controls state
		SRSetIniInt "AdvReset_Selection" UISelection.state
		for theControl in categoryControls do
			SRSetIniBool ("AdvReset_"+theControl.name) theControl.checked
		for theControl in parametersControls do
			SRSetIniBool ("AdvReset_"+theControl.name) theControl.checked
		
		--save dialog pos
		/*local SmartRefs_DlgPos=GetDialogPos SmartRefs_AdvancedReset
		SRSetIniInt "AdvReset_DlgPosX" SmartRefs_DlgPos.x
		SRSetIniInt "AdvReset_DlgPosY" SmartRefs_DlgPos.y*/
	)
	function RefreshUI=
	(
		--refresh enabled state
		case UISelection.state of
		(
			1:
			(
				--all checkboxes are enabled
				UICategoryAll.enabled=true
				for theControl in categoryControls do
					theControl.enabled=true
				UIParametersAll.enabled=true
				for theControl in parametersControls do
					theControl.enabled=true				
			)
			2:
			(
				--only parameter checkbox are enabled, except for "Deleted Nodes", the rest are disabled
				UICategoryAll.enabled=false
				for theControl in categoryControls do
					theControl.enabled=false
				UIParametersAll.enabled=true
				for theControl in parametersControls do
					theControl.enabled=true
				UIDeletedNodes.enabled=false
			)
			3:
			(
				--all checkbox are disabled
				UICategoryAll.enabled=false
				for theControl in categoryControls do
					theControl.enabled=false
				UIParametersAll.enabled=false
				for theControl in parametersControls do
					theControl.enabled=false
			)
		)
		
		--category all checkbox state
		local allOn=true
		local allOff=true
		for theControl in categoryControls do
		(
			if theControl.checked then
				allOff=false
			else
				allOn=false
		)
		if allOff then
			UICategoryAll.tristate=0
		else if allOn then
			UICategoryAll.tristate=1
		else
			UICategoryAll.tristate=2
		
		--parameters all checkbox state
		allOn=true
		allOff=true
		for theControl in parametersControls do
		(
			if theControl.checked then
				allOff=false
			else
				allOn=false
		)
		if allOff then
			UIParametersAll.tristate=0
		else if allOn then
			UIParametersAll.tristate=1
		else
			UIParametersAll.tristate=2
	)
	
	function DoReset=
	(
		local theSel
		case UISelection.state of
		(
			1: theSel="references"
			2: theSel="nodes"
			3: theSel="materials"
		)
		if (SRQueryBox ("Are you sure you want to reset the selected "+theSel+"?, this operation can't be undone.") title:"Advance Reset") then
		(
			resetCategory=#{}
			resetParameters=#{}
			
			for i=1 to categoryControls.count do
				if categoryControls[i].checked then
					append resetCategory i
				
			for i=1 to parametersControls.count do
				if parametersControls[i].checked then
					append resetParameters i
				
			smartrefs.advancedreset selection:UISelection.state category:resetCategory parameters:resetParameters
		)
	)
	
	--Rollout Events
	on SmartRefs_AdvancedReset open do Initialize()
	on SmartRefs_AdvancedReset close do Finalize()
	
	--Selection Controls Events
	on UISelection changed val do RefreshUI()
	
	--Category Controls Events
	on UICategoryAll changed val do
	(
		for theControl in categoryControls do
			theControl.checked=val
	)
	on UIGeometry changed val do RefreshUI()
	on UIShapes changed val do RefreshUI()
	on UILights changed val do RefreshUI()
	on UICameras changed val do RefreshUI()
	on UIHelpers changed val do RefreshUI()
	on UISpaceWarps changed val do RefreshUI()
	on UIParticleSystems changed val do RefreshUI()
	on UIBoneObjects changed val do RefreshUI()
	
	--Parameters Controls Events
	on UIParametersAll changed val do
	(
		for theControl in parametersControls do
			theControl.checked=val
	)
	on UIBaseObject changed val do RefreshUI()
	on UIModifiers changed val do RefreshUI()
	on UITransform changed val do RefreshUI()
	on UIMaterial changed val do RefreshUI()
	on UIObjectProperties changed val do RefreshUI()
	on UIParenting changed val do RefreshUI()
	on UIName changed val do RefreshUI()
	on UILayer changed val do RefreshUI()
	on UIDeletedNodes changed val do RefreshUI()
	
	--Buttons events
	on UIReset pressed do DoReset()
	on UIClose pressed do destroyDialog SmartRefs_AdvancedReset
)

--Main Rollout of the SmartRefs manager
rollout SmartRefs_Manager "SmartRefs" width:444 height:494
(
	local ready=false
	local ResizeCtrls
	local RefreshSmartRefsHelperList
	local RefreshSmartRefList
	local RefreshPropertiesControls
	local RefreshManager
	local InitializeIcons
	local InitializeUI
	
	local btI=((getdir #maxroot)+"UI_ln\\Icons\\SmartRefs_20i.bmp")
	local btA=((getdir #maxroot)+"UI_ln\\Icons\\SmartRefs_20a.bmp")
	local btIList=#()
	local btAList=#()
	local SmartRefsHelperList=#()
	local canRefresh=true
	local buttonsize=28
	local iconsize=20
	local lastFileName=""
	
	--List Context Menu Items
 	local SRCMI_File 
	local SRCMI_File_Open
	local SRCMI_File_OpenNewSession
	local SRCMI_File_RevealInExplorer
	local SRCMI_File_Overwrite	
	local SRCMI_File_SaveAs
	local SRCMI_SelectNodes
	local SRCMI_ShowDupNames
	
	--List Context Menu Functions
	local OnPopup
	local SelectNodes
	local OpenSmartRefFile
	local OpenSmartRefFileNewSession
	local RevealSmartRefFile
	local OverwriteSmartRefFile
	local SaveAsSmartRefFile
	local ShowDuplicatedNames
	
	label UIDummy "   " pos:[200,52] width:9 height:13
	button UIAdd "" tooltip:"Add Reference" align:#left  across:4 pos:[5,3] width:buttonsize height:buttonsize border:false 
	button UIReload "" tooltip:"Reload Reference" align:#left pos:[34,3] width:buttonsize height:buttonsize border:false 
	button UIRemove "" tooltip:"Remove Reference" align:#left  pos:[63,3] width:buttonsize height:buttonsize border:false
	button UIReset "" tooltip:"Reset Reference" align:#left  pos:[91,3] width:buttonsize height:buttonsize border:false 
	button UIDuplicate "" tooltip:"Duplicate Reference" align:#left  pos:[119,3] width:buttonsize height:buttonsize border:false 
	button UIMerge "" toolTip:"Merge Reference"   align:#left  pos:[147,3] width:buttonsize height:buttonsize  border:false
	GroupBox UIPropertiesGroup "Properties" pos:[6,32] width:430 height:218
	checkbox UIActive "Active" pos:[20,50] width:55 height:15
	checkbox UIUseNamePrefix "Use Name Prefix" pos:[120,50] width:115 height:15
	label UINameLabel "Name:    " pos:[20,70] width:52 height:17
	label UIFileNameLabel "File Name:" pos:[20,90] width:52 height:17
	edittext UIName "" pos:[70,70] width:400 height:17
	edittext UIFileName "" pos:[70,90] width:400 height:17
	button UIFileNameDir "..." pos:[500,90] width:30 height:20
	GroupBox UIProxyGroup "Proxy" pos:[11,112] width:418 height:66
	checkbox UIUseProxyViewport "Use in Viewport" pos:[20,130] width:98 height:15
	checkbox UIUseProxyRender "Use in Render" pos:[120,130] width:92 height:15 
	edittext UIProxyFileName "Proxy File Name:" pos:[20,150] width:400 height:17
	button UIProxyFileNameDir "..." pos:[500,150] width:30 height:20
	GroupBox UIAdvancedGroup "Advanced" pos:[12,182] width:417 height:60
	checkbox UIPersist "Persist in Scene" pos:[20,200] width:100 height:18 
	checkbox UIReloadIfChanged "Reload only if file has changed" pos:[120,200] width:166 height:18 visible:false
	radiobuttons UIPersistReloadType labels:#("Reload always","Reload if file has changed","Reload manually") pos:[120,200] offsets:#([0,0],[10,0],[20,0])
	checkbox UIOverlay "Overlay" pos:[20,220]   width:166 height:18 
	dotNetControl SmartRefList "system.windows.forms.listView" pos:[7,258] width:429 height:243
	
	--All the operations made when the Manager Dialog Box starts
	function Initialize=
	(
		if (SmartRefs==undefined) then
		(
			MessageBox "SmartRefs plugin is not properly loaded, Restart 3ds max or reinstall the plugin."
			DestroyDialog SmartRefs_Manager
		)
		else
		(
			InitializeIcons()
			resizeCtrls()
			InitializeUI()
			
			global SmartRefs_Manager_global=SmartRefs_Manager
			local theCallbackString="SmartRefs_Manager_global.RefreshManager()"
			callbacks.addScript #systemPostNew theCallbackString id:#SmartRefManagerResetCallback
			callbacks.addScript #systemPostReset theCallbackString id:#SmartRefManagerResetCallback
			callbacks.addScript #filePostOpen theCallbackString id:#SmartRefManagerResetCallback
			callbacks.addScript #nodeNameSet "SRM_notParam=callbacks.notificationParam(); if classof SRM_notParam[3]==SmartRefsHelper then SmartRefs_Manager_global.RefreshName SRM_notParam[3] SRM_notParam[2]" id:#SmartRefManagerResetCallback
			RefreshManager()
			try
			(
				smartrefs.checklicense()
			)
			catch
			(
				Messagebox "Error Initializing Manager" title:"Error"
			)
		)
	)
	--refresh the list of refs and the ui
	function RefreshManager=
	(
		if (canRefresh) then
		(
			RefreshSmartRefsHelperList()
			RefreshSmartRefList()
			local num=SmartRefsHelperList.count
			for i=1 to num where SmartRefsHelperList[i].selectedInManager do
			(
				SmartRefList.Items.Item[i-1].Focused=true
				SmartRefList.Items.Item[i-1].Selected=true
			)
			RefreshPropertiesControls()
		)
	)
	
	function CheckRefs=
	(
		local refreshFlag=false
		for ref in SmartRefsHelperList do
			if not (isvalidnode ref and classof ref==SmartRefsHelper) then
				refreshFlag=true
		if refreshFlag then
			RefreshManager()
	)
	--refresh the name of the defined smartref
	function RefreshName theSmartRef theNewName=
	(
		if (canRefresh) then
		(
			for i=1 to SmartRefsHelperList.count do
			(
				if SmartRefsHelperList[i]==theSmartRef then
				(
					SmartRefList.items.item[i-1].subitems.item[0].text=theNewName
					if (SmartRefList.selectedIndices.Count==1 and SmartRefList.Items.Item[i-1].Selected) then
						UIName.text=theNewName
				)
			)
		)
	)
	
	function CropIcon theBitmap theCount theNum =
	(
		theNum-=1
		local theWidth=theBitmap.width/theCount
		local theHeight=theBitmap.height
		local bm1=bitmap theWidth theHeight
		pasteBitmap theBitmap bm1 (box2 (theNum*theWidth) 0 (theNum*theWidth+theWidth)  theHeight) [0,0] 
		bm1
	)
	function InitializeIcons=
	(
		if ((maxversion())[1]>=19000) then
		(
			UIAdd.iconName="SmartRefs\Add"
			UIReload.iconName="SmartRefs\Reload"
			UIRemove.iconName="SmartRefs\Remove"
			UIReset.iconName="SmartRefs\Reset"
			UIDuplicate.iconName="SmartRefs\Duplicate"
			UIMerge.iconName="SmartRefs\Merge"
			
			UIAdd.iconSize=[iconSize,iconSize]
			UIReload.iconSize=[iconSize,iconSize]
			UIRemove.iconSize=[iconSize,iconSize]
			UIReset.iconSize=[iconSize,iconSize]
			UIDuplicate.iconSize=[iconSize,iconSize]
			UIMerge.iconSize=[iconSize,iconSize]
		)
		else
		(
			--the gamma must be disabled, otherwise the colors of the icons can look bad
			local colorCorrectionMode=IDisplayGamma.colorCorrectionMode
			if (colorCorrectionMode!=#none) then
				IDisplayGamma.colorCorrectionMode=#none
			UIAdd.images=#(btI,btA,14,1,1,8,8,true)
			UIReload.images=#(btI,btA,14,3,3,10,10,true)
			UIRemove.images=#(btI,btA,14,2,2,9,9,true)
			UIReset.images=#(btI,btA,14,6,6,13,13,true)
			UIDuplicate.images=#(btI,btA,14,4,4,11,11,true)
			UIMerge.images=#(btI,btA,14,7,7,14,14,true)
			if (colorCorrectionMode!=none) then
				IDisplayGamma.colorCorrectionMode=colorCorrectionMode
		)
	)
	--All the operations made for the UI when the manager Dialog Box starts
	function InitializeUI=
	(
		--Setup the forms view
		SmartRefList.view=(dotNetClass "system.windows.forms.view").details 
		SmartRefList.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
		SmartRefList.GridLines=true			--Show lines between the items. 
		SmartRefList.MultiSelect=true			--Allow for multiple selections. 
		SmartRefList.HideSelection =false
		--SmartRefList.BackColor=SmartRefList.BackColor.gray
		SmartRefList.BackColor = (dotnetclass "System.Drawing.SystemColors").Menu
		SmartRefList.gridlines=false
		SmartRefList.columns.add "Reference" 100
		SmartRefList.columns.add "On" 30
		SmartRefList.columns.add "PV" 30
		SmartRefList.columns.add "PR" 30
		SmartRefList.columns.add "FileName" 270
		SmartRefList.columns.add "ProxyFileName" -2
		
		-- create the context menu
		SRCM = (dotNetObject "System.Windows.Forms.ContextMenu")
		dotnet.addEventHandler SRCM "Popup" OnPopup
		--add the context menu items with handlers
		--File Menu Item
		SRCMI_File=SRCM.MenuItems.Add "&File"
		dotNet.setLifetimeControl SRCMI_File #dotnet
		
		--Open Menu SubItem
		SRCMI_File_Open=SRCMI_File.MenuItems.Add "&Open"
		dotNet.addEventHandler  SRCMI_File_Open "Click" OpenSmartRefFile
		dotNet.setLifetimeControl SRCMI_File_Open #dotnet
		--Open in New 3ds Max Session SubItem
		SRCMI_File_OpenNewSession=SRCMI_File.MenuItems.Add "Open in &New 3ds Max Session"
		dotNet.addEventHandler  SRCMI_File_OpenNewSession "Click" OpenSmartRefFileNewSession
		dotNet.setLifetimeControl SRCMI_File_OpenNewSession #dotnet
		--Reveal Location in Explorer SubItem
		SRCMI_File_RevealInExplorer=SRCMI_File.MenuItems.Add "&Reveal in Explorer"
		dotNet.addEventHandler  SRCMI_File_RevealInExplorer "Click" RevealSmartRefFile
		dotNet.setLifetimeControl SRCMI_File_RevealInExplorer #dotnet
		--Separator
		SRCMI_File.MenuItems.Add "-"
		--Overwrite Reference
		SRCMI_File_Overwrite=SRCMI_File.MenuItems.Add "&Overwrite"
		dotNet.addEventHandler  SRCMI_File_Overwrite "Click" OverwriteSmartRefFile
		dotNet.setLifetimeControl SRCMI_File_Overwrite #dotnet
		--Save As Reference
		SRCMI_File_SaveAs=SRCMI_File.MenuItems.Add "&Save As..."
		dotNet.addEventHandler  SRCMI_File_SaveAs "Click" SaveAsSmartRefFile
		dotNet.setLifetimeControl SRCMI_File_SaveAs #dotnet
		--SelectNodes Menu Item
		SRCMI_SelectNodes=SRCM.MenuItems.Add "&Select Nodes"
		dotNet.addEventHandler  SRCMI_SelectNodes "Click" SelectNodes
		dotNet.setLifetimeControl SRCMI_SelectNodes #dotnet
		--Show Duplicated Names
		SRCMI_ShowDupNames=SRCM.MenuItems.Add "Show &Duplicated Names"
		dotNet.addEventHandler  SRCMI_ShowDupNames "Click" ShowDuplicatedNames
		dotNet.setLifetimeControl SRCMI_ShowDupNames #dotnet
		SmartRefList.ContextMenu = SRCM
	)
	
	--The list of SmartRefs are collected
	function RefreshSmartRefsHelperList=
	(
		try
		(
			SmartRefsHelperList=SmartRefs.GetAllSmartRefs()
		)
		catch
		(
			Messagebox "Error Retrieving Smart Refs from the scene" title:"Error"
		)
	)
	--The Properties UI controls are updated depending of the SmartRefs Selected
	function RefreshPropertiesControls=
	(
		local num
		canRefresh=false
		undo "Select SmartRef" on
		(
			num=SmartRefsHelperList.count
			for i=1 to num do
				SmartRefsHelperList[i].selectedInManager=false
			num=SmartRefList.selectedIndices.Count
			for i=1 to num do
				SmartRefsHelperList[SmartRefList.selectedIndices.Item[i-1]+1].selectedInManager=true
		)
		canRefresh=true
		
		if (num<1) then
		(
			UIReload.enabled=false
			UIRemove.enabled=false
			UIReset.enabled=false
			UIDuplicate.enabled=false
			UIMerge.enabled=false
			
			UIDummy.text="  "--used to avoid UI flicker
			UIActive.enabled=false
			UIUseNamePrefix.enabled=false
			UIUseProxyViewport.enabled=false
			UIUseProxyRender.enabled=false
			UIName.enabled=false
			UINameLabel.enabled=false
			UIFileName.enabled=false
			UIFileNameDir.enabled=false
			UIFileNameLabel.enabled=false
			UIProxyFileName.enabled=false
			UIProxyFileNameDir.enabled=false
			UIPersist.enabled=false
			UIReloadIfChanged.enabled=false
			UIPersistReloadType.enabled=false
			UIOverlay.enabled=false
			
			UIActive.checked=false
			UIUseNamePrefix.checked=false
			UIName.text=""
			UIFileName.text=""
			UIProxyFileName.text=""
			UIUseProxyViewport.checked=false
			UIUseProxyRender.checked=false
			UIPersist.checked=false
			UIReloadIfChanged.checked=false
			UIPersistReloadType.state=0
			UIOverlay.checked=false
		)
		else if (num==1) then
		(
			local theSmartRef=SmartRefsHelperList[SmartRefList.selectedIndices.Item[0]+1]
			
			if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
			(
				UIReload.enabled=true
				UIRemove.enabled=true
				UIReset.enabled=true
				UIDuplicate.enabled=true
				UIMerge.enabled=true
				
				UIDummy.text="  "--used to avoid UI flicker
				UIActive.enabled=true
				UIUseNamePrefix.enabled=true
				UIName.enabled=true
				UIName.readonly=false
				UINameLabel.enabled=true
				UIFileName.enabled=true
				UIFileNameDir.enabled=true
				UIFileNameLabel.enabled=true
				UIProxyFileName.enabled=true
				UIProxyFileNameDir.enabled=true
				UIUseProxyViewport.enabled=true
				UIUseProxyRender.enabled=true
				UIPersist.enabled=true
				UIReloadIfChanged.enabled=theSmartRef.PersistRef
				UIPersistReloadType.enabled=theSmartRef.PersistRef
				UIOverlay.enabled=true
				
				UIActive.checked=theSmartRef.active
				UIUseNamePrefix.checked=theSmartRef.useNamePrefix
				UIName.text=theSmartRef.name
				if (theSmartRef.FileName!=undefined) then
					UIFileName.text=theSmartRef.FileName
				else
					UIFileName.text=""
				if (theSmartRef.ProxyFileName!=undefined) then
					UIProxyFileName.text=theSmartRef.ProxyFileName
				else
					UIProxyFileName.text=""
				UIUseProxyViewport.checked=theSmartRef.UseProxyInViewport
				UIUseProxyRender.checked=theSmartRef.UseProxyInRender
				UIPersist.checked=theSmartRef.PersistRef
				UIReloadIfChanged.checked=theSmartRef.ReloadIfChanged
				UIPersistReloadType.state=theSmartRef.PersistReloadType+1
				UIOverlay.checked=theSmartRef.Overlay
			)
			else
				RefreshManager()
		)
		else
		(
			UIReload.enabled=true
			UIRemove.enabled=true
			UIReset.enabled=true
			UIDuplicate.enabled=true
			UIMerge.enabled=true
			
			UIDummy.text="  "--used to avoid UI flicker
			UIActive.enabled=true
			UIUseNamePrefix.enabled=true
			UIUseProxyViewport.enabled=true
			UIUseProxyRender.enabled=true
			UIName.enabled=true
			UIName.readonly=true
			UINameLabel.enabled=true
			UIFileName.enabled=true
			UIFileNameDir.enabled=true
			UIFileNameLabel.enabled=true
			UIProxyFileName.enabled=true
			UIProxyFileNameDir.enabled=true
			UIPersist.enabled=true
			UIOverlay.enabled=true
			UIName.text="<"+(num as string)+" Selected>"
			
			local activeTrue=true
			local activeFalse=true
			local useNamePrefixTrue=true
			local useNamePrefixFalse=true
			local proxyViewportTrue=true
			local proxyViewportFalse=true
			local proxyRenderTrue=true
			local proxyRenderFalse=true
			local fileName=undefined
			local proxyFileName=undefined
			local persistRefTrue=true
			local persistRefFalse=true
			local reloadIfChangedTrue=true
			local reloadIfChangedFalse=true
			local persistReloadTypeState=SmartRefsHelperList[1].persistReloadType
			local overlayTrue=true
			local overlayFalse=true
			local isValid=true
			
			for i=1 to num do
			(
				local theSmartRef=SmartRefsHelperList[SmartRefList.selectedIndices.Item[i-1]+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					if theSmartRef.Active then
						activeFalse=false
					else
						activeTrue=false
					if theSmartRef.useNamePrefix then
						useNamePrefixFalse=false
					else
						useNamePrefixTrue=false
					if theSmartRef.UseProxyInViewport then
						proxyViewportFalse=false
					else
						proxyViewportTrue=false
					if theSmartRef.UseProxyInRender then
						proxyRenderFalse=false
					else
						proxyRenderTrue=false
					
					if (fileName==undefined) then
						fileName=theSmartRef.fileName
					else if (fileName!=theSmartRef.fileName) then
						fileName=""
					
					if (proxyFileName==undefined) then
						proxyFileName=theSmartRef.proxyFileName
					else if (proxyFileName!=theSmartRef.proxyFileName) then
						proxyFileName=""
					
					if theSmartRef.PersistRef then
						persistRefFalse=false
					else
						persistRefTrue=false
					
					if theSmartRef.ReloadIfChanged then
						reloadIfChangedFalse=false
					else
						reloadIfChangedTrue=false
					
					if (SmartRefsHelperList[i].persistReloadType!=persistReloadTypeState) then
						persistReloadTypeState=-1
					
					if theSmartRef.Overlay then
						overlayFalse=false
					else
						overlayTrue=false
				)
				else
					isValid=false
			)
			
			if isValid then
			(
				if activeTrue then
					UIActive.tristate=1
				else if activeFalse then
					UIActive.tristate=0
				else
					UIActive.tristate=2
				
				if useNamePrefixTrue then
					UIUseNamePrefix.tristate=1
				else if useNamePrefixFalse then
					UIUseNamePrefix.tristate=0
				else
					UIUseNamePrefix.tristate=2
				
				if proxyViewportTrue then
					UIUseProxyViewport.tristate=1
				else if proxyViewportFalse then
					UIUseProxyViewport.tristate=0
				else
					UIUseProxyViewport.tristate=2
				
				if proxyRenderTrue then
					UIUseProxyRender.tristate=1
				else if proxyRenderFalse then
					UIUseProxyRender.tristate=0
				else
					UIUseProxyRender.tristate=2
				
				if (fileName!=undefined) then
					UIFileName.text=fileName
				else 
					UIFileName.text=""
				if (proxyFileName!=undefined) then
					UIProxyFileName.text=proxyFileName
				else
					UIProxyFileName.text=""
				
				if persistRefTrue then
				(
					UIPersist.tristate=1
					UIReloadIfChanged.enabled=true
					UIPersistReloadType.enabled=true
				)
				else if persistRefFalse then
				(
					UIPersist.tristate=0
					UIReloadIfChanged.enabled=false
					UIPersistReloadType.enabled=false
				)
				else
				(
					UIPersist.tristate=2
					UIReloadIfChanged.enabled=true
					UIPersistReloadType.enabled=true
				)
				
				if reloadIfChangedTrue then
					UIReloadIfChanged.tristate=1
				else if reloadIfChangedFalse then
					UIReloadIfChanged.tristate=0
				else
					UIReloadIfChanged.tristate=2
				
				UIPersistReloadType.state=persistReloadTypeState+1
				
				if overlayTrue then
					UIOverlay.tristate=1
				else if overlayFalse then
					UIOverlay.tristate=0
				else
					UIOverlay.tristate=2
			)
			else
				RefreshManager()
		)
	)
	--the UI of the SmartRef List is updated
	function RefreshSmartRefList=
	(
		itemArray=#()
		for i=1 to SmartRefsHelperList.count do
		(
			newItem=dotNetObject "System.Windows.Forms.ListViewItem" SmartRefsHelperList[i].name
			if (SmartRefsHelperList[i].Active) then
				newItem.subitems.add "Yes"
			else
				newItem.subitems.add "No"
			if (SmartRefsHelperList[i].UseProxyInViewport) then
				newItem.subitems.add "Yes"
			else
				newItem.subitems.add "No"
			if (SmartRefsHelperList[i].UseProxyInRender) then
				newItem.subitems.add "Yes"
			else
				newItem.subitems.add "No"
			if (SmartRefsHelperList[i].fileName!=undefined) then
				newItem.subitems.add SmartRefsHelperList[i].fileName
			else
				newItem.subitems.add ""
			if (SmartRefsHelperList[i].ProxyFileName!=undefined) then
				newItem.subitems.add SmartRefsHelperList[i].ProxyFileName
			else
				newItem.subitems.add ""
			append itemArray newItem		--Added the listViewItem to the rows array
		)
		SmartRefList.items.Clear()
		SmartRefList.items.addRange itemArray
	)
	--Updating of UÏ controls when the Dialog Box is resized
	function ResizeCtrls=
	(
		UIPropertiesGroup.width=SmartRefs_Manager.width-13
		UIProxyGroup.width=SmartRefs_Manager.width-25
		UIAdvancedGroup.width=SmartRefs_Manager.width-25
		SmartRefList.width=SmartRefs_Manager.width-13
		SmartRefList.height=SmartRefs_Manager.height-SmartRefList.pos.y-7
		UIName.width=SmartRefs_Manager.width-94
		UIFileName.width=SmartRefs_Manager.width-128
		UIFileNameDir.pos.x=SmartRefs_Manager.width-50
		UIProxyFileName.width=SmartRefs_Manager.width-159
		UIProxyFileNameDir.pos.x=SmartRefs_Manager.width-50
	)
	--
	function SelectSmartRef index=
	(
		index-=1
		if (index<0) then
			index=0
		else if (index>=SmartRefList.Items.count) then
			index=SmartRefList.Items.count-1
		SmartRefList.Items.Item[index].Focused=true
		SmartRefList.Items.Item[index].Selected=true
		RefreshPropertiesControls()
	)
	--A new SmartRef is added
	function AddSmartRef=
	(
		try
		(
			canRefresh=false
			smartrefs.addsmartrefdialog()
			canRefresh=true
		)
		catch
		(
			canRefresh=true
			Messagebox "Error Adding Reference" title:"Error"
		)
		RefreshManager()
	)
	--the selected SmartRefs are removed
	function RemoveSmartRef=
	(
		try
		(
			local num=SmartRefList.selectedIndices.Count
			local indices=#()
			for i=1 to num do
				append indices (SmartRefList.selectedIndices.Item[i-1]+1)
			canRefresh=false
			smartRefs.RemoveSmartRefs indices
			canRefresh=true
		)
		catch
		(
			canRefresh=true
			Messagebox "Error Removing Reference" title:"Error"
		)
		RefreshManager()
	)
	--the selected SmartRefs are duplicated
	function DuplicateSmartRef=
	(
		try
		(
			local num=SmartRefList.selectedIndices.Count
			local indices=#()
			for i=1 to num do
				append indices (SmartRefList.selectedIndices.Item[i-1]+1)
			canRefresh=false
			smartRefs.DuplicateSmartRefs indices
			canRefresh=true
		)
		catch
		(
			canRefresh=true
			Messagebox "Error Duplicating Reference" title:"Error"
		)
		RefreshManager()
	)
	--the selected SmartRef are reloaded
	function ReloadSmartRef=
	(
		try
		(
			local num=SmartRefList.selectedIndices.Count
			local indices=#()
			for i=1 to num do
				append indices (SmartRefList.selectedIndices.Item[i-1]+1)
			smartRefs.ReloadSmartRefs indices
		)
		catch
		(
			Messagebox "Error Reloading Reference" title:"Error"
		)
	)
	--the selected SmartRef are Reset
	function ResetSmartRef=
	(
		try
		(
			local num=SmartRefList.selectedIndices.Count
			local index
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				SmartRefsHelperList[index+1].Reset()
			)
		)
		catch
		(
			Messagebox "Error Resetting Reference" title:"Error"
		)
	)
	--the selected SmartRef are Merged
	function MergeSmartRef=
	(
		try
		(
			local num=SmartRefList.selectedIndices.Count
			local index
			canRefresh=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				SmartRefsHelperList[index+1].Merge()
			)
			canRefresh=true
		)
		catch
		(
			Messagebox "Error Merging Reference" title:"Error"
		)
		RefreshManager()
	)
	--Context Menu Function, disabled some menu items that work when only one ref is selected
	function OnPopup sender arg =
	(
		local numSel=SmartRefList.SelectedItems.count
		
		if (numSel==1) then
		(
			SRCMI_File_Open.enabled=true
			SRCMI_File_OpenNewSession.enabled=true
			SRCMI_File_RevealInExplorer.enabled=true
			SRCMI_File_SaveAs.enabled=true
			SRCMI_ShowDupNames.enabled=true
		)
		else
		(
			SRCMI_File_Open.enabled=false
			SRCMI_File_OpenNewSession.enabled=false
			SRCMI_File_RevealInExplorer.enabled=false
			SRCMI_File_SaveAs.enabled=false
			SRCMI_ShowDupNames.enabled=false
		)
		
		if (numSel>0) then
		(
			SRCMI_SelectNodes.enabled=true
			SRCMI_File_Overwrite.enabled=true
		)
		else
		(
			SRCMI_SelectNodes.enabled=false
			SRCMI_File_Overwrite.enabled=false
		)
	)
	--Context Menu Function, selects the nodes of the selected references
	function SelectNodes sender arg =
 	(
		local theNodesToSelect=#()
		for i=1 to SmartRefList.SelectedItems.count do
		(
			local theIndex=SmartRefList.SelectedItems.Item[i-1].index+1
			if (theIndex<=SmartRefsHelperList.count) then
			(
				local theSR=SmartRefsHelperList[theIndex]
				if ((IsValidNode theSR) and (classof theSR==SmartRefsHelper)) then
					join theNodesToSelect (theSR.GetNodes())
			)
		)
		if theNodesToSelect.count>0 then
			select theNodesToSelect
		else
			clearselection()
 	)
	--Context Menu Function, opens the file of the selected reference
	function OpenSmartRefFile sender arg =
 	(
		if (SmartRefList.SelectedItems.count>0) then
		(
			local theIndex=SmartRefList.SelectedItems.Item[0].index+1
			if (theIndex>0 and theIndex<=SmartRefsHelperList.count) then
			(
				local theSR=SmartRefsHelperList[theIndex]
				if ((IsValidNode theSR) and (classof theSR==SmartRefsHelper)) then
				(
					if (checkForSave()) then
						loadMaxFile theSR.filename quiet:false
				)
			)
		)
 	)
	--Context Menu Function, opens the file of the selected reference in a new 3ds max session
	function OpenSmartRefFileNewSession sender arg =
 	(
		if (SmartRefList.SelectedItems.count>0) then
		(
			local theIndex=SmartRefList.SelectedItems.Item[0].index+1
			if (theIndex>0 and theIndex<=SmartRefsHelperList.count) then
			(
				local theSR=SmartRefsHelperList[theIndex]
				if ((IsValidNode theSR) and (classof theSR==SmartRefsHelper)) then
					ShellLaunch ((getDir #maxroot)+"3dsmax.exe") ("\""+theSR.filename+"\"")
			)
		)
 	)
	--Context Menu Function, reveals the file of the selected reference in the explorer
	function RevealSmartRefFile sender arg =
 	(
		if (SmartRefList.SelectedItems.count>0) then
		(
			local theIndex=SmartRefList.SelectedItems.Item[0].index+1
			if (theIndex>0 and theIndex<=SmartRefsHelperList.count) then
			(
				local theSR=SmartRefsHelperList[theIndex]
				if ((IsValidNode theSR) and (classof theSR==SmartRefsHelper)) then
					shellLaunch "explorer.exe" ("/select,\""+theSR.filename+"\"")
			)
		)
 	)
	--Context Menu Function, overwrites the selected references, that means all the referenced nodes with the modifications
	--made in the master file are saved over the source file.
	function OverwriteSmartRefFile sender arg =
 	(
		if (SRQueryBox "Are you sure you want to overwrite the selected references?, this operation can't be undone." title:"Overwrite Reference") then
		(
			for i=1 to SmartRefList.SelectedItems.count do
			(
				local theIndex=SmartRefList.SelectedItems.Item[i-1].index+1
				if (theIndex<=SmartRefsHelperList.count) then
				(
					local theSR=SmartRefsHelperList[theIndex]
					if ((IsValidNode theSR) and (classof theSR==SmartRefsHelper)) then
						theSR.Overwrite()
				)
			)
		)
 	)
	
	--Context Menu Function, save the selected reference to a specific file, that means all the referenced nodes with the modifications
	--made in the master file are saved in the specified file name (save dialog box).
	function SaveAsSmartRefFile sender arg =
 	(
		if (SmartRefList.SelectedItems.count>0) then
		(
			local theIndex=SmartRefList.SelectedItems.Item[0].index+1
			if (theIndex>0 and theIndex<=SmartRefsHelperList.count) then
			(
				local theSR=SmartRefsHelperList[theIndex]
				if ((IsValidNode theSR) and (classof theSR==SmartRefsHelper)) then
				(
					local theFileName=theSR.mainfilepath
					theFileName=getSaveFileName caption:("Save Reference "+theSR.name+" As...") filename:theFileName types:"3ds max(*.max)|*.max"  historyCategory:"SmartRefs"
					if (theFileName!=undefined) then
						theSR.SaveAs theFileName
				)
			)
		)
		
		
 	)
	
	--Context Menu Function, show duplicated names in the selected reference
	function ShowDuplicatedNames sender arg =
 	(
		if (SmartRefList.SelectedItems.count>0) then
		(
			local theIndex=SmartRefList.SelectedItems.Item[0].index+1
			if (theIndex>0 and theIndex<=SmartRefsHelperList.count) then
			(
				local theSR=SmartRefsHelperList[theIndex]
				if ((IsValidNode theSR) and (classof theSR==SmartRefsHelper)) then
					theSR.showdupnames()
			)
		)
 	)
	
	on SmartRefs_Manager open do
	(
		Initialize()
	)
	on SmartRefs_Manager close do
	(
		SmartRefs_Manager_global=undefined
		callbacks.removeScripts id:#SmartRefManagerResetCallback
		local dlgSize=GetDialogSize SmartRefs_Manager
		if (dlgSize.x>0) then
		(
			global SmartRefs_DlgSize=dlgSize
			global SmartRefs_DlgPos=GetDialogPos SmartRefs_Manager
			SRSetIniInt "DlgSizeX" SmartRefs_DlgSize.x
			SRSetIniInt "DlgSizeY" SmartRefs_DlgSize.y
			SRSetIniInt "DlgPosX" SmartRefs_DlgPos.x
			SRSetIniInt "DlgPosY" SmartRefs_DlgPos.y
		)
		if (SmartRefs_AdvancedReset!=undefined) then
			destroydialog SmartRefs_AdvancedReset
	)
	on SmartRefs_Manager resized val  do
	(
		resizeCtrls()
	)
	on UIAdd pressed do
	(
		AddSmartRef()
	)
	on UIReload pressed do
	(
		ReloadSmartRef()
	)
	on UIRemove pressed do
	(
		if (SRQueryBox "Are you sure you want to remove the selected references?, this operation can't be undone." title:"Remove Reference") then
			RemoveSmartRef()
	)
	on UIReset pressed do
	(
		if (SRQueryBox "Are you sure you want to reset the selected references?, this operation can't be undone." title:"Reset Reference") then
			ResetSmartRef()
	)
	on UIDuplicate pressed do
	(
		DuplicateSmartRef()
	)
	on UIMerge pressed do
	(
		if (UIUseProxyViewport.state==0) then
		(
			if (SRQueryBox "Are you sure you want to merge the selected references?, this operation can't be undone." title:"Merge Reference") then
				MergeSmartRef()
		)
		else
		(
			--it's important  to use a warning message that is noticeable different for the default one.
			rollout MergeProxyWarning "Merge References and Proxies" width:550 height:160
			(
				label UIWarningText1 "One or more selected references are used as Proxy in the viewport." offset:[0,20]
				label UIWarningText2 "The Proxy will be merged for those references, this action can't be undone."
				label UIWarningText3 "Do you want to continue?."
				
				button UICancel "Cancel" across:4 width:120 height:25 offset:[130,20] 
				button UIOk "Continue"  width:120 height:25  offset:[130,20] 
				
				on MergeProxyWarning open do
				(
					global SmartRefs_MergeWithProxies_State=false
				)
				on UICancel pressed do
				(
					global SmartRefs_MergeWithProxies_State=false
					destroydialog MergeProxyWarning
				)
				on UIOK pressed do
				(
					global SmartRefs_MergeWithProxies_State=true
					destroydialog MergeProxyWarning
				)
			) 
			createdialog MergeProxyWarning modal:true
			if (SmartRefs_MergeWithProxies_State) then 
				MergeSmartRef()
		)
	)
	on UIActive changed val do
	(
		try
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					if (val) then
						SmartRefList.items.item[index].subitems.item[1].text="Yes"
					else
						SmartRefList.items.item[index].subitems.item[1].text="No"
					SmartRefsHelperList[index+1].Active=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
		catch
		(
			canRefresh=true
			MessageBox "Error Toggling Reference" title:"Error"
			RefreshManager()
		)
	)
	on UIUseNamePrefix changed val do
	(
		try
		(
			undo on
			(
				canRefresh=false
				local num=SmartRefList.selectedIndices.Count
				local index
				local isNotValid=false
				for i=1 to num do
				(
					index=SmartRefList.selectedIndices.Item[i-1]
					local theSmartRef=SmartRefsHelperList[index+1]
					if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
					(
						--TODO this part in green
						/*if (val) then
							SmartRefList.items.item[index].subitems.item[3].text="Yes"
						else
							SmartRefList.items.item[index].subitems.item[3].text="No"*/
						SmartRefsHelperList[index+1].useNamePrefix=val
					)
					else
						isNotValid=true
				)
				if isNotValid then
					RefreshManager()
				canRefresh=true
			)
		)
		catch
		(
			canRefresh=true
			MessageBox "Error Renaming Referenced Nodes" title:"Error"
			RefreshManager()
		)
	)
	on UIName entered val do
	(
		undo on
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					SmartRefList.items.item[index].subitems.item[0].text=val
					SmartRefsHelperList[index+1].name=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
	)
	on UIFileName entered val do
	(
		try
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local theSmartRef
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					SmartRefList.items.item[index].subitems.item[4].text=val
					SmartRefsHelperList[index+1].fileName=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
		catch
		(
			canRefresh=true
			MessageBox "Error changing Reference file path" title:"Error"
			RefreshManager()
		)
	)
	on UIFileNameDir pressed do
	(
		try
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			if (num>0) then
			(
				local index=SmartRefList.selectedIndices.Item[0]
				local theSmartRef=SmartRefsHelperList[index+1]
				local theFileName=""
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					theFileName=SmartRefsHelperList[index+1].fileName
					if (theFileName==undefined or theFileName=="") then
						theFileName=MaxFilePath
				)
					
				theFileName=getOpenFileName caption:("Select file for reference "+theSmartRef.name) filename:theFileName types:"3ds max(*.max)|*.max"  historyCategory:"SmartRefs"
				if (theFileName!=undefined) then
				(
					UIFileName.text=theFileName
					local isNotValid=false
					for i=1 to num do
					(
						index=SmartRefList.selectedIndices.Item[i-1]
						theSmartRef=SmartRefsHelperList[index+1]
						if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
						(
							SmartRefList.items.item[index].subitems.item[4].text=theFileName
							SmartRefsHelperList[index+1].fileName=theFileName
						)
						else
							isNotValid=true
					)
					if isNotValid then
						RefreshManager()
				)
			)
			canRefresh=true
		)
		catch
		(
			canRefresh=true
			MessageBox "Error changing Reference file path" title:"Error"
			RefreshManager()
		)
	)
	on UIUseProxyViewport changed val do
	(
		try
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					if (val) then
						SmartRefList.items.item[index].subitems.item[2].text="Yes"
					else
						SmartRefList.items.item[index].subitems.item[2].text="No"
					SmartRefsHelperList[index+1].UseProxyInViewport=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
		catch
		(
			canRefresh=true
			MessageBox "Error Reloading Reference" title:"Error"
			RefreshManager()
		)
	)
	on UIUseProxyRender changed val do
	(
		undo on
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					if (val) then
						SmartRefList.items.item[index].subitems.item[3].text="Yes"
					else
						SmartRefList.items.item[index].subitems.item[3].text="No"
					SmartRefsHelperList[index+1].UseProxyInRender=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
	)
	on UIProxyFileName entered val do
	(
		try
		(
			undo on
			(
				canRefresh=false
				local num=SmartRefList.selectedIndices.Count
				local index
				local theSmartRef
				local isNotValid=false
				for i=1 to num do
				(
					index=SmartRefList.selectedIndices.Item[i-1]
					theSmartRef=SmartRefsHelperList[index+1]
					if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
					(
						SmartRefList.items.item[index].subitems.item[5].text=val
						SmartRefsHelperList[index+1].proxyFileName=val
					)
					else
						isNotValid=true
				)
				if isNotValid then
					RefreshManager()
				canRefresh=true
			)
		)
		catch
		(
			canRefresh=true
			MessageBox "Error changing Proxy Reference file path" title:"Error"
			RefreshManager()
		)
	)
	on UIProxyFileNameDir pressed do
	(
		try
		(
			undo on
			(
				canRefresh=false
				local num=SmartRefList.selectedIndices.Count
				if (num>0) then
				(
					local index=SmartRefList.selectedIndices.Item[0]
					local theSmartRef=SmartRefsHelperList[index+1]
					local theFileName=""
					if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
					(
						theFileName=SmartRefsHelperList[index+1].proxyFileName
						if (theFileName==undefined or theFileName=="") then
						(
							theFileName=SmartRefsHelperList[index+1].fileName
							if (theFileName==undefined or theFileName=="") then
								theFileName=MaxFilePath
						)
					)
					
					theFileName=getOpenFileName caption:("Select Proxy File for Reference "+theSmartRef.name)  filename:theFileName types:"3ds max(*.max)|*.max"  historyCategory:"SmartRefsProxy"
					if (theFileName!=undefined) then
					(
						UIProxyFileName.text=theFileName
						local isNotValid=false
						for i=1 to num do
						(
							index=SmartRefList.selectedIndices.Item[i-1]
							theSmartRef=SmartRefsHelperList[index+1]
							if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
							(
								SmartRefList.items.item[index].subitems.item[5].text=theFileName
								SmartRefsHelperList[index+1].proxyFileName=theFileName
							)
							else
								isNotValid=true
						)
						if isNotValid then
							RefreshManager()
					)
				)
				canRefresh=true
			)
		)
		catch
		(
			canRefresh=true
			MessageBox "Error changing Proxy Reference file path" title:"Error"
			RefreshManager()
		)
	)
	on UIPersist changed val do
	(
		undo on
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					--TODO this part in green
					/*if (val) then
						SmartRefList.items.item[index].subitems.item[3].text="Yes"
					else
						SmartRefList.items.item[index].subitems.item[3].text="No"*/
					SmartRefsHelperList[index+1].PersistRef=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			UIReloadIfChanged.enabled=val
			UIPersistReloadType.enabled=val
			canRefresh=true
		)
	)
	on UIReloadIfChanged changed val do
	(
		undo on
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					--TODO this part in green
					/*if (val) then
						SmartRefList.items.item[index].subitems.item[3].text="Yes"
					else
						SmartRefList.items.item[index].subitems.item[3].text="No"*/
					SmartRefsHelperList[index+1].ReloadIfChanged=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
	)
	on UIPersistReloadType changed val do
	(
		undo on
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					--TODO this part in green
					/*if (val) then
						SmartRefList.items.item[index].subitems.item[3].text="Yes"
					else
						SmartRefList.items.item[index].subitems.item[3].text="No"*/
					SmartRefsHelperList[index+1].PersistReloadType=val-1
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
	)
	on UIOverlay changed val do
	(
		undo on
		(
			canRefresh=false
			local num=SmartRefList.selectedIndices.Count
			local index
			local isNotValid=false
			for i=1 to num do
			(
				index=SmartRefList.selectedIndices.Item[i-1]
				local theSmartRef=SmartRefsHelperList[index+1]
				if (isValidNode theSmartRef and classof theSmartRef==SmartRefsHelper) then
				(
					--TODO this part in green
					/*if (val) then
						SmartRefList.items.item[index].subitems.item[3].text="Yes"
					else
						SmartRefList.items.item[index].subitems.item[3].text="No"*/
					SmartRefsHelperList[index+1].Overlay=val
				)
				else
					isNotValid=true
			)
			if isNotValid then
				RefreshManager()
			canRefresh=true
		)
	)
	on SmartRefList mouseUp do
	(
		RefreshPropertiesControls()
	)
	
)


function SmartRefs_ShowDuplicatedNamesWarning=
(
	if (smartrefs!=undefined) then
		smartrefs.ShowDuplicatedNamesWarning
	else
		false
)

--Menu Options
rcmenu SmartRefs_Manager_Menu
(
	subMenu "Reference"
	(
		menuItem ERFMM_Add "Add"
		menuItem ERFMM_Reload "Reload"
		menuItem ERFMM_Remove "Remove"
		menuItem ERFMM_Reset "Reset"
		menuItem ERFMM_Duplicate "Duplicate"
		menuItem ERFMM_Merge "Merge"
		separator ERFMM_Sep1
		menuItem ERFMM_Close "Close"
	)
	subMenu "Tools"
	(
		menuItem ERFMM_AdvancedReset "Advanced Reset"
	)
	subMenu "Options"
	(
		menuItem ERFMM_ShowDuplicatedNamesWarnings "Show Duplicated Names Warnings" checked:(SmartRefs_ShowDuplicatedNamesWarning())
		menuItem ERFMM_Register "Register"
	)
	subMenu "Help"
	(
		menuItem ERFMM_Help "SmartRefs Help..."
		menuItem ERFMM_About "About"
	)
	on ERFMM_Add picked do
	(
		if (SmartRefs_Manager_global!=undefined) then
			SmartRefs_Manager_global.AddSmartRef()
	)
	on ERFMM_Reload picked do
	(
		if (SmartRefs_Manager_global!=undefined) then
			SmartRefs_Manager_global.ReloadSmartRef()
	)
	on ERFMM_Remove picked do
	(
		if (SmartRefs_Manager_global!=undefined) then
			if (SRQueryBox "Are you sure you want to remove the selected references?, this operation can't be undone." title:"Remove Reference") then
				SmartRefs_Manager_global.RemoveSmartRef()
	)
	on ERFMM_Reset picked do
	(
		if (SmartRefs_Manager_global!=undefined) then
			if (SRQueryBox "Are you sure you want to reset the selected references?, this operation can't be undone." title:"Reset Reference") then
				SmartRefs_Manager_global.ResetSmartRef()
	)
	on ERFMM_Duplicate picked do
	(
		if (SmartRefs_Manager_global!=undefined) then
			SmartRefs_Manager_global.DuplicateSmartRef()
	)
	on ERFMM_Merge picked do
	(
		if (SmartRefs_Manager_global!=undefined) then
			if (SRQueryBox "Are you sure you want to merge the selected references?, this operation can't be undone." title:"Merge Reference") then
				SmartRefs_Manager_global.MergeSmartRef()
	)
	on ERFMM_Close picked do
	(
		if (SmartRefs_Manager_global!=undefined) then
			destroydialog SmartRefs_Manager_global
	)
	on ERFMM_AdvancedReset picked do
	(
		if (SmartRefs_AdvancedReset!=undefined) then
			destroydialog SmartRefs_AdvancedReset
		createdialog SmartRefs_AdvancedReset
	)
	on ERFMM_ShowDuplicatedNamesWarnings picked do
	(
		smartrefs.showduplicatednameswarning=not smartrefs.showduplicatednameswarning
	)

	on ERFMM_Register picked do
	(
		try
		(
			smartrefs.RegisterPlugin()
		)
		catch
		(
			Messagebox "Error With the plugin registration" title:"Error"
		)
	)
	on ERFMM_Help picked do
	(
		Shelllaunch "http://smartrefs.com/documentation/" ""
	)
	on ERFMM_About picked do
	(
		try
		(
			smartrefs.About()
		)
		catch
		(
			Messagebox "Error Opening the About dialog box" title:"Error"
		)
	)
)

--Getting the Dialog Size and position, from ini file or memory
if ((classof SmartRefs_DlgSize!=Point2) or (classof SmartRefs_DlgPos!=Point2)) then
(
	local XValue=SRGetIniInt "DlgSizeX" 720
	local YValue=SRGetIniInt "DlgSizeY" 400
	global SmartRefs_DlgSize=[XValue,YValue]
	
	XValue=SRGetIniInt "DlgPosX" 200
	YValue=SRGetIniInt "DlgPosY" 200
	global SmartRefs_DlgPos=[XValue,YValue]
)

function OpenSmartRefsManager=
(
	DestroyDialog SmartRefs_Manager 
	undo off CreateDialog SmartRefs_Manager width:SmartRefs_DlgSize.x height:SmartRefs_DlgSize.y pos:SmartRefs_DlgPos style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox, #style_resizing) menu:SmartRefs_Manager_Menu
)
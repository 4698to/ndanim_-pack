--------------------------------------------------------------------------
--DIMaster v2.0 
--Utilities Floater
--Last Edited: 2008/02/05
--Code by Borislav "Bobo" Petrov
--http://www.scriptspot.com/bobo 
--------------------------------------------------------------------------

macroScript DIMasterUtils category:"DIMaster" icon:#("TrackViewTools",105) tooltip:"Open DIMaster Utilities Floater - Manage Presets and Transfer Settings"
(
global DIMaster_Utilities_FLOATER
local theIniPath = (getDir #plugcfg + "\\DIMaster" )
makeDir theIniPath all:true

rollout DIMaster_TransferSettings_Rollout "Transfer DIMaster Settings"
(
	local getSettingsFromObject = undefined
	local thePropList = #()
	local thePropDisplayList = #()
	fn filterDIM o = matchPattern ((classof o.baseobject) as string) pattern:"DIM*" 
	pickbutton pck_getSettings "Acquire Settings From..." width:200 align:#center filter:filterDIM 
	multilistbox mlb_sourceProperties width:200 align:#center height:25
	button btn_setSettings "Apply Highlighted Settings To Selection" width:200 align:#center height:30
	checkbox chk_sameClassOnly "Apply to Objects Of The Same Type"
	
	
	on pck_getSettings picked obj do
	(
		getSettingsFromObject = obj
		if isValidNode obj do 
		(
			pck_getSettings.text = obj.name
			theSourceProps = getPropNames getSettingsFromObject.baseobject 
			thePropList = #()
			thePropDisplayList = #()
			for p in theSourceProps do
			(
				theVal = (getProperty getSettingsFromObject.baseobject p)
				if not isValidNode theVal and theVal != undefined do
				(
					append thePropList (p as string)
					append thePropDisplayList ((p as string) + " [" + theVal as string+ "]")
				)	
			)
			mlb_sourceProperties.items = thePropDisplayList
			mlb_sourceProperties.selection = #{}
		)	
	)
	fn applySettings =
	(
		thePattern = if chk_sameClassOnly.checked then ((classof getSettingsFromObject.baseobject) as string) else "DIM*"
		
		theSel = for o in selection where matchPattern ((classof o.baseobject) as string) pattern:thePattern collect o
		if theSel.count > 0 and isValidNode getSettingsFromObject do
		(
			for o in theSel do
			(
				theTargetProps = getPropNames o.baseobject
				for i in mlb_sourceProperties.selection do
				(
					thePropName = thePropList[i] as name
					if findItem theTargetProps thePropName > 0 then
					(
						theVal = (getProperty getSettingsFromObject.baseobject thePropName )
						if not isValidNode theVal and theVal != undefined do
							try(setProperty o.baseobject thePropName theVal )catch()
					)
				)
				o.baseobject.dirtyFlag = true
			)	
		)
		select theSel	
	)
	on btn_setSettings pressed do applySettings()
	on mlb_sourceProperties doubleclicked itms do applySettings()
)--end rollout

rollout DIMaster_Preferences_Rollout "DIMaster Preferences"
(

	group "Save"
	(
		button btn_saveSettings "Save Settings Of Selected DIMobject..." width:200 align:#center	
	)
	
	edittext edt_preferenceFile text:"Preference" fieldwidth:166 align:#left across:2 offset:[-12,0]
	button btn_create "Create" align:#right height:20 width:40 offset:[10,-2] 
	listbox lbx_preferences width:210 align:#center
	label lbl_01 "DIMline Settings:" across:3 align:#left offset:[-10,0]
	button btn_applyDIMlineSettingsToScene "->Scene" width:50 align:#center height:18 offset:[20,-2]
	button btn_applyDIMlineSettingsToSelection  "->Selection" width:60 align:#right height:18 offset:[10,-2]
	dropdownlist ddl_DIMlineFile  width:210 align:#center offset:[0,-3]
	
	label lbl_02 "DIMangle Settings:" across:3 align:#left offset:[-10,0]
	button btn_applyDIMangleSettingsToScene "->Scene" width:50 align:#center height:18 offset:[20,-2]
	button btn_applyDIMangleSettingsToSelection  "->Selection" width:60 align:#right height:18 offset:[10,-2]
	dropdownlist ddl_DIMangleFile width:210 align:#center offset:[0,-3]
	
	label lbl_03 "DIMnote Settings:" across:3 align:#left offset:[-10,0]
	button btn_applyDIMnoteSettingsToScene "->Scene" width:50 align:#center height:18 offset:[20,-2]
	button btn_applyDIMnoteSettingsToSelection  "->Selection" width:60 align:#right height:18 offset:[10,-2]
	dropdownlist ddl_DIMnoteFile width:210 align:#center offset:[0,-3]
	
	button btn_applyPreferenceAll "Apply Preference To All DIM Objects" width:210 align:#center height:25
	button btn_applyPreferenceSelected "Apply Preference To Selected Objects" width:210 align:#center height:25 offset:[0,-3]
	
	on btn_applyDIMlineSettingsToScene pressed do 
	(
		for o in objects where classof o.baseobject == DIMline do
			DIMasterFunctions.loadSettingsFromPreset o.baseobject (theIniPath + "\\" + ddl_DIMlineFile.selected + ".DIMline")
	)	
	on btn_applyDIMlineSettingsToSelection pressed do 
	(
		for o in selection where classof o.baseobject == DIMline do
			DIMasterFunctions.loadSettingsFromPreset o.baseobject (theIniPath + "\\" + ddl_DIMlineFile.selected + ".DIMline")
	)	

	on btn_applyDIMangleSettingsToScene pressed do 
	(
		for o in objects where classof o.baseobject == DIMangle do
			DIMasterFunctions.loadSettingsFromPreset o.baseobject (theIniPath + "\\" + ddl_DIMangleFile.selected + ".DIMangle")
	)	
	on btn_applyDIMangleSettingsToSelection  pressed do 
	(
		for o in selection where classof o == DIMangle do
			DIMasterFunctions.loadSettingsFromPreset o.baseobject (theIniPath + "\\" + ddl_DIMangleFile.selected + ".DIMangle")
	)	
	
	on btn_applyDIMnoteSettingsToScene pressed do 
	(
		for o in objects where classof o.baseobject == DIMnote do
			DIMasterFunctions.loadSettingsFromPreset o.baseobject (theIniPath + "\\" + ddl_DIMnoteFile.selected + ".DIMnote")
	)	
	on btn_applyDIMnoteSettingsToSelection  pressed do 
	(
		for o in selection where classof o.baseobject == DIMnote do
			DIMasterFunctions.loadSettingsFromPreset o.baseobject (theIniPath + "\\" + ddl_DIMnoteFile.selected + ".DIMnote")
	)	

	on btn_applyPreferenceAll pressed do
	(	
		for o in objects where matchPattern ((classof o.baseobject) as string) pattern:"DIM*" do
			DIMasterFunctions.loadSettingsFromPreferences o.baseobject
	)
	on btn_applyPreferenceSelected pressed do
	(	
		for o in selection where matchPattern ((classof o.baseobject) as string) pattern:"DIM*" do
			DIMasterFunctions.loadSettingsFromPreferences o.baseobject
	)	

	fn updatePreference itm =
	(
		theIniFile = theIniPath + "\\" + lbx_preferences.selected + ".DIMpref"
		if doesFileExist theIniFile then
		(
			theFile = getIniSetting theIniFile "DIMline" "PreferenceFile" 
			theIndex = (findItem ddl_DIMlineFile.items theFile ) 
			if theIndex == 0 do theIndex = 1
			ddl_DIMlineFile.selection = theIndex
			theFile = getIniSetting theIniFile "DIMangle" "PreferenceFile" 
			theIndex = (findItem ddl_DIMangleFile.items theFile ) 
			if theIndex == 0 do theIndex = 1
			ddl_DIMangleFile.selection = theIndex
			theFile = getIniSetting theIniFile "DIMnote" "PreferenceFile" 
			theIndex = (findItem ddl_DIMnoteFile.items theFile ) 
			if theIndex == 0 do theIndex = 1
			ddl_DIMnoteFile.selection = theIndex
		)	
		else
		(
			ddl_DIMlineFile.selection = ddl_DIMangleFile.selection = ddl_DIMnoteFile.selection = 1
		)
	)
	
	fn updateLists =
	(
		lbx_preferences.items = join #("--None--") (for f in (getFiles (theIniPath  + "\\*.DIMpref")) collect (getFileNameFile f))
		ddl_DIMlineFile.items = join #("--None--") (for f in (getFiles (theIniPath  + "\\*.DIMline")) collect (getFileNameFile f))
		ddl_DIMangleFile.items = join #("--None--") (for f in (getFiles (theIniPath  + "\\*.DIMangle")) collect (getFileNameFile f))
		ddl_DIMnoteFile.items = join #("--None--") (for f in (getFiles (theIniPath  + "\\*.DIMnote")) collect (getFileNameFile f))
		theCurrentPref = getIniSetting (theIniPath + "\\DIMasterSettings.ini") "Preferences"  "Current"
		theIndex = findItem lbx_preferences.items theCurrentPref 
		if theIndex > 0 do lbx_preferences.selection = theIndex
		updatePreference theIndex
	)	
	
	on btn_saveSettings pressed do
	(
		theSel = for o in selection where matchPattern ((classof o.baseobject) as string) pattern:"DIM*" collect o
		if theSel.count == 1 then
		(
			theObj = theSel[1].baseobject
			if matchPattern ((classof theObj ) as string) pattern:"DIMline" then
				theFile = getSaveFileName filename:(theIniPath+"\\Settings") types:"DIMline Settings (*.DIMline)|*.DIMline"
			if matchPattern ((classof theObj ) as string) pattern:"DIMangle" then
				theFile = getSaveFileName filename:(theIniPath+"\\Settings") types:"DIMangle Settings (*.DIMangle)|*.DIMangle"
			if matchPattern ((classof theObj ) as string) pattern:"DIMnote" then
				theFile = getSaveFileName filename:(theIniPath+"\\Settings") types:"DIMnote Settings (*.DIMnote)|*.DIMnote"
			if theFile != undefined do
			(	
				theProps = getPropNames theObj 
				for p in theProps do
				(
					theVal = getProperty theObj p
					if not isValidNode theVal and theVal != undefined do
						setIniSetting theFile "Settings" (p as string) (theVal as string)
				)	
			)
			updateLists()
		)
		else
			messagebox "Please select ONE DIMaster object!" title:"DIMaster Preferences"
	)
	
	on btn_create pressed do
	(
		if  edt_preferenceFile.text != "" do
		(
			theIniFile = theIniPath + "\\" + edt_preferenceFile.text + ".DIMpref"
			if not doesFileExist theIniFile do
			(
				setIniSetting theIniFile "DIMaster" "CreationDate" (localtime)
				updateLists()
				lbx_preferences.selection = findItem lbx_preferences.items edt_preferenceFile.text
				updatePreference lbx_preferences.selection
			)	
		)	
	)
	
	on lbx_preferences selected itm do
	(
		updatePreference itm
		setIniSetting (theIniPath + "\\DIMasterSettings.ini") "Preferences"  "Current" lbx_preferences.selected
	)
	
	on lbx_preferences doubleClicked itm do
	(
	--	theIniFile = theIniPath + "\\" + lbx_preferences.selected + ".DIMpref"
		if doesFileExist theIniPath do shelllaunch "explorer.exe" theIniPath 
	)
	on ddl_DIMlineFile selected itm do
	(
		if lbx_preferences.selected != "--None--" do
		(
			theIniFile = theIniPath + "\\" + lbx_preferences.selected + ".DIMpref"
			setIniSetting theIniFile "DIMline" "PreferenceFile" (ddl_DIMlineFile.selected)
			if lbx_preferences.selection > 0 do updatePreference lbx_preferences.selection
		)	
	)
	on ddl_DIMangleFile selected itm do
	(
		if lbx_preferences.selected != "--None--" do
		(
			theIniFile = theIniPath + "\\" + lbx_preferences.selected + ".DIMpref"
			setIniSetting theIniFile "DIMangle" "PreferenceFile" (ddl_DIMangleFile.selected)
			if lbx_preferences.selection > 0 do updatePreference lbx_preferences.selection
		)	
	)	
	on ddl_DIMnoteFile selected itm do
	(
		if lbx_preferences.selected != "--None--" do
		(
			theIniFile = theIniPath + "\\" + lbx_preferences.selected + ".DIMpref"
			setIniSetting theIniFile "DIMnote" "PreferenceFile" (ddl_DIMnoteFile.selected)
			if lbx_preferences.selection > 0 do updatePreference lbx_preferences.selection
		)	
	)
	
	on DIMaster_Preferences_Rollout open do
	(
		updateLists()
		if lbx_preferences.selection > 0 do updatePreference lbx_preferences.selection
	)
)

try(closeRolloutFloater DIMaster_Utilities_FLOATER)catch()
DIMaster_Utilities_FLOATER = newRolloutFloater "DIMaster Utilities" 230 470
addRollout DIMaster_Preferences_Rollout DIMaster_Utilities_FLOATER
addRollout DIMaster_TransferSettings_Rollout DIMaster_Utilities_FLOATER  rolledup:true

)--end script

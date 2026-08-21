--********************************************************************************************
--
--Script for 3dsMax (MaxScript)
--***Silhouette_Viewer***
--updated 2018/01/30
--Copyright (c) 2018 @Takayuki Sato All rights reserved.
--
--********************************************************************************************

try (CloseRolloutFloater Silhouette_Viewer_RO) catch() --AVOID DOUBLE WINDOW. YOU MUST MAKE "Silhouette_Viewer_RF" ORIGINAL NAME !!

-- macroScript *** SP_ ProjectNAME *** category:"SP_Tools"
(
--Check the expiration day ===============================================================================================	
	(
		local fromLimit = #( 0000, 00, 00 ) --START DAY
		local toLimit = #( 9999, 99, 99) --END DAY
		local FLG_expiration = false
		local c_time = getLocalTime() --Get Windows time

		currentDay = c_time[1] * 10000 + c_time[2] * 100 + c_time[4]
		fromDay = fromLimit[1] * 10000 + fromLimit[2] * 100 + fromLimit[3]
		toDay = toLimit[1] * 10000 + toLimit[2] * 100 + toLimit[3]

		if currentDay < fromDay do (
			MessageBox("This Script has been expired.桳岠婜尷偑愗傟偰偄傑偡丅")
			return()
		)
		if currentDay > toDay do (
			MessageBox("This Script has been expired.桳岠婜尷偑愗傟偰偄傑偡丅")
			return()
		)
	)
--Check the expiration day END ==============================================================================================

--global Silhouette_Viewer_RO
global RF_width = 220 --Define RolloutFloater Width
global RF_height = 50--Define RolloutFloater Height
--global Silhouette_Viewer_RF = newrolloutfloater "Silhouette_Viewer" RF_width RF_height 

--奺僆僽僕僃僋僩偺僨乕僞傪僶僢僋傾僢僾偡傞偨傔偺峔憿懱
struct obj_view_data (
obj,
wirecolor,
in_gray
)

local silhouette_flag = false --僔儖僄僢僩昞帵偵偟偨偐偳偆偐偺僼儔僌
local backup_arr = #()
local visual_style_backup = undefined
local visual_shadow_backup = undefined
local visual_ao_backup =undefined
local avs = NitrousGraphicsManager.GetActiveViewportSetting() --昞帵愗懼偺偨傔偵傾僋僥傿僽價儏乕愝掕偺庢摼

--UI/////////////////////////////////////////////////////////////////////////////////////////////////////
rollout Silhouette_Viewer_RO "Silhouette_Viewer"
(
	checkbutton CBN_run "选择模型 显示剪影" width:150 height:30 offset:[0,5]
	
	--FUNCTION restore setting 尦偺愝掕偵栠偡嵺偺張棟傪傑偲傔偨娭悢/////////////////////////////
	fn restore_setting =(
		with redraw off(
			for b in backup_arr do(
				if IsValidNode b.obj == true then(--僆僽僕僃僋僩偑嶍彍偝傟偰偄側偗傟偽丄偦偺愝掕傪尦偵栠偡
					b.obj.wirecolor = b.wirecolor
					b.obj.showFrozenInGray = b.in_gray
				)--end if 
			)--end for b
		)--end redraw
		displayColor.shaded = #material --僨傿僗僾儗僀昞帵傪儅僥儕傾儖僇儔乕偵
		viewport.setGridVisibility viewport.activeViewport true --傾僋僥傿僽價儏乕偺僌儕僢僪傪昞帵
		avs.VisualStyleMode = visual_style_backup --昞帵儌乕僪傪尦偵栠偡
		avs.ShadowsEnabled = visual_shadow_backup --價儏乕億乕僩偺僔儍僪僂愝掕傪尦偵栠偡
		avs.AmbientOcclusionEnabled = visual_ao_backup --價儏乕億乕僩偺僆僋儖乕僕儑儞愝掕傪婎偵栠偡
		
		silhouette_flag = false --僼儔僌偺峏怴
	)--end fn
	
	on CBN_run changed state do(
		if state == true then(
			--儃僞儞偑墴偝傟偨偲偒/////////////////////////////////////////////////////////
			--弶婜壔
			backup_arr = #()
			silhouette_flag = false --僼儔僌偺弶婜壔
			avs = NitrousGraphicsManager.GetActiveViewportSetting() --尰嵼偺傾僋僥傿僽價儏乕愝掕偺嵞搙庢摼
			
			--慡偰偺僕僆儊僩儕偺忣曬傪庢摼偟丄僆僽僕僃僋僩僇儔乕傪僔儖僄僢僩梡偵愝掕
			with redraw off(
				--for o in geometry do(
				for o in selection do (
					append backup_arr (obj_view_data o o.wirecolor o.showFrozenInGray)
					o.wirecolor = black
					o.showFrozenInGray = false
				)--end for o
			)--end redraw
			visual_style_backup = avs.VisualStyleMode --價儏乕億乕僩偺昞帵儌乕僪傪僶僢僋傾僢僾
			visual_shadow_backup = avs.ShadowsEnabled --價儏乕億乕僩偺僔儍僪僂偺僆儞僆僼傪僶僢僋傾僢僾
			visual_ao_backup = avs.AmbientOcclusionEnabled --價儏乕億乕僩偺僆僋儖乕僕儑儞偺僆儞僆僼傪僶僢僋傾僢僾
			
			--昞帵傪僔儖僄僢僩梡偵愝掕
			displayColor.shaded = #object --僨傿僗僾儗僀昞帵傪僆僽僕僃僋僩僇儔乕偵
			viewport.setGridVisibility viewport.activeViewport false --傾僋僥傿僽價儏乕偺僌儕僢僪傪旕昞帵
			avs.VisualStyleMode = #ConsistentColors --昞帵儌乕僪愗懼
			avs.ShadowsEnabled = false --僔儍僪僂傪僆僼
			avs.AmbientOcclusionEnabled = false --僆僋儖乕僕儑儞傪僆僼
			completeRedraw()--昞帵偺峏怴
			
			silhouette_flag = true --僼儔僌偺峏怴
		)else(
			--儃僞儞偑夝彍偝傟偨偲偒////////////////////////////////////////////////////
			restore_setting()
		)--end if

	)--end on CBN_run changed
	
	on Silhouette_Viewer_RO close do(
		if silhouette_flag == true then(
			--僂僀儞僪僂偑暵偠傜傟偨偲偒丄僔儖僄僢僩昞帵偩偭偨傜丄尦偺愝掕偵栠傞傛偆偵偡傞///////////////////////
			restore_setting()
		)--end if
	)--end on 
	
)--end rollout

createdialog Silhouette_Viewer_RO RF_width:width height:RF_height
--addRollout Silhouette_Viewer_RO Silhouette_Viewer_RF rolledUp:false

)-- end of script and end of macro definition
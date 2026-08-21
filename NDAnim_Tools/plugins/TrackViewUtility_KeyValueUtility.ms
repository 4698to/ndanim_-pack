/*
# coding: utf-8 
# @Date    : 2024-10-09 22:11:20
# @Author  : 4698to (738746223@qq.com)
# @Link    : sundaybox.cc
# @99U     : 199505
*/

plugin TrackViewUtility CurveKeyValueUtility
name:"Current Curve Value Editor"
category:"Scripted TV Utilities"
classID:#(0x329a8ceb, 0x3cea4d95)
(
	/* parameters main rollout:params
	(
		Coefficient type:#float default:1 ui:sp_Coefficient
	) */
	fn getSelectedControllers _currentTrackView =
	(
		numControllers = _currentTrackView.numSelTracks()
		theControllers = #()
		
		for i in 1 to numControllers do
		(
			currentController = (_currentTrackView.getSelected i)
			append theControllers currentController
		)
		theControllers
	)
	local currentTrackview = trackviews.current

	rollout params "EditKeyValue" width:200 --height:30
	(
		spinner sp_Coefficient "数值系数:" type:#float range:[-9999, 99999, 1] width:150 height:24 Align:#Left across:2 
		button btn_do "*= OK" width:40 height:18 Align:#right --offset:[10,0]
		local currentControllers = #()
		on btn_do pressed do 
		(
			currentControllers = getSelectedControllers currentTrackview
			
			undo "setcurvevalue" on 
			(
				for ic in currentControllers do
				(
					--str = exprForMAXObject ic 
					if (ic.classID[1] == 8199 ) do 
					(
						--format "% - % -> % \n" str  (ic.classID[1]) ic.keys.count 

						for i in ic.keys do 
						(
							--getProperty i 

							i.value = i.value * sp_Coefficient.value
							
							if i.inTangentType == #custom or i.outTangentType == #custom do 
							(
								i.inTangent *= sp_Coefficient.value
								i.outTangent *= sp_Coefficient.value
							)
						)
					)
					--format "% - % \n" str  (ic.classID[1])
				)	
			)		
		)
		on params open do(
			
		)
		
		on params close do
		(

		)
	)

	on Init val do
	(
		--Create a dialog from the Rollout, make it child of the Track View
		createDialog params parent:(val.ui.hwnd)
		--Register the dialog as Dialog Bar, make it child of the Track View
		cui.registerDialogBar params parent:val.ui.hwnd style:#(#cui_dock_all) maxSize:[220,40]
	)
)
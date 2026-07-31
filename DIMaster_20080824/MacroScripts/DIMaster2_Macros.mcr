--------------------------------------------------------------------------
--DIMaster v2.0 
--MacroScript Definitions
--Last Edited: 2008/02/05
--Code by Borislav "Bobo" Petrov
--http://www.scriptspot.com/bobo 
--------------------------------------------------------------------------

macroScript DIMline category:"DIMaster" icon:#("DIMaster",1) tooltip:"Create a DIMline measuring the distance between two points..."
(
	global DIMaster_p1 = undefined
	global DIMaster_p2 = undefined
	global DIMaster_p3 = undefined
	global DIMaster_theDim = undefined
	global DIMaster_firstPoint = undefined
	global DIMaster_theText = undefined
	result = startTool createDimensionLine
	if result == #abort do 
	(
		try(delete DIMaster_theText)catch()
		try(delete DIMaster_p1)catch()
		try(delete DIMaster_p2)catch()
		try(delete DIMaster_theDim)catch()
	)	
)

macroScript DIMangle category:"DIMaster" icon:#("DIMaster",2) tooltip:"Create a DIMangle measuring the angle between three points..."
(
	global DIMaster_p1 = undefined
	global DIMaster_p2 = undefined
	global DIMaster_p3 = undefined
	global DIMaster_theDim = undefined
	global DIMaster_firstPoint = undefined
	global DIMaster_theText = undefined
	result = startTool createDimensionAngle
	if result == #abort do 
	(
		try(delete DIMaster_theText)catch()
		try(delete DIMaster_p1)catch()
		try(delete DIMaster_p2)catch()
		try(delete DIMaster_p3)catch()
		try(delete DIMaster_theDim)catch()
	)	
)


macroScript DIMnote category:"DIMaster" icon:#("DIMaster",3) tooltip:"Create a DIMnote displaying position, distance, speed, custom object properties or user-defined text..."
(
	global DIMaster_p1 = undefined
	global DIMaster_p2 = undefined
	global DIMaster_p3 = undefined
	global DIMaster_theDim = undefined
	global DIMaster_firstPoint = undefined
	global DIMaster_theText = undefined
	result = startTool createDimensionNote
	if result == #abort do 
	(
		try(delete DIMaster_theText)catch()
		try(delete DIMaster_p1)catch()
		try(delete DIMaster_p2)catch()
		try(delete DIMaster_p3)catch()
		try(delete DIMaster_theDim)catch()
	)	
)

macroScript DIMlineMulti category:"DIMaster" icon:#("DIMaster",4) tooltip:"Create multiple DIMline objects measuring distances between pairs of points..."
(
	local isCheckedVar = false
	on isChecked return isCheckedVar 
	on execute do
	(
		isCheckedVar = true
		global DIMaster_p1 = undefined
		global DIMaster_p2 = undefined
		global DIMaster_p3 = undefined
		global DIMaster_theDim = undefined
		global DIMaster_firstPoint = undefined
		global DIMaster_theText = undefined
		local result = #go
		while result != #abort do
			result = startTool createDimensionLine
		isCheckedVar = false
	)	
)

macroScript DIMangleMulti category:"DIMaster" icon:#("DIMaster",5) tooltip:"Create multiple DIMangle objects measuring angles between sets of three points..."
(
	local isCheckedVar = false
	on isChecked return isCheckedVar 
	on execute do
	(
		isCheckedVar = true
		global DIMaster_p1 = undefined
		global DIMaster_p2 = undefined
		global DIMaster_p3 = undefined
		global DIMaster_theDim = undefined
		global DIMaster_firstPoint = undefined
		global DIMaster_theText = undefined
		local result = #go
		while result != #abort do
			result = startTool createDimensionAngle
		isCheckedVar = false
	)	
)


macroScript DIMnoteMulti category:"DIMaster" icon:#("DIMaster",6) tooltip:"Create multiple DIMnote objects displaying positions, distances, speeds, custom object properties or user-defined texts..."
(
	local isCheckedVar = false
	on isChecked return isCheckedVar 
	on execute do
	(
		isCheckedVar = true
		global DIMaster_p1 = undefined
		global DIMaster_p2 = undefined
		global DIMaster_p3 = undefined
		global DIMaster_theDim = undefined
		global DIMaster_firstPoint = undefined
		global DIMaster_theText = undefined
		result = #go
		while result != #abort do
			result = startTool createDimensionNote
		isCheckedVar = false
	)	
)


macroScript DIMasterDelete category:"DIMaster" icon:#("DIMaster",7) tooltip:"Delete DIMaster objects whose elements (Points, Lines or Texts) are currently selected..."
(
	with undo "DIMaster Delete" on
	(
		theSel = selection as array
		for o in theSel where isValidNode o do 
			DIMasterFunctions.DeleteCallback o
	)
)

macroScript DIMasterAttach category:"DIMaster" icon:#("DIMaster",8) tooltip:"Toggle Attaching the DIMaster object's Control Points to Snapped Points on Geometry Objects. Requires 3D Snaps."
(
	global DIMaster_AttachToSnapped
	on isChecked return DIMaster_AttachToSnapped == true
	on execute do
	(
		if DIMaster_AttachToSnapped == undefined do DIMaster_AttachToSnapped = false
		DIMaster_AttachToSnapped = not DIMaster_AttachToSnapped
	)	
)

struct Bcheck (left, right)
check1 = Bcheck left:" L " right:" R "
check2 = Bcheck left:"LFT" right:"RHT"
check3 = Bcheck left:"left" right:"right"
check4 = Bcheck left:"Left" right:"Right"
check5 = Bcheck left:"LEFT" right:"RIGHT"
check6 = Bcheck left:"_l" right:"_r"
check7 = Bcheck left:"_L" right:"_R"
check8 = Bcheck left:"l_" right:"r_"
check9 = Bcheck left:"L_" right:"R_"

/*
It's pretty simple to add bone names to swap.
The next version of the script will have an interface for this.

"Check6" thru "Check9" are prone to error if they are not at the end of the list.
So you will replace check6 and renumber the rest.

Say you speak Spanish so instead of "left and right" you use "derecha y izquierda."
Just add the line:

check6 = Bcheck left:"derecha" right:"izquierda"

and re-number the checks after it, simple.
*/

nameslist = #()
names = #()

---------------------------------------
-- LOADS THE BONE NAME LIST
---------------------------------------

fn loadnames = (
	local R
	local L
	local newlist = (getDir #Scripts) + "\\NDTools\\Martinez_Macro_MirrorWeights.mcr" 
	local number = 0
	if newlist != undefined then (
		cf = openfile newlist
		while eof cf == false do (
			a = readline cf
			b = filterstring a " "
			if b[3] == ( if b[1] == "struct" do continue; "Bcheck") then (
				number += 1
				L = "check" + ( number as string ) + ".left"
				R = "check" + ( number as string ) + ".right"
				L = execute(L)
				R = execute(R)
				append nameslist ( L + "  " + R )
				append names ( b[1] )
				)
			else exit
		)
		close
	)
) -- End loadnames Function

loadnames()

----------------------------
-- DEFINE SOME GLOBALS
----------------------------

global Physique_Tool

----------------------------
-- INTERFACE FUN
----------------------------

(
	if Physique_Tool != undefined do ( closerolloutfloater Physique_Tool )
	Physique_Tool = newrolloutfloater "Physique Tool" 190 320

	rollout TRIabout "About"
	(
			label info1 "Physique Tool 0.91 beta" align:#center
			label info2 "By Juan Martinez" align:#center
	)

	rollout BoneOptions "Bone Names"
	(
		label info3 "How the bone names are swapped." align:#center
		listbox BoneListBox items:nameslist
			--button moveup "Move Up" width:65 height:20 across:2
			--button movedown "Move Down" width:65 height:20
	
	) -- End BoneOptions Rollout
	
rollout PhyMirror "Physique Tool"
(

bitmap Top filename:"TRILogo.bmp"
	
group "Mirror Options" 
	(
		button MirrorPhy "Mirror Selected" width:140 height:20
		spinner thresh "Threshold  "  scale:.01 align:#center type:#float range:[0,5,.01]
	)
	label info1 "Updates will be" align:#center
	label info2 "given here." align:#center
	

----------------------------------------------
-- FUNCTION FOR FINDING THE MIRRORED BONE NAME 
----------------------------------------------

fn FindMirroredBone Name = (

local R = False
local L = False
local Insert
local int

for find = 1 to nameslist.count do (
	Insert = find
	int = "check" + ( find as string ) + ".right"
	int = execute(int)
	wildint = "*" + int + "*"
	R = matchpattern Name pattern:wildint ignoreCase:false
	if R then exit
	)
	if R then (
		Rcheck = findstring Name int
		InsertCount = (execute(names[Insert] as string + ".right")).count
		InsertName = execute(names[Insert] as string + ".left")
		NewName = replace Name Rcheck InsertCount InsertName
		return NewName
		)

for find = 1 to names.count do (
	Insert = find
	int = "check" + ( find as string ) + ".left"
	int = execute(int)
	wildint = "*" + int + "*"
	L = matchpattern Name pattern:wildint ignoreCase:false
	if L then exit
	)
	if L then (
		Lcheck = findstring Name int
		InsertCount = (execute(names[Insert] as string + ".left")).count
		InsertName = execute(names[Insert] as string + ".right")
		NewName = replace Name Lcheck InsertCount InsertName
		return NewName
		)

return Name

) -- End MirrorName Function

----------------------------
-- FUNCTION CREATE A MIRRORED BB
----------------------------

fn GetMirroredVertBB Array Expand = (

	local xMin xMax
	local yMin yMax
	local zMin zMax

	-- start with an empty bounding box

	xMin = 99999.9
	yMin = 99999.9
	zMin = 99999.9
	xMax = -99999.9
	yMax = -99999.9
	zMax = -99999.9

	-- grow bounding box by adding each vertex
	
	local v
	for v in Array do (
		
		-- Try and Catch E_mesh or E_Poly ops
		try (
		local vert = getvert $ v
		)
		catch()
		try (
		local vert = $.getvertex v
		)
		catch()		
	
		
		format "vertex index %: % % %\n" v vert.x vert.y vert.z
		if vert.x < xMin then (
			xMin = vert.x
		)
		if vert.x > xMax then (
			xMax = vert.x
		)
		if vert.y < yMin then (
			yMin = vert.y
		)
		if vert.y > yMax then (
			yMax = vert.y
		)
		if vert.z < zMin then (
			zMin = vert.z
		)
		if vert.z > zMax then (
			zMax = vert.z
		)
	)

	-- expand bounding box

	xMin = xMin - Expand
	xMax = xMax + Expand
	yMin = yMin - Expand
	yMax = yMax + Expand
	zMin = zMin - Expand
	zMax = zMax + Expand

	-- mirror boundingbox on x

	swap xMin xMax
	xMin = -1*xMin;
	xMax = -1*xMaX;

	print "Mirrored bounding box:"
	format "X: % % \n" xMin xMax
	format "Y: % % \n" yMin yMax
	format "Z: % % \n" zMin zMax

	-- Locate the points in the mesh that are in this new bounding box

	local MirroredVerts = #()
	local vertexIndex
	local progress
	local VItotal
	
	VItotal = physiqueOps.getVertexCount $		
	for vertexIndex = 1 to VItotal do (		

		-- Try and Catch E_mesh or E_Poly ops
		try (
			n = getvert $ vertexIndex
		)
		catch()
		try (
			n = $.getvertex vertexIndex
		)
		catch()

		progress = "SEARCHING: " + (vertexIndex as string) + " of " + ( VItotal as string )
		info1.text = progress
		if n.x >= XMin and n.x <= XMax then (
		   if n.y >= YMin and n.y <= YMax then (
		      if n.z >= ZMin and n.z <= ZMax then (
				append MirroredVerts vertexIndex
				PRINT (vertexIndex as string)
		      )
		   )
		)
	)
	gc light:false
	return MirroredVerts
)

fn MirrorPhyFN = (
	
	----------------------------
	-- FIND VERTS IN MIRRORED BOUNDING BOX
	----------------------------

	local selverts
	local threshold = thresh.value	

	selverts = getVertSelection $ as array
		
	---------------------------------------------
	-- SEARCH FOR VERTS IN THE MIRRORED BOUNDING BOX
	---------------------------------------------
	local InNewbb = #()
	
	InNewbb = GetMirroredVertBB selverts threshold
	found = "Found " + (InNewbb.count as string) + " vertices in mirrored bounding box."
	print found
	
	---------------------------------------------
	-- CLEAR THEIR WEIGHTS AND START V LOOP
	---------------------------------------------
	
	obj = $
	local selvertcount = physiqueOps.getVertexCount $ as string
	local t = [0,0,0]; t.x = threshold; t.y = threshold; t.z = threshold
	local newselverts = #{}
	
	for v in selverts do (
		local vert
		local n
		
		-- Try and Catch E_mesh or E_Poly ops
		try(
			vert = (getvert $ v)*[-1,1,1]
		)
		catch()
		try(
			vert = ($.getvertex v)*[-1,1,1]
		)
		catch()

		lowV = vert - t
		highV = vert + t
		
		---------------------------------------------
		-- FIND MATCHES AND COPY THE WEIGHTING OVER 	
		---------------------------------------------
		info1.text = "ASSIGNING WEIGHTS"
		for newvertex in InNewbb do (

			-- Try and Catch E_mesh or E_Poly ops
			try (
				n = getvert $ newvertex
			)
			catch()
			try (
				n = $.getvertex newvertex
			)
			catch()
			
			if n.x <= highV.x and n.x >= lowV.x do (
				if n.y <= highV.y and n.y >= lowV.y do (
					if n.z <= highV.z and n.z >= lowV.z do (
					
						if newvertex == v do continue;

						oldbone = physiqueOps.getVertexBone obj newvertex 1
						physiqueops.setvertexbone obj newvertex oldbone clear:true weight:0
	
						append newselverts newvertex
						number = findItem InNewbb newvertex
						deleteItem InNewbb number
								
						for b = 1 to physiqueOps.getVertexBoneCount obj v do (
								----------------
								-- Get Info
								----------------
								local _bone = physiqueOps.getVertexBone obj v b
								_bone = "$'" + _bone.name + "'"	
								_bone = FindMirroredBone(_bone)
								Mbone = execute _bone
								local weight = physiqueOps.getVertexWeight obj v b
								
								----------------
								--Set Info
								----------------
								physiqueops.setvertexbone obj newvertex Mbone weight:weight
						)
						info2.text = "Vert:" + ( v as string ) + " MATCHES Vert:" + ( newvertex as string )
						exit
					)
				)
			)
		)
	)
	return newselverts
	)


----------------------------------
-- MIRROR_PHY BUTTON
----------------------------------
on PhyMirror open do (
	gc light:false

)

on MirrorPhy pressed do (
	info1.text = "CLEARING GARBADGE"
	info2.text = "CLEARING GARBADGE"	
	print "CLEARING GARBADGE"
	gc light:false

GoAhead = false

if $ != undefined and getCommandPanelTaskMode() == #modify and subObjectLevel != 0 then (
	GoAhead = true )
			
if GoAhead then (
	
	try(
		if subObjectLevel != 1 do (
		$.EditablePoly.ConvertSelection subobjectLevel #Vertex
		subObjectLevel = 1
		)
	)
	catch()
	local newselverts
	with redraw off(
		undo off (
			setWaitCursor()
				info1.text = "COLLECTING DATA"
				info2.text = "COLLECTING DATA"		
				newselverts = MirrorPhyFN();			
			setArrowCursor()
		)
	)
	
---------------------------------------------
-- SELECT SUCCESSFUL TRANFERS
---------------------------------------------
	-- Try and Catch E_mesh or E_Poly ops
	try(
		$.selectedVerts = newselverts
	)
	catch()
	try(
		$.EditablePoly.SetSelection #Vertex newselverts		
	)
	catch()
	
	info1.text = "DONE! SELECTING"
	info2.text = "SUCCESSFUL TRANSFERS."
	gc light:false
)
else MessageBox "To Mirror: Select verts in Top_Level Subobject mode."
)
) --End rollout PhyMirror
addRollout PhyMirror Physique_Tool
addRollout BoneOptions Physique_Tool rolledup:true
addRollout TRIabout Physique_Tool rolledup:true

) --End roulloutfloater



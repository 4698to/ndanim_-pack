--------------------------------------------------------------------------
--DIMaster v2.0 
--Dimension Line Tool
--Last Edited: 2008/02/05
--Code by Borislav "Bobo" Petrov
--http://www.scriptspot.com/bobo 
--------------------------------------------------------------------------

global DIMasterFunctions
global DIMaster_p1, DIMaster_p2, DIMaster_p3, DIMaster_theDim, DIMaster_firstPoint, DIMaster_theText
global DIMaster_GlobalEdit = false
global DIMasterFunctions
global DIMaster_AttachToSnapped 

plugin simpleObject DIMline
name:"DIMline"
classID:#(0x5a7712e7, 0x3eeb17d6)
invisible:true
category:"DIMaster"
( 
	local updateDimension
	local dirtyFlag = true
	local lastAnimationFrame = currentTime
	local oldPos01, oldPos02, oldParentPos

	fn redrawDim globalUpdate:#none theValue:0 = 
	(
		dirtyFlag = true
		updateDimension()
		if DIMaster_GlobalEdit == true then
		(
			for o in objects where not o.isHiddenInVpt and classof o == DIMline and o != selection[1] do
			(
				case globalUpdate of
				(
					default: ()
					#pointHelperSize: (o.pointHelperSize = theValue)
					#isAnimatable: (o.isAnimatable = theValue)
					#thickness: (o.thickness = theValue)
					#thickness2: (o.thickness2 = theValue)
					#taperValue : (o.taperValue = theValue)
					#angleRadius: (o.angleRadius = theValue)
					#linesRadius : (o.linesRadius = theValue)
					#useLineRadius : (o.useLineRadius = theValue)
					#invertUpAxis : (o.invertUpAxis = theValue)
					#flipHorizontal : (o.flipHorizontal = theValue)
					#flipVertical : (o.flipVertical = theValue)
					#alignTextToView: (o.alignTextToView = theValue)

					#useDivisions : (o.useDivisions = theValue)
					#minorDivisions : (o.minorDivisions = theValue)
					#majorDivisions : (o.majorDivisions = theValue)
					#minorDivisionsLength : (o.minorDivisionsLength = theValue)
					#majorDivisionsLength : (o.majorDivisionsLength = theValue)
					#minorDivisionsThickness : (o.minorDivisionsThickness = theValue)
					#majorDivisionsThickness : (o.majorDivisionsThickness = theValue)
					
					#textOffsetX : (o.textOffsetX = theValue)
					#textOffsetY : (o.textOffsetY = theValue)
					#textOffsetZ : (o.textOffsetZ = theValue)
					
					#textSize : (o.textSize = theValue)
					#userPrefix : (o.userPrefix = theValue)
					#userSuffix : (o.userSuffix = theValue)
					#userText : (o.userText = theValue)
					#usePrefix : (o.usePrefix = theValue)
					#useSuffix : (o.useSuffix = theValue)
					#useUserText : (o.useUserText = theValue)
					#textMode : (o.textMode = theValue)
					#height : (o.height = theValue)
					#decimalPrecision : (o.decimalPrecision = theValue)
					
					#arrowType : (o.arrowType = theValue)
					#arrowLength : (o.arrowLength = theValue)
					#arrowHeight : (o.arrowHeight = theValue)
					#dashOvershoot : (o.dashOvershoot = theValue)
					#arrowOvershoot : (o.arrowOvershoot = theValue)
					#slashAngle : (o.slashAngle = theValue)
					#UpAxisMode : (o.UpAxisMode = theValue)
					
				)
				o.dirtyFlag = true
			)	
		)	
	)
	

	parameters main rollout:params
	(
		node01 type:#node
		node02 type:#node
		textNode type:#node 
		
		forceAnimationTrack  type:#float
		
		isAnimatable type:#boolean default:false ui:chk_isAnimatable 
		pointHelperSize type:#float default:2 ui:spn_pointHelperSize 
		
		UpAxisMode type:#integer default:3 ui:rad_UpAxisMode
		invertUpAxis type:#boolean default:false ui:chk_invertUpAxis 
		flipHorizontal type:#boolean default:false ui:chk_flipHorizontal 
		flipVertical type:#boolean default:false ui:chk_flipVertical
		alignTextToView type:#boolean default:false ui:chk_alignTextToView

		height type:#worldunits default:10 ui:spn_height
		thickness type:#worldunits default:1 ui:spn_thickness
		thickness2 type:#worldunits default:1 ui:spn_thickness2
		taperValue type:#float default:0 ui:spn_taperValue
		
		useDivisions type:#boolean default:false ui:chk_useDivisions 
		minorDivisions type:#float default:10 ui:spn_minorDivisions 
		minorDivisionsLength type:#float default:5 ui:spn_minorDivisionsLength
		minorDivisionsThickness type:#float default:0.5 ui:spn_minorDivisionsThickness
		majorDivisions type:#integer default:10 ui:spn_majorDivisions 
		majorDivisionsLength type:#float default:10 ui:spn_majorDivisionsLength
		majorDivisionsThickness type:#float default:1 ui:spn_majorDivisionsThickness


		arrowType type:#integer default:2 ui:ddl_arrowType
		
		arrowLength type:#float default:10 ui:spn_arrowLength
		arrowHeight type:#float default:2 ui:spn_arrowHeight
		dashOvershoot type:#float default:2 ui:spn_dashOvershoot
		arrowOvershoot type:#float default:2 ui:spn_arrowOvershoot 
		slashAngle type:#float default:-45 ui:spn_slashAngle 

		customDistance type:#float 
		
		on pointHelperSize set val do redrawDim globalUpdate:#pointHelperSize theValue:val
		on isAnimatable set val do 
		(
			if val then 
			(
				forceAnimationTrack.controller = float_script()
				forceAnimationTrack.controller.script = "0"			
			)
			else
			(
				forceAnimationTrack.controller = bezier_float()
			)
			redrawDim globalUpdate:#isAnimatable theValue:val
		)	
		on UpAxisMode set val do redrawDim globalUpdate:#UpAxisMode theValue:val
		on invertUpAxis set val do redrawDim globalUpdate:#invertUpAxis theValue:val
		on flipHorizontal set val do redrawDim globalUpdate:#flipHorizontal theValue:val
		on flipVertical set val do redrawDim globalUpdate:#flipVertical theValue:val
		on alignTextToView set val do redrawDim globalUpdate:#alignTextToView theValue:val
				
		on height set val do redrawDim globalUpdate:#height theValue:val
		on thickness set val do redrawDim globalUpdate:#thickness theValue:val
		on thickness2 set val do redrawDim globalUpdate:#thickness2 theValue:val
		on taperValue set val do redrawDim globalUpdate:#taperValue theValue:val

		on useDivisions set val do redrawDim globalUpdate:#useDivisions theValue:val
		on minorDivisions set val do redrawDim globalUpdate:#minorDivisions theValue:val
		on majorDivisions set val do redrawDim globalUpdate:#majorDivisions theValue:val
		on minorDivisionsLength set val do redrawDim globalUpdate:#minorDivisionsLength theValue:val
		on majorDivisionsLength set val do redrawDim globalUpdate:#majorDivisionsLength theValue:val
		on minorDivisionsThickness set val do redrawDim globalUpdate:#minorDivisionsThickness theValue:val
		on majorDivisionsThickness set val do redrawDim globalUpdate:#majorDivisionsThickness theValue:val
		
		on taperValue set val do redrawDim globalUpdate:#taperValue theValue:val

		on arrowType set val do redrawDim globalUpdate:#arrowType theValue:val
		on arrowLength set val do redrawDim globalUpdate:#arrowLength theValue:val
		on arrowHeight set val do redrawDim globalUpdate:#arrowHeight theValue:val

		on dashOvershoot set val do redrawDim globalUpdate:#dashOvershoot theValue:val
		on arrowOvershoot set val do redrawDim globalUpdate:#arrowOvershoot theValue:val
		on slashAngle set val do redrawDim globalUpdate:#slashAngle theValue:val
	)
	
	
	parameters textcontrols rollout:textrollout
	(
		textSize type:#float default:10 ui:spn_textSize

		textOffsetX type:#float default:0 ui:spn_textOffsetX
		textOffsetY type:#worldunits default:1 ui:spn_textOffsetY
		textOffsetZ type:#worldunits default:0 ui:spn_textOffsetZ

		usePrefix type:#boolean default:false ui:chk_usePrefix
		userPrefix type:#string default:"" ui:edt_userPrefix

		useUserText type:#boolean default:false ui:chk_userText
		userText type:#string default:"" ui:edt_userText
		
		useSuffix type:#boolean default:false ui:chk_useSuffix
		userSuffix type:#string default:"" ui:edt_userSuffix
		
		textMode  type:#integer default:1 ui:rad_textMode 
		
		decimalPrecision type:#integer default:4 ui:spn_decimalPrecision

		on userPrefix set val do redrawDim globalUpdate:#userPrefix theValue:val
		on userSuffix set val do redrawDim globalUpdate:#userSuffix theValue:val
		on useUserText set val do redrawDim globalUpdate:#useUserText theValue:val
		on userText set val do redrawDim globalUpdate:#userText theValue:val
		on useSuffix set val do redrawDim globalUpdate:#useSuffix theValue:val
		on usePrefix set val do redrawDim globalUpdate:#usePrefix theValue:val		
		on textMode set val do redrawDim globalUpdate:#textMode theValue:val
		
		on textOffsetX set val do redrawDim globalUpdate:#textOffsetX theValue:val
		on textOffsetY set val do redrawDim globalUpdate:#textOffsetY theValue:val
		on textOffsetZ set val do redrawDim globalUpdate:#textOffsetY theValue:val
		
		on textSize set val do redrawDim globalUpdate:#textSize theValue:val
		on decimalPrecision set val do redrawDim globalUpdate:#decimalPrecision theValue:val	
	)	
	
	rollout params "DIMaster Line Parameters"
	(
		checkbutton ckb_globalEdit ">Global Edit" width:150 offset:[0,-2] align:#center
		on ckb_globalEdit changed state do DIMaster_GlobalEdit = state
		
		checkbutton chk_isAnimatable ">Enable Animation" width:150 offset:[0,0] align:#center
		on chk_isAnimatable changed state do
		(
			if state then 
			(
				forceAnimationTrack.controller = float_script()
				forceAnimationTrack.controller.script = "0"			
			)
			else
			(
				forceAnimationTrack.controller = bezier_float()
			)
		)
		

		radiobuttons rad_UpAxisMode labels:#("X","Y","Z") align:#left offset:[0,-2]
		checkbox chk_invertUpAxis "Flip Up Axis" align:#left offset:[0,-2]
		checkbox chk_flipHorizontal "Flip Text Horizontally"  align:#left offset:[0,-2]
		checkbox chk_flipVertical "Flip Text Vertically" align:#left offset:[0,-2]
		checkbox chk_alignTextToView "Align Text To View" align:#left offset:[0,-2]
		
		
		group "Drawing Parameters"
		(
			spinner spn_height "Line Offset:" fieldwidth:50 scale:0.01 range:[0,1000,0] type:#worldunits offset:[0,-2]
			spinner spn_thickness "Line Thickness:" fieldwidth:50 scale:0.01 range:[0.0,100,0] type:#worldunits offset:[0,-2]
			spinner spn_thickness2 "Dash Thickness:" fieldwidth:50 scale:0.01 range:[0.0,100,0] type:#worldunits offset:[0,-2]
			spinner spn_taperValue "Dash Taper %:" fieldwidth:50 range:[0.0,100,0] type:#float offset:[0,-2]
		)	
		dropdownlist ddl_arrowType items:#("No Arrows", "Inside Arrows", "Outside Arrows", "Slashes" , "Rings" ) width:150 align:#center offset:[0,-2]
		group ">Size Rel.To Line Thickness"
		(
			spinner spn_arrowLength "      Arrow Length:" fieldwidth:45 scale:0.01 range:[0,1000,1] type:#float offset:[0,-2] align:#right
			spinner spn_arrowHeight "      Arrow Height:" fieldwidth:45 scale:0.01 range:[0,1000,1] type:#float offset:[0,-2] align:#right
			spinner spn_dashOvershoot "Dash Overshoot:" fieldwidth:45 scale:0.01 range:[0,1000,1] type:#float offset:[0,-2] align:#right
			spinner spn_arrowOvershoot "Arrow Overshoot:" fieldwidth:45 scale:0.01 range:[0,1000,1] type:#float offset:[0,-2] align:#right
			spinner spn_slashAngle "Slash Angle:" fieldwidth:45 scale:5 range:[-180,180,-45] type:#float offset:[0,-2] align:#right
		)
		group "Ruler Divisions"
		(
			checkbox chk_useDivisions "Show Ruler Divisions"
			spinner spn_minorDivisions "Minor Spacing:" fieldwidth:45 range:[1,10000000,1] type:#worldunits
			spinner spn_majorDivisions "Major Every:" fieldwidth:45 type:#integer range:[1,1000,1]
			
			spinner spn_minorDivisionsLength "Minor Length:" fieldwidth:45 range:[-1000,1000,0] type:#worldunits
			spinner spn_majorDivisionsLength "Major Length:" fieldwidth:45 range:[-1000,1000,0] type:#worldunits
			
			spinner spn_minorDivisionsThickness "Minor Thickness:" fieldwidth:45 type:#worldunits
			spinner spn_majorDivisionsThickness "Major Thickness:" fieldwidth:45 type:#worldunits
		)
		spinner spn_pointHelperSize "Point Helper Size:" fieldwidth:50  range:[0,1000,2] type:#float offset:[0,0]
		
		fn updateArrowControlsUI itm =
		(
			spn_taperValue.enabled = itm == 1
			spn_dashOvershoot.enabled = spn_arrowLength.enabled = spn_arrowHeight.enabled = itm > 1
			spn_arrowOvershoot.enabled =  itm > 2
			spn_slashAngle.enabled = ddl_arrowType.selection == 4
			
			spn_arrowLength.text = case itm of
			(
				default: 	"      Arrow Length:"
				4: 		"      Slash Length:"
				5: 		"    Ring Diameter:"
			)
			
			spn_arrowHeight.text = case itm of
			(
				default: 	"      Arrow Height:"
				4: 		"Slash Thickness:"
				5: 		" Ring Thickness:"
			)
			
		)

		on ddl_arrowType selected itm do updateArrowControlsUI itm
		on params open do
		(
			updateArrowControlsUI ddl_arrowType.selection
			ckb_globalEdit.checked = DIMaster_GlobalEdit == true
		)
	)
	
	rollout textrollout "DIMaster Line Text"
	(
		group "Text Size and Placement"
		(
			spinner spn_textSize "Font Size:" fieldwidth:50 scale:0.01 range:[0,100,0] type:#worldunits offset:[0,-2]
			spinner spn_textOffsetX "Horiz. Offset %:" fieldwidth:50 scale:0.01 range:[-200,200,0] type:#float offset:[0,-2]
			spinner spn_textOffsetY "Vertical Offset:" fieldwidth:50 scale:0.01 range:[-10000,10000,0] type:#worldunits offset:[0,-2]
			spinner spn_textOffsetZ "Off-Plane Offset:" fieldwidth:50 scale:0.01 range:[-10000,10000,0] type:#worldunits offset:[0,-2]
		)

		button btn_copyFont "Assign Font Globally" width:150 align:#center offset:[0,-2]
		pickbutton pck_getFont "Acquire Font From..." width:150 align:#center	offset:[0,-2] 		

		
		fn filterDimLines o = (classof o == DIMline or classof o == DIMangle or classof o == DIMnote or classof o.baseobject == Text)
		
		group "Custom Text"
		(
			checkbox chk_usePrefix align:#left across:2 offset:[0,-2]
			edittext edt_userPrefix "Prefix:" fieldwidth:80 align:#right offset:[0,-2]
			checkbox chk_userText align:#left across:2 offset:[0,-2]
			edittext edt_userText "Text:" fieldwidth:80 align:#right offset:[0,-2]
			checkbox chk_useSuffix align:#left across:2 offset:[0,-2]
			edittext edt_userSuffix "Suffix:" fieldwidth:80 align:#right offset:[0,-2]
			radiobuttons rad_textMode labels:#("Display User Units","Display Generic Units") align:#left offset:[0,-2]
			spinner spn_decimalPrecision "Decimal Precision:" range:[0,6,2] type:#integer fieldwidth:35 offset:[0,-2]
		)	
		
		on btn_copyFont pressed do
		(
			if querybox ("This will assign font [" + textNode.baseobject.font + "]\nto all visible DIMline Text Objects in the scene.\n\nAre you sure? ") title:"DIMline Global Font" then
				for o in objects where classof o == DIMline and not o.isHiddenInVpt do
					if o.textNode != undefined do o.textNode.baseobject.font = textNode.baseobject.font
		)
		
		on pck_getFont picked obj do
		(
			if obj != undefined do
			(
				if classof obj == DIMangle or classof obj == DIMnote or classof obj == DIMline then
					textNode.baseobject.font = obj.textNode.baseobject.font
				if classof obj.baseobject == Text then 
					textNode.baseobject.font = obj.baseobject.font
			)		
		)			
	
	)
	
	rollout construct_line "DIMaster Line Constructor"
	(
		spinner spn_distance "Length:" range:[0.001,10000000,100] fieldwidth:90 type:#worldunits
		on spn_distance changed val do
		(
			with animate off
			(
				if node01 != undefined and node02 != undefined do
				(
					theX = normalize (node02.pos - node01.pos)
					node02.pos = node01.pos + theX * val 
				)--end if 
			)	
		)
		on construct_line open do
		(
			with animate off spn_distance.value = customDistance
		)	
	)	
	
	rollout global_materials "DIMaster Global Materials"
	(
		colorpicker clr_diffusecolor "Line Color:" color:black align:#right modal:false
		colorpicker clr_textdiffusecolor "Text Color:" color:black align:#right modal:false
		
		on clr_diffusecolor changed clr do 
			 try(DimensionSystemMaterial.diffuse = clr)catch()
		on clr_textdiffusecolor changed clr do 
			 try(DimensionSystemTextMaterial.diffuse = clr)catch()			
			 
		on global_materials open do
		(		
			persistent global DimensionSystemMaterial 
			if DimensionSystemMaterial == undefined do DimensionSystemMaterial = (standard diffuse:black twosided:true selfillumamount:100 selfillumamount:100)
			persistent global DimensionSystemTextMaterial 
			if DimensionSystemTextMaterial == undefined do DimensionSystemTextMaterial = (standard diffuse:(black*0.5) twosided:true selfillumamount:100 selfillumamount:100)
			clr_diffusecolor.color = DimensionSystemMaterial.diffuse
			clr_textdiffusecolor .color = DimensionSystemTextMaterial.diffuse
		)	
	)	
	
	fn FillInTrailingZeros theVal =
	(
		local firstDecimal = 0
		local dotPosition = 0
		local decimalSign = (0.0 as string)[2]
		for i = theVal.count to 1 by -1 do
		(
			if firstDecimal == 0 AND findString "01234567890" theVal[i] != undefined do firstDecimal = i
			if firstDecimal > 0 and theVal[i] == decimalSign do (dotPosition = i; exit)
		)
		if firstDecimal != 0 and dotPosition != 0 then
		(
			local firstPart = substring theVal 1 dotPosition 
			local secondPart = substring theVal (dotPosition+1) (firstDecimal-dotPosition) 
			if secondPart.count > decimalPrecision do secondPart = substring secondPart 1 decimalPrecision
			if 	secondPart == "" do secondPart = "0"
			local thirdPart = substring theVal (firstDecimal+1) -1
			local theZeroCount = (decimalPrecision-secondPart.count)
			if theZeroCount > 0 do secondPart += (substring "00000000000000" 1 theZeroCount)
			firstPart + secondPart + thirdPart 
		)
		else
			theVal
	)
	
	fn updateDimension =
	(
		if node01 != undefined and node02 != undefined do
		(
			local UpVector = (
				case UpAxisMode of
				(
					1: normalize node01.transform.row1
					2: normalize node01.transform.row2
					default: normalize node01.transform.row3
				)	
			)
			if invertUpAxis do UpVector = -UpVector 
			if (dirtyFlag == true or (isAnimatable AND lastAnimationFrame != currentTime) or node01.pos != oldPos01 or node02.pos != oldPos02 or (node01.parent != undefined and node01.parent.pos != oldParentPos ) ) do
			(
				oldPos01	= node01.pos 
				oldPos02	= node02.pos 
				
				with animate off
				(
					node01.size = pointHelperSize * 2
					node02.size = pointHelperSize
				)	
				
				lastAnimationFrame = currentTime
				if node01.parent != undefined do oldParentPos = node01.parent.pos
				
				dirtyFlag = false
				
				theX = normalize (node02.pos - node01.pos)
				theY = normalize (cross UpVector theX )
				if theY.z < 0 then
					theZ = normalize (cross theY theX )
				else				
					theZ = normalize (cross theX theY)

				local theDistance = (distance node01 node02)
				if textNode != undefined do
				(
					with animate off
					(
						theDistance = (floor ((theDistance * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
						local txt = ""
						if usePrefix do txt+= userPrefix +" "
						txt += if useUserText then userText else 
						(
							if textMode == 1 then 
								FillInTrailingZeros (units.formatValue theDistance)
							else
								FillInTrailingZeros (theDistance as string)
						)		
						if useSuffix do txt+= " " +userSuffix 
						textNode.text = txt 
						textNode.size = textSize
						if alignTextToView then
						(
							local theViewTM = inverse (viewport.getTM())
							theViewTM.row4 = ((oldPos01+oldPos02)/2 + theZ*textOffsetZ  + (theX * theDistance * TextOffsetX/200)  + theY *(height+thickness/2+textOffsetY ))
							textNode.transform = theViewTM	
						)		
						else
						(
							theTMX = if flipHorizontal then -theX else theX
							theTMY = if flipVertical then -theY else theY
							textNode.transform = matrix3 theTMX theTMY theZ ((oldPos01+oldPos02)/2 + theZ*textOffsetZ  + (theX * theDistance * TextOffsetX/200)  + theY *(height+thickness/2+textOffsetY ))
						)
						customDistance = theDistance 
					)	
				)	
				
				case arrowType of
				(
				1: 
				(
					vertArray = #(
						oldPos01 + theY * (height + thickness*0.5) - theX*thickness2*0.5,  --1
						oldPos02 + theY * (height + thickness*0.5) + theX*thickness2*0.5,  --2
						oldPos02 + theY * (height -  thickness*0.5) + theX*thickness2*0.5,  --3
						oldPos02 + theX * thickness2*0.5 * (1.0-taperValue/100.0),  --4
						oldPos02 - theX * thickness2*0.5* (1.0-taperValue/100.0),  --5
						oldPos02 - theX * thickness2*0.5 + theY * height - theY * thickness*0.5,  --6
						oldPos01 + theX * thickness2*0.5 + theY * height - theY * thickness*0.5,  --7
						oldPos01 + theX * thickness2*0.5 * (1.0-taperValue/100.0), --8
						oldPos01 - theX * thickness2*0.5 * (1.0-taperValue/100.0) , --9
						oldPos01 + theY *(height-thickness*0.5) - theX*thickness2/2   --10 
					)
					faceArray = #([1,3,2], [1,10,3], [3,6,4], [4,6,5], [7,9,8], [7,10,9])
				)
				2:
				(
					local theHalfOffset = theX*thickness2/2
					vertArray = #(
						--First Dash
						oldPos01 - theHalfOffset, --1
						oldPos01 + theHalfOffset, --2
						oldPos01 + theHalfOffset + theY * (height+thickness*dashOvershoot ) ,  --3
						oldPos01 + theY * (height+thickness*dashOvershoot ) - theX*thickness2/2, --4
						
						--Second Dash
						oldPos02 + theHalfOffset , --5
						oldPos02 - theHalfOffset, --6
						oldPos02 - theHalfOffset + theY * (height+thickness*dashOvershoot ) ,  --7
						oldPos02 + theY * (height+thickness*dashOvershoot ) + theHalfOffset, --8
						
						
						oldPos01 + theX * thickness*arrowLength + theY * (height-thickness/2) + theHalfOffset , --9
						oldPos01 + theX * thickness*arrowLength + theY * (height+thickness/2) + theHalfOffset , --10
						oldPos02 - theX * thickness*arrowLength + theY * (height-thickness/2) - theHalfOffset , --11
						oldPos02 - theX * thickness*arrowLength + theY * (height+thickness/2) - theHalfOffset , --12
						
						--ARROWS:
						oldPos01  + theY * (height), --13 --+ theHalfOffset
						oldPos01 + theX * thickness*arrowLength + theY * (height + thickness*arrowHeight ) + theHalfOffset , --14
						oldPos01 + theX * thickness*arrowLength + theY * (height - thickness*arrowHeight ) + theHalfOffset , --15
	
						oldPos02 + theY * (height), --16 --- theHalfOffset 
						oldPos02 - theX * thickness*arrowLength  + theY * (height + thickness*arrowHeight ) - theHalfOffset , --17
						oldPos02 - theX * thickness*arrowLength + theY * (height- thickness*arrowHeight )- theHalfOffset  --18
					)
					faceArray = #([1,2,3], [1,3,4], [5,8,7], [5,7,6] , [9,11,12], [9,12,10] , [13,15,14] , [16,17,18])
				)
				
				3:
				(
					local theHalfOffset = theX*thickness2/2
					vertArray = #(
						oldPos01 - theHalfOffset, --1
						oldPos01 + theHalfOffset, --2
						oldPos01 + theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ) ,  --3
						oldPos01 + theY * (height+thickness/2+thickness*dashOvershoot ) - theHalfOffset, --4
						
						oldPos02 + theHalfOffset, --5
						oldPos02 - theHalfOffset, --6
						oldPos02 - theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ) ,  --7
						oldPos02 + theY * (height+thickness/2+thickness*dashOvershoot ) + theHalfOffset, --8
						
						oldPos01 - theX * thickness*arrowLength - theX*thickness*arrowOvershoot + theY * (height-thickness/2), --9
						oldPos01 - theX * thickness*arrowLength - theX*thickness*arrowOvershoot + theY * (height+thickness/2), --10
						oldPos02 + theX * thickness*arrowLength + theX*thickness*arrowOvershoot + theY * (height-thickness/2), --11
						oldPos02 + theX * thickness*arrowLength + theX*thickness*arrowOvershoot + theY * (height+thickness/2), --12
						
						--ARROWS:
						oldPos01 + theY * height , --13
						oldPos01 - theX * thickness*arrowLength + theY * (height + thickness*arrowHeight ) , --14
						oldPos01 - theX * thickness*arrowLength + theY * (height - thickness*arrowHeight ) , --15
	
						oldPos02 + theY * height , --16
						oldPos02 + theX * thickness*arrowLength  + theY * (height+ thickness*arrowHeight ) , --17
						oldPos02 + theX * thickness*arrowLength + theY * (height- thickness*arrowHeight ) --18
						
					)
					faceArray = #([1,2,3], [1,3,4], [5,8,7], [5,7,6] , [9,11,12], [9,12,10] , [13,14,15] , [16,18,17])
				)


				4: (
					local theVector = ((rotateZMatrix slashAngle ) *(matrix3 theX theY theZ [0,0,0] )).row1
					local theVector2 = ((rotateZMatrix slashAngle ) *(matrix3 theX theY theZ [0,0,0] )).row2
					local theHalfOffset = theX * thickness2/2					
					vertArray = #(
						oldPos01 - theHalfOffset, --1
						oldPos01 + theHalfOffset, --2
						oldPos01 + theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ) ,  --3
						oldPos01 - theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ), --4
						
						oldPos02 + theHalfOffset, --5
						oldPos02 - theHalfOffset, --6
						oldPos02 - theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ) ,  --7
						oldPos02 + theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ), --8
						
						oldPos01 - theHalfOffset  - theX*thickness*arrowOvershoot + theY * (height-thickness/2), --9
						oldPos01 - theHalfOffset - theX*thickness*arrowOvershoot + theY * (height+thickness/2), --10
						oldPos02 + theHalfOffset  + theX*thickness*arrowOvershoot + theY * (height-thickness/2), --11
						oldPos02 + theHalfOffset + theX*thickness*arrowOvershoot + theY * (height+thickness/2) --12
					)
	
					local theOffset1 = oldPos01 + theY * (height) 
					local theOffset2 = oldPos02 + theY * (height) 
					
					join vertArray #( 
						theOffset1 + (-theVector2 * thickness*arrowHeight/2 - theVector* thickness/2*arrowLength) ,
						theOffset1 + (theVector2 * thickness*arrowHeight/2 - theVector* thickness/2*arrowLength) ,
						theOffset1 + (-theVector2 * thickness*arrowHeight/2 + theVector* thickness/2*arrowLength) ,
						theOffset1 + (theVector2 * thickness*arrowHeight/2 + theVector* thickness/2*arrowLength) ,
						theOffset2 + (-theVector2 * thickness*arrowHeight/2 - theVector* thickness/2*arrowLength) ,
						theOffset2 + (theVector2 * thickness*arrowHeight/2 - theVector* thickness/2*arrowLength) ,
						theOffset2 + (-theVector2 * thickness*arrowHeight/2 + theVector* thickness/2*arrowLength),
						theOffset2 + (theVector2 * thickness*arrowHeight/2 + theVector* thickness/2*arrowLength)
					)				
					faceArray = #([1,2,3], [1,3,4], [5,8,7], [5,7,6] , [9,11,12], [9,12,10], [13,15,14] , [14,15,16], [17,19,18] , [18,19,20])
				)

				5:  (
					local theHalfOffset = theX * thickness2/2	
					vertArray = #(
						oldPos01 - theHalfOffset , --1
						oldPos01 + theHalfOffset, --2
						oldPos01 + theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ) ,  --3
						oldPos01 - theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ), --4
						
						oldPos02 + theHalfOffset, --5
						oldPos02 - theHalfOffset, --6
						oldPos02 - theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ) ,  --7
						oldPos02 + theHalfOffset + theY * (height+thickness/2+thickness*dashOvershoot ), --8
						
						oldPos01 - theHalfOffset  - theX*thickness*arrowOvershoot + theY * (height-thickness/2), --9
						oldPos01 - theHalfOffset - theX*thickness*arrowOvershoot + theY * (height+thickness/2), --10
						oldPos02 + theHalfOffset + theX*thickness*arrowOvershoot + theY * (height-thickness/2), --11
						oldPos02 + theHalfOffset + theX*thickness*arrowOvershoot + theY * (height+thickness/2) --12
					)
					faceArray = #([1,2,3], [1,3,4], [5,8,7], [5,7,6] , [9,11,12], [9,12,10])
					cnt = vertArray.count	
					local theOffset1 = oldPos01 + theY * height 
					local theOffset2 = oldPos02 + theY * height 					
					for i = 0 to 360 by 18 do
					(
						local theVector = ((rotateZMatrix i) *(matrix3 theX theY theZ [0,0,0] )).row1
						append vertArray (theOffset1 + theVector * thickness * arrowLength/2) --+ theY * thickness/2
						append vertArray (theOffset1 + theVector * thickness * arrowLength/2 + theVector  * thickness * arrowHeight) --+ theY * thickness/2
						append faceArray [cnt+1, cnt+2, cnt+4]
						append faceArray [cnt+1, cnt+4, cnt+3]
						cnt +=2
					)
					append vertArray (theOffset1 + theX * arrowLength/2+ theX * arrowHeight)	
					append vertArray (theOffset1 + theX * arrowLength/2)
					
					cnt = vertArray.count	
					for i = 0 to 360 by 18 do
					(
						local theVector = ((rotateZMatrix i) *(matrix3 theX theY theZ [0,0,0] )).row1
						append vertArray (theOffset2 + theVector * thickness * arrowLength/2) --+ theY * thickness/2
						append vertArray (theOffset2 + theVector * thickness * arrowLength/2+ theVector  * thickness * arrowHeight) --+ theY * thickness/2
						append faceArray [cnt+1, cnt+2, cnt+4]
						append faceArray [cnt+1, cnt+4, cnt+3]
						cnt +=2
					)
					append vertArray (theOffset2 + theX * arrowLength/2+ theX * arrowHeight)				
					append vertArray (theOffset2 + theX * arrowLength/2)
					
				)--end case 5
				)--end case of
				
				cnt = vertArray.count
				if useDivisions	then
				(
					majorDiv = majorDivisions-1 
					for i = 0 to theDistance by minorDivisions do
					(
						majorDiv += 1
						if majorDiv == majorDivisions then
						(
							majorDiv = 0
							append vertArray (oldPos01 + theX * i - theX*majorDivisionsThickness /2 + theY * height + theY *thickness * 0.5 ) 
							append vertArray (oldPos01 +theX * i - theX*majorDivisionsThickness /2 + theY * height + theY * majorDivisionsLength  )
							append vertArray (oldPos01 +theX * i + theX*majorDivisionsThickness /2 + theY * height + theY * majorDivisionsLength  )
							append vertArray (oldPos01 +theX * i + theX*majorDivisionsThickness /2 + theY * height + theY *thickness * 0.5) 
						)
						else
						(
							append vertArray (oldPos01 + theX * i - theX*minorDivisionsThickness /2 + theY * height  + theY *thickness * 0.5) 
							append vertArray (oldPos01 +theX * i - theX*minorDivisionsThickness /2 + theY * height + theY * minorDivisionsLength  )
							append vertArray (oldPos01 +theX * i + theX*minorDivisionsThickness /2 + theY * height + theY * minorDivisionsLength  )
							append vertArray (oldPos01 +theX * i + theX*minorDivisionsThickness /2 + theY * height + theY *thickness * 0.5) 
						)	
						join faceArray #([cnt+1,cnt+3,cnt+2], [cnt+1,cnt+4,cnt+3])
						cnt += 4
					)	
				)
				
				setMesh mesh vertices:vertArray faces:faceArray
			)
		)	
	)
	on buildMesh do updateDimension()

)--end plugin

fn DIMaster_GetMostOrthogonalPlane =
(
	thePlaneNormals = #([0,0,1],[0,1,0], [0,-1,0], [1,0,0], [-1,0,0],[0,0,-1]) 
	theAngles = #()
	for i in thePlaneNormals do
	(
		theViewVector = -(normalize (inverse (viewport.getTM())).row3)
		append theAngles (acos (dot i theViewVector))
	)	
	findItem theAngles (amin theAngles)
)

fn DIMaster_GetSnapPoint =
(
	local theHitData = #()
	local theHitPos = snapMode.worldHitPoint
	local theHitNode = snapMode.node
	if isValidNode theHitNode and canConvertTo theHitNode Editable_Mesh do
	(
		--format "Snap Hit Point = %, Node = %\n" theHitPos theHitNode.name
		local theMesh = snapshotasmesh theHitNode
		for f = 1 to theMesh.numfaces do
		(
			theBary = meshop.getBaryCoords theMesh f theHitPos
			if theBary.x >= 0 and theBary.y >= 0 and theBary.z >= 0 do
			(
				theFace = getFace theMesh f
				v1 = getVert theMesh theFace.x
				v2 = getVert theMesh theFace.y
				v3 = getVert theMesh theFace.z
				thePointAccordingToBary = v1 * theBary.x + v2 * theBary.y + v3 * theBary.z
				theDist = (distance thePointAccordingToBary theHitPos)
				format "% - %\n" f theDist 
				if theDist < 0.0001 do
				(
					theHitData = #(theHitNode, f, theBary, thePointAccordingToBary, theHitPos, theDist)
					--format "% Bary = % Point = %  Hit = %  Dist = %\n" f theBary thePointAccordingToBary theHitPos theDIst
					exit
				)	
			)	
		)
		delete theMesh
	)	
	theHitData
)--end fn 

fn DIMaster_AttachHelperTo thePoint theData =
(
	local theCtrl = attachment()
	local newPoint = Point pos:thePoint.pos size:2 cross:false box:false centermarker:true
	newPoint.name = uniquename (thePoint.name + "_Attach")
	setUserProp newPoint "DIMaster" true
	thePoint.parent = newPoint
	newPoint.position.controller = theCtrl
	theCtrl.align = false
	theCtrl.node = theData[1]
	addNewKey theCtrl 0f
	theAKey = AttachCtrl.getKey theCtrl 1
	theAKey.face = theData[2]-1
	theAKey.coord = [ theData[3].x, theData[3].y] 
)

tool createDimensionLine
(
	local DIMaster_FirstHitData = #()
	local DIMaster_SecondHitData = #()

	on mousePoint clickno do
	(
		case clickno of 
		(
			1: 
			(
				persistent global DimensionSystemMaterial 
				persistent global DimensionSystemTextMaterial 
				if DimensionSystemMaterial == undefined do 
				(
					theDIMs = for o in objects where matchPattern ((classof o) as string) pattern:"DIM*" and o.material != undefined collect o
					if theDIMs.count > 0 then
					(
						DimensionSystemMaterial = theDIMs[1].material
						try(DimensionSystemTextMaterial = theDIMs[1].textNode.material)catch()
					)
					else
					(
						DimensionSystemMaterial = (standard diffuse:black twosided:true selfillumamount:100)
						DimensionSystemMaterial.name = "DIMaster Lines"
					)	
					if DimensionSystemTextMaterial == undefined do 
					(
						DimensionSystemTextMaterial = (standard diffuse:(blue*0.5) twosided:true selfillumamount:100)
						DimensionSystemTextMaterial.name = "DIMaster Text"
					)	
				)		
				flipTheAxis = false
				DIMaster_p1 = point pos:worldPoint size:4 wirecolor:red box:true cross:true centermarker:false
				
				case DIMaster_GetMostOrthogonalPlane() of
				(
					1: ( flipTheAxis = true ) --top --
					2: ( 
						thePos = DIMaster_p1.pos
						DIMaster_p1.transform = rotateXmatrix 90
						DIMaster_p1.pos = thePos 					
					)
					3: (
						thePos = DIMaster_p1.pos
						DIMaster_p1.transform = rotateXmatrix -90
						DIMaster_p1.pos = thePos 						
					)
					4: (
						thePos = DIMaster_p1.pos
						DIMaster_p1.transform = rotateYmatrix -90
						DIMaster_p1.pos = thePos 						
					)
					5: (
						thePos = DIMaster_p1.pos
						DIMaster_p1.transform = rotateYmatrix 90
						DIMaster_p1.pos = thePos 						
					)
					6: ( ) --bottom
				)
				
				DIMaster_p2 = point pos:worldPoint size:2 wirecolor:green box:false cross:true centermarker:false
				DIMaster_theDim = DIMline wirecolor:black material:DimensionSystemMaterial name:(uniquename "DIM_Line_")
				DIMaster_theDim.isFrozen = true
				DIMaster_theDim.dirtyFlag = true
				DIMaster_p1.name = (uniquename (DIMaster_theDim.name+"_PointA_") )
				DIMaster_p2.name = (uniquename (DIMaster_theDim.name+"_PointB_") )
				DIMaster_p2.parent = DIMaster_p1
				
				DIMaster_theDim.transform.controller = transform_script()
				DIMaster_theDim.transform.controller.script = "matrix3 1"
				DIMaster_theDim.showfrozeningray = false
				DIMaster_theDim.node01 = DIMaster_p1
				DIMaster_theDim.node02 = DIMaster_p2
				DIMaster_theText = text size:5 wirecolor:black material:DimensionSystemTextMaterial name:(uniquename (DIMaster_theDim.name+"_Text_") )
				DIMaster_theText.steps =2
				DIMaster_theDim.textNode = DIMaster_theText			
				DIMaster_theText.backfacecull = DIMaster_TheDim.backfacecull = false

				DIMaster_theDim.invertUpAxis = flipTheAxis
				addModifier DIMaster_theText (Mesh_Select())
				
				setUserProp DIMaster_theText "DIMaster" true
				setUserProp DIMaster_p1 "DIMaster" true
				setUserProp DIMaster_p2 "DIMaster" true
				
				DIMasterFunctions.loadSettingsFromPreferences DIMaster_theDim
			)	
			2: (
				DIMaster_firstPoint = worldPoint 
				DIMaster_FirstHitData = DIMaster_getSnapPoint()
				--format "%\n" DIMaster_FirstHitData 
				)
			3: (
				DIMaster_SecondHitData = DIMaster_getSnapPoint()
				--format "%\n" DIMaster_SecondHitData 
				if DIMaster_AttachToSnapped == true and (DIMaster_FirstHitData.count > 0 or DIMaster_SecondHitData.count > 0) then
				(
					/*
					txt = "You have snapped DIMaster Control Points to \n"
					if DIMaster_FirstHitData.count > 0 do txt += "Point 1 - Object:" + DIMaster_FirstHitData[1].name + ", Face: "+ DIMaster_FirstHitData[2] as string+" \n"
					if DIMaster_SecondHitData.count > 0 do txt += "Point 2 - Object:" + DIMaster_SecondHitData[1].name + ", Face: "+ DIMaster_SecondHitData[2] as string+" \n"
					txt += "Do you want to Constrain the snapped point(s) using Attachment?"
					q = querybox txt
					if q == true do
					*/
					(
						DIMaster_theDim.isAnimatable = true
						if DIMaster_FirstHitData.count > 0 do 
						(
							DIMaster_AttachHelperTo DIMaster_p1 DIMaster_FirstHitData
							--DIMaster_p1.centermarker = true
							--DIMaster_p1.cross = DIMaster_p1.box = false
						)	
						if DIMaster_SecondHitData.count > 0 do 
						(
							DIMaster_AttachHelperTo DIMaster_p2 DIMaster_SecondHitData
							--DIMaster_p2.parent = undefined
							--DIMaster_p2.centermarker = true
							--DIMaster_p2.cross = DIMaster_p2.box = false
						)	
					)
				)
				DIMaster_theDim.isFrozen = false
				select DIMaster_theDim
				DIMaster_theDim = undefined
				#stop
			)
		)	
	)	
	
	on mouseMove clickno do 
	(
		case clickno of
		(
			2: (
				DIMaster_p1.pos = worldPoint
			)
			3: (
				DIMaster_p2.pos = worldPoint
			)
		)	
	)	
)--end tool




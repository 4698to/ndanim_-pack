--------------------------------------------------------------------------
--DIMaster v2.0
--Angle Tool
--Last Edited: 2008/02/05
--Code by Borislav "Bobo" Petrov
--http://www.scriptspot.com/bobo 
--------------------------------------------------------------------------
global DIMaster_p1, DIMaster_p2, DIMaster_p3, DIMaster_theDim, DIMaster_firstPoint, DIMaster_theText
global DIMaster_GlobalEdit = false
global DIMasterFunctions
global DIMaster_AttachToSnapped 

plugin simpleObject DIMangle
name:"DIMangle"
classID:#(0x5a7712e7, 0x3eeb17d7)
invisible:true
category:"DIMaster"
(
	local updateDimension
	local dirtyFlag = true
	local lastAnimationFrame = 0
	local oldPos01, oldPos02, oldPos03, oldParentPos 
	fn redrawDim globalUpdate:#none theValue:0 = 
	(
		dirtyFlag = true
		updateDimension()
		if DIMaster_GlobalEdit == true then
		(
			for o in objects where not o.isHiddenInVpt and classof o.baseobject == DIMangle and o != selection[1] do
			(
				case globalUpdate of
				(
					default: ()
					#isAnimatable: (o.isAnimatable = theValue)
					#pointHelperSize: (o.pointHelperSize = theValue)
					#thickness: (o.thickness = theValue)
					#angleRadius: (o.angleRadius = theValue)
					#linesRadius : (o.linesRadius = theValue)
					#useLineRadius : (o.useLineRadius = theValue)
					#invertUpAxis : (o.invertUpAxis = theValue)
					#flipHorizontal : (o.flipHorizontal = theValue)
					#flipVertical : (o.flipVertical = theValue)
					#alignTextToView: (o.alignTextToView = theValue)					
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
					#show360 : (o.show360 = theValue)
					#decimalPrecision : (o.decimalPrecision = theValue)
					#extendDashed1 : (o.extendDashed1 = theValue)
					#extendDashed2 : (o.extendDashed2 = theValue)
					#extend1Dash: (o.extend1Dash = theValue)
					#extend2Dash: (o.extend2Dash = theValue)
					#extend1Pause: (o.extend1Pause= theValue)
					#extend2Pause: (o.extend2Pause= theValue)
				)
				o.dirtyFlag = true
			)	
		)	
	)
	
	parameters main rollout:params
	(
		node01 type:#node
		node02 type:#node
		node03 type:#node
		textNode type:#node 

		forceAnimationTrack  type:#float
		isAnimatable type:#boolean default:false ui:chk_isAnimatable 
		pointHelperSize type:#float default:2 ui:spn_pointHelperSize 
		
		invertUpAxis type:#boolean default:false ui:chk_invertUpAxis 
		flipHorizontal type:#boolean default:false ui:chk_flipHorizontal 
		flipVertical type:#boolean default:false ui:chk_flipVertical
		alignTextToView type:#boolean default:false ui:chk_alignTextToView

		thickness type:#worldunits default:1 ui:spn_thickness
		angleRadius type:#worldunits default:10 ui:spn_angleRadius 
		linesRadius type:#worldunits default:50 ui:spn_linesRadius
		useLineRadius type:#boolean default:false ui:chk_useLineRadius 

		extendDashed1 type:#boolean default:false ui:chk_extendDashed1
		extend1Dash type:#worldunits default:5 ui:spn_extend1Dash 
		extend1Pause type:#worldunits default:5 ui:spn_extend1Pause
		extendDashed2 type:#boolean default:false ui:chk_extendDashed2
		extend2Dash type:#worldunits default:5 ui:spn_extend2Dash 
		extend2Pause type:#worldunits default:5 ui:spn_extend2Pause
		
		linkDash1 type:#boolean default:false animatable:false ui:chk_linkDash1
		linkDash2 type:#boolean default:false animatable:false ui:chk_linkDash2

		linkDashes type:#boolean default:false animatable:false ui:chk_linkDashes


		customDistance type:#worldunits 
		customAngle type:#float

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
		
		on thickness set val do redrawDim globalUpdate:#thickness theValue:val
		on angleRadius set val do redrawDim globalUpdate:#angleRadius theValue:val	
		on linesRadius set val do redrawDim globalUpdate:#linesRadius theValue:val	
		
		on invertUpAxis set val do redrawDim globalUpdate:#invertUpAxis theValue:val
		on flipHorizontal set val do redrawDim globalUpdate:#flipHorizontal theValue:val
		on flipVertical set val do redrawDim globalUpdate:#flipVertical theValue:val
		on alignTextToView set val do redrawDim globalUpdate:#alignTextToView theValue:val		
			
		on extendDashed1 set val do redrawDim globalUpdate:#extendDashed1 theValue:val	
		on extendDashed2 set val do redrawDim globalUpdate:#extendDashed2 theValue:val	
		on extend1Dash set val do redrawDim globalUpdate:#extend1Dash theValue:val	
		on extend2Dash set val do redrawDim globalUpdate:#extend2Dash theValue:val	
		on extend1Pause set val do redrawDim globalUpdate:#extend1Pause theValue:val	
		on extend2Pause set val do redrawDim globalUpdate:#extend2Pause theValue:val	
		
		on useLineRadius set val do redrawDim globalUpdate:#useLineRadius theValue:val	
	)

	parameters textcontrols rollout:textrollout
	(	
		textSize type:#float default:10 ui:spn_textSize
		textOffsetX type:#worldunits default:25 ui:spn_textOffsetX
		textOffsetY type:#worldunits default:1 ui:spn_textOffsetY
		textOffsetZ type:#worldunits default:0 ui:spn_textOffsetZ

		usePrefix type:#boolean default:false ui:chk_usePrefix
		userPrefix type:#string default:"" ui:edt_userPrefix

		useUserText type:#boolean default:false ui:chk_userText
		userText type:#string default:"" ui:edt_userText

		useSuffix type:#boolean default:false ui:chk_useSuffix
		userSuffix type:#string default:"" ui:edt_userSuffix

		textMode type:#integer default:1 ui:rad_textMode 
		show360 type:#boolean default:true ui:chk_show360 

		decimalPrecision type:#integer default:4 ui:spn_decimalPrecision
		
		on userPrefix set val do redrawDim globalUpdate:#userPrefix theValue:val
		on userSuffix set val do redrawDim globalUpdate:#userSuffix theValue:val
		on useUserText set val do redrawDim globalUpdate:#useUserText theValue:val
		on userText set val do redrawDim globalUpdate:#userText theValue:val
		on useSuffix set val do redrawDim globalUpdate:#useSuffix theValue:val
		on usePrefix set val do redrawDim globalUpdate:#usePrefix theValue:val
		
		on textOffsetX set val do redrawDim globalUpdate:#textOffsetX theValue:val
		on textOffsetY set val do redrawDim globalUpdate:#textOffsetY theValue:val
		on textOffsetZ set val do redrawDim globalUpdate:#textOffsetZ theValue:val
		
		on textSize set val do redrawDim globalUpdate:#textSize theValue:val		
		on textMode set val do redrawDim globalUpdate:#textMode theValue:val		
		on show360 set val do redrawDim globalUpdate:#show360 theValue:val	
		on decimalPrecision set val do redrawDim globalUpdate:#decimalPrecision theValue:val	
		
	)
	
	rollout params "DIMaster Angle Parameters"
	(
		checkbutton ckb_globalEdit ">Global Edit" width:150 offset:[0,-2] align:#center
		on ckb_globalEdit changed state do DIMaster_GlobalEdit = state

		checkbutton chk_isAnimatable ">Enable Animation" width:150 offset:[0,0] align:#center	
	
		checkbox chk_invertUpAxis "Flip Axis" offset:[0,-2] 
		checkbox chk_flipHorizontal "Flip Text Horizontally" offset:[0,-2]
		checkbox chk_flipVertical "Flip Text Vertically" offset:[0,-2]
		checkbox chk_alignTextToView "Align Text To View" align:#left offset:[0,-2]		
		
		group "Drawing Parameters"
		(
			spinner spn_thickness "Line Thickness:" fieldwidth:50 scale:0.01 range:[0.0,100,0] type:#float offset:[0,-2]
			spinner spn_angleRadius "Angle Radius:" fieldwidth:50 scale:0.01 range:[0.0,100,0] type:#float offset:[0,-2]
			spinner spn_linesRadius "Lines Radius:" fieldwidth:50 scale:0.01 range:[0.0,10000,0] type:#float offset:[0,-2]
			checkbox chk_useLineRadius "Limit Lines To Radius" align:#left offset:[0,-2]
		)	
		group "Extended Dashed Line"
		(
			checkbox chk_extendDashed1 "Extend Dashed Line 1" align:#left offset:[-5,-2]
			spinner spn_extend1Dash "Dash:" fieldwidth:50 scale:0.01 range:[0.01,100,0] type:#float offset:[-15,-2]
			spinner spn_extend1Pause "Space:" fieldwidth:50 scale:0.01 range:[0.01,100,0] type:#float offset:[-15,-2]
			checkbutton chk_linkDash1 "[" height:32 width:18 align:#left offset:[5,-40]
			
			checkbox chk_extendDashed2 "Extend Dashed Line 2" align:#left offset:[-5,0] across:2
			checkbutton chk_linkDashes "]" height:91 width:18 align:#right offset:[5,-38]
			
			spinner spn_extend2Dash "Dash:" fieldwidth:50 scale:0.01 range:[0.01,100,0] type:#float offset:[-15,-40]
			spinner spn_extend2Pause "Space:" fieldwidth:50 scale:0.01 range:[0.01,100,0] type:#float offset:[-15,-2]
			checkbutton chk_linkDash2 "[" height:32 width:18 align:#left offset:[5,-40]
		)
		spinner spn_pointHelperSize "Point Helper Size:" fieldwidth:50  range:[0,1000,2] type:#float offset:[0,0]


		on spn_extend1Dash changed val do
		(
			if chk_linkDash1.state then extend1Pause = val
			if chk_linkDashes.state then 
			(
				extend2Dash = val
				if chk_linkDash2.state then extend2Pause = val
			)	
		)
		on spn_extend2Dash changed val do
		(
			if chk_linkDash2.state then extend2Pause = val
			if chk_linkDashes.state then 
			(
				extend1Dash = val
				if chk_linkDash1.state then extend1Pause = val
			)	
		)	
		on spn_extend1Pause changed val do
		(
			if chk_linkDash1.state then extend1Dash = val
			if chk_linkDashes.state then 
			(
				extend2Pause = val
				if chk_linkDash2.state then extend2Dash = val
			)	
		)
		on spn_extend2Pause changed val do
		(
			if chk_linkDash2.state then extend2Dash = val
			if chk_linkDashes.state then 
			(
				extend1Pause = val
				if chk_linkDash1.state then extend1Dash = val
			)	
		)	

		fn updateExtendDashesUI =
		(
			chk_extendDashed1.enabled = spn_extend1Dash.enabled = spn_extend1Pause .enabled = useLineRadius
			chk_linkDash1 .enabled = chk_extendDashed2.enabled = useLineRadius
			chk_linkDashes.enabled = 	spn_extend2Dash.enabled =  spn_extend2Pause.enabled =  chk_linkDash2.enabled = useLineRadius
		)
		
		on chk_useLineRadius changed state do updateExtendDashesUI()
		
		on params open do
		(
			ckb_globalEdit.checked = DIMaster_GlobalEdit == true
			updateExtendDashesUI()
		)		

	)	
	
	rollout textrollout "DIMaster Angle Text"
	(
		group "Text Size and Placement"
		(
			spinner spn_textSize "Font Size:" fieldwidth:50 scale:0.01 range:[0,1000,0] type:#float offset:[0,-2]
			spinner spn_textOffsetX "Horiz. Offset" fieldwidth:50 scale:0.01 range:[0,10000,0] type:#float offset:[0,-2]
			spinner spn_textOffsetY "Vertical Offset:" fieldwidth:50 scale:0.01 range:[-10000,10000,0] type:#float offset:[0,-2]
			spinner spn_textOffsetZ "Off-Plane Offset:" fieldwidth:50 scale:0.01 range:[-10000,10000,0] type:#float offset:[0,-2]
		)
		
		fn filterDimLines o = (classof o == DIMline or classof o == DIMangle or classof o == DIMnote or classof o.baseobject == Text)

		button btn_copyFont "Assign Font Globally" width:150 align:#center offset:[0,-2]
		pickbutton pck_getFont "Acquire Font From..." width:150 align:#center offset:[0,-2]			
		
		group "Custom Text"
		(
			checkbox chk_usePrefix align:#left across:2 offset:[0,-2]
			edittext edt_userPrefix "Prefix:" fieldwidth:80 align:#right offset:[0,-2]
			checkbox chk_userText align:#left across:2 offset:[0,-2]
			edittext edt_userText "Text:" fieldwidth:80 align:#right offset:[0,-2]
			checkbox chk_useSuffix align:#left across:2 offset:[0,-2]
			edittext edt_userSuffix "Suffix:" fieldwidth:80 align:#right offset:[0,-2]
			radiobuttons rad_textMode labels:#("Display Degrees","Display Radians") align:#left offset:[0,-2]
			checkbox chk_show360 "Show Full 360 degrees" offset:[0,-2]
			spinner spn_decimalPrecision "Decimal Precision:" range:[0,6,2] type:#integer fieldwidth:35 offset:[0,-2]
		)	

		on btn_copyFont pressed do
		(
			if querybox ("This will assign font [" + textNode.baseobject.font + "]\nto all visible DIMangle Text Objects in the scene.\n\nAre you sure? ") title:"DIMangle Global Font"  then
				for o in objects where classof o == DIMangle and not o.isHiddenInVpt do
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
	
	rollout construct_angle "DIMaster Angle Constructor"
	(
		spinner spn_customAngle "Custom Angle:" range:[-360,360,45] fieldwidth:50 offset:[0,-2]
		spinner spn_distance "At Distance:" range:[0,10000000,100] fieldwidth:50 type:#worldunits offset:[0,-2]
		fn UpdateConstruction =
		(
			with animate off
			(
				theX = v1 = normalize (node02.pos - node01.pos)
				theDistance = distance node01 node02
				v2  = normalize (node03.pos - node01.pos)
				v3  = normalize (node03.pos - node02.pos)
				if invertUpAxis then
					theZ = normalize (cross v2 v1)
				else
					theZ = normalize (cross v1 v2)
				
				if abs theZ.z > 0.001 then theTest = theZ.z else theTest = theZ.y 
				if theTest < 0 then 
				(
					if invertUpAxis then
						theY = normalize (cross  theZ theX)
					else
						theY = normalize (cross theX theZ)
					above180 = true
				)	
				else				
				(
					if invertUpAxis then
						theY = normalize (cross theX theZ )
					else
						theY = normalize (cross theZ theX)
					above180 = false
				)
				theVector = ((rotateZMatrix spn_customAngle.value) *(matrix3 theX theY theZ [0,0,0] )).row1
				node03.pos = node01.pos + theVector * spn_distance.value 
			)	
		)
		
		on spn_customAngle changed val do UpdateConstruction()
		on spn_distance changed val do UpdateConstruction()
		
		on construct_angle open do
		(
			with animate off
			(
				spn_distance.value = customDistance
				spn_customAngle.value = customAngle
			)	
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
		if node01 != undefined and node02 != undefined and node03 != undefined do
		(
			if (dirtyFlag == true or (isAnimatable AND lastAnimationFrame != currentTime) or node01.pos != oldPos01 or node02.pos != oldPos02  or node03.pos != oldPos03 or (node01.parent != undefined and node01.parent.pos != oldParentPos )) do
			(
				oldPos01	= node01.pos 
				oldPos02	= node02.pos 
				oldPos03	= node03.pos 

				with animate off
				(
					node01.size = pointHelperSize * 2
					node03.size = node02.size = pointHelperSize
				)	
				
				
				lastAnimationFrame = currentTime
				if node01.parent != undefined do oldParentPos = node01.parent.pos
				
				dirtyFlag = false
				
				theX = v1 = normalize (node02.pos - node01.pos)
				theDistance = distance node01 node02
				v2  = normalize (node03.pos - node01.pos)
				v3  = normalize (node03.pos - node02.pos)
				if invertUpAxis then
					theZ = normalize (cross v2 v1)
				else
					theZ = normalize (cross v1 v2)
				
				theAngleRadius = amin #(angleRadius, distance node01 node02, distance node01 node03)
				
				
				if abs theZ.z > 0.001 then theTest = theZ.z else theTest = theZ.y 
				if theTest < 0 then 
				(
					if invertUpAxis then
					(
						theY = normalize (cross  theZ theX)
						theY2 = normalize (cross theZ v2)
					)	
					else
					(
						theY = normalize (cross theX theZ)
						theY2 = normalize (cross v2 theZ)
					)	
					above180 = true
				)	
				else				
				(
					if invertUpAxis then
					(
						theY = normalize (cross theX theZ )
						theY2 = normalize (cross v2 theZ )
					)
					else
					(
						theY = normalize (cross theZ theX)
						theY2 = normalize (cross theZ v2)
					)	
					above180 = false
				)
	
				if useLineRadius then
				(
					endPos2 = amin #(linesRadius, distance node02 node01)
					endPos3 = amin #(linesRadius, distance node03 node01)
				)	
				else
				(
					endPos2 = distance node02 node01
					endPos3 = distance node03 node01
				)
				
				local theAngle= acos (dot v1 v2)  
				if textNode != undefined do
				(
					with animate off
					(				
						if above180 and show360 then theAngleToDisplay = 360 - theAngle else theAngleToDisplay = theAngle
						if textMode == 2 then theAngleToDisplay = degToRad theAngleToDisplay
						theAngleToDisplay *= 10.0^decimalPrecision
						theAngleToDisplay = floor (theAngleToDisplay + 0.5)
						theAngleToDisplay /= 10.0^decimalPrecision
						local txt = ""
						if usePrefix do txt+= userPrefix +" "
						txt += if useUserText then userText else FillInTrailingZeros (theAngleToDisplay as string)
						if useSuffix do txt+= " " +userSuffix 
						textNode.text = txt 
						textNode.size = textSize
						if alignTextToView then
						(
							local theViewTM = inverse (viewport.getTM())
							theViewTM.row4 = (oldPos01 + theZ*textOffsetZ + (theX*angleRadius + theX * TextOffsetX )  + theY *(thickness+textOffsetY ))
							textNode.transform = theViewTM	
						)		
						else
						(
							theTMX = if flipHorizontal then -theX else theX
							theTMY = if flipVertical then -theY else theY
							textNode.transform = matrix3 theTMX theTMY theZ (oldPos01 + theZ*textOffsetZ + (theX*angleRadius + theX * TextOffsetX )  + theY *(thickness+textOffsetY ))
						)	
						customDistance = distance node01 node03
						customAngle = theAngle
					)	
				)
				
				vertArray = #(
					oldPos01 + theY * thickness/2,  --1
					oldPos01 + v1 * endPos2 + theY * thickness/2,  --2
					oldPos01 + v1 * endPos2 - theY * thickness/2, --3
					oldPos01 - theY * thickness/2 ,  --4
					oldPos01 - theY2 * thickness/2,  --5
					oldPos01 + v2 * endPos3 - theY2 * thickness/2,  --6
					oldPos01 + v2 * endPos3 + theY2 * thickness/2,  --7
					oldPos01 + theY2 * thickness/2  --8
				)
				faceArray = #([1,3,2], [1,4,3], [5,6,7], [5,7,8]  )
				
				--ANGLE ARC
				cnt = vertArray.count
				if show360 then
				(
					if above180 do theAngle = 360 - theAngle
					startAngle = 0.0
					endAngle = theAngle 
					theStep = 10
				)
				else
				(
					if above180 then
					(
						startAngle = 0.0
						endAngle = -theAngle
						theStep = -10
					)
					else
					(
						startAngle = 0.0
						endAngle = theAngle
						theStep = 10
					)	
				)	
				
				for i = startAngle to endAngle by theStep do
				(
					theVector = ((rotateZMatrix i) *(matrix3 theX theY theZ [0,0,0] )).row1
					append vertArray (oldPos01 + theVector * theAngleRadius + theY * thickness/2)
					append vertArray (oldPos01 + theVector * theAngleRadius + theVector  * thickness + theY * thickness/2)
					append faceArray [cnt+1, cnt+2, cnt+4]
					append faceArray [cnt+1, cnt+4, cnt+3]
					cnt +=2
				)
				theVector = ((rotateZMatrix endAngle ) *(matrix3 theX theY theZ [0,0,0] )).row1
				append vertArray (oldPos01 + theVector * theAngleRadius + theY * thickness/2)
				append vertArray (oldPos01 + theVector * theAngleRadius + theVector  * thickness + theY * thickness/2)

				--DASHED LINES
				if extendDashed1 do
				(
					cnt = vertArray.count
					endPos2full = distance node02 node01
					theStep = extend1Dash  + extend1Pause
					for i = endPos2 to endPos2full by theStep do
					(
						append vertArray (oldPos01 + v1 * (i) + theY * thickness/2)
						append vertArray (oldPos01 + v1 * (i) - theY * thickness/2)
						append vertArray (oldPos01 + v1 * (i+extend1Dash  ) + theY * thickness/2)
						append vertArray (oldPos01 + v1 * (i+extend1Dash  ) - theY * thickness/2)
						append faceArray [cnt+1, cnt+2, cnt+4]
						append faceArray [cnt+1, cnt+4, cnt+3]
						cnt += 4
					)--end i loop
				)
				if extendDashed2 do
				(
					cnt = vertArray.count
					endPos3full = distance node03 node01					
					theStep = extend2Dash  + extend2Pause
					for i = endPos3 to endPos3full by theStep do
					(
						append vertArray (oldPos01 + v2 * (i) + theY2 * thickness/2)
						append vertArray (oldPos01 + v2 * (i) - theY2 * thickness/2)
						append vertArray (oldPos01 + v2 * (i+extend2Dash) + theY2 * thickness/2)
						append vertArray (oldPos01 + v2 * (i+extend2Dash) - theY2 * thickness/2)
						append faceArray [cnt+1, cnt+2, cnt+4]
						append faceArray [cnt+1, cnt+4, cnt+3]
						cnt += 4
					)--end i loop
				)				
				setMesh mesh vertices:vertArray faces:faceArray
			)
		)	
	)
	on buildMesh do updateDimension()

)--end plugin

fn DIMaster_GetMostOrthogonalPlane =
(
	thePlaneNormals = #([0,0,1],[0,1,0], [0,-1,0], [1,0,0], [-1,0,0],[0,0,-1])  --top,front,back,left,right,bottom
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
	thePoint.position.controller = theCtrl
	theCtrl.node = theData[1]
	theCtrl.align = false
	addNewKey theCtrl 0f
	theAKey = AttachCtrl.getKey theCtrl 1
	theAKey.face = theData[2]-1
	theAKey.coord = [ theData[3].x, theData[3].y] 
)
tool createDimensionAngle
(
	local DIMaster_FirstHitData = #()
	local DIMaster_SecondHitData = #()
	local DIMaster_ThirdHitData = #()
	
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
				theTM  = (viewport.getTM()) as string
				
				case DIMaster_GetMostOrthogonalPlane() of
				(
					1: ( flipTheAxis = true ) --bottom
					2: ( flipTheAxis = true ) --front
					default: ( )
				)
				
				DIMaster_p1 = point pos:worldPoint size:4 wirecolor:red box:true cross:true centermarker:false
				DIMaster_p2 = point pos:worldPoint size:2 wirecolor:green box:false cross:true centermarker:false
				DIMaster_p3 = point pos:worldPoint size:2 wirecolor:blue box:false cross:true centermarker:false
				DIMaster_p3.parent = DIMaster_p1
				DIMaster_p2.parent = DIMaster_p1
				
				DIMaster_theDim = DIMAngle wirecolor:black material:DimensionSystemMaterial name:(uniquename "DIM_Angle_")
				DIMaster_theDim.dirtyFlag = true
				DIMaster_theDim.isFrozen = true
				DIMaster_p1.name = (uniquename (DIMaster_theDim.name+"_PointA_") )
				DIMaster_p2.name = (uniquename (DIMaster_theDim.name+"_PointB_") )
				DIMaster_p3.name = (uniquename (DIMaster_theDim.name+"_PointC_") )
				
				DIMaster_theDim.transform.controller = transform_script()
				DIMaster_theDim.transform.controller.script = "matrix3 1"
				DIMaster_theDim.showfrozeningray = false
				DIMaster_theDim.node01 = DIMaster_p1
				DIMaster_theDim.node02 = DIMaster_p2
				DIMaster_theDim.node03 = DIMaster_p3
				
				DIMaster_theText = text size:5 wirecolor:black material:DimensionSystemTextMaterial name:(uniquename (DIMaster_theDim.name+"_Text_") )
				DIMaster_theDim.textNode = DIMaster_theText			
				DIMaster_theText.backfacecull = DIMaster_TheDim.backfacecull = false
				DIMaster_theDim.invertUpAxis = flipTheAxis
				DIMaster_theText.steps =2

				setUserProp DIMaster_theText "DIMaster" true
				setUserProp DIMaster_p1 "DIMaster" true
				setUserProp DIMaster_p2 "DIMaster" true
				setUserProp DIMaster_p3 "DIMaster" true
				
				addModifier DIMaster_theText (Mesh_Select())
				
				DIMasterFunctions.loadSettingsFromPreferences DIMaster_theDim
			)	
			2 :
			(
				DIMaster_FirstHitData = DIMaster_getSnapPoint()
			)
			3: (
				DIMaster_firstPoint = worldPoint 
				DIMaster_SecondHitData = DIMaster_getSnapPoint()
				)
			4: (
				DIMaster_ThirdHitData = DIMaster_getSnapPoint()

				if DIMaster_AttachToSnapped == true and (DIMaster_FirstHitData.count > 0 or DIMaster_SecondHitData.count > 0 or DIMaster_ThirdHitData.count > 0 ) then
				(
					/*
					txt = "You have snapped DIMaster Control Points to \n"
					if DIMaster_FirstHitData.count > 0 do txt += "Point 1 - Object: " + DIMaster_FirstHitData[1].name + ", Face: "+ DIMaster_FirstHitData[2] as string+" \n"
					if DIMaster_SecondHitData.count > 0 do txt += "Point 2 - Object: " + DIMaster_SecondHitData[1].name + ", Face: "+ DIMaster_SecondHitData[2] as string+" \n"
					if DIMaster_ThirdHitData.count > 0 do txt += "Point 2 - Object: " + DIMaster_ThirdHitData[1].name + ", Face: "+ DIMaster_ThirdHitData[2] as string+" \n"
					
					txt += "Do you want to Constrain the snapped point(s) using Attachment?"
					q = querybox txt
					if q == true do
					*/
					(
						DIMaster_theDim.isAnimatable = true
						if DIMaster_FirstHitData.count > 0 do 
						(
							DIMaster_AttachHelperTo DIMaster_p1 DIMaster_FirstHitData
							DIMaster_p1.centermarker = true
							DIMaster_p1.cross = DIMaster_p1.box = false
						)	
						if DIMaster_SecondHitData.count > 0 do 
						(
							DIMaster_AttachHelperTo DIMaster_p2 DIMaster_SecondHitData
							DIMaster_p2.parent = undefined
							DIMaster_p2.centermarker = true
							DIMaster_p2.cross = DIMaster_p2.box = false
						)	
						if DIMaster_ThirdHitData.count > 0 do 
						(
							DIMaster_AttachHelperTo DIMaster_p3 DIMaster_ThirdHitData 
							DIMaster_p3.parent = undefined
							DIMaster_p3.centermarker = true
							DIMaster_p3.cross = DIMaster_p3.box = false
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
			2: ( DIMaster_p1.pos = worldPoint; DIMaster_p2.pos = worldPoint + [10,0,0]; DIMaster_p3.pos = worldPoint + [10,10,0])
			3: (DIMaster_p2.pos = worldPoint; DIMaster_p3.pos = worldPoint + [10,10,0])
			4: DIMaster_p3.pos = worldPoint
		)	
	)	
)--end tool


--------------------------------------------------------------------------
--DIMaster v2.0 
--Notes Tool
--Last Edited: 2008/02/05
--Code by Borislav "Bobo" Petrov
--http://www.scriptspot.com/bobo 
--------------------------------------------------------------------------

global DIMaster_p1, DIMaster_p2, DIMaster_p3, DIMaster_theDim, DIMaster_firstPoint, DIMaster_theText
global DIMaster_GlobalEdit = false


plugin simpleObject DIMnote
name:"DIMnote"
classID:#(0x5a7712e7, 0x3eeb17d8)
invisible:true
category:"DIMaster"
( 
	local updateDimension
	local dirtyFlag = true
	local oldPos01, oldPos02, oldPos03, oldParentPos
	local lastAnimationFrame = 0

	fn redrawDim globalUpdate:#none theValue:0 = 
	(
		dirtyFlag = true
		updateDimension()
		if DIMaster_GlobalEdit == true then
		(
			for o in objects where not o.isHiddenInVpt and classof o.baseobject == DIMnote and o != selection[1] do
			(
				case globalUpdate of
				(
					default: ()
					#pointHelperSize: (o.pointHelperSize = theValue)
					#isAnimatable: (o.isAnimatable = theValue)
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
					#textOffsetZ : (o.textOffsetY = theValue)
					#textSize : (o.textSize = theValue)
					#userPrefix : (o.userPrefix = theValue)
					#userSuffix : (o.userSuffix = theValue)
					#userText : (o.userText = theValue)
					#usePrefix : (o.usePrefix = theValue)
					#useSuffix : (o.useSuffix = theValue)
					#useUserText : (o.useUserText = theValue)
					#textMode : (o.textMode = theValue)
					#lineRight : (o.lineRight= theValue)
					#lineLeft : (o.lineLeft = theValue)

					#drawLine : (o.drawLine= theValue)
					#drawArrow : (o.drawArrow = theValue)
					#drawCross : (o.drawCross = theValue)
					#drawCircle : (o.drawCircle = theValue)
					#drawShadedCircle : (o.drawShadedCircle = theValue)
					#arrowWidth : (o.arrowWidth = theValue)
					#arrowHeight : (o.arrowHeight = theValue)
					
					
					#crossSize : (o.crossSize = theValue)
					#circleRadius : (o.circleRadius = theValue)
					#crossExtension1: (o.crossExtension1 = theValue)
					#crossExtension2: (o.crossExtension2 = theValue)
					#crossExtension3: (o.crossExtension3 = theValue)
					#crossExtension4: (o.crossExtension4 = theValue)
					
					#decimalPrecision : (o.decimalPrecision = theValue)
					#showX : (o.showX= theValue)
					#showY : (o.showY= theValue)
					#showZ : (o.showZ= theValue)
					#showVectorLength : (o.showVectorLength = theValue)
					
					#showXYZLabel : (o.showXYZLabel = theValue)
					#customDataMode: (o.customDataMode = theValue)
					#customDataSpeedMode: (o.customDataSpeedMode = theValue)
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
		taperValue type:#float default:0 ui:spn_taperValue
		lineRight type:#worldunits default:50 ui:spn_lineRight
		lineLeft type:#worldunits default:0 ui:spn_lineLeft
		
		crossSize type:#float default:10 ui:spn_crossSize
		crossExtension1 type:#float default:0 ui:spn_crossExtension1 
		crossExtension2 type:#float default:0 ui:spn_crossExtension2
		crossExtension3 type:#float default:0 ui:spn_crossExtension3 
		crossExtension4 type:#float default:0 ui:spn_crossExtension4 
		
		circleRadius type:#float default:5 ui:spn_circleRadius

		drawLine type:#boolean default:true ui:chk_drawLine 
		drawArrow type:#boolean default:true ui:chk_drawArrow 
		drawCross type:#boolean default:false ui:chk_drawCross 
		drawCircle type:#boolean default:false ui:chk_drawCircle 
		drawShadedCircle type:#boolean default:false ui:chk_drawShadedCircle 

		arrowWidth type:#float default:6 ui:spn_arrowWidth
		arrowHeight type:#float default:6 ui:spn_arrowHeight
		
		TotalValue type:#float default:0
		ValueX type:#float default:0
		ValueY type:#float default:0
		ValueZ type:#float default:0
		
		
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
	
		on invertUpAxis set val do redrawDim globalUpdate:#invertUpAxis theValue:val
		on flipHorizontal set val do redrawDim globalUpdate:#flipHorizontal theValue:val
		on flipVertical set val do redrawDim globalUpdate:#flipVertical theValue:val
		on alignTextToView set val do redrawDim globalUpdate:#alignTextToView theValue:val	
			
		on thickness set val do redrawDim globalUpdate:#thickness theValue:val
		on taperValue set val do redrawDim globalUpdate:#taperValue theValue:val
		on lineRight set val do redrawDim globalUpdate:#lineLeft theValue:val
		on lineLeft set val do redrawDim globalUpdate:#lineLeft theValue:val
		

	
		on drawLine set val do redrawDim globalUpdate:#drawLine theValue:val
		on drawArrow set val do redrawDim globalUpdate:#drawArrow theValue:val
		
		on drawCross set val do redrawDim globalUpdate:#drawCross theValue:val
		on drawCircle set val do redrawDim globalUpdate:#drawCircle theValue:val
		on drawShadedCircle set val do redrawDim globalUpdate:#drawShadedCircle theValue:val

		on arrowWidth set val do redrawDim globalUpdate:#arrowWidth theValue:val
		on arrowHeight set val do redrawDim globalUpdate:#arrowHeight theValue:val
		
		on crossSize set val do redrawDim globalUpdate:#crossSize theValue:val
		on crossExtension1 set val do redrawDim globalUpdate:#crossExtension1 theValue:val
		on crossExtension2 set val do redrawDim globalUpdate:#crossExtension2 theValue:val
		on crossExtension3 set val do redrawDim globalUpdate:#crossExtension3 theValue:val
		on crossExtension4 set val do redrawDim globalUpdate:#crossExtension4 theValue:val
		
		on circleRadius set val do redrawDim globalUpdate:#circleRadius theValue:val
	)
	
	parameters textcontrols rollout:textrollout
	(
		textSize type:#float default:10 ui:spn_textSize

		textOffsetX type:#worldunits default:0 ui:spn_textOffsetX
		textOffsetY type:#worldunits default:1 ui:spn_textOffsetY
		textOffsetZ type:#worldunits default:0 ui:spn_textOffsetZ

		usePrefix type:#boolean default:false ui:chk_usePrefix
		userPrefix type:#string default:"" ui:edt_userPrefix

		useUserText type:#boolean default:false ui:chk_userText
		userText type:#string default:"" ui:edt_userText

		useSuffix type:#boolean default:false ui:chk_useSuffix
		userSuffix type:#string default:"" ui:edt_userSuffix

		customDataMode type:#integer default:1 ui:ddl_customDataMode
		customDataNode type:#node 
		customDataProperty type:#string default:"" ui:edt_customDataProperty 
		customDataSpeedMode type:#integer default:2 ui:ddl_customDataSpeedMode
		
		textMode  type:#integer default:1 ui:rad_textMode 
		
		showXYZLabel type:#boolean default:true ui:chk_showXYZLabel
		showX type:#boolean default:true ui:chk_showX 
		showY type:#boolean default:true ui:chk_showY
		showZ type:#boolean default:true ui:chk_showZ 
		showVectorLength type:#boolean default:true ui:chk_showVectorLength

		decimalPrecision type:#integer default:4 ui:spn_decimalPrecision
		

		on textOffsetX set val do redrawDim globalUpdate:#textOffsetX theValue:val
		on textOffsetY set val do redrawDim globalUpdate:#textOffsetY theValue:val
		on textOffsetZ set val do redrawDim globalUpdate:#textOffsetZ theValue:val
		
		on textSize set val do redrawDim globalUpdate:#textSize theValue:val
		
		on userPrefix set val do redrawDim globalUpdate:#userPrefix theValue:val
		on userSuffix set val do redrawDim globalUpdate:#userSuffix theValue:val
		on useUserText set val do redrawDim globalUpdate:#useUserText theValue:val
		on userText set val do redrawDim globalUpdate:#userText theValue:val
		on useSuffix set val do redrawDim globalUpdate:#useSuffix theValue:val
		on usePrefix set val do redrawDim globalUpdate:#usePrefix theValue:val
		
		on textMode set val do redrawDim globalUpdate:#textMode theValue:val
		
		on decimalPrecision set val do redrawDim globalUpdate:#decimalPrecision theValue:val	
		on showX set val do redrawDim globalUpdate:#showX theValue:val	
		on showY set val do redrawDim globalUpdate:#showY theValue:val	
		on showZ set val do redrawDim globalUpdate:#showZ theValue:val	
		on showXYZLabel set val do redrawDim globalUpdate:#showXYZLabel theValue:val	
		on customDataMode set val do redrawDim globalUpdate:#customDataMode theValue:val	
		on customDataSpeedMode set val do redrawDim globalUpdate:#customDataSpeedMode theValue:val
		on showVectorLength set val do redrawDim globalUpdate:#showVectorLength theValue:val	
	)	
	
	rollout params "DIMaster Note Parameters"
	(
		checkbutton ckb_globalEdit ">Global Edit" width:150 offset:[0,-2] align:#center
		on ckb_globalEdit changed state do DIMaster_GlobalEdit = state
		
		checkbutton chk_isAnimatable ">Enable Animation" width:150 offset:[0,0] align:#center
		
		checkbox chk_invertUpAxis "Flip Up Axis" align:#left offset:[0,-2]
		checkbox chk_flipHorizontal "Flip Text Horizontal"  align:#left offset:[0,-2]
		checkbox chk_flipVertical "Flip Text Vertical" align:#left offset:[0,-2]
		checkbox chk_alignTextToView "Align Text To View" align:#left offset:[0,-2]		

		group "Drawing Parameters"
		(
			spinner spn_thickness "Line Thickness:" fieldwidth:50 scale:0.01 range:[0.0,100,0] type:#float offset:[0,-2]
			spinner spn_taperValue "Line Taper %:" fieldwidth:50 range:[0.0,100,0] type:#float offset:[0,-2]
			spinner spn_lineRight "Line Right:" fieldwidth:50 scale:0.01 range:[0.0,1000,0] type:#float offset:[0,-2]
			spinner spn_lineLeft "Line Left:" fieldwidth:50 scale:0.01 range:[0.0,1000,0] type:#float offset:[0,-2]
		)
			
		group "Icon Elements"
		(
			checkbox chk_drawLine "Line" across:2 offset:[-3,0]
			checkbox chk_drawArrow "Arrow" offset:[-14,0]
			checkbox chk_drawCross "Cross" offset:[-3,0]
			checkbox chk_drawCircle "Circle" across:2 offset:[-3,0]
			checkbox chk_drawShadedCircle "Shaded Circle" offset:[-14,0]
		)

		group ">Size Rel.To Line Thickness"
		(
			spinner spn_arrowWidth "Arrow Width:" fieldwidth:45 scale:0.01 range:[1,100,1] type:#float offset:[0,-2]
			spinner spn_arrowHeight "Arrow Height:" fieldwidth:45 scale:0.01 range:[1,100,1] type:#float offset:[0,-2]
		)

		group "Cross and Circle"	
		(
			spinner spn_crossSize "Cross Size:" fieldwidth:50 scale:0.01 range:[0,100,1] type:#float offset:[0,-2]
			spinner spn_crossExtension1 "Cross Ext Right:" fieldwidth:50 scale:0.01 range:[0,100,1] type:#float offset:[0,-2]
			spinner spn_crossExtension2 "Cross Ext Up:" fieldwidth:50 scale:0.01 range:[0,100,1] type:#float offset:[0,-2]
			spinner spn_crossExtension3 "Cross Ext Left:" fieldwidth:50 scale:0.01 range:[0,100,1] type:#float offset:[0,-2]
			spinner spn_crossExtension4 "Cross Ext Down:" fieldwidth:50 scale:0.01 range:[0,100,1] type:#float offset:[0,-2]
			spinner spn_circleRadius "Circle Radius:" fieldwidth:50 scale:0.01 range:[1,100,1] type:#float offset:[0,-2]
		)		

		spinner spn_pointHelperSize "Point Helper Size:" fieldwidth:50  range:[0,1000,2] type:#float offset:[0,0]

	
		
		on ddl_arrowType selected itm do 
		(
--			spn_crossSize.enabled = itm > 1
--			spn_circleRadius.enabled = itm > 2 
		)
		
		on params open do
		(
--			spn_crossSize.enabled = ddl_arrowType.selection > 1
--			spn_circleRadius.enabled = ddl_arrowType.selection > 2
			ckb_globalEdit.checked = DIMaster_GlobalEdit == true
		)
	)
	
	rollout textrollout "DIMaster Note Text"
	(
		group "Text Size and Placement"
		(
			spinner spn_textSize "Font Size:" fieldwidth:50 scale:0.01 range:[-100,100,0] type:#float offset:[0,-2]
			spinner spn_textOffsetX "Horiz. Offset:" fieldwidth:50 scale:0.01 range:[-10000,10000,0] type:#float offset:[0,-2]
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
			
			dropdownlist ddl_customDataMode items:#("World Space Position","Parent Space Position","Parent's Position","Note's Speed","Custom Object's Speed","Custom Object Property") width:150 align:#center
			dropdownlist ddl_customDataSpeedMode items:#("Units/frame","Units/second","Units/minute","Units/hour","MPH","km/h") width:150 align:#center offset:[0,-3]
			
			pickbutton pck_customDataNode ">>Pick Custom Objects" width:150 align:#center 
			edittext edt_customDataProperty "" fieldwidth:150 offset:[-11,0]
			
			radiobuttons rad_textMode labels:#("Display User Units","Display Generic Units") align:#left offset:[0,-2]

			checkbox chk_showXYZLabel "Show Axis Labels" align:#left offset:[0,-2]
			
			checkbox chk_showX "Show X Axis" align:#left offset:[10,-2]
			checkbox chk_showY "Show Y Axis" align:#left offset:[10,-2]
			checkbox chk_showZ "Show Z Axis" align:#left offset:[10,-2]
			checkbox chk_showVectorLength "Show Vector Length" align:#left offset:[10,-2]
			
			spinner spn_decimalPrecision "Decimal Precision:" range:[0,6,2] type:#integer fieldwidth:35 offset:[0,-2]
		)	
		
		fn updateEnabledState =
		(
			ddl_customDataSpeedMode.enabled = customDataMode == 4 or customDataMode == 5
		)
		
		on ddl_customDataMode selected itm do updateEnabledState()
		
		on pck_customDataNode picked obj do
		(
			if obj != undefined do customDataNode = obj
			pck_customDataNode.caption = obj.name
		)
		
		on btn_copyFont pressed do
		(
			if querybox ("This will assign font [" + textNode.baseobject.font + "]\nto all visible DIMnote Text Objects in the scene.\n\nAre you sure? ") title:"DIMnote Global Font"  then
				for o in objects where classof o == DIMnote and not o.isHiddenInVpt do
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
		
		on edt_customDataProperty entered txt do
		(
			dirtyFlag = true
			updateDimension()
		)
		
		on textrollout open do
		(
			if customDataNode != undefined do 
				pck_customDataNode.caption = customDataNode.name
			updateEnabledState()
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
	
	fn getCustomSpeed theValue=
	(
		case customDataSpeedMode of
		(
			default:() --per frame
			2: theValue*=FrameRate --per second
			3: theValue*=FrameRate*60 --per minute
			4: theValue*=FrameRate*3600 --per hour
			5: (
					theValue*=FrameRate*3600*units.SystemScale --MPH
					theValue/=case units.systemType of
					(
						#kilometers: 1.609
						#meters: 1609.344
						#centimeters: 160934.4
						#millimeters: 1609344.0
						#inches: 63360.0
						#feet: 5280.0
						#miles: 1.0
					)
				)
			6: (
					theValue*=FrameRate*3600*units.SystemScale --km/h
					theValue/=case units.systemType of
					(
						#kilometers: 1.0
						#meters: 0.001
						#centimeters: 1.0e-005
						#millimeters: 1.0e-006
						#inches: 3.93701e-006
						#feet: 4.7244e-005
						#miles: 0.621504
					)
				)				
		)	
		theValue
	)	
	
	fn getCustomSpeedSuffix =
	(
		case customDataSpeedMode of
		(
			default: "/frame " 
			2: "/sec "
			3: "/min "
			4: "/h "
			5: "MPH "
			6: "km/h"
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
			if (dirtyFlag == true or (isAnimatable AND lastAnimationFrame != currentTime) or node01.pos != oldPos01 or node02.pos != oldPos02 or node03.pos != oldPos03 or (node01.parent != undefined and node01.parent.pos != oldParentPos ) ) do
			(
				oldPos01	= node01.pos 
				oldPos02	= node02.pos 
				oldPos03 = node03.pos 
				
				with animate off
				(
					node01.size = pointHelperSize * 2
					node03.size = node02.size = pointHelperSize
				)	
				
				lastAnimationFrame = currentTime
				if node01.parent != undefined do oldParentPos = node01.parent.pos
				dirtyFlag = false
				
				theX = v1 = normalize (node03.pos - node02.pos)
				v2  = normalize (node02.pos - node01.pos)
				v3  = normalize (node01.pos - node03.pos)				
				
				if invertUpAxis then
					theZ = normalize (cross v2 v1)
				else
					theZ = normalize (cross v1 v2)
	
				local theDistance = distance node02 node03
				if invertUpAxis then
					theZ = normalize (cross v2 v1)
				else
					theZ = normalize (cross v1 v2)
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
					
	
				if textNode != undefined do
				(
					with animate off
					(
						local theValue 
						local theTotalPrefix = " Distance="
						case customDataMode of
						(
							1: (
								theValue = node01.pos
								theTotalPrefix = " Distance="
								)	
							2: (
								if node01.parent == undefined then theValue = node01.pos else in coordsys node01.parent theValue = node01.pos 
								theTotalPrefix = " Distance="
								)	
							3: (
								if node01.parent == undefined then theValue = [0,0,0] else theValue = node01.parent.pos 
								theTotalPrefix = " Distance="
								)	
							4: (
								theValue = (node01.pos - ((at time (currenttime-1) node01.pos)))
								theValue = getCustomSpeed theValue
								theTotalPrefix = " Speed="
								)
							5: (
								theTotalPrefix = " Speed="
								if customDataNode != undefined then
								(
									theValue = (customDataNode.pos - ((at time (currenttime-1) customDataNode.pos)))
									theValue = getCustomSpeed theValue
								)
								else theValue = [0.0,0.0,0.0]
								)								
						)--end case	
						
						local txt = ""
						if usePrefix do txt+= userPrefix +" "
						if useUserText then txt += userText else 
						(
							if customDataMode < 6 then
							(
								ValueX = theValue.x = (floor ((theValue.x * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
								ValueY = theValue.y = (floor ((theValue.y * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
								ValueZ = theValue.z = (floor ((theValue.z * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
								theTotalValue = (floor ((length theValue * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision 						
								TotalValue = theTotalValue
								if showX do 
								(
									txt += if showXYZLabel then "X=" else ""
									if customDataMode == 4 or  customDataMode == 5 then
									(
										if customDataSpeedMode >= 5 or textMode == 2 then
											txt += FillInTrailingZeros (theValue.x as string) 
										else
											txt += FillInTrailingZeros (units.formatValue theValue.x)
										txt += getCustomSpeedSuffix()
									)	
									else
										if textMode == 2 then
											txt += FillInTrailingZeros (theValue.x as string)
										else
											txt += FillInTrailingZeros (units.formatValue theValue.x)
								)	
								if showY do 
								(
									txt += if showXYZLabel then " Y=" else ""
									if customDataMode == 4 or  customDataMode == 5 then
									(
										if customDataSpeedMode >= 5 or textMode == 2 then
											txt += FillInTrailingZeros (theValue.y as string)
										else
											txt += FillInTrailingZeros (units.formatValue theValue.y)
										txt += getCustomSpeedSuffix()
									)	
									else
										if textMode == 2 then
											txt += FillInTrailingZeros (theValue.y as string)	
										else
											txt += FillInTrailingZeros (units.formatValue theValue.y)
								)	
								if showZ do 
								(
									txt += if showXYZLabel then " Z=" else ""
									if customDataMode == 4 or  customDataMode == 5 then
									(
										if customDataSpeedMode >= 5 or textMode == 2 then
											txt += FillInTrailingZeros (theValue.z as string) 
										else
											txt += FillInTrailingZeros (units.formatValue theValue.z)
										txt += getCustomSpeedSuffix()
									)	
									else
										if textMode == 2 then
											txt += FillInTrailingZeros (theValue.z as string)	
										else
											txt += FillInTrailingZeros (units.formatValue theValue.z)
								)	
								if showVectorLength do 
								(
									txt += if showXYZLabel then theTotalPrefix else ""
									if customDataMode == 4 or  customDataMode == 5 then
									(
										if customDataSpeedMode >= 5 or textMode == 2 then
											txt += FillInTrailingZeros (theTotalValue as string) 
										else
											txt += FillInTrailingZeros (units.formatValue theTotalValue)
										txt += getCustomSpeedSuffix()
									)	
									else
										if textMode == 2 then
											txt += FillInTrailingZeros (theTotalValue as string)	
										else
											txt += FillInTrailingZeros (units.formatValue theTotalValue)								
								)	
							)	
							else
							(
								if customDataNode != undefined  then
								(
									global DIMasterNote_customDataNode = customDataNode
									theDot = if matchPattern customDataProperty pattern:".*" then "" else "."
									try(theValue = execute ("DIMasterNote_customDataNode" + theDot + customDataProperty))catch(theValue = "")
									if superclassof theValue == Number then
									(
										theValue = (floor ((theValue * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
										if textMode == 1  then theValue = FillInTrailingZeros (units.formatValue theValue)
									)	
									else
									if classof theValue == Point3 then
									(
										ValueX = theValueX = (floor ((theValue.x * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
										ValueY = theValueY = (floor ((theValue.y * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
										ValueZ = theValueZ = (floor ((theValue.z * 10.0 ^ decimalPrecision) + 0.5))/ 10.0 ^ decimalPrecision
										txt2 = ""
										if textMode == 1  then 
										(
											if showX do txt2 += FillInTrailingZeros (units.formatValue theValueX) + " "
											if showY do txt2 += FillInTrailingZeros (units.formatValue theValueY) + " "
											if showZ do txt2 += FillInTrailingZeros (units.formatValue theValueZ)
											theValue = txt2
										)	
										else
										(
											if showX do txt2 += FillInTrailingZeros (theValueX as string) + " "
											if showY do txt2 += FillInTrailingZeros (theValueY as string) + " "
											if showZ do txt2 += FillInTrailingZeros (theValueZ as string)
											theValue = txt2
										)
									)	
									theValue = theValue as string
									
									if showXYZLabel then
										txt += customDataNode.name + "." + customDataProperty + "=" +  theValue 
									else	
										txt += theValue 
								)	
							)
						)	
						if useSuffix do txt+= " " +userSuffix 
						textNode.text = txt 
						textNode.size = textSize
						if alignTextToView then
						(
							local theViewTM = if viewport.getCamera() != undefined then 
								(viewport.getCamera()).transform
							else
								inverse (viewport.getTM())
							theViewTM.row4 = (oldPos02+ theZ*textOffsetZ + (theX * TextOffsetX)  + theY *(thickness+textOffsetY ))
							textNode.transform = theViewTM	
						)		
						else
						(
							theTMX = if flipHorizontal then -theX else theX
							theTMY = if flipVertical then -theY else theY
							textNode.transform = matrix3 theTMX theTMY theZ (oldPos02+ theZ*textOffsetZ + (theX * TextOffsetX)  + theY *(thickness+textOffsetY ))
						)	
					)	
				)	
				
				vertArray = #()
				faceArray = #()
				if drawLine then
				(
					append vertArray (oldPos01 + theY2 * thickness/2 * (1.0-taperValue/100.0) ) --1
					append vertArray (oldPos01 - theY2 * thickness/2 * (1.0-taperValue/100.0) )  --2
					append vertArray (oldPos02  + theY2 * thickness/2 )  --3
					append vertArray (oldPos02  - theY2 * thickness/2 ) --4
					
					append vertArray (oldPos02 + theY * (thickness/2))  --5
					append vertArray (oldPos02 + theY * (-thickness/2))  --6
					append vertArray (oldPos02 + theX * lineRight + theY * (thickness/2))  --7
					append vertArray (oldPos02 + theX * lineRight + theY * (-thickness/2)) --8
					append vertArray (oldPos02) --9
					append vertArray (oldPos02 + theY * (thickness/2)) --10
					append vertArray (oldPos02 + theY * (-thickness/2)) --11
					append vertArray (oldPos02 + theY * (thickness/2) - theX * lineLeft)   --12
					append vertArray (oldPos02 + theY * (-thickness/2) - theX * lineLeft)  --13			
					join faceArray  #([1,4,3], [1,2,4], [5,6,7], [6,8,7], [9, 5, 3], [10,11,12],[11,12,13] )	
				)
				cnt = vertArray.count
				if drawArrow then 
				(
					append vertArray (oldPos01)
					append vertArray (oldPos01 - theY2 * thickness * arrowWidth + v2 *  arrowHeight * thickness)
					append vertArray (oldPos01 + theY2 * thickness * arrowWidth + v2 * arrowHeight * thickness)
					join faceArray #([cnt+1,cnt+2,cnt+3])
				)
				
				cnt = vertArray.count
				if drawCross then
				(
					append vertArray (oldPos01 + theY * crossSize + theY*crossExtension2  + theX * (thickness/2))
					append vertArray (oldPos01 + theY * crossSize + theY*crossExtension2 - theX * (thickness/2))
					append vertArray (oldPos01 - theY * crossSize  - theY*crossExtension4 + theX * (thickness/2))
					append vertArray (oldPos01 - theY * crossSize  - theY*crossExtension4 - theX * (thickness/2))
					append vertArray (oldPos01 + theY * (thickness/2) + theX * crossSize + theX*crossExtension1)
					append vertArray (oldPos01 + theY * (thickness/2) - theX * crossSize - theX*crossExtension3)
					append vertArray (oldPos01 - theY * (thickness/2) + theX * crossSize + theX*crossExtension1)
					append vertArray (oldPos01 - theY * (thickness/2) - theX * crossSize - theX*crossExtension3)
					join faceArray #([cnt+1,cnt+2,cnt+3],[cnt+2,cnt+4,cnt+3],[cnt+5,cnt+6,cnt+7],[cnt+6,cnt+8,cnt+7])
				)
				cnt = vertArray.count
				if drawCircle and not drawShadedCircle then
				(
					for i = 0 to 360 by 10 do
					(
						theVector = ((rotateZMatrix i) * (matrix3 theX theY theZ [0,0,0] )).row1
						append vertArray (oldPos01 + theVector * circleRadius)
						append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness)
						append faceArray [cnt+1, cnt+2, cnt+4]
						append faceArray [cnt+1, cnt+4, cnt+3]
						cnt +=2
					)	
					theVector = ((rotateZMatrix 0) * (matrix3 theX theY theZ [0,0,0] )).row1				
					append vertArray (oldPos01 + theVector * circleRadius+ theY * thickness/2)
					append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness + theY * thickness/2)
				)	

				if drawShadedCircle then
				(
					append vertArray (oldPos01)
					cnt = centerVertex = vertArray.count
				
					for i = 0 to 90 by 10 do
					(
						theVector = ((rotateZMatrix i) * (matrix3 theX theY theZ [0,0,0] )).row1
						append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness)
						append faceArray [centerVertex , cnt+1, cnt+2]
						cnt +=1
					)
					theVector = ((rotateZMatrix 90 ) * (matrix3 theX theY theZ [0,0,0] )).row1	
					append vertArray (oldPos01 + theVector * circleRadius+ theY * thickness/2)
					cnt = vertArray.count
					for i = 90 to 180 by 10 do
					(
						theVector = ((rotateZMatrix i) * (matrix3 theX theY theZ [0,0,0] )).row1
						append vertArray (oldPos01 + theVector * circleRadius)
						append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness)
						append faceArray [cnt+1, cnt+2, cnt+4]
						append faceArray [cnt+1, cnt+4, cnt+3]
						cnt +=2
					)	
					theVector = ((rotateZMatrix 180) * (matrix3 theX theY theZ [0,0,0] )).row1				
					append vertArray (oldPos01 + theVector * circleRadius+ theY * thickness/2)
					append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness + theY * thickness/2)					
					
					cnt = vertArray.count
					for i = 180 to 270 by 10 do
					(
						theVector = ((rotateZMatrix i) * (matrix3 theX theY theZ [0,0,0] )).row1
						append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness)
						append faceArray [centerVertex , cnt+1, cnt+2]
						cnt +=1
					)
					theVector = ((rotateZMatrix 270 ) * (matrix3 theX theY theZ [0,0,0] )).row1	
					append vertArray (oldPos01 + theVector * circleRadius+ theY * thickness/2)					
					cnt = vertArray.count
					for i = 270 to 360 by 10 do
					(
						theVector = ((rotateZMatrix i) * (matrix3 theX theY theZ [0,0,0] )).row1
						append vertArray (oldPos01 + theVector * circleRadius)
						append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness)
						append faceArray [cnt+1, cnt+2, cnt+4]
						append faceArray [cnt+1, cnt+4, cnt+3]
						cnt +=2
					)	
					theVector = ((rotateZMatrix 360) * (matrix3 theX theY theZ [0,0,0] )).row1				
					append vertArray (oldPos01 + theVector * circleRadius+ theY * thickness/2)
					append vertArray (oldPos01 + theVector * circleRadius+ theVector * thickness + theY * thickness/2)						
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
				--format "% - %\n" f theDist 
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

tool createDimensionNote
(
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
				
				vOffset = 10
				hOffset1 = 0
				hOffset2 = 50
				
				offset01 = [0,vOffset ,0]
				offset02 = [hOffset2,vOffset ,0]
				flipTheAxis = false
				theTM  = (viewport.getTM()) as string
				case DIMaster_GetMostOrthogonalPlane() of
				(
					1: (
						offset01 = [hOffset1 ,-vOffset ,0]
						offset02 = [hOffset2,-vOffset ,0]	
						flipTheAxis = true			
					)
					2: (
						offset01 = [hOffset1 ,0,vOffset ]
						offset02 = [hOffset2,0,vOffset ]
						flipTheAxis = true	
					)
					3: (
						offset01 = [-hOffset1 ,0,vOffset]
						offset02 = [-hOffset2,0,vOffset ]				
					)
					4:(
						offset01 = [0,-hOffset1 ,vOffset ]
						offset02 = [0,-hOffset2,vOffset ]				
					)
					5: (
						offset01 = [0,hOffset1 ,vOffset ]
						offset02 = [0,hOffset2,vOffset ]				
					)
				)
				
				DIMaster_p1 = point pos:worldPoint size:4 wirecolor:red box:true cross:true centermarker:false
				DIMaster_p2 = point pos:(worldPoint + offset01 ) size:2 wirecolor:green box:false cross:true centermarker:false
				DIMaster_p3 = point pos:(worldPoint + offset02 ) size:2 wirecolor:blue box:false cross:true centermarker:false
				
				DIMaster_p3.parent = DIMaster_p2
				DIMaster_p2.parent = DIMaster_p1
				
				DIMaster_theDim = DIMnote wirecolor:black material:DimensionSystemMaterial name:(uniquename "DIM_Note_")
				DIMaster_theDim.dirtyFlag = true
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
				DIMaster_theDim.invertUpAxis = flipTheAxis
				DIMaster_theText.backfacecull = DIMaster_TheDim.backfacecull = false
				DIMaster_theText.steps =2
			
				addModifier DIMaster_theText (Mesh_Select())
				
				setUserProp DIMaster_theText "DIMaster" true
				setUserProp DIMaster_p1 "DIMaster" true
				setUserProp DIMaster_p2 "DIMaster" true
				setUserProp DIMaster_p3 "DIMaster" true	
				
				DIMaster_FirstHitData = DIMaster_getSnapPoint()
				if DIMaster_AttachToSnapped == true and DIMaster_FirstHitData.count > 0 then
				(
					DIMaster_theDim.isAnimatable = true
					DIMaster_AttachHelperTo DIMaster_p1 DIMaster_FirstHitData
				)
				
				DIMasterFunctions.loadSettingsFromPreferences DIMaster_theDim			
			)	
			2: ( select DIMaster_theDim; #stop)
		)	
	)	
	on mouseMove clickno do 
	(
		case clickno of
		(
			2: DIMaster_p1.pos = worldPoint
		)	
	)	
)--end tool




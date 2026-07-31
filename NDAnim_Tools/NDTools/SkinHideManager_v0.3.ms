-- 만든이 : 이상원
-- 사용 및 수정은 자유입니다. 하지만 재 배포는 금지합니다.

global SoxSkinHideManager		-- 롤아웃명을 글로벌 변수로 인식하기 위해 초기에 한 번 사용

try (destroydialog SoxSkinHideManager) catch()		-- 혹시 열려있는 창이 있으면 강제 종료

rollout SoxSkinHideManager "Sox SkinHideManager v0.30" width:180
(
	group "Hide Selected"
	(
		button uiBtnHideSelVerts "Vertex" align:#left across:3
		button uiBtnHideSelFace "Face" align:#center offset:[-3, 0]
		button uiBtnHideSelElem "Element" align:#right
	)
	
	button uiBtnUnhideAll "Unhide All"
	
	group "Option"
	(
		checkbox uiChkHideUnselected "Hide Unselected" across:2
		button uiBtnAbout "About" offset:[20, -4]
	)

	-- obj에 스킨 모디파이어가 적용되었는지 검사하여 해당 모디파이어 위치 id 번호를 리턴한다. 모디파이어가 없으면 0 리턴
	function CheckSkinModifier obj =
	(
		if ( obj.modifiers.count == 0 ) do return 0
		for o = 1 to obj.modifiers.count do
		(
			if ( (classof obj.modifiers[o])  == Skin ) do return o
		)
		return 0
	)
	
	-- Skin 모디파이어가 적용된 타입을 알아낸다. (현재는 폴리 타입만 지원)
	-- Teapot 오브제트를 예를 들면,
	-- 0. 예외 경우
	-- 1. Teapot > Skin
	-- 2. Teapot > ?? .... > Edit Poly > Skin  (Skin과 Edit Poly 사이에 다른 것이 끼어있을 수 있다)
	-- 3. Edittable Poly > Skin (Edit Poly 모디파이어가 존재하지 않음)
	-- 이 함수는 Skin이 적용되어있다는 전제 하에 작동
	local idEditPolyModifier
	local idSkinModifier
	function CheckType obj =
	(
		idSkinModifier = CheckSkinModifier obj
		if idSkinModifier == 0 do return 0
		
		-- 1번 혹은 3번 경우
		if ( obj.modifiers.count == 1 ) do (
			if ( (classof $.baseobject) == Editable_Poly ) then
			(
				return 3
			)
			else
			(
				return 1
			)
		)
		
		-- 이하 2번 혹은 3번
		-- 일단 Skin 모디파이어가 있는 위치를 찾는다.
		idSkin = CheckSkinModifier obj
		
		for o = idSkin to obj.modifiers.count do
		(
			if ( ( classof obj.modifiers[o] ) == Edit_Poly ) do
			(
				idEditPolyModifier = o		-- 발견된 Edit Poly 모디파이어 인덱스를 로컬 변수에 기억
				return 2
			)
		)
		
		if ( ( classof obj.baseobject ) == Editable_Poly ) do return 3
		
		-- 어떤 경우에도 해당되지 않으면 0 리턴
		return 0
	)
	
	-- 스킨 모디파이어로부터 현재 선택된 버택스 일련번호를 bitArray 로 리턴한다.
	function GetSkinVertSelection skinMod =
	(
		bitArr = #{}
		loopIndex = 1
		errFlag = false
		testValue = true
		while errFlag == false do
		(
			try
			(
				testValue = skinOps.IsVertexSelected skinMod loopIndex
			)
			catch
			(
				return bitArr
			)
			
			append bitArr loopIndex
			if testValue == 0 do
			(
				bitArr[loopIndex] = false
			)
			loopIndex += 1
		)
		return bitArr
	)
	
	on uiBtnHideSelVerts pressed do
	(
		if (selection.count != 1) do return()
			
		-- 여기서 idSkinModifier와 idEditPolyModifier 로컬 변수가 같이 세팅된다.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		disableSceneRedraw()
		undo on (
		case skinType of
		(
			2:
			(
				-- Edit Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				if (uiChkHideUnselected.state) do
				(
					selectedVerts = -selectedVerts
				)
				modPanel.setCurrentObject selection[1].modifiers[idEditPolyModifier]
				subobjectLevel = 1
				selection[1].modifiers[idEditPolyModifier].SetSelection #Vertex #{}
				selection[1].modifiers[idEditPolyModifier].Select #Vertex selectedVerts
				selection[1].modifiers[idEditPolyModifier].ButtonOp #HideVertex
				subobjectLevel = 0
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 2 end
			
			3:
			(
				-- Edittable Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				if (uiChkHideUnselected.state) do
				(
					selectedVerts = -selectedVerts
				)
				selection[1].EditablePoly.SetSelection #Vertex selectedVerts
				selection[1].EditablePoly.Hide #Vertex
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
		enableSceneRedraw()
	)
	
	on uiBtnHideSelFace pressed do
	(
		if (selection.count != 1) do return()
			
		-- 여기서 idSkinModifier와 idEditPolyModifier 로컬 변수가 같이 세팅된다.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		disableSceneRedraw()
		undo on (
		case skinType of
		(
			2:
			(
				-- Edit Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				modPanel.setCurrentObject selection[1].modifiers[idEditPolyModifier]
				subobjectLevel = 1
				selection[1].modifiers[idEditPolyModifier].SetSelection #Vertex #{}
				selection[1].modifiers[idEditPolyModifier].Select #Vertex selectedVerts
				selection[1].modifiers[idEditPolyModifier].ConvertSelection #Vertex #Face
				if (uiChkHideUnselected.state) do
				(
					subobjectLevel = 4
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
				)
				selection[1].modifiers[idEditPolyModifier].ButtonOp #HideFace
				subobjectLevel = 0
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 2 end
			
			3:
			(
				-- Edittable Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				selection[1].EditablePoly.SetSelection #Vertex selectedVerts
				selection[1].EditablePoly.ConvertSelection #Vertex #Face
				if (uiChkHideUnselected.state) do
				(
					modPanel.setCurrentObject selection[1].baseObject
					subobjectLevel = 4
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
					subobjectLevel = 0
				)
				selection[1].EditablePoly.Hide #Face
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
		enableSceneRedraw()
	)
	
	on uiBtnHideSelElem pressed do
	(
		if (selection.count != 1) do return()
			
		-- 여기서 idSkinModifier와 idEditPolyModifier 로컬 변수가 같이 세팅된다.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		disableSceneRedraw()
		undo on (
		case skinType of
		(
			2:
			(
				-- Edit Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				modPanel.setCurrentObject selection[1].modifiers[idEditPolyModifier]
				subobjectLevel = 1
				selection[1].modifiers[idEditPolyModifier].SetSelection #Vertex #{}
				selection[1].modifiers[idEditPolyModifier].Select #Vertex selectedVerts
				selection[1].modifiers[idEditPolyModifier].ConvertSelection #Vertex #Element
				if (uiChkHideUnselected.state) do
				(
					subobjectLevel = 5
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
				)
				selection[1].modifiers[idEditPolyModifier].ButtonOp #HideFace
				subobjectLevel = 0
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 2 end
			
			3:
			(
				-- Edittable Poly > Skin
				selectedVerts = GetSkinVertSelection selection[1].modifiers[idSkinModifier]
				selection[1].EditablePoly.SetSelection #Vertex selectedVerts
				selection[1].EditablePoly.ConvertSelection #Vertex #Element
				if (uiChkHideUnselected.state) do
				(
					modPanel.setCurrentObject selection[1].baseObject
					subobjectLevel = 5
					actionMan.executeAction 0 "40044"  -- Selection: Select Invert
					subobjectLevel = 0
				)
				selection[1].EditablePoly.Hide #Face
				modPanel.setCurrentObject selection[1].modifiers[idSkinModifier]
				subobjectLevel = 1
				skinOps.SelectVertices selection[1].modifiers[idSkinModifier] #{}
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
		enableSceneRedraw()
	)
	
	on uiBtnUnhideAll pressed do
	(
		if (selection.count != 1) do return()
			
		-- 여기서 idSkinModifier와 idEditPolyModifier 로컬 변수가 같이 세팅된다.	
		skinType = CheckType selection[1]
						
		if ( skinType == 0 ) do return()
		
		undo on (
		case skinType of
		(
			2:
			(
				selection[1].modifiers[idEditPolyModifier].ButtonOp #UnhideAllFace
				selection[1].modifiers[idEditPolyModifier].ButtonOp #UnhideAllVertex
			)-- 2 end
			
			3:
			(
				selection[1].EditablePoly.unhideAll #Face
				selection[1].EditablePoly.unhideAll #Vertex
			)-- 3 end
			
			default: return ()
		)
		)-- undo end
	)
	
	on uiBtnAbout pressed do
	(
		shellLaunch "http://cafe.naver.com/pinksox/6126" ""
	)
	
	on SoxSkinHideManager open do
	(

	)
	
	on SoxSkinHideManager close do
	(

	)
)

createDialog SoxSkinHideManager style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) lockWidth:true
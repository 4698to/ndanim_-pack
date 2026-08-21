
--macroScript EpicTools_TexMorpher category:"Epic Tools" buttontext:"Vertex Animation Tools" tooltip:"Vertex Animation Tools"
(
	ResumeEditing()
	escapeEnable = true
	/*********************************************************************************************************
	
	Vertex Animation Tools
	Written by Jonathan Lindquist at Epic Games
	
	*********************************************************************************************************/
	
	global default_Morph_FloaterOpen=True
	global default_SelectionSequenceRolloutOpen=False
	global Morph_Floater
	fn reinitRolloutSize = (
		mR=if default_Morph_FloaterOpen == true then 280 else 25
		kR=if default_SelectionSequenceRolloutOpen == true then 85 else 25
		Morph_Floater.Size=[175,(mR+kR)]

	)
	fn selectionModelCheck myModel = (
			isvalidnode myModel and superclassof myModel == GeometryClass 
	)
				
	rollout TexMorphRollout "Vertex Animation Tools" (

		on TexMorphRollout rolledUp state do (
			default_Morph_FloaterOpen=state 
			reinitRolloutSize()
			
		)
		
		/*************************************************************************************************************************************************
		base function library
		***************************************************************************************************************************************************/
		
			
			function round num = (
				remainder = num- (floor num)
				if (remainder >= .5) then (fnum= ceil num) else (fnum = floor num) 
				fnum
			)
			fn clamp num cMin cMax = (
				/*Chris Wood*/
				result = num
				if result < cMin
				then result = cMin
				else (
					if result > cMax
					then result = cMax
				)
				return result
			)
			fn clampVector V vMin vMax =(
				tempvector=[0.0,0.0,0.0] 
				for a=1 to 3 do (
					tempvector[a]=clamp V[a] vMin vMax
				)
				tempvector
			)
				
			fn absoluteValVector V= (
				tempvector=[0.0,0.0,0.0] 
				for a=1 to 3 do (
					tempvector[a]=abs V[a] 
				)
				tempvector
			)

			fn spreadOutSelection = if selection.count>0 do (for i=1 to selection.count do selection[i].position= [80*i,0,0])
			
		/*************************************************************************************************************************************************
		End base function library
		***************************************************************************************************************************************************/
			global originalMesh -- =$husky_arms001
			global copyBaseMesh 
			global numberofVerts 
			global originalMeshVertPositions = #()
			global MorphTargetArray
			global Morph_Floater
			global internalArrayOfStaticBaseMeshes=#()
			global vertexUVPosition=#()
			global MorphNormalArray=#()
			global MorphVertOffsetArray=#()
			global MorphTargetProgressPercentage = 0.0
			global masterMorphArray=#()
			global noMeshesArray=#(" No meshes processed" as string)
			radioButtons selectionOptions "Animation Options" labels:#("Animated Meshes", "Key Frame Meshes") default:1 
			group "Animated Meshes" (
				button processSelfAnimatedMeshes "Process Animated Meshes"
				spinner spinnerAnimationRangeStart "Anim Start" type:#integer range:[0,1000000,animationRange.start] 
				spinner spinnerAnimationRangeEnd "Anim End" type:#integer range:[0,1000000,animationRange.end] 
				spinner spinnerAnimationRate "Frame Skip" type:#integer range:[0,1000000,0] 
			)
			group "Key Frame Meshes" (
				button selectCurrentSelectedMeshes "Process Selected Meshes" enabled:false
			)
			button help "help"
			
			
			fn msgBreak = (
					format "*** % ***\n" (getCurrentException())
					messagebox ("An error has occured. Please send the this text to Jonathan.lindquist@epicgames.com \r\r''" + getCurrentException() + "''")
			)
			
			fn getvertCount originalMesh = (numberofVerts = getNumVerts originalMesh)
			
			fn checkmodel model =( isvalidnode model and superclassof model == GeometryClass ) --and (getvertCount model>0)
			
			
			fn updateProgAmount i myArrayCount = (
				MorphTargetProgressPercentage=((i as float/myArrayCount as float)*100.0)
				progressUpdate MorphTargetProgressPercentage   
				if MorphTargetProgressPercentage == 100.0 do progressEnd()
				if getProgressCancel() == true do (
					progressEnd()
				) -- returns true if cancelled
			)
			
			
			fn getTheVertexNormal processObject vertexIndex = ( 
				normal = [0.0,0.0,0.0] 
				if classof processObject.baseobject == Editable_Poly then (
					vertexPolygons = polyOp.getFacesUsingVert processObject vertexIndex
					for i in vertexPolygons do (
						normal+=in coordsys world polyOp.getFaceNormal processObject i
					)
				) else (
					normal= getNormal processObject vertexIndex
				)
				normal=normalize normal 
				normal 
			)
			
			
			-- store an array to querry instead of the object
			fn storeOriginalMeshVertPositions = 
			(
				originalMeshVertPositions= #()
				if classof originalMesh.baseobject == Editable_Poly then ( 
					for i=1 to numberofVerts do (append originalMeshVertPositions (in coordsys world polyop.getVert originalMesh i))
				) else (
						for i=1 to numberofVerts do (append originalMeshVertPositions (in coordsys world getVert originalMesh i))
				)
				originalMeshVertPositions
			)
			

	
			-- arrange the uvs
			function packVertUVs myMesh =
			(
				progressStart "Packing the game meshes UVs" 
				convertTo myMesh Editable_Poly
				for i=1 to (numberofVerts) do (
					offset=1.0/(numberofVerts*2) -- find have a sample ratio
					currentPosition=(((i as float)-.5)/numberofVerts)
					polyop.setVertColor myMesh 2 i [currentPosition*255.0,128.0,0] ----*255.0
					append vertexUVPosition CurrentPosition
					--Progress Bar--
					updateProgAmount i numberofVerts
				)
				progressEnd()
			)
		fn normalToScalar Normal b3DigitsPrecision:false = 
		(
				normal=normalize normal 
				if b3DigitsPrecision == true then 
				(
					zSign=if Normal[3] > 0.0 then 1.0 else -1.0 
					Normal=clampVector Normal -.999 .999
					
					Normal=(Normal+1.0)*0.5	
					Normal=[ceil (Normal[1]*1000.0),ceil (Normal[2]*1000.0),0]
					normalScalar=zSign*((Normal[1])+(Normal[2]*.001)) as float
				) 
				else(
					Normal=(Normal+1.0)*0.5	
					Normal=[ceil (Normal[1]*100.0),ceil (Normal[2]*100.0),ceil (Normal[3]*100.0) ]
					normal=clampVector normal 0 99
					normalScalar=((Normal[1]*10.0)+(Normal[2]*.1)+(Normal[3]*.001)) as float
				)
				normalScalar as float
		)
				
			fn getVertPos model index= 
			(
				pos=[0,0,0]
				if classof model.baseobject == editable_poly then (
					pos=in coordsys world polyop.getVert model index
				) else (
					pos=in coordsys world getVert model index
				)
				pos
			)
				
			fn populateMorphTargetArrays =
			(
				progressStart "Creating the Morph Targets" 
				masterCount=masterMorphArray.count
				for i=1 to masterCount do 
				(
					CurrentMorphTargetNormalArray=#()
					currentMorphTarget=masterMorphArray[i]
					global currentMorphVertexOffsetArray=#()
					MorphTargetProgressPercentage=updateProgAmount i masterCount
					for j=1 to numberofVerts do (
						oldnormal=((((normalize (getTheVertexNormal currentMorphTarget j))*[1.0,-1.0,1.0])+1.0)*0.5)*255.0
						append CurrentMorphTargetNormalArray oldnormal
						originalVertPos=originalMeshVertPositions[j]
						currentModelVertPos=getVertPos currentMorphTarget j
						currentOffset=(currentModelVertPos-originalVertPos)
						currentOffset=[currentOffset[1],-1.0*currentOffset[2],currentOffset[3]]
						currentOffset*=255.0
						append currentMorphVertexOffsetArray currentOffset
					)
					append MorphVertOffsetArray currentMorphVertexOffsetArray
					append MorphNormalArray CurrentMorphTargetNormalArray
				)
			)
				
			fn updateAndClampSpinners = 
			(
				spinnerAnimationRangeStart.value=clamp spinnerAnimationRangeStart.value -1000000000 spinnerAnimationRangeEnd.value
				spinnerAnimationRangeEnd.value=clamp spinnerAnimationRangeEnd.value spinnerAnimationRangeStart.value 1000000000
			)
			on 	spinnerAnimationRangeStart changed val do 
			(		
				updateAndClampSpinners ()
			)
			on 	spinnerAnimationRangeEnd changed val do 
			(
				updateAndClampSpinners ()
			)				
 
			
			fn makeSnapshotsReturnArray modelToSnap= 
			(
					progressStart "Creating Morph Targets" 
					FrameArray=#()
					NumberOfFrames = floor (spinnerAnimationRangeEnd.value-spinnerAnimationRangeStart.value) --/(spinnerAnimationRate.value+1)
					for i=0 to NumberOfFrames by (spinnerAnimationRate.value+1) do 
					(
						newtime = spinnerAnimationRangeStart.value+i 
						newCopy=at time newtime snapshot modelToSnap
						meshop.unifyNormals newCopy #{1..newCopy.numfaces}
						--!convertto newCopy editable_poly
						append FrameArray newCopy
						updateProgAmount i NumberOfFrames
					)
					progressEnd()
				FrameArray
			)		
		
			fn attachMeshes mesh1 mesh2= 
			(
				if classof mesh1 == editable_poly then mesh1.attach mesh2 mesh1
					else attach mesh1 mesh2 
			)
				
			fn makeAndMergeSnapShots arrayOfModels = (
				if arrayOfModels.count > 0 do (
					for i in arrayOfModels do (
						if checkmodel i do append masterMorphArray (makeSnapshotsReturnArray i) -- produces side by side arrays of models with the same frame count
					)
					-- consolidate multiple objects into one object so that the morph texture can be shared
					masterMorphArray1Count=masterMorphArray[1].count
					If masterMorphArray.count > 1 do (
						for i=2 to masterMorphArray.count do (
							--master arrays each item is a group
							for framecount=1 to masterMorphArray1Count do ( 
								-- Loop through each of the objects stored from each frame... then combine them with their associated paired meshes. the first mesh being the father of the others
								currentMasterObject=masterMorphArray[1][framecount]
								attachMeshes currentMasterObject masterMorphArray[i][framecount]
							)
						)
					)
					masterMorphArray = masterMorphArray[1] -- make master morph array a single dimensional array with the combined meshes
				)
			)
			
			
			fn renderOutTheTextures = 
			(	
				fopenexr.SetCompression 0
				fopenexr.setLayerOutputType 0 1 -- set layer 0  main layer to RGBA, RGB = 1
				fopenexr.setLayerOutputFormat 0 1 --0 32 sets main layer to float 16 via 1. other options are 0 float 32, 2 int 32 
				global TextureName = getSaveFileName types:"EXR (*.EXR)|*.EXR"
				if TextureName == undefined then (
					messagebox "please select a file location"
				)
				else(
					TextureNameNormal= replace TextureName (findString TextureName ".EXR") 4 "_Normals.BMP"
					global FinalTexture = bitmap numberofVerts (MorphVertOffsetArray.count) filename:TextureName hdr:true;--TextureName ;
					global FinalMorphTexture = bitmap numberofVerts (MorphVertOffsetArray.count) filename:TextureNameNormal hdr:false;--TextureName ;
					for i=0 to (MorphVertOffsetArray.count-1) do (
						setPixels FinalTexture [0, i] MorphVertOffsetArray[(i+1)]
						setPixels FinalMorphTexture [0, i] MorphNormalArray[(i+1)]
					)
					save FinalTexture
					close FinalTexture
					
					save FinalMorphTexture
					close FinalMorphTexture
				)
			)
		
			fn removeMeshes = 
			(
				if isvalidnode masterMorphArray[1] and masterMorphArray.count >0 do (
					delete masterMorphArray
					masterMorphArray=#()
				)
			)
			
			
			
		/*********************************************************************
		UI functions
		*********************************************************************/

			fn reinitVars = (
				masterMorphArray=#()
				MorphVertOffsetArray=#()
				originalMesh=undefined
				numberofVerts=0
				internalArrayOfStaticBaseMeshes=#()
				MorphTargetProgressPercentage=0.0
				originalMeshVertPositions=#()
				MorphNormalArray=#()
				tempMorphArray=#()
			)
			
			fn enableAnimatedControls enabled= (
				processSelfAnimatedMeshes.enabled=enabled	
				spinnerAnimationRangeStart.enabled=enabled	
				spinnerAnimationRangeEnd.enabled=enabled	
				spinnerAnimationRate.enabled=enabled	
				processSelfAnimatedMeshes.enabled=enabled
				selectCurrentSelectedMeshes.enabled=not enabled
				reinitVars()
			)
			
			fn smoothcopy myMesh = (
				/********** Duplicate the Mesh **********/
				originalName=myMesh.name
				originalMesh=at time 0 snapshot myMesh
				originalMesh.name=originalName+"_MorphExport"
				s=smooth()
				s.smoothingBits = 1
				addmodifier originalMesh s
				/********** Duplicate the Mesh **********/
				getvertCount originalMesh
				storeOriginalMeshVertPositions () 
			)
			fn updateSelectionButtons state = (
				if state==1 then (
					enableAnimatedControls true	
				)
				else (
					enableAnimatedControls false
				)
			)
			on selectionOptions changed state do updateSelectionButtons state

			on help pressed do (
				p=#()
				instructionString=""
				append p "The tools in this section will create an flipbook texture which can be used within UE4 to animate a static mesh through a series of static mesh morph targets."
				append p "To use the tools, you can either select individual animated meshes, for the animated meshes section,  or a series of non animated static meshes in order to be used with the key frame meshes section."
				append p "Additional info:"
				append p "---------Animated Meshes-------------"
				append p "Select an animated mesh or several meshes. The script will create snapshots of the meshes for the time specified in the animated meshes anim start and end details area."
				append p "The script then combines those snapshot meshes into a single series of meshes. The uvs on the first morph target are layed out in a line across the U axis."
				append p "The difference in location is then stored out to an .EXR file for import into the editor. A second normal map texture is exported as well. When importing the normal map texture do not change the compression type to Normal. It should be Vector displacement instead and sRGB should be turned off."
				append p "After that process is complete one must export the static mesh called *Mesh Name* ''_MorphExport''. This should be used as the in game asset. Do not export the mesh with modifiers on the stack. The model will import incorrectly."
				append p "Import the textures into unreal. The _Normal texture should use vector displacement texture compression setting and sRGB should be off. The .EXR texture should already be imported with the hdr setting."
				append p "The textures resolutions will most likely be a non-power of 2 value. This works on all devices but mobile. The final texture resolution comes from this formula: X= number of vertices in the final combined model, Y= the number of frames."
				append p "Once imported, both textures should be part of the UI mip gen settings group. This will prevent them from generating mip maps."
				append p "After importing the static mesh, disable ''enable collision'', ''remove degenerates'', enable ''use full precision uvs'', set ''Distance Field Resolution Scale'' to 0 and hit apply. This will alleviate any problems that may occur from the character model. I would also recommend increasing the models bound scale when placed in a level or when spawned from a blueprint. This will ensure that the model doesn't disappear when viewed from certain angles."
				append p "Once your assets are imported you can look at the engine/material_functions_02/contentexamples directory for material examples."
				append p "---------Key Framed Meshes-------------"
				append p "Everything that was said for the ''Animated Meshes'' section above holds true for the Key Framed Meshes toolset. The only difference is the workflow."
				append p "Create a mesh, animate it however you would like then snapshot key frames that you would like to have access to in Unreal."
				append p "Then select those meshes in order (This can be done by pressing the H key to bring up the list view of the scene or you can manually select them). You can either save that selection by creating a selection set from your current selection or just press the process selected meshes button. This will pack the uvs of the first model that you selected and save out the morph textures."
				for i in p do instructionString += i + "\r\r"
				messagebox instructionString 
			)
			
			
			on processSelfAnimatedMeshes pressed do (
				SuspendEditing()
				try
				with redraw off (
					reinitVars()
					for i in selection do if checkmodel i do append internalArrayOfStaticBaseMeshes i
					if internalArrayOfStaticBaseMeshes.count > 0 then (
						makeAndMergeSnapShots internalArrayOfStaticBaseMeshes -- populates masterMorphArray
						smoothcopy masterMorphArray[1] -- smooth mesh becomes  originalMesh storeOriginalMeshVertPositions -- Also sets vert count
						packVertUVs originalMesh 
						populateMorphTargetArrays () --		MorphVertOffsetArray MorphNormalArray
						removeMeshes()
						renderOutTheTextures ()  -- requires MorphVertOffsetArray.count to be correct
						convertto originalMesh editable_mesh
						select originalMesh
						--addmodifier originalMesh (Materialmodifier ()) --ui:on
					)	else (
						messagebox "No applicable meshes were selected."
					)
					ResumeEditing()
				)
				catch (
					msgBreak ()
					ResumeEditing()
				)
			)
			
			on selectCurrentSelectedMeshes pressed do (
				
				tempMorphArray=#()
				tempMeshMorphArray=#()
				reinitVars()
				SuspendEditing()
				try
				with redraw off (
					if selection.count > 1 and selectionModelCheck selection[1]==true do (
						
						global warningNameArray=#()
						finalWarningString=""
						
						smoothcopy selection[1]-- sets originalMesh
						getvertCount originalMesh --[sets numberofVerts]
						
						tempMorphArray=(for i in selection where (selectionModelCheck i) collect i)
						thecount = tempMorphArray.count
						if thecount > 1 do 
							(
								
								progressStart "Creating Morph Targets" 
								for i=1 to tempMorphArray.count do 
									(
										updateProgAmount i thecount
										j=snapshot tempMorphArray[i]
										
										if getNumVerts j == numberofVerts then 
											(
												append masterMorphArray j
											) 
												else 
											(
												append warningNameArray tempMorphArray[i].name
												delete j
											)
									)
							
								progressEnd()
							
								packVertUVs originalMesh 
								populateMorphTargetArrays() --		MorphVertOffsetArray MorphNormalArray
								removeMeshes()
								renderOutTheTextures ()
								convertto originalMesh editable_mesh 
								select originalMesh
								if warningNameArray.count > 0 do 
									(
										finalWarningString="The following meshes were not baked into the animation texture because their vertex count differs from the original mesh. \r\r "
										
										for i in warningNameArray do append finalWarningString  (" - "+i+"\r\r")
										
										messagebox finalWarningString
									)
							) 
						
					)
				)
				catch (
						msgBreak ()
				)
				ResumeEditing()

			)
			

			/*********************************************************************************************************************************************************************************************************************
			Function definitions
			
			getvertCount originalMesh [sets numberofVerts]
			checkmodel model [t or f]

			getTheVertexNormal processObject vertexIndex [returns normal]
			packVertUVs originalMesh [converts to ep - prog start end] 
			makeAndMergeSnapShots arrayOfModels [checks to see the models exist, copies them, fills masterMorphArray and merges them together]
					makeSnapshotsReturnArray modelToSnap [makes copies and returns a FrameArray - this gets called iteratively from makeAndMergeSnapShots ]
			smoothcopy myMesh [makes a smoothed version sets originalMesh to copy then calls storeOriginalMeshVertPositions]
				storeOriginalMeshVertPositions [originalMeshVertPositions - returns an array of vertex positions for the original mesh called by smoothcopy]
			populateMorphTargetArrays  [populates MorphNormalArray MorphVertOffsetArray ]
		
			UI Functions
			updateDropdowns [checks morphtargetarray and populates based on it]
			reinitVars [zeroes out MorphTargetArray, other arrays and updates dropdowns]
			enableAnimatedControls [enable disable stuff - also reinitsVars]
			
			*********************************************************************************************************************************************************************************************************************/
	)-- end rollout
	rollout SelectionSequenceRollout "Sequence Painter" rolledUp:true (
		on SelectionSequenceRollout rolledUp state do (
			default_SelectionSequenceRolloutOpen=state 
			reinitRolloutSize()
		)
		button storeSequence "Paint Selection Sequence" tooltip:"Pressing this button will assign ascending values to each model in the models uv channel 3's U component. In Unreal, this translates to uv 2. \r\rEach selected items value will be .5 + their position in the selection array.\r\rI.e. .5, 1.5, 2.5, 3.5... This can then be used as an animation value in Unreal."
		button helpSequence "Help"
	
		on storeSequence pressed do (
			nonPolyObjects=#()
			cleanSelectionArray=#()
			DirtyStringArray=#()
			SuspendEditing()
			try
			with redraw off (
			
			--- need to do a vertex count and make duplicate models also check for 
				cleanSelectionArray=#()
				for i in selection do 
					( 
						if selectionModelCheck i and classof i == editable_poly then 
						(
							append cleanSelectionArray i 
						) 
						else 
						(
							append DirtyStringArray i.name 
						)
					)
				if cleanSelectionArray.count > 0 do 
					(
						cleanCount=cleanSelectionArray.count
						for i=1 to cleanCount do polyop.setVertColor cleanSelectionArray[i] 3 #all [(i*255.0)-127.0,127.0,0] 
					)
				if DirtyStringArray.count > 0 do 
					(
						incorrectModelText="These model[s] were not processed because they \rwere not collapsed editable poly meshes:\r"
						for i in DirtyStringArray do 
							(
								incorrectModelText+="\r"+ i
							)
							messagebox incorrectModelText
					) 
				
			) catch (
					msgBreak ()
			)
			resumeediting ()
		)
		
		
		
		
		on helpSequence pressed do (
			messagebox "Directions:\r\rCreate a series of editable poly meshes and select them in order. Then press ''Paint Selection Sequence''. \r\rThe script will make collapse them to editable polygon objects and then store their selection sequence in the meshes uvs. \r\rUse the ''TexMorph_SelectionSequence'' material function, in UE4, to retrieve the values."
		)
		
	)
	
	if Morph_Floater != undefined then CloseRolloutFloater Morph_Floater
	global Morph_Floater = newRolloutFloater "" 175 420 
	addRollout TexMorphRollout Morph_Floater
	addRollout SelectionSequenceRollout Morph_Floater
	reinitRolloutSize()

) -- end macro 
	--macros.run "Epic Tools" "EpicTools_TexMorpher" 

	/* 
	Potential Failure points 
	
	wrong texture settings
		srgb off
		vector displacement map 
		ui group
			

	Mesh settings
		distance fields turned off
		recomputes off 
		remove degenerates off 
		full precision on
		bounds scale to avoid mesh clipping

	Material
		Not plugging in custom uv 2 or 3


	Max
		modifiers on the mesh after the procesing has been done
		hard edges not accepted
		
		 color as well? 
		Bake diffuse into vertex colors
		
	*/
/*

Author：ZhangHan  （Rewrite and modified based on PEN_batchItMax.ms by Paul Neale and autoSaveLoadAni.ms by Zheng bingbing. ）
99U:593027 
QQ :270528858
Usage: Just drag and drop
version: 1.2
Date:2016/10/25
update：2017/04/06


*/

fn CreateUser32ForDummies =
(
	source  = "using System;\n"
	source += "using System.Runtime.InteropServices;\n"
	source += "class User32\n"
	source += "{\n"
	source += "	[DllImport(\"user32.dll\")] [return: MarshalAs(UnmanagedType.Bool)]\n"
	source += "	public static extern bool EnableWindow(Int32 hWnd, bool bEnable);\n"
	source += "}\n"

	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	compilerResults.CompiledAssembly.CreateInstance "User32"
)
_user32 = CreateUser32ForDummies()

struct Bip_batchTool
(
	batchUtil=undefined,
	
	fn closeUI=
	(
		if batchUtil!=undefined then
		(
			destroyDialog batchUtil
			batchUtil=undefined
		)
	),
	fn run=
	(
		--Interface
		rollout batchUtil_R "Bip批量导入导出工具" width:1000
		(
			local btW = 80
		
			button browseProcess_bt "打开" width:btW across:2  pos:[16,50]
			editText processDir_et "源Max文件路径:" fieldWidth:780	 pos:[106,54]
			
			button browseBipSaveFolder_bt "打开" width:btW  across:2	 pos:[16,90]
			editText saveBipFolder_et "Bip文件路径:      " fieldWidth:780  pos:[106,94]
			
			button browseStandard_bt "打开" width:btW  across:2   pos:[16,130]
			editText browseStandard_et "新标准MAX档： " fieldWidth:780 fieldWidth:780  pos:[106,134]
			
			radiobuttons saveLoadStyle_rdo "" pos:[16,160] width:500	height:32 labels:#("导出", "导入")
			
			checkbox tcbEuler_chk "修改bone的旋转模式" checked:false across:2	 pos:[300,178]			
			radiobuttons tcbEulerStyle_rdo ""	default:1  pos:[500,178] width:500	height:32 labels:#("TCB", "Euler")
			
			checkbox bone_chk	"bone" checked:true across:2	 pos:[190,178]
			checkBox bip_chk  "bip" checked:true	 pos:[110,178]
--			checkBox vObj_chk "v_*虚拟体" enabled:false checked:true	 pos:[280,178]

			

			--checkbox xafPos_chk "位移" pos:[450,178] width:48 height:15 enabled:false checked:true
			--checkbox xafRot_chk "旋转" pos:[500,178] width:48 height:15 enabled:false checked:true
			--checkbox xafScale_chk "缩放" pos:[550,178] width:48 height:15 enabled:false checked:false
	

		

			multiListBox maxFiles_mlb "选择要处理的文件:" width:880 height:30  pos:[106,220]
			
			label prog0_lb "0%" across:3 align:#left
			label prog50_lb "50%"
			label prog1000_lb "100%" align:#right
			progressBar progBar_pb


			
			
			button getFiles_bt "读取文件"  width:btW align:#left pos:[14,300]
			checkBox recurse_cb "包含子目录" checked:true align:#left
			button selAll_bt "全选文件" width:btW align:#left 
			button deSelAll_bt "取消选择" width:btW align:#left
			button process_bt "开始导出/入" width:btW align:#left offset:[0,20]
			
			button close_bt "Close" width:btW align:#left offset:[0,230]



			
			--Sets the ini file for the interface	
			Fn setBatchIni_fn sectionStr keyStr valueStr =
			(
				logPath = (getDir #plugCfg) + "\\" + "BatchIni.ini"
				setIniSetting logPath sectionStr keyStr valueStr
			)
			
			--Gets the ini settings for the interface.
			Fn getBatchIni_fn sectionStr keyStr =
			(
				logPath = (getDir #plugCfg) + "\\" + "BatchIni.ini"
				outStr = (getIniSetting logPath sectionStr keyStr)
				return outStr
			)
			
			--Collects the scripts in the designated folder.
		/*
		Fn getScipts_fn dir =
			(
				local files = #()
				if dir != "" then 
				(
					allFiles = (getFiles (dir + "\\" + "*.ms"))
					for x in allFiles do (append files (fileNameFromPath x))
				)
				return files
			)
*/
			
			--Collects the Max files in the designated folders with the option of recursive or not.
			Fn getMaxFiles_fn dir =
			(
				if recurse_cb.checked then
				(
					local dir1 = getDirectories (dir + "*")
					for d in dir1 do
					(
						join dir1 (getDirectories (d + "*"))
					)
					
					local files = #()
					for f in dir1 do
					(
						join files (getFiles (f + "/*.max"))
					)
					return files
				)else
				(
					files = (getFiles (dir + "\*.max"))
					return files
				)
			)
			
			
			
			

			Fn getBipFiles_fn dir =
			(

					files = (getFiles (dir + "\*.bip"))
					return files

			)
			
			Fn getXafFiles_fn dir =
			(

					files = (getFiles (dir + "\*.Xaf"))
					return files

			)
			
			

			
			
	
			
			-- Search max files for string
			Fn searchMaxFiles_fn str =
			(
				selArray = #()
				numFiles = maxFiles_mlb.items.count
				for x = 1 to numFiles do
				(
					fileName = fileNameFromPath maxFiles_mlb.items[x]
					fileFound = findstring fileName str
					if fileFound != undefined then (append selArray x)
				)
				return selArray
			)
			

			
			--Create and write Log file.
			--FileIn is the file path being processed
			--ScriptIn is an array of the batch scripts being run on each max file
			Fn logFile_fn fileIn scriptIn =
			(

					iniEx = if (getFiles ((getDir #plugCfg) + "\\" + "BatchIni.ini")).count > 0 then (true) else (false)
					openedFile = if iniEx then (openFile (getBatchIni_fn "batchUtil" "LogPath") mode:"a+")else(undefined)
					if openedFile != undefined then
					(
						format "File: %\n" fileIn to:openedFile
						format "\tDate:\t\t%\n" localTime to:openedFile
						format "\tUser:\t\t%\n" sysInfo.userName to:openedFile
						format "\tComputer:\t%\n" sysInfo.computerName to:openedFile
						for x in scriptIn do
						(
							format "\tScript:\t\t%\n" (fileNameFromPath x) to:openedFile
						)
						format "\n" to:openedFile
						close openedFile

				)
				fileProperties.addProperty #custom "Batch Processed" ""
				fileProperties.addProperty #custom "Date:" localTime #Date
				fileProperties.addProperty #custom "User:" sysInfo.userName
				fileProperties.addProperty #custom "Computer:" sysInfo.computerName
				fileproperties.addproperty #summary "author" sysInfo.userName
		
				for x in scriptIn do
				(
					fileProperties.addProperty #custom "Script:" (fileNameFromPath x)
					curComment=try(fileProperties.getPropertyValue #summary 2)catch("")
					fileproperties.addproperty #summary "comments" (curComment+"\n"+("Batched with:\n"+(fileNameFromPath x)))
				)
				
			)
			
			--Run on opening the interface. Gets and sets the interface settings and positions the 
			--dialog to the last used position.
			on batchUtil_R open do
			(
				iniEx = if (getFiles ((getDir #plugCfg) + "\\" + "BatchIni.ini")).count > 0 then (true) else (false)
		
			
				processDir_et.text = if iniEx then (getBatchIni_fn "batchUtil" "processDir") else (getDir #scene)
				saveBipFolder_et.text = if iniEx then (getBatchIni_fn "batchUtil" "saveFolder") else (getDir #scene)

				

				recurse_cb.checked = if iniEx then (execute (getBatchIni_fn "batchUtil" "recurse")) else (true)
				
				--Update the scripts list on open
			--	batchList_mlb.items = (getScipts_fn batchDir_et.text)
				
				--Get the position of the Dialog
				setDialogPos batchUtil_R (if iniEx then (execute (getBatchIni_fn "batchUtil" "Position")) else ([10,100]))
		

					browseBipSaveFolder_bt.enabled = true
					saveBipFolder_et.enabled = true

		
			)
			--Run on closing the dialog. Saves the last used settings for the interface and dialog position.
			on batchUtil_R close do
			(

				setBatchIni_fn "batchUtil" "processDir" processDir_et.text
				setBatchIni_fn "batchUtil" "saveFolder" saveBipFolder_et.text

				setBatchIni_fn "batchUtil" "recurse" (recurse_cb.checked as string)
				
				--Save position of the dialog
				setbatchIni_fn "batchUtil" "Position" (getDialogPOs batchUtil_R as string)
			)
			
			
			on browseStandard_bt pressed do 
			(
				theName = undefined
				theName = getOpenFileName caption:"打开新的标准MAX文件" types:"Max Files (*.max)|*.max|" historyCategory:"openfile" initialDir:(getDir #maxroot)
				if theName != undefined then (browseStandard_et.text = theName)
			)
			
			
		/*	on browseDir_bt pressed do
			(
				path = (getSavePath caption:"Choose Directory for Scripts")
				if path != undefined then
				(
					batchDir_et.text = path
					batchList_mlb.items = (getScipts_fn batchDir_et.text)
				)
			)
			*/
			

			on saveLoadStyle_rdo changed state do
	(
		if saveLoadStyle_rdo.state == 2 then
		(

--			vObj_chk.enabled = true
			tcbEuler_chk.checked=false
			tcbEuler_chk.enabled=true
			_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[1] off
			_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[2] off
			bip_chk.checked= true
			bip_chk.enabled= false
			selAll_bt.enabled=true
			recurse_cb.enabled=false
			maxFiles_mlb.items = (getBipFiles_fn saveBipFolder_et.text)
/*			theName = undefined
			theName = getMAXOpenFileName() 
			try (loadMaxFile theName  useFileUnits:true quiet:true)
			catch()
*/
		)
		else 
		(

--			vObj_chk.enabled = false
			tcbEuler_chk.checked=false
			tcbEuler_chk.enabled=true
			_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[1] off
			_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[2] off
			selAll_bt.enabled=true
			recurse_cb.enabled=true
	--		if bone_chk.checked == true then vObj_chk.checked = true else vObj_chk.checked = false
			maxFiles_mlb.items = (getMaxFiles_fn processDir_et.text)
		)
	)	
	
			
			on browseProcess_bt pressed do
			(
				path = (getSavePath caption:"请选择要导出的Max文件路径")
				if path != undefined then
				(
					processDir_et.text = path
					getMaxFiles_fn path
				)
			)
			on browseBipSaveFolder_bt pressed do
			(
				path = (getSavePath caption:"请选择Bip文件路径")
				if path != undefined then
				(
					saveBipFolder_et.text = path
					
				)
			)
			

			
	/*on batchDir_et entered str do
			(
				batchList_mlb.items = (getScipts_fn str)
			)
		*/
			on processDir_et entered str do
			(
				
				maxFiles_mlb.items = (getMaxFiles_fn processDir_et.text)
					
			)
		/*	
			on bone_chk changed state do
			(
				if state then
				(
					browseBipSaveFolder_bt.enabled = false
					saveBipFolder_et.enabled = false
				)else
				(
					browseBipSaveFolder_bt.enabled = true
					saveBipFolder_et.enabled = true
				)
			)
			
		*/


			on tcbEuler_chk changed theState do
			(
				if tcbEuler_chk.checked!=true then
				(
					_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[1] off
					_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[2] off

				)else
				(
					_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[1] on
					_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[2] on
				)
			)


			--Read log file
			on readLog_bt pressed do
			(
				edit (getBatchIni_fn "batchUtil" "LogPath")
			)
			
			on getFiles_bt pressed do
			(
			
			
				if saveLoadStyle_rdo.state == 1 then
				(

					maxFiles_mlb.items = (getMaxFiles_fn processDir_et.text)
					

				)
				else 
				(

					maxFiles_mlb.items = (getBipFiles_fn saveBipFolder_et.text)
				)
			
			
			
				
			)
			
			on recurse_cb changed state do
			(
				maxFiles_mlb.items = (getMaxFiles_fn processDir_et.text)
			)
			
			
			
---------------------------------------开始导出/入--------------------------------------------------------------------------------------------------------------------------------------------------			

			on process_bt pressed do
			(
				escapeEnable = true
				maxpostfix= ".max"
				bipPostfix = ".bip"
				xafPostfix = ".xaf"
				txtPostfix = ".txt"
				if saveLoadStyle_rdo.state == 1 then
				(	
					if isDirectoryWriteable saveBipFolder_et.text ==false do makeDir saveBipFolder_et.text

					
					if bip_chk.checked==false and bone_chk.checked ==false do 
					(
						return(messagebox "请选择要导出的类型！bone？bip？")
					)

					--check for selected files
					
					fileSel = 0
					for x = 1 to maxFiles_mlb.items.count do
					(
						if maxFiles_mlb.selection[x] == true do (fileSel += 1)
					)
					
					progBar_pb.value = 0
					num = 0
					--check that files and scripts have been selected.
					if (fileSel > 0) then
					(
						escapeEnable = true
						
						--Loop through files, open and run script.
						for x in maxFiles_mlb.selection do
						(
							--Load the max file and run the selected scripts.
							loadMaxFile maxFiles_mlb.items[x] useFileUnits:true quiet:true

							
								if bip_chk.checked do
								(
									--print SaveBipFile							
									selBiparray=#()
									for i in objects do
									(
										if classof i == Biped_Object do append selBiparray i
									)

									----------------------------------------------------------
									if selBiparray.count == 0 do continue;
									
										currentMaxFileName = getFilenameFile maxFiles_mlb.items[x]
										saveBipFileName = saveBipFolder_et.text+ "\\"+currentMaxFileName+bipPostfix		

						--导出bip==============================================================================================================================
										bipedChosen = undefined
										allBiped = for i in geometry where (classof  i ==Biped_Object) collect i
										if (allBiped.count > 0) then  

										(
											for o in allBiped where o.controller.rootNode == o do bipedChosen = o
										)
										else  continue;
										(

										if bipedChosen.controller.figureMode==true do bipedChosen.controller.figureMode=false

										biped.saveBipFile bipedChosen.controller saveBipFileName 
										)
									
								)
								
								
		
								--导出xaf=========================================================================================================================
								if bone_chk.checked do
								(
									
									saveBoneAni=for i in geometry where (classof i == BoneGeometry) collect i
									for i in $v_* do (
										append saveBoneAni i	--添加虚拟体
										--addNewKey i 0f		--第一帧打上关键帧
									)
									for o in saveBoneAni do (addNewKey o 0f) 
									--------------------------华丽丽的分割线，去掉没有链接关系的重名骨骼--------------------------------------------------
									tempArr=#()
									for j = 1 to saveBoneAni.count-1 do
									(
										for k = j+1 to saveBoneAni.count do 
										(
											if saveBoneAni[j].name == saveBoneAni[k].name do 
											(
												if saveBoneAni[k] == undefined then append tempArr saveBoneAni[k] 
												else append tempArr saveBoneAni[j]
											)
										)
									)
									if tempArr.count != 0 do
									(
										for i =1 to tempArr.count do
										(
											for p =1 to saveBoneAni.count do
											(
												if tempArr[i]==saveBoneAni[p] do deleteItem saveBoneAni p
											)
										)
									)
									
									
								if saveBoneAni.count != 0 then		
								(	
								
									if tcbEuler_chk.checked!=false then
									(
										if tcbEulerStyle_rdo.state==1 then
										(  
											for i = 1 to tempArr.count do tempArr[i].rotation.controller = TCB_Rotation()
										)
		
										else
										(  
											for i = 1 to tempArr.count do tempArr[i].rotation.controller = Euler_XYZ()
										)	
									)	


									
								)	
									
									
									-------------------------华丽丽的分割线---------------------------------------------------
									
									
									timeRangeFile = saveBipFolder_et.text +"\\"+currentMaxFileName + txtPostfix
								

									try(
											if (doesFileExist timeRangeFile) == false then 
												fs = createFile timeRangeFile 
											else
												fs = openFile timeRangeFile mode:"w" --else open it mode w for writing

											sourceTimeRange = #(animationRange.start,animationRange.end)
											
											print sourceTimeRange to:fs
											close fs
										
										
										)
										
									catch( messageBox "未保存成功，请检查模型。")

								
									
									if saveBoneAni.count == 0 do continue;
									(
										currentMaxFileName = getFilenameFile maxFiles_mlb.items[x]
										saveXafFileName = saveBipFolder_et.text+ "\\"+currentMaxFileName+xafPostfix	
										
										userAttr = #()
										userVal = #()
										LoadSaveAnimation.saveAnimation saveXafFileName &saveBoneAni &userAttr &userVal 
									)
								)	

							resetMaxFile #noPrompt
							--Get path name
							path = ""

								path = (saveBipFolder_et.text)

							--get file name
							file = (fileNameFromPath maxFiles_mlb.items[x])
							

							
							--Update progress bar
							progBar_pb.value = ((100.0 * (num += 1)) / fileSel)
						)
					)else 
					(
						messageBox "请选择要导出的MAX文件。"
					)
			
				)
--***************************导入动画*************************************************************************************************************************************************


				else 
				(
			
					
					escapeEnable = true
					
					
					bipPostfix = ".bip"
					xafPostfix = ".xaf"
					txtPostfix = ".txt"
					standardMaxFileName = browseStandard_et.text
					standardMaxFilePath = getFilenamePath standardMaxFileName
					if isDirectoryWriteable standardMaxFilePath ==false do makeDir standardMaxFilePath	
					
					if bip_chk.checked==false and bone_chk.checked ==false do 
					(
						return(messagebox "请选择要导入的类型！bone？bip？")
					)



									
				
					--check for selected files

					
					fileSel = 0
					for x = 1 to maxFiles_mlb.items.count do
					(
						if maxFiles_mlb.selection[x] == true do (fileSel += 1)
					)
					
					progBar_pb.value = 0
					num = 0

					--check that files and scripts have been selected.
					if (fileSel > 0) and (getFiles browseStandard_et.text).count > 0 then
					(
						escapeEnable = true
						
						--Loop through files, open and run script.
						for x in maxFiles_mlb.selection do
						(

							try (loadMaxFile browseStandard_et.text  useFileUnits:true quiet:true)
							catch( messageBox "文件打开错误，请检查是否填入标准MAX档路径含文件名， 并保证该文件可读。")
							currentBipFileName = getFilenameFile maxFiles_mlb.items[x]
							currentBipFileFullName = saveBipFolder_et.text+ "\\"+currentBipFileName+bipPostfix
							saveMaxFileName = standardMaxFilePath+currentBipFileName+maxPostfix		
							currentTimeRangeFileName = saveBipFolder_et.text+ "\\"+currentBipFileName+txtPostfix
							--导入bip
							if bip_chk.checked do
							(
							
								
								bipedChosen = undefined
								allBiped = for i in geometry where (classof  i ==Biped_Object) collect i
								if (allBiped.count > 0) then 
								(
									for o in allBiped where o.controller.rootNode == o do bipedChosen = o
								)
								else	continue;
									(
									if bipedChosen.controller.figureMode == on do bipedChosen.controller.figureMode = off
									biped.loadbipfile bipedChosen.controller currentBipFileFullName			--导入bip档
									)
								
							)
							


					--导入xaf
					if bone_chk.checked then
					(
						--print loadXafFile 
						currentXafFileName = getFilenameFile maxFiles_mlb.items[x]
						currentXafFileFullName = saveBipFolder_et.text+ "\\"+currentXafFileName+xafPostfix
						loadBoneAni=for i in geometry where (classof i == BoneGeometry) collect i
/*						if vObj_chk.checked do
						(
							for i in $v_* do append loadBoneAni i			--添加虚拟体
						)
*/

						if loadBoneAni.count != 0 then		
						(	
						
							if tcbEuler_chk.checked!=false then
							(
								if tcbEulerStyle_rdo.state==1 then
								(  
									for i = 1 to loadBoneAni.count do loadBoneAni[i].rotation.controller = TCB_Rotation()
								)

								else
								(  
									for i = 1 to loadBoneAni.count do loadBoneAni[i].rotation.controller = Euler_XYZ()
								)	
							)	


							
						)			




						for o in loadBoneAni do deleteKeys o							
						if loadBoneAni.count == 0 do continue;
						(
							userAttr = #()
							userVal = #()
							LoadSaveAnimation.loadAnimation currentXafFileFullName &loadBoneAni --relative:false
													
							--select #($'Bone L Head05', $'Bone R Head05')
							--macros.run "Characters" "AssumeSkinPose"
							
						
						)
					)else
					(
/*						if vObj_chk.checked do
						(
							loadBoneAni = for i in $v_* collect i			--添加虚拟体
							for o in loadBoneAni do deleteKeys o							
							if loadBoneAni.count == 0 do continue;
							(
								userAttr = #()
								userVal = #()
								LoadSaveAnimation.loadAnimation currentXafFileFullName &loadBoneAni
								
	
							)
						)					
*/
						)


							 try
							 (
										timeRangeArr  = #()
										fs = openfile currentTimeRangeFileName
										while eof fs == false do
										(
											w = readline fs
											append timeRangeArr (w as integer)
										)
										close fs
										animationRange = interval timeRangeArr[1] timeRangeArr[2]

									
							  )
							  
							catch( print "error")

							savemaxfile saveMaxFileName useNewFile:true quiet:true			--保存max档


						--	resetMaxFile #noPrompt
							--Get path name
							path = ""

								path = (saveBipFolder_et.text)

							--get file name
							file = (fileNameFromPath maxFiles_mlb.items[x])
							

							
							--Update progress bar
							progBar_pb.value = ((100.0 * (num += 1)) / fileSel)
						)
					)else 
					(
						messageBox "请填入或打开新标准MAX档，同时选择要导入的bip文件。"
					)
				

			
				)
			)
			
				
	
			--Select all
			on selAll_bt pressed do
			(
				maxFiles_mlb.selection = #{1..maxFiles_mlb.items.count}
			)
			--Delselect all
			on deSelAll_bt pressed do
			(
				maxFiles_mlb.selection = #{}
			)
			
			--Cancel dialog
			on close_bt pressed do
			(
				destroyDialog batchUtil_R
			)
		)
		batchUtil=batchUtil_R
		createDialog batchUtil_R style:#(#style_titleBar, #style_border, #style_sysMenu, #style_minimizeBox)
		_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[1] off
		_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[2] off
	)--End Run Function
)--End Struct

	Bip_batchTool=Bip_batchTool()
	
try (
		Bip_batchTool.closeUI()
	)
catch()

		Bip_batchTool.run()




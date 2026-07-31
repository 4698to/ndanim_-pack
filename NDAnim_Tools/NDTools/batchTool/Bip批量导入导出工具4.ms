/*

Author：ZhangHan  （Rewrite and modified based on PEN_batchItMax.ms by Paul Neale and autoSaveLoadAni.ms by Zheng bingbing. ）
99U:593027
QQ :270528858
Usage: Just drag and drop
version: 1.2
Date:2016/10/25
update：2017/04/06

2020-07-17
99U:199505
QQ :738746223

*/
struct amin_controller_type_struct 
(
	name,
	node,
	parent,
	handle,
	parent_name,
	rotation_type,
	fn match_name = 
	(

		return (this.name + this.parent_name)
	)
)
struct anim_3dsMax_xaf_struct 
(
	savebones_anim = (),-- 这是新模文件中的 bone-挂点 数据
	rotationData = #(), -- 这是 xaf 动画文件中收集到的 bone-挂点 数据
	fn load_xaf file_path = 
	(
		local xmlDoc = (dotNetObject "system.xml.xmlDocument")
		xmlDoc.load file_path
		
		this.rotationData = #()
		
		-- 获取所有 Node 节点
		local nodes = xmlDoc.getElementsByTagName("Node")
		
		for i = 0 to (nodes.count - 1) do
		(
			local node = nodes.item(i)
			local nodeName = node.getAttribute("name")
			local node_parent_name = node.getAttribute("parentNode")

			-- 在当前 Node 下查找 Rotation Controller
			--local rotationControllers = node.selectNodes(".//Controller[@classOf='Euler XYZ']")

			match_str = ".//Controller[@name='" + nodeName + " \ Transform \ Rotation']"
			local rotationControllers = node.selectNodes(match_str)

			for j = 0 to (rotationControllers.count - 1) do
			(
				local controller = rotationControllers.item(j)
				local controllerName = controller.getAttribute("name")
				
				controller_struct = amin_controller_type_struct()
				controller_struct.name = nodeName
				controller_struct.parent_name = node_parent_name


				-- 获取 controller classOf
				class_type = controller.getAttribute("classOf")
				controller_struct.rotation_type = class_type

				append this.rotationData controller_struct
				--format "% ->%\n" controllerName class_type

				-- 获取 Samples 数据
				/* local samples = controller.selectNodes(".//Samples")
				if samples.count > 0 do
				(
					
					-- 存储该控制器的旋转数据
					local controllerData = (
						nodeName: nodeName,
						controllerName: controllerName,
						sampleCount: (sampleCount as integer),
						samples: sampleData
					)
					append rotationData controllerData
				) */
			)
		)
		
		xmlDoc = undefined
		-- 返回旋转数据
		return this.rotationData
	),
	fn updata_savebones_anim node_parent_name rotation_type = 
	(
		for i in this.savebones_anim do 
		(
			if (i.match_name()) == node_parent_name do 
			(
				i.rotation_type = rotation_type
				exit
			)
		)
	),
	-- 从 xaf 数据中更新 bone-挂点 旋转类型
	fn updata_rotation_type = 
	(
		for i in this.rotationData do 
		(
			this.updata_savebones_anim (i.match_name()) (i.rotation_type) 
		)
	),
	--设置场景中的 bone-挂点 旋转类型
	fn set_rotation_type = 
	(
		for i in this.savebones_anim do 
		(
			_node = maxOps.getNodeByHandle i.handle
			--多次判断，确定匹配成功
			if isValidNode _node then(
				if _node.name == i.name do 
				(
					if _node.parent != undefined then (
						if _node.parent.name == i.parent_name do 
						(
							--
							this.set_rotation_controller _node i.rotation_type 
						)
					)else(
						if i.parent_name == "Scene Root" do 
						(
							--
							this.set_rotation_controller _node i.rotation_type 

						)
					)
				)
			)else(

			)
		)
	),
	fn set_rotation_controller node rotation_type = 
	(
		if not isValidNode node do (return false)
		if rotation_type == undefined do (return false)
		if node.transform.controller.classid[1] != 8197 do (return false)

		if rotation_type == "Euler XYZ" or rotation_type == "Euler_XYZ" do 
		(
			node.Rotation.Controller = Euler_XYZ() 
			--format "set rotation Euler_XYZ -> % \n" node.name 
		)
		if rotation_type == "TCB Rotation" or rotation_type == "TCB_Rotation" do 
		(
			node.Rotation.Controller = TCB_Rotation() 
			--format "set rotation TCB_Rotation -> % \n" node.name 
		)
	)
)

global anim_3dsMax_xaf_struct_init 
anim_3dsMax_xaf_struct_init = anim_3dsMax_xaf_struct()


try (Bip_batchTool.closeUI())catch()
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
struct bone_anim_controller_struct 
(
	name ,
	controller 
)
global settings_bones_roll
struct Bip_batchTool
(
	batchUtil=undefined,

	fn closeUI=
	(
		if batchUtil!=undefined then
		(
			destroyDialog batchUtil
			batchUtil = undefined
		)
	),
	filter_bones_name = #(),
	set_bones_position_roll = rollout settings_bones_roll "设置骨骼名单" width:450 height:200
	(
		editText processDir_et "骨骼名单路径:" fieldWidth:340 readOnly:true  
		button bt_select "选择" width:80 across:2 
		button bt_saveas "保存选中骨骼" width:80 
		on bt_saveas pressed do 
		(
			for i in selection do 
			(
				if i.classid[1] == 683634317 do 
				(

				)
			)
		)
	),
	fn run =
	(
		--Interface
		rollout batchUtil_R "Bip批量导入导出工具 2025.10.16" width:1000
		(
			local btW = 80

			button browseProcess_bt "选择" width:btW across:2  pos:[16,10]
			editText processDir_et "源Max文件路径:" fieldWidth:795	 pos:[106,14] readOnly:true  

			button browseBipSaveFolder_bt "选择" width:btW  across:2	 pos:[16,40]
			editText saveBipFolder_et "Bip文件路径:      " fieldWidth:795  pos:[106,44] readOnly:true  

			button browseStandard_bt "选择" width:btW  across:2   pos:[16,70]
			editText browseStandard_et "新标准MAX档： " fieldWidth:795 fieldWidth:780  pos:[106,74] readOnly:true  


			button browseStandard_NewMaxSave_bt "选择" width:btW  across:2   pos:[16,100]
			editText NewMaxSave_et "新MAX档保存： " fieldWidth:795 fieldWidth:780  pos:[106,104] readOnly:true  

			groupbox gr_01 "模式" pos:[10,125] width:975  height:50
			radiobuttons saveLoadStyle_rdo "" pos:[16,145] width:100 height:32 labels:#("导出", "导入")

			checkbox tcbEuler_chk "修改bone的旋转模式" checked:false across:2	 pos:[330,145]
			radiobuttons tcbEulerStyle_rdo ""	default:1  pos:[465,145] width:500	height:32 labels:#("TCB", "Euler")

			label lab_0002 "骨骼："  pos:[150,145]
			checkbox bone_chk	"bone" checked:true  pos:[190,145]
			checkBox bip_chk  "bip" checked:true	 pos:[250,145]
            --checkBox vObj_chk "v_*虚拟体" enabled:false checked:true	 pos:[280,178]
			edittext ed_text_name "前缀名排除：" fieldWidth:70 height:20 pos:[610,143]
			
			button btn_open_setting "设置骨骼名单" width:80 height:20 pos:[800,143]

			button getFiles_bt "读取文件"  width:btW pos:[14,190] 
			checkBox recurse_cb "包含子目录" checked:true pos:[100,194] 
			button selAll_bt "全选文件" width:btW pos:[190,190] 
			button deSelAll_bt "取消选择" width:btW pos:[280,190] 
			button process_bt "开始导出/入" width:btW pos:[370,190] 
			
			hyperlink bt_info "帮助" across:2 address:"http://anim.nd.com.cn/pages/batch_bip3" width:btW pos:[480,194]  color:red hoverColor:(color 128 245 245)

			button close_bt "Close" width:btW pos:[905,190]


			multiListBox maxFiles_mlb "选择要处理的文件:" width:970 height:30  pos:[16,220]

			label prog0_lb "0%" across:3 align:#left
			label prog50_lb "50%"
			label prog1000_lb "100%" align:#right
			progressBar progBar_pb




			

			

			--保存 link 动画控制器
			local bones_anims = #()
			--保存的Bone-挂点 
			local savebones_anim = #() ,savebones_anim_scene_name = undefined

			local Encoding = (dotNetClass "System.Text.Encoding").UTF8
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

			fn get_Link_Constraint_nodes = 
			(
				Constraint_controllers = getclassinstances Link_Constraint processAllAnimatables:true
				find_nodes = #()
				for ic in Constraint_controllers do 
				(
					--defNodes = refs.dependents ic
					defNodes = refs.dependentNodes ic 
					for n in defNodes do 
					(
						if isValidNode n do (append find_nodes n)
					)

				)
				find_nodes = makeUniqueArray find_nodes
			)
			fn get_link_name currentMaxFileName i_link = 
			(
				_name = currentMaxFileName + i_link.name
				if isValidNode i_link.parent then  
				(
					_name += i_link.parent.name
				)else(
					if i_link.children.count > 0 then (
						_name += i_link.children[1].name
					)else(

					)
				)
				_name
			)
			fn new_link_anim currentMaxFileName = 
			(
				link_nodes = get_Link_Constraint_nodes()
				for i_link in link_nodes do 
				(
					ic = bone_anim_controller_struct()
					_name = get_link_name currentMaxFileName i_link 
					
					ic.name = _name 
					ic.controller = copy i_link.transform.controller
					append bones_anims ic 
				)
			)
			fn find_bones_anims_struct _name =
			(
				for ic in bones_anims do 
				(
					if ic.name == _name do 
					(
						return ic 
					)
				)
				undefined
			)
			--获取场景中的 Bone 和挂点 用于保存 xaf 动画文件
			fn get_saveBoneAni = 
			(
				--只处理 bone 和 v_ 命名的其他物体
				saveBoneAni = for i in geometry where (classof i == BoneGeometry) collect i
				for i in $v_* do (
					append saveBoneAni i	--添加虚拟体
					--addNewKey i 0f		--第一帧打上关键帧
				)
				saveBoneAni
			)
			fn init_saveBoneAni_data = 
			(
				savebones_anim = #()

				all_bones = get_saveBoneAni()
				for i in all_bones do 
				(
					it = amin_controller_type_struct()
					it.name = i.name 
					if isValidNode i.parent then (
						it.parent_name = i.parent.name
					)else(
						it.parent_name = "Scene Root" -- 就是没有父级，
					)
					it.handle = i.handle 
					it.rotation_type = (classof i.rotation.controller) as string
					append savebones_anim it 
				)
				savebones_anim
			)
			fn set_time_range currentTimeRangeFileName = 
			(
				
								
				time_range_data = (dotnetclass "System.IO.File").ReadAllLines currentTimeRangeFileName Encoding 
				if time_range_data.count > 0 do 
				(
					time_range_line = time_range_data[1]
					time_ranges = filterString time_range_line ","
					try(
						start_time = time_ranges[1] as integer
						end_time = time_ranges[2] as integer
					)catch(
						start_time = 0 
						end_time = 100 
					)
					format "set animationRange-> % ,% \n" start_time end_time
					animationRange = interval start_time end_time
				)	
				--format "currentTimeRangeFileName -> %\n" time_range_data
			)
			--Create and write Log file.
			--FileIn is the file path being processed
			--ScriptIn is an array of the batch scripts being run on each max file
			/*
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

			)*/

			--Run on opening the interface. Gets and sets the interface settings and positions the
			--dialog to the last used position.
			on batchUtil_R open do
			(
				iniEx = if (getFiles ((getDir #plugCfg) + "\\" + "BatchIni.ini")).count > 0 then (true) else (false)

				processDir_et.text = if iniEx then (getBatchIni_fn "batchUtil" "processDir") else (getDir #scene)
				saveBipFolder_et.text = if iniEx then (getBatchIni_fn "batchUtil" "saveFolder") else (getDir #scene)

				recurse_cb.checked = if iniEx then (execute (getBatchIni_fn "batchUtil" "recurse")) else (true)

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
				temppath = (getSavePath caption:"请选择要导出的Max文件路径")
				if temppath != undefined then
				(
					processDir_et.text = temppath
					getMaxFiles_fn temppath
				)
			)
			on browseBipSaveFolder_bt pressed do
			(
				temppath = (getSavePath caption:"请选择Bip文件路径")
				if temppath != undefined then
				(
					saveBipFolder_et.text = temppath

				)
			)

			on browseStandard_NewMaxSave_bt pressed do
			(
				temppath = (getSavePath caption:"请选择保存目录")
				if temppath != undefined then
				(
					NewMaxSave_et.text = temppath
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


            ---开始导出/入

			on process_bt pressed do
			(
				escapeEnable = true
				maxpostfix= ".max"
				bipPostfix = ".bip"
				xafPostfix = ".xaf"
				txtPostfix = ".txt"

				if saveLoadStyle_rdo.state == 1 then
				(
					bones_anims = #()
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
							format "处理:%\n" maxFiles_mlb.items[x]
							currentMaxFileName = getFilenameFile maxFiles_mlb.items[x]

							--Load the max file and run the selected scripts.
							loadMaxFile maxFiles_mlb.items[x] useFileUnits:true quiet:true

							if bip_chk.checked do
							(
								--print SaveBipFile
								allBiped=#()
								for i in objects do
								(
									if classof i == Biped_Object do (
										bipedChosen_controller = undefined 
										try(
											bipedChosen_controller = i.transform.controller
										)catch(
											bipedChosen_controller = i.controller
										)

										if bipedChosen_controller.classid[1] == 37206L do 
										(
											append allBiped i 
										)
									)
								)

								----------------------------------------------------------
								if allBiped.count > 0 then
								(
									saveBipFileName = saveBipFolder_et.text+ "\\"+currentMaxFileName+bipPostfix
					                --导出bip
									bipedChosen = allBiped[1]
									if allBiped.count > 1 do 
									(
										format "	多个biped -> %\n" allBiped.count
									)
									
									
									if isValidNode bipedChosen do
									(
										bipedChosen_controller = undefined 
										try(
											bipedChosen_controller = bipedChosen.transform.controller
										)catch(
											bipedChosen_controller = bipedChosen.controller
										)
									
										if bipedChosen_controller != undefined then
										(
											biped.saveBipFile bipedChosen_controller saveBipFileName
										)else(
											format "	无法获取 controller:%\n" bipedChosen
										)
									)
								)else(
									format "	无biped\n"
								)
							)

							--导出xaf
							if bone_chk.checked do
							(
								save_timerange_boneinfo = "" as StringStream 
								timeRangeFile = saveBipFolder_et.text +"\\"+ currentMaxFileName + txtPostfix
								--保存时间轴信息
								format "%,%\n" animationRange.start.frame animationRange.end.frame to:save_timerange_boneinfo

								--只处理 bone 和 v_ 命名的其他物体
								/* saveBoneAni = for i in geometry where (classof i == BoneGeometry) collect i
								for i in $v_* do (
									append saveBoneAni i	--添加虚拟体
									--addNewKey i 0f		--第一帧打上关键帧
								) */
								
								saveBoneAni = get_saveBoneAni()

								for o in saveBoneAni do (addNewKey o 0f)
								--去掉没有链接关系的重名骨骼
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
									format "tcbEuler_chk.checked -> %\n" tcbEuler_chk.checked
									if tcbEuler_chk.checked then
									(
										if tcbEulerStyle_rdo.state==1 then
										(
											for i = 1 to saveBoneAni.count do saveBoneAni[i].rotation.controller = TCB_Rotation()
										)
										else
										(
											for i = 1 to saveBoneAni.count do saveBoneAni[i].rotation.controller = Euler_XYZ()
										)
									)else(
										--format "tempArr.count -> %\n" tempArr.count 
										--format "saveBoneAni.count -> %\n" saveBoneAni.count 

										--保存每个bone 骨骼的旋转控制器类型信息
										/* for ibone in saveBoneAni do
										(
											format "%,%,%\n" ibone.name (ibone.rotation.controller.classid[1]) (classof ibone.rotation.controller) to:save_timerange_boneinfo
										) */

									)
								)


								

								try(
									


									save_timerange_boneinfo_text = save_timerange_boneinfo as string 
									(dotnetclass "System.IO.File").WriteAllText timeRangeFile save_timerange_boneinfo_text Encoding
									/* if (doesFileExist timeRangeFile) == false then(
										fs = createFile timeRangeFile
									)
									else(
										fs = openFile timeRangeFile mode:"w" --else open it mode w for writing
									)
									sourceTimeRange = #(animationRange.start.frame,animationRange.end.frame)

									print sourceTimeRange to:fs
									close fs */
									
								)catch( messageBox "未保存成功，请检查模型。")



								if saveBoneAni.count == 0 do (continue)
								
								currentMaxFileName = getFilenameFile maxFiles_mlb.items[x]
								saveXafFileName = saveBipFolder_et.text+ "\\"+currentMaxFileName+xafPostfix

								userAttr = #()
								userVal = #()
								LoadSaveAnimation.saveAnimation saveXafFileName &saveBoneAni &userAttr &userVal
								--处理link约束
								new_link_anim currentMaxFileName
							)

							resetMaxFile #noPrompt
							--Get path name
							temppath = ""
							temppath = (saveBipFolder_et.text)

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
				else
				(

					escapeEnable = true
					bipPostfix = ".bip"
					xafPostfix = ".xaf"
					txtPostfix = ".txt"
					standardMaxFileName = browseStandard_et.text
					--standardMaxFilePath = getFilenamePath standardMaxFileName
					standardMaxFilePath = NewMaxSave_et.text 
					if standardMaxFilePath.count == 0 do 
					(
						return(messagebox "请选择 新Max文件保存目录")
					)
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

							format "%\n" maxFiles_mlb.items[x]
							try (
								loadMaxFile browseStandard_et.text useFileUnits:true quiet:true
							)catch( messageBox "文件打开错误，请检查是否填入标准MAX档路径含文件名， 并保证该文件可读。")
							
							if savebones_anim_scene_name == getFilenameFile browseStandard_et.text then (

							)else(
								--如果没有收集 新模型的 bone -挂点 数据，就开始初始收集
								anim_3dsMax_xaf_struct_init.savebones_anim = init_saveBoneAni_data()

								savebones_anim_scene_name = getFilenameFile browseStandard_et.text
							)

							currentBipFileName = getFilenameFile maxFiles_mlb.items[x]
							

							currentBipFileFullName = saveBipFolder_et.text+ "\\"+currentBipFileName+bipPostfix
							saveMaxFileName = standardMaxFilePath + "\\" + currentBipFileName + maxPostfix
							currentTimeRangeFileName = saveBipFolder_et.text+ "\\"+currentBipFileName+txtPostfix
							--导入bip
							if bip_chk.checked do
							(
								bipedChosen_s =#()
								try(
									bipedChosen_s = for i in geometry where (i.controller.classid[1] == 37206) collect i
								)catch(
									bipedChosen_s = for i in geometry where (i.transform.controller.classid[1] == 37206) collect i
								)

								for bipedChosen in bipedChosen_s do
								(
									if bipedChosen.controller.figureMode == on do
									(
										bipedChosen.controller.figureMode = off
									)
									format "% _> %\n" bipedChosen.name currentBipFileFullName
									biped.loadbipfile bipedChosen.transform.controller currentBipFileFullName			--导入bip档
								)

							)

							--导入xaf
							if bone_chk.checked then
							(
								--print loadXafFile
								currentXafFileName = getFilenameFile maxFiles_mlb.items[x]
								currentXafFileFullName = saveBipFolder_et.text + "\\" + currentXafFileName + xafPostfix
								--loadBoneAni = for i in geometry where (classof i == BoneGeometry) collect i
								--ed_text_name
								loadBoneAni = #()
		            			regex = (dotnetclass "System.Text.RegularExpressions.regex")

								for i in geometry do
								(
									if ed_text_name.text != "" then (

										if classof i == BoneGeometry and regex.ismatch i.name ed_text_name.text do
										(append loadBoneAni i )
									)else(
										if classof i == BoneGeometry do
										(
											append loadBoneAni i
										)
									)
								)
								/*
								if vObj_chk.checked do
								(
									for i in $v_* do append loadBoneAni i			--添加虚拟体
								)
								*/
								if loadBoneAni.count > 0 then
								(
									/* if tcbEuler_chk.checked !=false then
									(
										if tcbEulerStyle_rdo.state==1 then
										(
											for i = 1 to loadBoneAni.count do loadBoneAni[i].rotation.controller = TCB_Rotation()
										)

										else
										(
											for i = 1 to loadBoneAni.count do loadBoneAni[i].rotation.controller = Euler_XYZ()
										)
									) */



								)
								--for o in loadBoneAni do deleteKeys o
								if loadBoneAni.count > 0 do
								(
									if doesFileExist currentXafFileFullName do
									(
										-- 新模型的 bone - 挂点数据 -> savebones_anim 
										anim_3dsMax_xaf_struct_init.load_xaf currentXafFileFullName
										--从 xaf 中 更新 bone - 挂点数据 的 旋转控制器 类型
										anim_3dsMax_xaf_struct_init.updata_rotation_type()

										-- 用 handle 获取场景 对象 设置 旋转 控制器的类型
										anim_3dsMax_xaf_struct_init.set_rotation_type()

										userAttr = #()
										userVal = #()
										--select loadBoneAni
										--print currentXafFileFullName
										--print loadBoneAni.count


										LoadSaveAnimation.loadAnimation currentXafFileFullName loadBoneAni relative:true insert:true insertTime:0 stripLayers:false useMapFile:false --relative:false
										

										link_nodes = get_Link_Constraint_nodes()
										format "	处理Link 约束\n"  
										for i_link in link_nodes do
										(
											_name = get_link_name currentBipFileName i_link 
											controller_anim = find_bones_anims_struct _name
											if controller_anim != undefined then  
											(
												format "	%\n" i_link.name 
												--i_link.transform.controller = copy controller_anim.controller
												if i_link.transform.controller.classid[1] == controller_anim.controller.classid[1] then 
												(
													
													i_link.transform.controller[1][1].controller = copy controller_anim.controller[1][1].controller
													i_link.transform.controller[1][2].controller = copy controller_anim.controller[1][2].controller
													i_link.transform.controller[1][3].controller = copy controller_anim.controller[1][3].controller

												)else(
													format "	%\n" i_link.transform.controller
												)
											)else(
												format "	错误：未找到link 约束的信息 % :: %\n" i_link.name _name 
											)
										) 

									)

									--select #($'Bone L Head05', $'Bone R Head05')
									--macros.run "Characters" "AssumeSkinPose"
								)
							)

							--设置时间轴
							if doesFileExist currentTimeRangeFileName do 
							(
								format "currentTimeRangeFileName -> %\n" currentTimeRangeFileName
								set_time_range currentTimeRangeFileName
									
							)
							--savemaxfile saveMaxFileName useNewFile:true quiet:true			--保存max档
							saveMaxFile saveMaxFileName

						    --	resetMaxFile #noPrompt
							--Get path name
							temppath = ""

							temppath = (saveBipFolder_et.text)

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
			on btn_open_setting pressed do 
			(
				createDialog Bip_batchTool.set_bones_position_roll parent:(Bip_batchTool.batchUtil.hwnd)
			)
		)
		batchUtil = batchUtil_R
		createDialog batchUtil_R style:#(#style_titleBar, #style_border, #style_sysMenu, #style_minimizeBox)
		_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[1] off
		_user32.enablewindow batchUtil_R.tcbEulerStyle_rdo.hwnd[2] off
	)
    --End Run Function
)
--End Struct

global anim_3dsMax_xaf_struct_init 
if anim_3dsMax_xaf_struct_init == undefined do 
(
	messageBox "未发现anim_3dsMax_xaf_struct_init"
)
Bip_batchTool = Bip_batchTool()
Bip_batchTool.run()




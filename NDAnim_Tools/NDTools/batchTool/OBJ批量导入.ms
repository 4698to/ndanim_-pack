Fn getnames Title FilterName =(

	dialog = DotNetObject"System.Windows.Forms.OpenFileDialog"
	dialog.title = Title

	dialog.filter = FilterName

	dialog.Multiselect = true

	OpenFileResult = dialog.ShowDialog()

	if OpenFileResult.Equals OpenFileResult.OK then

	(
		dialog.FileNames
	)
	else 
		Undefined
)


rollout form "批量导入obj"
(
	label lbl "批量导入obj"
	button btn "选择导入obj路径" width:120 height:25
	on btn pressed do
	(
		file_names= getnames "选择导入文件" "OBJ (*.obj)|*.obj"
		if file_names != undefined do
		(
			for f in file_names do  
			(
				-- getFilenameFile file
				if ( doesfileexist f ) do 
				(
					importFile f #noPrompt using:Wavefront_Object   
					$.name = getFilenameFile f
				)
			)
		)
	)
)

createdialog form 200 50
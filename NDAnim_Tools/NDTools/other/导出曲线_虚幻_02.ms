
(
	global Track_View_HWND = undefined ,export_setect_trackview_json
	for child in (windows.getChildrenHWND (windows.getDesktopHWND())) do
	(
		if child[4] == "#32770" and child[5] == "Track View - Curve Editor" do 
		(
			global Track_View_HWND
			Track_View_HWND = child[1]
		)
	)

	try(DestroyDialog export_setect_trackview_json)catch()
	rollout export_setect_trackview_json "导出 虚幻 浮点曲线json" width:450 height:150
	(
		group "曲线"
		(
			edittext lab_02 "" readOnly:true align:#center
			spinner sp_factor "数值系数:" range:[-99,99,1] align:#left 

			button btn_get_b "拾取 曲线编辑器 中 选中的曲线导出" width:300 height:22
			
		)
		
		HyperLink btn_Help_web "Help" address:"https://sundaybox.cc/ueFlaotCurve/"  align:#center-- offset:[0,10]
		local master_a = undefined , master_b = undefined ,node_a ,node_b 
		
		fn format_josn_key controller_ jsonfile = 
		(
			json_textA = "{\n\"floatCurve\":\n{\n\"keys\": [\n"

			json_textB = "],\n\"defaultValue\": 3.4028234663852886e+38,\n\"preInfinityExtrap\": \"RCCE_Constant\",\n\"postInfinityExtrap\": \"RCCE_Constant\""
			json_textC ="\n},\n\"bIsEventCurve\": false,\n\"assetImportData\":\n{\n\"_ClassName\": \"/Script/Engine.AssetImportData\",\n\"sourceData\":{}\n}\n}"
			
			_textA = "{\n\"interpMode\": \"RCIM_Cubic\",\n\"tangentMode\": \"RCTM_Auto\",\n\"tangentWeightMode\": \"RCTWM_WeightedNone\",\n"
			_textB = "\"arriveTangent\": 0,\n\"arriveTangentWeight\": 0,\n\"leaveTangent\": 0,\n\"leaveTangentWeight\": 0\n}"
			
			key_text = StringStream ""
			format json_textA to:key_text

			for i = 1 to controller_.keys.count do 
			(
				k = controller_.keys[i]
				kTime = k.time.frame / framerate 
				kValue = k.value*sp_factor.value
				format _textA to:key_text
				format "\"time\": %,\n" kTime to:key_text
				format "\"value\": %,\n" kValue to:key_text
				format _textB to:key_text
				if i != controller_.keys.count then 
				(
					format ",\n" to:key_text
				)else(
					format "\n" to:key_text

				)
			)
			format json_textB to:key_text
			format json_textC to:key_text


			Encoding = (dotNetClass "System.Text.Encoding").UTF8
			--jsonfile = @"G:\Git_NDTools\Dev_Channel\UE5_Python\flaotCurve2.json"
 			(dotnetclass "System.IO.File").WriteAllText jsonfile (key_text as String) Encoding
		)
		fn format_json keys_string = 
		(
			
		)
		fn find_track_tiew_select_track = 
		(
			select_track = undefined
			track_view = trackviews.getTrackView((trackviews.numTrackViews()))
			if track_view != undefined do 
			(
				select_num = track_view.numSelTracks()
				for i = 1 to select_num do 
				(
					select_track = track_view.getSelected(i)
				)
			)
			select_track
		)
		
		on btn_get_b pressed do 
		(	
			master_b = find_track_tiew_select_track()
			if master_b != undefined then 
			(
				lab_02.text = (exprForMAXObject master_b)
				if master_b.keys.count > 1 then
				(
					filepath = getSaveFileName caption:"导出虚幻 浮点曲线json " types:"josn(*.json)|*.json|All|*.*|"
					if filepath != undefined do (format_josn_key master_b filepath)
				)else(
					messageBox "选中曲线没有帧"
				)
			)else(
				messageBox "没有拿到曲线"
			)
		)
		
	)
	if Track_View_HWND != undefined then (
		CreateDialog export_setect_trackview_json parent:Track_View_HWND
	)else(
		CreateDialog export_setect_trackview_json
	)
)
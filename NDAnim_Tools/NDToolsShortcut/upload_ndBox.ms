/*
# coding: utf-8 
# @Date    : 2025-04-02 12:40:53
# @Author  : 4698to (738746223@qq.com)
# @Link    : sundaybox.cc
# @99U     : 199505
*/


try (DestroyDialog NDBoxUploadFile)catch()
rollout NDBoxUploadFile "天晴盒子 【反馈|分享】" width:520 height:565
(
	local Encoding = (dotNetClass "System.Text.Encoding").UTF8
	label lab_1 offset:[0,-12]

	group "请正确填写联系方式以便接受后续结果" 
	(
		edittext contact_name "昵称:" fieldWidth:160 height:20 across:2
		edittext contact_text "联系邮箱:" fieldWidth:190 height:20 Align:#left
		label lab_04 "邮箱用以接收审核 回复, 2、3天内得到审核结果"
	)
	label lab_01 offset:[0,-8]
	group "工具来源或者帮助页面 链接"
	(
		edittext contact_help_url "" fieldWidth:490 height:50 Align:#left
		--dotNetControl contact_help_url "System.Windows.Forms.Textbox"  width:480 Height:50 
	)
	label lab_001 offset:[0,-8]

	group "简单介绍下所分享工具.有助其他人快速了解, 例如放在盒子的什么 分类中,或是如何安装等等"
	(
		edittext body_text "" fieldWidth:490 height:170
	)
	label lab_0001 offset:[0,-8]

	group "附件 | .mse .ms .py .rar .zip 等等"
	(
		--edittext contact_file "附件:" fieldWidth:310 height:20  across:2
		listbox contact_file "" width:420 height:5 across:2 offset:[4,0]
		button btn_addfile "选择" width:50 height:30 Align:#right --offset:[83,0]
		button btn_removefile "移除" width:50 height:30 Align:#right offset:[0,-35]

	
		label lab_02 "上传包建议控制在 8MB 以下,否则可能上传失败。" across:2 
		label lab_03 "服务器限制每个IP 每小时反馈上传 3 次"
	)
	button btn_zip_sele "打包 上传 / 分享, 审核通过后,将此分享添加到盒子资源更新中" width:370 height:24 offset:[0,5] enabled:false
	HyperLink lbl_01 "sundaybox.cc" address:"https://sundaybox.cc" color:(color 0 255 255) hoverColor:(color 0 255 255) align:#center
	
	
	local file_size = 0 
	local pick_file = "",filelist=#() ,filelistname = #(),file_size_sun = 0 

	local theZip = undefined 
	local orange_title = "反馈"
	local confing_file = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\config_updata.ini"

	fn set_ScriptTree_UpDate_TooLsText str =
	(
		NDBoxUploadFile.title = orange_title +" => " + str
	)
	fn pingWeb = 
	(
		newping = dotnetobject "System.Net.NetworkInformation.Ping"
		replys = newping.Send("www.sundaybox.cc")
		if replys.status == replys.status.Success then
		(
			format "OK: 服务器连接正常\n"
			set_ScriptTree_UpDate_TooLsText "服务器连接正常"
			return true
		)else (
			set_ScriptTree_UpDate_TooLsText "无法连接远程服务器"
			format "OK: 无法连接远程服务器\n";return false
		)
	)
	fn pingbaidu =
	(
			newping = dotnetobject "System.Net.NetworkInformation.Ping"
			replys = newping.Send("www.baidu.com")
			if replys.status == replys.status.Success then
			(
				--format "OK:%\n" "网络连接正常"
				set_ScriptTree_UpDate_TooLsText "网络连接正常"
				return true
			)else (
				set_ScriptTree_UpDate_TooLsText "无连接网络"
				--format "OK:%\n" "无连接网络";
				return false
			)
	)
	fn try_upload =
	(
		if doesFileExist theZip do 
		(
			
			data_zip_byte = (dotnetClass "System.IO.File").ReadAllBytes theZip
			
			url = "https://sundaybox.cc/upload_file"
			--url = "http://127.0.0.1:8019/upload_file"
			local spm = dotNetClass "System.Net.ServicePointManager"
			spm.SecurityProtocol = spm.SecurityProtocol.Tls12

			Request = (dotNetClass "System.Net.WebRequest").Create url
			Request.Method = "POST"
			--Request.ContentType = "application/x-www-form-urlencoded"; --表单类型例如：name=John&age=30&city=New+York。
			Request.ContentType = "application/octet-stream"
			Request.Proxy = undefined
			--Request.ContentLength = byte_code.count; -- 内容的byte长度


			dataStream = Request.GetRequestStream()
			

			dataStream.Write data_zip_byte 0 data_zip_byte.count 

			--Close the Stream object.
			dataStream.Close();
			htmlString = ""
			--try(
				response = request.GetResponse();
				
				if response.StatusCode == response.StatusCode.OK do 
				(
					res_dataStream = response.GetResponseStream();
					objReader = dotnetobject "System.IO.StreamReader" res_dataStream
					sLine =""
					while sLine != undefined and objReader!=undefined do
					(
						sLine = objReader.ReadLine()
						if sLine != undefined then(
							htmlString += sline
						)
					)
				)
				response.Close()
				if htmlString == "200" then (
					format "上传结果 %\t\n" htmlString ; messageBox "上传完成！" title:htmlString
				)else(
					format "上传结果 %\t\n" htmlString ; messageBox htmlString title:"上传异常,请联系我 738746223@qq.com"
				)
				
			--)catch(
			--	format "%\n" htmlString 
			--	messageBox "上传失败" title:"上传结果" 
			--)
			

		)

	)
	fn ionic_zip_Extract paht_name id =
	(
			
		is_ok = false
			--test_password = zip_password.text --"ND123456"  --"123456"
			test_path = paht_name ;
			if not (doesFileExist test_path) do (return false)
			test_zipName = id + ".zip"
			test_zip = (getDir #temp) +"\\" + test_zipName

					--local Ionic_zip_b =  ((getDir #scripts)+"\\"+ "Ionic.Zip.dll")
					local Ionic_zip_b = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\Ionic.Zip.dll"

					if doesFileExist Ionic_zip_b do
					(
						file_index = filelist.count 
						for ifile in filelist do 
						(
							if doesFileExist ifile do 
							(
								file_index -= 1 
								try(
									tempfile = paht_name + (filenameFromPath ifile )
									copyFile ifile tempfile
								)catch()
							)
						)
						if file_index != 0 do
						(
							return false 
						)			
						dotNet.loadAssembly Ionic_zip_b
						tempZip = (dotNetObject "Ionic.Zip.ZipFile")
						tempZip.AlternateEncoding= tempZip.DefaultEncoding.UTF8 --设置编码，否则中文乱码
						tempZip.AlternateEncodingUsage = tempzip.AlternateEncodingUsage.Always
						--tempZip.password = test_password --压缩包密码
						tempZip.AddDirectory test_path -- 添加要压缩的文件夹
						
						--format "zip -> %\n" test_path

						tempZip.save test_zip --完成压缩
						
						tempZip.Dispose()
						file_size = (getFileSize test_zip) / 1024.0
						
						theZip = test_zip

						tempZip = undefined
						is_ok = true 
					)
		is_ok
	)
	
	on btn_zip_sele pressed do
	(
		if filelist.count > 0 then (
			if contact_text.text != "" and body_text.text != "" do 
			(
				theZip = ""
				--pick_file = ""

				file_txt = contact_text.text
				file_txt += "\r\n"
				file_txt += contact_name.text 
				file_txt += "\r\n"
				file_txt += body_text.text

				id = genguid() 
				txtfile_path = (getdir #temp) +"\\"+ id +"\\"

				if not ((dotNetClass "system.IO.Directory").Exists txtfile_path)do 
				(
					(dotNetClass "system.IO.Directory").CreateDirectory txtfile_path
				)
				txtfile = txtfile_path + "contact_text.txt"
				(dotnetclass "System.IO.File").WriteAllText txtfile file_txt Encoding
				
				format "打包内容 : %\r\n" txtfile_path

				if (ionic_zip_Extract txtfile_path id) then
				(
					
					--format "将会发送 % KB 资料包\r\n" ((file_size  / 1024.0 )as string )

					is_ok = queryBox ("将会发送 " + (file_size as string ) + " KB 资料包")
					if is_ok do 
					(
						if pingWeb() and pingbaidu() do (
							try_upload()
						)
					)
				)else(
					messageBox "打包失败,无法上传反馈信息"
				)
			)
		)else(
			messageBox "没有选取 文件"
		)
	)
	on btn_addfile pressed do
	(
		file = getOpenFileName caption:"选择上传文件 , 只能选择 1 个文件"
		if file != undefined do 
		(
			
			temp_size = (getFileSize file) / 1024.0
			file_size_sun = file_size_sun + temp_size

			max_size = 8.0*1024.0
			if file_size_sun <= max_size then 
			(
				--contact_file.text = file 
				if (findItem filelist file) == 0 do 
				(
					
					fname = (getFilenameFile file) + (getFilenameType file) 
					append filelist file
					append filelistname fname 
					contact_file.items = filelistname
					btn_zip_sele.enabled = true 
				)
				
			)else(
				messageBox ((temp_size as string ) + " KB 选择文件太大")
			)
		)
	)
	on btn_removefile pressed do 
	(
		if contact_file.selection > 0 and filelist.count > 0 then 
		(
			deleteItem filelist contact_file.selection 
			deleteItem filelistname contact_file.selection 
			contact_file.items = filelistname

		)else(
			btn_zip_sele.enabled = false 

		)

	)
	on NDBoxUploadFile close do
	(
		setINISetting confing_file "NDBoxUpdata" "nickname" contact_name.text 
		setINISetting confing_file "NDBoxUpdata" "contact_information" contact_text.text 
		setINISetting confing_file "NDBoxUpdata" "help_url" contact_help_url.text 
		setINISetting confing_file "NDBoxUpdata" "body_text" body_text.text 

	)
	on NDBoxUploadFile open do
	(
		contact_name.text = getINISetting confing_file "NDBoxUpdata" "nickname" 
		contact_text.text = getINISetting confing_file "NDBoxUpdata" "contact_information"
		contact_help_url.text = getINISetting confing_file "NDBoxUpdata" "help_url"
		body_text.text = getINISetting confing_file "NDBoxUpdata" "body_text" 
	)
)



createDialog NDBoxUploadFile 


/*
-- coding: utf-8 
-- @Date    : 2025-05-23 19:34:39
-- @Author  : 4698to (738746223@qq.com)
-- @Link    : sundaybox.cc
-- @Version : 
*/
global NDAnimLib -- 主体
--打开前先检查是已经打开过了
try(if NDAnimLib != undefined do (NDAnimLib.close()))catch()
global AnimLibHelpRoll
global AnimLibTestRoll -- 修改挂点任务卷展栏
global AnimLibTestAddNew -- 创建挂点任务卷展栏

struct NDAnimLibFilePack_Struct
(
	body_file, -- 文件路径列表
	thumbnail_file,--缩略图
	preview_file, --预览视频
	pictureBox_image,
	-- 带 _ 前缀的 属性全部都要添加 上传参数 上	
	body_ext ,--主文件夹后缀名
    preview_ext ,
    thumbnail_ext ,
	_id_99u = "199505" ,--99uID 
	_dcc_name = "3dsMax",
	
	_start_frame ,-- 起始帧
	_end_frame, -- 结束帧
	_fps=30, -- 帧率
	_frames, -- 帧数
	_tags = "", -- 标签字符
	
	_folder_id = "311922007", -- 目标文件夹id  天晴动作 311922007
	_target_path="", -- 目标文件夹路径
	
	encoding = (dotNetClass "System.Text.Encoding").UTF8,
	uploadURl , -- 上传的 API 接口 url
	formContent,
	fn new_prop_data = 
	(
		if this.formContent != undefined then (
			prop_name = getPropNames this 
			for i in prop_name do 
			(
				_name = i as string 
				if _name[1] == "_" do 
				(
					
					_value = getProperty this i  
					--format "% -> %\n" _name _value
					if _value != undefined then(
						_name = substring _name 2 (_name.count - 1)
						_StringContent = dotNetObject "System.Net.Http.StringContent" (_value as string) this.Encoding
						this.formContent.Add _StringContent _name
					)
				)
				
			)
		)else(
			format "formContent - 还没有实例化 \n"  
		) 

	) ,
	fn new_form_conten = 
	(
		_is_ok = false
		index = 0 
		data_zip_byte = undefined
		this.formContent = dotNetObject "System.Net.Http.MultipartFormDataContent"
		if doesFileExist this.body_file do 
		(
			this.body_ext = getFilenameType (this.body_file)

			data_zip_byte = (dotnetClass "System.IO.File").ReadAllBytes this.body_file
			
			fileContent = dotNetObject "System.Net.Http.ByteArrayContent" data_zip_byte

			Headers_ContentType = dotNetObject "System.Net.Http.Headers.ContentDispositionHeaderValue" "form-data"
			Headers_ContentType.Name = "body_file"
			Headers_ContentType.FileName = (dotNetClass "System.IO.Path").GetFileName(this.body_file)
			
			fileContent.Headers.ContentDisposition = Headers_ContentType

			-- 设置 Content-Type 头
			--contentType ="application/" + this.body_ext 
			--TypeHeaderValue = dotNetObject "System.Net.Http.Headers.MediaTypeHeaderValue" contentType
			--fileContent.Headers.ContentType = TypeHeaderValue

			this.formContent.Add fileContent
			index += 1 
		)
		if doesFileExist this.thumbnail_file do 
		(
			data_zip_byte = (dotnetClass "System.IO.File").ReadAllBytes this.thumbnail_file
			
			fileContent = dotNetObject "System.Net.Http.ByteArrayContent" data_zip_byte

			Headers_ContentType = dotNetObject "System.Net.Http.Headers.ContentDispositionHeaderValue" "form-data"
			Headers_ContentType.Name = "thumbnail_file"
			Headers_ContentType.FileName = (dotNetClass "System.IO.Path").GetFileName(this.thumbnail_file)
			
			fileContent.Headers.ContentDisposition = Headers_ContentType
			this.formContent.Add fileContent
			index += 1 

		)
		if doesFileExist this.preview_file do 
		(
			data_zip_byte = (dotnetClass "System.IO.File").ReadAllBytes this.preview_file
			
			fileContent = dotNetObject "System.Net.Http.ByteArrayContent" data_zip_byte

			Headers_ContentType = dotNetObject "System.Net.Http.Headers.ContentDispositionHeaderValue" "form-data"
			Headers_ContentType.Name = "preview_file"
			Headers_ContentType.FileName = (dotNetClass "System.IO.Path").GetFileName(this.preview_file)
			
			fileContent.Headers.ContentDisposition = Headers_ContentType
			this.formContent.Add fileContent
			index += 1 

		)
		data_zip_byte = undefined 
		if index < 3 then  
		(
			format "资源数量不对 , 取消 创建 formContent \n" 
			this.formContent = undefined 
		)else(
			_is_ok = true
		)
		ok 
		_is_ok 
		/*
		dcc_name_StringContent = dotNetObject "System.Net.Http.StringContent" (this.dcc_name()) this.Encoding
		body_ext_StringContent = dotNetObject "System.Net.Http.StringContent" (this.body_ext) this.Encoding
		preview_ext_StringContent = dotNetObject "System.Net.Http.StringContent" (this.preview_ext) this.Encoding
		thumbnail_ext_StringContent = dotNetObject "System.Net.Http.StringContent" (this.thumbnail_ext) this.Encoding

		
		start_frame_StringContent = dotNetObject "System.Net.Http.StringContent" (this.start_frame) this.Encoding
		end_frame_StringContent = dotNetObject "System.Net.Http.StringContent" (this.end_frame) this.Encoding
		fps_StringContent = dotNetObject "System.Net.Http.StringContent" (this.fps) this.Encoding
		frames_StringContent = dotNetObject "System.Net.Http.StringContent" (this.frames) this.Encoding

		folder_id_StringContent = dotNetObject "System.Net.Http.StringContent" (this.folder_id) this.Encoding
		target_path_StringContent = dotNetObject "System.Net.Http.StringContent" (this.target_path) this.Encoding
		root_type_StringContent = dotNetObject "System.Net.Http.StringContent" (this.root_type) this.Encoding
		

		this.formContent.Add dcc_name_StringContent "dcc_name"
		this.formContent.Add body_ext_StringContent "body_ext"

		this.formContent.Add start_frame_StringContent "start_frame"
		this.formContent.Add end_frame_StringContent "end_frame"
		this.formContent.Add fps_StringContent "fps"
		this.formContent.Add frames_StringContent "frames"

		this.formContent.Add folder_id_StringContent "folder_id"
		this.formContent.Add target_path_StringContent "target_path"
		this.formContent.Add root_type_StringContent "root_type"
		*/
	),
	fn jvalue_to_value _jvalue = 
	(
		_value = undefined 
		if _jvalue != undefined do 
		(
			_value = _jvalue.Value 
		)
		_value 
	),
	message , 
	success,
	video_share ,
	fn try_upload_data = 
	(
		if this.formContent == undefined do (
			format "this.formContent == undefined \n"
			return false
		)
		if this.uploadURl == undefined do (
			format "this.uploadURl == undefined \n"
			
			return false
		)
		try(
		local spm = dotNetClass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12

		--Request = (dotNetClass "System.Net.WebRequest").Create url
		handler = dotNetObject "System.Net.Http.HttpClientHandler"
		handler.UseProxy = false  -- 禁用代理
		
		httpClient = dotNetObject "System.Net.Http.HttpClient" handler

		-- 发送 POST 请求
		response = httpClient.PostAsync (this.uploadURl) (this.formContent)
		response.Wait()  -- 等待响应完成

		htmlStringTask = response.Result.Content.ReadAsStringAsync()
		htmlStringTask.Wait()

		_json = (dotNetObject "Newtonsoft.Json.Linq.JObject").parse (htmlStringTask.Result)
		this.success = this.jvalue_to_value (_json.GetValue "success") 
		this.message = this.jvalue_to_value (_json.GetValue "message")
		this.video_share = this.jvalue_to_value (_json.GetValue "video-share")
		format "%\n" ("上传结果 => " +  htmlStringTask.Result) 

		if (this.success as string) == "true" then (
			return true
		)else(
			return false
		)
		)catch(
			this.message = "try_upload_data 方法错误"
		)
		return false
		--format " % - % \n" _success _message 


		-- 检查响应状态码
		/* if response.Result.IsSuccessStatusCode then 
		(
			return true
			--this.show_message "上传完成！" 
		)else(
			return false
			--this.show_message "上传失败" 
		)  */
	),
	fn test_file_is_ok _path =
	(
		_is_ok = false 
		if _path != undefined do 
		(
			if doesFileExist _path do 
			(
				_size = getFileSize _path 
				if _size > 1 do 
				(
					_is_ok = true 
				)
			)
		)
		_is_ok
	),
	fn test_all_files_is_ok = 
	(
		_is_ok = true
		if not (this.test_file_is_ok (this.body_file)) do (_is_ok = false)
		if not (this.test_file_is_ok (this.preview_file)) do (_is_ok = false)
		if not (this.test_file_is_ok (this.thumbnail_file)) do (_is_ok = false)
		if _is_ok do 
		(
			this.body_ext = getFilenameType this.body_file
			this.preview_ext = getFilenameType this.preview_file
			this.thumbnail_ext = getFilenameType this.thumbnail_file
			this._fps = framerate
			this._start_frame = (animationRange.start.frame) as integer
			this._end_frame = (animationRange.end.frame) as integer
			this._frames = (this._end_frame) - (this._start_frame) + 1 
		)
		_is_ok 

	),
	fn try_delete_file _path = 
	(
		if doesFileExist _path do 
		(
			try (
				deleteFile _path
			) catch (
				format "删除失败 -> %\n" _path
			)
		)
	),
	fn try_delete_old_files = 
	(
		this.try_delete_file this.body_file
		this.try_delete_file this.preview_file
		this.try_delete_file this.thumbnail_file
		this.try_delete_file this.pictureBox_image
	)
)

struct NDAnimLibAppDragFile_struct 
(
	data_text , 
	file_obj , 
	img_obj ,
	folder_path ,
	_id ,
	_name  ,
	_parent_id  ,
	_file_extension  ,
	_s3Url ,
	_user ,
	_mp4url,
	_tags = "",
	_start_frame = 0,
	_end_frame = 1,
	_fps = framerate ,
	_dcc_name,
	session_id , 
	rcUserId ,
	server_url ,
	body_file ,
	thumbnail_file ,
	video_share ,
	fn jvalue_to_value _jvalue = 
	(
		_value = undefined 
		if _jvalue != undefined do 
		(
			_value = _jvalue.Value 
		)
		_value 
	),
	fn get_values = 
	(
		this.img_obj = (this.file_obj.GetValue "img")
		
		this.folder_path = this.jvalue_to_value (this.file_obj.GetValue "pathname")
		
		this.session_id = this.jvalue_to_value (this.file_obj.GetValue "session_id")
		this.video_share = this.jvalue_to_value (this.file_obj.GetValue "video_share")


		local rcUserId_value = this.jvalue_to_value (this.file_obj.GetValue "rcUserId")
		if rcUserId_value != undefined do 
		(
			this.rcUserId = (rcUserId_value as integer)
		)

		this._name = this.jvalue_to_value ((this.img_obj).GetValue "name")
		
		this._parent_id = this.jvalue_to_value ((this.img_obj).GetValue "parent_id")
		
		local _id = this.jvalue_to_value ((this.img_obj).GetValue "id")
		if _id != undefined do 
		(
			this._id = (_id as integer)
		)
		this._file_extension = this.jvalue_to_value ((this.img_obj).GetValue "file_extension")
		
		this._user = this.jvalue_to_value ((this.img_obj).GetValue "user")
		
		this._s3Url = this.jvalue_to_value ((this.img_obj).GetValue "s3Url")
		
		this._mp4url = this.jvalue_to_value ((this.img_obj).GetValue "mp4Url")
		
		local _tags_token = this.file_obj.GetValue "tags"
		if _tags_token != undefined do (
			local _tags_text = ""
			local _token_type = (_tags_token.GetType()).ToString()
			if _token_type == "Newtonsoft.Json.Linq.JArray" then (
				local _count = _tags_token.Count
				for i = 0 to (_count - 1) do (
					local _item = _tags_token.Item[i]
					local _value = this.jvalue_to_value _item
					if _value == undefined do (
						_value = _item.ToString()
					)
					if _value != undefined do (
						if _tags_text.count > 0 then (
							_tags_text += ", "
						)
						_tags_text += (_value as string)
					)
				)
			)else(
				local _value = this.jvalue_to_value _tags_token
				if _value == undefined do (
					_value = _tags_token.ToString()
				)
				if _value != undefined do (
					_tags_text = _value as string
				)
			)
			this._tags = _tags_text
		)

		local _user_info = ((this.img_obj).GetValue "user_info")
		if _user_info != undefined and _user_info.Value != undefined do (
			local _start_frame = this.jvalue_to_value (_user_info.GetValue "start")
			if _start_frame != undefined do 
			(
				this._start_frame = (_start_frame as integer)
			)

			local _end_frame = this.jvalue_to_value (_user_info.GetValue "end")
			if _end_frame != undefined do 
			(
				this._end_frame = (_end_frame  as integer)
			)

			local _fps = this.jvalue_to_value (_user_info.GetValue "fps")
			if _fps != undefined do 
			(
				this._fps = (_fps  as integer)
			)
			this._dcc_name  = this.jvalue_to_value (_user_info.GetValue "dcc_name")
			
		)
		/* prop_name = getPropNames this 
		for i in prop_name do 
		(
			_name = i as string 
			if _name[1] == "_" do 
			(
				--_value = getProperty this i  
				
				_value_name = substring _name 2 (_name.count - 1)
				--format "% -> \n" _value_name 
				_value = ((this.img_obj).GetValue _value_name)
				if _value != undefined do 
				(
					format "	% -> % \n" _name _value.value
					setProperty this _name (_value.value)
				)
			)
		) */
	),

	fn get_temp_path_folder = 
	(
		--用父级文件夹的ID创建临时文件夹
		thefolder = (getDir #animations)+"\\"+ (this._parent_id as string) 
		try(makeDir thefolder)catch()
		thefolder
		
	),
	fn download_thumbnail = 
	(
		
		thefile = this.get_temp_path_folder() + "\\" + (this._id as string) + ".mp4"
		this.try_delete_file thefile

		local spm = dotNetClass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12

		local donw_DN_object = (dotNetObject "System.Net.WebClient")
		donw_DN_object.Proxy = undefined

		try(
			donw_DN_object.DownloadFile this._mp4url thefile 
		)catch(
			format "无法下载 download_thumbnail -> %" this._mp4url 
			return false 
		)
		if not donw_DN_object.IsBusy and (doesFileExist thefile) then 
		(
			format "下载完成 !\n" 
			this.thumbnail_file = thefile
			return true
		)else(
			messageBox "下载失败,%\n" this._s3Url
		)
		return false
	),
	fn try_delete_file _path = 
	(
		if doesFileExist _path do 
		(
			try (
				deleteFile _path
			) catch (
				format "删除失败 -> %\n" _path
			)
		)
	),
	fn download_file = 
	(
		thefile = this.get_temp_path_folder() + "\\" + this._name 
		
		this.try_delete_file thefile

		theUri = this.server_url + "resource_center/download_stream?resource_id=" + (this._id  as string)+ "&user_id="+this._user

		local spm = dotNetClass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12

		local donw_DN_object = (dotNetObject "System.Net.WebClient")
		donw_DN_object.Proxy = undefined

		try(
			format "download_file: % => % \n" theUri thefile 
			donw_DN_object.DownloadFile theUri thefile 
		)catch(
			format "无法下载 % -> % \n" theUri thefile
			return false 
		)
		if not donw_DN_object.IsBusy and (doesFileExist thefile) then 
		(
			format "下载完成 !\n" 
			this.body_file = thefile
			
			return true
			--
		)else(
			
		)	
		return false
		
	)
	
)
struct NDAnimLib_group_srtuct 
(

	fn test_client_environment = 
	(
		_msg = StringStream "" 
		index = 0 
		test_dll = (getdir #maxroot ) + @"bin\assemblies\Newtonsoft.Json.dll"
		if not doesFileExist test_dll do 
		(
			format "缺少：%\n" test_dll to:_msg 
			index += 1
		)
		test_dll = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\Screen3dsMaxForm.dll"
		if not doesFileExist test_dll do 
		(
			format "缺少：%\n" test_dll to:_msg 
			index += 1
		)
		test_exe = this.get_Env_ffmpeg_path()
		if test_exe == undefined do 
		(
			format "缺少：FFmpeg\n" to:_msg 
			index += 1

		) 
		if index > 0 do 
		(
			format "!!!!\n" to:_msg
			_msg = _msg as string 
			messageBox _msg title:"未安装完整"
			format "%\n" _msg 
		)
	),
	fn test_dragdrop_data _data = 
	(
		is_ok1 = findString _data "{\"img\":{\""
		if is_ok1 == undefined then 
		(
			--is_ok2 = findString _data "{\"img\":{\"RESTYPE\":\"30001\""
			return false
		)
		return true 

	),
	--测试环境 http://127.0.0.1:8020/
	--正式环境 http://anim.nd.com.cn/api/
	prod_url = "http://anim.nd.com.cn/api/",
	test_url = "http://127.0.0.1:8020/",

	server_url ,
	--server_url = "http://anim.nd.com.cn/api/",
	fn set_server_url =
	(
		if this.get_env_test_or_production() == "test" then 
		(
			this.server_url = this.test_url
		)else(
			this.server_url =  this.prod_url
		)
		--this.server_url =  this.prod_url
	),
	motion_folder_id,
	motion_pose_folder_id,
	motion_hand_pose_folder_id ,
	motion_folder_path = @"Biped动作库\天晴动作",
	motion_pose_folder = @"POSE库\Biped姿势",
	motion_hand_pose_path =@"POSE库\Biped手势",
	--获取服务给的上传时的库根目录id
	fn set_public_motion_folder_id =
	(
	    local spm = dotNetClass "System.Net.ServicePointManager"
	    spm.SecurityProtocol = spm.SecurityProtocol.Tls12

	    local web_down = (dotNetObject "System.Net.WebClient")
	    web_down.Proxy = undefined
	    try(
			GetString = web_down.DownloadData (this.server_url + "get_public_motion_folder_id")
		    GetString = this.Encoding.GetString GetString
		    --format "get_public_motion_folder_id -> \n %\n" GetString

		    _json = (dotNetObject "Newtonsoft.Json.Linq.JObject").parse GetString
	    	
		    motion_folder_path = this.jvalue_to_value (_json.GetValue "motion_path")
		    motion_pose_folder = this.jvalue_to_value (_json.GetValue "motion_pose_path")
		    motion_hand_pose_path = this.jvalue_to_value (_json.GetValue "hand_pose_path")

		    format "Bip-LibPath : % ,% ,% \n" motion_folder_path motion_pose_folder motion_hand_pose_path

	    	motion_folder_id = this.jvalue_to_value (_json.GetValue "motion_id") 
			motion_pose_folder_id = this.jvalue_to_value (_json.GetValue "motion_pose_id") 
			motion_hand_pose_folder_id = this.jvalue_to_value (_json.GetValue "hand_pose_id")

			if motion_folder_id != undefined do (
				this.motion_folder_id = motion_folder_id as integer
			) 
			if motion_pose_folder_id != undefined do 
			(
				this.motion_pose_folder_id = motion_pose_folder_id as integer
			)
			if motion_hand_pose_folder_id != undefined do 
			(
				this.motion_hand_pose_folder_id = motion_hand_pose_folder_id as integer
			)


			--format "% , % \n" motion_folder_id motion_pose_folder_id
	   		return #(this.motion_folder_id , this.motion_pose_folder_id,this.motion_hand_pose_folder_id)
	    )catch(
	    	return undefined 
	    )
	),
	fn replace_string int_str _rep _new = 
	(
		result = dotNetObject "System.String" int_str
		result = dotNetObject "System.String" (result.Trim #("/",@"\"))
		result = result.Replace _rep _new
		result
	),
	fn set_new_motion_folder_path _path =
	(
		_new_path = _path 
		_match = filterString this.motion_folder_path "\\"
		for i in _match do 
		(
			_new_path = this.replace_string _new_path i ""
		)
		_new_path
	),
	fn uploadURl = 
	(
		return (this.server_url + "resource_center/upload_3dsMax_Biped")
	),
	fn jvalue_to_value _jvalue = 
	(
		_value = undefined 
		if _jvalue != undefined do 
		(
			_value = _jvalue.Value 
		)
		_value 
	),
	ffmpeg_path , 
	--------------------------------------------------
	asset_Type = 1 ,
	asset_current_directory = "", -- bip动画 路径
	asset_tags = "", --bip 标签

	asset_directory_pose = "", -- 全身姿势 路径
	asset_tags_pose = "", --全身姿势 标签

	asset_directory_posture = "", -- 局部姿势 路径
	asset_tags_posture = "", --局部姿势 标签

	--------------------------------------------------
	is_previews_maxfilepath = false, 
	_video_or_png = true,
	fn video_or_png = 
	(
		if this.asset_Type > 1 then(
			return false 
		)else(
			return true
		)
	),
	--------------------------------------------------
	form_w = 512,
	form_h = 512,
	form_location_x = 1024,
	form_location_y = 440,

	--------------------------------------------------

	root_path = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\",
	config = this.root_path + "NDAnimLibConfig.ini" ,
	dllfile = this.root_path + "Screen3dsMaxForm.dll",
	--dllfile = @"G:\Github\ResizeBorderlessForm\DragBorderlessForm\bin\Debug\Screen3dsMaxForm.dll",

	fn pingbaidu =
	(
		newping = dotnetobject "System.Net.NetworkInformation.Ping"
		replys = newping.Send("www.baidu.com")
		if replys.status == replys.status.Success then
		(
			format "OK:%\n" "网络连接正常"
			--set_ScriptTree_UpDate_TooLsText "网络连接正常"
			return true
		)else (
			--set_ScriptTree_UpDate_TooLsText "无连接网络"
			format "OK:%\n" "无连接网络";
			return false
		)
	),
	log_text = StringStream "",
	fn to_log _text = 
	(
		format "%\n" _text to:this.log_text
		format "NDAnimLib log -> %\n" _text 
	),
	fn message _text = 
	(
		format "message -> %\n" _text  
		messageBox (_text+"...\n") title:"NDAnimLib"
	),
	fn get_ip4 = 
	(
		hostName = (dotNetClass "System.net.dns").GetHostName()
		hostEntry = (dotNetClass "System.net.dns").GetHostEntry(hostName)
		hostEntry.AddressList[2].toString()
	),
	fn test_remote_server = 
	(
		if this.server_url.count < 2 do (return false)

		try(
			down_txt = (dotNetObject "System.Net.WebClient")
			down_txt.Proxy = undefined
			down_str = down_txt.DownloadString (this.server_url + "ping")
			if down_str == "1" then (return true)else(return false)
		)catch(
			return false
		)
	),
	fn get_Env_ffmpeg_path = 
	(
		_path = undefined
		--dotNet.loadAssembly "System"   
		local env = dotNetClass "system.Environment"
		env_path = env.GetEnvironmentVariable "Path"
		env_path = filterString env_path ";"
		for i in env_path do 
		(
			index = findString i "ffmpeg"
			if index != undefined do 
			(
				_path = i 
				exit()
			)
		)
		_path
	),
	fn get_env_test_or_production = 
	(
		local env = dotNetClass "system.Environment"
		env_value = env.GetEnvironmentVariable "ENVIRONMENT"
		env_value 
	),
	fn set_config key_string key = 
	(
		setINISetting this.config "NDAnimLib" key_string (key as string) 
	),
	fn get_config key_string key = 
	(
		temp_value = getINISetting this.config "NDAnimLib" key_string
		if temp_value.count > 0 then
		(
			*key = execute temp_value 
		)
	),
	fn get_config_string key_string key = 
	(
		temp_value = getINISetting this.config "NDAnimLib" key_string
		*key = temp_value  
	), 
	fn save_config = 
	(
		this.set_config "asset_Type" this.asset_Type 
		this.set_config "asset_current_directory" this.asset_current_directory
		this.set_config "asset_tags" this.asset_tags
		
		this.set_config "asset_directory_pose" this.asset_directory_pose
		this.set_config "asset_tags_pose" this.asset_tags_pose
		
		this.set_config "asset_directory_posture" this.asset_directory_posture
		this.set_config "asset_tags_posture" this.asset_tags_posture

		this.set_config "server_url" this.server_url
	),
	fn open_config =
	(
		if doesFileExist this.config do 
		(
			this.get_config "asset_Type" &this.asset_Type
			this.get_config_string "asset_current_directory" &this.asset_current_directory
			this.get_config_string "asset_tags" &this.asset_tags
			
			this.get_config_string "asset_directory_pose" &this.asset_directory_pose
			this.get_config_string "asset_tags_pose" &this.asset_tags_pose

			this.get_config_string "asset_directory_posture" &this.asset_directory_posture
			this.get_config_string "asset_tags_posture" &this.asset_tags_posture

			--this.get_config_string "server_url" &this.server_url

		)
	),
	spacer_ = #(".","_","#","@","-"),
	fn set_name str_name = --在文件名中检查分隔符
	(
		find_spacer = findString str_name this.spacer_[3] --查找分隔符
		if find_spacer != undefined then
		(
			-- 如果分隔符模式符合
			if str_name[find_spacer - 1] == this.spacer_[2] then
			(
				new_name = substring str_name 1 (find_spacer - 2)
				return new_name
			)
			else
			(
				new_name = substring str_name 1 (find_spacer - 1)
				return new_name
			)
		)
		else(return str_name)
	),
	fn getSelectBiped = 
	(
		if selection.count > 0 then 
		(
			select_bip = selection[1]
			if classOf select_bip == Biped_Object do
			(
				_bip = select_bip.controller.rootNode
				
				return _bip
			)
		)
		return undefined
	),
	fn getSelectBipeds = 
	(
		_bips = for i in selection where (classof i == Biped_Object )collect i 
		_bips 
	),
	fn switchbody_extsion path new_ext = 
	(
		_new = (getFilenamePath path) + (getFilenameFile path)+new_ext
		_new
	),
	fn close_event = 
	(
		this.save_config()
		--print("close_event")
	),
	fn open_event = 
	(
		this.open_config()

		this.set_server_url()
		
		

		--print("open_event")

	),
	fn start_event = 
	(
		this.set_public_motion_folder_id()
	),
	fn dcc_name =
	(
		_name = "3dsMax"
		_name +="_" + (MaxVersion())[1] as string
		_name
	),
	Encoding = (dotNetClass "System.Text.Encoding").UTF8,
	
	fn try_delete_file _path = 
	(
		if doesFileExist _path do 
		(
			try (
				deleteFile _path
			) catch (
				format "删除失败 -> %\n" _path
			)
		)
	),
	fn ffmpeg_to_jpg infile outfile =
	(
		this.try_delete_file outfile

		args = "-i"+ " \""+ infile + "\""+ " -vf scale=250:-2 -frames:v 1 -y " + "\""+ outfile + "\""
		
		format "%\n" args 

		proc = dotnetobject "system.diagnostics.process"
		proc.StartInfo.FileName = this.ffmpeg_path
		proc.StartInfo.Arguments = args
		proc.StartInfo.RedirectStandardOutput = true
		proc.EnableRaisingEvents = true
		proc.StartInfo.UseShellExecute = false
		proc.StartInfo.CreateNoWindow = true
		proc.StartInfo.WindowStyle = (dotNetClass "System.Diagnostics.ProcessWindowStyle").Hidden
		--proc.StartInfo.RedirectStandardOutput = true;

		--dotNet.addEventHandler proc "Exited" jAuto_anim.ffmpeg_ok
		
		proc.Start()
		proc.WaitForExit()
		if proc.HasExited do (
			proc.Close()
			
		)

	),
	fn set_pictureBox_image pictureBox image_path = 
	(

		jpg_image_path = (getFilenamepath image_path ) + (getFilenameFile image_path) + ".jpg"

		image_type = getFilenameType image_path
		
		format "%-%\n" image_path jpg_image_path
		if image_type == ".webp" or image_type == ".mp4"  or image_type == ".png" then 
		(
			this.ffmpeg_to_jpg image_path jpg_image_path
		)
		if image_type == ".jpg" then (
			jpg_image_path = image_path
		)
		if doesFileExist jpg_image_path then 
		(
			if getFileSize jpg_image_path > 1 do 
			(
				local fs = dotNetObject "System.IO.FileStream" jpg_image_path (dotNetClass "System.IO.FileMode").Open (dotNetClass "System.IO.FileAccess").Read
   				local img = (dotNetClass "System.Drawing.Image").FromStream fs
   				fs.Close()  -- 读完立即关闭
   				pictureBox.Image = img
   				pictureBox.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").Zoom
   				
   				--这种会持续占用文件，如果有覆盖图片需求就会被报错
				--pictureBox.Image = (DotnetClass "System.Drawing.Image").FromFile jpg_image_path
				--pictureBox.SizeMode = (DotnetClass "System.Windows.Forms.PictureBoxSizeMode").Zoom
				return true
			)
		)else(
			format "ffmpeg转化失败 ： % -> %\n" image_path jpg_image_path
			return false
		)
		format "不支持的格式-> %\n" image_path
	),
	fn get_colortheme_is_dark = 
	(
		iGlobal = (dotnetClass "Autodesk.Max.GlobalInterface").Instance
		if (iGlobal.ColorManager.AppFrameColorTheme.ToString()) == "LightTheme" then 
		(
			return false 
		)else(
			return true
		)
	),
WebRoll = rollout AnimLibTestRoll "导入 | 从服务器下载资源" width:275 height:210
(
	--label lbl_remote "" pos:[15,5]
	--HyperLink lbl_01 this.server_url address:this.server_url color:red hoverColor:(color 0 255 255)  pos:[65,5]
	HyperLink hyplink_resource_file "http://anim.nd.com.cn/SVN" address:"http://anim.nd.com.cn/SVN" width:250 color:red hoverColor:(color 0 255 255) align:#center
	--dotNetControl textBox_tags "System.Windows.Forms.RichTextBox" width:250 Height:24 offset:[-3,0] tooltip:"右键重新加载资源"

   	group "页面资源拖拽进来" (
		--dotNetControl textBox_model "System.Windows.Forms.textBox" width:256 Height:120 offset:[-3,0]
		dotNetControl textBox_model "System.Windows.Forms.PictureBox" width:170 Height:72 offset:[-3,0] tooltip:"右键重新加载资源"
		--dotNetControl textBox_model "System.Windows.Forms.Button" width:220 Height:72 offset:[-3,0]
		label lab_start_f "起始帧：" pos:[190 ,50]
		label lab_start_v "0"  pos:[193 ,65]
		
		label lab_end_f "结束帧：" pos:[190 ,85] color:red
		label lab_end_v "0"  pos:[193 ,100]

		checkbutton che_hor "Hor" checked:true width:24 height:24 pos:[235 ,45] tooltip:"biped 加载pose的设置" images:#("bip_tracksel_i.bmp",undefined, 10, 1, 1, 2, 2,true)
		checkbutton che_ver "Ver" checked:true width:24 height:24 pos:[235 ,70] tooltip:"biped 加载pose的设置" images:#("bip_tracksel_i.bmp",undefined, 10, 3, 3, 4, 4,true)
		checkbutton che_trn "turn" checked:true width:24 height:24 pos:[235 ,95] tooltip:"biped 加载pose的设置" images:#("bip_tracksel_i.bmp",undefined, 10, 5, 5,6, 6,true)
		
		button btn_reload_file "Load" width:24 height:24 tooltip:"重新加载 资源" align:#left enabled:false images:#("bip_general_i.bmp",undefined, 30, 5, 5, 6, 6,true)
		checkbox che_FileStruct "匹配体型" tooltip:"使用bip文件中的体型设置" across:3
		checkbox che_auto_load "自动加载" tooltip:"下载成功时自动设置新动画或者POSE"
		checkbox che_auto_timerange "设置范围" tooltip:"设置时间轴范围"

		--button che_turn "" images:#("Cameras",2)
	)
	label lab1 "先在场景中选中biped骨骼" color:red
	local this = undefined ,thefile = undefined
	local resource_file = undefined
	local toolTip_model = undefined


    fn setup_list =
	(
		textBox_model.allowdrop = True
		if this != undefined do (
			if this.get_colortheme_is_dark() then (
				textBox_model.BackColor = textBox_model.BackColor.fromargb 100 100 100
				--textBox_tags.BackColor = textBox_model.BackColor
				--textBox_tags.ForeColor = (dotNetClass "System.Drawing.Color").White
			)else(
				textBox_model.BackColor = textBox_model.BackColor.fromargb 186 186 186
				--textBox_tags.BackColor = textBox_model.BackColor
				--textBox_tags.ForeColor = (dotNetClass "System.Drawing.Color").Black
			)
		)

		if toolTip_model == undefined do (
			toolTip_model = dotNetObject "System.Windows.Forms.ToolTip"
			toolTip_model.AutoPopDelay = 5000
			toolTip_model.InitialDelay = 200
			toolTip_model.ReshowDelay = 200
		)
		toolTip_model.SetToolTip textBox_model "右键重新加载资源"
		--toolTip_model.SetToolTip textBox_tags "资源标签"

		/* textBox_tags.ReadOnly = true
		textBox_tags.Multiline = false
		textBox_tags.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").None
		textBox_tags.ScrollBars = (dotNetClass "System.Windows.Forms.RichTextBoxScrollBars").None
		textBox_tags.DetectUrls = false
		textBox_tags.WordWrap = false
		textBox_tags.ShortcutsEnabled = false
		textBox_tags.Text = "" */


		/* textBox_model.MultiLine = true
		textBox_model.ReadOnly = true
		textBox_model.WordWrap = true */
	)
	fn set_pictureBox_image image_path = 
	(
		this.set_pictureBox_image textBox_model image_path
	)
	fn LoadAnimSelectBiped file_obj  = 
	(
		select_bip = this.getSelectBiped()
		if isValidObj select_bip then 
		(
			
			select_bip.controller.figuremode = false
			select_bip.controller.enableSubAnims = true
			undo "lxxx" on (
				format "load bip -> %\n" file_obj.body_file
				if che_FileStruct.state then (
					biped.loadBipFile select_bip.controller (file_obj.body_file) #noRedraw #matchFileStruct #zeroHgt #retargetHeight #retargetLimbSizes
				)else(
					biped.loadBipFile select_bip.controller (file_obj.body_file) #noRedraw #zeroHgt #retargetHeight #retargetLimbSizes
				)
				if che_auto_timerange.state do 
				(
					animationRange = interval file_obj._start_frame file_obj._end_frame
				)
			)
		)else(
			messageBox "选中Biped骨骼之后再试试...\n" 
		)
	)
	fn LoadPoseSelectBiped file_obj = 
	(
		select_bip = this.getSelectBiped()
		if isValidObj select_bip then 
		(
			select_bip.controller.figuremode = false
			select_bip.controller.enableSubAnims = true

			biped.loadCopyPasteFile select_bip.controller (file_obj.body_file)
			_numCopy = biped.numCopyCollections select_bip.controller
			_copyColl = biped.getCopyCollection select_bip.controller _numCopy
			
			_posture_num = biped.numCopies select_bip.controller #posture
			_pose_num = biped.numCopies select_bip.controller #pose
			if _posture_num > 0 do (
				_copies = getCopy _copyColl #posture _posture_num
				undo "xx1" on(
					animate on ( 
						biped.pasteBipPosture select_bip.controller _copies false #pstdefault true true true true	
					)
				)
				format "Posture -> %\n" _copies.name 
			)
			if _pose_num > 0 do (
				_copies = getCopy _copyColl #pose _pose_num
				_index=#(1,2,5,6)
				undo "xx2" on
				(
					--FK 
					for i in _index do
					(
						_nb = biped.getNode select_bip.controller i
						if isValidObj _nb do
						(
							biped.setFreeKey _nb
						)
					)
					animate on ( 
					biped.pasteBipPose select_bip.controller _copies false #pstdefault che_hor.state che_ver.state che_trn.state false 
					)
				)
				format "pose -> %\n" _copies.name 

			)
			--_numCopy = biped.numCopyCollections select_bip.controller
			if _numCopy > 0 do (
				--biped.deleteCopyCollection select_bip.controller _numCopy
			)

		)
	)
	fn GetFileName theUri = 
	(
		n = getFilenameFile theUri --不带后缀的文件名
		m = getFilenameType theUri --带参数的后缀名
		m = filterString m "?&"
		--thefile = (getDir #temp)+"\\" + n + (m[1])
		thefile = (getDir #animations)+"\\" + n + (m[1])

		thefile
	)
	fn reload_file = 
	(
		if resource_file != undefined and  doesFileExist resource_file.body_file do 
		(
			_ok = true --queryBox (resource_file.body_file) title:"是否重新加载此资源?"
			if _ok do 
			(
				if (resource_file._file_extension) == ".cpy" do 
				(
					LoadPoseSelectBiped resource_file
				)
				if (resource_file._file_extension) == ".bip" do 
				(
					--format "load LoadAnimSelectBiped resource_file \n"
					LoadAnimSelectBiped resource_file
				)
			)
		)
	)
	on btn_reload_file pressed do 
	(
		reload_file()

	)
	/* on btn_load_file pressed do 
	(
		open_type = ".bip"
		temp_path = (getDir #animations)
		select_bip = this.getSelectBiped()
		if not isValidNode select_bip do (
			messageBox "请选中 Biped 骨骼后再试...\n"
			return false
		)

		if resource_file != undefined and doesFileExist resource_file.body_file do 
		(
			temp_path = (getFilenamePath resource_file.body_file)
			open_type = resource_file._file_extension
		)

		if open_type == ".bip" then 
		(
			biped.loadBipFileDlg select_bip.controller filename:temp_path
		)else(

		)
	) */
	on textBox_model Click arg do 
	(
		--print(arg)
	) 

	--接受拖拽区域的右键功能
	on textBox_model MouseDown arg do 
	(
		if arg.Button == arg.Button.Right do 
		(
			reload_file()
			--print("Right")
		)
	)
   	on textBox_model DragEnter sender arg do
	(
		arg.Effect = arg.AllowedEffect
	)
	on textBox_model DragOver sender EventArgs do
	(
		--showMethods EventArgs.data
		--EventArgs.Effect = if EventArgs.data.ContainsFileDropList() then (EventArgs.Effect.Move)
		EventArgs.Effect = if EventArgs.data.ContainsText() then (EventArgs.Effect.Move)

		else (EventArgs.Effect.None)
	)

	--接受资源的拖拽
	on textBox_model DragDrop sender EventArgs do
	(
		--showMethods EventArgs.data
		local data = EventArgs.data.GetText()
		local files =#()
		--ormat "%\n" data 
		if (this.test_dragdrop_data data ) then 
		(
			_temp_obj = undefined
			try(
				_temp_obj = (dotNetObject "Newtonsoft.Json.Linq.JObject").parse data
			)catch(
				_temp_obj = undefined
				messageBox "2 拖拽的类型不支持!!!!\n" 
			)
			if _temp_obj != undefined do 
			(
				resource_file = NDAnimLibAppDragFile_struct()
				resource_file.server_url = this.server_url
				resource_file.file_obj = _temp_obj
				resource_file.get_values()
				
				if (resource_file.download_file()) then (

					hyplink_resource_file.text = resource_file._name
					hyplink_resource_file.address = resource_file.video_share

					lab_start_v.text = resource_file._start_frame as string
					lab_end_v.text = resource_file._end_frame as string
					--textBox_tags.Text = resource_file._tags

					
					btn_reload_file.enabled = true

					if (resource_file.download_thumbnail()) then 
					(
						set_pictureBox_image resource_file.thumbnail_file
					)
					
					if che_auto_load.state do 
					(
						if (resource_file._file_extension) == ".cpy" do 
						(
							LoadPoseSelectBiped (resource_file)
						)
						if (resource_file._file_extension) == ".bip" do 
						(
							LoadAnimSelectBiped (resource_file)
						)
					)
				)else(
					hyplink_resource_file.text = ""
					hyplink_resource_file.address = "http://anim.nd.com.cn/SVN"

					lab_start_v.text = ""
					lab_end_v.text = ""
					--textBox_tags.Text = ""
					btn_reload_file.enabled = false

				) 
			)
		)else(
			messageBox "1 拖拽的类型不支持!!!!\n" 
		)
		--format "%\n" data 
	)
	fn opendo = 
	(
		setup_list()
	)
	on AnimLibTestRoll open do 
	(
		
	)
),


AddNew = rollout AnimLibTestAddNew "入库 | 向服务器上传资源" width:275 height:210
(
	group ""(
		--radiobuttons rad_anim_type "" labels:#("动画 bip","姿势 pose","手势 posture")
		checkbutton rad_anim_type_bip "动画 bip" width:79 height:20 across:3 tooltip:""
		checkbutton rad_anim_type_pose "姿势 pose" width:79 height:20
		checkbutton rad_anim_type_posture "手势 posture" width:79 height:20
		
	)
	group "" (
	label lab_path "" pos:[10,70] width: 220--align:#left 
	editText edit_path "" fieldWidth:250 align:#left offset:[-8,0]
    -- Rollout body.
    label lab_name "资源名:" pos:[10,110]
	editText edit_name "" fieldWidth:220 align:#left pos:[5,130] across:2 
	button btn_reset "R" width:20 height:20 tooltip:"左键使用max文件名|右键随机名" align:#right 
	)
	label lab_tgs "" pos:[5,160]
	
	dotNetControl pictureBox1 "System.Windows.Forms.PictureBox" width:250 Height:90 pos:[5,160]
	editText textBox_tags "标签:" fieldWidth:225 pos:[5,260]
	--dotNetControl textBox_tags "System.Windows.Forms.textBox" width:160 Height:70 pos:[5,180]
    button btn_recording "创建预览视频" Width:240 height:35 align:#center --pos:[5,280]
    --button btn_update "上传" width:80 height:35 align:#right pos:[90,280] enabled:false tooltip:"右键重试"

    label lab_help ""
	HyperLink lbl_resource_url "" address:"" color:red hoverColor:(color 0 255 255) pos:[5,335]


    local ffmpeg_path = undefined ,previewpath = ""
    local new_mp4 = undefined,new_gif= undefined,new_bip = undefined, new_png = undefined,new_cpy = undefined
    local filelist=#()
	local Encoding = (dotNetClass "System.Text.Encoding").UTF8
	local theZip = undefined ,formContent = undefined ,response = undefined,file_size = 0

    local this = undefined 
    local fecorder_form = undefined
    
    local bip_data = undefined ,pose_data = undefined,posture_data = undefined 
    local update_target_folder_id = undefined

    fn setup_list =
	(

		--pictureBox1.Image = (DotnetClass "System.Drawing.Image").FromFile New_Image
		pictureBox1.SizeMode = (DotnetClass "System.Windows.Forms.PictureBoxSizeMode").Zoom
		--pictureBox1.BackColor = (dotNetClass "System.Drawing.Color").Green
		--if colorMan.colorTheme == #dark then ( --高版本才有的方法
		if this.get_colortheme_is_dark() then (
			pictureBox1.BackColor = pictureBox1.BackColor.fromargb 81 81 81
		)else(
			pictureBox1.BackColor = pictureBox1.BackColor.fromargb 186 186 186
		)
		--GlobalInterface.Instance;
		--global.ColorManager.AppFrameColorTheme
		--textBox_tags.allowdrop = True
		--textBox_tags.MultiLine = true
		--textBox_tags.ReadOnly = true
		--textBox_tags.WordWrap = true
	)
	fn get_update_target_folder_id = 
	(
		if this.asset_Type == 1 do (
			lab_path.text = this.motion_folder_path
			update_target_folder_id = this.motion_folder_id
		)
		if this.asset_Type == 2 do (
			lab_path.text = this.motion_pose_folder
			update_target_folder_id = this.motion_pose_folder_id
		)
		if this.asset_Type == 3 do (
			lab_path.text = this.motion_hand_pose_path
			update_target_folder_id = this.motion_hand_pose_folder_id
		)
		update_target_folder_id
	)
	fn set_pictureBox_image image_path = 
	(
		this.set_pictureBox_image pictureBox1 image_path
	)
	fn get_id_name = 
	(
		id_name = genClassID returnValue:true
		filename = (id_name[1]) as string
		filename
	)
	fn get_maxfilepath = 
	(
		if this.is_previews_maxfilepath and maxfilepath.count > 1 then 
		(
			filepath = maxfilepath
		)else(
			filepath = (GetDir #preview) + "\\"
		)
		filepath
	)
	fn get_maxfilename = 
	(
		if edit_name.text.count < 1 then(
			filename = this.set_name (getFilenameFile maxfilename)
		)else(
			filename = this.set_name edit_name.text
		)
		if filename.count < 2 then
		(
			filename = get_id_name()
		)
		filename
	)  
	fn get_name = 
	(
		filename = get_maxfilename()
		edit_name.text = filename
		filepath = get_maxfilepath()
		previewpath = filepath + filename + ".avi" 

	)
	fn get_save_path = 
	(
		
		filename = get_maxfilename()
		filepath = get_maxfilepath()

		previewpath = filepath + filename + ".avi" 

		edit_name.text = getFilenameFile previewpath
	)
	fn save_bip_anim _bip bip_file = 
	(
		rep = false 
		if isValidObj _bip do 
		(
			rep = biped.saveBipfile _bip.controller bip_file
			format "saveBipfile -> % => % -> % \n" bip_file _bip.name rep
		)
		rep
	)
	fn save_bip_pose _bip cpy_file = 
	(
		_biplist = this.getSelectBipeds()
		--_bip = this.getSelectBiped()
		_name = get_id_name()
		

		_copycoll = biped.createCopyCollection _bip.controller _name
		if this.asset_Type ==2 do (
			--全身的pose
			_copyposture = biped.copyBipPose _bip.controller _copycoll #snapAuto
		)
		if this.asset_Type ==3 do (
			--选中骨骼的姿势

			_copyposture = biped.copybipposture _bip.controller _copycoll _biplist #snapAuto
		)
		biped.saveCopyPasteFile _bip.controller cpy_file
		biped.deleteCopyCollection _bip.controller (biped.numCopyCollections _bip.controller)
		

		clearSelection()
		cpy_file
		
	)
	fn clear_show_data_state = 
	(
		lbl_resource_url.address = ""
		lbl_resource_url.text = ""
		lab_help.text = ""
	)
	fn set_show_data_state data_obj = 
	(
		if data_obj != undefined then (
			lbl_resource_url.address = data_obj.video_share
			lbl_resource_url.text = data_obj.video_share
			--messageBox (bip_data.message) title:"上传完成"
			--btn_update.enabled = false
			lab_help.text = "上传完成,下方是资源链接"
		)else(
			lbl_resource_url.address = ""
			lbl_resource_url.text = ""
			messageBox (bip_data.message) title:"上传失败"
			lab_help.text = "上传失败"
		)
	)
	
	fn update_png = 
	(
		if pose_data != undefined and doesFileExist pose_data.preview_file then 
		(
			
			if not (pose_data.test_file_is_ok (pose_data.preview_file)) do (
				messageBox "预览截图失败！！！" title:"请重新截图"
				return false
			)
			if pose_data.test_all_files_is_ok() then 
			(
				if (pose_data.new_form_conten()) then (
					pose_data.new_prop_data()
					if (pose_data.try_upload_data()) then(
						set_show_data_state pose_data
						
					)else(
						
						set_show_data_state undefined
					)
				)
			)else(

			)

			
		)else(
			messageBox "预览视频没有录制成功"
		)
		--btn_update.enabled = false

	)
	fn update_mp4 = 
	(
		if bip_data.preview_file != undefined and doesFileExist bip_data.preview_file then
		(
			if not (bip_data.test_file_is_ok (bip_data.preview_file)) then (
				messageBox "预览视频录制失败！！！" title:"请重新录制"
				return false
			)

			if bip_data.test_all_files_is_ok() then  
			(
				if (bip_data.new_form_conten()) then(

					bip_data.new_prop_data()
					
					
					if (bip_data.try_upload_data()) then (
						set_show_data_state bip_data
						
					)else(
						
						set_show_data_state undefined
					) 

				)else(

					--btn_update.enabled = false
				)

			)else(
				--btn_update.enabled = false
				messageBox "资源收集失败，无法上传...\n"
			)

		)else(
			--btn_update.enabled = false 
			messageBox "预览视频没有录制成功"
		)
	)
	fn event_ok_exit s e =
	(
		try(
			this.form_w = s.width
			this.form_h = s.height
			this.form_location_x = s.Location.X
			this.form_location_y = s.Location.Y

		)catch(
			this.form_w = 512
			this.form_h = 512
			this.form_location_x = 1024
			this.form_location_y = 440
		)
		if this.asset_Type == 1 do (
			if bip_data != undefined do (
				set_pictureBox_image bip_data.pictureBox_image
				update_mp4()
			)
		)
		if this.asset_Type == 2 do (
			if pose_data != undefined do (
				set_pictureBox_image pose_data.preview_file
				update_png()
			)
		)
		if this.asset_Type == 3 do (
			if pose_data != undefined do (
				set_pictureBox_image pose_data.preview_file
				update_png()

			)
		)
		--btn_update.enabled = true
		--btn_update.text = "上传"
		--print(e.message)
		print("ok_exit")
	)
	fn event_cancel_exit s e =
	(
		try(
			this.form_w = s.width
			this.form_h = s.height
			this.form_location_x = s.Location.X
			this.form_location_y = s.Location.Y

		)catch(
			this.form_w = 512
			this.form_h = 512
			this.form_location_x = 1024
			this.form_location_y = 440
		)
		
		--s.Close();
		--btn_update.enabled = false
		--btn_update.text = "上传"
		print("cancel_exit")

	)
	fn recording_video = 
	(
		get_name()
		_bip = this.getSelectBiped()
		if isValidObj _bip then 
		(
			clearSelection()
		)else(
			no_bip = queryBox "没选中Biped ,是否继续录制?...\n" title:"只上传视频?"
			if not no_bip then 
			(
				--btn_update.enabled = false
				lab_help.text = ""
				return false
			)
		)
		if previewpath.count > 3 and (doesFileExist this.ffmpeg_path) do
		(
			get_update_target_folder_id()

			bip_data = NDAnimLibFilePack_Struct()
			
			bip_data.uploadURl = this.uploadURl()

			bip_data.preview_file = this.switchbody_extsion previewpath ".mp4"
			bip_data.thumbnail_file = this.switchbody_extsion previewpath ".webp"
			bip_data.body_file = this.switchbody_extsion previewpath ".bip"
			bip_data.pictureBox_image = this.switchbody_extsion previewpath ".jpg"
			bip_data._folder_id = update_target_folder_id
			
			bip_data._tags = textBox_tags.text 
			bip_data._target_path = this.set_new_motion_folder_path (edit_path.text )
			
			edit_path.text = bip_data._target_path

			/* bip_data.body_file = new_bip 
			bip_data.preview_file = new_mp4
			bip_data.thumbnail_file = new_gif */

			bip_data.try_delete_old_files()

			if not(save_bip_anim _bip (bip_data.body_file)) do 
			(
				new_bip = ""
				bip_data.body_file = undefined
			)
			
			if bip_data.test_file_is_ok (bip_data.body_file) do 
			(
				bip_data.body_ext = getFilenameType (bip_data.body_file)
			)

			

			if keyboard.escPressed do (return false)
			
			
			if doesFileExist this.dllfile then  
			(
				DllDatas = (dotnetClass "System.Io.File").ReadAllBytes this.dllfile		---Dll 数据
				DllClassGet = (dotnetclass "System.Reflection.Assembly").Load DllDatas  ---装载Dll文件
				try(
					fecorder_form = dllclassGet.CreateInstance "Screen3dsMaxForm.Form1"
					fecorder_form.is_Scale = false --是否使用屏幕缩放
					fecorder_form.is_mp4 = true
					fecorder_form.gifW = 200

					dotNet.addEventHandler fecorder_form "onOKExitHandleEvent" event_ok_exit
					dotNet.addEventHandler fecorder_form "onCancelExitHandleEvent" event_cancel_exit

					fecorder_form.SetSize this.form_w this.form_h false
					--fecorder_form.SetLocation (this.form_location_x) (this.form_location_y)

					fecorder_form.is_delete = false; -- //是否删除 png 序列帧

					fecorder_form.mp4file = bip_data.preview_file
					fecorder_form.jpgfile = bip_data.pictureBox_image
					fecorder_form.webpfile = bip_data.thumbnail_file
					
					fecorder_form.Show()

				)catch(
					messageBox "无法截图！\n可能是 Screen3dsMaxForm.dll 版本不对...\n "
				)
				


				format "ffmpeg -> %\n" fecorder_form.mp4file
				
				--btn_update.enabled = true
				--lab_help.text = fecorder_form.mp4file
			)else(
				messageBox this.dllfile title:"没有DLL"
			)

		)
	)
	fn recording_png = 
	(
		get_name()
		_bip = this.getSelectBiped()
		if not isValidObj _bip then 
		(
			no_bip = messageBox "没选中Biped ,无法创建姿势 ...\n" title:"请选中Biped"
			
			--btn_update.enabled = false
			lab_help.text = ""
			return false
		)else(
			if previewpath.count > 3 do 
			(
				get_update_target_folder_id()

				pose_data = NDAnimLibFilePack_Struct()
			
				pose_data.uploadURl = this.uploadURl()

				pose_data.preview_file = this.switchbody_extsion previewpath ".png"
				pose_data.thumbnail_file = this.switchbody_extsion previewpath ".webp"
				pose_data.body_file = this.switchbody_extsion previewpath ".cpy"
				pose_data.pictureBox_image = this.switchbody_extsion previewpath ".jpg"
				pose_data._folder_id = update_target_folder_id
				
				pose_data._tags = textBox_tags.text 
				pose_data._target_path = this.set_new_motion_folder_path (edit_path.text )
				
				edit_path.text = pose_data._target_path

				new_png = this.switchbody_extsion previewpath ".png"
				new_cpy = this.switchbody_extsion previewpath ".cpy"
				
				pose_data.try_delete_old_files()
				
				save_bip_pose _bip new_cpy


				


				if keyboard.escPressed do (return false)
				DllDatas = (dotnetClass "System.Io.File").ReadAllBytes this.dllfile		---Dll 数据
				DllClassGet = (dotnetclass "System.Reflection.Assembly").Load DllDatas  ---装载Dll文件
				try (
					fecorder_form = dllclassGet.CreateInstance "Screen3dsMaxForm.Form1"
					fecorder_form.is_Scale = false --是否使用屏幕缩放
					fecorder_form.is_mp4 = false
					
					fecorder_form.pngfile = pose_data.preview_file
					fecorder_form.gifW = 200 
					fecorder_form.webpfile = pose_data.thumbnail_file

					dotNet.addEventHandler fecorder_form "onOKExitHandleEvent" event_ok_exit
					dotNet.addEventHandler fecorder_form "onCancelExitHandleEvent" event_cancel_exit

					fecorder_form.SetSize this.form_w this.form_h false

					fecorder_form.Show()
				)catch(
					messageBox "无法截图！\n可能是 Screen3dsMaxForm.dll 版本不对...\n "
					
				)
				format "png -> %\n" new_png

				--btn_update.enabled = true
				--lab_help.text = new_png
			)
		)
	)
	

	fn set_anim_type = 
	(
		_index = 0 
		if rad_anim_type_pose.state do (_index+=1)
		if rad_anim_type_posture.state do (_index+=1)
		if rad_anim_type_bip.state do (_index+=1)
		if _index != 1 then  
		(
			return false
		)else(
			return true
		)

	)
	
	fn get_asset_info = 
	(
		if this.asset_Type == 1 do (
			edit_path.text = this.asset_current_directory
			textBox_tags.text = this.asset_tags
			btn_recording.text = "创建预览视频"
		)
		if this.asset_Type == 2 do (
			edit_path.text = this.asset_directory_pose
			textBox_tags.text = this.asset_tags_pose
			btn_recording.text = "截图"
		)
		if this.asset_Type == 3 do (
			edit_path.text = this.asset_directory_posture
			textBox_tags.text = this.asset_tags_posture
			btn_recording.text = "截图"

		)
		get_update_target_folder_id()
	)
	fn set_asset_info = 
	(
		if this.asset_Type == 1 do (
			this.asset_current_directory = edit_path.text  
			this.asset_tags = textBox_tags.text 
		)
		if this.asset_Type == 2 do (
			this.asset_directory_pose = edit_path.text 
			this.asset_tags_pose = textBox_tags.text 

		)
		if this.asset_Type == 3 do (
			this.asset_directory_posture = edit_path.text  
			this.asset_tags_posture = textBox_tags.text 

		)
	)
	on rad_anim_type_bip changed arg do 
	(
		if arg then 
		(
			this.asset_Type = 1
			rad_anim_type_pose.state = false
			rad_anim_type_posture.state = false
			get_asset_info()	
		)
		btn_recording.enabled = set_anim_type()

	)
	on rad_anim_type_pose changed arg do 
	(
		if arg do 
		(
			this.asset_Type = 2
			rad_anim_type_bip.state = false
			rad_anim_type_posture.state = false
			get_asset_info()	
			
		)
		btn_recording.enabled = set_anim_type()

	)
	on rad_anim_type_posture changed arg do 
	(
		if arg do  
		(
			this.asset_Type = 3
			rad_anim_type_bip.state = false
			rad_anim_type_pose.state = false
			get_asset_info()	
			
		)
		btn_recording.enabled = set_anim_type()

	)
	on edit_path changed arg do
	(
		--print(arg)
	) 
	on edit_name changed arg do
	(
		--print(arg)
	)

	on btn_reset pressed do 
	(
		--get_save_path()
		--edit_name.text = maxfilename
		edit_name.text = this.set_name (getFilenameFile maxfilename)

	)
	
	/* on btn_update pressed do 
	(
		if this.video_or_png() then
		(
			--视频
			update_mp4()
		)else(
			update_png()
		)
	) */

	on btn_recording pressed do 
	(
		if this.video_or_png() then
		(
			--视频
			clear_show_data_state()
			recording_video()
		)else(
			--图片
			clear_show_data_state()

			recording_png()
		)

	)
	on btn_reset rightclick do 
	(
		edit_name.text = get_id_name()
	)
	/* on btn_update rightclick do 
	(
		print("btn_update")
		_ok = queryBox "重试上传.." title:"是否重试上传?"
		if _ok do (
		)
	) */
	on AnimLibTestAddNew open do 
	(

	)
	fn opendo =
	(
		setup_list()
		----------------------------------------------------
		--rad_anim_type.state = this.asset_Type
		if this.asset_Type == 1 do 
		(
			rad_anim_type_bip.checked = true
		)
		if this.asset_Type == 2 do 
		(
			rad_anim_type_pose.checked = true
		)
		if this.asset_Type == 3 do 
		(
			rad_anim_type_posture.checked = true
		)

		get_asset_info()	

		----------------------------------------------------


		temp_path = this.get_Env_ffmpeg_path()
		get_save_path()

		if temp_path != undefined then (
			this.ffmpeg_path = temp_path + @"\ffmpeg.exe"
			lab_help.text = this.ffmpeg_path
			btn_recording.enabled = true

		)else(
			this.ffmpeg_path = undefined
			btn_recording.enabled = false

			lab_help.text = "请下载视频处理软件ffmpeg 并添加到系统环境变量中..."
			messageBox lab_help.text
		)
	)
	on AnimLibTestAddNew close do 
	(
		set_asset_info()

		this.close_event()
	)

),
helpRoll = rollout AnimLibHelpRoll "帮助" width:275 height:210
(

	HyperLink lbl_01 "使用帮助?" address:"http://anim.nd.com.cn/pages/BipedLib/" color:red hoverColor:(color 0 255 255) align:#center
	label lab3 "使用过程中有任何问题可99U：199505" align:#center
	
	group ""(
	button btn_open_downtemp "缓存目录" width:70 height:22 tooltip:"打开缓存目录" across:2
	button btn_open_downpath "下载目录" width:70 height:22 tooltip:"打开缓存目录"

	)
	local this = undefined
	local UriKind = (dotNetClass "System.UriKind").Absolute

	fn opendo = 
	(

	)
	on btn_open_downtemp pressed do 
	(
		ShellLaunch "explorer.exe" (GetDir #preview)
	)
	on btn_open_downpath pressed do 
	(
		ShellLaunch "explorer.exe" (getdir #animations)
	)
	
),
	on create do (
		--实例话结构体事件
	),
	AnimLibTestRollFloat = newRolloutFloater "Biped Manager v.3" 280 450,
	fn close = (
		try(
			closeRolloutFloater this.AnimLibTestRollFloat
		)
		catch()
	),
	fn show = (
		addRollout this.WebRoll this.AnimLibTestRollFloat
		addRollout this.AddNew this.AnimLibTestRollFloat 
		addRollout this.helpRoll this.AnimLibTestRollFloat rolledUp:true

		this.AddNew.this = this 
		this.AddNew.opendo()

		this.WebRoll.this = this
		this.WebRoll.opendo()

		this.helpRoll.this = this 
		this.helpRoll.opendo()
	)
)
global NDAnimLib
NDAnimLib = NDAnimLib_group_srtuct()
NDAnimLib.open_event()
NDAnimLib.show()

if not NDAnimLib.test_remote_server() then
(
	messageBox "无法链接服务器" title:NDAnimLib.server_url
	NDAnimLib.WebRoll.textBox_model.text = "无法链接服务器" + "\r\n" + NDAnimLib.server_url + "\r\n"+"请联系动画库管理员..."
	format "%\n" NDAnimLib.WebRoll.textBox_model.text

)else(
	--如果链接服务器是正常的的
	NDAnimLib.start_event()
)
--测试允许环境依赖是否正常
NDAnimLib.test_client_environment()
--NDAnimLib.AddNew.backend = NDAnimLib
/* AnimLibTestRollFloat = newRolloutFloater "Biped Manager v.2" 280 400
addRollout AnimLibTestRoll AnimLibTestRollFloat rolledUp:true
addRollout AnimLibTestAddNew AnimLibTestRollFloat --rolledUp:true
--createDialog AnimLibTestAddNew
--createDialog AnimLibTestRoll
 */
/*   
天晴动作脚本工具组 检测更新
2019-10-3 / 2021-09-19
2023-11-26 改成天晴盒子的检测更新
2025-04-12 更新选项布局
2025-07-22 内网检查更新版本 http://anim.nd.com.cn
2025-07-23 界面加宽，显示信息完整
2026-08-24 优化：修复bug、清理冗余、同步下载带超时避免启动卡顿
当检查到 @scripts\NDTools\C3S3\AllC3Exporter.mse 存在使用 内网 链接http://anim.nd.com.cn/download 检测更新
否则使用外网链接检测更新 http://sundaybox.cc/Test_download
*/

(
	struct try_test_ndboxUp 
	(
	    config_file = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\config.ini",
	    ver_str = "",
	    Show_str = "",
	    down_str = "",
	    message = "",
	    selfpath = "",
		oldpath = "",
		downloader_exe = "", -- 下载器路径（内网/外网）
	    test_type = "",
		is_open_updata_rollout = false,
		Month = "", --月
		DayOfWeek = "",--星期
		Day = "",--日
		
		UpMonth = "", --月
		UpDayOfWeek = "",--星期
		UpDay = "",--日

		fn getint str =
		(
			return_int = 0 
			if str.count != 0 do (
				try (return_int = str as integer) catch ( return_int = 0 )
			)
			return_int 
		), 

		fn test_day = 
		(
			daytime = getLocalTime()
			this.Month = daytime[2]
			this.DayOfWeek = daytime[3]
			this.Day = daytime[4]
			case of (
				(this.test_type == "1"):( return true )
				(this.test_type == "2"):( if this.UpDay == this.Day then (return false) else (return true) )
				(this.test_type == "3"):( if this.UpMonth == this.Month then (return false) else (return true) )
				(this.test_type == "4"):( return false )
				default: return true
			)
		),

		fn save = 
		(
			setINISetting this.config_file "NDBoxDownload" "Version" this.ver_str
			setINISetting this.config_file "NDBoxDownload" "ShowUp" this.Show_str 
			setINISetting this.config_file "NDBoxDownload" "TestType" this.test_type
			setINISetting this.config_file "NDBoxDownload" "Month" (this.Month as string)
			setINISetting this.config_file "NDBoxDownload" "DayOfWeek" (this.DayOfWeek as string)
			setINISetting this.config_file "NDBoxDownload" "Day" (this.Day as string)
		),

		fn try_get_up_data = 
		(
			try (deleteFile this.oldpath) catch()
			if this.Show_str != "0" then
			(
				-- 存在内网工具则用内网链接检测，否则用外网链接
				if doesFileExist ((getdir #scripts) + "\\NDTools\\C3S3\\AllC3Exporter.mse") then (
					url = "http://anim.nd.com.cn/download?fileid=updateBox.txt"
					this.downloader_exe = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\NDDownloadIn.exe"
				) else (
					url = "http://sundaybox.cc/Test_download?fileid=updateBox.txt"
					this.downloader_exe = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\NDDownload.exe"
				)
				try (
					-- 同步下载版本信息，带10秒超时，避免启动长时间卡住
					reqClass = dotNetClass "System.Net.HttpWebRequest"
					req = reqClass.Create (dotNetObject "System.Uri" url)
					req.Timeout = 5000
					req.Proxy = undefined
					resp = req.GetResponse()
					stream = resp.GetResponseStream()
					reader = dotNetObject "System.IO.StreamReader" stream
					this.down_str = reader.ReadToEnd()
					reader.Close()
					resp.Close()
					format "下载到版本号 -> % \n" this.down_str
				) catch (
					-- 无法下载到版本号，删除本启动脚本
					format "无法下载 % 服务器上的版本信息,删除启动自动检测脚本\n" url
					try (deleteFile this.selfpath) catch()
					this.down_str = this.ver_str
					this.is_open_updata_rollout = false
					return false
				)
				format "天晴盒子Max启动检测更新脚本 NDtools_2015_StartupND.ms\n"
				format "	安装版本 -> % ; 服务器版本 -> % \n" this.ver_str this.down_str
				if this.ver_str != this.down_str then 
				(
					this.message = ("检测到服务器版本 "+ this.down_str +" 是否打开下载器？  \r\n ")
					this.is_open_updata_rollout = this.test_day()
				) else (
					this.message = ("服务器版本 "+ this.down_str)
				)
			) else (
				this.message = ("已关闭检测服务器更新功能")
				format "已关闭检测服务器更新功能\n"
				this.is_open_updata_rollout = false
			)
		),

	    on create do 
	    (
	    	this.ver_str = getINISetting this.config_file "NDBoxDownload" "Version"
			this.Show_str = getINISetting this.config_file "NDBoxDownload" "ShowUp"
			this.selfpath = (getdir #startupScripts) + "\\NDtools_2015_StartupND.ms"
			this.oldpath = (getdir #startupScripts) + "\\NDtools_2015_StartupXX.mse"
			this.test_type = getINISetting this.config_file "NDBoxDownload" "TestType"
			if this.test_type == "" do 
			(
				this.test_type = "1"
			)

			this.UpMonth = this.getint(getINISetting this.config_file "NDBoxDownload" "Month")
			this.UpDayOfWeek = this.getint(getINISetting this.config_file "NDBoxDownload" "DayOfWeek")
			this.UpDay = this.getint(getINISetting this.config_file "NDBoxDownload" "Day")
	    )
	)
 
	try(destroyDialog NDBoxDownload_updata_rollout)catch()
	global NDBoxDownload_updata_rollout 

	rollout NDBoxDownload_updata_rollout "天晴盒子-内网 启动时检测更新脚本 【0.22】" width:380 height:170
	(
		group "NDtools_2015_StartupND"(
		label lab_01 "" align:#left 
		label lab_02 ""
		
		radiobuttons check_is_updata "" labels:#("总提示","今日不提示","本月不提示","不再提示") columns:4 offsets:#([20,0], [0,0], [0,0], [0,0]) --offset:[0,5]
		button btn_close_test "不再检测？" tooltip:"不再检测服务器更新" width:90 height:25 offset:[0,5] across:3
		button btn_open "打开下载器" width:90 height:25 offset:[0,5]
		button btn_close "关闭" width:90 height:25 offset:[0,5]
		)
		HyperLink btn_Help_web "查看更新内容" address:"http://anim.nd.com.cn/pages/aa2ff7/" align:#center
		local backen = undefined

		fn show_msg = 
		(
			lab_01.text = "已安装版本：" + backen.ver_str
			lab_02.text = backen.message
			check_is_updata.state = backen.test_type as integer
			if backen.Show_str == "0" do 
			(
				btn_close_test.text = "开启检测？"
				btn_close_test.tooltip = "是否开启检测服务器更新功能？"
			)
		)

		on check_is_updata changed arg do 
		(
			backen.test_type = (arg as string)
			backen.save()
		)

		on btn_close_test pressed do 
		(
			if (backen.Show_str != "0") then 
			(
				--不再提示，除非是手动修改配置
				is_ok = queryBox "确定永不再检测更新？\n除非是手动修改配置,将再不自动检测...\n" title:"警告"
				if is_ok do  
				(
					backen.Show_str = "0"
					backen.save()
					format "除非手动修改 C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\config.ini \n"
					format "	NDBoxDownload -> Show=1 ,将永久不检测更新\n"
					messageBox "不再检测更新设置完成\n"
				)
			) else (
				is_ok = queryBox "是否开启检测更新功能？\n" title:"警告"
				if is_ok do (
					backen.Show_str = "1"
					backen.save()
					messageBox "检测更新设置完成\n"
				)
			)
		)

		on btn_open pressed do 
		(
			_exefile = backen.downloader_exe
			if _exefile != "" and doesFileExist _exefile then
			(
				HiddenDOSCommand ("start " + _exefile)
			)
			else
			(
				messageBox "未找到下载器, http://anim.nd.com.cn/   \r\n" title:"anim.nd.com.cn"
			)
		)
		
		on btn_close pressed do 
		(
			backen.save()
			destroyDialog NDBoxDownload_updata_rollout
		)
	)

	global try_test_ndboxUp_init = try_test_ndboxUp()
	try_test_ndboxUp_init.try_get_up_data()

	if try_test_ndboxUp_init.is_open_updata_rollout do (
		createDialog NDBoxDownload_updata_rollout
		NDBoxDownload_updata_rollout.backen = try_test_ndboxUp_init
		NDBoxDownload_updata_rollout.show_msg()
	)
)

/*
# coding: utf-8 
# @Date    : 2024-08-28 21:44:47
# @Author  : 4698to (738746223@qq.com)
# @Link    : sundaybox.cc
# @99U     : 199505
*/

(
	scipt_ = @"C:\ProgramData\Autodesk\ApplicationPlugins\NDToolsBox\Joe_Anim_Picker\BipedAinmPicker_FBXmap__menu_v2.ms"
	if doesFileExist scipt_ then 
	(
		try(filein scipt_)catch()
	)else(
		messageBox "没有下载"
	)

)
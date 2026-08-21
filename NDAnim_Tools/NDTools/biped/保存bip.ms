/*
-- coding: utf-8 
-- @Date    : 2024-05-17 13:40:50
-- @Author  : 4698to (738746223@qq.com)
-- @Link    : sundaybox.cc
-- @Version : 
*/

/* try(destroyDialog rolloutName)catch()

rollout rolloutName "rolloutName" (
    -- Rollout body.
)

createDialog rolloutName */

(
	bip_root = @"D:\Program Files\Autodesk\3ds Max 2015\AutoBip\"

	if maxfilename != "" then (
		bip_file = bip_root + (getFilenameFile maxfilename) + ".bip" 
	)else(
		bip_file = getSaveFileName caption:"保存 bip" filename:bip_root types:"Bip(*.bip)|*.bip|All|*.*|"
	)
	if bip_file != undefined do (
		if selection.count > 0 do 
		(
			bipobj = selection[1]
			bipobj = bipobj.transform.controller.rootnode

			rep = biped.saveBipfile bipobj.controller bip_file
			format "saveBipfile -> % => % -> % \n" bip_file bipobj.name rep
		)	
	)
)
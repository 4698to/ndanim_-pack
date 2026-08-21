
Global GMOrigScnPth = Getdir #scene
Global GMStringTest = ""

callbacks.addScript #filePostOpenProcess "if (GMStringTest != undefined) and (GMStringTest.count == 0) do(if maxFilePath != GMStringTest do(SetDir #scene maxFilePath))" id:#filePostOpen_callback
callbacks.addScript #filePostSave "SetDir #scene maxFilePath" id:#filePostSave_callback

callbacks.addScript #preSystemShutdown "if (GMOrigScnPth != undefined) do(if (doesFileExist GMOrigScnPth) do(SetDir #scene GMOrigScnPth))" id:#preSystemShutdown_callback
--https://forums.autodesk.com/t5/3ds-max-forum/2015-sp3-bug-quot-file-save-as-quot-directory/td-p/5451395/page/2
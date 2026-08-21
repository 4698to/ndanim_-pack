rollout importFBXUI "Import FBX UI-myl"
(
    button btnSingleFBX "导入单个fbx"
    button btnMultipleFBX "导入多个fbx"

    on btnSingleFBX pressed do
    (
        -- 导入单个FBX文件
        local filename = getOpenFileName types:"FBX Files (*.fbx)|*.fbx|All Files (*.*)|*.*|"
        if filename != undefined then
        (
            FBXImporterSetParam "QuietMode" true
            importFile filename #noPrompt
        )
    )

    on btnMultipleFBX pressed do
    (
        -- 导入多个FBX文件
        local path = getSavePath caption:"Select Folder with FBX Files"
        if path != undefined then
        (
            local files = getFiles (path + "\\*.fbx")
            for filename in files do
            (
                FBXImporterSetParam "QuietMode" true
                importFile filename #noPrompt
            )
        )
    )
)

createDialog importFBXUI

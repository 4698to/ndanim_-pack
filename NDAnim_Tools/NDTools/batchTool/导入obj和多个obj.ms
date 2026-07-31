rollout importUI "Import UI-myl"
(
    button btnSingleOBJ "导入单个 OBJ"
    button btnMultipleOBJ "导入多个 OBJs"

    on btnSingleOBJ pressed do
    (
        -- 导入单个OBJ文件
        local filename = getOpenFileName types:"OBJ Files (*.obj)|*.obj|All Files (*.*)|*.*|"
        if filename != undefined then
        (
            importFile filename #noPrompt
        )
    )

    on btnMultipleOBJ pressed do
    (
        -- 导入多个OBJ文件
        local path = getSavePath caption:"Select Folder with OBJ Files"
        if path != undefined then
        (
            local files = getFiles (path + "\\*.obj")
            for filename in files do
            (
                importFile filename #noPrompt
            )
        )
    )
)

createDialog importUI

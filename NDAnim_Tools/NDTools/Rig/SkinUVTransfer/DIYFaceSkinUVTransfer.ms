(
    local scriptDir = getFilenamePath (getSourceFileName())
    local entryScript = scriptDir + "DIYFaceSkinUVTransfer.py"

    if doesFileExist entryScript then
    (
        local pythonPath = substituteString entryScript "\\" "/"
        pythonPath = substituteString pythonPath "'" "\\'"
        local pythonCode = "import sys, imp; "
        pythonCode += "_old_module = sys.modules.get('DIYFaceSkinUVTransfer'); "
        pythonCode += "_old_dialog = getattr(_old_module, '_DIALOG', None); "
        pythonCode += "_old_dialog.close() if _old_dialog is not None else None; "
        pythonCode += "sys.modules.pop('DIYFaceSkinUVSemantics', None); "
        pythonCode += "_DIYFACE_SKIN_UV_MODULE = imp.load_source('DIYFaceSkinUVTransfer', u'" + pythonPath + "'); "
        pythonCode += "_DIYFACE_SKIN_UV_MODULE.show_dialog()"
        python.Execute pythonCode
    )
    else
    (
        messageBox ("未找到插件入口文件：\n" + entryScript) title:"DIYFace UV 蒙皮权重复制"
    )
)
0

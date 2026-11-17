/*
    AIhub 入口
    由 Startup\NDTools.ms 中的 macroScript AIHubSettings 调用。
    负责加载模块、创建唯一公共单例 AIHub，并打开设置窗口。
*/

-- 模块 struct / rollout 一律显式声明为 global：
-- fileIn 的模块若在块内被求值，未声明 global 的 struct 会退化成块内局部变量，
-- 随后 AIHUB_Config() 就会报 “Call needs function or class, got: undefined”。
global AIHub
global AIHub_Settings
global AIHUB_Config, AIHUB_Schema, AIHUB_Http
(
    -- 模块目录固定为 NDBox 插件目录
    local aihubDir = "C:\\ProgramData\\Autodesk\\ApplicationPlugins\\NDToolsBox\\maxTools\\AIhub\\"

    if not (doesFileExist (aihubDir + "AIHub_Config.ms")) do
        throw ("AIhub 模块目录不存在: " + aihubDir)

    if AIHub == undefined do
    (
        fileIn (aihubDir + "AIHub_Schema.ms")
        fileIn (aihubDir + "AIHub_Http.ms")
        fileIn (aihubDir + "AIHub_Config.ms")

        if AIHUB_Config == undefined or AIHUB_Schema == undefined or AIHUB_Http == undefined do
            throw ("AIhub 模块加载失败（struct 未定义）: " + aihubDir)

        AIHub = AIHUB_Config()
        AIHub.schema = AIHUB_Schema()
        AIHub.http = AIHUB_Http()
    )

    if AIHub_Settings == undefined do
        fileIn (aihubDir + "AIHub_UI.ms")

    try (destroyDialog AIHub_Settings) catch()
    createDialog AIHub_Settings
)

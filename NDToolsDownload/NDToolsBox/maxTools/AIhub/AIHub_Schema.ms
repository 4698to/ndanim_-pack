/*
    AIhub 内置字段注册表
    仅描述 ai_resources.ini 中已知字段的展示与校验信息，不负责读写文件。
    新增一个需要长期结构化展示的字段时，在 defs 中追加一条 AIHUB_FieldDef 即可。
*/

-- 显式 global：确保 fileIn 后 struct 落在全局作用域
global AIHUB_FieldDef, AIHUB_Schema

struct AIHUB_FieldDef (
    section,
    key,
    labelText,
    kind,          -- #url / #int / #bool / #enum / #tristate / #string
    defaultVal,    -- 未设置时的展示默认值，undefined 表示没有默认
    options,       -- enum 的合法值数组
    minVal,
    maxVal,
    readOnly,
    healthPath,    -- 仅对服务段的 base_url 有意义
    owner          -- 消费该字段的工具名，便于排查
)

struct AIHUB_Schema (
    defs = #(
        AIHUB_FieldDef "vipose_sam3d_service" "base_url" "服务地址" #url "http://127.0.0.1:8010" #() undefined undefined false "/v2/pose/health" "ImagePose",
        AIHUB_FieldDef "vipose_sam3d_service" "timeout_ms" "超时(毫秒)" #int "180000" #() 1000 3600000 false "" "ImagePose",
        AIHUB_FieldDef "vipose_sam3d_service" "retarget_scheme" "重定向档位" #enum "v4" #("v1", "v4") undefined undefined false "" "ImagePose",
        AIHUB_FieldDef "vipose_sam3d_service" "server_name" "服务器名称" #string undefined #() undefined undefined true "" "ImagePose",
        AIHUB_FieldDef "vipose_sam3d_service" "target_pose_rest_rebase" "目标姿态重定向" #tristate undefined #("未设置（默认）", "开启 (1)", "关闭 (0)") undefined undefined false "" "ImagePose",
        AIHUB_FieldDef "vipose_sam3d_service" "use_msdata" "使用 msdata（调试）" #bool "false" #() undefined undefined false "" "ImagePose",
        AIHUB_FieldDef "skintokens" "base_url" "服务地址" #url undefined #() undefined undefined false "/health" "SkinTokens",
        AIHUB_FieldDef "service" "base_url" "服务地址" #url "http://127.0.0.1:8010" #() undefined undefined false "/health" "待确认",
        AIHUB_FieldDef "dev" "allow_local" "允许本地离线资源" #bool "false" #() undefined undefined false "" "ImagePose 调试",
        AIHUB_FieldDef "servers" "count" "服务器数量" #int undefined #() undefined undefined true "" "ImagePose"
    ),

    fn Find section key = (
        local s = toLower section
        local k = toLower key
        local hit = undefined
        for d in this.defs where (hit == undefined) do (
            if (toLower d.section == s) and (toLower d.key == k) do hit = d
        )
        hit
    ),

    fn DefsForSection section = (
        local s = toLower section
        local out = #()
        for d in this.defs where (toLower d.section == s) do append out d
        out
    ),

    fn SectionOrder = (
        local out = #()
        local seen = #()
        for d in this.defs do (
            local s = toLower d.section
            if (findItem seen s) == 0 do (
                append seen s
                append out d.section
            )
        )
        out
    ),

    fn IsKnownSection section = (
        local s = toLower section
        local hit = false
        for d in this.defs where (hit == false) do (
            if (toLower d.section == s) do hit = true
        )
        hit
    ),

    fn IsServiceSection section = (
        local d = this.Find section "base_url"
        d != undefined
    ),

    fn HealthPath section = (
        local d = this.Find section "base_url"
        if d == undefined then "" else (if d.healthPath == undefined then "" else d.healthPath)
    ),

    fn KindFor section key = (
        local d = this.Find section key
        if d == undefined then undefined else d.kind
    ),

    fn LabelFor section key = (
        local d = this.Find section key
        if d == undefined then key else d.labelText
    ),

    fn OptionsFor section key = (
        local d = this.Find section key
        if d == undefined then #() else d.options
    ),

    fn DefaultFor section key = (
        local d = this.Find section key
        if d == undefined then undefined else d.defaultVal
    ),

    fn IsReadOnly section key = (
        local d = this.Find section key
        if d == undefined then false else d.readOnly
    ),

    fn OwnerFor section key = (
        local d = this.Find section key
        if d == undefined then "" else d.owner
    )
)

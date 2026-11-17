/*
    AIhub 设置窗口
    依赖全局单例 AIHub（由 AIHub.ms 创建）。
    所有修改先进入内存，点击“保存到文件”后才写入 ai_resources.ini。
*/

-- 显式 global：确保 fileIn 后 rollout 落在全局作用域
global AIHub_Settings

rollout AIHub_Settings "AI 服务器地址设置 v7" width:640 height:428
(
    local cfg = undefined
    local busy = false
    local sectionNames = #()
    local fieldRows = #()
    local statusLog = #()
    local curSection = ""
    local curKey = ""
    local curKind = #string

    -- ① 服务：地址即字段 base_url，统一在下方字段区编辑
    groupBox gbService "① 服务" pos:[8,6] width:624 height:52
    label lblSvcPick "服务:" pos:[18,26] width:50 height:18
    dropdownList ddlSections "" pos:[72,24] width:260 height:22
    button btnAddSection "新建…" pos:[338,23] width:74 height:24 tooltip:"新建服务段 [servers:名称]"
    button btnDelSection "删除服务" pos:[418,23] width:88 height:24 tooltip:"删除当前服务段"
    button btnTest "连接测试" pos:[512,23] width:102 height:24 tooltip:"按当前服务的 base_url 测连通性"

    -- ② 字段：左选右改
    groupBox gbFields "② 字段编辑（左侧选字段，右侧改值）" pos:[8,66] width:624 height:142
    listBox lbFields "" pos:[18,86] width:290 height:8
    label lblKey "" pos:[326,86] width:288 height:34
    label lblValue "值:" pos:[326,130] width:30 height:18
    editText edValue "" pos:[358,128] width:256 height:22
    button btnApply "应用修改" pos:[326,156] width:140 height:24
    button btnDelField "删除字段" pos:[472,156] width:142 height:24

    -- ③ 新增字段（一行：左字段名 / 右字段值 / 添加；值一律按字符串写入）
    groupBox gbNew "③ 新增字段（默认按文本保存）" pos:[8,216] width:624 height:52
    label lblNewKey "字段名:" pos:[18,238] width:58 height:18
    editText edNewKey "" pos:[82,236] width:185 height:22
    label lblNewValue "字段值:" pos:[275,238] width:58 height:18
    editText edNewFieldValue "" pos:[339,236] width:185 height:22
    button btnAddField "添加" pos:[532,235] width:82 height:24

    dotNetControl edStatus "System.Windows.Forms.TextBox" pos:[16,276] width:600 height:76

    -- 保存与刷新
    groupBox gbSave "保存与刷新" pos:[8,360] width:624 height:56
    button btnSave "保存到文件" pos:[18,380] width:130 height:26
    button btnRevert "撤销更改" pos:[156,380] width:130 height:26
    button btnReload "重新加载" pos:[294,380] width:130 height:26
    button btnOpenDir "打开目录" pos:[432,380] width:130 height:26

    fn status msg = (
        local m = if msg == undefined then "" else (msg as string)
        append statusLog m
        if statusLog.count > 50 do deleteItem statusLog 1
        local lines = ""
        for s in statusLog do lines += (s + "\r\n")
        try (
            edStatus.Text = lines
            edStatus.SelectionStart = edStatus.Text.Length
            edStatus.ScrollToCaret()
        ) catch()
        local ts = ""
        try ( ts = (dotNetClass "System.DateTime").Now.ToString("HH:mm:ss") ) catch()
        format "[AIhub %] %\n" ts m
        m
    )

    fn trimDisplay s limit = (
        if s == undefined then return ""
        local v = s as string
        if v.count > limit then (substring v 1 limit) + "..." else v
    )

    fn kindText kind = (
        if kind == #url then "URL"
        else if kind == #int then "整数"
        else if kind == #bool then "布尔"
        else if kind == #enum then "枚举"
        else if kind == #tristate then "三态"
        else "文本"
    )

    fn loadField key = (
        local row = undefined
        for r in fieldRows where (toLower r.key == toLower key) do row = r
        if row == undefined do return false
        curKey = row.key
        curKind = if row.kind == undefined then #string else row.kind
        local tag = "  [" + (kindText curKind) + "]"
        if row.readOnly do tag += "  [只读]"
        if row.labelText != undefined and (toLower row.labelText != toLower row.key) do tag += "  " + row.labelText
        local hint = ""
        if curKind == #bool then (
            hint = "取值: 1/true 或 0/false"
        ) else if curKind == #tristate then (
            hint = "取值: 1 开启 / 0 关闭（清空=未设置）"
        ) else if curKind == #enum then (
            local opts = if cfg.schema == undefined then #() else cfg.schema.OptionsFor curSection row.key
            if opts.count > 0 do hint = "可选: " + (opts as string)
        ) else if curKind == #url then (
            hint = "需以 http:// 或 https:// 开头"
        )
        lblKey.text = row.key + tag + (if hint == "" then "" else "    " + hint)

        local v = if row.value == undefined then "" else (row.value as string)
        edValue.text = v
        edValue.enabled = not row.readOnly
        btnApply.enabled = not row.readOnly
        true
    )

    fn refreshFields = (
        busy = true
        local wantKey = curKey
        fieldRows = #()
        local items = #()
        if curSection != "" do (
            fieldRows = cfg.Fields curSection
            for r in fieldRows do (
                local v = if r.value == undefined then "" else (r.value as string)
                local mark = if r.dirty then "* " else "  "
                local defMark = if (not r.present) and (r.value != undefined) then "  (默认)" else ""
                append items (mark + r.key + " = " + (trimDisplay v 40) + defMark)
            )
        )
        lbFields.items = items
        local idx = 0
        local n = 0
        for r in fieldRows do (
            n += 1
            if (wantKey != "") and (toLower r.key == toLower wantKey) do idx = n
        )
        if idx > 0 then (
            lbFields.selection = idx
            loadField fieldRows[idx].key
        ) else if fieldRows.count > 0 then (
            lbFields.selection = 1
            loadField fieldRows[1].key
        ) else (
            lbFields.selection = 0
            curKey = ""
            lblKey.text = "（无字段）"
            edValue.text = ""
            edValue.enabled = false
            btnApply.enabled = false
        )
        busy = false
    )

    fn refreshSections selectName = (
        busy = true
        local want = selectName
        if want == undefined or want == "" do want = curSection
        local names = cfg.Sections()
        sectionNames = #()
        local items = #()
        for s in names do (
            append sectionNames s
            append items s
        )
        ddlSections.items = items
        local idx = 1
        if want != undefined do (
            local n = 0
            for s in sectionNames do (
                n += 1
                if toLower s == toLower want do idx = n
            )
        )
        if sectionNames.count > 0 then (
            ddlSections.selection = idx
            curSection = sectionNames[idx]
        ) else (
            ddlSections.selection = 0
            curSection = ""
        )
        busy = false
        refreshFields()
    )

    fn refreshServers = (
        local isSvc = false
        if curSection != "" do (
            if cfg.schema != undefined do isSvc = cfg.schema.IsServiceSection curSection
            if not isSvc do (
                local v = cfg.FieldValue curSection "base_url"
                if v != undefined and (trimLeft (trimRight (v as string))).count > 0 do isSvc = true
            )
        )
        btnTest.enabled = isSvc
    )

    fn refreshAll = (
        refreshSections curSection
        refreshServers()
    )

    on AIHub_Settings open do (
        global AIHub
        cfg = AIHub
        try (
            edStatus.ReadOnly = true
            edStatus.Multiline = true
            edStatus.WordWrap = true
            edStatus.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
            edStatus.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
        ) catch()
        local cc = dotNetClass "System.Drawing.Color"
        local bg = undefined
        try (
            -- colorMan.getColor 在不同 Max 版本返回 Color 或 Point3（0–1 浮点），两种都要兼容。
            local rawBg = colorMan.getColor #background
            bg = if classof rawBg == Color then #(rawBg.r, rawBg.g, rawBg.b) else #((rawBg.x * 255) as integer, (rawBg.y * 255) as integer, (rawBg.z * 255) as integer)
            edStatus.BackColor = cc.FromArgb 255 bg[1] bg[2] bg[3]
        ) catch()
        try (
            local rawFg = colorMan.getColor #text
            local fg = if classof rawFg == Color then #(rawFg.r, rawFg.g, rawFg.b) else #((rawFg.x * 255) as integer, (rawFg.y * 255) as integer, (rawFg.z * 255) as integer)
            edStatus.ForeColor = cc.FromArgb 255 fg[1] fg[2] fg[3]
        ) catch (
            if bg != undefined and (((bg[1] + bg[2] + bg[3]) / 3.0) < 128) do
                edStatus.ForeColor = cc.FromArgb 255 224 224 224
        )
        if cfg != undefined do (
            local ok = cfg.Ensure()
            cfg.Reload()
            refreshAll()
            if not ok then (
                status "无法创建配置文件，请检查 ProgramData 写入权限"
            ) else if cfg.GetReadError() != undefined then (
                status ("读取失败: " + cfg.GetReadError())
            ) else (
                status ("配置文件: " + cfg.GetPath())
            )
        )
    )

    on ddlSections selected i do (
        if not busy do (
            if (i >= 1) and (i <= sectionNames.count) do (
                curSection = sectionNames[i]
                refreshFields()
                refreshServers()
            )
        )
    )

    on lbFields selected i do (
        if not busy do (
            if (i >= 1) and (i <= fieldRows.count) do loadField fieldRows[i].key
        )
    )

    on btnApply pressed do (
        if curKey == "" do return false
        local row = undefined
        for r in fieldRows where (toLower r.key == toLower curKey) do row = r
        if row == undefined do return false
        if row.readOnly do (
            messageBox "该字段为只读，不能修改。" title:"AIhub"
            return false
        )
        local val = trimLeft (trimRight edValue.text)
        local err = cfg.ValidateValue curSection curKey val curKind
        if err != undefined do (
            messageBox err title:"AIhub"
            return false
        )
        cfg.SetValue curSection curKey val kind:curKind
        status ("已修改: " + curKey + " = " + val + "（待保存）")
        refreshFields()
        refreshServers()
        true
    )

    on btnAddField pressed do (
        if curSection == "" do (
            messageBox "请先选择一个服务或段。" title:"AIhub"
            return false
        )
        local key = trimLeft (trimRight edNewKey.text)
        if not (cfg.IsValidName key) do (
            messageBox "字段名不能为空，且不能包含 [ ] = ; # 等字符。" title:"AIhub"
            return false
        )
        local val = trimLeft (trimRight edNewFieldValue.text)
        cfg.SetValue curSection key val kind:#string
        edNewKey.text = ""
        edNewFieldValue.text = ""
        curKey = key
        refreshFields()
        status ("已新增字段: " + key + " = " + val + "（按文本保存，待保存）")
        true
    )

    on btnDelField pressed do (
        if (curSection == "") or (curKey == "") do return false
        if (cfg.schema != undefined) and (cfg.schema.IsReadOnly curSection curKey) do (
            messageBox "该字段为只读，不能删除。" title:"AIhub"
            return false
        )
        if (toLower curKey) == "base_url" do (
            messageBox "服务地址字段不能删除，可修改或置空。" title:"AIhub"
            return false
        )
        if (queryBox ("确定删除字段 [" + curKey + "]？") title:"AIhub") == false do return false
        cfg.DeleteKey curSection curKey
        curKey = ""
        refreshFields()
        refreshServers()
        status "已标记删除字段（待保存）"
        true
    )

    fn CreateSection nm = (
        local name = trimLeft (trimRight ((if nm == undefined then "" else nm) as string))
        if not (cfg.IsValidName name) do (
            messageBox "服务名不能为空，且不能包含 [ ] = ; # 等字符。" title:"AIhub"
            return false
        )
        if cfg.HasSection name do (
            messageBox "该服务已存在。" title:"AIhub"
            return false
        )
        cfg.AddSection name
        curSection = name
        refreshSections name
        refreshServers()
        status ("已新建服务: " + name + "（待保存）")
        true
    )

    on btnAddSection pressed do (
        try (destroyDialog AIHub_NewSection) catch()
        createDialog AIHub_NewSection
        true
    )

    on btnDelSection pressed do (
        if curSection == "" do return false
        if (cfg.schema != undefined) and (cfg.schema.IsKnownSection curSection) do (
            messageBox "内置服务不能在此删除，请直接编辑或清空对应字段。" title:"AIhub"
            return false
        )
        if (queryBox ("确定删除服务 [" + curSection + "] 及其全部字段？") title:"AIhub") == false do return false
        cfg.DeleteSection curSection
        curSection = ""
        curKey = ""
        refreshAll()
        status "已标记删除服务（待保存）"
        true
    )

    on btnTest pressed do (
        local url = ""
        if curSection != "" do (
            local v = cfg.FieldValue curSection "base_url"
            if v != undefined do url = trimLeft (trimRight (v as string))
        )
        if url.count == 0 do (
            messageBox "当前服务的 base_url 为空，请先在下方字段区填写。" title:"AIhub"
            return false
        )
        btnTest.enabled = false
        btnTest.text = "测试中..."
        status "正在连接..."
        local hp = if cfg.schema == undefined then "" else cfg.schema.HealthPath curSection
        local res = cfg.http.TestService url hp timeoutMs:3000
        btnTest.text = "连接测试"
        btnTest.enabled = true
        local msg = ""
        if res.ok then (
            msg = "可达  HTTP " + (res.status as string) + "  " + (res.elapsedMs as string) + "ms"
        ) else (
            msg = "不可达  " + (if res.error == undefined then "未知错误" else (res.error as string))
            if res.status > 0 do msg += "  HTTP " + (res.status as string)
        )
        if res.bodyPreview != undefined and (res.bodyPreview as string).count > 0 do (
            msg += "  响应: " + (trimDisplay res.bodyPreview 80)
        )
        status msg
        true
    )

    on btnSave pressed do (
        if cfg.HasExternalChange() do (
            if (queryBox "文件已被其他程序修改，仍要覆盖吗？" title:"AIhub") == false do return false
        )
        local res = cfg.Save()
        refreshAll()
        if res[1] then (
            status res[2]
        ) else (
            status ("保存失败: " + res[2])
            messageBox res[2] title:"AIhub"
        )
        true
    )

    on btnRevert pressed do (
        if cfg.IsDirty() and ((queryBox "放弃所有未保存修改？" title:"AIhub") == false) do return false
        cfg.Reload()
        refreshAll()
        status "已撤销未保存的修改"
        true
    )

    on btnReload pressed do (
        if cfg.IsDirty() and ((queryBox "有未保存的修改，重新加载会丢弃这些修改，继续？" title:"AIhub") == false) do return false
        cfg.Reload()
        refreshAll()
        local err = cfg.GetReadError()
        if err != undefined then status ("读取失败: " + err) else status "已重新加载"
        true
    )

    on btnOpenDir pressed do (
        local p = cfg.GetPath()
        if doesFileExist p then (
            ShellLaunch "explorer.exe" ("/select,\"" + p + "\"")
        ) else (
            ShellLaunch "explorer.exe" ("\"" + (getFilenamePath p) + "\"")
        )
        true
    )
)

rollout AIHub_NewSection "新建服务" width:320 height:112
(
    label lblName "服务名" pos:[10,16] width:52 height:16
    editText edName "" pos:[66,14] width:244 height:20
    label lblTip "将生成 [servers:名称] 段，创建后在主窗口填写地址" pos:[10,44] width:300 height:16
    button btnOK "创建" pos:[112,74] width:90 height:26
    button btnCancel "取消" pos:[208,74] width:90 height:26

    on AIHub_NewSection open do (
        edName.text = ""
        setFocus edName
    )

    on btnOK pressed do (
        if (AIHub_Settings.CreateSection edName.text) do destroyDialog AIHub_NewSection
        true
    )

    on btnCancel pressed do (
        destroyDialog AIHub_NewSection
        true
    )
)

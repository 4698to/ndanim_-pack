/*
    AIhub 配置内核
    - 解析 ai_resources.ini，保留注释、空行与行序
    - 以“待保存编辑”的方式修改字段，保存时按差异重写
    - 对其他工具提供只读 API
    - 公共单例只应由 AIHub.ms 创建一次
*/

-- 显式 global：确保 fileIn 后 struct 落在全局作用域
global AIHUB_Line, AIHUB_Parsed, AIHUB_Edit, AIHUB_Lookup
global AIHUB_FieldRow, AIHUB_CustomType, AIHUB_ServerEntry, AIHUB_TextFile, AIHUB_Config

struct AIHUB_Line (
    kind,       -- #blank / #comment / #section / #kv / #other
    raw,
    section,    -- 该行所属的 section；section 行为自身名称
    key,
    keyRaw,     -- 原始键文本，保留大小写
    value
)

struct AIHUB_Parsed (
    lines = #(),
    sections = #(),
    eol = "\r\n"
)

struct AIHUB_Edit (
    target,     -- #key / #section
    section,
    key,
    value,
    isDelete = false,
    kind = undefined
)

struct AIHUB_Lookup (found, value)

struct AIHUB_FieldRow (key, value, present, dirty, kind, readOnly, labelText)

struct AIHUB_CustomType (section, key, kind)

struct AIHUB_ServerEntry (name, url)

struct AIHUB_TextFile (text, encoding)

struct AIHUB_Config (
    path = "C:\\ProgramData\\Autodesk\\ApplicationPlugins\\NDToolsBox\\ai_resources.ini",
    schema = undefined,
    http = undefined,
    _edits = #(),
    _customTypes = #(),
    _lastWrite = "",
    _readError = undefined,

    -- ---------- 文件与编码 ----------

    fn GetPath = this.path,

    fn GetReadError = this._readError,

    fn Ensure = (
        local dir = getFilenamePath this.path
        try (
            makeDir dir all:true
        ) catch ()
        if not (doesFileExist this.path) do (
            try (
                (dotNetClass "System.IO.File").WriteAllText this.path ""
            ) catch (
                return false
            )
        )
        true
    ),

    fn _ReadText = (
        local fallback = (dotNetClass "System.Text.Encoding").Default
        if not (doesFileExist this.path) do return (AIHUB_TextFile "" fallback)
        local text = ""
        local enc = fallback
        this._readError = undefined
        try (
            local sr = dotNetObject "System.IO.StreamReader" this.path fallback true
            text = sr.ReadToEnd()
            enc = sr.CurrentEncoding
            sr.Close()
        ) catch (
            text = ""
            enc = fallback
            this._readError = getCurrentException() as string
        )
        if text == undefined do text = ""
        AIHUB_TextFile text enc
    ),

    fn _Backup = (
        if not (doesFileExist this.path) do return false
        try (
            local b1 = this.path + ".bak1"
            local b2 = this.path + ".bak2"
            local b3 = this.path + ".bak3"
            local io = dotNetClass "System.IO.File"
            if doesFileExist b3 do deleteFile b3
            if doesFileExist b2 do io.Move b2 b3
            if doesFileExist b1 do io.Move b1 b2
            io.Copy this.path b1 true
            true
        ) catch (
            false
        )
    ),

    fn _WriteText text enc = (
        this.Ensure()
        local tmp = this.path + ".tmp"
        (dotNetClass "System.IO.File").WriteAllText tmp text enc
        local replaced = false
        if doesFileExist this.path do (
            try (
                local bak = this.path + ".bak_replace"
                (dotNetClass "System.IO.File").Replace tmp this.path bak
                if doesFileExist bak do deleteFile bak
                replaced = true
            ) catch (
                replaced = false
            )
        )
        if not replaced do (
            (dotNetClass "System.IO.File").Copy tmp this.path true
            if doesFileExist tmp do deleteFile tmp
        )
        true
    ),

    fn GetLastWrite = (
        try (
            local t = (dotNetClass "System.IO.File").GetLastWriteTimeUtc this.path
            t.ToString()
        ) catch ("")
    ),

    -- ---------- 解析 ----------

    fn _SplitLines text = (
        local out = #()
        local cur = ""
        local i = 1
        while i <= text.count do (
            local ch = substring text i 1
            if ch == "\r" then (
                append out cur
                cur = ""
                if (i < text.count) and ((substring text (i + 1) 1) == "\n") do i += 1
            ) else if ch == "\n" then (
                append out cur
                cur = ""
            ) else (
                cur += ch
            )
            i += 1
        )
        append out cur
        out
    ),

    fn _Parse text = (
        local parsed = AIHUB_Parsed()
        parsed.eol = if (findString text "\r\n") != undefined then "\r\n" else "\n"
        local lines = this._SplitLines text
        local curSection = ""
        local seen = #()
        local seenLower = #()
        for raw in lines do (
            local t = trimLeft (trimRight raw)
            local kind = #blank
            local sec = curSection
            local k = undefined
            local kraw = undefined
            local v = undefined
            if t.count == 0 then (
                kind = #blank
            ) else if ((substring t 1 1) == ";") or ((substring t 1 1) == "#") then (
                kind = #comment
            ) else if (t.count >= 2) and ((substring t 1 1) == "[") and ((substring t t.count 1) == "]") then (
                kind = #section
                local name = trimLeft (trimRight (substring t 2 (t.count - 2)))
                curSection = name
                sec = name
                local low = toLower name
                if (findItem seenLower low) == 0 do (
                    append seenLower low
                    append seen name
                )
            ) else (
                local eq = findString t "="
                if eq != undefined then (
                    kind = #kv
                    kraw = trimLeft (trimRight (substring t 1 (eq - 1)))
                    k = kraw
                    if eq < t.count then (
                        v = trimLeft (trimRight (substring t (eq + 1) (t.count - eq)))
                    ) else (
                        v = ""
                    )
                    sec = curSection
                ) else (
                    kind = #other
                )
            )
            append parsed.lines (AIHUB_Line kind raw sec k kraw v)
        )
        parsed.sections = seen
        parsed
    ),

    fn _FindIndex parsed section key = (
        local s = toLower section
        local k = toLower key
        local idx = 0
        local i = 0
        for l in parsed.lines do (
            i += 1
            if (idx == 0) and (l.kind == #kv) and (l.key != undefined) do (
                if (toLower l.section == s) and (toLower l.key == k) do idx = i
            )
        )
        idx
    ),

    fn _Lookup parsed section key = (
        local idx = this._FindIndex parsed section key
        if idx == 0 then (
            AIHUB_Lookup false undefined
        ) else (
            AIHUB_Lookup true parsed.lines[idx].value
        )
    ),

    fn _PendingFor section key = (
        local s = toLower section
        local k = toLower key
        local hit = undefined
        for e in this._edits where (e.target == #key) do (
            if (toLower e.section == s) and (toLower e.key == k) do hit = e
        )
        hit
    ),

    fn _EffectiveLookup parsed section key = (
        local p = this._PendingFor section key
        if p != undefined then (
            if p.isDelete then AIHUB_Lookup false undefined else AIHUB_Lookup true p.value
        ) else (
            this._Lookup parsed section key
        )
    ),

    -- ---------- 只读公共 API ----------

    fn Get section key defaultVal:undefined = (
        local tf = this._ReadText()
        local parsed = this._Parse tf.text
        local r = this._Lookup parsed section key
        if r.found then r.value else defaultVal
    ),

    fn GetUrl section defaultUrl = (
        local v = this.Get section "base_url" defaultVal:defaultUrl
        if v == undefined then return defaultUrl
        if this.http == undefined then return v
        this.http.NormalizeUrl v
    ),

    fn GetInt section key defaultVal = (
        local v = this.Get section key defaultVal:defaultVal
        try (
            v as integer
        ) catch (
            defaultVal
        )
    ),

    fn GetBool section key defaultVal = (
        local v = this.Get section key defaultVal:defaultVal
        if v == undefined then return defaultVal
        local s = toLower (v as string)
        if (s == "1") or (s == "true") or (s == "on") or (s == "yes") then true
        else if (s == "0") or (s == "false") or (s == "off") or (s == "no") then false
        else defaultVal
    ),

    -- ---------- 段落与字段 ----------

    fn _PendingSection section = (
        local s = toLower section
        local hit = undefined
        for e in this._edits where (e.target == #section) do (
            if toLower e.section == s do hit = e
        )
        hit
    ),

    fn Sections = (
        local tf = this._ReadText()
        local parsed = this._Parse tf.text
        local out = #()
        local seen = #()
        for s in parsed.sections do (
            local p = this._PendingSection s
            if (p == undefined) or (not p.isDelete) do (
                append out s
                append seen (toLower s)
            )
        )
        for e in this._edits where (e.target == #section) and (not e.isDelete) do (
            if (findItem seen (toLower e.section)) == 0 do (
                append out e.section
                append seen (toLower e.section)
            )
        )
        if this.schema != undefined do (
            for s in (this.schema.SectionOrder()) do (
                if (findItem seen (toLower s)) == 0 do (
                    append out s
                    append seen (toLower s)
                )
            )
        )
        out
    ),

    fn HasSection section = (
        local s = toLower section
        local hit = false
        for x in (this.Sections()) where (hit == false) do (
            if toLower x == s do hit = true
        )
        hit
    ),

    fn Services = (
        local tf = this._ReadText()
        local parsed = this._Parse tf.text
        local out = #()
        local seen = #()
        for s in (this.Sections()) do (
            local isSvc = false
            if this.schema != undefined do isSvc = this.schema.IsServiceSection s
            if not isSvc do (
                local r = this._EffectiveLookup parsed s "base_url"
                isSvc = r.found
            )
            if isSvc and ((findItem seen (toLower s)) == 0) do (
                append out s
                append seen (toLower s)
            )
        )
        out
    ),

    fn _InferKind value = (
        if value == undefined then return #string
        local s = value as string
        if (findString s "://") != undefined then return #url
        local isInt = false
        try (
            local n = s as integer
            isInt = true
        ) catch (isInt = false)
        if isInt then return #int
        local low = toLower s
        if (low == "true") or (low == "false") then return #bool
        #string
    ),

    fn KindFor section key = (
        local k = undefined
        if this.schema != undefined do k = this.schema.KindFor section key
        if k != undefined do return k
        local s = toLower section
        local kk = toLower key
        for t in this._customTypes where (toLower t.section == s) and (toLower t.key == kk) do k = t.kind
        if k != undefined do return k
        local tf = this._ReadText()
        local parsed = this._Parse tf.text
        local r = this._EffectiveLookup parsed section key
        this._InferKind (if r.found then r.value else undefined)
    ),

    fn _SetCustomType section key kind = (
        local s = toLower section
        local k = toLower key
        local keep = #()
        for t in this._customTypes where not ((toLower t.section == s) and (toLower t.key == k)) do append keep t
        append keep (AIHUB_CustomType section key kind)
        this._customTypes = keep
    ),

    fn Fields section = (
        local tf = this._ReadText()
        local parsed = this._Parse tf.text
        local rows = #()
        local seen = #()
        local s = toLower section

        -- 磁盘已有字段（按文件顺序）
        for l in parsed.lines where (l.kind == #kv) and (l.key != undefined) do (
            if toLower l.section == s do (
                local low = toLower l.key
                if (findItem seen low) == 0 do (
                    append seen low
                    local p = this._PendingFor section l.key
                    if (p == undefined) or (not p.isDelete) do (
                        local val = if p == undefined then l.value else p.value
                        local ro = if this.schema == undefined then false else (this.schema.IsReadOnly section l.key)
                        local lb = if this.schema == undefined then l.key else (this.schema.LabelFor section l.key)
                        append rows (AIHUB_FieldRow l.key val true (p != undefined) (this.KindFor section l.key) ro lb)
                    )
                )
            )
        )

        -- 本次新增、磁盘上还没有的字段
        for e in this._edits where (e.target == #key) and (not e.isDelete) do (
            if toLower e.section == s do (
                local low = toLower e.key
                if (findItem seen low) == 0 do (
                    append seen low
                    local kd = if e.kind != undefined then e.kind else (this.KindFor section e.key)
                    local ro = if this.schema == undefined then false else (this.schema.IsReadOnly section e.key)
                    local lb = if this.schema == undefined then e.key else (this.schema.LabelFor section e.key)
                    append rows (AIHUB_FieldRow e.key e.value true true kd ro lb)
                )
            )
        )

        -- 内置 schema 中尚未出现的字段
        if this.schema != undefined do (
            for d in (this.schema.DefsForSection section) do (
                local low = toLower d.key
                if (findItem seen low) == 0 do (
                    append seen low
                    local p = this._PendingFor section d.key
                    if (p == undefined) or (not p.isDelete) do (
                        append rows (AIHUB_FieldRow d.key d.defaultVal false false d.kind d.readOnly d.labelText)
                    )
                )
            )
        )
        rows
    ),

    fn FieldValue section key = (
        local tf = this._ReadText()
        local parsed = this._Parse tf.text
        local r = this._EffectiveLookup parsed section key
        if r.found then r.value else undefined
    ),

    fn PendingFor section key = (
        this._PendingFor section key
    ),

    fn IsDirty = this._edits.count > 0,

    fn PendingCount = this._edits.count,

    fn ClearEdits = (
        this._edits = #()
        this._customTypes = #()
        true
    ),

    -- ---------- 编辑 ----------

    fn _Trim s = trimLeft (trimRight (s as string)),

    fn NormalizeValue section key value kind = (
        if value == undefined then return undefined
        local v = this._Trim value
        if kind == #url do (
            if this.http != undefined do v = this.http.NormalizeUrl v
        )
        if kind == #bool do (
            local low = toLower v
            if (low == "1") or (low == "true") or (low == "on") or (low == "yes") then v = "1"
            else if (low == "0") or (low == "false") or (low == "off") or (low == "no") then v = "0"
        )
        v
    ),

    fn SetValue section key value del:false kind:undefined = (
        local kd = kind
        if kd == undefined do kd = this.KindFor section key
        local val = value
        if not del do val = this.NormalizeValue section key value kd
        local s = toLower section
        local k = toLower key
        local keep = #()
        for e in this._edits do (
            if not ((e.target == #key) and (toLower e.section == s) and (toLower e.key == k)) do append keep e
        )
        append keep (AIHUB_Edit #key section key val del kd)
        this._edits = keep
        if kind != undefined do this._SetCustomType section key kind
        true
    ),

    fn DeleteKey section key = (
        this.SetValue section key undefined del:true
    ),

    fn AddSection section = (
        local s = toLower section
        local keep = #()
        for e in this._edits do (
            if not ((e.target == #section) and (toLower e.section == s)) do append keep e
        )
        append keep (AIHUB_Edit #section section undefined undefined false undefined)
        this._edits = keep
        true
    ),

    fn DeleteSection section = (
        local s = toLower section
        local keep = #()
        for e in this._edits do (
            local sameSection = ((e.target == #section) and (toLower e.section == s))
            local sameKey = ((e.target == #key) and (toLower e.section == s))
            if not (sameSection or sameKey) do append keep e
        )
        append keep (AIHUB_Edit #section section undefined undefined true undefined)
        this._edits = keep
        true
    ),

    -- ---------- 校验 ----------

    fn IsValidName name = (
        if name == undefined then return false
        local s = name as string
        if s.count == 0 then return false
        if (findString s "[") != undefined then return false
        if (findString s "]") != undefined then return false
        if (findString s "=") != undefined then return false
        if (findString s ";") != undefined then return false
        if (findString s "#") != undefined then return false
        true
    ),

    fn ValidateValue section key value kind = (
        local v = if value == undefined then "" else (trimLeft (trimRight (value as string)))
        if kind == undefined do kind = #string
        if kind == #url do (
            if (this.http == undefined) or (not (this.http.IsValidUrl v)) do return "地址必须以 http:// 或 https:// 开头，且 host 不能为空"
            return undefined
        )
        if kind == #int do (
            local n = undefined
            try (n = v as integer) catch (n = undefined)
            if n == undefined do return "必须是整数"
            if this.schema != undefined do (
                local d = this.schema.Find section key
                if d != undefined do (
                    if (d.minVal != undefined) and (n < d.minVal) do return ("不能小于 " + (d.minVal as string))
                    if (d.maxVal != undefined) and (n > d.maxVal) do return ("不能大于 " + (d.maxVal as string))
                )
            )
            return undefined
        )
        if kind == #bool do (
            local low = toLower v
            if (low == "1") or (low == "0") or (low == "true") or (low == "false") or (low == "on") or (low == "off") or (low == "yes") or (low == "no") then return undefined
            return "布尔值只能填 1/0、true/false、on/off、yes/no"
        )
        if kind == #enum do (
            local opts = if this.schema == undefined then #() else (this.schema.OptionsFor section key)
            if opts.count == 0 then return undefined
            for o in opts where (toLower o == toLower v) do return undefined
            return ("只能是: " + (opts as string))
        )
        if kind == #tristate do (
            if (v == "") or (v == "0") or (v == "1") then return undefined
            return "只能是 0、1 或未设置"
        )
        undefined
    ),

    fn Validate = (
        local msgs = #()
        for e in this._edits do (
            if e.target == #section then (
                if (not e.isDelete) and (not (this.IsValidName e.section)) do append msgs ("非法服务名: " + (e.section as string))
            ) else (
                local secOk = this.IsValidName e.section
                local keyOk = this.IsValidName e.key
                if not secOk do append msgs ("非法 section: " + (e.section as string))
                if not keyOk do append msgs ("非法字段名: " + (e.key as string))
                if secOk and keyOk and (not e.isDelete) do (
                    local kd = if e.kind != undefined then e.kind else (this.KindFor e.section e.key)
                    local err = this.ValidateValue e.section e.key e.value kd
                    if err != undefined do append msgs ((e.section as string) + "." + (e.key as string) + ": " + err)
                )
            )
        )
        if msgs.count == 0 then #(true, "") else #(false, msgs[1])
    ),

    -- ---------- 服务器列表 ----------

    fn ListSection service = (
        if (toLower service) == "vipose_sam3d_service" then "servers" else ("servers:" + service)
    ),

    fn ServerLabel url = (
        local u = if this.http == undefined then (url as string) else (this.http.NormalizeUrl url)
        local rest = u
        local low = toLower u
        if low.count > 7 and (substring low 1 7) == "http://" then (
            rest = substring u 8 (u.count - 7)
        ) else if low.count > 8 and (substring low 1 8) == "https://" then (
            rest = substring u 9 (u.count - 8)
        )
        local slash = findString rest "/"
        if slash != undefined do rest = substring rest 1 (slash - 1)
        if rest.count == 0 then u else rest
    ),

    fn GetServers service = (
        local tf = this._ReadText()
        local parsed = this._Parse tf.text
        local ls = this.ListSection service
        local count = 0
        local cr = this._EffectiveLookup parsed ls "count"
        if cr.found do (try (count = cr.value as integer) catch (count = 0))
        if count <= 0 do (
            -- 手改文件可能没有 count，退化为探测 url1..urlN
            local probe = 1
            while probe <= 100 do (
                local pr = this._EffectiveLookup parsed ls ("url" + (probe as string))
                if not pr.found then exit
                count = probe
                probe += 1
            )
        )
        local out = #()
        local seenUrls = #()
        for i = 1 to count do (
            local nr = this._EffectiveLookup parsed ls ("name" + (i as string))
            local ur = this._EffectiveLookup parsed ls ("url" + (i as string))
            if ur.found and (ur.value != undefined) and ((ur.value as string).count > 0) do (
                local url = ur.value
                local low = toLower url
                if (findItem seenUrls low) == 0 do (
                    append seenUrls low
                    local nm = if nr.found then nr.value else ""
                    if (nm == undefined) or ((nm as string).count == 0) do nm = this.ServerLabel url
                    append out (AIHUB_ServerEntry nm url)
                )
            )
        )
        out
    ),

    fn SetServers service entries = (
        if entries.count == 0 do return false
        local old = this.GetServers service
        local ls = this.ListSection service
        local n = entries.count
        local total = amax old.count n
        for i = 1 to total do (
            if i <= n then (
                this.SetValue ls ("name" + (i as string)) entries[i].name
                this.SetValue ls ("url" + (i as string)) entries[i].url
            ) else (
                this.DeleteKey ls ("name" + (i as string))
                this.DeleteKey ls ("url" + (i as string))
            )
        )
        this.SetValue ls "count" (n as string)
        true
    ),

    fn UpsertServer service url name:"" = (
        if (this.http != undefined) and (not (this.http.IsValidUrl url)) do return false
        local entries = this.GetServers service
        local norm = if this.http == undefined then url else (this.http.NormalizeUrl url)
        local found = 0
        local i = 0
        for s in entries do (
            i += 1
            if (toLower s.url) == (toLower norm) do found = i
        )
        local nm = if name == undefined then "" else name
        if (nm as string).count == 0 do nm = this.ServerLabel norm
        if found > 0 then (
            entries[found] = AIHUB_ServerEntry nm norm
        ) else (
            append entries (AIHUB_ServerEntry nm norm)
        )
        this.SetServers service entries
    ),

    fn RemoveServer service index = (
        local entries = this.GetServers service
        if entries.count <= 1 do return false
        if (index < 1) or (index > entries.count) do return false
        deleteItem entries index
        this.SetServers service entries
    ),

    fn SetActiveServer service url name:"" = (
        local nm = if name == undefined then "" else name
        if (nm as string).count == 0 do nm = this.ServerLabel url
        this.SetValue service "base_url" url
        this.SetValue service "server_name" nm
        true
    ),

    -- ---------- 保存 ----------

    fn _BuildText parsed = (
        local outLines = for ln in parsed.lines collect ln.raw
        local removeLines = for ln in outLines collect false

        local deletedSections = #()
        for e in this._edits where (e.target == #section) and e.isDelete do append deletedSections (toLower e.section)

        local curSection = ""
        for lineIdx = 1 to parsed.lines.count do (
            local l0 = parsed.lines[lineIdx]
            if l0.kind == #section do curSection = toLower l0.section
            if (findItem deletedSections curSection) > 0 do removeLines[lineIdx] = true
        )

        local applied = for e in this._edits collect false
        local eIdx = 0
        for e in this._edits do (
            eIdx += 1
            if e.target == #key do (
                local sLow = toLower e.section
                local kLow = toLower e.key
                local target = 0
                for lineIdx = 1 to parsed.lines.count do (
                    local l1 = parsed.lines[lineIdx]
                    if (target == 0) and (l1.kind == #kv) and (l1.key != undefined) do (
                        if (toLower l1.section == sLow) and (toLower l1.key == kLow) do target = lineIdx
                    )
                )
                if target > 0 then (
                    if e.isDelete then (
                        removeLines[target] = true
                    ) else (
                        local l2 = parsed.lines[target]
                        local keyText = if l2.keyRaw != undefined then l2.keyRaw else l2.key
                        outLines[target] = keyText + "=" + (e.value as string)
                    )
                    applied[eIdx] = true
                )
            )
        )

        -- 新增字段按 section 分组，插入到该段最后一个非空行之后
        local inserts = #()
        local newSections = #()
        eIdx = 0
        for e in this._edits do (
            eIdx += 1
            if (e.target == #key) and (not applied[eIdx]) and (not e.isDelete) do (
                local sLow2 = toLower e.section
                if (findItem deletedSections sLow2) == 0 do (
                    local start = 0
                    local nextStart = 0
                    for lineIdx = 1 to parsed.lines.count do (
                        local l3 = parsed.lines[lineIdx]
                        if l3.kind == #section do (
                            if (start == 0) and (toLower l3.section == sLow2) then (
                                start = lineIdx
                            ) else if (start > 0) and (nextStart == 0) then (
                                nextStart = lineIdx
                            )
                        )
                    )
                    local newLine = (e.key as string) + "=" + (e.value as string)
                    if start == 0 then (
                        local found = 0
                        local n = 0
                        for ns in newSections do (
                            n += 1
                            if toLower ns[1] == sLow2 do found = n
                        )
                        if found > 0 then (
                            append newSections[found][2] newLine
                        ) else (
                            append newSections #(e.section, #(newLine))
                        )
                    ) else (
                        local endIdx = if nextStart > 0 then (nextStart - 1) else parsed.lines.count
                        local insertAfter = start
                        local q = endIdx
                        while q > start do (
                            if (not removeLines[q]) and (parsed.lines[q].kind != #blank) do (
                                insertAfter = q
                                q = start
                            )
                            q -= 1
                        )
                        append inserts #(insertAfter, newLine)
                    )
                )
            )
        )

        -- 只新建了服务、还没有字段的段，也要保留段头
        for e in this._edits where (e.target == #section) and (not e.isDelete) do (
            local sLow3 = toLower e.section
            if (findItem deletedSections sLow3) == 0 do (
                local found2 = false
                for ns2 in newSections where (toLower ns2[1] == sLow3) do found2 = true
                if not found2 do append newSections #(e.section, #())
            )
        )

        local finalLines = #()
        for lineIdx = 1 to outLines.count do (
            if not removeLines[lineIdx] do append finalLines outLines[lineIdx]
            for ins in inserts where ins[1] == lineIdx do append finalLines ins[2]
        )

        for ns in newSections do (
            if (finalLines.count > 0) and ((trimLeft (trimRight finalLines[finalLines.count])).count > 0) do append finalLines ""
            append finalLines ("[" + (ns[1] as string) + "]")
            for t in ns[2] do append finalLines t
        )

        local result = ""
        if finalLines.count > 0 do (
            result = finalLines[1]
            for lineIdx = 2 to finalLines.count do result = result + parsed.eol + finalLines[lineIdx]
        )
        result
    ),

    fn Save = (
        local v = this.Validate()
        if not v[1] do return v
        local tf = this._ReadText()
        if this._readError != undefined do return #(false, "读取失败，已取消保存: " + this._readError)
        local parsed = this._Parse tf.text
        local text = this._BuildText parsed
        if (doesFileExist this.path) and (not (this._Backup())) do return #(false, "备份失败，已取消保存")
        try (
            this._WriteText text tf.encoding
        ) catch (
            return #(false, "写入失败: " + (getCurrentException() as string))
        )
        this._edits = #()
        this._customTypes = #()
        this._lastWrite = this.GetLastWrite()
        #(true, "已保存")
    ),

    fn Reload = (
        this._edits = #()
        this._customTypes = #()
        this._lastWrite = this.GetLastWrite()
        true
    ),

    fn HasExternalChange = (
        local cur = this.GetLastWrite()
        (this._lastWrite != "") and (cur != "") and (cur != this._lastWrite)
    )
)

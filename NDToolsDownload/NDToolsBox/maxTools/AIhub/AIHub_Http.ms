/*
    AIhub 通用连接测试
    只判断 HTTP 可达性，不解析业务协议、不发送凭据，也不依赖 ImagePose 的客户端。
*/

-- 显式 global：确保 fileIn 后 struct 落在全局作用域
global AIHUB_HttpResult, AIHUB_Http

struct AIHUB_HttpResult (
    ok = false,
    status = -1,
    statusText = "",
    elapsedMs = 0,
    bodyPreview = "",
    error = undefined
)

struct AIHUB_Http (
    fn IsValidUrl url = (
        if url == undefined then return false
        local u = trimLeft (trimRight (url as string))
        if u.count < 8 then return false
        if (findString u " ") != undefined then return false
        local lower = toLower u
        local rest = undefined
        if (substring lower 1 7) == "http://" then (
            rest = substring u 8 (u.count - 7)
        ) else if u.count > 8 and (substring lower 1 8) == "https://" then (
            rest = substring u 9 (u.count - 8)
        ) else (
            return false
        )
        if rest == undefined or rest.count == 0 then return false
        local slash = findString rest "/"
        local host = if slash == undefined then rest else (substring rest 1 (slash - 1))
        host.count > 0
    ),

    fn NormalizeUrl url = (
        if url == undefined then return ""
        local u = trimLeft (trimRight (url as string))
        while u.count > 8 and (substring u u.count 1) == "/" do (
            u = substring u 1 (u.count - 1)
        )
        u
    ),

    fn JoinUrl baseUrl subPath = (
        local b = this.NormalizeUrl baseUrl
        local p = if subPath == undefined then "" else (trimLeft (trimRight (subPath as string)))
        if p == "" then return b
        if (substring p 1 1) == "/" then (b + p) else (b + "/" + p)
    ),

    fn Test url timeoutMs:3000 = (
        local res = AIHUB_HttpResult()
        local u = if url == undefined then "" else (trimLeft (trimRight (url as string)))
        if not (this.IsValidUrl u) do (
            res.error = "地址必须以 http:// 或 https:// 开头，且 host 不能为空"
            return res
        )
        local sw = dotNetObject "System.Diagnostics.Stopwatch"
        sw.Start()
        local resp = undefined
        try (
            local req = (dotNetClass "System.Net.WebRequest").Create u
            req.Method = "GET"
            req.Timeout = timeoutMs
            req.ReadWriteTimeout = timeoutMs
            try (
                req.Proxy = (dotNetClass "System.Net.GlobalProxySelection").GetEmptyWebProxy()
            ) catch ()
            try (
                local spm = dotNetClass "System.Net.ServicePointManager"
                local tp = dotNetClass "System.Net.SecurityProtocolType"
                spm.SecurityProtocol = tp.Tls12
            ) catch ()
            resp = req.GetResponse()
            res.ok = true
            try (
                res.status = (dotNetClass "System.Convert").ToInt32 resp.StatusCode
            ) catch (res.status = -1)
            res.statusText = resp.StatusCode as string
            local stream = resp.GetResponseStream()
            local sr = dotNetObject "System.IO.StreamReader" stream
            local body = sr.ReadToEnd()
            sr.Close()
            resp.Close()
            if body == undefined do body = ""
            if body.count > 200 do body = substring body 1 200
            res.bodyPreview = body
        ) catch (
            local ex = getCurrentException()
            res.error = ex as string
            -- 4xx/5xx 也会进入 catch；能取到响应即视为服务器可达
            try (
                local we = ex
                if we.Response != undefined do (
                    res.ok = true
                    res.error = undefined
                    try (
                        res.status = (dotNetClass "System.Convert").ToInt32 we.Response.StatusCode
                    ) catch (res.status = -1)
                    res.statusText = we.Response.StatusCode as string
                    local rs = we.Response.GetResponseStream()
                    local sr2 = dotNetObject "System.IO.StreamReader" rs
                    local b2 = sr2.ReadToEnd()
                    sr2.Close()
                    we.Response.Close()
                    if b2.count > 200 do b2 = substring b2 1 200
                    res.bodyPreview = b2
                )
            ) catch ()
        )
        sw.Stop()
        try (res.elapsedMs = sw.ElapsedMilliseconds as integer) catch (res.elapsedMs = 0)
        res
    ),

    fn TestService baseUrl healthPath timeoutMs:3000 = (
        this.Test (this.JoinUrl baseUrl healthPath) timeoutMs:timeoutMs
    )
)

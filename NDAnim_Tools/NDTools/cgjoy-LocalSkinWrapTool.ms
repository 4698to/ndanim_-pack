/*
https://www.cgjoy.com/forum.php?mod=viewthread&tid=283124&extra=page%3D1%26filter%3Dsortid%26sortid%3D123

 *  局部蒙皮包裹工具 v2.1 (Fast)
 *  功能: 把"来源顶点"的蒙皮权重按空间位置传递给"目标顶点"
 *
 *  使用流程:
 *    1. 选中带 Skin 的物体, 进入 Skin 顶点子层级, 选择需要"处理"的顶点 -> 按钮1 记录目标
 *    2. 选中带 Skin 的物体(可同物体/不同物体), 选择作为"包裹来源"的顶点 -> 按钮2 记录来源(位置+权重)
 *    3. 按钮3 计算并传递: 每个目标顶点取最近 K 个来源点, 按衰减加权混合后写入
 *    4. 若目标 Skin 缺少来源骨骼, 会列出缺失骨骼并询问是否按同名对象添加进 Skin
 *
 *  相对 v1.0 的算法优化:
 *    * 均匀网格改为"计数排序桶"结构(整型线性下标 + 两个平铺数组),
 *      彻底去掉字符串 key 与 .NET Hashtable, 建表 O(n) 一次完成
 *    * 邻域查询改为"逐层壳扩张 + 半径保证提前终止", 不再重复扫描内层格子
 *    * K 近邻改为固定长度插入排序(O(m·K)), 取代 qsort + 回调比较 + 逐候选临时数组
 *    * 坐标拆成 x/y/z 平铺 float 数组, 避免每次比较都构造 Point3
 *    * 骨骼映射(来源骨骼 -> 目标骨骼)在开始时一次算好, 累加用"骨骼ID 直接下标 + 脏表回滚",
 *      循环内不再有 findItem / 哈希查询
 *    * 网格在"记录来源"时构建并缓存, 反复调参传递时不再重建
 *    * 写权重时退出子层级 + disableSceneRedraw, 避免每次写入刷新权重色
 *    * 目标点坐标一次性快照取出, 立即释放 snapshotAsMesh 网格
 *    * 位置几乎重合的顶点直接整份拷贝权重(更快也更准)
 *    * 支持进度条与 ESC 取消, 可选是否记录撤销
 *
 *  说明: 顶点匹配基于世界空间位置(snapshotAsMesh), 适用于来源/目标几何在空间上重叠的包裹场景
 *
 *  v2.1: 所有函数与状态变量改为 rollout 局部作用域, 不再使用 global,
 *        仅保留两个 struct 类型定义(MAXScript 中 struct 为全局类型), 便于嵌入其他脚本
 */

-- ============================================
-- 清理旧实例
-- ============================================
try (destroyDialog FT_LWT2_rol) catch()

-- ============================================
-- 数据结构 (struct 为全局类型定义, 仅此两处)
-- ============================================
-- 桶式均匀网格: cellStart[c]..cellStart[c+1]-1 为第 c 个格子在 items 中的区间
struct FT_LWT2_Grid (nx, ny, nz, minx, miny, minz, cell, invc, cellStart, items)
-- 传递任务参数包: 避免嵌套函数引用外层局部变量
struct FT_LWT2_Job (sk, tvs, nt, tx, ty, tz, grid, sx, sy, sz, sbi, sw, boneMap, nsb, range, falloff, kn, maxInf)

rollout FT_LWT2_rol "局部蒙皮包裹工具 v2.1 (Fast)" width:240
(
    -- ============================================
    -- 状态变量 (rollout 局部, 不再使用 global)
    -- ============================================
    local srcX = #()           -- 来源顶点世界坐标(平铺)
    local srcY = #()
    local srcZ = #()
    local srcBI = #()          -- 每个来源顶点: 骨骼ID数组(来源 Skin 内的索引)
    local srcW  = #()          -- 每个来源顶点: 归一化权重数组
    local srcBoneNames = #()   -- 来源 Skin 骨骼ID -> 骨骼名(仅用到的填充)
    local srcGrid = undefined  -- 缓存的空间网格
    local targetNode = undefined
    local targetVerts = #()
    local lastMS = 0           -- 上次传递耗时(毫秒)
    local backNode = undefined -- 手动撤销: 备份的目标物体
    local backVerts = #()      -- 手动撤销: 备份的目标顶点
    local backWeights = #()    -- 手动撤销: 备份的权重数据

    -- ============================================
    -- UI
    -- ============================================
    label    lbHelp  "选择带 Skin 物体并进入顶点层级" align:#center
    button   btn1    "1. 记录处理顶点 (目标)" width:216 height:30
    button   btn2    "2. 记录包裹顶点 (来源)" width:216 height:30
    button   btn3    "3. 计算并传递权重"      width:216 height:34

    group "衰减与影响范围"
    (
        spinner  spnRange "影响范围(0=无限):" range:[0.0, 1e7, 0.0] type:#worldUnits fieldwidth:60
        spinner  spnFall  "衰减指数:"        range:[0.01, 10.0, 2.0] type:#float scale:0.1 fieldwidth:60
        spinner  spnK     "采样点数K:"       range:[1, 32, 4] type:#integer fieldwidth:60
        spinner  spnMaxI  "最大骨骼数(0=不限):" range:[0, 32, 0] type:#integer fieldwidth:60
        checkbox chkUndo  "备份权重(可撤销)" checked:true
    )

    label lbTgt "目标顶点: 0" align:#left
    label lbSrc "来源顶点: 0" align:#left
    label lbTime "耗时: -" align:#left
    button btnClr "清空记录" width:216 height:22
    button btnUndo "撤销传递" width:216 height:22 enabled:false

    -- ============================================
    -- 辅助函数
    -- ============================================
    fn getSkin node =
    (
        local res = undefined
        if isValidNode node do
        (
            for m in node.modifiers while res == undefined do
                if (classof m == Skin) do res = m
        )
        res
    )

    -- skinOps 大多数操作要求物体被选中且 Skin 处于修改面板当前层级
    -- vertLevel:true 进入顶点/封套子层级(读取选择用), false 保持 0 级(批量写权重更快)
    fn prep node sk vertLevel:true =
    (
        if not (isValidNode node) or sk == undefined do return false
        if selection.count != 1 or selection[1] != node do select node
        max modify mode
        modPanel.setCurrentObject sk
        -- 记录并恢复当前选中的封套(骨骼), 保证回到蒙皮姿势时封套仍被选中
        local prevBone = 0
        try (prevBone = skinOps.GetSelectedBone sk) catch ()
        local lv = if vertLevel then 1 else 0
        if subobjectLevel != lv do subobjectLevel = lv
        if prevBone != undefined and prevBone > 0 do (try (skinOps.SelectBone sk prevBone) catch ())
        true
    )

    -- 返回 Skin 中当前选中的顶点索引数组(升序)
    -- 按返回值类型分派到两个专用循环, 省掉每次迭代的双重比较
    fn getSelVerts sk =
    (
        local nv = skinOps.GetNumberVertices sk
        if nv == undefined or nv <= 0 do return #()

        local probe = undefined
        local _ok = true
        try (probe = skinOps.IsVertexSelected sk 1) catch (_ok = false)
        if not _ok do return #()

        local ba = #{}
        if (classof probe) == BooleanClass then
        (
            for i = 1 to nv do if (skinOps.IsVertexSelected sk i) do ba[i] = true
        )
        else
        (
            for i = 1 to nv do if (skinOps.IsVertexSelected sk i) == 1 do ba[i] = true
        )
        ba as array
    )

    -- ============================================
    -- 空间加速网格 (桶式均匀网格, 计数排序建表)
    -- ============================================
    fn buildGrid sx sy sz maxCells:262144 =
    (
        local n = sx.count
        if n == 0 do return undefined

        local mnx = sx[1]; local mxx = sx[1]
        local mny = sy[1]; local mxy = sy[1]
        local mnz = sz[1]; local mxz = sz[1]
        for i = 2 to n do
        (
            local v = sx[i]
            if v < mnx then mnx = v else (if v > mxx do mxx = v)
            v = sy[i]
            if v < mny then mny = v else (if v > mxy do mxy = v)
            v = sz[i]
            if v < mnz then mnz = v else (if v > mxz do mxz = v)
        )

        local dx = mxx - mnx; local dy = mxy - mny; local dz = mxz - mnz
        local diag = sqrt (dx * dx + dy * dy + dz * dz)
        if diag < 1e-5 do diag = 1.0

        -- 初始边长按体积密度估计, 但蒙皮点云多为面状分布(实际占用率远高于估算),
        -- 因此下面用真实占用率自适应细分, 直到平均每格约几个点
        local cell = 2.0 * diag / ((n as float) ^ (1.0 / 3.0))
        if cell < 1e-4 do cell = 1e-4

        local nx, ny, nz, nxy, nc, invc, counts, ci
        local attempt = 0
        while true do
        (
            attempt += 1
            nx = ((floor (dx / cell)) as integer) + 1
            ny = ((floor (dy / cell)) as integer) + 1
            nz = ((floor (dz / cell)) as integer) + 1
            -- 格子总数封顶, 防止细长/稀疏点云爆内存
            local capped = false
            while ((nx as float) * ny * nz) > maxCells do
            (
                cell *= 1.6
                capped = true
                nx = ((floor (dx / cell)) as integer) + 1
                ny = ((floor (dy / cell)) as integer) + 1
                nz = ((floor (dz / cell)) as integer) + 1
            )

            invc = 1.0 / cell
            nxy = nx * ny
            nc = nxy * nz

            -- 1) 统计每格点数
            counts = for c = 1 to nc collect 0
            ci = #(); ci.count = n
            for i = 1 to n do
            (
                local ix = (floor ((sx[i] - mnx) * invc)) as integer
                local iy = (floor ((sy[i] - mny) * invc)) as integer
                local iz = (floor ((sz[i] - mnz) * invc)) as integer
                if ix < 0 do ix = 0
                if iy < 0 do iy = 0
                if iz < 0 do iz = 0
                if ix > nx - 1 do ix = nx - 1
                if iy > ny - 1 do iy = ny - 1
                if iz > nz - 1 do iz = nz - 1
                local c = ix + iy * nx + iz * nxy + 1
                ci[i] = c
                counts[c] += 1
            )

            -- 非空格子的平均点数过高 -> 边长减半重建
            local occ = 0
            for c = 1 to nc do if counts[c] > 0 do occ += 1
            local meanOcc = if occ > 0 then ((n as float) / occ) else 1.0
            if meanOcc <= 6.0 or capped or attempt >= 5 do exit
            cell *= 0.5
        )

        -- 2) 前缀和得到每格起始位置
        local cellStart = #(); cellStart.count = nc + 1
        cellStart[1] = 1
        for c = 1 to nc do cellStart[c + 1] = cellStart[c] + counts[c]

        -- 3) 回填点索引(counts 清零后当作每格的填充偏移, 省一个数组)
        for c = 1 to nc do counts[c] = 0
        local items = #(); items.count = n
        for i = 1 to n do
        (
            local c = ci[i]
            items[cellStart[c] + counts[c]] = i
            counts[c] += 1
        )

        FT_LWT2_Grid nx:nx ny:ny nz:nz minx:mnx miny:mny minz:mnz cell:cell invc:invc \
            cellStart:cellStart items:items
    )

    -- K 近邻: 逐层壳扩张, 结果写入复用数组 bd(距离平方,升序)/bi(来源索引), 返回实际个数
    -- maxD > 0 表示只接受该半径内的点; maxD <= 0 为不限半径
    fn knn g sx sy sz px py pz kn maxD bd bi =
    (
        local nx = g.nx; local ny = g.ny; local nz = g.nz
        local cs = g.cellStart; local items = g.items
        local cell = g.cell; local invc = g.invc
        local nxy = nx * ny

        local cx = (floor ((px - g.minx) * invc)) as integer
        local cy = (floor ((py - g.miny) * invc)) as integer
        local cz = (floor ((pz - g.minz) * invc)) as integer
        if cx < 0 do cx = 0
        if cy < 0 do cy = 0
        if cz < 0 do cz = 0
        if cx > nx - 1 do cx = nx - 1
        if cy > ny - 1 do cy = ny - 1
        if cz > nz - 1 do cz = nz - 1

        local cnt = 0
        local worst = 1e30
        local maxD2 = if maxD > 0 then (maxD * maxD) else -1.0

        -- 覆盖整个网格所需的最大层数; 有半径限制时再收紧
        local rLimit = amax (amax (amax cx (nx - 1 - cx)) (amax cy (ny - 1 - cy))) (amax cz (nz - 1 - cz))
        if maxD > 0 do
        (
            local rd = ((ceil (maxD * invc)) as integer) + 1
            if rd < rLimit do rLimit = rd
        )

        local r = 0
        while r <= rLimit do
        (
            local x0 = cx - r; local x1 = cx + r
            local y0 = cy - r; local y1 = cy + r
            local z0 = cz - r; local z1 = cz + r
            if x0 < 0 do x0 = 0
            if y0 < 0 do y0 = 0
            if z0 < 0 do z0 = 0
            if x1 > nx - 1 do x1 = nx - 1
            if y1 > ny - 1 do y1 = ny - 1
            if z1 > nz - 1 do z1 = nz - 1

            for ix = x0 to x1 do
            (
                local ax = abs (ix - cx)
                for iy = y0 to y1 do
                (
                    local axy = amax ax (abs (iy - cy))
                    local base = ix + iy * nx + 1
                    for iz = z0 to z1 do
                    (
                        -- 只处理第 r 层壳, 内层在之前的迭代已扫过
                        if axy == r or (abs (iz - cz)) == r do
                        (
                            local c = base + iz * nxy
                            for t = cs[c] to (cs[c + 1] - 1) do
                            (
                                local si = items[t]
                                local ddx = sx[si] - px
                                local ddy = sy[si] - py
                                local ddz = sz[si] - pz
                                local d2 = ddx * ddx + ddy * ddy + ddz * ddz
                                if (maxD2 < 0.0 or d2 <= maxD2) and (cnt < kn or d2 < worst) do
                                (
                                    local pos
                                    if cnt < kn then (cnt += 1; pos = cnt) else pos = kn
                                    -- 定长插入排序: 把更大的往后挪, 腾出 d2 的位置
                                    while pos > 1 do
                                    (
                                        if bd[pos - 1] <= d2 do exit
                                        bd[pos] = bd[pos - 1]
                                        bi[pos] = bi[pos - 1]
                                        pos -= 1
                                    )
                                    bd[pos] = d2
                                    bi[pos] = si
                                    if cnt >= kn do worst = bd[kn]
                                )
                            )
                        )
                    )
                )
            )

            -- 已凑满 K 个, 且第 r 层的保证半径已超过当前最远采样点 -> 外层不可能更近
            if cnt >= kn and worst <= (r * cell) * (r * cell) do exit
            r += 1
        )
        cnt
    )

    -- ============================================
    -- 按钮1: 记录处理顶点(目标)
    -- ============================================
    fn recordTarget =
    (
        if selection.count != 1 do (messagebox "请仅选择一个带 Skin 的物体"; return 0)
        local node = selection[1]
        local sk = getSkin node
        if sk == undefined do (messagebox "所选物体没有 Skin 修改器"; return 0)
        if not (prep node sk) do return 0
        local verts = getSelVerts sk
        if verts.count == 0 do (messagebox "请先在 Skin 顶点子层级选择需要处理的顶点"; return 0)
        targetNode = node
        targetVerts = verts
        verts.count
    )

    -- ============================================
    -- 按钮2: 记录包裹顶点(来源: 位置 + 权重), 并构建空间网格
    -- ============================================
    fn recordSource =
    (
        if selection.count != 1 do (messagebox "请仅选择一个带 Skin 的物体"; return 0)
        local node = selection[1]
        local sk = getSkin node
        if sk == undefined do (messagebox "所选物体没有 Skin 修改器"; return 0)
        if not (prep node sk) do return 0
        local verts = getSelVerts sk
        if verts.count == 0 do (messagebox "请先在 Skin 顶点子层级选择作为来源的顶点"; return 0)

        local nbSrc = skinOps.GetNumberBones sk
        local names = #(); names.count = nbSrc
        local n = verts.count
        local sx = #(); sx.count = n
        local sy = #(); sy.count = n
        local sz = #(); sz.count = n
        local sbi = #(); sbi.count = n
        local sw = #(); sw.count = n

        local msh = snapshotAsMesh node   -- 世界空间(含变形)网格
        local err = undefined
        try
        (
            for i = 1 to n do
            (
                local vi = verts[i]
                local p = getVert msh vi
                sx[i] = p.x; sy[i] = p.y; sz[i] = p.z

                local wc = skinOps.GetVertexWeightCount sk vi
                local bb = #(); local ww = #()
                local sum = 0.0
                for b = 1 to wc do
                (
                    local w = skinOps.GetVertexWeight sk vi b
                    if w > 1e-5 do
                    (
                        local bid = skinOps.GetVertexWeightBoneID sk vi b
                        if bid >= 1 and bid <= nbSrc do
                        (
                            if names[bid] == undefined do names[bid] = skinOps.GetBoneName sk bid 0
                            append bb bid
                            append ww w
                            sum += w
                        )
                    )
                )
                -- 记录时先归一化, 后续混合只需处理相对比例
                if sum > 0.0 do for k = 1 to ww.count do ww[k] = ww[k] / sum
                sbi[i] = bb
                sw[i] = ww
            )
        )
        catch (err = getCurrentException())
        try (delete msh) catch ()
        if err != undefined do (messagebox ("读取来源权重失败:\n" + err); return 0)

        srcX = sx
        srcY = sy
        srcZ = sz
        srcBI = sbi
        srcW = sw
        srcBoneNames = names
        srcGrid = buildGrid sx sy sz   -- 网格缓存, 反复调参不再重建
        n
    )

    -- ============================================
    -- 传递主循环
    --   MAXScript 不允许嵌套函数引用外层函数的局部变量, 所以运行参数用 FT_LWT2_Job 打包;
    --   进入后先拷进局部变量, 热循环里不走结构体成员访问
    --   返回 #(写入顶点数, 是否被取消)
    -- ============================================
    fn transfer job =
    (
        local sk = job.sk
        local tvs = job.tvs
        local nt = job.nt
        local tx = job.tx; local ty = job.ty; local tz = job.tz
        local grid = job.grid
        local sx = job.sx; local sy = job.sy; local sz = job.sz
        local sbi = job.sbi; local sw = job.sw
        local boneMap = job.boneMap
        local range = job.range
        local falloff = job.falloff
        local kn = job.kn
        local maxInf = job.maxInf

        -- 复用缓冲: K 近邻结果 / 每个采样点的混合系数
        local bd = for q = 1 to kn collect 1e30
        local bi = for q = 1 to kn collect 0
        local fw = for q = 1 to kn collect 0.0
        -- 骨骼权重累加器: 按来源骨骼ID直接下标, touched 记录脏项以便 O(k) 回滚
        local accW = for q = 1 to job.nsb collect 0.0
        local touched = #()

        local snapTol2 = 1e-6      -- 位置几乎重合 -> 直接整份拷贝
        local done = 0
        local cancelled = false

        for i = 1 to nt do
        (
            local tv = tvs[i]
            local px = tx[i]; local py = ty[i]; local pz = tz[i]
            local found = knn grid sx sy sz px py pz kn range bd bi
            -- 范围内一个都没采到 -> 退化为不限范围的最近点
            if found == 0 do found = knn grid sx sy sz px py pz 1 0.0 bd bi

            if found > 0 do
            (
                local nUse = found
                if bd[1] <= snapTol2 then (nUse = 1; fw[1] = 1.0)
                else
                (
                    for t = 1 to found do
                    (
                        local d = sqrt bd[t]
                        local w = if range > 0 then
                            (local bfac = 1.0 - d / range; if bfac < 0.0 do bfac = 0.0; pow bfac falloff)
                        else
                            (1.0 / (pow (d + 1e-3) falloff))
                        if w < 1e-9 do w = 1e-9
                        fw[t] = w
                    )
                )

                -- 累加来源权重
                for t = 1 to nUse do
                (
                    local si = bi[t]
                    local f = fw[t]
                    local bb = sbi[si]; local ww = sw[si]
                    for k = 1 to bb.count do
                    (
                        local bid = bb[k]
                        if accW[bid] == 0.0 do append touched bid
                        accW[bid] += f * ww[k]
                    )
                )

                -- 映射到目标骨骼 + 清理累加器
                local bids = #(); local bws = #()
                local total = 0.0
                for k = 1 to touched.count do
                (
                    local bid = touched[k]
                    local w = accW[bid]
                    accW[bid] = 0.0
                    local tid = boneMap[bid]
                    if tid > 0 and w > 0.0 do
                    (
                        -- 同名骨骼合并, 避免重复 boneID 写入
                        local ex = findItem bids tid
                        if ex == 0 then (append bids tid; append bws w)
                        else bws[ex] += w
                        total += w
                    )
                )
                touched.count = 0

                -- 只保留最强的 maxInf 根骨骼
                if maxInf > 0 and bids.count > maxInf do
                (
                    for a = 1 to maxInf do
                    (
                        local best = a
                        for b2 = a + 1 to bids.count do if bws[b2] > bws[best] do best = b2
                        if best != a do
                        (
                            local ti = bids[a]; bids[a] = bids[best]; bids[best] = ti
                            local tw = bws[a]; bws[a] = bws[best]; bws[best] = tw
                        )
                    )
                    bids.count = maxInf
                    bws.count = maxInf
                    total = 0.0
                    for w in bws do total += w
                )

                if bids.count > 0 and total > 0.0 do
                (
                    local inv = 1.0 / total
                    for j = 1 to bws.count do bws[j] = bws[j] * inv
                    skinOps.ReplaceVertexWeights sk tv bids bws
                    done += 1
                )
            )

            if (mod i 500) == 0 do
            (
                progressUpdate (100.0 * i / nt)
                if getProgressCancel() do (cancelled = true; exit)
            )
        )
        #(done, cancelled)
    )

    -- ============================================
    -- 骨骼映射: 来源骨骼ID -> 目标 Skin 骨骼索引
    --   返回 #(映射数组, 目标 Skin 中缺失的骨骼名数组)
    -- ============================================
    fn buildBoneMap sk srcNames =
    (
        local nb = skinOps.GetNumberBones sk
        local tgtNames = for b = 1 to nb collect (skinOps.GetBoneName sk b 0)
        local nsb = srcNames.count
        local bm = #(); bm.count = nsb
        local missing = #()
        for b = 1 to nsb do
        (
            bm[b] = 0
            if srcNames[b] != undefined do
            (
                local id = findItem tgtNames srcNames[b]
                bm[b] = id
                if id == 0 do appendIfUnique missing srcNames[b]
            )
        )
        #(bm, missing)
    )

    -- 按骨骼名从场景里找到同名对象, 添加进目标 Skin
    --   返回 #(成功添加数, 找不到同名对象或添加失败的骨骼名数组)
    fn addMissingBones sk names =
    (
        local added = 0
        local failed = #()
        for nm in names do
        (
            local bn = getNodeByName nm
            if bn == undefined then append failed nm
            else
            (
                local ok = true
                try (skinOps.addBone sk bn 1) catch (ok = false)
                if ok then added += 1 else append failed nm
            )
        )
        #(added, failed)
    )

    -- ============================================
    -- 手动撤销: 备份/还原目标顶点权重
    -- ============================================
    fn backupWeights sk verts =
    (
        local data = #(); data.count = verts.count
        for i = 1 to verts.count do
        (
            local vi = verts[i]
            local wc = skinOps.GetVertexWeightCount sk vi
            local bb = #(); local ww = #()
            for b = 1 to wc do
            (
                local w = skinOps.GetVertexWeight sk vi b
                if w > 1e-5 do
                (
                    append bb (skinOps.GetVertexWeightBoneID sk vi b)
                    append ww w
                )
            )
            data[i] = #(bb, ww)
        )
        data
    )

    fn restoreWeights sk verts data =
    (
        for i = 1 to verts.count do
        (
            local vi = verts[i]
            local bb = data[i][1]; local ww = data[i][2]
            if bb.count > 0 then
                skinOps.ReplaceVertexWeights sk vi bb ww
            else
            (
                -- 原顶点无权重: 清空当前权重
                local wc = skinOps.GetVertexWeightCount sk vi
                for b = 1 to wc do
                    skinOps.SetVertexWeights sk vi (skinOps.GetVertexWeightBoneID sk vi b) 0.0
            )
        )
    )

    -- ============================================
    -- 按钮3: 计算并传递权重
    --   每个目标顶点取范围内最近的 K 个来源点, 按衰减加权混合后写入
    --     range>0 : 权重 = (1 - d/range)^falloff   (超出范围不参与)
    --     range=0 : 权重 = 1 / (d+eps)^falloff      (反距离加权)
    --   maxInf>0 时只保留最强的 maxInf 根骨骼
    -- ============================================
    fn apply range:0.0 falloff:2.0 kn:4 maxInf:0 useUndo:true =
    (
        if targetNode == undefined or not (isValidNode targetNode) do
            (messagebox "请先用按钮1记录处理顶点(目标)"; return 0)
        if srcX.count == 0 or srcGrid == undefined do
            (messagebox "请先用按钮2记录包裹顶点(来源)"; return 0)

        local node = targetNode
        local sk = getSkin node
        if sk == undefined do (messagebox "目标物体没有 Skin 修改器"; return 0)

        local tvs = targetVerts
        local nt = tvs.count
        if nt == 0 do (messagebox "目标顶点为空, 请重新记录"; return 0)
        if kn < 1 do kn = 1

        local t0 = timeStamp()

        -- 写权重时留在 0 级: 避免每次写入都重算顶点权重色
        if not (prep node sk vertLevel:false) do return 0

        -- 来源骨骼 -> 目标骨骼索引, 一次算好
        local srcNames = srcBoneNames
        local nsb = srcNames.count
        local mapRes = buildBoneMap sk srcNames
        local boneMap = mapRes[1]
        local missing = mapRes[2]

        -- 目标 Skin 缺少来源骨骼: 列出来问一下, 同意就按同名对象补进 Skin 再传权重
        if missing.count > 0 do
        (
            local msg = "目标 Skin 中缺少以下 " + (missing.count as string) + " 根来源骨骼:\n\n"
            for k = 1 to (amin 20 missing.count) do msg += "    " + missing[k] + "\n"
            if missing.count > 20 do msg += "    ... 其余 " + ((missing.count - 20) as string) + " 根未列出\n"
            msg += "\n是否把它们添加到目标 Skin 中?\n\n"
            msg += "是: 按同名对象添加骨骼, 然后连这些骨骼的权重一起传递\n"
            msg += "    (新骨骼的封套会影响附近顶点, 可能改变其他顶点权重)\n"
            msg += "否: 忽略这些骨骼的权重, 只用目标 Skin 已有的骨骼"
            if (queryBox msg title:"缺失骨骼") do
            (
                local addRes = undefined
                undo "添加缺失骨骼" on (addRes = addMissingBones sk missing)
                -- 骨骼列表变了, 重建映射
                mapRes = buildBoneMap sk srcNames
                boneMap = mapRes[1]
                missing = mapRes[2]

                local failed = addRes[2]
                if failed.count > 0 do
                (
                    local s = "已添加 " + (addRes[1] as string) + " 根骨骼。\n\n"
                    s += "以下 " + (failed.count as string) + " 根在场景中找不到同名对象(或添加失败), 其权重将被忽略:\n\n"
                    for k = 1 to (amin 20 failed.count) do s += "    " + failed[k] + "\n"
                    messagebox s title:"部分骨骼无法添加"
                )
            )
        )

        -- 目标点坐标一次性取出后立即释放临时网格
        local tx = #(); tx.count = nt
        local ty = #(); ty.count = nt
        local tz = #(); tz.count = nt
        local msh = snapshotAsMesh node
        try
        (
            for i = 1 to nt do
            (
                local vi = tvs[i]
                local p = getVert msh vi
                tx[i] = p.x; ty[i] = p.y; tz[i] = p.z
            )
        )
        catch ()
        try (delete msh) catch ()

        -- 打包运行参数交给顶层的 transfer
        local job = FT_LWT2_Job sk:sk tvs:tvs nt:nt tx:tx ty:ty tz:tz \
            grid:srcGrid sx:srcX sy:srcY sz:srcZ \
            sbi:srcBI sw:srcW boneMap:boneMap nsb:nsb \
            range:range falloff:falloff kn:kn maxInf:maxInf

        local cnt = 0
        local cancelled = false
        local res = undefined

        -- 手动撤销: 先备份目标顶点权重(避免自动 undo 在大量顶点时反复撤销崩溃)
        if useUndo do
        (
            backNode = node
            backVerts = tvs
            backWeights = backupWeights sk tvs
        )

        disableSceneRedraw()
        progressStart "局部蒙皮包裹..."
        local err = undefined
        try (res = transfer job)
        catch (err = getCurrentException())
        progressEnd()
        enableSceneRedraw()

        if res != undefined do (cnt = res[1]; cancelled = res[2])

        -- 手动撤销: 备份成功则启用撤销按钮
        if useUndo and backWeights.count > 0 do
        (
            btnUndo.enabled = true
            btnUndo.text = "可撤销传递"
        )

        -- 回到顶点子层级, 方便继续调整选择
        try (prep node sk vertLevel:true) catch ()
        completeRedraw()

        lastMS = timeStamp() - t0

        if err != undefined do (messagebox ("传递权重失败:\n" + err); return 0)
        if cancelled do messagebox ("已取消, 仅处理了 " + (cnt as string) + " 个顶点")
        cnt
    )

    fn refreshLabels =
    (
        lbTgt.text = "目标顶点: " + (targetVerts.count as string)
        lbSrc.text = "来源顶点: " + (srcX.count as string)
        lbTime.text = if lastMS > 0 then
            ("耗时: " + (lastMS as string) + " ms")
        else "耗时: -"
    )

    on btn1 pressed do
    (
        local n = recordTarget()
        refreshLabels()
        if n > 0 do lbHelp.text = "已记录目标顶点: " + (n as string)
    )

    on btn2 pressed do
    (
        local n = recordSource()
        refreshLabels()
        if n > 0 do lbHelp.text = "已记录来源顶点: " + (n as string)
    )

    on btn3 pressed do
    (
        local n = apply range:spnRange.value falloff:spnFall.value kn:spnK.value \
                    maxInf:spnMaxI.value useUndo:chkUndo.checked
        refreshLabels()
        if n > 0 do lbHelp.text = "已传递权重: " + (n as string) + " 个顶点"
    )

    on btnClr pressed do
    (
        targetNode = undefined
        targetVerts = #()
        srcX = #(); srcY = #(); srcZ = #()
        srcBI = #(); srcW = #()
        srcBoneNames = #()
        srcGrid = undefined
        lastMS = 0
        backNode = undefined
        backVerts = #()
        backWeights = #()
        btnUndo.enabled = false
        btnUndo.text = "撤销传递"
        refreshLabels()
        lbHelp.text = "已清空记录"
    )

    on btnUndo pressed do
    (
        if isValidNode backNode and backWeights.count > 0 do
        (
            local sk = getSkin backNode
            if sk != undefined and (prep backNode sk vertLevel:false) do
            (
                disableSceneRedraw()
                try (restoreWeights sk backVerts backWeights) catch ()
                enableSceneRedraw()
                completeRedraw()
                btnUndo.enabled = false
                btnUndo.text = "撤销传递"
                lbHelp.text = "已撤销上次传递"
            )
        )
    )

    on FT_LWT2_rol open do refreshLabels()
)

-- 被其他脚本 filein 时(如 ChangSkinWeight_v2.4.0.ms)不自动弹出对话框
--if FT_LWT2_standalone != false do createDialog FT_LWT2_rol

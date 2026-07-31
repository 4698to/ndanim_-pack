/*
-- coding: utf-8 
-- @Date    : 2025-12-17 16:32:10
-- @Author  : 4698to (738746223@qq.com)
-- @Link    : sundaybox.cc
-- @Version : 
*/

/* 
    Gemini 3 Pro - Skeleton Visualizer & Auto-Skin Tool
    Date: 2025-12-17
    
    Usage:
    1. Select your bone hierarchy (select all bones you want to process).
    2. Run the script.
    3. Adjust the "Thickness" spinner and click "Generate Skinned Mesh".
*/

/* 
    Gemini 3 Pro - Smart Skeleton Visualizer (L/R Detection)
    Date: 2025-12-17
    
    Features:
    - Auto-Skinning with procedural weights.
    - Smart Side Detection: Colors meshes based on bone names (Left/Right/Center).
*/

/* 
    Gemini 3 Pro - Smart Skeleton Visualizer (L/R + Head Detection)
    Date: 2025-12-17
    
    Features:
    - Auto-Skinning.
    - Smart Side Coloring (L/R).
    - Head Detection: Makes "Head" bones significantly larger.
*/

/* 
    Gemini 3 Pro - Global Skeleton Visualizer
    Date: 2025-12-17
    
    Update:
    - Processes ALL objects in the scene (no selection needed).
    - Auto-filters out Lights, Cameras, and existing Proxies.
    - Includes "Delete All Proxies" for quick cleanup.
*/

/* 
    Gemini 3 Pro - Ultimate Skeleton Visualizer
    Date: 2025-12-17
    
    Updates:
    - Handles "Terminal/Leaf" bones (specifically Heads with no children).
    - Extends geometry automatically based on parent vector.
    - Single-bone skinning for terminal nodes.
*/

/* 
    Gemini 3 Pro - Bone Mesher Struct API
    Date: 2025-12-17
    
    Description: 
    A modular struct to generate skinned proxy meshes for bone hierarchies.
    Supports L/R detection, Head scaling, and terminal node handling.
*/

struct GeminiBoneMesher
(
    -- Public Settings (Default Values)
    baseWidth      = 1.6,
    headMultiplier = 3.5,
    segments       = 1,
    proxySuffix    = "_Proxy",
    
    -- Colors
    colCenter      = (color 8 110 134),
    colLeft        = (color 28 28 177),
    colRight       = (color 6 134 6),
    colbone        = (color 255 100 100),
    is_hide_bone = true,
    -- Private: Helper to determine color based on name
    fn _getBoneColor bName =
    (
        if (matchPattern bName pattern:"*_L*" ignoreCase:true) or \
           (matchPattern bName pattern:"* L *" ignoreCase:true) or \
           (matchPattern bName pattern:"L_*" ignoreCase:true) or \
           (matchPattern bName pattern:"*Left*" ignoreCase:true) then return this.colLeft
        
        if (matchPattern bName pattern:"*_R*" ignoreCase:true) or \
           (matchPattern bName pattern:"* R *" ignoreCase:true) or \
           (matchPattern bName pattern:"R_*" ignoreCase:true) or \
           (matchPattern bName pattern:"*Right*" ignoreCase:true) then return this.colRight
        
        if (matchPattern bName pattern:"*Bone*" ignoreCase:true) do return this.colbone
        return this.colCenter
    ),

    -- Private: Matrix Math
    fn _getMatrixFromZAxis p1 p2 =
    (
        local zVec = normalize (p2 - p1)
        local upVec = [0,0,1]
        if (abs (dot zVec upVec)) > 0.99 do upVec = [0,1,0]
        local xVec = normalize (cross upVec zVec)
        local yVec = normalize (cross zVec xVec)
        return matrix3 xVec yVec zVec p1
    ),

    -- Private: Core creation logic
    fn _createProxy pBone targetObjOrPos isTerminal finalWidth =
    (
        local p1 = pBone.pos
        local p2 = if isTerminal then targetObjOrPos else targetObjOrPos.pos
        local dist = distance p1 p2
        
        if dist > 0.001 do
        (
            -- Create Mesh
            local meshColor = this._getBoneColor pBone.name
            local geo = Box width:finalWidth length:finalWidth height:dist \
                        widthsegs:1 lengthsegs:1 heightsegs:this.segments \
                        wirecolor:meshColor name:(pBone.name + this.proxySuffix)
            
            -- Align
            geo.transform = this._getMatrixFromZAxis p1 p2
            
            -- Skinning
            --resetScale geo
            addModifier geo (Skin())
            local skinMod = geo.modifiers[#Skin]
            
            -- SkinOps requires selection and modify mode
            select geo
            max modify mode 
            
            if isTerminal then
            (
                -- Terminal/Head: 100% weight to parent only
                skinOps.addBone skinMod pBone 1
            )
            else
            (
                -- Chain: Gradient weight
                skinOps.addBone skinMod pBone 1
                skinOps.addBone skinMod targetObjOrPos 1
                
                local vertCount = skinOps.GetNumberVertices skinMod
                for v = 1 to vertCount do
                (
                    local vPos = getVert geo.mesh v
                    local ratio = vPos.z / dist
                    if ratio < 0 do ratio = 0
                    if ratio > 1 do ratio = 1
                    skinOps.ReplaceVertexWeights skinMod v #(1, 2) #((1.0 - ratio), ratio)
                )
            )
            pBone.renderable = not this.is_hide_bone 
            
            return geo
        )
        return undefined
    ),

    --------------------------------------------------------
    -- Public API Methods
    --------------------------------------------------------

    -- Cleanup Method
    fn DeleteAll =
    (
        local patternStr = "*" + this.proxySuffix
        delete (for o in objects where (matchPattern o.name pattern:patternStr) collect o)
        format "GeminiMesher: Proxies deleted.\n"
    ),

    -- Main Execution Method
    -- targetNodes: Can be 'selection', 'objects', or an array of nodes
    fn Run targetNode =
    (
        this._createNodeChilderProxy targetNode
    ),
    fn auto_run = 
    (
        top_world = rootscene[#world]
        for iw in top_world.object.children do 
        (
            if iw.classid[1] == 683634317 do (
                this._createNodeChilderProxy iw 
            )

        )
    ),
    fn _createNodeChilderProxy parentBone = 
    (
        if parentBone == undefined do return false
        
        --undo "Generate Bone Proxies" on
        (
            with redraw off 
            (
                local count = 0
                --local processedNodes = if (classof targetNodes == ObjectSet) then (targetNodes as array) else targetNodes
                
                --for parentBone in processedNodes do
                (
                    -- Filters
                    if (matchPattern parentBone.name pattern:("*" + this.proxySuffix)) do continue
                    --if (superclassof parentBone != GeometryClass and superclassof parentBone != helper) do continue
                    
                    -- Analysis
                    local isHead = matchPattern parentBone.name pattern:"*Head*" ignoreCase:true
                    local currentWidth = this.baseWidth
                    
                    -- Logic Branch
                    if parentBone.children.count > 0 then
                    (
                        -- Has Children
                        for childBone in parentBone.children do
                        (
                            if (matchPattern childBone.name pattern:("*" + this.proxySuffix)) do continue
                            is_bone_name = matchPattern childBone.name pattern:("*Bone*") ignoreCase:true
                            if is_bone_name then (
                                geo = this._createProxy parentBone childBone false (currentWidth*0.28)
                                if geo != undefined do (
                                    geo.castShadows = false 
                                    geo.receiveshadows = false 
                                    geo.ApplyAtmospherics =false 
                                )
                            )else(
                                this._createProxy parentBone childBone false currentWidth
                            )  
                            --递归循环创建子级
                            this._createNodeChilderProxy childBone

                            count += 1
                        )
                    )
                    if isHead then
                    (
                        currentWidth = if isHead then (this.baseWidth * this.headMultiplier) else this.baseWidth

                        -- Terminal Head Logic
                        local dir = [0,0,1] 
                        if isValidNode parentBone.parent do (
                            dir = normalize (parentBone.pos - parentBone.parent.pos)
                        )
                        local headLen = currentWidth * 1.5 
                        local virtualTarget = parentBone.pos + (dir * headLen)
                        
                        this._createProxy parentBone virtualTarget true currentWidth
                        count += 1
                    )
                )
                format "GeminiMesher: Generated % proxies.\n" count
            )
        )
        redrawViews()
    )
)
/*
-- 1. 实例化结构体
myMesher = GeminiBoneMesher()

-- 2. (可选) 修改设置
myMesher.baseWidth = 1.5
myMesher.headMultiplier = 4.0
myMesher.colLeft = color 0 0 255 -- 纯蓝

-- 3. 清理旧的
myMesher.DeleteAll()

-- 4. 对整个场景生成
myMesher.Run objects

-- 或者只对选择的物体生成
-- myMesher.Run selection

*/
try(destroydialog rol_StructRunner)catch()

rollout rol_StructRunner "FBX骨骼显示" width:200
(
    spinner spn_size "Size:" range:[0.1, 100, 1.0]
    button btn_do "选中根骨骼运行" width:180 height:30
    button btn_clean "清理" width:180
    
    -- 创建结构体实例
    local mesher = GeminiBoneMesher()
    
    on btn_do pressed do
    (
        -- 将 UI 的值传给结构体
        mesher.baseWidth = spn_size.value
        
        -- 执行
        mesher.Run selection[1]
    )
    
    on btn_clean pressed do
    (
        mesher.DeleteAll()
    )
)

createDialog rol_StructRunner
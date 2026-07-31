
-- 定义一个函数来获取选中的模型的变换信息
fn getTransformInfo obj = (
    local pos = obj.pos
    local rot = quatToEuler obj.rotation
    local scale = obj.scale
    return #(pos, rot, scale)
)

-- 定义一个函数来设置选中的模型的变换信息
fn setTransformFn obj pos rot scale = (
    -- 设置位置
    obj.pos = pos
    
    -- 设置旋转
    local rotQuat = (eulerAngles rot.x rot.y rot.z) as quat
    obj.rotation = rotQuat
    
    -- 设置缩放
    obj.scale = scale
)

-- 创建一个窗口来显示变换信息
rollout transformInfoRollout "变换信息" width:300 height:350 (

    
    label lblPos "位置:" align:#left
    label lblRot "旋转:" align:#left
    label lblScale "缩放:" align:#left
    edittext edtPosX "X:" text:"0" align:#left across:3
    edittext edtPosY "Y:" text:"0" align:#left across:3
    edittext edtPosZ "Z:" text:"0" align:#left
    edittext edtRotX "X:" text:"-90" align:#left across:3
    edittext edtRotY "Y:" text:"0" align:#left across:3
    edittext edtRotZ "Z:" text:"0" align:#left
    edittext edtScaleX "X:" text:"1" align:#left across:3
    edittext edtScaleY "Y:" text:"1" align:#left across:3
    edittext edtScaleZ "Z:" text:"1" align:#left
    button btnGetInfo "获取变换信息" width:180 height:30
    button btnSetTransform "修改模型变换信息" width:180 height:30
    button btnResetXform "Reset Xform" width:180 height:30
    -- 添加空行
    label lblSpacer1 "" height:50
    -- 添加作者、版本和修改时间信息
    label lblAuthor "                                  作者: myl" align:#left
    label lblVersion "                                  版本: V1.0" align:#left
    on btnGetInfo pressed do (
        if selection.count == 0 then (
            messageBox "请选择一个模型。" title:"未选择"
        ) else (
            local obj = selection[1]
            local info = getTransformInfo obj
            lblPos.text = "位置: " + (info[1] as string)
            lblRot.text = "旋转: " + (info[2] as string)
            lblScale.text = "缩放: " + (info[3] as string)
        )
    )

    on btnSetTransform pressed do (
        if selection.count == 0 then (
            messageBox "请选择一个模型。" title:"未选择"
        ) else (
            local obj = selection[1]
            local pos = [edtPosX.text as float, edtPosY.text as float, edtPosZ.text as float]
            local rot = [edtRotX.text as float, edtRotY.text as float, edtRotZ.text as float]
            local scale = [edtScaleX.text as float, edtScaleY.text as float, edtScaleZ.text as float]

    
            -- Reset Xform 操作
            resetXForm obj
            collapseStack obj
    

------------------------------------------------------
            -- 记录当前pivot位置
            local oldPivot = obj.pivot
            
            -- 应用新的变换
            setTransformFn obj pos rot scale
            
            -- 计算pivot的偏移
            local pivotOffset = oldPivot - obj.pivot
            
            -- 移动对象以补偿pivot的变化
            obj.position += pivotOffset
            
            -- 将pivot移回原来的位置
            obj.pivot = oldPivot
            -- Reset Xform 操作
            resetXForm obj
            collapseStack obj
    

------------------------------------------------------
            -- 记录当前pivot位置
            local oldPivot = obj.pivot
            
            -- 应用新的变换
            setTransformFn obj pos rot scale
            
            -- 计算pivot的偏移
            local pivotOffset = oldPivot - obj.pivot
            
            -- 移动对象以补偿pivot的变化
            obj.position += pivotOffset
            
            -- 将pivot移回原来的位置
            obj.pivot = oldPivot
            -- Reset Xform 操作
            resetXForm obj
            collapseStack obj
    

------------------------------------------------------
            -- 记录当前pivot位置
            local oldPivot = obj.pivot
            
            -- 应用新的变换
            setTransformFn obj pos rot scale
            
            -- 计算pivot的偏移
            local pivotOffset = oldPivot - obj.pivot
            
            -- 移动对象以补偿pivot的变化
            obj.position += pivotOffset
            
            -- 将pivot移回原来的位置
            obj.pivot = oldPivot
            -- Reset Xform 操作
            resetXForm obj
            collapseStack obj
    

------------------------------------------------------
            -- 记录当前pivot位置
            local oldPivot = obj.pivot
            
            -- 应用新的变换
            setTransformFn obj pos rot scale
            
            -- 计算pivot的偏移
            local pivotOffset = oldPivot - obj.pivot
            
            -- 移动对象以补偿pivot的变化
            obj.position += pivotOffset
            
            -- 将pivot移回原来的位置
            obj.pivot = oldPivot

            
            messageBox "模型变换信息已再次修改。" title:"修改完成"
        )
    )

    on btnResetXform pressed do (
        if selection.count == 0 then (
            messageBox "请选择一个模型。" title:"未选择"
        ) else (
            local obj = selection[1]
            resetXForm obj
            collapseStack obj
            messageBox "Reset Xform 操作已完成并塌陷。" title:"Reset完成"
        )
    )
)

-- 创建一个对话框并添加rollout
createDialog transformInfoRollout


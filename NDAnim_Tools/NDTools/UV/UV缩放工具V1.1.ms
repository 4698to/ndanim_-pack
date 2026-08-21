rollout unnamedRollout "UV缩放平移工具-myl" width:220 height:320
--可以针对uv进行，按比例缩放和平移，也可以按x轴和y轴单独进行平移

(   

    button bt_BOX "1.创建box" pos:[8,30] width:150 height:30 offset:[0,0] toolTip:"创建后要选择模型合并它-用来保持uv边界"
    -------------------
    label label2 "2.缩放UV："pos:[8, 70] width:180 
    button bt_scale2 "确定" pos:[180,90] width:30 height:45 offset:[0,0] toolTip:"缩放X+Y的值"
    --button bt_scale1 "确定" pos:[180,120] width:30 height:45 offset:[0,0] toolTip:"缩放XY的值"
    --spinner scaleSpinner "缩放UV:  "  range:[-16,16,0.5]  pos:[8,90] width:150 height:30 align:#left offset:[0,0]
    spinner scaleSpinnerX "缩放 U:"  range:[-16,16,0.5]  pos:[8,90] width:150 height:30 align:#left offset:[0,0]
    spinner scaleSpinnery "缩放 V:"  range:[-16,16,0.5]  pos:[8,120] width:150 height:30 align:#left offset:[0,0]

    -- 创建一个旋转器用于输入移动值

    -----------------------   

    -- 创建一个按钮用于执行移动操作

    label label3 "3.移动 UV：" pos:[8, 170] width:180  
    --button btnMoveXY "确定" pos:[180,210] width:30 height:20 offset:[0,0] toolTip:"移动 UV的值"
    button btnMove "确定" pos:[180,190] width:30 height:45 offset:[0,0] toolTip:"移动 U+V的值"
    --spinner moveSpinnerUV "移动 UV:" range:[-100,100,0.25] pos:[8,210] width:150 height:30 align:#left offset:[0,0]
    spinner moveSpinnerX "移动 U:" range:[-100,100,0.25] pos:[8,190] width:150 height:30 align:#left offset:[0,0]
    spinner moveSpinnerY "移动 V:" range:[-100,100,0.25] pos:[8,220] width:150 height:30 align:#left offset:[0,0]


	on bt_BOX pressed  do
		Box lengthsegs:1 widthsegs:1 heightsegs:1 length:2 width:2 height:2 mapcoords:on pos:[2,2,0] isSelected:on
    on bt_scale pressed  do
        (
        if selection.count == 0 then
        (
            messageBox "请至少选择一个对象进行缩放"
            exit
        )
        local scaleValue = scaleSpinner.value
        for obj in selection do
        (
            local unwrapMod = Unwrap_UVW()
            addModifier obj unwrapMod
            subObjectLevel = 3
            max select all
            actionMan.executeAction 0 "40021"  -- Selection: Select All
            local uvCenter = polyOp.getFaceCenter obj 1
            --unwrapMod.unwrap.ScaleSelectedCenter  [scaleValue,scaleValue,1]
            unwrapMod.unwrap2.ScaleSelectedXY scaleValue scaleValue [0,0,0]
            --unwrapMod.unwrap.moveSelected moveSpinner moveSpinner [0,0,0]
        )
        )
        
    on bt_scale2 pressed  do
        (
        if selection.count == 0 then
        (
            messageBox "请至少选择一个对象进行缩放"
            exit
        )
        local scaleSpinnerX1 = scaleSpinnerX.value
        local scaleSpinnerY1 = scaleSpinnery.value
        for obj in selection do
        (
            local unwrapMod = Unwrap_UVW()
            addModifier obj unwrapMod
            subObjectLevel = 3
            max select all
            actionMan.executeAction 0 "40021"  -- Selection: Select All
            local uvCenter = polyOp.getFaceCenter obj 1
            --unwrapMod.unwrap.ScaleSelectedCenter  [scaleValue,scaleValue,1]
            unwrapMod.unwrap2.ScaleSelectedXY scaleSpinnerX1 scaleSpinnerY1 [0,0,0]
            --unwrapMod.unwrap.moveSelected moveSpinner moveSpinner [0,0,0]
        )
        )
    -- 当按钮被按下时执行的操作
    on btnMove pressed do
    (
        -- 获取旋转器的值
        local moveU = moveSpinnerX.value
        local moveV = moveSpinnerY.value

        -- 对每个选定的对象执行操作
        for obj in selection do
        (
            -- 添加Unwrap UVW修改器
            addModifier obj (Unwrap_UVW())

            -- 进入面子对象级别
            max modify mode -- switch to modify panel
            modPanel.setCurrentObject obj.modifiers[#unwrap_uvw] -- set unwrap uvw as current modifier
            subObjectLevel = 3 -- set sub object level to face

            -- 选择所有面
            max select all

            -- 移动选定的UVs
            obj.modifiers[#unwrap_uvw].unwrap2.MoveSelected [moveU, moveV, 0]
        )
    )
    on btnMoveXY pressed do
    (
        -- 获取旋转器的值
        local moveU2 = moveSpinnerUV.value

        -- 对每个选定的对象执行操作
        for obj in selection do
        (
            -- 添加Unwrap UVW修改器
            addModifier obj (Unwrap_UVW())

            -- 进入面子对象级别
            max modify mode -- switch to modify panel
            modPanel.setCurrentObject obj.modifiers[#unwrap_uvw] -- set unwrap uvw as current modifier
            subObjectLevel = 3 -- set sub object level to face

            -- 选择所有面
            max select all

            -- 移动选定的UVs
            obj.modifiers[#unwrap_uvw].unwrap2.MoveSelected [moveU2, moveU2, 0]
        )
    )
)
createDialog unnamedRollout
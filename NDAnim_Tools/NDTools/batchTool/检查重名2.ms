try (destroydialog foo) catch()
rollout foo "检查重命名-灯佬" width:162 height:220
(
    checkbox ck_01 "骨骼" checked:true across:3 enabled:false
    checkbox ck_02 "模型" --checked:true
    checkbox ck_03 "所有" --checked:true

    button btn1 "检查重名"  

    button btn2 "自动改名" 
    button btn3_pre "预览删除(跨骨架)" 
    button btn3 "确认删除(跨骨架)" 
    button btn4_pre "预览删除(同骨架)" 
    button btn4 "确认删除(同骨架)" 
    
    label lab_02 "说明: 跨骨架=只保留1个" across:1
    label lab_03 "同骨架=每个骨架保留1个"
    
    local SameNameNode = #(),AllNodes = #()
    local toDeleteNodes = #()  -- 用来存储待删除的对象
    
    -- 检查对象是否有效的函数
    fn isObjValid obj =
    (
        local result = false
        try
        (
            if obj != undefined and obj != null then
            (
                local testName = obj.name
                result = true
            )
        )
        catch()
        result
    )
    
    -- 获取对象的根骨架
    fn getRootBone obj =
    (
        local root = obj
        while root.parent != undefined do
        (
            root = root.parent
        )
        root
    )
    
    fn getSameNameNode =
    (
        local index = 1
        if ck_02.state do(index =2)
        if ck_03.state do(index =3)
        case of
        (
            (index < 2):(AllNodes = for i in geometry where ((classof i == Biped_Object) or (classof i== BoneGeometry)) collect i)
            (index > 2):(AllNodes = objects as array)
            (index ==2):(AllNodes = for i in geometry where ((classof i != Biped_Object) or (classof i != BoneGeometry)) collect i)
        )
    )
    
    -- 生成跨骨架删除列表
    fn generateDeleteList_CrossBone =
    (
        toDeleteNodes = #()
        
        local validNodes = #()
        for obj in SameNameNode do
        (
            if (isObjValid obj) then
                append validNodes obj
        )
        
        if validNodes.count == 0 do
            return toDeleteNodes
        
        local nameList = #()
        local groupList = #()
        
        for obj in validNodes do
        (
            local objName = obj.name
            local foundIndex = finditem nameList objName
            
            if foundIndex == 0 then
            (
                append nameList objName
                append groupList #(obj)
            )
            else
            (
                append groupList[foundIndex] obj
            )
        )
        
        -- 收集待删除的对象（每组的第2个开始）
        for i = 1 to groupList.count do
        (
            local group = groupList[i]
            for j = 2 to group.count do
            (
                append toDeleteNodes group[j]
            )
        )
        
        toDeleteNodes
    )
    
    -- 生成同骨架删除列表
    fn generateDeleteList_SameBone =
    (
        toDeleteNodes = #()
        
        local validNodes = #()
        for obj in SameNameNode do
        (
            if (isObjValid obj) then
                append validNodes obj
        )
        
        if validNodes.count == 0 do
            return toDeleteNodes
        
        -- 按名字和骨架分组
        local nameList = #()
        local boneList = #()
        local groupList = #()
        
        for obj in validNodes do
        (
            local objName = obj.name
            local rootBone = getRootBone obj
            local foundIndex = 0
            
            for i = 1 to nameList.count do
            (
                if nameList[i] == objName and boneList[i] == rootBone then
                (
                    foundIndex = i
                    break
                )
            )
            
            if foundIndex == 0 then
            (
                append nameList objName
                append boneList rootBone
                append groupList #(obj)
            )
            else
            (
                append groupList[foundIndex] obj
            )
        )
        
        -- 收集待删除的对象
        for i = 1 to groupList.count do
        (
            local group = groupList[i]
            for j = 2 to group.count do
            (
                append toDeleteNodes group[j]
            )
        )
        
        toDeleteNodes
    )
    
    on btn1 pressed do
    (
        getSameNameNode()
        SameNameNode = #()
        
        local nameList = #()
        local groupList = #()
        
        for obj in AllNodes do
        (
            local objName = obj.name
            local foundIndex = finditem nameList objName
            
            if foundIndex == 0 then
            (
                append nameList objName
                append groupList #(obj)
            )
            else
            (
                append groupList[foundIndex] obj
            )
        )
        
        -- 收集所有重名对象
        for i = 1 to groupList.count do
        (
            if groupList[i].count > 1 do
            (
                for obj in groupList[i] do
                    append SameNameNode obj
            )
        )
        
        clearselection()
        toDeleteNodes = #()
        if SameNameNode.count != 0 do
        (
            lab_01.text ="有 "+(SameNameNode.count as string ) +" 个重名对象"
            select SameNameNode
        )
    )
    
    on btn2 pressed do
    (
        if SameNameNode.count != 0 do
        (
            for o in SameNameNode do
            (
                if (isObjValid o) do
                    o.name = uniquename(o.name)
            )
            SameNameNode = #()
            toDeleteNodes = #()
            lab_01.text = ""
        )
    )
    
    -- 预览删除(跨骨架)
    on btn3_pre pressed do
    (
        if SameNameNode.count != 0 do
        (
            generateDeleteList_CrossBone()
            clearselection()
            if toDeleteNodes.count > 0 do
            (
                select toDeleteNodes
                lab_01.text = "预览: 将删除 " + (toDeleteNodes.count as string) + " 个对象"
            )
        )
    )
    
    -- 确认删除(跨骨架)
    on btn3 pressed do
    (
        if toDeleteNodes.count > 0 then
        (
            local deletedCount = 0
            for obj in toDeleteNodes do
            (
                if (isObjValid obj) do
                (
                    try
                    (
                        delete obj
                        deletedCount += 1
                    )
                    catch()
                )
            )
            
            SameNameNode = #()
            toDeleteNodes = #()
            lab_01.text = "已删除 " + (deletedCount as string) + " 个对象"
            clearselection()
        )
        else
        (
            lab_01.text = "请先预览删除"
        )
    )
    
    -- 预览删除(同骨架)
    on btn4_pre pressed do
    (
        if SameNameNode.count != 0 do
        (
            generateDeleteList_SameBone()
            clearselection()
            if toDeleteNodes.count > 0 do
            (
                select toDeleteNodes
                lab_01.text = "预览: 将删除 " + (toDeleteNodes.count as string) + " 个对象"
            )
        )
    )
    
    -- 确认删除(同骨架)
    on btn4 pressed do
    (
        if toDeleteNodes.count > 0 then
        (
            local deletedCount = 0
            for obj in toDeleteNodes do
            (
                if (isObjValid obj) do
                (
                    try
                    (
                        delete obj
                        deletedCount += 1
                    )
                    catch()
                )
            )
            
            SameNameNode = #()
            toDeleteNodes = #()
            lab_01.text = "已删除 " + (deletedCount as string) + " 个对象"
            clearselection()
        )
        else
        (
            lab_01.text = "请先预览删除"
        )
    )
)
createdialog foo
--99U:199505
--E-mail:738746223@qq.com
--因为在新MAX文件里是按选择对象名字来创建选择集的，所以如果选择名单里有重名物体就不好使了。像C3 项目的。一般也就选骨骼的时候用
try(destroyDialog sele_sets_help)
    catch()
rollout sele_sets_help "选择集传递.v4" width:205 height:270
(
    global sele_set=#()
    global sele_set_name=#()
    global tabset_nd =#()
    local newsets_name = #()--选择集名称
    local newsets_node =#() --每个选择集的对象

    group "依对象名字新建选择集" (
        combobox set_combo "" items:sele_set_name

        button bt_reset "刷新" width:50 toolTip:"保存所有选择集" across:2
        button bt_do_create_set "创建" width:50 toolTip:"创建所有选择集"--pos:[65,90]

    )
    group "合并文件之后选择集丢失？" (
    	button btn_save_set "保存到对象" width:85 height:30 across:2 toolTip:"将选择集信息保存到对象"
        button btn_merged "重建选择集" width:85 height:30
    )
    --------------------------------------------------
    fn get_setlist  =
    (
        sele_set=#();sele_set_name=#()
        --------------------------
        local set_array = getNumNamedSelSets();
        for i=1 to set_array do
        (
            local set_Name = getNamedSelSetName i ;
            --local set_temp = selectionSets[set_Name];
            local set_count = getNamedSelSetItemCount i ;

            local set_array_name = #()
            for o = 1 to set_count do
            (
                temp_sets = getNamedSelSetItem i o
                if temp_sets != undefined do (
                local temp_node = temp_sets.name ;
                append set_array_name temp_node;
                )
            )
            append sele_set_name set_Name
            append sele_set set_array_name
        )
        set_combo.items = sele_set_name
    )
    --------------------------------------------------
    fn AMSS_savenamedsel =
    (

    	for obj in objects do
    	(
    		setAppData obj 777 ""
    		setAppData obj 77 (animationRange.start as string +"|" +animationRange.end as string)
    	)
    	--try
    	--(
    		if getNumNamedselsets() != 0 then
    		(
    			for i in 1 to getNumNamedselsets() do
    			(
    				for j in 1 to (getNamedselsetItemcount i) do
    				(
    					obj = (getNamedselsetItem i j)
                        isValidNode
                        if isValidNode obj then (
                            temp_ = getAppData obj 777
                            if temp_ != undefined or temp_.count > 0 do
                            (
        					   selSetString = temp_ + getNamedselsetName i + "|"
        					   try (setAppData obj 777 selSetString) catch ()
                            )
                        )else(
                            --print(i )
                            --print(j)
                            --print("_")
                        )
    				)
    			)
    		)
    	--) catch ()
    )
    fn get_new_selsets_name =
    (
        --收集对象上选择集标签
        newsets_name = #() ; newsets_node=#()
        for i in objects do
        (
        	local temp_appdata = getAppData i 777
        	if temp_appdata != undefined do (
	            local name_sel = filterstring temp_appdata "|"

	            join newsets_name name_sel

            )
            --append newsets_name name_sel
        )
        newsets_name = makeUniqueArray newsets_name
        for i in newsets_name do
        (
            append newsets_node #()
        )
        --newsets_name
    )
    fn AMSS_merge_bonus_nd elem =      --obj
    (

        local namedsel = filterstring (getAppData elem 777) "|"

        for i in namedsel do
        (
            local index_set = findItem newsets_name i

            if index_set > 0 do (
                append newsets_node[index_set] elem
            )

        )
    )
    --------------------------------------------------

    --------------------------------------------------

    on sele_sets_help open do
    (
        get_setlist()
    )
    on bt_reset pressed do
    (
        get_setlist()
    )

    on bt_do_create_set pressed do
    (
        --if sele_set.count != 0  do (
            for o=1 to sele_set.count do
            (
                local set_Node_name = sele_set[o]
                local set_name = sele_set_name[o]

                local temp_set_Node = #();

                for i=1 to set_Node_name.count  do
                (
                    local temp_node = getNodeByName set_Node_name[i] ;
                    if temp_node != undefined do
                    (
                        --append temp_set_Node  temp_node
                        temp_set_Node[i] = temp_node
                    )
                )
                --format "temp_set_Node.count == %||% \r\n" temp_set_Node.count  o
                selectionSets[set_name] = temp_set_Node
            )
        --)
    )
    --------------------------------------------------
    on set_combo entered itm do
    --on set_combo selected itm do
    (

        if set_combo.text != "" do (
            sele_set_name[set_combo.selection] = set_combo.text
        )
        set_combo.items = sele_set_name
    )
    on set_combo doubleClicked itm do
    (
        --print "dd"
        local set_Node_name = sele_set[set_combo.selection]
        local set_name = sele_set_name[set_combo.selection]

        local temp_set_Node = #();

        for i=1 to set_Node_name.count  do
        (
            local temp_node = getNodeByName set_Node_name[i] ;
            if temp_node != undefined do
            (
                temp_set_Node[i] = temp_node
            )
        )
        selectionSets[set_name] = temp_set_Node
        select selectionSets[set_name]
    )
    --------------------------------------------------
    on btn_merged pressed do
    (
        get_new_selsets_name()
        for obj in objects do
        (
            --设置选择集
            prop = (getAppData obj 777)
            if ((prop != "") and (prop != undefined)) then
            (
                AMSS_merge_bonus_nd obj
            )

        )
        for i = 1 to newsets_name.count do
        (
            selectionSets[(newsets_name[i])] = newsets_node[i]
        )
        --AMSS_applynewsets tabset
    )
    on btn_save_set pressed do
    (
    	AMSS_savenamedsel()
    )
    --------------------------------------------------

)
createDialog sele_sets_help
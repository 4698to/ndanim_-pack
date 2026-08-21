rollout CreatDummy "辅助物体 v.02" width:208 height:200
(
    local get_txt_name = ""
    group "设置"
    (

        checkbox NewPointbox "Box" enabled:true checked:true across:3 --pos:[16,24]
        checkbox NewPointcross "Cross" --pos:[75,24]
        checkbox N_link "Link" --pos:[142,24]

        spinner spn_PointSize "大小:"  range:[0,300,20] type:#integer width:60 height:16 across:2 offset:[-20,0]--pos:[30,50]
        editText edt_name "前缀:"  fieldWidth:70 offset:[-15,0]--pos:[80,50]

        checkbox n_pos "位置" checked:true across:3
        checkbox n_rot "旋转" checked:true
        checkbox n_anim "动画" checked:false
    )
    group "类型" (
        --checkbox c_circle "Circle"
        radiobuttons c_type labels:#("虚拟体","圆圈","四边形")
    )
    group "" (

        button bt_origin "原点创建" across:2
        button btn_CreatPoint "选择创建"

          --width:31 height:21
    )

    fn check_name a_string b_string =
    (
        if get_txt_name == true then
        (
            New_name = edt_name.text + "_" + b_string
            return New_name
        )
        else
        (
            if (b_string == undefined) or (b_string == "")  then
            (
                New_name = uniqueName a_string
            )
            else
            (
                New_name = a_string + b_string
            )
            return New_name
        )
    )
    fn c_circle_spline obj =
    (
        New_cirele = Circle radius:spn_PointSize.value
        if obj != undefined then
        (
            if n_pos.state do
            (
                New_cirele.transform = (matrix3 New_cirele.transform[1] New_cirele.transform[2] New_cirele.transform[3] obj.transform[4])
            )
            if n_rot.state do
            (
                --local tem_rot = obj.transform.rotation as matrix3
                --New_cirele.transform *= tem_rot
                New_cirele.transform = (matrix3 obj.transform[1] obj.transform[2] obj.transform[3] New_cirele.transform[4])
                New_cirele.scale = [1,1,1]
                New_cirele.objectoffsetrot = (quat 0 -1 0 1)
                --in coordSys Local rotate New_cirele (angleaxis 90 [0,1,0])
            )
            if n_anim.state do
            (
                animate On
                (
                    for t=0 to (animationRange.end.frame as integer) do
                    (
                        at time t
                        New_cirele.transform = obj.transform
                    )
                )
            )
            New_cirele.name = check_name "Circle_" obj.name
        )
        else
        (
            New_cirele.name = check_name "Circle_" ""--obj.name
        )
        return New_cirele
    )
    fn c_lineShape obj = --控制手柄实体
    (
            --c = 1
            n = spn_PointSize.value
            new_spline = Rectangle length:n width:n
            /*
            new_spline = splineShape ()
            new_spline.pos = [0,0,0]
            addNewSpline new_spline

            addKnot new_spline 1 #corner #curve [-(n*c),-n,0]
            addKnot new_spline 1 #corner #curve [(-n*c),n,0]
            addKnot new_spline 1 #corner #curve [(n*c),n,0]
            addKnot new_spline 1 #corner #curve [(n*c),-(n),0]
            addKnot new_spline 1 #corner #curve [-(n*c),-n,0]

            close new_spline 1
            updateshape new_spline
            */
            if obj != undefined then
            (
                if n_pos.state do
                (
                    new_spline.transform =  (matrix3 new_spline.transform[1] new_spline.transform[2] new_spline.transform[3] obj.transform[4])
                )
                if n_rot.state do
                (
                    --local tem_rot = obj.transform.rotation as matrix3
                    --new_spline.transform *= tem_rot
                    new_spline.transform = (matrix3 obj.transform[1] obj.transform[2] obj.transform[3] new_spline.transform[4])
                    new_spline.scale = [1,1,1]
                    new_spline.objectoffsetrot = (quat 0 -1 0 1)
                    --in coordSys Local rotate new_spline (angleaxis 90 [0,1,0])
                )
                if n_anim.state do
                (
                    animate On
                    (
                        for t=0 to (animationRange.end.frame as integer) do
                        (
                            at time t
                            new_spline.transform = obj.transform
                        )
                    )
                )
                new_spline.name = check_name "Spline_"  obj.name
            )
            else
            (
                new_spline.pos = [0,0,5]
                new_spline.name = check_name "Spline_" ""
            )
            return new_spline
    )
    fn c_help obj =
    (
        local NewPoint = point()
        if NewPointbox.checked == true then (NewPoint.box=on)
        else (NewPoint.box=off)

        if NewPointcross.checked == true then(NewPoint.cross=on)
        else(NewPoint.cross=off)

        NewPoint.size = spn_PointSize.value
        if obj != undefined then
        (
            if n_pos.state do
            (
                NewPoint.transform = (matrix3 NewPoint.transform[1] NewPoint.transform[2] NewPoint.transform[3] obj.transform[4])
            )
            if n_rot.state do
            (
                NewPoint.transform = (matrix3 obj.transform[1] obj.transform[2] obj.transform[3] NewPoint.transform[4])
                NewPoint.scale = [1,1,1]
            )
            NewPoint.name = check_name "Point_"  obj.name

            if N_link.checked == true do( Newpoint.parent = obj )
            if n_anim.state do
            (
                animate On
                (
                    for t=0 to (animationRange.end.frame as integer) do
                    (
                        at time t
                        Newpoint.transform = obj.transform
                    )
                )
            )
        )
        else
        (
            NewPoint.name = check_name "Point_" ""
        )
        return NewPoint
    )
    --on N_par changed state do edt1.enabled = state
    on edt_name entered txt do
    (
        if txt !="" then (get_txt_name = true )
        else (get_txt_name = false)

    )
    -----------------------------------------
    on btn_CreatPoint pressed do
    (
        undo on
        (
            if selection.count != 0  then
            (
                if c_type.state == 1 do
                (
                    AllPoint = #()
                    for o in selection do
                    (
                        local NewPoint = c_help o

                        append AllPoint  Newpoint
                    )

                    select AllPoint
                    selectionSets ["Point_ji"] = AllPoint
                )
                if c_type.state == 2 do
                (
                    AllPoint = #()
                    for o in selection do
                    (
                        local Newpoint = c_circle_spline o
                        append AllPoint Newpoint
                    )
                    select AllPoint
                    selectionSets ["Circle_ji"] = AllPoint
                )
                if c_type.state == 3 do
                (
                    AllPoint = #()
                    for o in selection do
                    (
                        local Newpoint = c_lineShape o
                        append AllPoint Newpoint
                    )
                    select AllPoint
                    selectionSets ["spline_ji"] = AllPoint
                )

            )
            else
            (
                if c_type.state == 1 do
                (
                        --local NewPoint = point()
                        --if NewPointbox.checked == true then ( NewPoint.box=on)
                        --else ( NewPoint.box=off )

                        --if NewPointcross.checked == true then (NewPoint.cross=on)
                        --else ( NewPoint.cross=off )

                        --if get_txt_name == true do (NewPoint.name = edt_name.text)
                        --else(NewPoint.name = "Point_" + o.name)
                        /*if NewPoint_root.checked == true do(
                            Newpoint.name = "Root"
                            --Newpoint.transform = (matrix3 [0,0,1] [-1.50996e-007,-1,0] [1,-1.50996e-007,0] [0,0,0])

                            --$boy_Hub.parent = Newpoint
                            Newpoint.boneEnable=true
                        )*/
                    a = undefined
                    local NewPoint = c_help a
                )
                if c_type.state == 2 do
                (
                    a = undefined
                    local Newpoint = c_circle_spline a
                )
                if c_type.state == 3 do
                (
                    a = undefined
                    local Newpoint = c_lineShape a
                )

            )
        )


    )
    on bt_origin pressed do
    (
        undo on(
            if selection.count == 0 do
            (
                --NewPoint = point()
                --if NewPointbox.checked == true then (NewPoint.box=on)
                --else (NewPoint.box=off)

                --if NewPointcross.checked == true then (NewPoint.cross=on)
                --else(NewPoint.cross=off)

                --if get_txt_name == true do (NewPoint.name = edt_name.text)
                --else(NewPoint.name = "Root_" )

                --if New_cat.checked == true do ( Newpoint.transform = (matrix3 [0,0,1] [-1.50996e-007,-1,0] [1,-1.50996e-007,0] [0,0,0]) )
                if c_type.state == 1 do
                (
                    a = undefined
                    local NewPoint = c_help a
                    Newpoint.name = uniqueName "Root_"
                    Newpoint.boneEnable = true
                )

                if c_type.state == 2 do
                (
                    a = undefined
                    local Newpoint = c_circle_spline a
                )
                if c_type.state == 3 do
                (
                    a = undefined
                    local Newpoint = c_lineShape a
                )
            )

            if selection.count == 1 do
            (

                if c_type.state == 1 do
                (
                    a = undefined
                    local NewPoint = c_help a
                    Newpoint.name = uniqueName ("Root_" + $.name)
                    Newpoint.boneEnable = true
                    $.parent = Newpoint
                )

                if c_type.state == 2 do
                (
                    a = undefined
                    local Newpoint = c_circle_spline a
                )
                if c_type.state == 3 do
                (
                    a = undefined
                    local Newpoint = c_lineShape a
                )

            )

            if selection.count > 1 do ( messageBox ("只能选择一个物体") )
        )
    )

)
createDialog CreatDummy
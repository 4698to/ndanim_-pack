-- --Maxscript
--author:4698to
--E-Mail:738746223@qq.com
--99U:199505
--2020-07-18
try (destroydialog fooname) catch()
rollout fooname "检查重命名 v2" width:162 height:110
(
    checkbox ck_01 "骨骼" checked:true across:3 enabled:false
    checkbox ck_02 "模型" --checked:true
    checkbox ck_03 "所有" --checked:true

    button btn1 "检查重名"  width:95 height:24 --pos:[36,189]
    label lab_01 ""

    button btn2 "自动改名" width:95 height:24
    local SameNameNode = #(),AllNodes = #()
    fn getSameNameNode =
    (
        local index = 1
        if ck_02.state do(index =2)
        if ck_03.state do(index =3)
        AllNodes = #()
        case of
        (
            (index < 2):(AllNodes = for i in geometry where ((classof i == Biped_Object) or (classof i== BoneGeometry)) collect i)
            (index > 2):(AllNodes = objects as array)
            (index ==2):(AllNodes = for i in geometry where ((classof i != Biped_Object) or (classof i != BoneGeometry)) collect i)
        )
    )
    on btn1 pressed  do
    (
        --AllNodes = Objects as array
        --AllNodes = for i in objects where ((classof i== Biped_Object) or (classof i== BoneGeometry)) collect i
        getSameNameNode()
        SameNameNode = #()
        for i = 1 to AllNodes.count do
    	(
            for o = 2 to AllNodes.count do
            (
                if AllNodes[i].name == AllNodes[o].name and AllNodes[i] != AllNodes[o] do
                (
                    append SameNameNode AllNodes[i]
                )
            )

    	)
        SameNameNode = makeUniqueArray SameNameNode
        clearselection()
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
                o.name = uniquename(o.name )
            )
            SameNameNode = #()
            lab_01.text = ""
        )
    )
)
createdialog fooname



 if selection.count != 0 then
 (
    undo "ss" on
    (
        selectObj = getCurrentSelection()
        for i in selectObj do
        (   
            CenterPivot i
            i.pivot.z = i.min.z
        )
    )--end undo on
)
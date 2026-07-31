  if selection.count != 0 then
  (
 undo "dds" on
    (
    selectObj = getCurrentSelection()
    for i in selectObj do
        (   tempZ = i.pos.z
            tempMinZ = i.min.z
            i.pivot.z = i.min.z
            i.pos.z = 0
            i.pivot.z = tempZ - tempMinZ
        )
    )--end undo on
 )
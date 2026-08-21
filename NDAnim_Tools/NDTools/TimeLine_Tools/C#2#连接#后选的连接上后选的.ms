(
if selection.count != 0 then
(
    undo "ssd" on
    (
        selectObj = selection[selection.count]
        for i=1 to (selection.count - 1) do
        (
            selection[i].parent = selectObj 
        ) 
    )--end undo on
)
)
(
    if selection.count >= 2 then
    (
        undo "ssd2" on
        (
            selection[1].transform = selection[2].transform
            selection[1].parent = selection[2]

        )--end undo on
    )
)
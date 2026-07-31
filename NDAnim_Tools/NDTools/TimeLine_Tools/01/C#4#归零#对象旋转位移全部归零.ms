  undo on
    (
            for i in selection do
            (
                i.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
            )
    )
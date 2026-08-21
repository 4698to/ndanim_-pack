try (
    j_save = getmaxsavefilename filename:(maxfilepath+maxfilename)
    if j_save!=undefined do
    (
        if (MaxVersion())[1] >= 17000 then(
            savemaxfile j_save saveAsVersion:2015 --保存为2015版本
            )
        else (
            savemaxfile j_save
            )

    )
)catch()
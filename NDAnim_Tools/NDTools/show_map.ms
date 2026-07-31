-- 2019-08-11
--99U:199505
--E-mail:738746223@qq.com
--UTF8

for i in geometry do
(
    if i.material != undefined do
    (
        o = i.material
        if classof o == Standardmaterial do (
            enableHardwareMaterial o true

        )
        if classof o == Multimaterial do
        (
            for y in o do
            (
                try (
                    enableHardwareMaterial y true
                )catch()
            )
        )
    )
)

--actionMan.executeAction 0 "63547"

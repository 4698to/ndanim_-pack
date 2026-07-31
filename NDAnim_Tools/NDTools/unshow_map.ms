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
            enableHardwareMaterial o false
            --if o.diffuseMap != undefined do
            --(
            --    showTextureMap i.material false

            --)
        )
        if classof o == Multimaterial do
        (
            for y in o do
            (
                try (
                    enableHardwareMaterial y false
                    --if y.diffuseMap != undefined do (
                    --    local temp = y.diffuseMap.fileName
                    --    showTextureMap y false
                    --)
                )catch()
            )
        )
    )
)

--actionMan.executeAction 0 "63546"
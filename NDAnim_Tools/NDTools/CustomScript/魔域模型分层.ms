fn app_layermanager name_str node_s is_hidden =
(
    local thelayer = layerManager.getLayerFromName name_str
    if thelayer == undefined do (
        thelayer = LayerManager.newLayerFromName name_str
    )
    for i in node_s do (
        thelayer.addNode i
    )
    if is_hidden do ( thelayer.on = not true )
)

models_ = #()
v_mesh_ = #()
bones_ = #()
boneend_ = #()
biped_ = #()
help_ = #()
for i in objects do
(
    if i.classid[1] == 469250957  do
    (
        append models_ i
    )
    if i.classid[1] == -464580429 do
    (
        append v_mesh_ i
    )
    if i.classid[1] == 683634317 do
    (
        if i.children.count == 0 then (
            append boneend_ i
        )else (
            append bones_ i
        )
    )
    if i.classid[1] == 37157 do
    (
        append biped_ i
    )
    if i.classid[1] == 8211 do
    (
        append help_ i
    )
)
app_layermanager "挂点" v_mesh_ false
app_layermanager "模型" models_ false
app_layermanager "Bone" bones_ false
app_layermanager "Biped" biped_ false
app_layermanager "help" help_ false
app_layermanager "Bone_end" boneend_ false


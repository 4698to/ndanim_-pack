rollout BoneVisibilityTool "扭曲骨骼可见性工具"
(
       button toggleVisibilityButton "显隐" width:150 height:50
       on togglevisibilityButton pressed do
        (
          local bones = $*Twist*
              for bone in bones do
                (
                 if bone.isHidden
                        then
                        bone.isHidden = false
                        else
                        bone.isHidden = true
                        )
          )
  )
createDialog BoneVisibilityTool width:200 height:60

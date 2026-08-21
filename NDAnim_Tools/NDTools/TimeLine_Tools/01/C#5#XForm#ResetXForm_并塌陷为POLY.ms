  for theNode in selection do
  if (isValidNode(theNode)) do
    (
    ResetXForm theNode
    macros.run "Modifier Stack" "Convert_to_poly"
    )
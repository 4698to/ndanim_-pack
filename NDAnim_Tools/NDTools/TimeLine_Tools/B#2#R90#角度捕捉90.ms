iGlobal = (dotnetClass "Autodesk.Max.GlobalInterface").Instance
showProperties iGlobal
--dotNetClass
--dotNetObject

--dotNetControl

--showMethods
--showProperties

  .COREInterface : <Autodesk.Max.IInterface>, read-only
  .COREInterface10 : <Autodesk.Max.IInterface10>, read-only
  .COREInterface11 : <Autodesk.Max.IInterface11>, read-only
  .COREInterface12 : <Autodesk.Max.IInterface12>, read-only
  .COREInterface13 : <Autodesk.Max.IInterface13>, read-only
  .COREInterface14 : <Autodesk.Max.IInterface14>, read-only
  .COREInterface7 : <Autodesk.Max.IInterface7>, read-only
  .COREInterface8 : <Autodesk.Max.IInterface8>, read-only
  .COREInterface9 : <Autodesk.Max.IInterface9>, read-only

--iGlobal.COREInterface7.SnapActive
showProperties iGlobal.COREInterface.SnapAngle_ = 45
iGlobal.COREInterface7.SnapAngle_ = 90
iGlobal.COREInterface7.PushPrompt "test"
iGlobal.COREInterface7.GetDir 1

for i = 1 to 50 do 
(
	print(iGlobal.COREInterface7.GetDir i)
)
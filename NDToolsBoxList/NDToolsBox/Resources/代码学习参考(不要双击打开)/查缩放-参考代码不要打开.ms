----##收集所有不符合条件的缩放异常物体
			--允许的误差精度
			all =  objects as array
			accuracy = yunMuscle_creatorUI.CC_accuracy.value    ---允许的误差精度
		
			----*获取庶排除检查缩放在biped末端	
			fingerAndToeNubs = #()   	
			bb = for i in geometry where (classof i== Biped_Object) collect i
			if bb.count>0 then
			(
				biped_ctrl=bb[1].controller   ---获取biped				
				---获取手指末端
				for i =1 to biped_ctrl.fingers  do
				(
					endF = biped.getNode biped_ctrl #lfingers link:(biped_ctrl.fingerLinks*i)	
					if endF.children.count==1 and (classof endF.children[1]==Dummy)  do 
					( append fingerAndToeNubs endF.children[1] )
					endF = biped.getNode biped_ctrl #rfingers link:(biped_ctrl.fingerLinks*i)	
					if endF.children.count==1 and (classof endF.children[1]==Dummy)  do 
					( append fingerAndToeNubs endF.children[1] )
				)
				---获取脚指末端
				for i =1 to biped_ctrl.toes  do
				(
					endF = biped.getNode biped_ctrl #ltoes link:(biped_ctrl.toeLinks*i)	
					if endF.children.count==1 and (classof endF.children[1]==Dummy)  do 
					( append fingerAndToeNubs endF.children[1] )
					endF = biped.getNode biped_ctrl #rtoes link:(biped_ctrl.toeLinks*i)	
					if endF.children.count==1 and (classof endF.children[1]==Dummy)  do 
					( append fingerAndToeNubs endF.children[1] )
				)
			)
			
			-----*异常物体
			error = #()
			error =  for i in all where 
			(	
				i.transform.scale.x>1 + accuracy or i.transform.scale.x<1 - accuracy or 
				i.transform.scale.y>1 + accuracy or i.transform.scale.y<1 - accuracy or 
				i.transform.scale.y>1 + accuracy or i.transform.scale.z<1 - accuracy
				
			) collect i
		
			
			errorFinal = #()
			for i in error do     ----    i=error[2]
			(
				if  (findItem fingerAndToeNubs i)==0 then	(append errorFinal  i)
			)
		
			
			--选择异常物体
			if yunMuscle_creatorUI.CC_select.checked then   (select errorFinal)
			
			
		----##打开日志
			---写入ini文件
			fileName =((GetDir #export)+ "\\scaleErrorLog.ini")
			try 
			(
				delIniSetting fileName "缩放不为100的物体(排除biped手指脚趾的末端)" 
				setINISetting fileName  "缩放不为100的物体(排除biped手指脚趾的末端)"  "蒙皮文件安全:"  "没有异常缩放物体"
			)catch()   ---清空log			
			if errorFinal.count>1 then			
			(
				delIniSetting fileName "缩放不为100的物体(排除biped手指脚趾的末端)"
				---写入，必须有四个变量：路径，父1，父2，主体
				for i in errorFinal do ( setINISetting fileName  "缩放不为100的物体(排除biped手指脚趾的末端)"  i.name  (i.transform.scale as string))
			)
			if yunMuscle_creatorUI.CC_log.checked then  
			(
				shellLaunch "notepad.exe" fileName
			)
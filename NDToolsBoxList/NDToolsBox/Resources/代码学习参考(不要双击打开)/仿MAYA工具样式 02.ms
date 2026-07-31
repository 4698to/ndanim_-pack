(
	------------------------------------------------------------------------------
	-- 本代码由MAX DotNet 编辑器输出
	-- 对此文件的更改可能会导致不正确的行为，
	-- 并且如果重新生成代码，这些更改将会丢失。
	-- 生成此代码的工具为测试版本，作者并不能保证代码的完全可用性。
	-- DotNet For Max 技术探讨欢迎加群：364518591。
	-- 如发现错误或有任何好建议欢迎联系我唯一QQ：602076763
	-- BY：蓬荜生徽 2015年元旦发布~~
	------------------------------------------------------------------------------
	
	--判断窗口是否释放掉了，否则干掉他~~以免窗口重复打开...
	try(if not MaxScriptssForm.IsDisposed do MaxScriptssForm.Dispose())catch()

	MaxScriptssForm = dotNetObject "MaxCustomControls.maxForm" 
		IsMove = false
	FN MaxScriptssForm_Shown sender EventArgs = 
	( 
-- 		MaxScriptssForm.ResetBackColor() 
		MaxScriptssForm.TransparencyKey = MaxScriptssForm.BackColor
-- 		MaxScriptssForm.ResetForeColor() 
	) 
	dotNet.addEventHandler MaxScriptssForm "Shown" MaxScriptssForm_Shown  

	button1 = dotNetObject "System.Windows.Forms.Button"
	button3 = dotNetObject "System.Windows.Forms.Button"
	button5 = dotNetObject "System.Windows.Forms.Button"
	button2 = dotNetObject "System.Windows.Forms.Button"
	button4 = dotNetObject "System.Windows.Forms.Button"
	-- button1
	button1.Location = dotNetObject "System.Drawing.Point" 160 36 
	button1.Name = "button1" 
	button1.Size = dotNetObject "System.Drawing.Size" 75 23 
	button1.TabIndex = 15 
	button1.Text = "button1" 
	button1.UseVisualStyleBackColor = True 
	-- button3
	button3.Location = dotNetObject "System.Drawing.Point" 300 129 
	button3.Name = "button3" 
	button3.Size = dotNetObject "System.Drawing.Size" 75 23 
	button3.TabIndex = 10 
	button3.Text = "button11" 
	button3.UseVisualStyleBackColor = True 
	-- button5
	button5.Location = dotNetObject "System.Drawing.Point" 160 122 
	button5.Name = "button5" 
	button5.Size = dotNetObject "System.Drawing.Size" 77 33 
	button5.TabIndex = 16 
	button5.Text = "移动" 
	button5.UseVisualStyleBackColor = True 

global currentPositionY,currentPositionX,PosX,PosY
	FN  button5_MouseMove sender EventArgs =
	(	
		--鼠标在控件上移动时
		if IsMove do
		(
			MaxScriptssForm.Left += (MaxScriptssForm.MousePosition.x  - currentPositionX )+(EventArgs.x-PosX)
			MaxScriptssForm.Top += (MaxScriptssForm.MousePosition.y  - currentPositionY)+(EventArgs.y-PosY)
			currentPositionY = MaxScriptssForm.MousePosition.y
			currentPositionX = MaxScriptssForm.MousePosition.X
		)
	)
	dotNet.addEventHandler button5 "MouseMove" button5_MouseMove 
	
	FN  MaxScriptssForm_MouseUp sender EventArgs =
	(
		--鼠标弹起时
		IsMove = false
	)
	dotNet.addEventHandler button5 "MouseUp" MaxScriptssForm_MouseUp 

	FN  MaxScriptssForm_MouseDown sender EventArgs =
	(
		--用鼠标单击控件
		IsMove = true
		currentPositionY=MaxScriptssForm.MousePosition.Y
		currentPositionX=MaxScriptssForm.MousePosition.X
		PosX = EventArgs.x
		PosY = EventArgs.y
	)
	dotNet.addEventHandler button5 "MouseDown" MaxScriptssForm_MouseDown 

	FN  MaxScriptssForm_Leave sender EventArgs =
	(

		
	)
	-- button2
	button2.Location = dotNetObject "System.Drawing.Point" 161 218 
	button2.Name = "button2" 
	button2.Size = dotNetObject "System.Drawing.Size" 75 23 
	button2.TabIndex = 17 
	button2.Text = "button2" 
	button2.UseVisualStyleBackColor = True 
	-- button4
	button4.Location = dotNetObject "System.Drawing.Point" 21 124 
	button4.Name = "button4" 
	button4.Size = dotNetObject "System.Drawing.Size" 75 23 
	button4.TabIndex = 18 
	button4.Text = "button4" 
	button4.UseVisualStyleBackColor = True 
	-- MaxScriptssForm
	MaxScriptssForm.ClientSize = dotNetObject "System.Drawing.Size" 396 277 
	MaxScriptssForm.Controls.Add(button4)
	MaxScriptssForm.Controls.Add(button2)
	MaxScriptssForm.Controls.Add(button1)
	MaxScriptssForm.Controls.Add(button3)
	MaxScriptssForm.Controls.Add(button5)
	MaxScriptssForm.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Default
	MaxScriptssForm.Font = dotNetObject "System.Drawing.Font" "宋体" 9  
	MaxScriptssForm.ForeColor = (dotNetClass "System.Drawing.SystemColors").ControlText
	MaxScriptssForm.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").None
	MaxScriptssForm.Name = "MaxScriptssForm" 
	MaxScriptssForm.RightToLeft = (dotNetClass "System.Windows.Forms.RightToLeft").No

	FN  MaxScriptssForm_Deactivate sender EventArgs =
	(
		MaxScriptssForm.close()
	)
	dotNet.addEventHandler MaxScriptssForm "Deactivate" MaxScriptssForm_Deactivate 
	MaxScriptssForm.Show()
	--MaxScriptssForm.Show(DotNetObject "MaxCustomControls.Win32HandleWrapper" (DotNetObject "System.IntPtr" (windows.getMAXHWND()))) 

)
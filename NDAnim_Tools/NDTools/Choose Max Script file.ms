--(
--global
textbox190310_DragOver = undefined
--global
textbox190310_DragDrop = undefined
--global
button1_Click = undefined
files = #()
--global
--------------------------------------------------------------------------------
--# 如发现错误或有任何建议欢迎联系我,Email：602076763@qq.com
--# 对此文件的更改可能会导致错误，并且如果重新生成代码，这些更改将会丢失。
--# DotNet For MXS 技术探讨欢迎加群：364518591  -BY:蓬荜生徽-
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
global MxsDesignerHost
struct MxsDesignerHost
(
	private fn LoadUsing =
	(
	),
	 -- [Import NameSpace: System]
	 -- [Import NameSpace: System.IO]
	 -- [Import NameSpace: System.Data]
	 -- [Import NameSpace: System.Design]
	 -- [Import NameSpace: System.Drawing]
	 -- [Import NameSpace: System.ComponentModel]
	 -- [Import NameSpace: System.Windows.Forms]
	 -- [Import NameSpace: System.Reflection]
	Form1 = undefined,
	private groupBox1 = undefined, -- 声明 System.Windows.Forms.GroupBox
	private button1 = undefined, -- 声明 System.Windows.Forms.Button
	public textbox190310 = undefined, -- 声明 System.Windows.Forms.TextBox

	fn InitializeComponent =
	(
		this.textbox190310 = (DotnetObject "System.Windows.Forms.TextBox")
		this.groupBox1 = (DotnetObject "System.Windows.Forms.GroupBox")
		this.button1 = (DotnetObject "System.Windows.Forms.Button")
		this.groupBox1.SuspendLayout()
		this.Form1.SuspendLayout()
		--
		-- textbox190310
		--
		this.textbox190310.AllowDrop = true
		this.textbox190310.Location = (DotnetObject "System.Drawing.Point" 6 26)
		this.textbox190310.Name = "name_textbox190310"
		this.textbox190310.Size = (DotnetObject "System.Drawing.Size" 387 21)
		this.textbox190310.TabIndex = 0

		/*[(TextChanged) 在控件上更改 Text 属性的值时引发的事件。]*/
		dotNet.addEventHandler this.textbox190310 "DragOver" textbox190310_DragOver
		dotNet.addEventHandler this.textbox190310 "DragDrop" textbox190310_DragDrop

		--
		-- groupBox1
		--
		this.groupBox1.Controls.Add this.button1
		this.groupBox1.Controls.Add this.textbox190310
		this.groupBox1.Location = (DotnetObject "System.Drawing.Point" 12 11)
		this.groupBox1.Name = "groupBox1"
		this.groupBox1.Size = (DotnetObject "System.Drawing.Size" 399 123)
		this.groupBox1.TabIndex = 1
		this.groupBox1.TabStop = false
		this.groupBox1.Text = "Encrypt:"
		this.groupBox1.UseCompatibleTextRendering = true
		--
		-- button1
		--
		this.button1.Location = (DotnetObject "System.Drawing.Point" 6 62)
		this.button1.Name = "button1"
		this.button1.Size = (DotnetObject "System.Drawing.Size" 387 43)
		this.button1.TabIndex = 1
		this.button1.Text = "Choose Max Script file"
		this.button1.UseCompatibleTextRendering = true
		this.button1.UseVisualStyleBackColor = true

		/*[(Click) 单击组件时发生。]*/
		dotNet.addEventHandler this.button1 "Click" button1_Click

		--
		-- Form1
		--
		this.Form1.ClientSize = (DotnetObject "System.Drawing.Size" 423 140)
		this.Form1.Controls.Add this.groupBox1
		this.Form1.FormBorderStyle = (DotnetClass "System.Windows.Forms.FormBorderStyle").FixedToolWindow
		this.Form1.Name = "Form1"
		this.Form1.TopMost = true
		this.Form1.StartPosition = (DotnetClass "System.Windows.Forms.FormStartPosition").CenterScreen
		this.Form1.Text = "CreateEncrypting 0.1"
		this.groupBox1.ResumeLayout false
		this.groupBox1.PerformLayout()
		this.Form1.ResumeLayout false
	),

	fn Run =
	(
		LoadUsing()
		Form1 = DotnetObject "System.Windows.Forms.Form"
		InitializeComponent()
		--fn Form1_Activated = ((dotnetclass "ManagedServices.AppSDK").DisableAccelerators())
		--fn Form1_Deactivate = ((dotnetclass "ManagedServices.AppSDK").EnableAccelerators())
		--dotNet.addEventHandler this.Form1 "Activated" Form1_Activated
		--dotNet.addEventHandler this.Form1 "Deactivate" Form1_Deactivate
		--local MaxHwndPtr = (DotNetObject "System.IntPtr" (Windows.GetMaxHwnd()))
		--if (maxversion())[1] <= 1600 then (Form1.Show(DotNetObject "MaxCustomControls.Win32HandleWrapper" MaxHwndPtr))
		--	else (Form1.Show((DotNetObject "System.Windows.Forms.NativeWindow").FromHandle MaxHwndPtr))
        fn Form1_FormClosing sender EventArgs =
        (
            ::MxsDesignerHost = undefined
            max_script_20190310 = undefined;

            (dotnetclass "system.gc").collect()
            --gc()
            --print "close"
        )
        dotNet.addEventHandler this.Form1 "FormClosed" Form1_FormClosing
		Form1.show()
	),

	on Create do
	(
		Run()
	)

)

/*判断窗口是否释放掉了，否则干掉他~~以免窗口重复打开...*/
try(if max_script_20190310.Form1 != undefined and not max_script_20190310.Form1.IsDisposed do max_script_20190310.Form1.Dispose())catch()

--try(filein ((dotnetobject "System.String" (getthisscriptfilename())).replace ".Designer" ""))catch(print (getcurrentexception()))
	FN  textbox190310_DragOver sender EventArgs =
	(
		EventArgs.Effect = if EventArgs.data.ContainsFileDropList() then EventArgs.Effect.Move else EventArgs.Effect.None
	)
	FN  textbox190310_DragDrop sender EventArgs =
	(
		data = EventArgs.data.GetFileDropList()
		files =  for k = 0 to data.count-1 collect data.item[k]
		--max_script_20190310.textbox190310
		sender.text = files[1]
		--for i in files do (
		--	print (getfilenamefile i)
		--)
	)

	FN  button1_Click sender EventArgs =
	(
		for i in files do
		(
			 try (if (getFilenameType i) == ".ms" do encryptScript i version:1 )catch()
		)
	)
	--::
	global max_script_20190310 = MxsDesignerHost()
--)



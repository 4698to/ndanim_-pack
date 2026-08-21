/*
# coding: utf-8 
# @Date    : 2024-05-22 21:57:44
# @Author  : 4698to (738746223@qq.com)
# @Link    : sundaybox.cc
# @99U     : 199505
*/
try(destroyDialog TentacleBone_pos )catch()

rollout TentacleBone_pos "TentacleBone v3.1" width:260 height:120 
(
	group "反向"(
		button btn_do_b "选中创建" width:100 height:20 
	)

	group "正向"
	(

		button btn_do_f "选中创建" width:100 height:20 
	)
	local Proot = undefined

	fn CreateCircleMaster Sources title =
	(
		Proot = Point pos:[0,0,0] isSelected:off Box:on Cross:on name:(uniqueName "Tentacle_Master") size:(Sources[1].width*10) wirecolor:red
		--Proot.transform = Source[Source.count].transform
		Proot.transform = Sources[1].transform
		--Sources[1].parent = Proot
		
		select Proot
			modPanel.addModToSelection (EmptyModifier ()) ui:on
				ca=attributes Tentacle_Controls
				(
					parameters NewSlider rollout: Tentacle
					(
						rig_type type:#string UI:lab_type default:""
						VitesseX type: #float  ui:(spn01)
						AmplitudeX type: #float  ui:(spn02)
						OffsetX type: #float  ui:(spn03)
						FallofX type: #float  ui:(spn10)
						
						VitesseY type: #float  ui:(spn04)
						AmplitudeY type: #float  ui:(spn05)
						OffsetY type: #float  ui:(spn06)
						FallofY type: #float  ui:(spn11)
						
						VitesseZ type: #float  ui:(spn07)
						AmplitudeZ type: #float  ui:(spn08)
						OffsetZ type: #float  ui:(spn09)
						FallofZ type: #float  ui:(spn12)
					)	
					rollout Tentacle "Tentacle Controls"
					(	
						edittext lab_type "" readOnly:true 
						group "X" (
							label lab_x ""

							spinner spn01 "Vitesse" range:[0,100,0] width:120 Align:#right
							spinner spn02 "Amplitude" range:[0,100,0]  width:120 Align:#right		
							spinner spn03 "Offset" range:[0,100,0]   width:120 Align:#right
							spinner spn10 "Fallof" range:[0,10,0] width:120 Align:#right	
							button btn01 "Random X" width:120 height:20 
						)
						group "Y"(

							label lab_y ""

							spinner spn04 "Vitesse" range:[0,100,0] width:120 Align:#right	
							spinner spn05 "Amplitude" range:[0,100,0] width:120	Align:#right
							spinner spn06 "Offset" range:[0,100,0] width:120 Align:#right
							spinner spn11 "Fallof" range:[0,10,0] width:120 Align:#right
							button btn02 "Random Y" width:120 height:20 
						)
						group "Z" (
							label lab_z ""
							spinner spn07 "Vitesse" range:[0,100,0] width:120 Align:#right	
							spinner spn08 "Amplitude" range:[0,100,0] width:120	Align:#right
							spinner spn09 "Offset" range:[0,100,0] width:120 Align:#right
							spinner spn12 "Fallof" range:[0,10,0] width:120 Align:#right
							button btn03 "Random Z" width:120 height:20
						)
						button btn04 "Random All" width:140 height:30
						button btn05 "Reset" width:140 height:20
						fn get_loop_range_lenght arg =
						(
							-- 30 fps 
							v = ((360.0 / (arg / 500.0) / 160.0) as integer )
							v as string 
						)
						on Tentacle open do 
						(
							lab_x.text = get_loop_range_lenght spn01.value
							lab_y.text = get_loop_range_lenght spn04.value
							lab_z.text = get_loop_range_lenght spn07.value
						)
						on spn01 changed arg do 
						(
							lab_x.text = get_loop_range_lenght arg 
						)
						on spn04 changed arg do 
						(
							lab_y.text = get_loop_range_lenght arg 
						)
						on spn07 changed arg do 
						(
							lab_z.text = get_loop_range_lenght arg 
						)
						on btn05 pressed do
						(
							Spinn = #(spn01, spn02, spn03, spn04, spn05, spn06, spn07, spn08, spn09, spn10, spn11, spn12)
							for o in Spinn do
							(
								o.value = 0
							)
						)
						
						on btn01 pressed do
						(
							spn01.value = random 0 5
							spn10.value = random 0.00 1.00
							Spinn = #(spn02, spn03)
							for o in Spinn do
							(
								o.value = random 0 10 
							)
						)
						
						on btn02 pressed do
						(
							spn04.value = random 0 5
							spn11.value = random 0.00 1.00
							Spinn = #(spn05, spn06)
							for o in Spinn do
							(
								o.value = random 0 10
							)
						)
						
						on btn03 pressed do
						(
							spn07.value = random 0 5
							spn12.value = random 0.00 1.00
							Spinn = #(spn08, spn09)
							for o in Spinn do
							(
								o.value = random 0 10
							)
						)
						
						on btn04 pressed do
						(
							Spinn = #(spn02, spn03, spn05, spn06, spn08, spn09)
							for o in Spinn do
							(
								o.value = random 0 10
							)
							Spinn = #(spn01, spn04, spn07)
							for o in Spinn do
							(
								o.value = random 0 5
							)
							
							Spinn = #(spn10, spn11, spn12)
							for o in Spinn do
							(
								o.value = random 0.00 1.00
							)
							
						)
					)
				)
				custAttributes.add $.modifiers[1] ca
				$.modifiers[1].rig_type = title
				clearSelection()
	)
	on btn_do_b pressed do 
	(
		Proot = undefined

		Source = selection as array

		CreateCircleMaster Source "反向"

		source_help = #()
		help_p = #()
		dist = 0 
		for i=1 to Source.count do
		(
			ptm = Source[1].transform
			if i > 1 do (
			    dist += distance Source[i] Source[i-1]
				--format "% - % == % \n" Source[i].name Source[i-1].name (Source[i-1]).length
				ptm = preTranslate ptm [dist, 0 , 0 ]
			)
			ppp_name = uniqueName ("B_rig_"+i as string + "_")
			ppp = Point transform:ptm size:0.2 name: ppp_name
			pp = copy ppp 
			pp.name = uniqueName ("F_rig_"+i as string + "_")
			pp.size = 1 

			source_help[i] = pp 
			help_p[i] = ppp 
		)

		for i = source_help.count to 2 by - 1 do 
		(
			source_help[i].parent =  source_help[(i-1)]
		)
		source_help[1].parent = Proot


		for i = 1 to (help_p.count - 1) do 
		(
			help_p[i].parent = help_p[(i+1)]
		)
		help_p[help_p.count].parent = Proot

		for i=1 to Source.count do
		(
			---d_w = i * 1.0 
			
 			d_w = Source.count - (i - 1) 


			Source[i].name = uniqueName("TentacleBone_"+i as string)

			help_p[i].position.controller = position_list ()

			--help_p[i].position.controller.Available.controller = Position_XYZ ()
			--help_p[i].position.controller.Available.controller = Position_XYZ ()	
			--help_p[i].position.controller.setname 2 "Slave"
			--help_p[i].position.controller.setname 3 "Manual"
			--help_p[i].position.controller.setActive 3 
			
			help_p[i].rotation.controller = rotation_list ()
			
			help_p[i].rotation.controller.Available.controller = Euler_XYZ ()
			help_p[i].rotation.controller.Available.controller = Euler_XYZ ()
			
			help_p[i].rotation.controller.setname 2 "Slave"
			help_p[i].rotation.controller.setname 3 "Manual"
			help_p[i].rotation.controller.setActive 3 

			
			yctr = float_script ()

			yctr.addTarget "a" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#VitesseY]
			yctr.addTarget "b" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#AmplitudeY]
			yctr.addTarget "c" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#OffsetY]
			yctr.addTarget "e" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#FallofY]
			yctr.addConstant "d" d_w
			

			yctr.Script = "degtorad((sin(t*(a/500.0)+c*d))*b)*(d*e)"
			-- 360.0 / (a / 500.0) / 160.0 循环帧
			zctr = copy yctr
			zctr.SetTarget "a" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#VitesseZ]
			zctr.SetTarget "b" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#AmplitudeZ]
			zctr.SetTarget "c" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#OffsetZ]
			zctr.SetTarget "e" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#FallofZ]

			xctr = copy yctr
			xctr.SetTarget "a" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#VitesseX]
			xctr.SetTarget "b" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#AmplitudeX]
			xctr.SetTarget "c" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#OffsetX]
			xctr.SetTarget "e" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#FallofX]
			
			
			help_p[i].rotation.controller.Slave.controller.X_Rotation.controller = xctr
			help_p[i].rotation.controller.Slave.controller.Y_Rotation.controller = yctr
			help_p[i].rotation.controller.Slave.controller.Z_Rotation.controller = zctr

		)

		for i=1 to Source.count do
		(
			Source[i].rotation.controller = rotation_list ()
			Source[i].position.controller = position_list ()
			
			source_help[i].rotation.controller = rotation_list ()
			source_help[i].position.controller = position_list ()

			pos_cons = position_constraint()
			pos_cons.appendTarget help_p[i] 50 

			source_help[i].position.controller.Available.controller = pos_cons
			source_help[i].position.controller.Available.controller = Position_XYZ ()
			source_help[i].position.controller.setname 2 "Slave"
			source_help[i].position.controller.setname 3 "Manual"
			source_help[i].position.controller.setActive 3 

			if (i < Source.count ) do 
			(
				
				local RotCon = LookAt_Constraint()
				RotCon.appendTarget help_p[i+1] 50 
				RotCon.target_axis = 0
				RotCon.upnode_axis = 1
				RotCon.StoUP_axis = 1
				RotCon.upnode_ctrl = 1
				RotCon.pickUpNode = help_p[i]
				RotCon.viewline_length_abs = false
				RotCon.upnode_world = false
				RotCon.lookat_vector_length = 0.1

				source_help[i].rotation.controller.Available.controller = RotCon
				source_help[i].rotation.controller.Available.controller = Euler_XYZ ()
				source_help[i].rotation.controller.setname 2 "Slave"
				source_help[i].rotation.controller.setname 3 "Manual"
				source_help[i].rotation.controller.setActive 3 

			)

			ori_ctr = rotation_script()
			ori_ctr.addNode "s_help" source_help[i]
			
			if isValidNode Source[i].parent then (
				ori_ctr.addNode "s_parent" Source[i].parent 
				--script_text = "ltm = s_help.transform * inverse s_help.Parent.transform;\n"	
				script_text = "ltm = s_help.transform * inverse s_parent.transform;\n"	
			)else(
				script_text = "ltm = s_help.transform ;\n"	
			)

			script_text += "ltm.rotation;\n"

			ori_ctr.Script = script_text

			Source[i].rotation.controller[1].controller = ori_ctr
			Source[i].rotation.controller.Available.controller = Euler_XYZ ()	
			Source[i].rotation.controller.setname 1 "Slave"
			Source[i].rotation.controller.setname 2 "Manual"
			Source[i].rotation.controller.setActive 2 

			
		)
		pos_cons = position_constraint()
		pos_cons.appendTarget source_help[1] 50 
		Source[1].position.controller.Available.controller = pos_cons

		Source[1].position.controller.Available.controller = Position_XYZ ()
		Source[1].position.controller.setname 2 "Slave"
		Source[1].position.controller.setname 3 "Manual"
		Source[1].position.controller.setActive 3 

	)

	on btn_do_f pressed do 
	(
		Proot = undefined
		Source = selection as array
		CreateCircleMaster Source "正向"

		for i=1 to Source.count do
		(
			Source[i].name = uniqueName("TentacleBone_"+i as string)
			Source[i].rotation.controller = rotation_list ()
			Source[i].rotation.controller.Available.controller = Euler_XYZ ()	
			Source[i].rotation.controller.setname 1 "Slave"
			Source[i].rotation.controller.setname 2 "Manual"
			Source[i].rotation.controller.setActive 2 
			
			Source[i].rotation.controller.Slave.controller.Y_Rotation.controller = float_script ()
			Source[i].rotation.controller.Slave.controller.Y_Rotation.controller.addTarget "a" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#VitesseY]
			Source[i].rotation.controller.Slave.controller.Y_Rotation.controller.addTarget "b" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#AmplitudeY]
			Source[i].rotation.controller.Slave.controller.Y_Rotation.controller.addTarget "c" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#OffsetY]
			Source[i].rotation.controller.Slave.controller.Y_Rotation.controller.addTarget "e" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#FallofY]
			Source[i].rotation.controller.Slave.controller.Y_Rotation.controller.addConstant "d" i
			Source[i].rotation.controller.Slave.controller.Y_Rotation.controller.Script = "degtorad((sin(t*(a/500)+c*d))*b)*(d*e)"
			
			Source[i].rotation.controller.Slave.controller.X_Rotation.controller = float_script ()
			Source[i].rotation.controller.Slave.controller.X_Rotation.controller.addTarget "a" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#VitesseX]
			Source[i].rotation.controller.Slave.controller.X_Rotation.controller.addTarget "b" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#AmplitudeX]
			Source[i].rotation.controller.Slave.controller.X_Rotation.controller.addTarget "c" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#OffsetX]
			Source[i].rotation.controller.Slave.controller.X_Rotation.controller.addTarget "e" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#FallofX]
			Source[i].rotation.controller.Slave.controller.X_Rotation.controller.addConstant "d" i
			Source[i].rotation.controller.Slave.controller.X_Rotation.controller.Script = "degtorad((sin(t*(a/500)+c*d))*b)*(d*e)"
			
			Source[i].rotation.controller.Slave.controller.Z_Rotation.controller = float_script ()
			Source[i].rotation.controller.Slave.controller.Z_Rotation.controller.addTarget "a" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#VitesseZ]
			Source[i].rotation.controller.Slave.controller.Z_Rotation.controller.addTarget "b" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#AmplitudeZ]
			Source[i].rotation.controller.Slave.controller.Z_Rotation.controller.addTarget "c" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#OffsetZ]
			Source[i].rotation.controller.Slave.controller.Z_Rotation.controller.addTarget "e" Proot.modifiers[#Attribute_Holder].Tentacle_Controls[#FallofZ]
			Source[i].rotation.controller.Slave.controller.Z_Rotation.controller.addConstant "d" i
			Source[i].rotation.controller.Slave.controller.Z_Rotation.controller.Script = "degtorad((sin(t*(a/500)+c*d))*b)*(d*e)"
		)
	)
)

createDialog TentacleBone_pos
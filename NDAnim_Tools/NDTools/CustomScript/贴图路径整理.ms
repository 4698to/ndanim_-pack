--------------------------------------
--	zoa path editor for maps, ies, hdri and vrayproxies
--	2012 by zoa
--	Balogh Andras Miklos
--  	http://www.zoa3d.com
--------------------------------------
--   	v 3.00
--  	Last Modified On: 28/03/2012
--   	Created On: 17/11/2009
-------------------------------------------------------------------------------
--   	Description:
--
--	Simple Path relinker application for maps, ies, hdri and vrayproxy objects. Features are: path text replacing and copy functions.
--	The two text fields on the bottom of the script window are for "original" and for "future" paths.
--	$ stand for string. Use it to copy a map path of a selected map to the desired text field.
-------------------------------------------------------------------------------
--	Notes and limitations:
--
--	Refreshing works manually only
-------------------------------------------------------------------------------
--	Revision History:
--
--	v 1.00 - 10/10/2010 - first public version released
--	v 3.00 - 28/03/2012 - new ui, hdri, environment, object selection
-------------------------------------------------------------------------------


try(destroyDialog patheditor)catch()

rollout patheditor "贴图路径整理" width:666 height:445
(
	local map_list=#()
	local	mat_array=#()
	local full_list=#()
	local environ_tmp_list=#()
	local ascending=true
	local col=-1

	dotNetControl lv "System.Windows.Forms.ListView" width:657 height:200 pos:[5,5]


	checkbox chk_1 "bitmap" checked:true
	checkbox chk_2 "hdri"	checked:true
	checkbox chk_3 "VrayProxy" checked:true
	checkbox chk_4 "IES"	checked:true
	checkbox chk_5 "environment" checked:true

	button btn_sel "select" width:100
	button btn_copy "copy to" width:100 tooltip:"复制到新路径"
	button btn_miss "select missing" width:100
	button btn_set "设置新路径" width:100 tooltip:"设置为新路径"
	button btn_refr "刷新" width:100 tooltip:"刷新重新加载"
	button btn_repl "replace to"	width:100

	edittext old_path "" width:220 height:17
	button old_path_browse "..." width:20 height:20
	button get_old_path "$" width:20 height:20

	edittext new_path "目"  width:220 height:17
	button new_path_browse "..." width:20 height:20 tooltip:"选择新路径"
	button get_new_path "$" width:20 height:20 --Enabled:false






-- fn  re_size ----------------------------------------------------------------------------------------------
	fn re_size arg=
		(
		lv.width=arg[1]-10
		lv.Columns.item[0].width=floor (300*(lv.width-17)/640)
		lv.Columns.item[1].width=floor (140*(lv.width-17)/640)
		lv.Columns.item[2].width=floor (60*(lv.width-17)/640)
		lv.Columns.item[3].width=floor (60*(lv.width-17)/640)
		lv.Columns.item[4].width=floor (80*(lv.width-17)/640)
		lv.height=arg[2]-85

		chk_1.pos=[5,arg[2]-75]
		chk_2.pos=[110,arg[2]-75]
		chk_3.pos=[215,arg[2]-75]
		chk_4.pos=[5,arg[2]-50]
		chk_5.pos=[110,arg[2]-50]

		btn_sel.pos=[arg[1]/2+5,arg[2]-75]
		btn_refr.pos=[arg[1]/2+110,arg[2]-75]
		btn_miss.pos=[arg[1]/2+215,arg[2]-75]
		btn_copy.pos=[arg[1]/2+5,arg[2]-50]
		btn_repl.pos=[arg[1]/2+110,arg[2]-50]
		btn_set.pos=[arg[1]/2+215,arg[2]-50]

		old_path.width=floor (arg[1]/2-60)
		old_path.pos=[5, arg[2]-23]
		old_path_browse.pos=[floor (arg[1]/2-50), arg[2]-25]
		get_old_path.pos=[floor (arg[1]/2-25), arg[2]-25]

		new_path.width=floor (arg[1]/2-80)
		new_path.pos=[floor (arg[1]/2+25), arg[2]-23]
		new_path_browse.pos=[(arg[1]-50), arg[2]-25]
		get_new_path.pos=[(arg[1]-25), arg[2]-25]
		)

-- fn  fill_mat_array ----------------------------------------------------------------------------------------------
fn fill_mat_array =
	(
	materials=#()
	for obj in geometry do
		(
		a= (finditem materials obj.mat)
		if a==0 then
			(
			append materials obj.mat
			append mat_array #(obj.mat, #(obj))
			)else(
			append mat_array[a][2] obj
			)
		)

	for mat = 1 to mat_array.count do
		(
		tex_maps=#()
		bit_maps=#()
		hdri_maps=#()
		mats=#(mat_array[mat][1])

		for i in mats do
			(
			try
			if (getNumSubMtls i)>1 then
				(
				for j = 1 to (getNumSubMtls i) do
					(
					append mats (getSubMtl i j)
					)
				)
			catch ()

			try
				(
				for m = 1 to (getNumSubTexmaps i) do
					(
					if (getSubTexmap i m)!=undefined then
						(
						append 	tex_maps (getSubTexmap i m)
						)
					)
				)
			catch()
			)


		for i in tex_maps do
			(
			if (classof i ) == Bitmaptexture then appendifunique bit_maps i.filename
			if (classof i ) == VRayHDRI then appendifunique hdri_maps i.HDRIMapName
			if (getNumSubTexmaps i)>0 then
				(
				for j= 1 to (getNumSubTexmaps i) do
					(
					if (getSubTexmap i j)!=undefined then
						(
						append tex_maps (getSubTexmap i j)
						)
					)
				)
			)

		mat_array[mat][3]=bit_maps
		mat_array[mat][4]=hdri_maps
		)
	)



-- fn setupListView----------------------------------------------------------------------------------------------
fn setupListView =
	(
	local topItemNum=0; if lv.items.count>0 then topItemNum=lv.TopItem.index -- record the scroll position so we can use it later


	lv.clear()

	lv.View = (dotNetClass "System.Windows.Forms.View").Details -- this is what allows the grid-like format to be used
	lv.fullRowSelect = true
	lv.gridLines = true
	lv.HideSelection=false
	lv.BorderStyle=lv.BorderStyle.FixedSingle
	lv.HeaderStyle=lv.HeaderStyle.Clickable
	lv.backColor=lv.backColor.FromArgb 220 220 000


	lv.Columns.add "file path" 300
	lv.Columns.add "file name" 140
	lv.Columns.add "ext" 60
	lv.Columns.add "type" 60
	lv.Columns.add "use" 80

	map_list=#()
	mat_array=#()
	full_list=#()
	rows=#()
	map_tmp_list=#()
	map_list=#()
	proxy_list=#()
	proxy_tmp_list=#()
	ies_tmp_list=#()
	ies_list=#()
	environ_tmp_list=#()
	environ_list=#()


	for m in getClassInstances BitmapTexture do
		(
		if m.filename!=undefined then
			(
			if (findItem map_tmp_list m.filename) == 0 then
				(
				append map_tmp_list m.filename
				append map_list #((getFilenamePath m.filename),(getFilenameFile  m.filename), (getFilenameType  m.filename), "bitmap","unused", #()  )
				)
			)
		)

	fill_mat_array ()

	for i in mat_array do
		(
		for j in i[3] do
			(
			for m=1 to map_list.count do
				(
				if j==map_tmp_list[m] then
					(
					map_list[m][5]="used"
					join map_list[m][6] i[2]
					)
				)
			)
		)



	for obj in geometry where classof obj == VRayProxy do
		(
		ok=true
		for arg in proxy_tmp_list do
			(
			if (areNodesInstances obj arg) then
				(
				ok=false
				a=finditem proxy_tmp_list arg
				append proxy_list[a][6] obj
				)
			)
		if ok then
			(
			append proxy_tmp_list obj
			append proxy_list #((getFilenamePath obj.filename),(getFilenameFile  obj.filename), (getFilenameType  obj.filename), "VrProxy", "used" , #(obj))
			)
		)

	for obj in lights where iskindof obj light do
		(
		ok=true
		m=""
		if ((classof obj==Target_Light) or  (classof obj==Free_Disc) or (classof obj==Free_Light) or (classof obj==Target_Disc)) do (m= obj.webFile)
		if classof obj==VRayIES  do (m= obj.ies_file)
		if m!="" then
			(
			for arg in ies_tmp_list do
				(
				if (areNodesInstances obj arg) then
					(
					ok=false
					a=finditem ies_tmp_list arg
					append ies_list[a][6] obj
					)
				)
			if ok then
				(

				append ies_tmp_list obj ;
				append ies_list #((getFilenamePath m),(getFilenameFile  m), (getFilenameType  m), "IES", "used" , #(obj))
				)
			)
		)



	if proxy_list.count>1 then
		(
		for i = 1 to proxy_list.count do
			(
			for j in proxy_list.count to i by -1 do
				(
				if i!=j then
					(
					if proxy_list[i][2]==proxy_list[j][2] then
						(
						if proxy_list[i][3]==proxy_list[j][3] then
							(
							join proxy_list[i][6] proxy_list[j][6]
							deleteitem proxy_list j
							)
						)
					)
				)
			)
		)


	if ies_list.count>1 then
		(
		for i = 1 to ies_list.count do
			(
			for j in ies_list.count to i by -1 do
				(
				if i!=j then
					(
					if ies_list[i][2]==ies_list[j][2] then
						(
						if ies_list[i][3]==ies_list[j][3] then
							(
							join ies_list[i][6] ies_list[j][6]
							deleteitem ies_list j
							)
						)
					)
				)
			)
		)

	if 	environmentMap !=undefined then append environ_tmp_list environmentMap
	--if 	renderers.current.environment_gi_map !=undefined then append environ_tmp_list renderers.current.environment_gi_map
	--if 	renderers.current.environment_rr_map !=undefined then append environ_tmp_list renderers.current.environment_rr_map
	--if 	renderers.current.environment_refract_map !=undefined then append environ_tmp_list renderers.current.environment_refract_map

	for i in environ_tmp_list do
		(
		if (classof i ) == Bitmaptexture then appendifunique environ_list  #((getFilenamePath i.filename),(getFilenameFile  i.filename), (getFilenameType  i.filename), "Map", "environment" )
		if (classof i ) == VRayHDRI and chk_2.checked==true then appendifunique environ_list  #((getFilenamePath i.HDRIMapName),(getFilenameFile  i.HDRIMapName), (getFilenameType  i.HDRIMapName), "Map", "environment" )
		if (getNumSubTexmaps i)>0 then
			(
			for j= 1 to (getNumSubTexmaps i) do
				(
				if (getSubTexmap i j)!=undefined then
					(
					append environ_tmp_list (getSubTexmap i j)
					)
				)
			)
		)

	if chk_1.checked==true then
		(
		for i in map_list do
			(
			append full_list i[6]
			li = dotNetObject "System.Windows.Forms.ListViewItem"  i[1]
			li.subitems.add i[2]
			li.subitems.add i[3]
			li.subitems.add i[4]
			li.subitems.add i[5]
			append rows li
			)
		)

	if chk_3.checked==true then
		(
		for i in proxy_list do
			(
			append full_list i[6]
			li = dotNetObject "System.Windows.Forms.ListViewItem"  i[1]
			li.subitems.add i[2]
			li.subitems.add i[3]
			li.subitems.add i[4]
			li.subitems.add i[5]
			append rows li
			)
		)

	if chk_4.checked==true then
		(
		for i in ies_list do
			(
			append full_list i[6]
			li = dotNetObject "System.Windows.Forms.ListViewItem"  i[1]
			li.subitems.add i[2]
			li.subitems.add i[3]
			li.subitems.add i[4]
			li.subitems.add i[5]
			append rows li
			)
		)

	if chk_5.checked==true then
		(
		for i in environ_list do
			(
			li = dotNetObject "System.Windows.Forms.ListViewItem"  i[1]
			li.subitems.add i[2]
			li.subitems.add i[3]
			li.subitems.add i[4]
			li.subitems.add i[5]
			append rows li
			)
		)

	lv.items.addRange rows

	)


-- fn addmap----------------------------------------------------------------------------------------------
local missing_maps=#()

fn addmap mapfile =
		(
		appendifunique missing_maps mapfile
		)


-- fn set_bitmap----------------------------------------------------------------------------------------------
fn set_bitmap	old_file new_file =
	(
	for m in getClassInstances BitmapTexture do
		(
		if m.filename == old_file do ( m.fileName=new_file)
		)
	)

-- fn set_bitmap----------------------------------------------------------------------------------------------
fn set_proxy	old_file new_file =
	(
	for obj in geometry where classof obj == VRayProxy do
		(
		if obj.filename == old_file do ( obj.fileName=new_file)
		)
	)

-- fn set_bitmap----------------------------------------------------------------------------------------------
fn set_ies	old_file new_file =
	(
	for obj in lights where iskindof obj light do
		(
		if ((classof obj==Target_Light) or  (classof obj==Free_Disc) or (classof obj==Free_Light) or (classof obj==Target_Disc)) then
			(
			if  obj.webFile == old_file then (obj.webFile=new_file)
			)
		if classof obj==VRayIES  then
			(
			if  obj.ies_file == old_file then (obj.ies_file=new_file)
			)
		)
	)

-- fn set_bitmap----------------------------------------------------------------------------------------------
fn set_map	old_file new_file =
	(
	for i in environ_tmp_list do
		(
		try (if  i.filename == old_file then (i.filename=new_file))catch ()
		try (if  i.HDRIMapName == old_file then (i.HDRIMapName=new_file))catch ()
		)
	)





-- main---------------------------------------------------------------------------------------------------------
	on patheditor open do
		(
		setupListView()
		re_size ([666,445])
		)

-- 	on lv ColumnClick arg do
-- 		(
-- 		tmp=#()
-- 		for i =1 to lv.Items.count do
-- 			(
-- 			append tmp (toLower lv.items.item[i-1].subitems.item[arg.column].text)
-- 			)

-- 		sort tmp
-- 		if col==arg.column then
-- 			(
-- 			if ascending==true then
-- 				(
-- 				tmp2=#()
-- 				for i=tmp.count to 1 by -1 do
-- 					(
-- 					append tmp2  tmp[i]
-- 					)
-- 				tmp=tmp2
-- 				ascending=false
-- 				)else(
-- 				ascending=true
-- 				)
-- 			)else(
-- 			ascending=true
-- 			)
-- 		col=arg.column
-- 		print tmp
-- 		)


	on new_path entered arg do
		(
		--	a=""
		if (substring new_path.text new_path.text.count 1)!="\\" then new_path.text = new_path.text + "\\"
		)

	on btn_sel pressed do
		(
    		deselect selection
    		if  lv.SelectedItems.count>0 then
    			(
    			for i =1 to lv.SelectedItems.count do
    				(
    				try (selectMore full_list[(lv.SelectedItems.item[i-1].index+1)])catch()
    				)
    			)
		)

	on btn_refr pressed do
		(
		setupListView()
		)

	on btn_miss pressed do
		(

		tmp=#()
		for i =1 to lv.Items.count do
			(
			if (doesFileExist ( lv.Items.item[i-1].subitems.item[0].text+lv.Items.item[i-1].subitems.item[1].text+lv.Items.item[i-1].subitems.item[2].text))==false then
				(
				lv.items.item[i-1].selected=true
				)else(
				lv.items.item[i-1].selected=false
				)
			)
		)

	on btn_copy pressed do
		(
		for i =1 to lv.SelectedItems.count do
			(
			old_file=lv.SelectedItems.item[i-1].subitems.item[0].text+lv.SelectedItems.item[i-1].subitems.item[1].text+lv.SelectedItems.item[i-1].subitems.item[2].text


-- 			if lv.SelectedItems.item[i-1].subitems.item[1].text
			new_file=new_path.text+lv.SelectedItems.item[i-1].subitems.item[1].text+lv.SelectedItems.item[i-1].subitems.item[2].text

			try (copyFile old_file new_file) catch ()
			)
		)

	on btn_repl pressed do
	(
		for i =1 to lv.SelectedItems.count do
		(
			arg=	lv.SelectedItems.item[i-1].subitems.item[0].text
			if (findstring arg old_path.text)!=undefined do
			(
				temp_text1=substring arg 1 ((findstring arg old_path.text)-1)
				temp_text2=new_path.text
				temp_text3=substring arg (old_path.text.count+(findstring arg old_path.text)) (arg.count-old_path.text.count-(findstring arg old_path.text)+1)
				j=temp_text1+temp_text2+temp_text3
		 		old_file=lv.SelectedItems.item[i-1].subitems.item[0].text+lv.SelectedItems.item[i-1].subitems.item[1].text+lv.SelectedItems.item[i-1].subitems.item[2].text
				new_file=j+lv.SelectedItems.item[i-1].subitems.item[1].text+lv.SelectedItems.item[i-1].subitems.item[2].text
				type=lv.SelectedItems.item[i-1].subitems.item[3].text
				if type=="bitmap"	then set_bitmap		old_file new_file
				if type=="IES" 		then set_ies			old_file new_file
				if type=="VrProxy"	then set_proxy	 	old_file new_file
				if type=="Map"		then set_map	 		old_file new_file
			)
		)
		setupListView()
	)

	on btn_set pressed do
		(
		for i =1 to lv.SelectedItems.count do
			(
			old_file=lv.SelectedItems.item[i-1].subitems.item[0].text+lv.SelectedItems.item[i-1].subitems.item[1].text+lv.SelectedItems.item[i-1].subitems.item[2].text
			type=lv.SelectedItems.item[i-1].subitems.item[3].text
			new_file=new_path.text+lv.SelectedItems.item[i-1].subitems.item[1].text+lv.SelectedItems.item[i-1].subitems.item[2].text

			if type=="bitmap"	then set_bitmap		old_file new_file
			if type=="IES" 		then set_ies			old_file new_file
			if type=="VrProxy"	then set_proxy	 	old_file new_file
			if type=="Map"		then set_map	 		old_file new_file
			)
		setupListView()
		)

	on patheditor resized arg do
		(
		re_size (arg)
		)

	on old_path_browse pressed do
		(
		local dir = getSavePath caption:"new path" initialDir:(old_path.text)
		if (dir != undefined) do (old_path.text = (dir+"\\" ))
		)

	on get_old_path pressed do
		(
		try (i= lv.SelectedItems.item[0].subitems.item[0].text)catch()
		if (i != undefined) do (old_path.text = i)
		)

	on new_path_browse pressed do
		(
		local dir = getSavePath caption:"new path" initialDir:(new_path.text)
		if (dir != undefined) do (new_path.text = (dir+"\\" ))
		)

	on get_new_path pressed do
		(
		  try ( i = lv.SelectedItems.item[0].subitems.item[0].text;print i )catch()
		  if ( i != undefined) do (new_path.text = i)
		)
)
createdialog patheditor style:#( #style_sysmenu, #style_resizing, #style_minimizebox, #style_titlebar ) --pos:[0,100]



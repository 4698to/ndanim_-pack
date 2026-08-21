
(
        Global rlpick, target = undefined,Morpher_target=undefined,mirror_target,skin_target,mirror_target01,get_vert,get_array,vert_array;
     local p_poly,get_VertSelection;   
        
	function Yvi_selSceneObjChanged =
        (
                source = selection[1];
                if( target == undefined )then
                (
                        return undefined;
                )
                if( source == undefined)then
                (
                        return undefined;
                )
                rl_pick.lb_selSource.text = source.name;


        )

        rollout rlpick11 "变形器镜像工具" width:200 height:200
        (
        	pickbutton pbtn_pickTarget "Morpher物体" pos:[32,7] width:133 height:33 autoDisplay:true
        	label lb_selSource "" pos:[50,60] width:99 height:15
        	pickbutton pbtn_pickTarget001 "镜像物体" pos:[32,50] width:133 height:33 autoDisplay:true
        	button btn16 "开始" pos:[24,100] width:71 height:38
        	button btn5 "刷新" pos:[121,107] width:57 height:24
        	button btn7 "复制顶点" pos:[24,150] width:65 height:24
        	button btn8 "粘贴顶点" pos:[121,151] width:65 height:24	
	
			
			
        	on rl_pick close do
        	(
        	        callbacks.removeScripts id:#FnselNodeChanged01
        	)
        	on rl_pick changed state do
        	(
        	      if ( state == on ) then
        	      (
        	              
        	              -- 注册selectionSetChanged的消息回调函数Yvi_selSceneObjChanged,
        	               Callbacks.AddScript #selectionSetChanged "Yvi_selSceneObjChanged()" ID:#FnselNodeChanged01
        	        )
        	)
        	on pbtn_pickTarget picked obj do
        	(
        	        if( obj != undefined)do
        	        (
        	                -- pick source obj
        	                Morpher_target= obj;
        				
        	        )
        	)
        	on pbtn_pickTarget001 picked obj do
        	(
        	        if( obj != undefined)do
        	        (
        	                -- pick source obj
        	                target= obj;
        			
        	        )
        	)
        	on btn16 pressed do
        	(
        	     if(  Morpher_target!= undefined)do
        		        (
        		                -- pick source obj
        		            mirror_target= copy Morpher_target;
        					skin_target=copy Morpher_target;
        					
        					
        		        )
        			
        				-------先镜像再加变形器
        		if( mirror_target!= undefined)do
        			(
        			select mirror_target;
        			modPanel.addModToSelection (mirror ()) ui:on;
        			modPanel.addModToSelection (Morpher ()) ui:on;
        		   )
        		   -------加蒙皮包裹
        		if( skin_target!= undefined)do
        			(
        			select skin_target;
        			modPanel.addModToSelection (Skin_Wrap()) ui:on;
        			
        			skin_target.modifiers[#蒙皮包裹].meshList =#(mirror_target)	;
        		    skin_target.modifiers[#蒙皮包裹].engine =0;
        		)
        		-----镜像物体加个镜个
        		if(target!= undefined)do
        		(
        		    mirror_target01=copy target;
        			select mirror_target01;
        			modPanel.addModToSelection (mirror ()) ui:on;
        			select mirror_target;
        			Build=WM3_MC_BuildFromNode mirror_target.morpher 1 mirror_target01;
        		    holdMaxFile()
				    WM3_MC_SetValue mirror_target.morpher 1 100.0;
        		    maxOps.CollapseNodeTo mirror_target  1 off
        		    maxOps.CollapseNodeTo skin_target  1 off
        		    arr=#(mirror_target,mirror_target01)
        		   if(arr.count==2)do
        		   (
        			   delete arr
        		    )
        		   target = undefined
        		
        		   mirror_target=undefined
        		   skin_target=undefined
        		   mirror_target01=undefined	
        				
        			)
        				)
        	on btn5 pressed do
        	(
        		WM3_MC_SetValue mirror_target.morpher 1 100.0;
        		maxOps.CollapseNodeTo mirror_target  1 off
        		maxOps.CollapseNodeTo skin_target  1 off
        		arr=#(mirror_target,mirror_target01)
        		if(arr.count==2)do
        		(
        			   delete arr
        		)
        		target = undefined
        		
        		mirror_target=undefined
        		skin_target=undefined
        		mirror_target01=undefined
        	 
        	)
        	on btn7 pressed  do
        (
		if ($!=undefined) do
			(
		    --p_poly=convertto $ editable_poly
			p_poly=$	
	        get_VertSelection=polyop.getVertSelection p_poly
			get_array=get_VertSelection as array
			
			vert_array=#()
			for i=1 to get_array.count do
			(
			get_vert=polyop.getvert p_poly get_array[i]
				print get_array[i]	
			vert_array[i]=[get_vert[1]-$.pos[1],get_vert[2]-$.pos[2],get_vert[3]-$.pos[3]]
			
			)
			
		
			)
		
	
        	)
        	on btn8 pressed  do
        (  
		print get_VertSelection 
		print $.pos[1]
	     polyop.setVertSelection p_poly get_VertSelection
	    for j=1 to get_array.count do 
	    (
			
		polyop.setVert $ get_array[j] [vert_array[j][1]+$.pos[1],vert_array[j][2]+$.pos[2],vert_array[j][3]+$.pos[3]]
		print 	vert_array[j]
	    	
		)
        	)
        )
		
        CreateDialog rlpick11
)

-- 参数计数错误: setVert 需要 3 个，得到 2 个 <<
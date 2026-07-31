----------------------------------------------------------------------------------------
-- Script Name:		JJTools9_JimFunctions.ms
-- Compatible:		Max 5, 6, 7, 8 and 9
-- Version:			v1.3
-- Started:      	18 June 2001
-- Last Modified: 	19 August 2007
-- Code by:			Jim Jagger jimjagger@gmail.com
-- 					www.JimJagger.com
----------------------------------------------------------------------------------------
-- v1.0 -- 2004.05.18 -- first release
-- v1.1 -- 2004.05.21 -- Added function to return all biped bones
-- v1.2 -- 2004.11.10 -- Added support for Max 8
-- v1.2 -- 2007.08.19 -- Added support for Max 9
----------------------------------------------------------------------------------------

-- function to return all biped roots in the current scene
fn getAllBips =
(
	allBips = #()
	for obj in geometry do
	(
		if classof obj.controller == Vertical_Horizontal_Turn then 
		(
			append allBips obj
		)
	)
	return allBips
)

-- function to return all biped bones in the current scene
fn getAllBipBones =
(
	allBips = #()
	for obj in geometry do
	(
		if classof obj == Biped_Object then 
		(
			append allBips obj
		)
	)
	return allBips
)

-- function to return the currently selected biped's root node
fn getBipRootNode obj1 =
(
	if classof obj1 == Biped_Object then
	(
		obj_root = obj1.controller.rootnode
		return obj_root
	)
	else
	(
		return obj1
	)
)
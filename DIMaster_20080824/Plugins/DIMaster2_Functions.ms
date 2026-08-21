(
--------------------------------------------------------------------------
--DIMaster v2.0 
--Functions Structure
--Last Edited: 2008/02/05
--Code by Borislav "Bobo" Petrov
--http://www.scriptspot.com/bobo 
--------------------------------------------------------------------------

global DIMasterFunctions
struct DIMasterFunctions
(
	fn DeleteCallback theNode =
	(
		--with undo "Delete DIMaster Object" on
		(
			--callbacks.removeScripts #nodePreDelete id:#DIMaster 
			if isValidNode theNode do
			(
				if matchPattern ((classof theNode) as string) pattern:"DIM*" then
				(
					try(delete theNode.textNode)catch()
					try(delete theNode.node01)catch()
					try(delete theNode.node02)catch()
					try(delete theNode.node03)catch()
					try(delete theNode)catch()
				)	
				else
				(
					if (getUserProp theNode "DIMaster") == true do				
					(
						for o in refs.dependents theNode where isValidNode o and matchPattern ((classof o) as string) pattern:"DIM*"  do 
						(
							if  o != undefined do 
							(
								try(delete o.textNode)catch()
								try(delete o.node01)catch()
								try(delete o.node02)catch()
								try(delete o.node03)catch()
								try(delete o)catch()
							)	
						)	
					)	
				)	
			)	
			--callbacks.addScript #nodePreDelete "DIMasterFunctions.DeleteCallback (callbacks.notificationParam() )" id:#DIMaster 
		)	
	),
	fn loadSettingsFromPreset theObj theFile = 
	(
		theKeys = getIniSetting theFile "Settings"
		theProps = getPropNames theObj
		for k in theKeys where findItem theProps (k as name) > 0 do
		(	
			if classof (getProperty theObj k) == String then
				try(setProperty theObj k ((getIniSetting theFile "Settings" k)))catch(format "Failed To Set %\n" k )
			else
				try(setProperty theObj k (execute (getIniSetting theFile "Settings" k)))catch(format "Failed To Set %\n" k )
		)
	),
	fn loadSettingsFromPreferences theObj =
	(
		theIniPath = (getDir #plugcfg + "\\DIMaster" )
		thePref = getIniSetting (theIniPath + "\\DIMasterSettings.ini") "Preferences"  "Current" 
		thePrefFile = (theIniPath + "\\" + thePref + ".DIMpref") 
		theClass = (classof theObj) as string
		if doesFileExist thePrefFile then
		(
			theFile = (theIniPath + "\\" + (getIniSetting thePrefFile theClass  "PreferenceFile" ) + "." + theClass )
			if doesFileExist theFile do
			(
				DIMasterFunctions.loadSettingsFromPreset theObj theFile
			)
		)
	)
)

--callbacks.removeScripts id:#DIMaster 
--DISABLED BECAUSE OF CRASHES IN UNDO SYSTEM
--callbacks.addScript #nodePreDelete "DIMasterFunctions.DeleteCallback (callbacks.notificationParam() )" id:#DIMaster 

)
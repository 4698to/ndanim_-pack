/*
-- coding: utf-8 
-- @Date    : 2025-12-17 18:17:15
-- @Author  : 4698to (738746223@qq.com)
-- @Link    : sundaybox.cc
-- @Version : 
*/

/* 
	Gemini 3 Pro - Relinker Suite
	Date: 2025-12-17
	
	Part 1: The Struct (Logic Core / API)
	Part 2: The Rollout (UI with ListView)
*/

--------------------------------------------------------------------------------
-- PART 1: THE STRUCT (API)
--------------------------------------------------------------------------------
struct GeminiRelinker
(
	-- Settings
	ParentDepth = 1,
	ChildDepth  = 5,
	
	-- .NET Helpers
	_sysDir  = dotNetClass "System.IO.Directory",
	_dirInfo = dotNetClass "System.IO.DirectoryInfo",
	
	rootDirObj ,
	-- Helper: Recursive Scan
	fn _recursiveScan pathStr currentDepth maxDepth fileDict =
	(
		try
		(
			local files = this._sysDir.GetFiles pathStr 
			format "recursiveScan :: % -> % \n" pathStr files.count 
			for f in files do
			(
				local fName = filenameFromPath f
				if not (fileDict.ContainsKey fName) do fileDict.Add fName f
			)
			
			if currentDepth < maxDepth do
			(
				local dirs = this._sysDir.GetDirectories pathStr
				for d in dirs do(
					this._recursiveScan d (currentDepth + 1) maxDepth fileDict
				)
			)
		)
		catch()
	),
	
	-- API: Get Missing Assets (Returns Array of Structs or Data)
	-- Returns: #(#(FileName, FullPath), ...)
	fn GetMissingAssets =
	(
		ATSOps.Refresh()
		local files = #()
		--local status = #()
		--local statusCode = #()
		--ATSOps.GetFileSystemStatus files &status &statusCode
		ATSOps.GetFilesByFileSystemStatus #Missing &files
		
		local result = #()
		
		for i = 1 to files.count do
		(
			append result #(filenameFromPath files[i], files[i])
		)
		return result
	),
	
	-- API: Search for specific files
	-- Input: Array of filenames
	-- Returns: DotNet Dictionary {FileName : NewFullPath}
	fn SearchForAssets missingFileNames =
	(
		if maxFilePath == "" do return undefined
		
		-- 1. Determine Root
		this.rootDirObj = dotNetObject this._dirInfo maxFilePath
		for i = 1 to this.ParentDepth do
		(
			if this.rootDirObj.Parent != undefined then (this.rootDirObj = this.rootDirObj.Parent)
			else(exit)
		)
		local searchRoot = this.rootDirObj.FullName
		format "searchRoot -> %\n" searchRoot
		-- 2. Build Index
		local fileDict = dotNetObject "System.Collections.Generic.Dictionary`2[System.String,System.String]"
		this._recursiveScan searchRoot 0 this.ChildDepth fileDict
		
		-- 3. Filter (Only keep what we are looking for to save memory/time?)
		-- Actually, we return the whole dict, it's faster than filtering in MXS
		return fileDict
	),
	
	-- API: Execute Relink
	-- Input: Array of Data #(#(OldPath, NewPath), ...)
	fn ApplyRelink pairList =
	(
		local oldSilent = ATSOps.Silent
		ATSOps.Silent = true
		local count = 0
		
		try
		(
			for pair in pairList do
			(
				ATSOps.ClearSelection()
				--format "% -> %\n" pair[1] pair[2]  
				ATSOps.SelectFiles #(pair[1]) --Old Path
				ATSOps.RetargetSelection pair[2]  CreateOutputFolder:true-- New Path
            	ATSOps.Refresh()
				count += 1
			)
		)
		catch()
		
		ATSOps.Silent = oldSilent
		
		if count > 0 do
		(
			ATSOps.Refresh()
			freeSceneBitmaps()
		)
		return count
	)
)

--------------------------------------------------------------------------------
-- PART 2: THE ROLLOUT (UI)
--------------------------------------------------------------------------------
try(destroydialog rol_GeminiUI)catch()

rollout rol_GeminiUI "天晴贴图追踪 v.1" width:400 height:440
(
	-- Instance of the Struct
	local this = GeminiRelinker()
	
	-- UI Controls
	group "搜索设置"
	(
		label lal_stats_path "" align:#left
		spinner spn_p "父级目录层数:" range:[0,4,1] type:#integer fieldwidth:40 across:2 align:#left
		spinner spn_c "子级目录深度:" range:[0,20,5] type:#integer fieldwidth:40 align:#right
	)
	
	dotNetControl lv_assets "System.Windows.Forms.ListView" height:300
	
	label lbl_stats "Status: Idle" align:#left
	
	button btn_scan "1. 扫描丢失贴图" width:120 height:40 across:3
	button btn_fix  "2. 搜索贴图" width:120 height:40 enabled:false
	button btn_open_ATSops "打开资产追踪"  width:120 height:40  
	-- Data Storage for UI
	local _missingData = #() -- Stores #(#(name, path), ...)
	local foundDict = undefined
	local pairsToRelink = undefined
	-- Init ListView
	fn initLV =
	(
		lv_assets.View = (dotNetClass "System.Windows.Forms.View").Details
		lv_assets.FullRowSelect = true
		lv_assets.GridLines = true
		lv_assets.Columns.add "贴图" 180
		lv_assets.Columns.add "状态" 80
		lv_assets.Columns.add "路径" 120
	)
	
	on rol_GeminiUI open do initLV()
	
	-- UPDATE SETTINGS
	on spn_p changed val do this.ParentDepth = val
	on spn_c changed val do this.ChildDepth = val
	
	on btn_open_ATSops pressed do 
	(
		ATSOps.Visible = true
	)
	-- SCAN BUTTON
	on btn_scan pressed do
	(
		lv_assets.Items.Clear()
		_missingData = this.GetMissingAssets()
		
		if _missingData.count == 0 then
		(
			lbl_stats.text = "状态: 无丢失贴图."
			btn_fix.enabled = false
		)
		else
		(
			-- Populate ListView
			for data in _missingData do
			(
				local item = lv_assets.Items.add data[1] -- Filename
				item.SubItems.add "丢失"
				item.SubItems.add data[2] -- FullPath
				item.ForeColor = (dotNetClass "System.Drawing.Color").Red
			)
			lbl_stats.text = "状态: 发现 " + (_missingData.count as string) + " 个丢失贴图."
			btn_fix.enabled = true
		)
	)
	
	-- FIX BUTTON
	on btn_fix pressed do
	(
		if maxFilePath == "" do (messageBox "Save scene first!"; return false)
		
		lbl_stats.text = "状态: 搜索中 (Please wait)..."
		(dotNetClass "System.Windows.Forms.Cursor").Current = (dotNetClass "System.Windows.Forms.Cursors").WaitCursor
		
		-- 1. Search
		-- We pass a dummy array because the struct searches everything in range anyway
		foundDict = this.SearchForAssets #() 
		
		if foundDict == undefined do return false
		
		pairsToRelink = #()
		local successCount = 0
		
		-- 2. Match
		for i = 1 to _missingData.count do
		(
			local fName = _missingData[i][1]
			local oldPath = _missingData[i][2]
			local item = lv_assets.Items.item[i-1]
			
			if (foundDict.ContainsKey fName) then
			(
				local newPath = foundDict.Item[fName]
				append pairsToRelink #(oldPath, newPath)
				
				-- Update UI to "Ready" state (Visual feedback before actual relink)
				item.SubItems.item[1].text = "FOUND"
				item.ForeColor = (dotNetClass "System.Drawing.Color").Orange
			)
		)
		-- 3. Apply
		if pairsToRelink.count > 0 then
		(
			lbl_stats.text = "状态: 修复中..."
			this.ApplyRelink pairsToRelink
			if this.rootDirObj != undefined do (
				lal_stats_path.text = this.rootDirObj.FullName
			)
			-- Update UI to "Done" state
			for i = 1 to _missingData.count do
			(
				local item = lv_assets.Items.item[i-1]
				if item.SubItems.item[1].text == "FOUND" do
				(
					item.SubItems.item[1].text = "FIXED"
					item.ForeColor = (dotNetClass "System.Drawing.Color").Green
				)
			)
			lbl_stats.text = "状态: 修复 " + (pairsToRelink.count as string) + " 资产."
		)
		else
		(
			lbl_stats.text = "状态: 在父级路径中没有找到资产."
		)
		
		(dotNetClass "System.Windows.Forms.Cursor").Current = (dotNetClass "System.Windows.Forms.Cursors").Default
	)
)

createDialog rol_GeminiUI
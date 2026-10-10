/*
--------------------------------------------------------------------
Propose skel nodes for skinning by surface proximity.
Load via fileIn.

Listener:
	addBoneToSkin.excludePrefixes = #("v_")
	addBoneToSkin.debugSpine = true  -- Listener: [addBoneToSkin][spine] ...
	res = addBoneToSkin.proposeSkinBones #(meshNode) padRatio:0.03
	res.bones  -- node array to add into Skin
--------------------------------------------------------------------
*/
global addBoneToSkin

struct proposeBoneEntry
(
	name = "",
	node = undefined,
	reason = #far, -- #near_mesh | #ancestor | #far | #name_filter
	distance = undefined
)

struct proposeSkinBonesResult
(
	_ok = false,
	error = undefined,
	bones = #(),
	kept = #(),
	dropped = #(),
	mesh_diag = 0.0,
	max_dist = 0.0,
	warning = undefined
)

struct addBoneToSkinStruct
(
	-- Name prefixes to skip (case-insensitive), e.g. helper joints "v_".
	excludePrefixes = #("v_"),
	-- Print signed-distance breakdown for bones whose name contains "spine".
	debugSpine = false,

	fn isSkinBoneNode o =
	(
		o != undefined and ((isKindOf o BoneGeometry) or (isKindOf o Biped_Object))
	),

	fn isSpineDebugName nodeName =
	(
		if nodeName == undefined do return false
		(findString (toLower (nodeName as string)) "spine") != undefined
	),

	fn isExcludedName nodeName prefixes:#("v_") =
	(
		if nodeName == undefined do return false
		local low = toLower (nodeName as string)
		if prefixes == undefined do prefixes = #("v_")
		for pfx in prefixes do
		(
			local p = toLower (pfx as string)
			if p.count > 0 and (findString low p) == 1 do return true
		)
		false
	),

	fn isCandidateNode o prefixes:#("v_") =
	(
		(this.isSkinBoneNode o) and (not (this.isExcludedName o.name prefixes:prefixes))
	),

	fn worldBBox node =
	(
		if node == undefined do return undefined
		local bb = undefined
		try (bb = nodeGetBoundingBox node (matrix3 1)) catch (bb = undefined)
		if bb == undefined do return undefined
		#(bb[1], bb[2])
	),

	fn expandBox bmin bmax pad =
	(
		#([bmin.x - pad, bmin.y - pad, bmin.z - pad], [bmax.x + pad, bmax.y + pad, bmax.z + pad])
	),

	fn pointToAabbDist p bmin bmax =
	(
		local dx = 0.0
		local dy = 0.0
		local dz = 0.0
		if p.x < bmin.x then dx = bmin.x - p.x else if p.x > bmax.x then dx = p.x - bmax.x
		if p.y < bmin.y then dy = bmin.y - p.y else if p.y > bmax.y then dy = p.y - bmax.y
		if p.z < bmin.z then dz = bmin.z - p.z else if p.z > bmax.z then dz = p.z - bmax.z
		sqrt (dx * dx + dy * dy + dz * dz)
	),

	fn aabbOverlap aMin aMax bMin bMax =
	(
		not (aMax.x < bMin.x or aMin.x > bMax.x or aMax.y < bMin.y or aMin.y > bMax.y or aMax.z < bMin.z or aMin.z > bMax.z)
	),

	fn aabbCenter bmin bmax =
	(
		(bmin + bmax) * 0.5
	),

	fn pointInAabb p bmin bmax =
	(
		p.x >= bmin.x and p.x <= bmax.x and \
		p.y >= bmin.y and p.y <= bmax.y and \
		p.z >= bmin.z and p.z <= bmax.z
	),

	-- Shrink mesh AABB so "inside" claims must sit in the core volume
	-- (rejects floating bones that only sit inside the oversized dress world box).
	fn meshCoreAabb meshMin meshMax pad =
	(
		local p = pad as float
		if p < 0 do p = 0
		local cmin = [meshMin.x + p, meshMin.y + p, meshMin.z + p]
		local cmax = [meshMax.x - p, meshMax.y - p, meshMax.z - p]
		if cmin.x > cmax.x or cmin.y > cmax.y or cmin.z > cmax.z do
			return #(meshMin, meshMax)
		#(cmin, cmax)
	),

	-- Start = bone pivot; end = first candidate child's pivot (or bone length for leaves).
	fn axisEndpoints _skelNode prefixes:#("v_") =
	(
		local p0 = _skelNode.transform.pos
		local skelKids = for c in _skelNode.children where (this.isCandidateNode c prefixes:prefixes) collect c
		if skelKids.count > 0 do
			return #(p0, skelKids[1].transform.pos)
		if isKindOf _skelNode BoneGeometry do
		(
			local len = 0.0
			try (len = _skelNode.length as float) catch (len = 0.0)
			if len > 0.0001 do
			(
				local xAxis = [1, 0, 0]
				try (xAxis = normalize _skelNode.transform.row1) catch ()
				return #(p0, p0 + xAxis * len)
			)
		)
		#(p0, p0)
	),

	fn buildMeshGrids meshNodes =
	(
		local grids = #()
		for m in meshNodes do
		(
			-- try/catch removed temporarily so Initialize/addNode/buildGrid errors surface
			local g = RayMeshGridIntersect()
			-- Initialize N: voxels along each axis (Autodesk docs).
			g.Initialize 72
			g.addNode m
			g.buildGrid()
			append grids g
		)
		grids
	),

	fn freeMeshGrids grids =
	(
		if grids == undefined do return()
		for g in grids do
		(
			try (g.free()) catch ()
		)
	),

	-- Signed distance to one grid: <0 inside (behind outward normal), >0 outside.
	fn signedDistToGrid g pos searchDist =
	(
		local detail = this.signedDistDetail g pos searchDist
		detail[1]
	),

	-- Returns #(sd, fd, dotOrUndefined, branch) branch:#inside|#outside|#no_normal|#fail
	-- RayMeshGridIntersect: closestFace -> getClosestHit -> getHitPoint/getHitNormal/getHitDist
	-- try/catch temporarily removed so API errors surface in Listener.
	fn signedDistDetail g pos searchDist =
	(
		if g == undefined do return #(undefined, undefined, undefined, #fail)

		local nHit = g.closestFace pos
		if nHit == undefined or nHit < 1 do return #(undefined, undefined, undefined, #fail)

		local idx = g.getClosestHit()
		if idx == undefined or idx < 1 do idx = 1

		local fd = g.getHitDist idx
		if fd == undefined or fd < 0 do fd = g.getPerpDist idx
		if fd == undefined or fd < 0 do return #(undefined, undefined, undefined, #fail)

		local hp = g.getHitPoint idx
		local hn = g.getHitNormal idx
		if hp == undefined or hn == undefined do return #(fd, fd, undefined, #no_normal)

		local nl = length hn
		if nl < 0.000001 do return #(fd, fd, undefined, #no_normal)
		local dv = dot (pos - hp) (hn / nl)
		if dv < 0.0 then
			#((-fd), fd, dv, #inside)
		else
			#(fd, fd, dv, #outside)
	),

	-- Across grids: prefer any inside (most negative), else nearest outside.
	fn signedDistToMeshes grids pos searchDist =
	(
		local detail = this.signedDistDetailMeshes grids pos searchDist
		detail[1]
	),

	-- Same selection as signedDistToMeshes; returns #(sd, fd, dot, branch)
	fn signedDistDetailMeshes grids pos searchDist =
	(
		if grids == undefined or grids.count == 0 do return #(undefined, undefined, undefined, #fail)
		local bestInside = undefined
		local bestOutside = undefined
		local bestInDetail = undefined
		local bestOutDetail = undefined
		for g in grids do
		(
			local det = this.signedDistDetail g pos searchDist
			local s = det[1]
			if s != undefined do
			(
				if s < 0.0 then
				(
					if bestInside == undefined or s < bestInside do
					(
						bestInside = s
						bestInDetail = det
					)
				)
				else
				(
					if bestOutside == undefined or s < bestOutside do
					(
						bestOutside = s
						bestOutDetail = det
					)
				)
			)
		)
		if bestInDetail != undefined then bestInDetail
		else if bestOutDetail != undefined then bestOutDetail
		else #(undefined, undefined, undefined, #fail)
	),

	-- Keep when: confirmed inside (sd<0 and sample in mesh core AABB),
	-- or outside surface distance <= outsideLimit (stricter than maxDist).
	-- Samples: pivot, end (first child pivot), bone world-AABB center only.
	fn boneContactsMeshGrid grids boneNode maxDist searchDist meshMin meshMax =
	(
		if grids == undefined or grids.count == 0 do return #(false, -1.0)
		local bb = this.worldBBox boneNode
		if bb == undefined do return #(false, -1.0)
		local bnMin = bb[1]
		local bnMax = bb[2]

		local doSpineDbg = (this.debugSpine == true) and (this.isSpineDebugName boneNode.name)

		local expBone = this.expandBox bnMin bnMax maxDist
		if not (this.aabbOverlap expBone[1] expBone[2] meshMin meshMax) do
		(
			local cd = this.pointToAabbDist (this.aabbCenter bnMin bnMax) meshMin meshMax
			if doSpineDbg do
				format "[addBoneToSkin][spine] % AABB_cull dist:% maxDist:% keep:false\n" boneNode.name cd maxDist
			return #(false, cd)
		)

		local meshDiag = distance meshMin meshMax
		if meshDiag < 0.0001 do meshDiag = 0.0001
		-- Core volume: demote false "inside" on oversized dress AABB fringe / outside box.
		local corePad = amax #(maxDist, meshDiag * 0.05)
		local core = this.meshCoreAabb meshMin meshMax corePad
		local coreMin = core[1]
		local coreMax = core[2]
		-- Pure exterior bones must be closer than half maxDist (rejects cape / floaters near surface).
		local outsideLimit = maxDist * 0.5

		local ends = this.axisEndpoints boneNode prefixes:(if this.excludePrefixes != undefined then this.excludePrefixes else #("v_"))
		local boxC = this.aabbCenter bnMin bnMax
		local pts = #(ends[1], ends[2], boxC)
		local ptLabels = #("pivot", "end", "boxCenter")

		local insideCount = 0
		local bestOutside = undefined
		local bestSigned = undefined
		for i = 1 to pts.count do
		(
			local p = pts[i]
			local det = this.signedDistDetailMeshes grids p searchDist
			local s = det[1]
			local fd = det[2]
			local dv = det[3]
			local br = det[4]
			local demoted = false
			local eff = s
			-- Only trust negative sd when sample sits in mesh core AABB.
			if eff != undefined and eff < 0 and (not (this.pointInAabb p coreMin coreMax)) do
			(
				eff = abs eff
				demoted = true
				br = #outside_aabb
			)
			if doSpineDbg do
			(
				local dotStr = if dv == undefined then "n/a" else (dv as string)
				local sdStr = if s == undefined then "n/a" else (s as string)
				local fdStr = if fd == undefined then "n/a" else (fd as string)
				local effStr = if eff == undefined then "n/a" else (eff as string)
				format "[addBoneToSkin][spine] % sample:% fd:% dot:% sd:% eff:% demoted:% branch:%\n" \
					boneNode.name ptLabels[i] fdStr dotStr sdStr effStr demoted br
			)
			if eff != undefined do
			(
				if bestSigned == undefined then
					bestSigned = eff
				else if eff < bestSigned do
					bestSigned = eff

				if eff < 0 then
					insideCount += 1
				else
				(
					if bestOutside == undefined then
						bestOutside = eff
					else if eff < bestOutside do
						bestOutside = eff
				)
			)
		)
		if bestSigned == undefined do
		(
			if doSpineDbg do
				format "[addBoneToSkin][spine] % bestSigned:n/a maxDist:% keep:false\n" boneNode.name maxDist
			return #(false, -1.0)
		)
		local keep = (insideCount >= 1) or \
			(bestOutside != undefined and bestOutside <= outsideLimit)
		if doSpineDbg do
			format "[addBoneToSkin][spine] % bestSigned:% inside:% bestOut:% outLimit:% maxDist:% keep:%\n" \
				boneNode.name bestSigned insideCount \
				(if bestOutside == undefined then "n/a" else (bestOutside as string)) \
				outsideLimit maxDist keep
		local reportDist = if insideCount >= 1 then (abs bestSigned) \
			else if bestOutside != undefined then bestOutside \
			else (abs bestSigned)
		if keep then
			#(true, reportDist)
		else
			#(false, reportDist)
	),

	fn resolveNode ref =
	(
		if ref == undefined do return undefined
		if isValidNode ref do return ref
		local hi = ref
		try (hi = ref as integer) catch (return undefined)
		local obj = undefined
		try (obj = maxOps.getNodeByHandle hi) catch (obj = undefined)
		obj
	),

	fn makeEntry node reason distance:undefined =
	(
		proposeBoneEntry name:(if node != undefined then node.name else "") node:node reason:reason distance:distance
	),

	fn makeFailResult errMsg =
	(
		proposeSkinBonesResult _ok:false error:errMsg
	),

	-- Propose skel nodes for skinning by mesh surface proximity (no Skin weights).
	-- meshRefs: mesh nodes and/or AnimHandles.
	-- boneRefs: optional; omit → all unhidden Bone/Biped.
	-- includeAncestors: if true, also keep parents that themselves pass proximity (2x maxDist).
	-- Returns proposeSkinBonesResult; primary output is .bones (node array).
	fn proposeSkinBones meshRefs boneRefs:undefined padRatio:0.04 absPadding:0.0 sampleCount:5 includeAncestors:false =
	(
		local excludePrefixes = this.excludePrefixes
		if excludePrefixes == undefined do excludePrefixes = #("v_")

		-- Allow a single node as well as an array.
		if meshRefs == undefined then meshRefs = #()
		else if (isValidNode meshRefs) then meshRefs = #(meshRefs)

		local meshNodes = #()
		for r in meshRefs do
		(
			local obj = this.resolveNode r
			if obj != undefined do append meshNodes obj
		)
		if meshNodes.count == 0 do
			return (this.makeFailResult "没有有效的模型节点")

		local bmin = undefined
		local bmax = undefined
		for m in meshNodes do
		(
			local bb = this.worldBBox m
			if bb != undefined do
			(
				if bmin == undefined then
				(
					bmin = bb[1]
					bmax = bb[2]
				)
				else
				(
					bmin = [amin #(bmin.x, bb[1].x), amin #(bmin.y, bb[1].y), amin #(bmin.z, bb[1].z)]
					bmax = [amax #(bmax.x, bb[2].x), amax #(bmax.y, bb[2].y), amax #(bmax.z, bb[2].z)]
				)
			)
		)
		if bmin == undefined do
			return (this.makeFailResult "无法读取模型包围盒")

		local diag = distance bmin bmax
		if diag < 0.0001 do diag = 0.0001
		local pr = padRatio as float
		if pr < 0 do pr = 0
		local ap = absPadding as float
		if ap < 0 do ap = 0
		local maxDist = amax #(ap, pr * diag)
		local coarsePad = amax #(maxDist * 2.0, diag * 0.05)

		local boneNodes = #()
		local droppedEntries = #()
		local droppedNodes = #()
		if boneRefs != undefined and boneRefs.count > 0 then
		(
			for r in boneRefs do
			(
				local obj = this.resolveNode r
				if this.isSkinBoneNode obj do
				(
					if this.isExcludedName obj.name prefixes:excludePrefixes then
					(
						append droppedNodes obj
						append droppedEntries (this.makeEntry obj #name_filter)
					)
					else
					(
						append boneNodes obj
					)
				)
			)
		)
		else
		(
			for o in objects where (not o.isHidden) do
			(
				if this.isSkinBoneNode o do
				(
					if this.isExcludedName o.name prefixes:excludePrefixes then
					(
						append droppedNodes o
						append droppedEntries (this.makeEntry o #name_filter)
					)
					else
					(
						append boneNodes o
					)
				)
			)
		)

		local grids = this.buildMeshGrids meshNodes
		if grids.count == 0 do
			return (this.makeFailResult "无法构建模型体素网格(RayMeshGridIntersect)")

		-- Large search for ClosestPoint; final accept still uses maxDist.
		local searchDist = coarsePad + maxDist + diag * 0.5
		if searchDist < 0.001 do searchDist = 0.001

		local nearBones = #()
		local keptSpatialEntries = #()

		for skelNode in boneNodes do
		(
			local nearInfo = this.boneContactsMeshGrid grids skelNode maxDist searchDist bmin bmax
			local isNear = nearInfo[1]
			local bestSurf = nearInfo[2]
			if isNear then
			(
				append nearBones skelNode
				append keptSpatialEntries (this.makeEntry skelNode #near_mesh distance:bestSurf)
			)
			else
			(
				append droppedNodes skelNode
				append droppedEntries (this.makeEntry skelNode #far distance:bestSurf)
			)
		)

		this.freeMeshGrids grids

		local keepBones = for b in nearBones collect b
		local ancestorEntries = #()
		local ancestorBones = #()

		if includeAncestors do
		(
			local ancMaxDist = maxDist * 2.0
			local ancSearch = ancMaxDist + diag * 0.5
			local grids2 = this.buildMeshGrids meshNodes
			for skelNode in nearBones do
			(
				local p = skelNode.parent
				local guard = 0
				while p != undefined and guard < 512 do
				(
					guard += 1
					if not (this.isCandidateNode p prefixes:excludePrefixes) then
					(
						if (this.isSkinBoneNode p) and (this.isExcludedName p.name prefixes:excludePrefixes) then
							p = p.parent
						else
							p = undefined
					)
					else
					(
						if (findItem keepBones p) == 0 do
						(
							local nearP = this.boneContactsMeshGrid grids2 p ancMaxDist ancSearch bmin bmax
							if nearP[1] then
							(
								append keepBones p
								append ancestorBones p
								append ancestorEntries (this.makeEntry p #ancestor distance:nearP[2])
							)
						)
						p = p.parent
					)
				)
			)
			this.freeMeshGrids grids2
		)

		local keptEntries = #()
		for e in keptSpatialEntries do append keptEntries e
		for e in ancestorEntries do append keptEntries e

		local bonesOut = for b in nearBones collect b
		for b in ancestorBones do
		(
			if (findItem bonesOut b) == 0 do append bonesOut b
		)

		local warningVal = undefined
		if keptEntries.count == 0 do
		(
			if boneNodes.count == 0 then
				warningVal = "场景中没有可探测的骨骼(Bone/Biped)"
			else
				warningVal = ("未探测到与模型邻近的骨骼\n候选骨骼: " + (boneNodes.count as string) + "\n阈值距离: " + ((maxDist as float) as string) + "\n可尝试增大 padRatio / absPadding")
		)

		local dropFiltered = #()
		for i = 1 to droppedEntries.count do
		(
			if (findItem keepBones droppedNodes[i]) == 0 do
				append dropFiltered droppedEntries[i]
		)

		proposeSkinBonesResult \
			_ok:true \
			bones:bonesOut \
			kept:keptEntries \
			dropped:dropFiltered \
			mesh_diag:diag \
			max_dist:maxDist \
			warning:warningVal
	)
)
addBoneToSkin = addBoneToSkinStruct()

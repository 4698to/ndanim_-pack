-- Spring Max
-- this is a tool for create bone chain follow throught animation
-- features:
-- wave, twist animations
-- strach and squash effect
-- collision with capsule body and plane
-- can apply wind or explosion force

-- Yanbin Bai
-- 2021.01
-- animbai.com

-- Version History:

-- 1.8
-- add pin end
-- draw view point when calculation

-- 1.71
-- improve loop result with inertia

-- 1.7
-- add inertia effect
-- bug fix

-- 1.6
-- able to set keyframe on basic values

-- 1.5
-- add Japanese support (Thanks Ken Taguma)
-- adjust language setting function

-- 1.4
-- fix bug: loop result poping when wind or explosion applied
-- fix bug: script error when fail to visit update site

-- 1.3
-- add roll back function
-- fix bug: "Bone On" cause bone display issue
-- fix bug: keyframe been set out of calculation range
-- fix bug: error message when first time use connection bone function

-- 1.2
-- add pose match
-- add bone relation
-- keep bone anim out of current animation rage
-- fix bug that pose slightly changed when redo same calculation

-- 1.1
-- Add bone size collision

-- 1.0
-- First public build

sm_ver = 1.8

aimRefLoc_subFix = "_SpringMaxRefLoc"
aimChildRefLoc_subFix = "_SpringMaxChildRefLoc"
aimCurLocBase_subFix = "_SpringMaxCurLocBase"
aimCurLoc_subFix = "_SpringMaxCurLoc"
aimPreLoc_subFix = "_SpringMaxPreLoc"
aimPrePreLoc_subFix = "_SpringMaxPrePreLoc"
aimUpLoc_subFix = "_SpringMaxUpLoc"
aimRefUpLoc_subFix = "_SpringMaxRefUpLoc"
aimPreUpLoc_subFix = "_SpringMaxPreUpLoc"
aimFinAPreLoc_subFix = "_SpringMaxFinAPreLoc"
aimFinARefLoc_subFix = "_SpringMaxFinARefLoc"
aimFinACurLoc_subFix = "_SpringMaxFinACurLoc"
aimFinBPreLoc_subFix = "_SpringMaxFinBPreLoc"
aimFinBRefLoc_subFix = "_SpringMaxFinBRefLoc"
aimFinBCurLoc_subFix = "_SpringMaxFinBCurLoc"
animSaveLoc_subFix = "_SpringMaxAnimSaveLoc"
poseSaveLoc_subFix = "_SpringMaxPoseSaveLoc"
poseSaveChildLoc_subFix = "_SpringMaxPoseSaveChildLoc"
colBody_subFix = "_SpringMaxColBody"
colPlane_subFix = "_SpringMaxColPlan"
windCone_subFix = "_SpringMaxWind"
expCtrl_subFix = "_SpringMaxExplosion"
connectSpline_subFix = "SpringMaxSpline"
smProxy_subFix = "_SpringMaxProxy"
endPinTargetName = "SpringMax_PinEnd"


isDebug = False

uistrLst = #()
spamWord = #("","","","","")
spamWordCHN = #("","","","","")

fn getObjWithName objStr exact:False =(
    objLst = #()
    if exact then(
        obj = execute ("$'"+objStr+"'")
        append objLst obj
    )
    else objLst = execute ("$*'"+objStr+"*'")
    if objLst.count>0 then(
        objLst
    )
    else undefined
)

fn sm_getLoc obj locatorSubFix =(
    (getnodebyname (obj.name+locatorSubFix) exact:true)
)

fn sm_addPosCons boneObj fNeibour bNeibour =(
    smBonePreUpLoc = sm_getLoc boneObj aimPreUpLoc_subFix
    fRefLoc = undefined
    if fNeibour != undefined then(
        fRefLoc = sm_getLoc fNeibour aimRefLoc_subFix
--         fPreLoc = sm_getLoc fNeibour aimPreLoc_subFix
    )
    bRefLoc = undefined
    if bNeibour != undefined then(
        bRefLoc = sm_getLoc bNeibour aimRefLoc_subFix
--         bPreLoc = sm_getLoc bNeibour aimPreLoc_subFix
    )

    posCtrl = Position_Constraint()
    nloc = undefined
    if fRefLoc != undefined then(
        posCtrl.appendTarget fRefLoc 0.5
--         posCtrl.appendTarget fPreLoc 0.5
    )
    if bRefLoc != undefined then(
        posCtrl.appendTarget bRefLoc 0.5
--         posCtrl.appendTarget bPreLoc 0.5
    )
    smBonePreUpLoc.pos.controller = posCtrl

    posCtrl.RELATIVE = on
)

fn sm_addAimCons aimbone refLoc preLoc upLoc weight tension isTension fNeibour bNeibour =(

    aimCtrl = LookAt_Constraint()
    aimCtrl.appendTarget refLoc weight
    aimCtrl.appendTarget preLoc (1-weight)


    -- add tension aim
    tensionLoc = sm_getLoc aimbone aimChildRefLoc_subFix
    tensionWeight = 0.0

    if aimbone.children.count>0 then(
        smBoneChild = aimbone.children[1]
        if smBoneChild.children.count>0 then(
            aimCtrl.appendTarget tensionLoc tensionWeight
        )
        else(
            aimCtrl.appendTarget upLoc 0.0
        )
    )

    -- add neibour
    nloc = undefined
    if fNeibour != undefined or bNeibour != undefined then(

        smBonePreUpLoc = sm_getLoc aimbone aimPreUpLoc_subFix

        aimCtrl.appendTarget smBonePreUpLoc (tension/4)
    )

    aimCtrl.viewline_length_abs = False
    aimCtrl.lookat_vector_length = 0

    aimCtrl.upnode_world = False
    aimCtrl.pickUpNode = upLoc
--     aimbone.rotation.controller = aimCtrl
    -- add aim constraint into rotation list
    aimbone.rotation.controller = Rotation_list()
    aimbone.rotation.controller.available.controller = aimCtrl
    aimbone.rotation.controller.setactive 2 --otherwise, EulerXYZ was active
    
--     aimCtrl.RELATIVE = on
)

fn sm_addOriCons curUpLoc preUpLoc refUpLoc weight=(
    oriCtrl = Orientation_Constraint()
    oriCtrl.appendTarget refUpLoc weight
    oriCtrl.appendTarget preUpLoc (1-weight)

    curUpLoc.rotation.controller = oriCtrl
)

fn collapseTransform obj startFrame endFrame subDiv isTCB= (
    -- same function as collapse transform in Trajections panel
    local TCtrller = Position_XYZ()
    if not isTCB then(
        local RCtrller = Euler_XYZ()
    )
    else(
        local RCtrller = TCB_Rotation() -- TCB can get smoother result for long chain
    )

    tPoint = point()

    with animate on(
        for i in startFrame to endFrame by 1/subDiv do(
            at time i(
                tPoint.transform = obj.transform
            )
        )
        obj.pos.controller = TCtrller
        obj.rotation.controller = RCtrller

        for i in startFrame to endFrame by 1/subDiv do(
            at time i(
                obj.transform = tPoint.transform
            )
        )
    )
    delete tPoint
)

fn sm_createLocator obj subfix boneLocLst isChildTransform isParent isDraw =(
    if obj.children.count>0 then(
        local objChild = obj.children[1]
        local locator = point name:(obj.name+subfix) cross:isDraw box:isDraw
        if isChildTransform then(
            locator.transform = objChild.transform
        )
        else(
            locator.transform = obj.transform
        )
        if isParent then(
            locator.parent = obj.parent
        )
        append boneLocLst locator
        locator
    )
    else(
        undefined
    )
)

fn sm_creatPinPoint=(

    try(
        delete (getnodebyname endPinTargetName exact:true)
    )catch()

    if $Selection.count > 0 then(
        if (classOf $Selection[$Selection.count]) == boneObj then(
            endBone = $Selection[$Selection.count]
            pinPoint = point name:endPinTargetName cross:True box:True size:(endBone.width*3)
            pinPoint.pos = endBone.pos
        )
    )
)

fn sm_removeExistProxy subfix=(
    -- remove exist proxy
    if (getObjWithName subfix) != undefined then(
        delete (getObjWithName subfix)[1]
    )
)

fn sm_createSMProxy sm_SpringMax =(
    -- create a proxy object and connect ui value to it, to make keyframe working
    sm_removeExistProxy smProxy_subFix

    SMProxy = point name:("the"+smProxy_subFix) cross:False box:False
    SMProxy.xray = on
    SMProxy.renderable = off
    -- add new modifier
    m = EmptyModifier name:"Spring Max Setting"
    ca = attributes springAttr
    (
        parameters params rollout:params
        (
            spring type:#float ui:SM_spring
            twist type:#float ui:SM_twist
            flex type:#float ui:SM_flex
            tension type:#float ui:SM_tension
            mass type:#float ui:SM_mass
        )
        rollout params "Setting"
        (
            spinner SM_spring "Spring:" type:#float
            spinner SM_twist "Twist:" type:#float
            spinner SM_flex "Flex:" type:#float
            spinner SM_tension "Tension:" type:#float
            spinner SM_mass "Mass:" type:#float
        )
    )
    custattributes.add m ca
    addmodifier SMProxy m

    SMProxy.modifiers[#Spring_Max_Setting].springAttr.spring = sm_SpringMax.springBend_spinner.value
    SMProxy.modifiers[#Spring_Max_Setting].springAttr.twist = sm_SpringMax.springTwist_spinner.value
    SMProxy.modifiers[#Spring_Max_Setting].springAttr.flex = sm_SpringMax.springFlex_spinner.value
    SMProxy.modifiers[#Spring_Max_Setting].springAttr.tension = 0.5
    SMProxy.modifiers[#Spring_Max_Setting].springAttr.mass = sm_SpringMax.springMass_spinner.value

    SMProxy.modifiers[#Spring_Max_Setting].springAttr.spring.controller = sm_SpringMax.springBend_spinner.controller
    SMProxy.modifiers[#Spring_Max_Setting].springAttr.twist.controller = sm_SpringMax.springTwist_spinner.controller
    SMProxy.modifiers[#Spring_Max_Setting].springAttr.flex.controller = sm_SpringMax.springFlex_spinner.controller
    SMProxy.modifiers[#Spring_Max_Setting].springAttr.mass.controller = sm_SpringMax.springMass_spinner.controller
--     SMProxy.modifiers[#Spring_Max_Setting].springAttr.tension.controller = sm_SpringMax.springTension_spinner.controller

    return SMProxy
)

fn sm_createWindCone =(
    sm_removeExistProxy windCone_subFix

    windCone = cone name:("the"+windCone_subFix)
    windCone.xray = on
    windCone.renderable = off
    -- add new modifier
    m = EmptyModifier name:"Spring Max Force"
    ca = attributes forceAttr
    (
        parameters params rollout:params
        (
            maxForce type:#float ui:windMaxForce
            minForce type:#float ui:windMinForce
            frequency type:#float ui:windFrequency
        )
        rollout params "Wind"
        (
            spinner windMaxForce "Max Force:" type:#float
            spinner windMinForce "Min Force:" type:#float
            spinner windFrequency "Frequency:" type:#float
        )
    )
    custattributes.add m ca
    addmodifier windCone m

    windCone.modifiers[#Spring_Max_Force].forceAttr.maxForce = 10.0
    windCone.modifiers[#Spring_Max_Force].forceAttr.minForce = 5.0
    windCone.modifiers[#Spring_Max_Force].forceAttr.frequency = 0.15
)

fn sm_createExpCtrl =(
    sm_removeExistProxy expCtrl_subFix

    ExpCtrl = Hedra name:("the"+expCtrl_subFix)
    ExpCtrl.xray = on
    ExpCtrl.renderable = off
    -- add new modifier
    m = EmptyModifier name:"Spring Max Force"
    ca = attributes forceAttr
    (
        parameters params rollout:params
        (
            maxForce type:#float ui:windMaxForce
            minForce type:#float ui:windMinForce
            frequency type:#float ui:windFrequency
            isReverse type:#boolean ui:windIsReverse
        )
        rollout params "Explosion"
        (
            spinner windMaxForce "Max Force:" type:#float
            spinner windMinForce "Min Force:" type:#float
            spinner windFrequency "Frequency:" type:#float
            checkbox windIsReverse "Reverse" type:#boolean
        )
    )
    custattributes.add m ca
    addmodifier ExpCtrl m

    ExpCtrl.modifiers[#Spring_Max_Force].forceAttr.maxForce = 50.0
    ExpCtrl.modifiers[#Spring_Max_Force].forceAttr.minForce = 30.0
    ExpCtrl.modifiers[#Spring_Max_Force].forceAttr.frequency = 0.5
)

fn offsetPosByDirection sDirection tPos moveDistance =(
    -- get new target pos
    tPos += ((normalize sDirection)*moveDistance)

    tPos
)

fn sigmoid x =(
  (1 / (1 + exp(-x)))
)

fn sm_distance a b =(
    length(b-a)
)

fn lerp_vec a b t =(
    (a*(1-t) + b*t)
)

fn dist_to_plane pt n d =(
    -- pt: point pos
    -- n: plane direction
    -- q: a point pos on plane
    -- d = dot n q
    -- return: distance to plane, - means on back side
    -- this function calculate plane as a infinity size plane
    ((dot n pt) - d/(dot n n))
)

fn dist_to_line a b p =(
    ap = p-a
    ab = b-a
    dap = dot ap ab
    dab = dot ab ab
    result = a + dap/dab * ab
    (sm_distance result p)
)

fn is_same_side_of_plane pt test_pt n d =(
    d1 = 1.0
    if (dist_to_plane pt n d) < 0 then(
        d1 = -1.0
    )
    d2 = 1.0
    if (dist_to_plane test_pt n d) < 0 then(
        d2 = -1.0
    )
    ((d1*d2) == 1.0)
)

fn proj_pt_to_plane pt  n  d=(
    t = (dot n pt) - d
    (pt - n*t)
)

fn pt_in_sphere pt c r =(
    (sm_distance c pt <= r)
)

fn pt_in_cylinder pt p q r=(
    n = normalize(q-p)
    d = dot n p
    if not (is_same_side_of_plane pt ((p+q)/2.0) n d) then False
    n = normalize(q-p)
    d = dot n q
    if not (is_same_side_of_plane pt ((p+q)/2.0) n d) then False
    proj_pt = proj_pt_to_plane pt n d
    ((sm_distance proj_pt q) <= r)
)

fn segment_sphere_isect sa sb c r =(
    NotFound = #(False, None)
    
    p = sa
    d = normalize(sb-sa)

    m = p - c
    b = dot m d
    c = (dot m m) - r * r

    if (c > 0.0) and (b > 0.0) then NotFound

    discr = b*b - c
    if discr < 0.0 then NotFound

    t = -b - sqrt(discr)
    if t < 0.0 then NotFound

    dist = sm_distance sa sb
    q = p + d * t
    #((t>=0 and t<=dist), q)
)

fn segment_cylinder_isect sa sb p q r=(
    SM_EPSILON = 1e-6
    d = q-p
    m = sa-p
    n = sb-sa
    md = dot m d
    nd = dot n d
    dd = dot d d

    NotFound = #(False, None)
    if (md < 0) and ((md + nd) < 0) then NotFound
    if (md > dd) and ((md + nd) > dd) then NotFound

    nn = dot n n
    mn = dot m n

    a = dd*nn - nd*nd
    k = (dot m m) - r*r
    c = dd*k - md*md

    if abs(a) < SM_EPSILON then(
        if c > 0 then NotFound
        if (md < 0)or(md > dd) then(
            if md < 0 then(
                t = -mn / nn
            )
            if md > dd then(
                t = (nd - mn) / nn
            )
        )
        else(
            t = 0
        )
        #(True, (lerp_vec sa sb t))
    )

    b = dd*mn - nd*md
    discr = b*b - a*c
    if discr < 0 then NotFound
    t = (-b - sqrt(discr))/a
    if (t < 0.0) or (t > 1.0) then NotFound
    if ((md + t * nd) < 0.0) then(
        if nd <= 0.0 then NotFound
        t = (-1*md)/nd
        #((k + 2*t*(mn + t*nn) <= 0.0), (lerp_vec sa sb t))
    )
    if (md + t*nd) > dd then(
        if nd >= 0.0 then NotFound
        t = (dd - md)/nd
        #(((k + dd - 2*md + t*(2*(mn - nd) + t*nn)) <= 0.0), (lerp_vec sa sb t))
    )
    #(True, (lerp_vec sa sb t))
)

fn pt_in_capsule pt p q r =(
    ((pt_in_cylinder pt p q r) or (pt_in_sphere pt p r) or (pt_in_sphere pt q r))
)

fn segment_capsule_isect sa sb p q r =(

    if (pt_in_capsule sa p q r) and (pt_in_capsule sb p q r) then(
        -- both inside.  extend sb to get intersection
        newb = sa + normalize(sb-sa) * 200.0
        sa = newb
        sb = sa
    )
    if (pt_in_capsule sa p q r) then(
        sb = sa
        sa = sb
    )
    d = normalize(sb-sa)

    i1 = segment_sphere_isect sa sb p r
    i2 = segment_sphere_isect sa sb q r
    i3 = segment_cylinder_isect sa sb p q r

    -- make a big number
    dist = 3.40E38

    closest_pt = None
    hit = False
    hitCylinder = False
    if i1[1] then(
        hit = True
        pt = i1[2]
        if (sm_distance sa pt) < dist then(
            closest_pt = pt
        )
        dist = amin #(dist, (sm_distance sa pt))
        -- draw_locator(i1[2], 'i1')
    )
    if i2[1] then(
        hit = True
        pt = i2[2]
        if (sm_distance sa pt) < dist then(
            closest_pt = pt
        )
        dist = amin #(dist, (sm_distance sa pt))
    )
    if i3[1] then(
        hit = True
        hitCylinder = True
        pt = i3[2]
        if (sm_distance sa pt) < dist then(
            closest_pt = pt
        )
        dist = amin #(dist, (sm_distance sa pt))
    )
    #(hit, closest_pt, hitCylinder)
)


fn getColCapsulePQ colBody =(

    r = colBody.radius
    h = colBody.height
    m = matrix3 1
    m.pos = [-r,0,0]
    p = (inverse m*colBody.transform).pos -- sphereA center pos of capsule
    m.pos = [-(h-r),0,0]
    q = (inverse m*colBody.transform).pos -- sphereB center pos of capsule
    #(p,q,r,h)
)

fn sm_flipObj obj =(
    t = obj.transform
    obj.transform *= inverse obj.transform
    obj.rotation *= quat 1 1 0 0
    obj.transform *= t
)

fn preCheckCollision obj colBodyLst =(
    -- pre check bone length compare with collision body radius
    -- will improve performance if bone is far from capsule
    objLength = obj.boneLength
    for colBody in colBodyLst do(
        pq = getColCapsulePQ colBody
        p = pq[1]
        q = pq[2]
        boneToCapsuleDistance = dist_to_line p q obj.pos
        r = pq[3]

        if boneToCapsuleDistance < (objLength+r) then return #(p,q)  -- means close enough to have a hit change
    )
    undefined
)

fn ckeckPointInTri pos pa pb pc =(
    ra = acos(dot (normalize (pa-pos)) (normalize(pb-pos)))
    rb = acos(dot (normalize (pb-pos)) (normalize(pc-pos)))
    rc = acos(dot (normalize (pc-pos)) (normalize(pa-pos)))
    (abs(ra+rb+rc)>359)
)

fn getVertexPositions obj = (
    local vPositions = #()
    local triMesh = snapshotAsMesh obj
    for v = 1 to triMesh.numVerts do (
        append vPositions (getVert triMesh v)
    )
    delete triMesh
    vPositions
)

fn checkPlaneCollision obj refLoc colPlane=(

    v_coords = getVertexPositions colPlane

    -- get obj distance to plane
    n = colPlane.dir
    q = v_coords[1]
    d = dot n q
    pt = obj.pos
    toPlaneDistance = dist_to_plane pt n d
    pt_child = refLoc.pos
    toPlaneDistance_child = dist_to_plane pt_child n d

    -- get project pos on plane
    projectPos_child = proj_pt_to_plane pt_child n d
    inPlane = False
    if (ckeckPointInTri projectPos_child v_coords[1] v_coords[2] v_coords[3]) then inPlane = True
    else(
        if (ckeckPointInTri projectPos_child v_coords[4] v_coords[2] v_coords[3]) then inPlane = True
    )

    -- bone above plane and bone child under plane and child project point on plane
    -- means has collision with plane
    if (toPlaneDistance>0) and (toPlaneDistance_child<0) and inPlane then projectPos_child
    else undefined
)

fn sm_getParentLst parentLst root obj =(
    if obj.parent != root then(
        append parentLst obj.parent
        sm_getParentLst parentLst root obj.parent
    )
    parentLst
)

fn sm_getChainLength rootObj endObj isRefPose =(
    parentLst = #(endObj)
    chainLst = sm_getParentLst parentLst rootObj endObj
    chainLength = 0.0
    for obj in chainLst do(
        if isRefPose then(
            chainLength += obj.boneLength
        )else(
            chainLength += obj.length
        )
    )
    chainLength
)

fn smooth_butterworth indata Samplingrate:30.0 CutOff:7.0=(
    -- indata:          input float array #()
    -- Samplingrate:    frame rate float
    -- CutOff:          the power of smooth float
    if indata == undefined then undefined
    if CutOff == 0.0 then indata

--     Samplingrate = 1 / deltaTimeinsec
--     Samplingrate = deltaTimeinsec
    dF2 = indata.count      -- the last array index, not length
    Dat2 = #()
    data = deepCopy indata

    -- Copy indata to Dat2
    Dat2[1] = indata[1]
    Dat2[2] = indata[1]
    for r = 1 to dF2 do(
        Dat2[2 + r] = indata[r]
    )
    Dat2[dF2 + 2] = indata[dF2]
    Dat2[dF2 + 3] = indata[dF2]

    wc1 = CutOff * pi / Samplingrate -- radian value
    wc = tan(radToDeg wc1) -- tan function in max take degree
    k1 = 1.414213 * wc -- Sqrt(2) * wc
    k2 = wc * wc
    a = k2 / (1 + k1 + k2)
    b = 2 * a
    c = a
    k3 = b / k2
    d = -2 * a + k3
    e = 1 - (2 * a) - k3

    -- RECURSIVE TRIGGERS - ENABLE filter is performed (first, last points constant)
    DatYt = #()
    DatYt[1] = indata[1]
    DatYt[2] = indata[1]
    for s = 3 to (dF2+2) do(
        DatYt[s] = a*Dat2[s] + b*Dat2[s - 1] + c*Dat2[s - 2] + d*DatYt[s - 1] + e*DatYt[s - 2]
    )
    DatYt[dF2 + 2] = DatYt[dF2 + 1]
    DatYt[dF2 + 3] = DatYt[dF2 + 1]

    -- FORWARD filter
    DatZt = #()
    for i = 1 to dF2+2 do DatZt[i] = 0
    DatZt[dF2] = DatYt[dF2 + 2]
    DatZt[dF2 + 1] = DatYt[dF2 + 3]
    g = -1
    for t = (-dF2+1) to -1 do(
        DatZt[-t] = a*DatYt[-t + 2] + b*DatYt[-t + 3] + c*DatYt[-t + 4] + d*DatZt[-t + 1] + e*DatZt[-t + 2]
--         DatZt[-t] = a*DatYt[-t + 2+g] + b*DatYt[-t + 3+g] + c*DatYt[-t + 4+g] + d*DatZt[-t + 1+g] + e*DatZt[-t + 2+g]
    )

    -- Calculated points copied for return
    for p = 1 to dF2 do(
        data[p] = DatZt[p]
    )
    -- force end with input data
    data[dF2] = indata[dF2]

    data
)

fn smooth_objects_rotation obj startFrame endFrame isTCB =(

    -- convert rotation to Euler_XYZ
    collapseTransform obj startFrame endFrame 1.0 False
    smBoneCtrl = obj.rotation.controller
    for iii = 1 to 3 do(
        -- get key values for each track
        inData = #()
        for kkk = 1 to smBoneCtrl[iii].keys.count do(
            inData[kkk] = smBoneCtrl[iii].keys[kkk].value
        )

        -- filter curve with butterworth algorithm
        outData = smooth_butterworth inData
        -- apply filered result back
        for kkk = 1 to smBoneCtrl[iii].keys.count do(
            smBoneCtrl[iii].keys[kkk].value = outData[kkk]
        )

    )
    collapseTransform obj startFrame endFrame 1.0 isTCB
)

fn sm_applyForce targetObj forceObj subDiv offset isExp =(
    offset = offset as float
    if offset>0 then(    -- skip on first frame
        maxForce = forceObj.modifiers[#Spring_Max_Force].forceAttr.maxForce
        minForce = forceObj.modifiers[#Spring_Max_Force].forceAttr.minForce
        freq = forceObj.modifiers[#Spring_Max_Force].forceAttr.frequency

        midForce = (maxForce+minForce)/2

        -- get source x-axis direction in world space
        forceDir = undefined
        disOffset = 0.0
        if isExp then(
            isReverse = forceObj.modifiers[#Spring_Max_Force].forceAttr.isReverse
            if isReverse then(
                forceDir = forceObj.pos-targetObj.pos
            )
            else(
                forceDir = targetObj.pos-forceObj.pos
            )
            -- get obj distance to wind plane
            n = forceObj.dir
            q = forceObj.pos
            d = dot n q
            disOffset = dist_to_plane targetObj.pos n d
        )
        else(
            forceDir = forceObj.dir
            disOffset = sm_distance forceObj.pos targetObj.pos
        )
        forceDistance = sin(offset*freq+disOffset)*(maxForce-minForce)+midForce

        targetObj.pos = offsetPosByDirection forceDir targetObj.pos (forceDistance/subDiv)
    )
)


fn checkCollision cur_pos pre_pos capsuleLst isRevert fastMoveNum subDiv =(
    -- checkCollision with ray
    if not isRevert then(
        rRay = ray cur_pos (pre_pos-cur_pos)
    )
    else(
        rRay = ray pre_pos (cur_pos-pre_pos)
    )

    closest_pt_dict = #()
    for colBody in capsuleLst do(
        pqr = getColCapsulePQ colBody
        with animate off(
            colBody.curPosP = pqr[1]
            colBody.curPosQ = pqr[2]
        )
        r = pqr[3]
        h = pqr[4]
        is_cur_pos_inside = pt_in_capsule cur_pos colBody.curPosP colBody.curPosQ r
        is_pre_pos_inside = pt_in_capsule pre_pos colBody.curPosP colBody.curPosQ r
--         print is_cur_pos_inside
--         print is_pre_pos_inside

        if is_cur_pos_inside or is_pre_pos_inside then( -- skip ray check if both point out of capsult
            if is_cur_pos_inside and is_cur_pos_inside then( -- rebuild ray if both point are inside capsule
                n = amax #(r*2, h)    -- use longest side of capsule as n
                t = n/(distance cur_pos pre_pos)+1  -- get times rate between n and line length
                if not isRevert then(
                    rRay = ray ((pre_pos-cur_pos)*t+cur_pos) (cur_pos-pre_pos)
                )
                else(
                    rRay = ray ((cur_pos-pre_pos)*t+pre_pos) (pre_pos-cur_pos)
                )
            )
            result = (intersectray colBody rRay)
            -- print (result != undefined)
            if result != undefined then(
                append closest_pt_dict #(colBody,result.pos)
            )
        )
        -- if any end of Capsule moves faster than seted number, will trigger fast move
        pSpeed = (sm_distance colBody.curPosP colBody.prePosP)*subDiv
        qSpeed = (sm_distance colBody.curPosQ colBody.prePosQ)*subDiv
        with animate off(
            colBody.isFastMove = (pSpeed>fastMoveNum) or (qSpeed>fastMoveNum)
            colBody.moveSpeed = amax #(pSpeed,qSpeed)
        )
--         print #(colBody.curPosP,colBody.prePosP)
--         print pSpeed
--         print qSpeed
--         print colBody.isFastMove
    )
    if closest_pt_dict.count>0 then(
        pt_length = 3.40E38
        closest_pt = undefined
        col_obj = undefined
        for pt in closest_pt_dict do(
            lLength = distance pre_pos pt[2]
            if lLength < pt_length then(

                pt_length = lLength
                closest_pt = pt[2]
                col_obj = pt[1]

            )
        )
        -- return col pt and col_body speed
        #(closest_pt, col_obj)
    )
    else #(undefined, undefined)
)

fn sm_restoreInitPose boneLst =(
    for obj in boneLst do(
        local boneInitPos_attr = attributes boneInitPos_attr (parameters main (boneInitPos type:#point3))
        custAttributes.add obj boneInitPos_attr
        local boneInitRot_attr = attributes boneInitRot_attr (parameters main (boneInitRot type:#string))
        custAttributes.add obj boneInitRot_attr
        obj.boneInitPos = obj.pos.controller.value
        obj.boneInitRot = (obj.rotation.controller.value) as string
    )
)

fn sm_repeatMoveToPlane obj objTarget colPlane times =(
--     proxyPlane = convertToPoly(instance colPlane)
--     v_coords = for vID = 1 to proxyPlane.GetNumVertices() collect polyOp.getVert proxyPlane vID
--     delete proxyPlane

    n = colPlane.dir
    q = colPlane.pos
    d = dot n q
    for i = 1 to times do(
        pt = obj.pos
        obj.pos = proj_pt_to_plane pt n d
        if i != times then obj.pos = objTarget.pos
    )
)

fn sm_connectBone boneLst isClose=(
    -- filter bones
    boneLst = for obj in boneLst where (classOf obj == BoneGeometry) and (obj.children != undefined) collect obj
    if boneLst.count < 2 then return False
    -- creat curve
    ss = SplineShape pos:[0,0,0]
    ss.renderable = off
    ss.name = ""
    addNewSpline ss
    local attr = attributes attr (parameters main (boneLst type:#stringTab tabSizeVariable:true))
    custAttributes.add ss attr
    local cAttr = attributes cAttr (parameters main (isClose type:#boolean))
    custAttributes.add ss cAttr
    for smBone in boneLst do(
        ss.name += smBone.name
        ss.name += "_"
        addKnot ss 1 #smooth #curve smBone.children[1].pos
        append ss.boneLst smBone.name
    )
    if isClose then(
        addKnot ss 1 #smooth #curve boneLst[1].children[1].pos
    )
    ss.name += connectSpline_subFix
    ss.isClose = isClose
    updateShape ss
)

fn sm_getAnimSaveLoc =(
    animSaveLoc = execute ("$'*"+animSaveLoc_subFix+"'")
    if animSaveLoc.count == 0 then undefined
    else animSaveLoc
)

fn sm_revertBoneAnim =(
    animSaveLoc = execute ("$'*"+animSaveLoc_subFix+"'")
    if animSaveLoc.count != 0 then(
        for loc in animSaveLoc do(
            smBoneName = substring loc.name 1 ((findString loc.name animSaveLoc_subFix)-1)
            smBone = getnodebyname smBoneName exact:true
            if smBone != undefined then(
                ooo = smBone.boneEnable
                smBone.boneEnable = false
                deleteKeys smBone.pos.controller #allKeys
                deleteKeys smBone.rotation.controller #allKeys
                deleteKeys smBone.scale.controller #allKeys
                at time loc.rotation.controller.keys[1].time(
                    smBone.transform = loc.transform
                )
                for key in loc.rotation.controller.keys do(
                    at time key.time(
                        with animate on(
                            smBone.transform = loc.transform
                        )
                    )
                )
                smBone.boneEnable = ooo
            )
        )
        delete animSaveLoc
    )
)

fn sm_clearAnimSaveLoc =(
    animSaveLoc = execute ("$'*"+animSaveLoc_subFix+"'")
    if animSaveLoc.count != 0 then delete animSaveLoc
)

sm_bonePosLst = #()
sm_boneRotLst = #()
fn sm_copyBoneTM boneLst=(
    sm_bonePosLst = #()
    sm_boneRotLst = #()
    for obj in boneLst do(
        append sm_bonePosLst obj.pos.controller.value
        append sm_boneRotLst obj.rotation.controller.value
    )
)
fn sm_pasteBoneTM boneLst=(
    i=1
    for obj in boneLst do(
        obj.pos.controller.value = sm_bonePosLst[i]
        obj.rotation.controller.value = sm_boneRotLst[i]
        i += 1
    )
)

fn springMax_Main boneLst spring_bend spring_twist extend tension mass startFrame endFrame isTargetFrame targetFrame subDiv isWipe isLoop isTcb isCollision isFastMove fastMoveNum isBoneSize colBodyLst colPlaneLst isWind windObj isExp expObj isPoseMatch isPinEndStretch poseMatchSpace SMProxy =(

    isFirstPass = True

--     spring_bend /= subDiv
--     spring_twist /= subDiv
--     mass /= subDiv
--     tension /= subDiv

    tension /= 1/(sigmoid(1-subDiv)+0.5)

    -- create locator
    boneLocLst = #()
    -- restore bone anim before calculation
    for smBone in boneLst do(
        sliderTime = startFrame
        -- restore anim to loc
        smBoneAnimSaveLoc = point name:(smBone.name+animSaveLoc_subFix) cross:false box:false
        -- remove animSaveLoc out of boneLocLst to keep it after calculation for revert animation
        -- append boneLocLst smBoneAnimSaveLoc

        -- get start and end time of bone animation
        at time startFrame(
            smBoneAnimSaveLoc.transform = smBone.transform
            addNewKey smBoneAnimSaveLoc.pos.controller startFrame
            addNewKey smBoneAnimSaveLoc.rotation.controller startFrame
        )

        for key in smBone.rotation.controller.keys do(
            at time key.time(
                sliderTime = key.time
                with animate on smBoneAnimSaveLoc.transform = smBone.transform
            )
        )
    )
    -- goto target frame do to initial work
    if isTargetFrame then sliderTime = targetFrame
    else sliderTime = startFrame
    -- build locator first
    for smBone in boneLst do(


        if isPoseMatch then(
            smBonePoseSaveLoc = point name:(smBone.name+poseSaveLoc_subFix) cross:False box:False
            smBonePoseSaveLoc.parent = smBone.parent
            append boneLocLst smBonePoseSaveLoc
            -- get start and end time of bone animation
            with animate on(
                for key in smBone.rotation.controller.keys do(
                    at time key.time(
                        smBonePoseSaveLoc.transform = smBone.transform
                    )
                )
            )            
        )

        if smBone.children.count>0 then(

            smBoneChild = smBone.children[1]

            smBonePoseSaveChildLoc = point pos:smBoneChild.pos name:(smBone.name+poseSaveChildLoc_subFix) cross:False box:False
            smBonePoseSaveChildLoc.parent = smBonePoseSaveLoc
            append boneLocLst smBonePoseSaveChildLoc
            -- ref pos
            smBoneRefLoc = sm_createLocator smBone aimRefLoc_subFix boneLocLst True True False
            -- child ref pos, only creat of whe bone has grandchild
            if smBoneChild.children.count>0 then(
                smBoneChildRefLoc = sm_createLocator smBoneChild aimChildRefLoc_subFix boneLocLst True True False
                smBoneChildRefLoc.name = smBone.name+aimChildRefLoc_subFix
                smBoneChildRefLoc.parent = smBone.parent
            )
            -- pre pos
            smBonePreLoc = sm_createLocator smBone aimPreLoc_subFix boneLocLst True False False
            -- pre pre pos for mass
            smBonePrePreLoc = sm_createLocator smBone aimPrePreLoc_subFix boneLocLst True False False
            -- up axis
            smBoneUpLoc = sm_createLocator smBone aimUpLoc_subFix boneLocLst False False False
            -- ref up axis
            smBoneRefUpLoc = sm_createLocator smBone aimRefUpLoc_subFix boneLocLst True True False
            -- pre up axis
            smBonePreUpLoc = sm_createLocator smBone aimPreUpLoc_subFix boneLocLst False False False

            -- create size loc
            if isBoneSize then(

                smBoneFinAPreLoc = sm_createLocator smBone aimFinAPreLoc_subFix boneLocLst True False False
                smBoneFinARefLoc = sm_createLocator smBone aimFinARefLoc_subFix boneLocLst True True False
                smBoneFinACurLoc = sm_createLocator smBone aimFinACurLoc_subFix boneLocLst True False False
                smBoneFinBPreLoc = sm_createLocator smBone aimFinBPreLoc_subFix boneLocLst True False False
                smBoneFinBRefLoc = sm_createLocator smBone aimFinBRefLoc_subFix boneLocLst True True False
                smBoneFinBCurLoc = sm_createLocator smBone aimFinBCurLoc_subFix boneLocLst True False False
                smBoneFinACurLoc.parent = smBoneFinBCurLoc.parent = smBone
                -- place size loc
                boneDir = [0,0,0]
                fin_Offset = 0
                if smBone.width>=smBone.height then(
                    fin_Offset = smBone.width/2
                    boneDir = smBone.dir
                )
                else(
                    fin_Offset = smBone.height/2
                    boneDir = smBone.transform.row2
                )
                FinA_Pos = smBoneChild.pos + boneDir*fin_Offset
                smBoneFinAPreLoc.pos = smBoneFinARefLoc.pos = smBoneFinACurLoc.pos = FinA_Pos
                FinB_Pos = smBoneChild.pos + -1*boneDir*fin_Offset
                smBoneFinBPreLoc.pos = smBoneFinBRefLoc.pos = smBoneFinBCurLoc.pos = FinB_Pos
            )
--             remove exist anim
            selectKeys smBone.pos.controller startFrame endFrame
            deleteKeys smBone.pos.controller #selection
            selectKeys smBone.rotation.controller startFrame endFrame
            deleteKeys smBone.rotation.controller #selection
        )
    )

    -- add constraint after
    for smBone in boneLst do(

        -- disable bone on before calculation
        local boneOnState_attr = attributes boneOnState_attr (parameters main (boneOnState type:#boolean))
        custAttributes.add smBone boneOnState_attr
        smBone.boneOnState = smBone.boneEnable
        smBone.boneEnable=false

        if smBone.children.count>0 then(
--             -- use two aim that can play offset on smBoneCurLoc
--             -- make smBoneCurLocBase aim to target angle
--             sm_addAimCons smBoneCurLocBase smBoneRefLoc smBonePreLoc undefined spring_bend False False
            -- make bone aim to smBoneCurLoc
            -- find all bone loc
            smBoneRefLoc = sm_getLoc smBone aimRefLoc_subFix
            smBonePreLoc = sm_getLoc smBone aimPreLoc_subFix
            smBonePrePreLoc = sm_getLoc smBone aimPrePreLoc_subFix
            smBoneCurLocBase = sm_getLoc smBone aimCurLocBase_subFix
            smBoneCurLoc = sm_getLoc smBone aimCurLoc_subFix
            smBoneUpLoc = sm_getLoc smBone aimUpLoc_subFix
            smBonePreUpLoc = sm_getLoc smBone aimPreUpLoc_subFix
            smBoneRefUpLoc = sm_getLoc smBone aimRefUpLoc_subFix

            isTension = (tension>0.0 and isCollision)

            -- add connect bone
            cCurveLst = getObjWithName connectSpline_subFix
            fNeibourBone = undefined
            bNeibourBone = undefined
            -- get all curve
            if cCurveLst != undefined then(
                for cCurve in cCurveLst do(
                    boneIndex = 1
                    foundBone = False
                    boneLstCount = cCurve.boneLst.count
                    for boneName in cCurve.boneLst do(
                        boneObjLst = getObjWithName boneName exact:True

                        -- quit calculation if duplication bone name or cannot find bone
                        if (boneObjLst==undefined) then(
                            messageBox (boneName+uistrLst[2][5])
                            return False
--                             exit
                        )
                        if (boneObjLst.count>1) then(
                            messageBox (boneName+uistrLst[2][4])
                            return False
--                             exit
                        )
                        -- find neibour
                        if boneObjLst[1] == smBone then(
                            foundBone = True
                            -- get bone neibour if found bone in connection list
                            if boneIndex == 1 then( -- is start bone
                                if cCurve.isClose then fNeibourBone = (getObjWithName cCurve.boneLst[boneLstCount] exact:True)[1]
                                else fNeibourBone = undefined
                                bNeibourBone = (getObjWithName cCurve.boneLst[2] exact:True)[1]
                            )
                            if (boneIndex>1) and (boneIndex<boneLstCount) then( -- is middle bone
                                fNeibourBone = (getObjWithName cCurve.boneLst[boneIndex-1] exact:True)[1]
                                bNeibourBone = (getObjWithName cCurve.boneLst[boneIndex+1] exact:True)[1]
                            )
                            if boneIndex == boneLstCount then( -- is end bone
                                fNeibourBone = (getObjWithName cCurve.boneLst[boneLstCount-1] exact:True)[1]
                                if cCurve.isClose then bNeibourBone = (getObjWithName cCurve.boneLst[1] exact:True)[1]
                                else bNeibourBone = undefined
                            )
                        )
                        boneIndex += 1
                    )
                    if foundBone then exit
                )
            )

            sm_addPosCons smBone fNeibourBone bNeibourBone

            sm_addAimCons smBone smBoneRefLoc smBonePreLoc smBoneUpLoc spring_bend tension isTension fNeibourBone bNeibourBone

            sm_addOriCons smBoneUpLoc smBonePreUpLoc smBoneRefUpLoc spring_twist

            oldRange = animationRange
            if startFrame >= 0 then(
                animationRange = interval -1 (endFrame + 1)
            )
            else(
                animationRange = interval (startFrame-1) (endFrame + 1)
            )
            with animate on(
                -- disable constraint before and after cal range
                sliderTime = 0
                smBone.rotation.controller.weight = #(100.0, 0.0)
                sliderTime = (startFrame - 1)
                smBone.rotation.controller.weight = #(100.0, 0.0)
                sliderTime = startFrame
                smBone.rotation.controller.weight = #(0.0, 100.0)
                sliderTime = endFrame
                smBone.rotation.controller.weight = #(0.0, 100.0)
                sliderTime = (endFrame + 1)
                smBone.rotation.controller.weight = #(100.0, 0.0)
            )
            animationRange = oldRange

            -- add pre TM attr
            local bonePrePos_attr = attributes bonePrePos_attr (parameters main (bonePrePos type:#point3))
            custAttributes.add smBone bonePrePos_attr
            local bonePrePrePos_attr = attributes bonePrePrePos_attr (parameters main (bonePrePrePos type:#point3))
            custAttributes.add smBone bonePrePrePos_attr
            local bonePreDis_attr = attributes bonePreDis_attr (parameters main (bonePreDis type:#float))
            custAttributes.add smBone bonePreDis_attr
            local boneRefPos_attr = attributes boneRefPos_attr (parameters main (boneRefPos type:#point3))
            custAttributes.add smBone boneRefPos_attr
            local bonePreUpTM_attr = attributes bonePreUpTM_attr (parameters main (bonePreUpTM type:#matrix3))
            custAttributes.add smBone bonePreUpTM_attr
            local boneLength_attr = attributes boneLength_attr (parameters main (boneLength type:#float))
            custAttributes.add smBone boneLength_attr
--             local boneCurLengthAttr = attributes boneCurLengthAttr (parameters main (boneCurLength type:#float))
--             custAttributes.add smBone boneCurLengthAttr            
            local boneChildRefPos_attr = attributes boneChildRefPos_attr (parameters main (boneChildRefPos type:#point3))
            custAttributes.add smBone boneChildRefPos_attr
            local isCollide_attr = attributes isCollide_attr (parameters main (isCollide type:#boolean))
            custAttributes.add smBone isCollide_attr
            local isCollidePlane_attr = attributes isCollidePlane_attr (parameters main (isCollidePlane type:#boolean))
            custAttributes.add smBone isCollidePlane_attr            
            local boneChildRefTM_attr = attributes boneChildRefTM_attr (parameters main (boneChildRefTM type:#matrix3))
            custAttributes.add smBone boneChildRefTM_attr
            local bonePreLocPos_attr = attributes bonePreLocPos_attr (parameters main (bonePreLocPos type:#point3))
            custAttributes.add smBone bonePreLocPos_attr

            if isBoneSize then(
                local boneFinAPreLocPos_attr = attributes boneFinAPreLocPos_attr (parameters main (boneFinAPreLocPos type:#point3))
                custAttributes.add smBone boneFinAPreLocPos_attr
                local boneFinARefLocPos_attr = attributes boneFinARefLocPos_attr (parameters main (boneFinARefLocPos type:#point3))
                custAttributes.add smBone boneFinARefLocPos_attr
                local boneFinBPreLocPos_attr = attributes boneFinBPreLocPos_attr (parameters main (boneFinBPreLocPos type:#point3))
                custAttributes.add smBone boneFinBPreLocPos_attr
                local boneFinBRefLocPos_attr = attributes boneFinBRefLocPos_attr (parameters main (boneFinBRefLocPos type:#point3))
                custAttributes.add smBone boneFinBRefLocPos_attr
            )

            if isTargetFrame then sliderTime = targetFrame
            else sliderTime = startFrame

            smBoneChild = smBone.children[1]

            smBone.boneRefPos = smBoneRefLoc.pos.controller.value
            smBone.boneLength = smBoneChild.pos.controller.value[1]
            smBone.bonePreLocPos = [0,0,0]
            if isBoneSize then(
                smBoneFinARefLoc = sm_getLoc smBone aimFinARefLoc_subFix
                smBoneFinBRefLoc = sm_getLoc smBone aimFinBRefLoc_subFix
                smBone.boneFinARefLocPos = smBoneFinARefLoc.pos.controller.value
                smBone.boneFinBRefLocPos = smBoneFinBRefLoc.pos.controller.value
            )

            if smBoneChildRefLoc != undefined then(
                if (findItem boneLst smBoneChild)>0 then (
                    smBoneChild.isCollide = False
                    smBoneChild.isCollidePlane = False
                )
                boneGrandChild = smBoneChild.children[1]
                if boneGrandChild != undefined then(
                    smBoneChildRefLoc.pos = boneGrandChild.pos
                    smBone.boneChildRefPos = smBoneChildRefLoc.pos.controller.value
                )
            )
            sliderTime = (startFrame-1)
            with animate on (
                smBoneChild.Pos = smBoneChild.Pos
                smBone.bonePrePrePos = smBone.bonePrePos
                smBone.bonePrePos = smBoneChild.Pos
                smBone.bonePreDis = length(smBone.bonePrePos - smBone.bonePrePrePos)
                smBone.bonePreUpTM = smBone.transform
                if isBoneSize then(
                    smBoneFinACurLoc = sm_getLoc smBone aimFinACurLoc_subFix
                    smBoneFinBCurLoc = sm_getLoc smBone aimFinBCurLoc_subFix
                    smBone.boneFinAPreLocPos = smBoneFinACurLoc.pos
                    smBone.boneFinBPreLocPos = smBoneFinBCurLoc.pos
                )
            )
--             point pos:smBone.bonePrePos
            sliderTime = startFrame
        )
    )
    -- attr list added by script that gona remove later
    attrNameLst = #(\
        "bonePrePos_attr" as name,\
        "bonePrePrePos_attr" as name,\
        "bonePreDis_attr" as name,\
        "boneRefPos_attr" as name,\
        "bonePreUpTM_attr" as name,\
        "boneLength_attr" as name,\
        "boneChildRefPos_attr" as name,\
        "isCollide_attr" as name,\
        "isCollidePlane_attr" as name,\
        "bonePreLocPos_attr" as name,\
        "boneFinAPreLocPos_attr" as name,\
        "boneFinARefLocPos_attr" as name,\
        "boneFinBPreLocPos_attr" as name,\
        "boneFinBRefLocPos_attr" as name,\
        "boneChildRefTM_attr" as name
    )


    i = startFrame
    sliderTime = startFrame
    -- initial capsule pq
    if isCollision and (colBodyLst != undefined) then(
        for colBody in colBodyLst do(
            pq = getColCapsulePQ colBody
            colBody.curPosP = pq[1]
            colBody.curPosQ = pq[2]
            colBody.isFastMove = False
        )
    )
    pre_i = startFrame
    iWind = startFrame
    windOffset = 0
    while i < (endFrame+(1/subDiv)) do (
        iWind = i
        with animate on (
            at time i(  -- frame loop
                -- get value from spring proxy to work with value keyframe
                SMProxy_spring = SMProxy.modifiers[#Spring_Max_Setting].springAttr.spring
                SMProxy_twist = SMProxy.modifiers[#Spring_Max_Setting].springAttr.twist
                SMProxy_flex = SMProxy.modifiers[#Spring_Max_Setting].springAttr.flex
                SMProxy_mass = SMProxy.modifiers[#Spring_Max_Setting].springAttr.mass
                SMProxy_mass *= (1-SMProxy_spring) -- reduce mass base on bend, to avoid jittery
                -- make sub div affect
                SMProxy_spring /= subDiv
                SMProxy_twist /= subDiv
                SMProxy_flex /= subDiv
--                 SMProxy_mass /= subDiv

                for smBone in boneLst do(   -- bone loop
                    if smBone.children.count>0 then(
                        smBoneCtrl = smBone.rotation.controller.getActive()
                        if subDiv == 1.0 then(
                            smBone.rotation.controller[smBoneCtrl].weight[1] = (1-SMProxy_spring)
                            smBone.rotation.controller[smBoneCtrl].weight[2] = SMProxy_spring
                        )else(
                            smBone.rotation.controller[smBoneCtrl].weight[1] = SMProxy_spring
                            smBone.rotation.controller[smBoneCtrl].weight[2] = 1-SMProxy_spring
                        )

                        smBoneChild = smBone.children[1]
                        smBoneRefLoc = sm_getLoc smBone aimRefLoc_subFix
                        smBonePreLoc = sm_getLoc smBone aimPreLoc_subFix
                        smBonePrePreLoc = sm_getLoc smBone aimPrePreLoc_subFix
                        smBoneCurLocBase = sm_getLoc smBone aimCurLocBase_subFix
                        smBoneCurLoc = sm_getLoc smBone aimCurLoc_subFix
                        smBoneUpLoc = sm_getLoc smBone aimUpLoc_subFix
                        smBonePreUpLoc = sm_getLoc smBone aimPreUpLoc_subFix
                        smBoneChildRefLoc = sm_getLoc smBone aimChildRefLoc_subFix
                        if isPoseMatch then(
                            smBonePoseSaveLoc = sm_getLoc smBone poseSaveLoc_subFix
                            smBonePoseSaveChildLoc = sm_getLoc smBone poseSaveChildLoc_subFix
                        )

                        -- get fin loc
                        if isBoneSize then(
                            smBoneFinAPreLoc = sm_getLoc smBone aimFinAPreLoc_subFix
                            smBoneFinARefLoc = sm_getLoc smBone aimFinARefLoc_subFix
                            smBoneFinBPreLoc = sm_getLoc smBone aimFinBPreLoc_subFix
                            smBoneFinBRefLoc = sm_getLoc smBone aimFinBRefLoc_subFix
                            smBoneFinACurLoc = sm_getLoc smBone aimFinACurLoc_subFix
                            smBoneFinBCurLoc = sm_getLoc smBone aimFinBCurLoc_subFix
                        )

                        if i == startFrame and (not isFirstPass) then (
                            -- paste last frame pose to first fram for loop
                            sm_pasteBoneTM boneLst
                            iWind += (endFrame-startFrame)
                        )
                        -- load last frame data
                        if isPoseMatch then(
                            if (i == startFrame and isFirstPass == True) or SMProxy_mass == 0.0 then(
                                smBoneRefLoc.pos = smBonePoseSaveChildLoc.pos
                            )else(  -- offset ref loc when has mass setting
                                smBoneRefLocOffsetDir = smBonePoseSaveChildLoc.pos - smBoneRefLoc.pos
                                smBoneRefLocOffsetDistance = length(smBoneRefLocOffsetDir)*(1-SMProxy_spring)*(1-SMProxy_mass)
                                smBoneRefLoc.pos = offsetPosByDirection smBoneRefLocOffsetDir smBoneRefLoc.pos (smBoneRefLocOffsetDistance/subDiv)
                            )
                        )
                        else(
                            if (i == startFrame and isFirstPass == True) or SMProxy_mass == 0.0 then(
                                smBoneRefLoc.pos.controller.value = smBone.boneRefPos
                            )else(  -- offset ref loc when has mass setting
                                smBoneRefLocOffsetDir = smBone.boneRefPos - smBoneRefLoc.pos.controller.value
                                smBoneRefLocOffsetDistance = length(smBoneRefLocOffsetDir)*(1-SMProxy_spring)*(1-SMProxy_mass)
                                smBoneRefLoc.pos.controller.value = offsetPosByDirection smBoneRefLocOffsetDir smBoneRefLoc.pos.controller.value (smBoneRefLocOffsetDistance/subDiv)
                            )
                        )
                        smBonePrePreLoc.pos = smBonePreLoc.pos
                        smBonePreLoc.pos = smBone.bonePrePos
--                         smBonePreUpLoc.pos = smBonePreLoc.pos
                        if isBoneSize then(
                            smBoneFinARefLoc.pos.controller.value = smBone.boneFinARefLocPos
                            smBoneFinAPreLoc.pos = smBone.boneFinAPreLocPos
                            smBoneFinBRefLoc.pos.controller.value = smBone.boneFinBRefLocPos
                            smBoneFinBPreLoc.pos = smBone.boneFinBPreLocPos
                        )

                        -- apply mass
                        if i != startFrame or isFirstPass == False then(
                            forceDir = smBonePreLoc.pos-smBonePrePreLoc.pos
                            forceDistance = smBone.bonePreDis*SMProxy_mass
                            smBoneRefLoc.pos = offsetPosByDirection forceDir smBoneRefLoc.pos (forceDistance/subDiv)
                        )

                        -- apply wind
                        windOffset = iWind
                        if isWind then(
                            sm_applyForce smBoneRefLoc windObj subDiv windOffset False
                        )

                        -- apply explosion
                        if isExp then(
                            sm_applyForce smBoneRefLoc expObj subDiv windOffset True
                        )

                        -- detect collision
                        col_pre = undefined
                        col_cur = undefined
                        -- apply capsule collision
                        if isCollision and (colBodyLst != undefined) then(
                            preResult = preCheckCollision smBone colBodyLst
                            if preResult != undefined then(
                                -- check col from previous pos to cur pos
                                checkResult = checkCollision smBoneRefLoc.pos smBonePreLoc.pos colBodyLst True fastMoveNum subDiv
                                col_pre = checkResult[1]
                                col_body_pre = checkResult[2]
                                -- check col from cur pos to previous pos
                                checkResult = checkCollision smBoneRefLoc.pos smBonePreLoc.pos colBodyLst False fastMoveNum subDiv
                                col_cur = checkResult[1]
                                col_body_cur = checkResult[2]

                                midPoint_A = smBonePreLoc.pos
                                midPoint_B = smBoneRefLoc.pos

                                -- do 2 more check for bone fin loc
                                if isBoneSize then(
                                    -- check col from previous pos to cur pos
                                    checkResult = checkCollision smBoneFinARefLoc.pos smBoneFinAPreLoc.pos colBodyLst True fastMoveNum subDiv
                                    col_finA_pre = checkResult[1]
                                    col_finA_body_pre = checkResult[2]
                                    -- check col from cur pos to previous pos
                                    checkResult = checkCollision smBoneFinARefLoc.pos smBoneFinAPreLoc.pos colBodyLst False fastMoveNum subDiv
                                    col_finA_cur = checkResult[1]
                                    col_finA_body_cur = checkResult[2]

                                    -- check col from previous pos to cur pos
                                    checkResult = checkCollision smBoneFinBRefLoc.pos smBoneFinBPreLoc.pos colBodyLst True fastMoveNum subDiv
                                    col_finB_pre = checkResult[1]
                                    col_finB_body_pre = checkResult[2]
                                    -- check col from cur pos to previous pos
                                    checkResult = checkCollision smBoneFinBRefLoc.pos smBoneFinBPreLoc.pos colBodyLst False fastMoveNum subDiv
                                    col_finB_cur = checkResult[1]
                                    col_finB_body_cur = checkResult[2]

--                                     print "----------------------------"
--                                     print i
--                                     print #(col_finA_pre,col_finA_cur,col_finB_pre,col_finB_cur)

                                    -- get longest distance as moving distance
                                    maxDist = 0.00123456
                                    if col_pre != undefined then(
                                        dist_o = sm_distance smBonePreLoc.pos col_pre
                                    ) else dist_o = 0
                                    if col_finA_pre != undefined then(
                                        dist_a = sm_distance smBoneFinAPreLoc.pos col_finA_pre
                                    ) else dist_a = 0
                                    if col_finB_pre != undefined then(
                                        dist_b = sm_distance smBoneFinBPreLoc.pos col_finB_pre
                                    ) else dist_b = 0
                                    -- apply movement onto bone pre loc
                                    maxDist = amax #(dist_o,dist_a,dist_b)
                                    if (maxDist == dist_a) and (col_finA_pre != undefined) then(
                                        -- transform collide movement result to smbone offset
                                        col_pre = (col_finA_pre-smBoneFinAPreLoc.pos)+smBonePreLoc.pos
                                        col_body_pre = col_finA_body_pre
                                        -- transform fin pre position to smbone offset
                                        midPoint_A = (smBoneRefLoc.pos-smBoneFinARefLoc.pos)+smBoneFinAPreLoc.pos
--                                         midPoint_B = smBoneFinARefLoc.pos
                                    )
                                    if (maxDist == dist_b) and (col_finB_pre != undefined) then(
                                        col_pre = (col_finB_pre-smBoneFinBPreLoc.pos)+smBonePreLoc.pos
                                        col_body_pre = col_finB_body_pre
                                        midPoint_A = (smBoneRefLoc.pos-smBoneFinBRefLoc.pos)+smBoneFinBPreLoc.pos
--                                         midPoint_B = smBoneFinBRefLoc.pos
                                    )

                                    -- get longest distance as moving distance
                                    if col_cur != undefined then(
                                        dist_o = sm_distance smBonePreLoc.pos col_cur
                                    ) else dist_o = 0
                                    if col_finA_cur != undefined then(
                                        dist_a = sm_distance smBoneFinAPreLoc.pos col_finA_cur
                                    ) else dist_a = 0
                                    if col_finB_cur != undefined then(
                                        dist_b = sm_distance smBoneFinBPreLoc.pos col_finB_cur
                                    ) else dist_b = 0
                                    -- apply movement onto bone pre loc
                                    maxDist = amax #(dist_o,dist_a,dist_b)
--                                     print #(dist_o,dist_a,dist_b,maxDist)
                                    if (maxDist == dist_a) and (col_finA_cur != undefined) then(
                                        col_cur = (col_finA_cur-smBoneFinAPreLoc.pos)+smBonePreLoc.pos
                                        col_body_cur = col_finA_body_cur
                                        -- transform fin position offset to bone 
                                        midPoint_A = (smBoneRefLoc.pos-smBoneFinARefLoc.pos)+smBoneFinAPreLoc.pos
                                    )
                                    if (maxDist == dist_b) and (col_finB_cur != undefined) then(
                                        col_cur = (col_finB_cur-smBoneFinBPreLoc.pos)+smBonePreLoc.pos
                                        col_body_cur = col_finB_body_cur
                                        midPoint_A = (smBoneRefLoc.pos-smBoneFinBRefLoc.pos)+smBoneFinBPreLoc.pos
                                    )

--                                     print #(col_pre,col_body_pre,col_cur,col_body_cur)

                                )
--                                 -- debug
--                                 if (col_pre != undefined) then(
--                                     point name:("col_pre Frame "+i as string) pos:col_pre size:3
--                                 )
--                                 if (col_cur != undefined) then(
--                                     point name:("col_cur Frame "+i as string) pos:col_cur size:3
--                                 )

                                if (col_pre != undefined) and (col_cur == undefined) then(
                                    smBoneRefLoc.pos = col_pre
                                )
                                if (col_cur != undefined) and (col_pre == undefined) then(
                                    smBonePreLoc.pos = col_cur
                                )
                                if (col_pre != undefined) and (col_cur != undefined) then(
                                    -- move cur child pose to closest out point if both pre and cur pos are already inside of col body
                                    midPoint = (midPoint_A+midPoint_B)/2
                                    isCloseToPre = (sm_distance col_pre midPoint) < (sm_distance col_cur midPoint)
                                    if isCloseToPre then(
                                        smBoneRefLoc.pos = col_pre
                                        if col_body_pre.isFastMove then(
                                            moveRate = (col_body_pre.moveSpeed-fastMoveNum)/(fastMoveNum+0.01)
                                            if moveRate>1.0 then moveRate = 1.0
                                            if moveRate<0.0 then moveRate = 0.0
                                            smBonePreLoc.pos = col_pre*moveRate+smBonePreLoc.pos*(1-moveRate)
                                        )
                                    )
                                    else(
                                        smBoneRefLoc.pos = col_cur
                                        if col_body_cur.isFastMove then(
                                            moveRate = (col_body_cur.moveSpeed-fastMoveNum)/(fastMoveNum+0.01)
                                            if moveRate>1.0 then moveRate = 1.0
                                            if moveRate<0.0 then moveRate = 0.0
                                            smBonePreLoc.pos = col_cur*moveRate+smBonePreLoc.pos*(1-moveRate)
                                        )
                                    )
                                )
                            )
                        )

                        -- apply plane collision
                        isPlaneHit = False
                        if isCollision and (colPlaneLst != undefined) then(
                            colPlane = colPlaneLst[1]
                            colResult_Plane = checkPlaneCollision smBone smBoneRefLoc colPlane

                            isCollidePlane_Parent = False
                            if (findItem boneLst smBone.parent)>0 then(
                                isCollidePlane_Parent = smBone.parent.isCollidePlane
                            )

                            if colResult_Plane != undefined or isCollidePlane_Parent then(
                                sm_repeatMoveToPlane smBoneRefLoc smBoneChild colPlane 3
                                isPlaneHit = colResult_Plane != undefined
                            )
                        )

                        isHit = (col_pre != undefined) or (col_cur != undefined) or isPlaneHit

                        -- update tension locator pos
                        if smBoneChildRefLoc != undefined then(
                            if (findItem boneLst smBoneChild)>0 then(
                                boneGrandChild = smBoneChild.children[1]
                                if boneGrandChild != undefined then(
                                    smBoneChildRefLoc.pos = boneGrandChild.pos
                                )
                                -- if clide, set parent tension on
                                if (findItem boneLst smBone.parent)>0 then(
                                    aimCons = smBone.parent.rotation.controller[2]
                                    aimWeightLst = aimCons.weight
                                    if isHit and aimWeightLst.count>2 then aimWeightLst[3] = tension
                                    else aimWeightLst[3] = 0.0
                                )
                            )
                        )

                        aimCons = smBone.rotation.controller[2]
                        aimWeightLst = aimCons.weight
                        if isHit and aimWeightLst.count>3 then (aimWeightLst[4] = 0.0) else (aimWeightLst[4] = (tension/4))

                        -- flex
                        if SMProxy_flex != 0.0 then(
                            -- get length between bone pos and previous child pos
                            if subDiv>1 then(
                                if ceil pre_i.frame == floor i.frame then(    -- pass through an int frame number
                                    -- update bonePreLocPos on int frame
                                    with animate off(
                                        smBone.bonePreLocPos = smBonePreLoc.pos
                                    )
                                )
                            )
                            else(
                                with animate off(
                                    smBone.bonePreLocPos = smBonePreLoc.pos
                                )
                            )
                            x2 = (sm_distance smBone.pos smBone.bonePreLocPos)
--                             x3 = smBone.boneLength*(1-extend) + x2*extend
                            x3 = smBone.boneLength*(1-SMProxy_flex) + x2*SMProxy_flex
                            smBoneChild.pos.controller.value.x = x3

                            pre_i = i

                        )

                        -- twist
                        if subDiv == 1.0 then(
                            smBoneUpLoc.rotation.controller.weight[1] = (1-SMProxy_twist)
                            smBoneUpLoc.rotation.controller.weight[2] = SMProxy_twist
                        )else(
                            smBoneUpLoc.rotation.controller.weight[2] = (1-SMProxy_twist)
                            smBoneUpLoc.rotation.controller.weight[1] = SMProxy_twist
                        )
                        if isPoseMatch then(
                            smBonePreUpLoc.transform = smBonePoseSaveLoc.transform
                        )else(
                            smBonePreUpLoc.transform = smBone.bonePreUpTM
                        )

                        -- restore results for next frame
                        with animate off(
                            smBone.bonePrePrePos = smBone.bonePrePos
                            smBone.bonePrePos = smBoneChild.pos
                            smBone.bonePreDis = length(smBone.bonePrePos - smBone.bonePrePrePos)
                            smBone.bonePreUpTM = smBoneUpLoc.transform
                            smBone.isCollide = (col_pre != undefined) or (col_cur != undefined)
                            smBone.isCollidePlane = isPlaneHit
                            if isBoneSize then(
                                smBone.boneFinAPreLocPos = smBoneFinACurLoc.pos
                                smBone.boneFinBPreLocPos = smBoneFinBCurLoc.pos
                            )
                        )
                    )
                ) -- bone loop end

--                 return True

                -- two point lock
                -- apply ik to lock the end of chain
                -- creat IK for each frame that can keep the exsits pose
                endPinTarget = getnodebyname endPinTargetName exact:True
                if endPinTarget != undefined then(

                    with animate on(
                        -- set lookat constraint weight to 0, to ignore LookAt_Constraint
                        for smBone in boneLst do(
                            if smBone.children.count>0 then(
                                smBone.rotation.controller.setactive 1
                                smBone.rotation.controller.weight = #(100.0, 0.0)
                            )
                        )
--                         -- disable for better idea
--                         if isPinEndStretch then(
--                             pinEnd_endBone = boneLst[boneLst.count]
--                             pinEnd_rootBone = boneLst[1]
--                             chainLength = sm_getChainLength pinEnd_rootBone pinEnd_endBone false
--                             pinEndDistance = sm_distance endPinTarget.pos pinEnd_rootBone.pos
--                             if chainLength > 0.0 then(
--                                 chainScaleRate = pinEndDistance / chainLength
--                                 if chainScaleRate > 1.0 then(
--                                     chainObjLst = #()
--                                     for smBone in (sm_getParentLst chainObjLst pinEnd_rootBone pinEnd_endBone) do(
--                                         smBoneTX = smBone.pos.controller.value.x
--                                         smBone.pos.controller.value.x = smBoneTX * chainScaleRate
--                                     )
--                                 )
--                             )
--                         )

                        -- apply IK
                        ikCtrl = iksys.ikchain boneLst[1] boneLst[boneLst.count] "IKHiSolver"
                        ikCtrl.pos = endPinTarget.pos

                        -- update bone data with IK pose
                        for smBone in boneLst do(
                            if smBone.children.count>0 then(
                                -- restore results for next frame
                                with animate off(
                                    smBone.bonePrePos = smBone.children[1].pos
                                    smBone.bonePreDis = length(smBone.bonePrePos - smBone.bonePrePrePos)
                                    smBoneUpLoc = sm_getLoc smBone aimUpLoc_subFix
                                    smBone.bonePreUpTM = smBoneUpLoc.transform
                                    if isBoneSize then(
                                        smBone.boneFinAPreLocPos = smBoneFinACurLoc.pos
                                        smBone.boneFinBPreLocPos = smBoneFinBCurLoc.pos
                                    )
                                )
                                smBone.rotation.controller.setactive 2
                                smBone.rotation.controller.weight = #(0.0, 100.0)
                            )
                        )
                        -- remove IK
                        delete ikCtrl
                    )
                )
                -- tick time slider here, to get correct IK pose affected
                sliderTime = i

                -- update col body pq
                with animate off(
                    if isCollision and (colBodyLst != undefined) then(
                        for colBody in colBodyLst do(
                            pq = getColCapsulePQ colBody
                            colBody.prePosP = pq[1]
                            colBody.prePosQ = pq[2]
                        )
                    )
                )
            )
        )
        if i == endFrame and isLoop and isFirstPass then(
            sm_copyBoneTM boneLst
            i = startFrame
            isFirstPass = False
        )
        else(
            i += 1/subDiv
        )
--         sm_SpringMax.springProgress.value = i as integer
        ppp = 0
        qqq = 1
        if isLoop then(
            qqq = 2
            if not isFirstPass then(
                ppp = 40
            )
        )
--         print windOffset
        progressUpdate(((i-startFrame) as float/(endFrame-startFrame) as float)*80/qqq+ppp)
        -- sm_SpringMax.springProgress.value = ((i-startFrame) as integer/(endFrame-startFrame) as integer)*100
    ) -- frame loop end


    if isDebug == False then(
        -- collapse bone result
        if isWipe then subDiv = 1.0
        i = 1.0
        for smBone in boneLst do(
            -- bake animation
            collapseTransform smBone startFrame endFrame subDiv isTcb
            -- recover anim from loc
            smBoneAnimSaveLoc = sm_getLoc smBone animSaveLoc_subFix
            with animate on(
                for key in smBoneAnimSaveLoc.rotation.controller.keys do(
                    if key.time<startFrame or key.time>endFrame then( -- ignore anim in calculate range
                        at time key.time(
                            smBone.transform = smBoneAnimSaveLoc.transform
                        )
                    )
                )
            )

            -- revert bone on
            smBone.boneEnable=smBone.boneOnState

            -- remove custom attr made by script
            boneCusAttrLst = custAttributes.getDefs smBone
            if boneCusAttrLst != undefined then(
                for attr in boneCusAttrLst do(
                    if (findItem attrNameLst attr.name)>0 then(
                        custAttributes.delete smBone attr
                    )
                )
            )
            progressUpdate(i/boneLst.count*15+80)
            i+=1
        )
        progressUpdate 95
        -- remove locators
        -- do twice with try solve script failed in some max case
        try(
            for item in boneLocLst do delete item
        )catch()
        try(
            delete boneLocLst
        )catch()
    )

    -- pin end
    -- apply 2nd pass ik to pin end solid
    endPinTarget = getnodebyname endPinTargetName exact:True
    if endPinTarget != undefined then(

        -- smooth bone rotation after IK pass
        for smBone in boneLst do(
            smooth_objects_rotation smBone startFrame endFrame isTCB
        )


        with animate on(
            for i = startFrame to endFrame do(
                at time i(

                    sliderTime = i

                    if isPinEndStretch then(
                        pinEnd_endBone = boneLst[boneLst.count]
                        pinEnd_rootBone = boneLst[1]
                        chainLength = sm_getChainLength pinEnd_rootBone pinEnd_endBone false
                        pinEndDistance = distance endPinTarget pinEnd_rootBone
                        if chainLength > 0.0 then(
                            chainScaleRate = pinEndDistance / chainLength
                            if chainScaleRate > 1.0 then(
                                chainObjLst = #(pinEnd_endBone)
                                for smBone in (sm_getParentLst chainObjLst pinEnd_rootBone pinEnd_endBone) do(
                                    smBoneTX = smBone.pos.controller.value.x
                                    smBone.pos.controller.value.x = smBoneTX * chainScaleRate
                                )
                            )
                        )
                        ikCtrl = iksys.ikchain boneLst[1] boneLst[boneLst.count] "IKHiSolver"
                        ikCtrl.pos = endPinTarget.pos
                        delete ikCtrl

                    )

                    ikCtrl = iksys.ikchain boneLst[1] boneLst[boneLst.count] "IKHiSolver"
                    ikCtrl.pos = endPinTarget.pos
                    delete ikCtrl
                )
            )
        )

        -- smooth bone rotation after IK pass
        for smBone in boneLst do(
            smooth_objects_rotation smBone startFrame endFrame isTCB
        )
    )

    progressUpdate 100
)

fn sm_straightBone =(
    for obj in $Selection do(
        obj.rotation.controller.value = (quat 0 0 0 1)
    )
)

fn sm_initBoneTM boneLst =(
    for obj in boneLst do(
        try(
            obj.pos.controller.value = obj.boneInitPos
            obj.rotation.controller.value = execute obj.boneInitRot
        )
        catch()
    )
)

fn RotatePivotOnly obj rotation= (
    local rotValInv=inverse (rotation as quat)
    animate off in coordsys local obj.rotation*=RotValInv
    obj.objectoffsetrot*=RotValInv
    obj.objectoffsetpos*=RotValInv
)

fn createColCapsule obj =(
    colCapsule = Capsule radius:3 height:10 sides:8 heighttype:0
    colCapsule.xray = on
    colCapsule.renderable = off
    -- fix capsule axis to follow x
    RotatePivotOnly colCapsule (quat 0 1 0 1)
    -- lock scale
    setTransformLockFlags colCapsule #{7,8,9}

    if obj != undefined and (ClassOf obj == Biped_Object or ClassOf obj == BoneGeometry) then(
        colCapsule.name = obj.name+colBody_subFix
        colCapsule.transform = obj.transform
        colCapsule.parent = obj
        if obj.children.count > 0 then(
            if ClassOf obj == Biped_Object then(
                childTX = (obj.children[1].transform * (inverse obj.transform)).pos.x
                bipedSize = biped.getTransform obj #scale
                colCapsule.radius = (bipedSize.y+bipedSize.z)/20
            )
            if ClassOf obj == BoneGeometry then(
                childTX = obj.children[1].pos.controller.value.x
                boneSize = (obj.width+obj.height)/2
                colCapsule.radius = boneSize
            )
            colCapsule.height = childTX+2*colCapsule.radius
            colCapsule.pos.controller.value = [-colCapsule.radius,0,0]
        )
    )
    else(
        colCapsule.name = "the"+colBody_subFix
    )

    local prePosP_attr = attributes prePosP_attr (parameters main (prePosP type:#point3))
    custAttributes.add colCapsule prePosP_attr
    local prePosQ_attr = attributes prePosQ_attr (parameters main (prePosQ type:#point3))
    custAttributes.add colCapsule prePosQ_attr
    local curPosP_attr = attributes curPosP_attr (parameters main (curPosP type:#point3))
    custAttributes.add colCapsule curPosP_attr
    local curPosQ_attr = attributes curPosQ_attr (parameters main (curPosQ type:#point3))
    custAttributes.add colCapsule curPosQ_attr
    local isFastMove_attr = attributes isFastMove_attr (parameters main (isFastMove type:#boolean))
    custAttributes.add colCapsule isFastMove_attr
    local moveSpeed_attr = attributes moveSpeed_attr (parameters main (moveSpeed type:#float))
    custAttributes.add colCapsule moveSpeed_attr

    colCapsule
)


fn sm_createColPlane =(

    -- remove exist wind cone
    if (getObjWithName colPlane_subFix) != undefined then(
        delete (getObjWithName colPlane_subFix)[1]
    )
    colPlane = plane name:("the"+colPlane_subFix)
    colPlane.xray = on
    colPlane.renderable = off
    colPlane.backfacecull = on
    colPlane.lengthsegs = 1
    colPlane.widthsegs = 1
    colPlane.length = 50.0
    colPlane.width = 50.0
    -- lock scale
    setTransformLockFlags colPlane #{7,8,9}

    select colPlane
)



-------------------------------
-- UI
-------------------------------
floaterWidth = 388
floaterHeight = 464
paypalLink = @"https://www.paypal.me/Yanbin/10usd"
zhTutorialsLink = @"https://animbai.com/zh/2018/08/18/spring-max-tutorial/"
enTutorialsLink = @"https://animbai.com/2018/08/18/spring-max-tutorial/"
downloadLink = @"https://animbai.com/2018/08/12/spring-max/"
linkedLink = @"https://www.linkedin.com/in/baiyanbin/"
versionCheckLink = @"http://animbai.com/springmaxver/"

scriptPath = getFileNamePath(getThisScriptFilename())
iconPath = scriptPath + @"springMax_icons\"
-- iniFile = iconPath + "springMax.ini"
-- iniLan = GetINISetting iniFile "Basic" "Lan"

sm_SpringMax = undefined
fn springMax_Launcher =(
    -- get select bones, ignore root bone
    boneLst = for obj in $Selection where (ClassOf obj == BoneGeometry) and (obj.parent!=undefined) collect obj
    if boneLst.count>0 then(
        if sm_SpringMax.springKeyRange_radio.state == 1 then(
            startFrame = animationRange.start
            endFrame = animationRange.end
        )
        else(
            startFrame = sm_SpringMax.springTimeFrom_spinner.value as time
            endFrame = sm_SpringMax.springTimeTo_spinner.value as time
        )
        if sm_SpringMax.springColActive_checkbox.state then(
            subDiv = sm_SpringMax.springTimeSubFrame_spinner.value as float
        )
        else(
            subDiv = 1.0
        )
        -- creat proxy for animate value
        SMProxy = sm_createSMProxy(sm_SpringMax)
        SMProxy_spring = SMProxy.modifiers[#Spring_Max_Setting].springAttr.spring
        SMProxy_twist = SMProxy.modifiers[#Spring_Max_Setting].springAttr.twist
        SMProxy_flex = SMProxy.modifiers[#Spring_Max_Setting].springAttr.flex
        SMProxy_mass = SMProxy.modifiers[#Spring_Max_Setting].springAttr.mass

        spring_bend = 1 - SMProxy_spring
        spring_twist = 1 - SMProxy_twist
        extend = SMProxy_flex
        tension = sm_SpringMax.springTension_spinner.value
        mass = SMProxy_mass
        isWipe = sm_SpringMax.springTimeWipe_checkbox.state
        isLoop = sm_SpringMax.springTimeLoop_checkbox.state
        isTcb = sm_SpringMax.springTcb_checkbox.state
        isCollision = sm_SpringMax.springColActive_checkbox.state
        isFastMove = sm_SpringMax.springColFast_checkbox.state
        fastMoveNum = sm_SpringMax.springColFastNum_spinner.value
        colBodyLst = getObjWithName colBody_subFix
        colPlaneLst = getObjWithName colPlane_subFix
        isBoneSize = sm_SpringMax.springColBoneSize_checkbox.state
        isPinEndStretch = sm_SpringMax.springPinEndStretch_checkbox.state

        isWind=False
        windObj=undefined
        if (getObjWithName windCone_subFix) != undefined then(
            isWind = True
            windObj = (getObjWithName windCone_subFix)[1]
        )

        isExp=False
        expObj=undefined
        if (getObjWithName expCtrl_subFix) != undefined then(
            isExp = True
            expObj = (getObjWithName expCtrl_subFix)[1]
        )

        isTargetFrame = sm_SpringMax.springIsTargetFrame_checkbox.state
        targetFrame = sm_SpringMax.springTargetFrame_spinner.value
        -- pose match
        isPoseMatch = sm_SpringMax.springPoseMatch_checkbox.state
        poseMatchSpace = "Local"
        if sm_SpringMax.springPoseMatch_radio.state == 1 then poseMatchSpace = "World"

        slidertime = startFrame
        -- restore bone init pose before calculation
        -- sm_restoreInitPose boneLst

        sm_clearAnimSaveLoc()

--         with redraw off(
            progressStart uistrLst[2][2]
            springMax_Main boneLst spring_bend spring_twist extend tension mass startFrame endFrame isTargetFrame targetFrame subDiv isWipe isLoop isTcb isCollision isFastMove fastMoveNum isBoneSize colBodyLst colPlaneLst isWind windObj isExp expObj isPoseMatch isPinEndStretch poseMatchSpace SMProxy
            progressEnd()
--         )

        sm_removeExistProxy smProxy_subFix

        gc()
    )

    -- set spam word
    if uistr=="CHN" then sm_SpringMax.springSpam_lb.caption = spamWordCHN[(random 1 5)]
    else sm_SpringMax.springSpam_lb.caption = spamWord[(random 1 5)]
)

lang=sysinfo.getmaxlanguage()
uistr="ENG"

if lang[3]=="CHS" then uistr="CHN"
if lang[3]=="JPN" then uistr="JPN"

if not (hasINISetting (getMAXIniFile()) "Spring Max" "Language") do(
    setINISetting (getMAXIniFile()) "Spring Max" "Language" uistr
)
uistr = getINISetting (getMAXIniFile()) "Spring Max" "Language"

uistrLst_CHN = #(\
                #(1,"Spring Max","                  白严宾","- 施工中 -"),\
                #(2,"飘带计算:","算飘带"," 名称重复, 退出计算!"," 丢失, 退出计算!"),\
                #(3,"打赏","需要你的支持!","Spring Max 是一款免费工具, 你可以无偿使用它的所有功能! 然而, 如果它使你的工作轻松了一些的话...","                                 请我喝杯奶茶怎么样？"),\
                #(4,"摆动:","飘带摆动幅度，数值越大结果越柔软"),\
                #(5,"拧转:","拧转效果（X轴）的柔软度，数值越大拧得越多"),\
                #(6,"伸缩:","给骨骼链增加弹性，以产生拉伸和挤压的效果"),\
                #(7,"张力:","链条张力，用于定义由碰撞造成的弯曲如何在链条中传递。\n适当设置可减少碰撞计算结果的抖动和穿插。"),\
                #(8,"关键帧设置"),\
                #(9,"当前        ","","从:","到:"),\
                #(10,"循环","计算两次，以获得循环动画"),\
                #(11,"拆帧:","将一帧拆分成若干碎帧来进行细分计算，以捕捉非常快速移动的碰撞体\n如设为5，则会以1/5帧为步进来计算\n相应的会成倍增加计算时间，但能获得更精细的效果"),\
                #(12,"清理碎帧","在计算完成后清理不在整数上的细碎关键帧"),\
                #(13,"TCB","将计算结果转换为TCB旋转，可以减少链条在两帧之间抖动"),\
                #(14,"碰撞设置"),\
                #(15,"启用","勾选后会计算飘带与场景中胶囊体或平面的碰撞"),\
                #(16,"快速移动","如果胶囊体附加在快速移动的物体上，比如奔跑中的双腿与裙子的碰撞。勾选此项时，可以减少穿插。\n注意：在碰撞体移动较慢时勾选此项，可能会造成结果抖动。"),\
                #(17,"+ 胶囊","创建一个碰撞胶囊体，如果不选择骨骼，则在原点生成，如选择骨骼，则跟骨骼大小位置对齐\n注意：请勿通过缩放来调整胶囊大小，也不要改变名称，否则可能造成计算错误"),\
                #(18,"+ 平面","创建一个碰撞平面\n注意：请勿改变名称"),\
                #(19,"清理","清除所有碰撞物体"),\
                #(20,"骨骼姿态"),\
                #(21,"回退","撤销计算结果，返回计算前状态"),\
                #(22,"拉直","将骨骼链拉直"),\
                #(23,"复制","复制当前姿态"),\
                #(24,"粘贴","粘帖复制的姿态"),\
                #(25,"高级"),\
                #(26,"关联","关联选中的骨骼，使其能在计算时相互影响","闭环","创建封闭的关联环"),\
                #(27,"拾取","创建拾取控制器来拎起骨骼"),\
                #(28,"外力"),\
                #(29,"风","创建一个风力物体"),\
                #(30,"爆炸","创建一个爆炸物体"),\
                #(31,"计 算","开始计算选中骨骼"),\
                #(32,"有新版本！","B站中文教程","YouTube英文教程","界面语言","作者简介","工具栏命令"),\
                #(33,"指定目标帧:","指定一个关键帧，使骨骼计算结果向其靠拢\n如不指定，则默认向起始帧靠拢\n该功能主要是为了解决从动画中间开始计算时，骨骼仍能正确向最终姿势靠拢","指定目标帧"),\
                #(34,"灵敏度","碰撞体速度达到多少时，会触发骨骼全力追赶它\n数值越小，灵敏度越高，但也可能造成更多的抖动"),\
                #(35,"更多内容，请访问我的网站:","animbai.com"),\
                #(36,"骨骼形状","在计算碰撞时考虑骨骼鳍片的尺寸\n仅对胶囊体有效"),\
                #(37,"姿态拟合","使计算结果尽量匹配骨骼已有的动画","世界","局部"),\
                #(38,"惯性","惯性晃动效果的强度，数值越大，晃动越大"),\
                #(39,"末端固定","创建一个末端固定控制器"),\
                #(40,"拉长","在需要时拉长，以保持末端固定在目标点"),\
                #()\
                )
uistrLst_ENG = #(\
                #(1,"Spring Max","                Yanbin Bai","  - WIP -"),\
                #(2,"Spring Calculating:","Spring Max"," has duplication name, quit calculation!"," missing, quit calculation!"),\
                #(3,"Donate","Need Your Supports!","Spring Max is free for everyone, which means you can use FULL FUNCTION as FREE! However if this tool make your life easier...","                   HOW about bought me a cup of coffee?"),\
                #(4,"Spring:","How soft the spring is, bigger value, softer result."),\
                #(5,"Twist:","How soft the twist (X-axis) is."),\
                #(6,"Flex:","Flexibility of spring, which can produce strach and squash animation."),\
                #(7,"Tension:","Tension of the chain, means how much the force of bend will be path through the chain.\nCan reduce poping and clip through of collision result."),\
                #(8,"Key Setting"),\
                #(9,"Active   ","","From","To"),\
                #(10,"Loop","Will caculate twice to get looped result."),\
                #(11,"Sub:","How many sub frame that will be go through during 1 frame, that for capture really fast move collision body.\nIf set as 5, means will step as 1/5 frame to calculation.\nWill increase calculation time by times"),\
                #(12,"Wipe Sub","Remove precision keys on sub frame after calculation."),\
                #(13,"TCB","Bake rotation as TCB. Can reduce jittery in-between frame."),\
                #(14,"Collision Setting"),\
                #(15,"Active","Active collision calculation with capsule body or plane in scene."),\
                #(16,"Fast Move","Click on this if capsule attach on a fast move bone, like sprinting legs, to reduce the clip through.\nNote: May cause more poping if capsule moving slowly."),\
                #(17,"+ Body","Add a collision capsule at original point if select notion, or add a capsule match with selected bone.\nDO NOT change capsule shape with scale function and change name, otherwise may cause wrong result."),\
                #(18,"+ Plane","Add a collision plane at original point\nDO NOT change name"),\
                #(19,"Clear","Remove all collison object in scene"),\
                #(20,"Bone Pose"),\
                #(21,"Roll Back","Cancel calculation, revert back to original animation."),\
                #(22,"Straight","Set joint chain as straight"),\
                #(23,"Copy","Copy current bone poses"),\
                #(24,"Paste","Paste copied poses"),\
                #(25,"Advance"),\
                #(26,"Connect","Connect selected bone that make them can interact each other","Close","Make a close relation rim"),\
                #(27,"Pick","Create a pick controller to lift up bone chain"),\
                #(28,"Force"),\
                #(29,"Wind","Create a wind object"),\
                #(30,"Explosion","Create a explotion object"),\
                #(31,"Apply","Start calculate selected bones."),\
                #(32,"New Version Available!","Tutorials on bilibili","Tutorials on YouTube","Set Language","Author Profile","Toolbar Command"),\
                #(33,"Target Frame:","Assign a frame as reference that calculation should move towards.\nIf set False, then will use start frame as target.\nCan use this let bone chain still back to correct pose if start calculation from middle of animation.","Target Frame"),\
                #(34,"Sensitivity","How fast the collision body moves that will trigger bone trying to catch it as close as possiable.\nSmaller the number is more sensitive the bone will be, more jittery may cause as well."),\
                #(35,"To know more, check my site:","animbai.com"),\
                #(36,"Bone Shape","Consider bone fins size when calculate collision.\nOnly effect with capsule body."),\
                #(37,"Pose Match","Try to match exsit animation of bone","World","Local"),\
                #(38,"Inertia","Inertia swing strength fo the chain, bigger value, bouncer result"),\
                #(39,"Pin End","Creat a controller to pin chain end"),\
                #(40,"Ext.","Stretch chain when needed, to make end can reach pin point"),\
                #()\
                )
uistrLst_JPN = #(\
                #(1,"Spring Max","                Yanbin Bai","  - WIP -"),\
                #(2,"計算:","Spring Max","名前の重複があります。処理を中止します!","対象が見つかりません。 処理を中止します!"),\
                #(3,"寄付する","サポートを歓迎します！","Spring Max はすべての機能を無料で使用することができます。 気に入ってくれたなら…","開発者にコーヒー代をカンパしてくれませんか？"),\
                #(4,"Spring:","スプリングの柔らかさ, 値が大きいほど柔らかくなります"),\
                #(5,"Twist:","ツイスト(X軸) "),\
                #(6,"Flex:","スクワッシュ＆ストレッチ"),\
                #(7,"Tension:","チェーンのテンション, ベンドの伝わりやすさ。\nこの値を調整することでコリジョン検知の異常を軽減することができます"),\
                #(8,"キー"),\
                #(9,"現在範囲","","開始","終了"),\
                #(10,"ループ","ループさせるために計算を二度行います"),\
                #(11,"サブ:","1フレームあたりの計算に使用するサブフレーム数。動きが速い場合は高い値を設定します。\n例：サブフレームを5にすると1/5フレームごとに計算が行われます。\n値を大きくするほど計算量が増えます"),\
                #(12,"サブフレーム削除","計算終了時にサブフレームキーを削除します"),\
                #(13,"TCB","回転にTCBを使用します。フレーム間のジッタ（揺らぎ）を軽減することができます"),\
                #(14,"衝突"),\
                #(15,"有効","コリジョン計算を有効化します。コリジョン対象はカプセルか平面としてシーン内に設置できます"),\
                #(16,"高速","ボーンの動きが速く、コリジョンオブジェクトを突き抜けてしまう場合にクリックしてください。\nNote: この設定はコリジョンオブジェクトの移動が遅い場合に意図しない結果につながる可能性があります"),\
                #(17,"+ カプセル","コリジョン用のカプセルを原点に生成します。ボーンを選択して実行すると選択したボーンの大きさにマッチしたカプセルを生成します。\n[注意]生成されたオブジェクトはパラメータ操作以外の方法で変形しないでください。またオブジェクト名も変更しないでください。予期しない結果になります"),\
                #(18,"+ 平面","コリジョン平面を原点に生成します。\n生成されたオブジェクトの名前を変更しないでください"),\
                #(19,"クリア","シーン内のすべてのコリジョンオブジェクトを削除します"),\
                #(20,"ポーズ"),\
                #(21,"元に戻す","計算をキャンセルし、元の状態に戻します"),\
                #(22,"直線化","チェーンを直線状にします"),\
                #(23,"コピー","現在のボーンポーズをコピーします"),\
                #(24,"貼付","コピーしたボーンポーズを貼り付けます"),\
                #(25,"連動"),\
                #(26,"接続","選択したボーンリンクし、互いに影響し合うようにします","Close","リンク終端が先頭にリンクするように閉じます"),\
                #(27,"ピック","ボーンチェーンを持ち上げるピックコントローラを生成します"),\
                #(28,"force"),\
                #(29,"風","風を生成します"),\
                #(30,"爆発","爆発を生成します"),\
                #(31,"実行","選択されたボーンの計算を開始します"),\
                #(32,"新しいバージョンがあります!","チュートリアル（bilibili）","チュートリアル（YouTube）","言語設定","開発者プロフィール","ツールバーコマンド"),\
                #(33,"対象Frame:","目的ポーズにするフレームを指定します\nOFFにすると開始フレームを目的ポーズとして使用します","対象フレーム"),\
                #(34,"感度","コリジョンオブジェクトの速さによって正しく検知できるように値を調整する必要があります\n値を小さくするほどボーンの感度が上がりますが、ジッタが増える可能性があります"),\
                #(35,"詳しくはWebサイトを見てください:","animbai.com"),\
                #(36,"形状","ボーンの形状を計算に含めます。\nカプセル状の場合のみ有効"),\
                #(37,"マッチ","既存のキーフレームのポーズを参照して計算を行います","ワールド","ローカル"),\
                #(38,"Inertia","Inertia swing strength fo the chain, bigger value, bouncer result"),\
                #(39,"Pin End","Creat a controller to pin chain end"),\
                #(40,"Ext.","Stretch chain when needed, to make end can reach pin point"),\
                #()\
                )
uistrLst=uistrLst_ENG
if uistr=="CHN" then uistrLst=uistrLst_CHN
if uistr=="JPN" then uistrLst=uistrLst_JPN
linkColor = (color 0 250 200)
rollout sm_Donate uistrLst[3][2] width:376 height:284
(
    groupBox sm_grp1 uistrLst[3][3] pos:[5,13] width:364 height:255
    label sm_lbl1 uistrLst[3][4] pos:[32,41] width:312 height:39
    label sm_lbl2 uistrLst[3][5] pos:[32,77] width:312 height:24
    bitmap sm_alipay_pic "alipay_pic" pos:[14,108] width:120 height:120 fileName:(iconPath+"ali_pay.png")
    bitmap sm_Wechat_pic "Wechat_pic" pos:[240,108] width:120 height:120 fileName:(iconPath+"wechat_pay.png")
    button sm_paypal_btn "paypal" pos:[156,140] width:64 height:64 images:#(iconPath+"paypal.png", undefined, 1,1,1,1,1,True) iconSize:[64,64]
    label sm_lbl3 uistrLst[35][2] pos:[75,240] width:312 height:24
    hyperLink web uistrLst[35][3] pos:[235,240] color:linkColor hoverColor:linkColor visitedColor:linkColor address:"http://animbai.com/"

    on sm_paypal_btn pressed  do(
        shellLaunch paypalLink ""
    )
)


rollout sm_SpringMax uistrLst[2][3] width:376 height:404
(
    spinner springBend_spinner uistrLst[4][2] toolTip:uistrLst[4][3] pos:[42,16] width:52 height:16 range:[0,1,0.7] scale:0.1 controller:(Bezier_Float())
    spinner springTwist_spinner uistrLst[5][2] toolTip:uistrLst[5][3] pos:[128,16] width:52 height:16 range:[0,1,0.7] scale:0.1 controller:(Bezier_Float())
    spinner springFlex_spinner uistrLst[6][2] toolTip:uistrLst[6][3] pos:[212,16] width:52 height:16 range:[0,1,0] scale:0.1 controller:(Bezier_Float())
    spinner springTension_spinner uistrLst[7][2] toolTip:uistrLst[7][3] pos:[306,16] width:52 height:16 range:[0,1,0.5] scale:0.1 visible:False
    spinner springMass_spinner uistrLst[38][2] toolTip:uistrLst[38][3] pos:[306,16] width:52 height:16 range:[0,1,0.0] scale:0.1 controller:(Bezier_Float())
    groupBox grp1 uistrLst[8][2] pos:[13,47] width:348 height:81
    radioButtons springKeyRange_radio "" pos:[45,72] width:155 height:16 labels:#(uistrLst[9][2], uistrLst[9][3]) columns:2
    spinner springTimeFrom_spinner uistrLst[9][4] pos:[150,72] width:64 height:16 enabled:false range:[-99999,99999,0] type:#integer scale:1
    spinner springTimeTo_spinner uistrLst[9][5] pos:[234,72] width:64 height:16 enabled:false range:[-99999,99999,1] type:#integer scale:1
    checkbox springTimeLoop_checkbox uistrLst[10][2] toolTip:uistrLst[10][3] pos:[310,72] width:46 height:16 enabled:true checked:false
    spinner springTimeSubFrame_spinner uistrLst[11][2] toolTip:uistrLst[11][3] pos:[40,102] width:42 height:16 enabled:false range:[1,100,1] type:#integer scale:1
    checkbox springTimeWipe_checkbox uistrLst[12][2] toolTip:uistrLst[12][3] pos:[102,102] width:70 height:16 enabled:false checked:true visible:False
    checkbox springTcb_checkbox uistrLst[13][2] toolTip:uistrLst[13][3] pos:[316,102] width:42 height:16 enabled:true checked:true
    groupBox grp2 uistrLst[14][2] pos:[16,144] width:344 height:64
    checkbox springColActive_checkbox uistrLst[15][2] toolTip:uistrLst[15][3] pos:[30,172] width:50 height:16 enabled:true checked:false
    checkbox springColFast_checkbox uistrLst[16][2] toolTip:uistrLst[16][3] pos:[90,172] width:70 height:16 enabled:false checked:true visible:False
    spinner springColFastNum_spinner uistrLst[34][2] toolTip:uistrLst[34][3] pos:[120,160] width:70 height:16 range:[0,100,1.5] scale:0.1 enabled:false
    checkbox springColBoneSize_checkbox uistrLst[36][2] toolTip:uistrLst[36][3] pos:[110,182] width:78 height:16 enabled:false checked:false
    button springColAddBody_btn uistrLst[17][2] toolTip:uistrLst[17][3] pos:[200,160] width:40 height:40 images:#(iconPath+"addCapsule.png", iconPath+"addCapsule_a.png", 1,1,1,1,1,True) border:False
    button springColAddPlane_btn uistrLst[18][2] toolTip:uistrLst[18][3] pos:[250,160] width:40 height:40 images:#(iconPath+"addPlane.png", iconPath+"addPlane_a.png", 1,1,1,1,1,True) border:False
    button springColClear_btn uistrLst[19][2] toolTip:uistrLst[19][3] pos:[300,160] width:40 height:40 images:#(iconPath+"clearCapsule.png", iconPath+"clearCapsule_a.png", 1,1,1,1,1,True) border:False
    groupBox grp3 uistrLst[20][2] pos:[16,224] width:128 height:112
    button springBoneInit_btn uistrLst[21][2] toolTip:uistrLst[21][3] pos:[24,248] width:54 height:32 enabled:false
    button springBoneStraight_btn uistrLst[22][2] toolTip:uistrLst[22][3] pos:[24,294] width:54 height:32
    button springBoneCopy_btn uistrLst[23][2] toolTip:uistrLst[23][3] pos:[82,248] width:54 height:32
    button springBonePaste_btn uistrLst[24][2] toolTip:uistrLst[24][3] pos:[82,294] width:54 height:32
    groupBox grp4 uistrLst[25][2] pos:[152,224] width:96 height:112
--     label springTmp_lb uistrLst[1][4] pos:[175,270] width:50 height:24
    checkbox springIsTargetFrame_checkbox uistrLst[33][2] toolTip:uistrLst[33][3] pos:[172,102] width:86 height:16 enabled:true checked:false
    spinner springTargetFrame_spinner pos:[262,102] width:46 height:16 range:[-99999,99999,0] type:#integer scale:1 enabled:False
    button springConnect_btn uistrLst[26][2] toolTip:uistrLst[26][3] pos:[158,248] width:32 height:32 images:#(iconPath+"connect.png", undefined, 1,1,1,1,1,False) border:False visible:True
    checkbox springConnectClose_checkbox uistrLst[26][4] toolTip:uistrLst[26][5] pos:[196,256] width:44 height:16 visible:True checked:true
    button springPinEnd_btn uistrLst[39][2] toolTip:uistrLst[39][3] pos:[158,290] width:32 height:32 images:#(iconPath+"pinEnd.png", iconPath+"pinEnd_a.png", 1,1,1,1,1,True) border:False visible:True
    checkbox springPinEndStretch_checkbox uistrLst[40][2] toolTip:uistrLst[40][3] pos:[196,300] width:44 height:16 visible:True checked:True
    checkbox springPoseMatch_checkbox uistrLst[37][2] toolTip:uistrLst[37][3] pos:[92,102] width:76 height:16 checked:False
    radioButtons springPoseMatch_radio "" pos:[153,316] width:60 height:16 labels:#(uistrLst[37][4], uistrLst[37][5]) columns:2 enabled:False visible:False
--     button springPick_btn uistrLst[27][2] toolTip:uistrLst[27][3] pos:[162,293] width:54 height:32 images:#(iconPath+"ctrl_bake.png", undefined, 1,1,1,1,1,False)
--     label springCtrlBake_lb "Bake" pos:[204,300] width:32 height:32
    groupBox grp5 uistrLst[28][2] pos:[256,224] width:104 height:64
    button springWind_btn uistrLst[29][2] toolTip:uistrLst[29][3] pos:[264,248] width:36 height:36 images:#(iconPath+"wind.png", iconPath+"wind_a.png", 1,1,1,1,1,True) border:False
--     label springCtrlWind_lb "Wind" pos:[290,225] width:32 height:32
    button springExp_btn uistrLst[30][2] toolTip:uistrLst[30][3] pos:[318,248] width:32 height:32 images:#(iconPath+"expWind.png", iconPath+"expWind_a.png", 1,1,1,1,1,True) border:False
--     label springCtrlExp_lb "Explosion" pos:[290,260] width:64 height:32
    button springApply_btn uistrLst[31][2] toolTip:uistrLst[31][3] pos:[260,294] width:98 height:42  border:True
    button springMiscUpdate_btn "update" toolTip:uistrLst[32][2] pos:[16,344] width:28 height:28 images:#(iconPath+"update.png", iconPath+"update_a.png", 1,1,1,1,1,True) visible:False border:False
    button springMiscBili_btn "bili" toolTip:uistrLst[32][3] pos:[202,344] width:28 height:28 images:#(iconPath+"bilibili.png", undefined, 1,1,1,1,1,False) border:False
    button springMiscYoutu_btn "You" toolTip:uistrLst[32][4] pos:[236,344] width:28 height:28 images:#(iconPath+"youtube.png", undefined, 1,1,1,1,1,True) border:False
    button springMiscLink_btn "Link" toolTip:uistrLst[32][6] pos:[268,344] width:28 height:28 images:#(iconPath+"linkedin.png", undefined, 1,1,1,1,1,True) border:False
    button springMiscLan_btn "Lan" toolTip:uistrLst[32][5] pos:[300,344] width:28 height:28 images:#(iconPath+"language.png", undefined, 1,1,1,1,1,True) border:False
    button springMiscShelf_btn "Shelf" toolTip:uistrLst[32][7] pos:[332,344] width:28 height:28 images:#(iconPath+"Shelf.png", undefined, 1,1,1,1,1,True) border:False
--     progressBar springProgress "" pos:[16,404] width:344 height:24
--     label springProgress_lb "0%" pos:[182,408]
    button spingLanCHN_btn "CHN" pos:[300,258] width:28 height:28 images:#(iconPath+"Chinese.png", undefined, 1,1,1,1,1,True) visible:False
    button spingLanENG_btn "ENG" pos:[300,286] width:28 height:28 images:#(iconPath+"english.png", undefined, 1,1,1,1,1,True) visible:False
    button spingLanJPN_btn "JPN" pos:[300,315] width:28 height:28 images:#(iconPath+"japanese.png", undefined, 1,1,1,1,1,True) visible:False
    label springSpam_lb "" pos:[160,384] width:312 height:24

    fn updateRollBackButtonState =(
        if sm_getAnimSaveLoc() != undefined then springBoneInit_btn.enabled = true
        else springBoneInit_btn.enabled = false
    )

    fn sm_setLan lanName =(
        -- set lan
        setINISetting (getMAXIniFile()) "Spring Max" "Language" lanName
        try(closeRolloutFloater springMaxWindow)catch()
        execute("fileIn (@\""+(getThisScriptFilename())+"\")")
    )

    fn sm_updateTimeRange =(
        animationRange = interval springTimeFrom_spinner.value springTimeTo_spinner.value
    )

    fn sm_toggleLanUI =(
        spingLanCHN_btn.visible = not spingLanCHN_btn.visible
        spingLanENG_btn.visible = not spingLanENG_btn.visible
        spingLanJPN_btn.visible = not spingLanJPN_btn.visible
        springApply_btn.visible = not springApply_btn.visible
        springWind_btn.visible = not springWind_btn.visible
        springExp_btn.visible = not springExp_btn.visible
    )

    fn readWebPage urlLink timeOut =(
        pageData = ""
        try(
            requestClass = dotNetClass "System.Net.WebRequest"
            request = requestClass.Create(urlLink)
            request.Method = "GET"
            request.Timeout = timeOut

            response = request.getResponse()
            -- response is an HttpWebResponse
            responseStream = response.GetResponseStream()

            encodingClass = dotNetClass "System.Text.Encoding"
            encoding = encodingClass.GetEncoding "utf-8"

            readStream = dotNetObject "System.IO.StreamReader" responseStream encoding
            pageData = readStream.ReadToEnd()
            readStream.Close()
            response.Close()
        )catch()

        pageData
    )

    fn getPageWord pageData keyWord =(
        skipToString pageData keyWord
        a = readLine pageData errorAtEOF:false
--         print a
--         b = (filterString a keyWord)[1]
--         print b
        c = findString a keyWord
        substring a 1 (c-1)
    )


    on sm_SpringMax open do(
        version = 0.0
        try(
            pageData = (readWebPage versionCheckLink 7000) as stringStream
            pageDataString = pageData as string
        )
        catch()
        if pageDataString != "" and (findString pageDataString "|SpringMax|")!= undefined then(
            spamWord = #()
            spamWordCHN = #()
            version = (getPageWord pageData "|SpringMax|") as float
            for j = 1 to 5 do(
                spamKeyWord = "|spam"+(j as string)+"|"
                append spamWord (getPageWord pageData spamKeyWord)
            )
            for j = 1 to 5 do(
                spamKeyWordCHN = "|spam"+(j as string)+"chn|"
                append spamWordCHN (getPageWord pageData spamKeyWordCHN)
            )
            -- set spam word
            if uistr=="CHN" then(
                springSpam_lb.caption = spamWordCHN[(random 1 5)]
            )
            else springSpam_lb.caption = spamWord[(random 1 5)]
        )
        else print "Fail to load page!"

        if version > sm_ver then(
            springMiscUpdate_btn.visible = True
        )

        updateRollBackButtonState()
    )

    on springKeyRange_radio changed state do(
        a = springKeyRange_radio.state == 2
        springTimeFrom_spinner.enabled = a
        springTimeFrom_spinner.value = animationRange.start
        springTimeTo_spinner.enabled = a
        springTimeTo_spinner.value = animationRange.end

    )

    on springTimeFrom_spinner changed val do(
        if springTimeTo_spinner.value <= springTimeFrom_spinner.value then(
            springTimeTo_spinner.value = springTimeFrom_spinner.value+1
        )
--         sm_updateTimeRange()
    )

    on springTimeTo_spinner changed val do(
        if springTimeTo_spinner.value <= springTimeFrom_spinner.value then(
            springTimeFrom_spinner.value = springTimeTo_spinner.value-1
        )
--         sm_updateTimeRange()
    )

    on springColActive_checkbox changed state do(
        springTimeSubFrame_spinner.enabled = springColActive_checkbox.state
        springTimeWipe_checkbox.enabled = springColActive_checkbox.state
        springColFast_checkbox.enabled = springColActive_checkbox.state
        springColFastNum_spinner.enabled = springColActive_checkbox.state
--         springTension_spinner.enabled = springColActive_checkbox.state
        springColBoneSize_checkbox.enabled = springColActive_checkbox.state
    )

    on springPoseMatch_checkbox changed state do(
        springPoseMatch_radio.enabled = springPoseMatch_checkbox.state
    )

    on springIsTargetFrame_checkbox changed state do(
        springTargetFrame_spinner.enabled = springIsTargetFrame_checkbox.state
    )

    on springColAddBody_btn pressed  do(
        if $Selection.count == 0 then(createColCapsule undefined)
        else(
            bodyLst = #()
            for obj in $Selection where (ClassOf obj == Biped_Object or ClassOf obj == BoneGeometry) do(
                append bodyLst (createColCapsule obj)
            )
            select bodyLst
        )
    )
    on springColAddPlane_btn pressed  do(
        sm_createColPlane()
    )

    on springColClear_btn pressed  do(
        try(
            delete (getObjWithName colBody_subFix)
        )catch()
        try(
            delete (getObjWithName colPlane_subFix)
        )catch()
    )
    on springBoneInit_btn pressed do(
        sm_revertBoneAnim()
        -- sm_initBoneTM $Selection
        updateRollBackButtonState()
    )
    on springBoneStraight_btn pressed  do(
        sm_straightBone()
    )
    on springBoneCopy_btn pressed  do(
        sm_copyBoneTM $Selection
    )
    on springBonePaste_btn pressed  do(
        sm_pasteBoneTM $Selection
    )
    on springConnect_btn pressed  do(
        isClose = springConnectClose_checkbox.state
        sm_connectBone $Selection isClose
    )
--     on springPick_btn pressed  do(
    
--     )
    on springPinEnd_btn pressed do(
        sm_creatPinPoint()
    )

    on springWind_btn pressed  do(
        sm_createWindCone()
    )
    on springExp_btn pressed  do(
        sm_createExpCtrl()
    )
    on springApply_btn pressed  do(
        springMax_Launcher()
        updateRollBackButtonState()
    )
    on springMiscUpdate_btn pressed  do(
        shellLaunch downloadLink ""
    )
    on springMiscBili_btn pressed  do(
        shellLaunch zhTutorialsLink ""
    )
    on springMiscYoutu_btn pressed  do(
        shellLaunch enTutorialsLink ""
    )
    on springMiscLan_btn pressed  do(
        sm_toggleLanUI()
    )
    on springMiscLink_btn pressed  do(
        shellLaunch linkedLink ""
    )
    on springMiscShelf_btn pressed  do(
        actionMan.executeAction 0 "40472"
        print("fileIn (@\""+(getThisScriptFilename())+"\")")
    )
    on spingLanCHN_btn pressed  do(
        sm_toggleLanUI()
        sm_setLan "CHN"
    )
    on spingLanENG_btn pressed  do(
        sm_toggleLanUI()
        sm_setLan "ENG"
    )
    on spingLanJPN_btn pressed  do(
        sm_toggleLanUI()
        sm_setLan "JPN"
    )
    on sm_SpringMax close do(
        sm_clearAnimSaveLoc()
--         sm_removeExistProxy smProxy_subFix
    )
)

fn sm_init_UI =(
    with animate off(
        sm_SpringMax.springBend_spinner.value = 0.7
        sm_SpringMax.springTwist_spinner.value = 0.7
        sm_SpringMax.springFlex_spinner.value = 0.0
        sm_SpringMax.springTension_spinner.value = 0.5
        sm_SpringMax.springMass_spinner.value = 0.0

    )
)

-- kill exist tool window
try(closeRolloutFloater springMaxWindow)catch()
-- -- creat proxy

springMaxWindow = newRolloutFloater (uistrLst[1][2]+" "+(sm_ver as string)+uistrLst[1][3]) floaterWidth floaterHeight 360 160

addRollout sm_Donate springMaxWindow
addRollout sm_SpringMax springMaxWindow
sm_Donate.open = False
sm_SpringMax.open = True
sm_init_UI()
"""
From the selected root joint, walk the hierarchy level by level,
pair joints by "_L_" / "_R_", and make their world translate symmetric.
"""

from maya import cmds

_WINDOW = "sb_symmetrize_joint_translate_win"


def short_name(node):
    return node.split("|")[-1].split(":")[-1]


def counterpart_name(name):
    """Return the L/R counterpart short name, or None."""
    if "_L_" in name:
        return name.replace("_L_", "_R_", 1)
    if "_R_" in name:
        return name.replace("_R_", "_L_", 1)
    if "_l_" in name:
        return name.replace("_l_", "_r_", 1)
    if "_r_" in name:
        return name.replace("_r_", "_l_", 1)
    return None


def is_left(name):
    return "_L_" in name or "_l_" in name


def is_center(name):
    return "_C_" in name or "_c_" in name


def namespace_of(node):
    leaf = node.split("|")[-1]
    if ":" in leaf:
        return leaf.rsplit(":", 1)[0] + ":"
    return ""


def all_joints_under(root):
    joints = [root] if cmds.nodeType(root) == "joint" else []
    descendants = cmds.listRelatives(root, allDescendents=True, type="joint", fullPath=True) or []
    joints.extend(descendants)
    return joints


def joint_depth(node, root):
    return node.count("|") - root.count("|")


def collect_pairs(nodes, root):
    """Match L/R by name anywhere under root (not only the same BFS level)."""
    by_short = {}
    for node in nodes:
        name = short_name(node)
        by_short.setdefault(name, node)

    pairs = []
    used = set()
    unmatched = []
    for name, node in by_short.items():
        if name in used:
            continue
        other_name = counterpart_name(name)
        if not other_name:
            continue
        other = by_short.get(other_name)
        if other is None:
            ns = namespace_of(node)
            hits = cmds.ls(ns + other_name, type="joint", long=True) or []
            if not hits:
                hits = cmds.ls(other_name, type="joint", long=True) or []
            other = hits[0] if hits else None
        if other:
            left, right = (node, other) if is_left(name) else (other, node)
            key = (short_name(left), short_name(right))
            if key in used:
                continue
            pairs.append((left, right))
            used.add(key)
            used.add(name)
            used.add(other_name)
        else:
            unmatched.append(node)

    pairs.sort(key=lambda pair: min(joint_depth(pair[0], root), joint_depth(pair[1], root)))
    return pairs, unmatched


def mirror_xyz(pos, axis="x"):
    x, y, z = pos
    axis = axis.lower()
    if axis == "x":
        return [-x, y, z]
    if axis == "y":
        return [x, -y, z]
    if axis == "z":
        return [x, y, -z]
    raise ValueError("axis must be x, y or z")


def average_symmetric(a, b, axis="x"):
    ax, ay, az = a
    bx, by, bz = b
    if axis == "x":
        mag = (abs(ax) + abs(bx)) * 0.5
        sign = 1.0 if ax >= 0 else -1.0
        y = (ay + by) * 0.5
        z = (az + bz) * 0.5
        left = [sign * mag, y, z]
        right = [-left[0], y, z]
        return left, right
    if axis == "y":
        mag = (abs(ay) + abs(by)) * 0.5
        sign = 1.0 if ay >= 0 else -1.0
        x = (ax + bx) * 0.5
        z = (az + bz) * 0.5
        left = [x, sign * mag, z]
        right = [x, -left[1], z]
        return left, right
    mag = (abs(az) + abs(bz)) * 0.5
    sign = 1.0 if az >= 0 else -1.0
    x = (ax + bx) * 0.5
    y = (ay + by) * 0.5
    left = [x, y, sign * mag]
    right = [x, y, -left[2]]
    return left, right


def symmetrize_from_root(
    root=None,
    direction="LtoR",
    axis="x",
    zero_center=True,
    dry_run=False,
):
    """
    @param root: root joint. If None, use current selection.
    @param direction: "LtoR" | "RtoL" | "average"
    @param axis: "x" | "y" | "z"  (world mirror axis)
    @param zero_center: if True, set _C_ joints' mirrored axis to 0 in world
    """
    if root is None:
        sel = cmds.ls(selection=True, type="joint", long=True) or []
        if not sel:
            raise RuntimeError("Please select a root joint.")
        root = sel[0]
    if cmds.nodeType(root) != "joint":
        joints = cmds.listRelatives(root, children=True, type="joint", fullPath=True) or []
        if not joints:
            raise RuntimeError("'{}' is not a joint.".format(root))
        root = root if cmds.nodeType(root) == "joint" else joints[0]

    report = {"pairs": 0, "center": 0, "unmatched": []}
    cmds.undoInfo(openChunk=True, chunkName="symmetrizeJointTranslate")
    try:
        nodes = all_joints_under(root)
        pairs, unmatched = collect_pairs(nodes, root)
        report["unmatched"] = [short_name(n) for n in unmatched]

        for left, right in pairs:
            depth = min(joint_depth(left, root), joint_depth(right, root))
            lpos = cmds.xform(left, query=True, worldSpace=True, translation=True)
            rpos = cmds.xform(right, query=True, worldSpace=True, translation=True)
            if direction == "LtoR":
                new_l, new_r = lpos, mirror_xyz(lpos, axis)
            elif direction == "RtoL":
                new_l, new_r = mirror_xyz(rpos, axis), rpos
            else:
                new_l, new_r = average_symmetric(lpos, rpos, axis)

            print(
                "L{0}: {1}  <->  {2}".format(
                    depth, short_name(left), short_name(right)
                )
            )
            if not dry_run:
                cmds.xform(left, worldSpace=True, translation=new_l)
                cmds.xform(right, worldSpace=True, translation=new_r)
            report["pairs"] += 1

        if zero_center:
            for node in nodes:
                name = short_name(node)
                if not is_center(name):
                    continue
                pos = cmds.xform(node, query=True, worldSpace=True, translation=True)
                if axis == "x":
                    pos[0] = 0.0
                elif axis == "y":
                    pos[1] = 0.0
                else:
                    pos[2] = 0.0
                print("center: {0}".format(name))
                if not dry_run:
                    cmds.xform(node, worldSpace=True, translation=pos)
                report["center"] += 1
    finally:
        cmds.undoInfo(closeChunk=True)

    print(
        "done. pairs={0} center={1} unmatched={2}".format(
            report["pairs"], report["center"], len(report["unmatched"])
        )
    )
    if report["unmatched"]:
        print("unmatched: {}".format(", ".join(report["unmatched"])))
    return report


def show():
    if cmds.window(_WINDOW, exists=True):
        cmds.deleteUI(_WINDOW)

    win = cmds.window(_WINDOW, title="Joint Translate 左右对称", widthHeight=(360, 220))
    cmds.columnLayout(adjustableColumn=True, rowSpacing=6, columnAttach=("both", 8))
    cmds.text(
        label="选择根骨骼（如 FACIAL_C_FacialRoot）。在整棵子树里按 _L_ / _R_ 配对，浅层先对称。",
        align="left",
        wordWrap=True,
    )
    cmds.separator(height=8, style="in")

    cmds.radioButtonGrp(
        "sb_sym_dir",
        label="方向",
        labelArray3=["L → R", "R → L", "平均"],
        numberOfRadioButtons=3,
        select=1,
        columnWidth4=(50, 70, 70, 70),
    )
    cmds.radioButtonGrp(
        "sb_sym_axis",
        label="镜像轴",
        labelArray3=["X", "Y", "Z"],
        numberOfRadioButtons=3,
        select=1,
        columnWidth4=(50, 50, 50, 50),
    )
    cmds.checkBox("sb_sym_center", label="中线 _C_ 骨骼对齐到 0", value=True)
    cmds.button(label="预览（不改场景）", height=28, command=lambda *_: _run(True))
    cmds.button(label="应用对称", height=32, backgroundColor=(0.4, 0.55, 0.4), command=lambda *_: _run(False))
    cmds.showWindow(win)
    return win


def _run(dry_run):
    dirs = {1: "LtoR", 2: "RtoL", 3: "average"}
    axes = {1: "x", 2: "y", 3: "z"}
    direction = dirs[cmds.radioButtonGrp("sb_sym_dir", query=True, select=True)]
    axis = axes[cmds.radioButtonGrp("sb_sym_axis", query=True, select=True)]
    zero_center = cmds.checkBox("sb_sym_center", query=True, value=True)
    try:
        symmetrize_from_root(
            direction=direction,
            axis=axis,
            zero_center=zero_center,
            dry_run=dry_run,
        )
    except Exception as exc:
        cmds.confirmDialog(title="Joint Translate 对称", message=str(exc), button=["OK"], icon="warning")


if __name__ == "__main__":
    show()

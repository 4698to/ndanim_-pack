# -*- coding: utf-8 -*-
from __future__ import division, print_function

import io
import json
import math
import os
import time
import sys

def _reload_cached_semantics():
    cached = sys.modules.get('DIYFaceSkinUVSemantics')
    if cached is None:
        return None
    try:
        from importlib import reload
    except ImportError:
        from imp import reload
    try:
        return reload(cached)
    except Exception:
        return cached


_SEMANTICS_REQUIRED = ('build_marker_rules', 'pair_bones', 'parse_name', 'make_reference',
                       'map_bones', 'resolve_candidates', 'validate_v3')

sem = _reload_cached_semantics()
if sem is None:
    try:
        import DIYFaceSkinUVSemantics as sem
    except ImportError:
        _script_file = globals().get('__file__')
        if not _script_file:
            raise ImportError(u"必须携带 DIYFaceSkinUVSemantics.py；exec 运行时请设置主脚本 __file__ 或将脚本目录加入 sys.path。")
        _script_dir = os.path.dirname(os.path.abspath(_script_file))
        if _script_dir not in sys.path:
            sys.path.insert(0, _script_dir)
        try:
            import DIYFaceSkinUVSemantics as sem
        except ImportError:
            raise ImportError(u"主脚本目录中缺少必需模块 DIYFaceSkinUVSemantics.py：{}".format(_script_dir))
_missing = [name for name in _SEMANTICS_REQUIRED if not hasattr(sem, name)]
if _missing:
    raise ImportError(u"DIYFaceSkinUVSemantics.py 版本与主脚本不匹配，缺少：{}。请确认两者在同一目录且为最新版本后重新打开工具。".format(
        u"、".join(_missing)))

try:
    from PySide6 import QtCore, QtWidgets
except ImportError:
    try:
        from PySide2 import QtCore, QtWidgets
    except ImportError:
        from PySide import QtCore, QtGui
        QtWidgets = QtGui

HOST = None
rt = None
qtmax = None
MaxPlus = None
try:
    from pymxs import runtime as rt
    HOST = "3dsmax"
    try:
        import qtmax
    except ImportError:
        pass
except ImportError:
    try:
        import MaxPlus
        HOST = "3dsmax"
    except ImportError:
        pass

_DIALOG = None
_APPLICATION = None
UV_TOLERANCE = 1e-5
try:
    _STRING_TYPES = (basestring,)
    _TEXT_TYPE = unicode
    _INTEGER_TYPES = (int, long)
except NameError:
    _STRING_TYPES = (str,)
    _TEXT_TYPE = str
    _INTEGER_TYPES = (int,)


def _text(value):
    if isinstance(value, bytes) and not isinstance(value, _TEXT_TYPE):
        try:
            return value.decode("utf-8")
        except UnicodeDecodeError:
            return value.decode("mbcs")
    return _TEXT_TYPE(value)


class _MaxScriptValue(object):
    def __init__(self, runtime, expression):
        self._runtime = runtime
        self._expression = expression

    def __getattr__(self, name):
        return self._runtime._evaluate(self._expression + "." + name)

    def __call__(self, *args):
        if not args:
            return self._runtime._evaluate(
                u"(local bridgeCallable = {}; bridgeCallable())".format(self._expression))
        expression = u"(" + self._expression
        for value in args:
            expression += u" " + self._runtime._literal(value)
        return self._runtime._evaluate(expression + u")")

    def __iter__(self):
        count = int(self._runtime._evaluate(self._expression + ".count"))
        for index in range(1, count + 1):
            yield self._runtime._evaluate("{}[{}]".format(self._expression, index))

    def __mul__(self, other):
        return self._runtime._evaluate("({} * {})".format(
            self._expression, self._runtime._literal(other)))

    def __unicode__(self):
        return self._runtime._string("({}) as string".format(self._expression))

    def __str__(self):
        value = self.__unicode__()
        return value if _TEXT_TYPE is str else value.encode("utf-8")


class _MaxPlusRuntime(object):
    # 用引用槽保留节点、修改器和函数，避免按名称拼接场景对象。
    def __init__(self):
        self._string("global DIYFaceSkinUVTransferRefs = #(); \"\"")

    def _string(self, expression):
        result = MaxPlus.FPValue()
        success = MaxPlus.Core.EvalMAXScript(expression, result)
        if success is False:
            raise RuntimeError(u"MaxPlus 执行 MAXScript 失败：{}".format(expression))
        return _text(result.Get())

    def _literal(self, value):
        if isinstance(value, _MaxScriptValue):
            return value._expression
        if value is None:
            return "undefined"
        if isinstance(value, bool):
            return "true" if value else "false"
        if isinstance(value, _STRING_TYPES):
            return u'"{}"'.format(_text(value).replace("\\", "\\\\").replace('"', '\\"')
                                 .replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t"))
        if isinstance(value, (list, tuple)):
            return u"#({})".format(u",".join(self._literal(item) for item in value))
        return repr(value)

    def _evaluate(self, expression):
        script = (
            u'(try (local bridgeValue = {expression}; '
            u'local bridgeType = (classOf bridgeValue) as string; '
            u'if bridgeType == "UndefinedClass" then "U|" '
            u'else if bridgeType == "String" then ("S|" + bridgeValue) '
            u'else if bridgeType == "BooleanClass" then ("B|" + (bridgeValue as string)) '
            u'else if (bridgeType == "Integer" or bridgeType == "Integer64") then '
            u'("I|" + (bridgeValue as string)) '
            u'else if (bridgeType == "Float" or bridgeType == "Double") then '
            u'("F|" + (bridgeValue as string)) '
            u'else (append DIYFaceSkinUVTransferRefs bridgeValue; '
            u'"R|" + (DIYFaceSkinUVTransferRefs.count as string))) '
            u'catch (local bridgeError = getCurrentException() as string; '
            u'print bridgeError; "E|" + bridgeError))'
        ).format(expression=expression)
        value = self._string(script)
        kind, payload = value.split("|", 1)
        if kind == "E":
            raise RuntimeError(u"MAXScript 接口错误：{}".format(payload))
        if kind == "U":
            return None
        if kind == "S":
            return payload
        if kind == "B":
            return payload.lower() == "true"
        if kind == "I":
            return int(payload)
        if kind == "F":
            return float(payload)
        return _MaxScriptValue(self, "DIYFaceSkinUVTransferRefs[{}]".format(int(payload)))

    def __getattr__(self, name):
        return self._evaluate(name)

    def Name(self, value):
        return self._evaluate("({} as name)".format(self._literal(value)))

    def Array(self, *values):
        return self._evaluate(self._literal(values))


if rt is None and MaxPlus is not None:
    rt = _MaxPlusRuntime()


def _combo_data(combo):
    return _text(combo.itemData(combo.currentIndex()))


def _require_max():
    if HOST != "3dsmax":
        raise RuntimeError(u"此工具必须在 3ds Max 内运行。")


def _skin_modifier(node, create=False, activate=True):
    for modifier in node.modifiers:
        try:
            is_skin = "skin" in str(rt.classOf(modifier)).lower()
        except Exception:
            continue
        if is_skin:
            if activate:
                rt.select(node)
                rt.setCommandPanelTaskMode(rt.Name("modify"))
                rt.modPanel.setCurrentObject(modifier)
            return modifier
    if create:
        if not activate:
            raise ValueError(u"只读采集不能创建 Skin。")
        modifier = rt.Skin()
        rt.addModifier(node, modifier)
        rt.select(node)
        rt.setCommandPanelTaskMode(rt.Name("modify"))
        rt.modPanel.setCurrentObject(modifier)
        return modifier
    return None


def _mesh_kind(node):
    base = node.baseObject
    try:
        if rt.isKindOf(base, rt.Editable_Poly):
            return "poly"
    except Exception:
        pass
    return "mesh"


def _mesh_counts(node, kind):
    if kind == "poly":
        return int(rt.polyop.getNumVerts(node)), int(rt.polyop.getNumFaces(node))
    return int(rt.getNumVerts(node)), int(rt.getNumFaces(node))


def _local_vertex(node, kind, index):
    if kind == "poly":
        return rt.polyop.getVert(node, index + 1)
    return rt.getVert(node, index + 1)


def _face_corners(node, kind, face_index):
    if kind == "poly":
        return [int(v) - 1 for v in rt.polyop.getFaceVerts(node, face_index + 1)]
    face = rt.getFace(node, face_index + 1)
    return [int(face.x) - 1, int(face.y) - 1, int(face.z) - 1]


def _map_face(node, kind, channel, face_index):
    if kind == "poly":
        values = rt.polyop.getMapFace(node, channel, face_index + 1)
        return [int(v) - 1 for v in values]
    face = rt.meshop.getMapFace(node, channel, face_index + 1)
    return [int(face.x) - 1, int(face.y) - 1, int(face.z) - 1]


def _map_vertex(node, kind, channel, map_index):
    if kind == "poly":
        value = rt.polyop.getMapVert(node, channel, map_index + 1)
    else:
        value = rt.meshop.getMapVert(node, channel, map_index + 1)
    return [float(value.x), float(value.y)]


def _map_supported(node, kind, channel):
    try:
        if kind == "poly":
            return bool(rt.polyop.getMapSupport(node, channel))
        return bool(rt.meshop.getMapSupport(node, channel))
    except Exception:
        return False


def _world_position(node, kind, index):
    point = _local_vertex(node, kind, index)
    world = point * node.transform
    return [float(world.x), float(world.y), float(world.z)]


def _skin_bones(skin):
    result = []
    count = int(rt.skinOps.getNumberBones(skin))
    for bone_id in range(1, count + 1):
        result.append(_text(rt.skinOps.getBoneName(skin, bone_id, 0)))
    return result


def _bone_limit(skin):
    for name in ("bone_Limit", "boneLimit"):
        try:
            return int(rt.getProperty(skin, rt.Name(name)))
        except Exception:
            continue
    try:
        return int(rt.skinOps.GetBoneLimit(skin))
    except Exception:
        return None


def _set_bone_limit(skin, value):
    for name in ("bone_Limit", "boneLimit"):
        try:
            rt.setProperty(skin, rt.Name(name), int(value))
            return True
        except Exception:
            continue
    try:
        rt.skinOps.SetBoneLimit(skin, int(value))
        return True
    except Exception:
        return False


def _skin_vertex_weights(skin, vertex_index):
    vertex_id = vertex_index + 1
    count = int(rt.skinOps.getVertexWeightCount(skin, vertex_id))
    values = []
    for item in range(1, count + 1):
        bone_id = int(rt.skinOps.getVertexWeightBoneID(skin, vertex_id, item))
        weight = float(rt.skinOps.getVertexWeight(skin, vertex_id, item))
        if bone_id > 0 and weight > 0.0:
            values.append([bone_id - 1, weight])
    return values


def _collect(node, channel):
    _require_max()
    skin = _skin_modifier(node, activate=False)
    if skin is None:
        raise RuntimeError(u"导出模型必须已有 Skin 修改器。")
    kind = _mesh_kind(node)
    if not _map_supported(node, kind, channel):
        raise RuntimeError(u"节点“{}”没有 UV 通道 {}。".format(node.name, channel))
    vertex_count, face_count = _mesh_counts(node, kind)
    bones = _skin_bones(skin)
    positions = [_world_position(node, kind, i) for i in range(vertex_count)]
    weights = [_skin_vertex_weights(skin, i) for i in range(vertex_count)]
    faces, face_uvs, materials = [], [], []
    for face_index in range(face_count):
        corners = _face_corners(node, kind, face_index)
        map_corners = _map_face(node, kind, channel, face_index)
        if len(corners) < 3 or len(map_corners) != len(corners):
            continue
        for corner in range(1, len(corners) - 1):
            selected = [0, corner, corner + 1]
            faces.append([corners[k] for k in selected])
            face_uvs.append([_map_vertex(node, kind, channel, map_corners[k]) for k in selected])
            materials.append(_face_material(node, kind, face_index))
    if not faces:
        raise RuntimeError(u"节点“{}”没有可用三角面 UV。".format(node.name))
    return skin, kind, {
        "format": "DIYFaceSkinWeights", "version": 2, "mode": "uv", "host": "3dsmax",
        "createdAt": time.strftime("%Y-%m-%dT%H:%M:%S"),
        "source": {"node": _text(node.name), "uvChannel": int(channel),
                   "vertexCount": vertex_count, "faceCount": face_count,
                   "unitScale": 1.0, "boneLimit": _bone_limit(skin)},
        "bones": bones, "positions": positions, "weights": weights,
        "faces": faces, "faceUVs": face_uvs, "faceMaterialIds": materials
    }


def _face_material(node, kind, face_index):
    if kind == 'poly':
        return int(rt.polyop.getFaceMatID(node, face_index + 1))
    return int(rt.getFaceMatID(node, face_index + 1))


def _scene_name_groups():
    groups = {}
    for bone in rt.objects:
        groups.setdefault(_text(bone.name), []).append(bone)
    return groups


def _unique_node(name, groups):
    choices = groups.get(name, [])
    if len(choices) != 1:
        raise ValueError(u"骨骼原名必须在场景唯一：{}（找到 {} 个）。".format(name, len(choices)))
    return choices[0]


def _node_center(node):
    try:
        low, high = node.min, node.max
        return [(float(low.x) + float(high.x)) / 2.0,
                (float(low.y) + float(high.y)) / 2.0,
                (float(low.z) + float(high.z)) / 2.0]
    except Exception:
        pass
    try:
        return _node_position(node)
    except Exception:
        return None


def _auto_side_pair(node, names, rules, groups):
    pairs, unused_issues = sem.pair_bones(names, rules)
    center = _node_center(node)
    best, best_key = None, None
    for left, right, unused_base in pairs:
        try:
            left_xyz = _node_position(_unique_node(names[left], groups))
            right_xyz = _node_position(_unique_node(names[right], groups))
        except Exception:
            continue
        spacing = math.sqrt(sum((a - b) ** 2 for a, b in zip(left_xyz, right_xyz)))
        if spacing <= 1e-9:
            continue
        midpoint = [(a + b) / 2.0 for a, b in zip(left_xyz, right_xyz)]
        distance = float('inf') if center is None else math.sqrt(
            sum((a - b) ** 2 for a, b in zip(midpoint, center)))
        # 先比较到网格中心的距离，再看骨骼间距（大者优先），最后按名称稳定排序。
        key = (distance, -spacing, _text(names[left]), _text(names[right]))
        if best_key is None or key < best_key:
            best_key = key
            best = (_text(names[left]), _text(names[right]))
    return best


def _node_position(node):
    holder = getattr(node, 'transform', None)
    point = getattr(holder, 'position', None) if holder is not None else None
    if point is None:
        point = getattr(node, 'position', None)
    if point is None:
        raise ValueError(u"无法读取骨骼位置：{}".format(getattr(node, 'name', node)))
    return [float(point.x), float(point.y), float(point.z)]


def _reference(names, side_pair, groups, epsilon, rules, pose):
    if side_pair is None:
        return None
    if not isinstance(side_pair, (tuple, list)) or len(side_pair) != 2:
        raise ValueError(u"参考对必须是 Left/Right 原始骨骼名称二元组。")
    indices, positions = [], []
    for name, side in zip(side_pair, ('Left', 'Right')):
        if names.count(name) != 1 or sem.parse_name(name, rules)['side'] != side:
            raise ValueError(u"参考骨骼必须唯一且具有 {} 语义：{}".format(side, name))
        indices.append(names.index(name))
        positions.append(_node_position(_unique_node(name, groups)))
    return sem.make_reference(indices[0], indices[1], positions[0], positions[1], epsilon, pose)


def export_weights(node, file_path, uv_channel=1, mode="uv", side_pair=None,
                   epsilon_side=0.001, naming_rules=None, pose=''):
    _require_max()
    if not _valid_index(uv_channel) or uv_channel < 1:
        raise ValueError(u"UV 通道必须是正整数。")
    if not _valid_number(epsilon_side) or epsilon_side < 0 or not isinstance(pose, _STRING_TYPES):
        raise ValueError(u"参考带宽或姿态说明无效。")
    sem.parse_name('Head', naming_rules)
    if mode == "uv":
        unused_skin, unused_kind, data = _collect(node, int(uv_channel))
        reference = _reference(data['bones'], side_pair, _scene_name_groups(),
                               epsilon_side, naming_rules, pose)
        coords = [sem.side_coordinate(p, reference) for p in data['positions']]
        regions = []
        for face in data['faces']:
            sides = [sem.classify_side(coords[i], epsilon_side) for i in face]
            regions.append('Unknown' if 'Unknown' in sides else
                           ('Left' if all(s == 'Left' for s in sides) else
                            ('Right' if all(s == 'Right' for s in sides) else 'Mixed')))
        data.update(version=3, boneSemantics=[sem.parse_name(n, naming_rules) for n in data['bones']],
                    sideReference=reference, vertexSideCoordinates=coords, faceRegions=regions,
                    sideNamingRules={'version': 1, 'rules': naming_rules or {}})
        _validate_v2(data)
    elif mode == "legacy":
        skin = _skin_modifier(node, activate=False)
        if skin is None:
            raise RuntimeError(u"导出模型必须已有 Skin。")
        vertex_count, unused_faces = _mesh_counts(node, _mesh_kind(node))
        bones = _skin_bones(skin)
        entries = {}
        for index in range(vertex_count):
            entries[str(index)] = {bones[bone_id]: weight for bone_id, weight in _skin_vertex_weights(skin, index)}
        data = {_text(node.name): entries}
    else:
        raise ValueError(u"未知导出模式：{}".format(mode))
    with io.open(file_path, "w", encoding="utf-8") as output_file:
        output_file.write(_text(json.dumps(data, ensure_ascii=False, separators=(",", ":"))))
    return {"vertices": len(data["weights"]) if mode == "uv" else len(data[_text(node.name)]), "mode": mode}


def _validate_v2(data):
    if (not isinstance(data, dict) or data.get("format") != "DIYFaceSkinWeights"
            or not _valid_index(data.get('version')) or data['version'] not in (2, 3)):
        raise ValueError(u"权重文件格式或版本不受支持（仅支持整数 2/3）。")
    source = data.get('source', {})
    if not isinstance(source, dict):
        raise ValueError(u"source 必须是 JSON 对象。")
    limit = source.get('boneLimit')
    if limit is not None and (not _valid_index(limit) or limit < 1):
        raise ValueError(u"source.boneLimit 必须是合法正整数或 null。")
    required = ("bones", "weights", "positions", "faces", "faceUVs")
    if any(key not in data for key in required):
        raise ValueError(u"UV v2 文件缺少必要字段。")
    if not all(isinstance(data[key], list) for key in required):
        raise ValueError(u"UV v2 文件字段类型无效。")
    if len(data["positions"]) != len(data["weights"]):
        raise ValueError(u"文件顶点坐标与权重数量不一致。")
    if len(data["faces"]) != len(data["faceUVs"]):
        raise ValueError(u"文件三角面与角点 UV 数量不一致。")
    if not data["bones"] or any(not isinstance(name, _STRING_TYPES) for name in data["bones"]):
        raise ValueError(u"文件骨骼名称列表无效。")
    vertex_count = len(data["positions"])
    for position in data["positions"]:
        if not isinstance(position, (list, tuple)) or len(position) != 3 or any(not _valid_number(v) for v in position):
            raise ValueError(u"文件顶点坐标包含无效数据。")
    for weights in data["weights"]:
        if not isinstance(weights, list):
            raise ValueError(u"文件顶点权重格式无效。")
        for pair in weights:
            if not isinstance(pair, (list, tuple)) or len(pair) != 2:
                raise ValueError(u"文件顶点权重格式无效。")
            bone_id, weight = pair
            if not _valid_index(bone_id) or bone_id >= len(data['bones']) or not _valid_number(weight) or weight < 0:
                raise ValueError(u"文件包含无效的骨骼索引或权重。")
    for face, face_uv in zip(data["faces"], data["faceUVs"]):
        if not isinstance(face, (list, tuple)) or len(face) != 3 or not isinstance(face_uv, (list, tuple)) or len(face_uv) != 3:
            raise ValueError(u"文件三角面或角点 UV 格式无效。")
        if any(not _valid_index(index) or index >= vertex_count for index in face):
            raise ValueError(u"文件三角面包含无效顶点索引。")
        if any(not isinstance(uv, (list, tuple)) or len(uv) != 2 or any(not _valid_number(v) for v in uv) for uv in face_uv):
            raise ValueError(u"文件包含无效 UV 坐标。")
    if 'faceMaterialIds' in data:
        materials = data['faceMaterialIds']
        if (not isinstance(materials, list) or len(materials) != len(data['faces'])
                or any(not _valid_index(m) for m in materials)):
            raise ValueError(u"faceMaterialIds 类型、数量或 ID 无效。")
    if data['version'] == 3:
        sem.validate_v3(data)
    return data


def _valid_index(value):
    return isinstance(value, _INTEGER_TYPES) and not isinstance(value, bool) and value >= 0


def _valid_number(value):
    if isinstance(value, bool) or not isinstance(value, _INTEGER_TYPES + (float,)):
        return False
    try:
        number = float(value)
        return not math.isnan(number) and not math.isinf(number)
    except (TypeError, ValueError, OverflowError):
        return False


def _is_v2(data):
    return isinstance(data, dict) and "format" in data


def _legacy_entries(data):
    if not isinstance(data, dict) or not data:
        raise ValueError(u"无法识别的旧版权重文件。")
    root = data
    if len(root) == 1:
        outer_key, candidate = next(iter(root.items()))
        if not _text(outer_key).isdigit() and isinstance(candidate, dict):
            root = candidate
    entries = []
    try:
        indexed = sorted(((int(key), value) for key, value in root.items()), key=lambda item: item[0])
    except (TypeError, ValueError):
        raise ValueError(u"旧版权重文件缺少按顶点序号排列的数据。")
    for expected, pair in enumerate(indexed):
        if pair[0] != expected or not isinstance(pair[1], dict):
            raise ValueError(u"旧版权重顶点序号不连续或数据无效。")
        entries.append(pair[1])
    return entries


def _bone_key(name):
    return sem.clean_name(name)


def _target_bone_lookup(skin):
    groups = {}
    for index, name in enumerate(_skin_bones(skin), 1):
        groups.setdefault(_bone_key(name), []).append(index)
    return {key: ids[0] for key, ids in groups.items() if len(ids) == 1}


def _virtual_bones(skin, source_names, groups, explicit, source_rules, target_rules):
    names = _skin_bones(skin) if skin is not None else []
    scene_names = [name for name in sorted(groups) for unused in groups[name]]
    scene_mapping, issues = sem.map_bones(
        source_names, scene_names, explicit, source_rules, target_rules)
    mapping, unused_issues = sem.map_bones(
        source_names, names, explicit, source_rules, target_rules)
    duplicate_issues = []
    # 优先保留 Skin 匹配，仅未匹配的源骨骼使用场景候选。
    for source_id, scene_id in sorted(scene_mapping.items()):
        if source_id in mapping:
            continue
        name = scene_names[scene_id - 1]
        if names.count(name) > 1:
            duplicate_issues.append('Duplicate original Skin target: {}'.format(name))
            continue
        if name not in names:
            names.append(name)
        mapping[source_id] = names.index(name) + 1
    # 基于完整场景生成报告，不对缩减后的虚拟列表重新匹配。
    resolved_explicit = dict(explicit)
    for source_id, target_id in mapping.items():
        resolved_explicit[source_names[source_id]] = names[target_id - 1]
    if resolved_explicit != explicit:
        unused_mapping, issues = sem.map_bones(
            source_names, scene_names, resolved_explicit, source_rules, target_rules)
    issues.extend(duplicate_issues)
    for source_id, target_id in list(mapping.items()):
        name = names[target_id - 1]
        if len(groups.get(name, [])) != 1:
            issues.append('Missing or duplicate scene target: {}'.format(name))
            del mapping[source_id]
    return names, mapping, issues


def _barycentric(point, a, b, c):
    v0x, v0y = b[0] - a[0], b[1] - a[1]
    v1x, v1y = c[0] - a[0], c[1] - a[1]
    v2x, v2y = point[0] - a[0], point[1] - a[1]
    denominator = v0x * v1y - v1x * v0y
    if abs(denominator) < 1e-16:
        return None
    wb = (v2x * v1y - v1x * v2y) / denominator
    wc = (v0x * v2y - v2x * v0y) / denominator
    wa = 1.0 - wb - wc
    if min(wa, wb, wc) < -UV_TOLERANCE:
        return None
    bary = [max(0.0, wa), max(0.0, wb), max(0.0, wc)]
    total = sum(bary)
    return [value / total for value in bary] if total > 0.0 else None


def _build_uv_index(data):
    triangles = []
    for face_id, face in enumerate(data["faces"]):
        if len(face) != 3 or any(int(i) < 0 or int(i) >= len(data["positions"]) for i in face):
            continue
        uv = data["faceUVs"][face_id]
        if len(uv) != 3:
            continue
        if _barycentric(uv[0], uv[0], uv[1], uv[2]) is None:
            continue
        xs, ys = [p[0] for p in uv], [p[1] for p in uv]
        triangles.append({"ids": [int(i) for i in face], "uv": uv, 'face_id': face_id,
                          'material': data['faceMaterialIds'][face_id] if 'faceMaterialIds' in data else None,
                          "box": (min(xs), min(ys), max(xs), max(ys))})
    if not triangles:
        return triangles, {}, [], 0.0, 0.0, 1.0
    min_x = min(t["box"][0] for t in triangles)
    min_y = min(t["box"][1] for t in triangles)
    max_x = max(t["box"][2] for t in triangles)
    max_y = max(t["box"][3] for t in triangles)
    span = max(max_x - min_x, max_y - min_y, 1e-6)
    cell = max(span / max(8.0, math.sqrt(float(len(triangles)))), 1e-5)
    grid = {}
    broad = []
    for tri_id, tri in enumerate(triangles):
        x0 = int(math.floor((tri["box"][0] - min_x) / cell))
        y0 = int(math.floor((tri["box"][1] - min_y) / cell))
        x1 = int(math.floor((tri["box"][2] - min_x) / cell))
        y1 = int(math.floor((tri["box"][3] - min_y) / cell))
        if (x1 - x0 + 1) * (y1 - y0 + 1) > 4096:
            broad.append(tri_id)
            continue
        for x in range(x0, x1 + 1):
            for y in range(y0, y1 + 1):
                grid.setdefault((x, y), []).append(tri_id)
    return triangles, grid, broad, min_x, min_y, cell


def _query_uv(point, index):
    triangles, grid, broad, min_x, min_y, cell = index
    x = int(math.floor((point[0] - min_x) / cell))
    y = int(math.floor((point[1] - min_y) / cell))
    candidates = set(grid.get((x, y), ()))
    candidates.update(broad)
    for nx in (x - 1, x, x + 1):
        for ny in (y - 1, y, y + 1):
            candidates.update(grid.get((nx, ny), ()))
    output = []
    for tri_id in sorted(candidates):
        tri = triangles[tri_id]
        box = tri["box"]
        if point[0] < box[0] - UV_TOLERANCE or point[0] > box[2] + UV_TOLERANCE or point[1] < box[1] - UV_TOLERANCE or point[1] > box[3] + UV_TOLERANCE:
            continue
        bary = _barycentric(point, tri["uv"][0], tri["uv"][1], tri["uv"][2])
        if bary is not None:
            output.append((tri, bary))
    return output


def _flip_u(uv):
    base = math.floor(uv[0])
    return (base + (1.0 - (uv[0] - base)), uv[1])


def _build_point_index(positions):
    if not positions:
        raise ValueError(u"权重文件没有顶点坐标。")
    min_x = min(p[0] for p in positions)
    min_y = min(p[1] for p in positions)
    min_z = min(p[2] for p in positions)
    max_x = max(p[0] for p in positions)
    max_y = max(p[1] for p in positions)
    max_z = max(p[2] for p in positions)
    span = max(max_x - min_x, max_y - min_y, max_z - min_z, 1e-6)
    cell = max(span / max(8.0, len(positions) ** (1.0 / 3.0)), 1e-5)
    grid = {}
    for vertex_id, position in enumerate(positions):
        key = (int(math.floor((position[0] - min_x) / cell)),
               int(math.floor((position[1] - min_y) / cell)),
               int(math.floor((position[2] - min_z) / cell)))
        grid.setdefault(key, []).append(vertex_id)
    return grid, cell, (min_x, min_y, min_z), span, positions


def _nearest_source_vertex(index, point):
    grid, cell, origin, span, positions = index
    cx = int(math.floor((point[0] - origin[0]) / cell))
    cy = int(math.floor((point[1] - origin[1]) / cell))
    cz = int(math.floor((point[2] - origin[2]) / cell))
    best_id = None
    best_distance = None
    max_radius = int(span / cell) + 2
    radius = 0
    while radius <= max_radius:
        for x in range(cx - radius, cx + radius + 1):
            for y in range(cy - radius, cy + radius + 1):
                for z in range(cz - radius, cz + radius + 1):
                    for vertex_id in grid.get((x, y, z), ()):
                        position = positions[vertex_id]
                        distance = ((position[0] - point[0]) ** 2 +
                                    (position[1] - point[1]) ** 2 +
                                    (position[2] - point[2]) ** 2)
                        if best_distance is None or distance < best_distance:
                            best_distance = distance
                            best_id = vertex_id
        if best_id is not None and best_distance <= (radius * cell) ** 2:
            break
        radius += 1
    return best_id


def _interpolate_weights(data, tri, bary):
    values = {}
    for corner, vertex_id in enumerate(tri["ids"]):
        factor = bary[corner]
        for bone_id, weight in data["weights"][vertex_id]:
            values[int(bone_id)] = values.get(int(bone_id), 0.0) + factor * float(weight)
    return values


def _map_weights(weights, source_bones, target_lookup, max_influences):
    mapped = {}
    missing = set()
    for source_id, weight in weights.items():
        if source_id < 0 or source_id >= len(source_bones):
            continue
        name = source_bones[source_id]
        target_id = target_lookup.get(_bone_key(name))
        if target_id is None:
            missing.add(name)
        elif weight > 0.0:
            mapped[target_id] = mapped.get(target_id, 0.0) + weight
    ordered = sorted(mapped.items(), key=lambda pair: (-pair[1], pair[0]))[:max(1, int(max_influences))]
    total = sum(value for unused_bone, value in ordered)
    if total <= 1e-12:
        return {}, missing
    return {bone_id: value / total for bone_id, value in ordered}, missing


def _current_weight_total(skin, vertex_index):
    return sum(weight for unused_bone, weight in _skin_vertex_weights(skin, vertex_index))


def _legacy_map(entries, node, skin, lookup, max_influences):
    vertex_count, unused_faces = _mesh_counts(node, _mesh_kind(node))
    if len(entries) != vertex_count:
        raise ValueError(u"旧格式顶点数 {} 与目标顶点数 {} 不一致。".format(len(entries), vertex_count))
    results, missing = {}, set()
    for index, entry in enumerate(entries):
        mapped = {}
        for name, weight in entry.items():
            if not _valid_number(weight) or float(weight) < 0.0:
                raise ValueError(u"旧版权重包含无效数值。")
            target_id = lookup.get(_bone_key(name))
            if target_id is None:
                missing.add(_text(name))
            else:
                mapped[target_id] = mapped.get(target_id, 0.0) + float(weight)
        if mapped:
            ordered = sorted(mapped.items(), key=lambda pair: pair[1], reverse=True)[:max(1, int(max_influences))]
            total = sum(value for unused_id, value in ordered)
            if total > 1e-12:
                results[index] = {bone_id: value / total for bone_id, value in ordered}
    return results, {"hit": len(results), "no_uv": 0, "far": 0, "missing_bones": sorted(missing)}


def _normalize_weights(values, cap):
    ordered = sorted(values.items(), key=lambda pair: (-pair[1], pair[0]))[:cap]
    total = sum(w for unused, w in ordered)
    return {bone: w / total for bone, w in ordered if w > 0} if total > 1e-12 else {}


def import_weights(node, file_path, uv_channel=1, write_mode="overwrite", method="uv",
                   flip_u=False, preview=False, side_pair=None, epsilon_side=0.001,
                   naming_rules=None, bone_mapping=None, disambiguation='side',
                   use_material=False, pose='', tolerance=1e-5):
    _require_max()
    if write_mode not in ('overwrite', 'unweighted', 'blend') or method not in ('uv', 'distance'):
        raise ValueError(u"写入模式或复制方式无效。")
    if not _valid_index(uv_channel) or uv_channel < 1:
        raise ValueError(u"UV 通道必须是正整数。")
    if (disambiguation not in ('side', 'consistency') or not _valid_number(epsilon_side)
            or epsilon_side < 0 or not _valid_number(tolerance) or tolerance < 0
            or not isinstance(pose, _STRING_TYPES)):
        raise ValueError(u"消歧方式、带宽、容差或姿态说明无效。")
    explicit = {} if bone_mapping is None else bone_mapping
    sem.parse_name('Head', naming_rules)
    sem.map_bones([], [], explicit=explicit, target_rules=naming_rules)
    with io.open(file_path, 'r', encoding='utf-8') as input_file:
        data = json.load(input_file)
    modern = _is_v2(data)
    if modern:
        data = _validate_v2(data)
        source_names = data['bones']
        source_rules = data['sideNamingRules']['rules'] if data['version'] == 3 else {}
        saved_bone_limit = data.get('source', {}).get('boneLimit')
        cap = saved_bone_limit or max([1] + [len(w) for w in data['weights']])
        if use_material and method == 'uv' and 'faceMaterialIds' not in data:
            raise ValueError(u"材质备选已启用，但源文件没有 faceMaterialIds；请重新导出。")
    else:
        if method != 'uv':
            raise ValueError(u"兼容格式没有位置，只能按顶点序号导入。")
        if use_material:
            raise ValueError(u"兼容格式不包含材质 ID。")
        entries = _legacy_entries(data)
        source_names = sorted(set(name for entry in entries for name in entry))
        source_rules, saved_bone_limit = {}, None
        cap = max([1] + [len(e) for e in entries])
    kind = _mesh_kind(node)
    vertex_count, face_count = _mesh_counts(node, kind)
    if not modern and len(entries) != vertex_count:
        raise ValueError(u"兼容格式顶点数与目标不一致。")
    if modern and method == 'uv' and not _map_supported(node, kind, uv_channel):
        raise ValueError(u"目标模型没有 UV 通道 {}。".format(uv_channel))
    skin = _skin_modifier(node, activate=False)
    groups = _scene_name_groups()
    names, mapping, issues = _virtual_bones(skin, source_names, groups, explicit, source_rules, naming_rules)
    reference_names = list(names)
    if side_pair is not None:
        if (not isinstance(side_pair, (list, tuple)) or len(side_pair) != 2
                or any(not isinstance(n, _STRING_TYPES) for n in side_pair)):
            raise ValueError(u"参考对必须是 Left/Right 原始名称二元组。")
        for name in side_pair:
            if name not in reference_names:
                reference_names.append(name)
    reference_error = None
    try:
        reference = _reference(reference_names, side_pair, groups, epsilon_side, naming_rules, pose)
    except ValueError as exc:
        reference = None
        reference_error = _text(exc)
    report = {key: 0 for key in ('hit', 'no_uv', 'far', 'written', 'preserved', 'eligible',
                                'no_side', 'center_ambiguous', 'overlap_ambiguous', 'ambiguous',
                                'invalid_reference', 'degenerate_uv', 'lost_weight_sum')}
    semantics = [sem.parse_name(n, source_rules) for n in source_names]
    report.update(mapping_issues=issues, missing_bones=[], vertex_reasons={},
                  unrecognized_bones=[n for n, s in zip(source_names, semantics) if s['side'] == 'Unspecified'],
                  conflict_bones=[n for n, s in zip(source_names, semantics) if s['side'] == 'Conflict'])
    results, missing = {}, set()
    use_side = modern and data['version'] == 3 and method == 'uv' and disambiguation == 'side' and reference is not None and data.get('sideReference') is not None
    if modern and method == 'uv' and disambiguation == 'side' and not use_side:
        report['invalid_reference'] = 1
        report['reference_warning'] = u"没有完整的源/目标参考平面，仅检查候选一致性；v2 请重新导出 v3。"
        if reference_error:
            report['reference_warning'] += u'\n' + reference_error
    if modern and method == 'uv':
        index = _build_uv_index(data)
        report['degenerate_uv'] = len(data['faces']) - len(index[0])
        samples = [set() for unused in range(vertex_count)]
        sides = [sem.classify_side(sem.side_coordinate(_world_position(node, kind, i), reference), epsilon_side)
                 if use_side else 'Unknown' for i in range(vertex_count)]
        for face_id in range(face_count):
            corners = _face_corners(node, kind, face_id)
            map_ids = _map_face(node, kind, uv_channel, face_id)
            if len(corners) != len(map_ids):
                raise ValueError(u"目标面角点与 UV 数量不一致。")
            material = _face_material(node, kind, face_id) if use_material else None
            for corner, vertex_id in enumerate(corners):
                uv = _map_vertex(node, kind, uv_channel, map_ids[corner])
                uv = _flip_u(uv) if flip_u else uv
                samples[vertex_id].add((tuple(uv), sides[vertex_id], material))
        for vertex_id, vertex_samples in enumerate(samples):
            values, reasons, lost = [], set(), 0.0
            if not vertex_samples:
                reasons.add('no_uv')
            for uv, side, material in sorted(vertex_samples):
                weights, reason, omitted, loss = sem.resolve_candidates(
                    data, _query_uv(uv, index), side, mapping, epsilon=epsilon_side,
                    tolerance=tolerance, material_id=material, use_side=use_side)
                missing.update(omitted)
                lost += loss
                if reason != 'ok':
                    reasons.add(reason)
                else:
                    values.append(weights)
            loss = lost / max(1, len(vertex_samples))
            report['lost_weight_sum'] += loss
            if loss:
                report['vertex_reasons'][vertex_id] = {'reasons': [], 'lost_weight': loss}
            if reasons:
                report['vertex_reasons'][vertex_id] = {'reasons': sorted(reasons), 'lost_weight': loss}
                for reason in reasons:
                    report[reason] = report.get(reason, 0) + 1
                continue
            averaged = {}
            for weights in values:
                for bone, w in weights.items():
                    averaged[bone] = averaged.get(bone, 0.0) + w / len(values)
            if averaged:
                results[vertex_id] = _normalize_weights(averaged, cap)
    elif modern:
        # 保留独立的最近源点距离算法。
        point_index = _build_point_index(data['positions'])
        for vertex_id in range(vertex_count):
            source_id = _nearest_source_vertex(point_index, _world_position(node, kind, vertex_id))
            if source_id is None:
                report['no_uv'] += 1
                continue
            weights = {}
            for source_bone, w in data['weights'][source_id]:
                if source_bone in mapping:
                    target = mapping[source_bone]
                    weights[target] = weights.get(target, 0.0) + w
                elif w > 0:
                    missing.add(source_names[source_bone])
            if weights:
                results[vertex_id] = _normalize_weights(weights, cap)
    else:
        source_ids = {name: i for i, name in enumerate(source_names)}
        for vertex_id, entry in enumerate(entries):
            weights = {}
            for name, w in entry.items():
                if not _valid_number(w) or w < 0:
                    raise ValueError(u"兼容格式权重不是合法非负数值。")
                target = mapping.get(source_ids[name])
                if target is None:
                    if w > 0:
                        missing.add(name)
                else:
                    weights[target] = weights.get(target, 0.0) + w
            normalized = _normalize_weights(weights, cap)
            if normalized:
                results[vertex_id] = normalized
    report['hit'] = report['eligible'] = len(results)
    if skin is not None and write_mode in ('unweighted', 'blend'):
        existing_names = _skin_bones(skin)
        for vertex_id, incoming in list(results.items()):
            pairs = _skin_vertex_weights(skin, vertex_id)
            if write_mode == 'unweighted':
                if sum(w for unused, w in pairs) > 1e-8:
                    del results[vertex_id]
                    report['vertex_reasons'][vertex_id] = {'reasons': ['already_weighted'], 'lost_weight': 0.0}
            else:
                current = {}
                for actual_id, w in pairs:
                    name = existing_names[actual_id]
                    if names.count(name) != 1:
                        raise ValueError(u"混合权重的现有骨骼原名不唯一：{}".format(name))
                    virtual_id = names.index(name) + 1
                    current[virtual_id] = current.get(virtual_id, 0.0) + w
                combined = {b: 0.5 * (current.get(b, 0.0) + incoming.get(b, 0.0))
                            for b in set(current).union(incoming)}
                results[vertex_id] = _normalize_weights(combined, cap)
    for vertex_id in range(vertex_count):
        if vertex_id not in report['vertex_reasons']:
            report['vertex_reasons'][vertex_id] = {'reasons': [] if vertex_id in results else ['no_weights'], 'lost_weight': 0.0}
    report.update(would_write=len(results), preserved=vertex_count - len(results), missing_bones=sorted(missing))
    for vertex_id, weights in results.items():
        if (not weights or any(not _valid_index(b) or b < 1 or b > len(names)
                              or not _valid_number(w) or w < 0 for b, w in weights.items())
                or abs(sum(weights.values()) - 1.0) > 1e-5):
            raise ValueError(u"计算结果权重或虚拟骨骼 ID 无效。")
    if preview or not results:
        return report
    required_ids = sorted(set(b for w in results.values() for b in w))
    for bone_id in required_ids:
        _unique_node(names[bone_id - 1], groups)
    redraw_disabled, hold_started = False, False
    try:
        rt.disableSceneRedraw()
        redraw_disabled = True
        rt.theHold.Begin()
        hold_started = True
        skin = _skin_modifier(node, create=True)
        for bone_id in required_ids:
            name = names[bone_id - 1]
            actual_names = _skin_bones(skin)
            if name not in actual_names:
                rt.skinOps.addBone(skin, _unique_node(name, groups), 0)
        actual_names = _skin_bones(skin)
        remap = {}
        for bone_id in required_ids:
            name = names[bone_id - 1]
            if actual_names.count(name) != 1:
                raise ValueError(u"写入 Skin 骨骼原名不唯一：{}".format(name))
            remap[bone_id] = actual_names.index(name) + 1
        if saved_bone_limit and not _set_bone_limit(skin, saved_bone_limit):
            raise RuntimeError(u"不能设置 Skin boneLimit，已撤销本次导入。")
        for vertex_id, weights in sorted(results.items()):
            ids = sorted(weights)
            rt.skinOps.ReplaceVertexWeights(skin, vertex_id + 1,
                                           rt.Array(*[remap[b] for b in ids]),
                                           rt.Array(*[weights[b] for b in ids]))
        rt.theHold.Accept(u"UV权重复制")
        hold_started = False
        report['written'] = len(results)
    except Exception:
        if hold_started:
            rt.theHold.Cancel()
        raise
    finally:
        if redraw_disabled:
            rt.enableSceneRedraw()
            rt.redrawViews()
    return report


def _host_main_window():
    if HOST == "3dsmax":
        if qtmax is not None:
            return qtmax.GetQMaxMainWindow()
        if MaxPlus is not None:
            for name in ("GetQMaxMainWindow", "GetQMaxWindow"):
                getter = getattr(MaxPlus, name, None)
                if getter is not None:
                    return getter()
    return None


def _bind_max_window(dialog):
    import ctypes

    win_id = dialog.winId()
    try:
        hwnd = int(win_id)
    except (TypeError, ValueError):
        # Max 2015 的 PySide 返回 PyCObject，而不是整数 HWND。
        as_void_ptr = ctypes.pythonapi.PyCObject_AsVoidPtr
        as_void_ptr.restype = ctypes.c_void_p
        as_void_ptr.argtypes = [ctypes.py_object]
        hwnd = as_void_ptr(win_id)
    user32 = ctypes.windll.user32
    setter = user32.SetWindowLongPtrW if ctypes.sizeof(ctypes.c_void_p) == 8 else user32.SetWindowLongW
    setter.restype = ctypes.c_ssize_t
    setter.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_ssize_t]
    # 设置顶层窗口的 owner，保持工具窗口跟随 Max，但仍可独立移动。
    setter(hwnd, -8, int(MaxPlus.Win32.GetMAXHWnd()))


def _set_accelerators(enabled):
    """Max 2015 及旧版本会抢输入框按键（加速键），窗口激活时需临时关闭。"""
    if HOST != "3dsmax":
        return
    if MaxPlus is not None:
        try:
            action = MaxPlus.CUI.EnableAccelerators if enabled else MaxPlus.CUI.DisableAccelerators
            action()
            return
        except Exception:
            pass
    if rt is not None:
        try:
            action = rt.enableAccelerators if enabled else rt.disableAccelerators
            action()
        except Exception:
            pass


def _is_text_input(widget):
    for name in ('QLineEdit', 'QAbstractSpinBox'):
        cls = getattr(QtWidgets, name, None)
        if cls is not None and isinstance(widget, cls):
            return True
    return False


class _AcceleratorGuard(QtCore.QObject):
    """参考 BipedAinmPicker_FBXmap：文本框获得焦点时关闭 Max 加速键，否则按键会被 Max 吞掉。"""

    def eventFilter(self, obj, event):
        kind = event.type()
        if kind in (QtCore.QEvent.FocusIn, QtCore.QEvent.FocusOut) and _is_text_input(obj):
            _set_accelerators(kind == QtCore.QEvent.FocusOut)
        return False


_ACCELERATOR_GUARD = None


def _install_accelerator_guard():
    global _ACCELERATOR_GUARD
    app = QtWidgets.QApplication.instance()
    if app is None or _ACCELERATOR_GUARD is not None:
        return
    _ACCELERATOR_GUARD = _AcceleratorGuard()
    app.installEventFilter(_ACCELERATOR_GUARD)


class SkinUVTransferDialog(QtWidgets.QDialog):
    def __init__(self, parent=None):
        QtWidgets.QDialog.__init__(self, parent)
        self.setWindowTitle(u"DIYFace UV 空间蒙皮权重复制")
        self.resize(480, 300)
        self.node = None
        layout = QtWidgets.QVBoxLayout(self)
        form = QtWidgets.QFormLayout()
        layout.addLayout(form)

        node_row = QtWidgets.QHBoxLayout()
        self.node_label = QtWidgets.QLabel(u"未选择", self)
        node_button = QtWidgets.QPushButton(u"使用当前选择", self)
        node_button.clicked.connect(self._pick_node)
        node_row.addWidget(self.node_label, 1)
        node_row.addWidget(node_button)
        form.addRow(u"处理模型", node_row)

        self.channel = QtWidgets.QSpinBox(self)
        self.channel.setRange(1, 99)
        self.channel.setValue(1)
        form.addRow(u"UV 通道", self.channel)
        self.mode = QtWidgets.QComboBox(self)
        self.mode.addItem(u"UV v3（跨拓扑/消歧）", "uv")
        self.mode.addItem(u"兼容格式（按顶点序号）", "legacy")
        form.addRow(u"导出模式", self.mode)

        path_row = QtWidgets.QHBoxLayout()
        self.path = QtWidgets.QLineEdit(self)
        open_button = QtWidgets.QPushButton(u"选择文件...", self)
        open_button.clicked.connect(self._browse_open)
        save_button = QtWidgets.QPushButton(u"另存为...", self)
        save_button.clicked.connect(self._browse_save)
        path_row.addWidget(self.path, 1)
        path_row.addWidget(open_button)
        path_row.addWidget(save_button)
        form.addRow(u"权重文件", path_row)

        self.write_mode = QtWidgets.QComboBox(self)
        self.write_mode.addItem(u"覆盖", "overwrite")
        self.write_mode.addItem(u"仅未加权", "unweighted")
        self.write_mode.addItem(u"混合", "blend")
        form.addRow(u"写入模式", self.write_mode)
        self.association = QtWidgets.QComboBox(self)
        self.association.addItem(u"UV 空间", "uv")
        self.association.addItem(u"3D 距离（最近点）", "distance")
        form.addRow(u"复制方式", self.association)
        self.flip_u = QtWidgets.QCheckBox(u"目标 UV 水平翻转（U）", self)
        self.flip_u.setToolTip(u"源模型与目标模型的 UV 左右镜像时勾选。")
        self.disambiguation = QtWidgets.QComboBox(self)
        self.disambiguation.addItem(u"骨骼左右 + 候选一致性", 'side')
        self.disambiguation.addItem(u"仅候选一致性", 'consistency')
        uv_row = QtWidgets.QHBoxLayout()
        uv_row.addWidget(self.flip_u)
        uv_row.addWidget(QtWidgets.QLabel(u"消歧", self))
        uv_row.addWidget(self.disambiguation)
        form.addRow(u"UV 镜像与消歧", uv_row)
        self.material = QtWidgets.QCheckBox(u"启用材质 ID 备选（源/目标含义必须相同）", self)
        self.material.setChecked(False)
        form.addRow(u"材质分区", self.material)
        pair_row = QtWidgets.QHBoxLayout()
        parse_button = QtWidgets.QPushButton(u"骨骼解析预览", self)
        parse_button.setToolTip(u"列出全部左右候选骨骼对；实际使用哪一对由消歧方式自动选择。")
        parse_button.clicked.connect(self._parse_bones)
        pair_row.addWidget(parse_button)
        self.pair_label = QtWidgets.QLabel(u"参考对：未选择模型", self)
        self.pair_label.setWordWrap(True)
        pair_row.addWidget(self.pair_label, 1)
        form.addRow(u"当前模型参考对", pair_row)
        self.disambiguation.currentIndexChanged.connect(self._refresh_pair_label)
        self.left_marker = QtWidgets.QLineEdit(self)
        self.right_marker = QtWidgets.QLineEdit(self)
        self.left_marker.setText('_L_')
        self.right_marker.setText('_R_')
        for editor in (self.left_marker, self.right_marker):
            editor.setToolTip(u'直接输入标识，不用引号；区分大小写，字面替换，不使用正则。两个均留空为自动解析模式。')
            editor.editingFinished.connect(self._refresh_markers)
        marker_row = QtWidgets.QHBoxLayout()
        marker_row.addWidget(QtWidgets.QLabel(u"左", self))
        marker_row.addWidget(self.left_marker)
        marker_row.addWidget(QtWidgets.QLabel(u"右", self))
        marker_row.addWidget(self.right_marker)
        form.addRow(u"骨骼命名镜像标识", marker_row)
        marker_help = QtWidgets.QLabel(u'导出设源模型标识；导入设目标模型标识，源规则自动读取。仅判别骨骼名称，不交换权重或镜像 U。', self)
        marker_help.setWordWrap(True)
        form.addRow(marker_help)
        self.marker_error = QtWidgets.QLabel('', self)
        self.marker_error.setWordWrap(True)
        form.addRow(self.marker_error)

        buttons = QtWidgets.QHBoxLayout()
        export_button = QtWidgets.QPushButton(u"导出权重", self)
        import_button = QtWidgets.QPushButton(u"导入权重", self)
        export_button.clicked.connect(self._export)
        import_button.clicked.connect(lambda: self._import(False))
        preview_button = QtWidgets.QPushButton(u"预览（不修改场景）", self)
        preview_button.clicked.connect(lambda: self._import(True))
        buttons.addWidget(preview_button)
        buttons.addWidget(export_button)
        buttons.addWidget(import_button)
        layout.addLayout(buttons)
        self.status = QtWidgets.QLabel(u"就绪。", self)
        self.status.setWordWrap(True)
        layout.addWidget(self.status)
        contact = QtWidgets.QLabel(u"天晴数码 | 联系邮箱：738746223@qq.com", self)
        contact.setAlignment(QtCore.Qt.AlignRight | QtCore.Qt.AlignVCenter)
        layout.addWidget(contact)

    def _pick_node(self):
        try:
            _require_max()
            selected = list(rt.selection)
            if not selected:
                QtWidgets.QMessageBox.information(self, u"选择节点", u"请先在场景中选择一个模型节点。")
                return
            self.node = selected[0]
            self.node_label.setText(_text(self.node.name))
            self._refresh_pair_label()
        except Exception as exc:
            message = _text(exc)
            self.status.setText(message)
            QtWidgets.QMessageBox.critical(self, u"读取选择失败", message)

    def _browse_open(self):
        path, unused_filter = QtWidgets.QFileDialog.getOpenFileName(
            self, u"选择权重文件", self.path.text(), u"JSON 文件 (*.json)")
        if path:
            self.path.setText(path)

    def _browse_save(self):
        default_path = ""
        if self.node is not None:
            default_path = os.path.join(u"C:/TempWeight", _text(self.node.name) + u"_skinweights.json")
        path, unused_filter = QtWidgets.QFileDialog.getSaveFileName(
            self, u"保存权重文件", default_path, u"JSON 文件 (*.json)")
        if path:
            if not path.lower().endswith(".json"):
                path += ".json"
            self.path.setText(path)

    def _export(self):
        try:
            if self.node is None:
                raise RuntimeError(u"请先选择处理模型。")
            path = _text(self.path.text()).strip()
            if not path:
                path = os.path.join(u"C:/TempWeight", _text(self.node.name) + u"_skinweights.json")
            options = self._reference_options()
            parent = os.path.dirname(os.path.abspath(path))
            if not os.path.isdir(parent):
                os.makedirs(parent)
            self.path.setText(path)
            result = export_weights(self.node, path, uv_channel=self.channel.value(),
                                    mode=_combo_data(self.mode), **options)
            self.status.setText(u"导出完成：{} 个顶点，模式 {}。".format(result["vertices"], result["mode"]))
        except Exception as exc:
            self.status.setText(_text(exc))
            QtWidgets.QMessageBox.critical(self, u"导出失败", _text(exc))

    def _current_names_rules(self):
        skin = _skin_modifier(self.node, activate=False) if self.node is not None else None
        groups = _scene_name_groups() if self.node is not None else {}
        names = []
        for name in (_skin_bones(skin) if skin is not None else []) + sorted(groups):
            if name not in names:
                names.append(name)
        rules = sem.build_marker_rules(names, _text(self.left_marker.text()),
                                       _text(self.right_marker.text()))
        return names, rules, groups

    def _refresh_markers(self):
        try:
            self._current_names_rules()
            self.marker_error.setText('')
        except Exception as exc:
            self.marker_error.setText(_text(exc))
        self._refresh_pair_label()

    def _refresh_pair_label(self, *args):
        if self.node is None:
            self.pair_label.setText(u"参考对：未选择模型")
            return
        if _combo_data(self.disambiguation) != 'side':
            self.pair_label.setText(u"参考对：未启用（仅候选一致性）")
            return
        try:
            names, rules, groups = self._current_names_rules()
            pair = _auto_side_pair(self.node, names, rules, groups)
        except Exception as exc:
            self.pair_label.setText(u"参考对：{}".format(_text(exc)))
            return
        if pair is None:
            self.pair_label.setText(u"参考对：未找到可用左右骨骼对")
        else:
            self.pair_label.setText(u"参考对：{} / {}".format(pair[0], pair[1]))

    def _reference_options(self):
        names, rules, groups = self._current_names_rules()
        pair = None
        if _combo_data(self.disambiguation) == 'side':
            pair = _auto_side_pair(self.node, names, rules, groups)
            if pair is None:
                raise ValueError(u"消歧方式为骨骼左右分区，但当前模型没有唯一且左右分离的骨骼对；"
                                 u"请检查镜像标识，或把消歧改为“仅候选一致性”。")
        return dict(side_pair=pair, naming_rules=rules)

    def _source_rules(self):
        path = _text(self.path.text()).strip()
        if not path or not os.path.isfile(path):
            return [], {}
        with io.open(path, 'r', encoding='utf-8') as input_file:
            data = json.load(input_file)
        if data.get('version') in (2, 3):
            data = _validate_v2(data)
            return data['bones'], data['sideNamingRules']['rules'] if data['version'] == 3 else {}
        return sorted(set(n for entry in _legacy_entries(data) for n in entry)), {}

    def _parse_bones(self):
        try:
            if self.node is None:
                raise ValueError(u"请先选择处理模型。")
            names, rules, unused_groups = self._current_names_rules()
            pairs, issues = sem.pair_bones(names, rules)
            lines = [u"当前模型 {}: {}".format(n, sem.parse_name(n, rules)) for n in names]
            source_names, source_rules = self._source_rules()
            lines += [u"文件源 {}: {}".format(n, sem.parse_name(n, source_rules)) for n in source_names]
            lines += [u"参考对候选（仅供诊断）：{} / {}".format(names[l], names[r]) for l, r, unused in pairs]
            lines += issues
            self._details(u"骨骼解析", u"只读解析 {} 个名称，候选 {} 对；参考对由消歧方式自动选择。".format(len(names), len(pairs)), u'\n'.join(lines))
        except Exception as exc:
            QtWidgets.QMessageBox.critical(self, u"解析失败", _text(exc))

    def _details(self, title, summary, details):
        box = QtWidgets.QMessageBox(self)
        box.setWindowTitle(title)
        box.setIcon(QtWidgets.QMessageBox.Information)
        box.setText(summary)
        box.setDetailedText(details)
        box.setStandardButtons(QtWidgets.QMessageBox.Ok)
        execute = getattr(box, 'exec_', None) or getattr(box, 'exec')
        execute()

    def _import(self, preview=False):
        try:
            if self.node is None:
                raise RuntimeError(u"请先选择处理模型。")
            path = _text(self.path.text()).strip()
            if not path or not os.path.isfile(path):
                raise RuntimeError(u"请指定有效的权重 JSON 文件。")
            options = self._reference_options()
            result = import_weights(self.node, path, uv_channel=self.channel.value(),
                                    write_mode=_combo_data(self.write_mode),
                                    method=_combo_data(self.association), flip_u=self.flip_u.isChecked(),
                                    preview=preview,
                                    disambiguation=_combo_data(self.disambiguation), use_material=self.material.isChecked(),
                                    **options)
            message = u"{}：可写 {would_write}，实际写入 {written}，保留 {preserved}，UV 未覆盖 {no_uv}，歧义 {ambiguous}/{center_ambiguous}/{overlap_ambiguous}。".format(
                u"预览（场景未修改）" if preview else u"完成", **result)
            if preview:
                message += u" 保留数按正式可写数量计算，不代表预览已写入。"
            if result.get('reference_warning'):
                message += u'\n' + result['reference_warning']
            self.status.setText(message)
            self._details(u"预览结果" if preview else u"导入结果", message,
                          _text(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True)))
        except Exception as exc:
            self.status.setText(_text(exc))
            QtWidgets.QMessageBox.critical(self, u"预览失败" if preview else u"导入失败", _text(exc))

    def event(self, event):
        kind = event.type()
        if kind == QtCore.QEvent.WindowActivate:
            _set_accelerators(False)
        elif kind == QtCore.QEvent.WindowDeactivate:
            _set_accelerators(True)
        return QtWidgets.QDialog.event(self, event)

    def closeEvent(self, event):
        global _DIALOG
        _set_accelerators(True)
        if _DIALOG is self:
            _DIALOG = None
        event.accept()


def show_dialog():
    global _DIALOG, _APPLICATION
    if HOST != "3dsmax":
        raise RuntimeError(u"DIYFaceSkinUVTransfer 只能在 3ds Max 中运行。")
    if QtWidgets.QApplication.instance() is None:
        _APPLICATION = QtWidgets.QApplication([])
    if _DIALOG is not None:
        _DIALOG.close()
    legacy_window = isinstance(rt, _MaxPlusRuntime)
    _install_accelerator_guard()
    _DIALOG = SkinUVTransferDialog(None if legacy_window else _host_main_window())
    _DIALOG.setWindowFlags(QtCore.Qt.Window | QtCore.Qt.WindowCloseButtonHint)
    if legacy_window:
        _bind_max_window(_DIALOG)
    _DIALOG.show()
    _DIALOG.raise_()
    _DIALOG.activateWindow()
    return _DIALOG


if __name__ == "__main__":
    show_dialog()

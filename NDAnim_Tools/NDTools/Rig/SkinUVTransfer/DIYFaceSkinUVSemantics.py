# -*- coding: utf-8 -*-
from __future__ import division

import math
import re

try:
    _STRINGS = (basestring,)
    _TEXT = unicode
    _INTEGERS = (int, long)
except NameError:
    _STRINGS = (str,)
    _TEXT = str
    _INTEGERS = (int,)

SIDES = ('Left', 'Right', 'Unspecified', 'Conflict')
STATUSES = ('parsed', 'unspecified', 'conflict', 'override')
REGIONS = ('Left', 'Right', 'Mixed', 'Unknown')
RULE_VERSION = 1


def _text(value):
    if isinstance(value, bytes) and not isinstance(value, _TEXT):
        return value.decode('utf-8')
    return _TEXT(value)


def _number(value):
    if isinstance(value, bool) or not isinstance(value, _INTEGERS + (float,)):
        return False
    try:
        return not math.isnan(value) and not math.isinf(value)
    except (ValueError, OverflowError):
        return False


def _index(value, count=None):
    return (not isinstance(value, bool) and isinstance(value, _INTEGERS)
            and value >= 0 and (count is None or value < count))


def _vector(value):
    return (isinstance(value, (list, tuple)) and len(value) == 3
            and all(_number(v) for v in value))


def clean_name(name):
    """解码三位 FBXASC 编码，移除层级和命名空间并转为小写。"""
    if not isinstance(name, _STRINGS):
        raise ValueError('Bone name must be text')
    value = re.sub(r'FBXASC([0-9]{3})', lambda m: _codepoint(int(m.group(1))),
                   _text(name), flags=re.I)
    return re.split(r'[|:]', value)[-1].strip().lower()


def _codepoint(value):
    try:
        return unichr(value)
    except NameError:
        return chr(value)


def _display_name(name):
    value = re.sub(r'FBXASC([0-9]{3})', lambda m: _codepoint(int(m.group(1))),
                   _text(name), flags=re.I)
    return re.split(r'[|:]', value)[-1].strip()


def build_marker_rules(names, left_marker, right_marker):
    """按大小写敏感的字面镜像标识生成原名覆盖规则；均为空时使用自动解析。"""
    if not isinstance(left_marker, _STRINGS) or not isinstance(right_marker, _STRINGS):
        raise ValueError(u'左右镜像标识必须是字符串。')
    left_marker, right_marker = _text(left_marker), _text(right_marker)
    if not left_marker and not right_marker:
        return {}
    if not left_marker or not right_marker:
        raise ValueError(u'左右镜像标识必须同时填写，或同时留空使用自动解析。')
    if left_marker in right_marker or right_marker in left_marker:
        raise ValueError(u'左右镜像标识不能相同或互相包含。')
    rules = {}
    for name in names:
        if not isinstance(name, _STRINGS):
            raise ValueError('Bone name must be text')
        value = _display_name(name)
        left, right = left_marker in value, right_marker in value
        if left and right:
            raise ValueError(u'骨骼同时包含左右镜像标识：{}'.format(name))
        if left or right:
            marker = left_marker if left else right_marker
            rules[name] = {'side': 'Left' if left else 'Right',
                           'base': value.replace(marker, '{side}').lower()}
    return rules


def _check_rules(rules):
    if rules is None:
        return
    if not isinstance(rules, dict):
        raise ValueError('Naming rules must be a dictionary')
    for name, rule in rules.items():
        if not isinstance(name, _STRINGS):
            raise ValueError('Naming rule keys must be original names')
        side = rule.get('side') if isinstance(rule, dict) else rule
        if side not in SIDES[:3]:
            raise ValueError('Invalid naming rule side')
        if isinstance(rule, dict):
            if set(rule) - set(('side', 'base')):
                raise ValueError('Unknown naming rule field')
            if 'base' in rule and (not isinstance(rule['base'], _STRINGS)
                                   or not rule['base'].strip()):
                raise ValueError('Naming rule base must be nonempty text')


def parse_name(name, rules=None):
    """返回侧别、基础名称和解析状态。

    侧别标记原位替换为 {side}，保留分隔符。
    覆盖规则以未修改的原名为键，不使用清理后的名称。
    """
    if not isinstance(name, _STRINGS):
        raise ValueError('Bone name must be text')
    _check_rules(rules)
    value = _display_name(name)
    # 保留分隔符，转小写前识别驼峰边界。
    tokens = re.finditer(r'[A-Za-z0-9]+', value)
    hits = []
    for token in tokens:
        word = token.group(0)
        for part in re.finditer(r'[A-Z]+(?=[A-Z][a-z]|[0-9]|$)|[A-Z]?[a-z]+|[0-9]+', word):
            text = part.group(0).lower()
            if text in ('left', 'right', 'l', 'r'):
                hits.append((token.start() + part.start(), token.start() + part.end(),
                             'Left' if text in ('left', 'l') else 'Right'))
    sides = set(hit[2] for hit in hits)
    side = next(iter(sides)) if len(sides) == 1 else ('Conflict' if sides else 'Unspecified')
    base = value
    for start, end, unused in reversed(hits):
        base = base[:start] + '{side}' + base[end:]
    result = {'side': side, 'base': base.lower(),
              'status': 'conflict' if side == 'Conflict' else
              ('unspecified' if side == 'Unspecified' else 'parsed')}
    if rules is not None and name in rules:
        rule = rules[name]
        result['side'] = rule['side'] if isinstance(rule, dict) else rule
        if isinstance(rule, dict) and 'base' in rule:
            result['base'] = rule['base'].strip().lower()
        result['status'] = 'override'
    return result


def pair_bones(names, rules=None):
    groups, issues = {}, []
    for index, name in enumerate(names):
        item = parse_name(name, rules)
        if item['side'] == 'Conflict':
            issues.append('Conflicting side markers: {}'.format(name))
        elif item['side'] in ('Left', 'Right'):
            group = groups.setdefault(item['base'], {'Left': [], 'Right': []})
            group[item['side']].append(index)
    pairs = []
    for base in sorted(groups):
        group = groups[base]
        if any(len(group[side]) > 1 for side in ('Left', 'Right')):
            issues.append('Duplicate side for base: {}'.format(base))
        elif group['Left'] and group['Right']:
            pairs.append((group['Left'][0], group['Right'][0], base))
        else:
            issues.append('Missing partner for base: {}'.format(base))
    return pairs, issues


def _groups(values):
    result = {}
    for index, value in enumerate(values):
        result.setdefault(value, []).append(index)
    return result


def map_bones(source_names, target_names, explicit=None, source_rules=None, target_rules=None):
    """将从零开始的源索引唯一映射到从一开始的目标索引。

    显式原名映射可跨侧，但不能任意选择重名骨骼；自动匹配不跨侧。
    """
    explicit = {} if explicit is None else explicit
    if not isinstance(explicit, dict) or any(not isinstance(k, _STRINGS)
                                            or not isinstance(v, _STRINGS)
                                            for k, v in explicit.items()):
        raise ValueError('Explicit mappings must map original names to original names')
    source = [parse_name(n, source_rules) for n in source_names]
    target = [parse_name(n, target_rules) for n in target_names]
    sr, tr = _groups(source_names), _groups(target_names)
    sc = _groups([clean_name(n) for n in source_names])
    tc = _groups([clean_name(n) for n in target_names])
    ss = _groups([(p['base'], p['side']) for p in source])
    ts = _groups([(p['base'], p['side']) for p in target])
    mapping, issues = {}, []
    for name in sorted(explicit):
        if name not in sr:
            issues.append('Missing explicit source: {}'.format(name))
    for i, name in enumerate(source_names):
        if len(sr[name]) != 1:
            issues.append('Duplicate original source: {}'.format(name))
            continue
        if name in explicit:
            choices = tr.get(explicit[name], [])
            if len(choices) == 1:
                mapping[i] = choices[0] + 1
            else:
                issues.append('Missing or duplicate explicit target: {}'.format(explicit[name]))
            continue
        item = source[i]
        key = clean_name(name)
        if item['side'] == 'Conflict':
            issues.append('Conflicting source side: {}'.format(name))
            continue
        choices = tr.get(name, [])
        exact = bool(choices)
        if len(choices) > 1:
            issues.append('Duplicate original target: {}'.format(name))
            continue
        if not choices:
            if len(sc[key]) != 1 or len(tc.get(key, [])) > 1:
                issues.append('Normalized name collision: {}'.format(name))
                continue
            choices = tc.get(key, [])
        if not choices:
            semantic = (item['base'], item['side'])
            if len(ss[semantic]) != 1 or len(ts.get(semantic, [])) > 1:
                issues.append('Semantic name collision: {}'.format(name))
                continue
            choices = ts.get(semantic, [])
        if not choices:
            issues.append('Missing target bone: {}'.format(name))
        elif target[choices[0]]['side'] == 'Conflict' or target[choices[0]]['side'] != item['side']:
            issues.append('Conflicting or cross-side target: {}'.format(name))
        elif (not exact and (len(tr[target_names[choices[0]]]) != 1
                             or len(tc[clean_name(target_names[choices[0]])]) != 1)):
            issues.append('Target name collision: {}'.format(name))
        else:
            mapping[i] = choices[0] + 1
            if exact and (len(sc[key]) > 1 or len(tc[key]) > 1):
                issues.append('Normalized collision resolved by unique original name: {}'.format(name))
    return mapping, issues


def make_reference(left_index, right_index, left_position, right_position, epsilon=0.001, pose=''):
    """用从零开始的骨骼索引和无量纲容差构建参考。"""
    if not _index(left_index) or not _index(right_index) or left_index == right_index:
        raise ValueError('Reference bone indices must be distinct nonnegative integers')
    if not _vector(left_position) or not _vector(right_position):
        raise ValueError('Reference positions must be finite 3-vectors')
    if not _number(epsilon) or epsilon < 0 or not isinstance(pose, _STRINGS):
        raise ValueError('Invalid reference epsilon or pose')
    left, right = list(map(float, left_position)), list(map(float, right_position))
    delta = [l - r for l, r in zip(left, right)]
    scale = max(abs(v) for v in delta)
    if not _number(scale) or scale == 0:
        raise ValueError('Degenerate reference bone pair')
    spacing = scale * math.sqrt(sum((v / scale) ** 2 for v in delta))
    center = [l * 0.5 + r * 0.5 for l, r in zip(left, right)]
    if not _number(spacing) or spacing <= 0 or not _vector(center):
        raise ValueError('Nonfinite reference geometry')
    return {'leftBone': left_index, 'rightBone': right_index,
            'leftPosition': left, 'rightPosition': right, 'center': center,
            'direction': [v / spacing for v in delta], 'spacing': spacing,
            'epsilon': float(epsilon), 'pose': pose}


def side_coordinate(position, reference):
    if reference is None or not _vector(position) or not isinstance(reference, dict):
        return None
    if (not _vector(reference.get('center')) or not _vector(reference.get('direction'))
            or not _number(reference.get('spacing')) or reference['spacing'] <= 0):
        return None
    terms = [((float(p) - c) / reference['spacing']) * n
             for p, c, n in zip(position, reference['center'], reference['direction'])]
    if not all(_number(v) for v in terms):
        return None
    try:
        value = math.fsum(terms)
    except (OverflowError, ValueError):
        return None
    return value if _number(value) else None


def classify_side(d, epsilon):
    if not _number(d) or not _number(epsilon) or epsilon < 0:
        return 'Unknown'
    return 'Left' if d > epsilon else ('Right' if d < -epsilon else 'CenterBand')


def _region(values, epsilon):
    sides = [classify_side(v, epsilon) for v in values]
    if 'Unknown' in sides:
        return 'Unknown'
    if all(s == 'Left' for s in sides):
        return 'Left'
    if all(s == 'Right' for s in sides):
        return 'Right'
    return 'Mixed'


def _close(a, b):
    return abs(a - b) <= 1e-8 * max(1.0, abs(a), abs(b))


def validate_v3(data):
    """校验 v3 新增字段并返回数据，无效时抛出 ValueError。

    名称规则包含版本号及以原名为键的规则，骨骼语义沿用名称解析状态。
    全在中线带内的面归为混合区；参考索引从零开始。v2 校验独立进行。
    """
    if not isinstance(data, dict) or not _index(data.get('version')) or data['version'] != 3:
        raise ValueError('Expected version 3')
    required = ('boneSemantics', 'sideReference', 'vertexSideCoordinates',
                'faceRegions', 'sideNamingRules')
    if any(k not in data for k in required):
        raise ValueError('Missing v3 field')
    for key in ('bones', 'weights', 'positions', 'faces', 'boneSemantics',
                'vertexSideCoordinates', 'faceRegions'):
        if not isinstance(data.get(key), list):
            raise ValueError('Invalid list field: {}'.format(key))
    bones, positions, faces = data['bones'], data['positions'], data['faces']
    coords, regions = data['vertexSideCoordinates'], data['faceRegions']
    if (len(data['boneSemantics']) != len(bones) or len(coords) != len(data['weights'])
            or len(coords) != len(positions) or len(regions) != len(faces)):
        raise ValueError('Mismatched v3 array lengths')
    envelope = data['sideNamingRules']
    if (not isinstance(envelope, dict) or set(envelope) != set(('version', 'rules'))
            or not _index(envelope.get('version')) or envelope['version'] != RULE_VERSION
            or not isinstance(envelope.get('rules'), dict)):
        raise ValueError('Unsupported naming rule version or structure')
    _check_rules(envelope['rules'])
    for name, item in zip(bones, data['boneSemantics']):
        if (not isinstance(item, dict) or set(item) != set(('side', 'base', 'status'))
                or item.get('side') not in SIDES or item.get('status') not in STATUSES
                or not isinstance(item.get('base'), _STRINGS) or not item['base'].strip()):
            raise ValueError('Invalid bone semantics')
        if item != parse_name(name, envelope['rules']):
            raise ValueError('Bone semantics inconsistent with naming rules')
    # 严格检查旧版 v2 校验器通过类型转换接受的索引类型。
    for face in faces:
        if not isinstance(face, (list, tuple)) or len(face) != 3 or any(not _index(i, len(coords)) for i in face):
            raise ValueError('Invalid face index')
    for weights in data['weights']:
        if not isinstance(weights, list):
            raise ValueError('Invalid weights list')
        for pair in weights:
            if (not isinstance(pair, (list, tuple)) or len(pair) != 2
                    or not _index(pair[0], len(bones))):
                raise ValueError('Invalid weight bone index')
    if any(not _vector(p) for p in positions):
        raise ValueError('Nonfinite source positions')
    if any(v is not None and not _number(v) for v in coords) or any(r not in REGIONS for r in regions):
        raise ValueError('Invalid side coordinate or face region')
    if 'faceMaterialIds' in data:
        materials = data['faceMaterialIds']
        if not isinstance(materials, list) or len(materials) != len(faces) or any(not _index(v) for v in materials):
            raise ValueError('Invalid face material IDs')
    reference = data['sideReference']
    if reference is None:
        if any(v is not None for v in coords) or any(r != 'Unknown' for r in regions):
            raise ValueError('Null reference requires null coordinates and Unknown regions')
        return data
    fields = ('leftBone', 'rightBone', 'leftPosition', 'rightPosition', 'center',
              'direction', 'spacing', 'epsilon', 'pose')
    if not isinstance(reference, dict) or set(reference) != set(fields):
        raise ValueError('Invalid reference structure')
    if not _index(reference['leftBone'], len(bones)) or not _index(reference['rightBone'], len(bones)):
        raise ValueError('Invalid reference bone index')
    if (data['boneSemantics'][reference['leftBone']]['side'] != 'Left'
            or data['boneSemantics'][reference['rightBone']]['side'] != 'Right'):
        raise ValueError('Reference bones must have Left/Right semantics')
    expected = make_reference(reference['leftBone'], reference['rightBone'],
                              reference['leftPosition'], reference['rightPosition'],
                              reference['epsilon'], reference['pose'])
    for key in ('center', 'direction'):
        if not _vector(reference[key]) or any(not _close(a, b) for a, b in zip(reference[key], expected[key])):
            raise ValueError('Reference {} inconsistent with bone positions'.format(key))
    if (not _number(reference['spacing']) or reference['spacing'] <= 0
            or abs(reference['spacing'] / expected['spacing'] - 1.0) > 1e-8):
        raise ValueError('Reference spacing inconsistent with bone positions')
    for position, value in zip(positions, coords):
        calculated = side_coordinate(position, expected)
        cached = side_coordinate(position, reference)
        if (value is None or calculated is None or cached is None
                or not _close(value, calculated) or not _close(value, cached)
                or classify_side(value, expected['epsilon']) != classify_side(calculated, expected['epsilon'])
                or classify_side(value, expected['epsilon']) != classify_side(cached, expected['epsilon'])):
            raise ValueError('Side coordinate inconsistent with source position')
    for face, region in zip(faces, regions):
        if region != _region([coords[i] for i in face], expected['epsilon']):
            raise ValueError('Face region inconsistent with side coordinates')
    return data


def resolve_candidates(data, candidates, target_side, mapping, epsilon=0.001,
                       tolerance=1e-5, material_id=None, use_side=True):
    """返回目标权重字典（索引从一开始）或空值、原因、缺失名称及丢失比例。

    候选沿用主脚本的三角形与重心坐标格式，可通过材质或面索引读取材质 ID。
    源侧别使用源参考容差，而非目标容差；比较时保留缺失骨骼的源索引标识。
    """
    if not _number(tolerance) or tolerance < 0 or not _number(epsilon) or epsilon < 0:
        raise ValueError('Invalid candidate tolerance or epsilon')
    if not isinstance(mapping, dict) or any(not _index(k, len(data['bones']))
                                           or not _index(v) or v == 0 for k, v in mapping.items()):
        raise ValueError('Mapping must use zero-based source and one-based target indices')
    candidates = list(candidates)
    if not candidates:
        return None, 'no_uv', [], 0.0
    coords = data.get('vertexSideCoordinates', [])
    reference = data.get('sideReference')
    source_epsilon = reference.get('epsilon', epsilon) if isinstance(reference, dict) else epsilon
    retained = []
    for tri, bary in candidates:
        ids = tri['ids']
        if (len(ids) != 3 or any(not _index(i, len(data['weights'])) for i in ids)
                or len(bary) != 3 or any(not _number(v) or v < 0 for v in bary)
                or not _close(math.fsum(bary), 1.0)):
            raise ValueError('Invalid candidate triangle or barycentric coefficients')
        if material_id is not None:
            material = tri.get('materialId', tri.get('material'))
            face_id = tri.get('faceId', tri.get('face_id'))
            if material is None and _index(face_id, len(data.get('faceMaterialIds', []))):
                material = data['faceMaterialIds'][face_id]
            if material is None and 'faceMaterialIds' in data:
                matches = [data['faceMaterialIds'][i] for i, face in enumerate(data['faces']) if list(face) == list(ids)]
                if matches and len(set(matches)) == 1:
                    material = matches[0]
            if material != material_id:
                continue
        side = 'Unknown'
        if use_side and coords and all(i < len(coords) and _number(coords[i]) for i in ids):
            side = classify_side(math.fsum(coords[i] * b for i, b in zip(ids, bary)), source_epsilon)
        contributions = {}
        for vertex, factor in zip(ids, bary):
            for bone, weight in data['weights'][vertex]:
                if not _index(bone, len(data['bones'])) or not _number(weight) or weight < 0:
                    raise ValueError('Invalid source weight')
                if weight > 0 and factor > 0:
                    key = ('target', mapping[bone]) if bone in mapping else ('missing', bone)
                    contributions.setdefault(key, []).append(float(weight) * factor)
        vector = {key: math.fsum(values) for key, values in contributions.items()}
        total = math.fsum(vector.values())
        if not _number(total):
            raise ValueError('Nonfinite interpolated weight')
        retained.append((side, vector, total))
    if not retained:
        return None, 'no_uv', [], 0.0
    if use_side and target_side in ('Left', 'Right'):
        if any(side != 'Unknown' for side, unused, total in retained):
            retained = [item for item in retained if item[0] == target_side]
            if not retained:
                return None, 'no_side', [], 0.0
    elif use_side and target_side == 'CenterBand':
        center = [item for item in retained if item[0] == 'CenterBand']
        if center:
            retained = center
    missing_ids = sorted(set(key[1] for side, vector, total in retained for key in vector if key[0] == 'missing'))
    missing_names = [data['bones'][i] for i in missing_ids]
    total_raw = math.fsum(sorted(item[2] for item in retained))
    missing_raw = math.fsum(sorted(value for side, vector, total in retained
                                   for key, value in vector.items() if key[0] == 'missing'))
    lost = missing_raw / total_raw if total_raw > 0 else 0.0
    if any(total <= 0 for side, vector, total in retained):
        return None, 'no_weights', missing_names, lost
    normalized = [{key: value / total for key, value in vector.items()}
                  for side, vector, total in retained]
    keys = set(key for vector in normalized for key in vector)
    # 用各分量极差比较所有候选对，而非只与首个候选比较。
    if any(max(v.get(key, 0.0) for v in normalized) - min(v.get(key, 0.0) for v in normalized) > tolerance for key in keys):
        reason = 'ambiguous'
        if use_side and target_side == 'CenterBand':
            reason = 'center_ambiguous'
        elif use_side and target_side in ('Left', 'Right') and any(item[0] != 'Unknown' for item in retained):
            reason = 'overlap_ambiguous'
        return None, reason, missing_names, lost
    # 排序求和项以消除候选顺序影响，仅对一致的候选取平均。
    averaged = {key: math.fsum(sorted(v.get(key, 0.0) for v in normalized)) / len(normalized)
                for key in sorted(keys) if key[0] == 'target'}
    total = math.fsum(averaged.values())
    if total <= 0:
        return None, 'no_weights', missing_names, lost
    return {key[1]: value / total for key, value in averaged.items()}, 'ok', missing_names, lost

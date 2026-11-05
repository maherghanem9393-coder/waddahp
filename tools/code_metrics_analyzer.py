#!/usr/bin/env python3
"""
أداة التحليل الساكن للشيفرة البرمجية (Static Code Metrics Analyzer)
لحساب المؤشرات المعتمدة في الفصل الثالث من الأطروحة:
1. حجم الشيفرة البرمجية الفعلية (Lines of Code - LOC) بعد استبعاد الأسطر الفارغة والتعليقات.
2. درجة التعقيد الدوري (Cyclomatic Complexity - McCabe's CC).
3. نسبة الشيفرة الزائدة (Boilerplate Ratio %) المرتبطة بتهيئة وربط آلية إدارة الحالة.
"""

import os
import re
import json

DECISION_KEYWORDS = [
    r'\bif\b',
    r'\bfor\b',
    r'\bwhile\b',
    r'\bcase\b',
    r'\bcatch\b',
    r'&&',
    r'\|\|',
    r'\?[^\.:]',  # ternary operator ?:
    r'\?\?',      # null-coalescing operator ??
]

def analyze_dart_file(filepath: str) -> dict:
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    total_lines = len(lines)
    loc = 0
    comment_lines = 0
    blank_lines = 0
    boilerplate_lines = 0
    in_block_comment = False

    code_only_lines = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            blank_lines += 1
            continue

        if in_block_comment:
            comment_lines += 1
            if '*/' in stripped:
                in_block_comment = False
            continue

        if stripped.startswith('//'):
            comment_lines += 1
            continue

        if stripped.startswith('/*'):
            comment_lines += 1
            if '*/' not in stripped:
                in_block_comment = True
            continue

        loc += 1
        code_only_lines.append(stripped)

        if (
            stripped.startswith('import ')
            or stripped.startswith('part ')
            or stripped.startswith('export ')
            or stripped.startswith('@override')
            or 'List<Object?> get props' in stripped
            or 'copyWith(' in stripped
            or stripped in ('{', '}', ');', '];', 'return state;')
            or 'super(' in stripped
            or 'extends Equatable' in stripped
            or 'extends ItemsEvent' in stripped
            or 'extends ReduxAction' in stripped
        ):
            boilerplate_lines += 1

    cc = 1
    joined_code = '\n'.join(code_only_lines)
    for pattern in DECISION_KEYWORDS:
        matches = re.findall(pattern, joined_code)
        cc += len(matches)

    return {
        'file': os.path.basename(filepath),
        'path': filepath,
        'total_lines': total_lines,
        'loc': loc,
        'comments': comment_lines,
        'blanks': blank_lines,
        'cyclomatic_complexity': cc,
        'boilerplate_loc': boilerplate_lines,
        'boilerplate_ratio_pct': round((boilerplate_lines / loc * 100.0), 2) if loc > 0 else 0.0,
    }


def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    groups = {
        'Shared_MVVM_Core': [
            'lib/model/item.dart',
            'lib/data/items_data_source.dart',
            'lib/data/items_repository.dart',
            'lib/viewmodel/items_view_state.dart',
            'lib/viewmodel/items_view_model.dart',
            'lib/view/items_page.dart',
        ],
        'MVVM_BLoC_Layer': [
            'lib/viewmodel/bloc/items_event.dart',
            'lib/viewmodel/bloc/items_state.dart',
            'lib/viewmodel/bloc/items_bloc.dart',
            'lib/viewmodel/bloc/bloc_items_view_model.dart',
        ],
        'MVVM_Redux_Layer': [
            'lib/viewmodel/redux/items_actions.dart',
            'lib/viewmodel/redux/items_redux_state.dart',
            'lib/viewmodel/redux/items_reducer.dart',
            'lib/viewmodel/redux/items_middleware.dart',
            'lib/viewmodel/redux/redux_items_view_model.dart',
        ],
    }

    report = {}
    for group_name, rel_paths in groups.items():
        items = []
        for rp in rel_paths:
            full_p = os.path.join(base_dir, rp)
            if os.path.exists(full_p):
                items.append(analyze_dart_file(full_p))
        total_loc = sum(x['loc'] for x in items)
        total_cc = sum(x['cyclomatic_complexity'] for x in items)
        total_bp = sum(x['boilerplate_loc'] for x in items)
        report[group_name] = {
            'files': items,
            'summary': {
                'file_count': len(items),
                'total_loc': total_loc,
                'total_cyclomatic_complexity': total_cc,
                'avg_cyclomatic_complexity_per_file': round(total_cc / len(items), 2) if items else 0,
                'total_boilerplate_loc': total_bp,
                'boilerplate_percentage': round(total_bp / total_loc * 100.0, 2) if total_loc > 0 else 0.0,
            },
        }

    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()

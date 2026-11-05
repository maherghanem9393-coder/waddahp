#!/usr/bin/env python3
"""
سكريبت التحليل الإحصائي الوصفي والاستدلالي (الفصل الثالث - القسم 3.10)
يقوم بقراءة ملف CSV المُصدّر من التطبيق التجريبي وحساب:
1. المتوسط الحسابي (Mean) والانحراف المعياري (Standard Deviation - SD)
2. نسبة الفرق المئوية (Percentage Difference - PD%)
3. اختبار اعتدالية التوزيع (Shapiro-Wilk Normality Test)
4. اختبار الفروق الإحصائية عند مستوى دلالة α = 0.05:
   - اختبار t للعينات المستقلة (Independent Samples t-test) عند تحقق الاعتدالية
   - اختبار Mann-Whitney U اللامعلمي عند عدم تحقق الاعتدالية
5. حجم التأثير العملي (Cohen's d Effect Size) وتفسيره (صغير / متوسط / كبير)
"""

import sys
import math
import csv
from collections import defaultdict

try:
    from scipy import stats as scipy_stats
    HAS_SCIPY = True
except ImportError:
    HAS_SCIPY = False

def mean(vals):
    return sum(vals) / len(vals) if vals else 0.0

def std_dev(vals, m=None):
    if len(vals) <= 1:
        return 0.0
    if m is None:
        m = mean(vals)
    return math.sqrt(sum((x - m) ** 2 for x in vals) / (len(vals) - 1))

def percentage_diff(v1, v2):
    avg = (v1 + v2) / 2.0
    return (abs(v1 - v2) / avg) * 100.0 if avg != 0 else 0.0

def cohens_d(vals1, vals2):
    n1, n2 = len(vals1), len(vals2)
    if n1 + n2 <= 2:
        return 0.0
    m1, m2 = mean(vals1), mean(vals2)
    s1, s2 = std_dev(vals1, m1), std_dev(vals2, m2)
    pooled_var = (((n1 - 1) * s1 ** 2) + ((n2 - 1) * s2 ** 2)) / (n1 + n2 - 2)
    pooled_sd = math.sqrt(pooled_var)
    return (m1 - m2) / pooled_sd if pooled_sd != 0 else 0.0

def interpret_d(d_val: float) -> str:
    ad = abs(d_val)
    if ad < 0.2:
        return "ضئيل (Negligible)"
    elif ad < 0.5:
        return "صغير (Small)"
    elif ad < 0.8:
        return "متوسط (Medium)"
    return "كبير (Large)"

def run_inferential_tests(vals1, vals2, alpha=0.05):
    if not HAS_SCIPY or len(vals1) < 3 or len(vals2) < 3:
        return {
            'test_used': 'N/A (Requires scipy & n>=3)',
            'p_value': None,
            'significant': False,
        }
    _, p_norm1 = scipy_stats.shapiro(vals1)
    _, p_norm2 = scipy_stats.shapiro(vals2)
    both_normal = (p_norm1 >= alpha) and (p_norm2 >= alpha)

    if both_normal:
        stat, p_val = scipy_stats.ttest_ind(vals1, vals2, equal_var=False)
        test_name = 'Independent t-test'
    else:
        stat, p_val = scipy_stats.mannwhitneyu(vals1, vals2, alternative='two-sided')
        test_name = 'Mann-Whitney U'

    return {
        'shapiro_p_bloc': round(float(p_norm1), 4),
        'shapiro_p_redux': round(float(p_norm2), 4),
        'both_normal': both_normal,
        'test_used': test_name,
        'statistic': round(float(stat), 4),
        'p_value': round(float(p_val), 5),
        'significant_at_0_05': bool(p_val < alpha),
    }

def analyze_csv(csv_path: str):
    data = defaultdict(lambda: defaultdict(list))
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            scenario = row['Scenario']
            arch = row['Architecture']
            rt = float(row['ResponseTimeMs'])
            data[scenario][arch].append(rt)

    header = (
        f"{'Scenario':<20} | {'BLoC Mean±SD':<17} | {'Redux Mean±SD':<17} | "
        f"{'PD %':<7} | {'Test Used':<18} | {'p-value':<8} | {'Cohen d'}"
    )
    print(header)
    print("-" * len(header))
    for scenario, arch_map in data.items():
        bloc_vals = arch_map.get('MVVM+BLoC', [])
        redux_vals = arch_map.get('MVVM+Redux', [])
        if not bloc_vals or not redux_vals:
            continue
        m_b, sd_b = mean(bloc_vals), std_dev(bloc_vals)
        m_r, sd_r = mean(redux_vals), std_dev(redux_vals)
        pd = percentage_diff(m_b, m_r)
        d = cohens_d(bloc_vals, redux_vals)
        inf = run_inferential_tests(bloc_vals, redux_vals)
        p_str = f"{inf['p_value']:.4f}" if inf['p_value'] is not None else "N/A"
        sig_mark = "*" if inf.get('significant_at_0_05') else ""
        print(
            f"{scenario:<20} | {m_b:6.2f}±{sd_b:5.2f} ms | {m_r:6.2f}±{sd_r:5.2f} ms | "
            f"{pd:5.2f}% | {inf['test_used']:<18} | {p_str:<7}{sig_mark} | {d:6.3f} ({interpret_d(d)})"
        )

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 statistical_analysis.py <benchmark_results.csv>")
    else:
        analyze_csv(sys.argv[1])

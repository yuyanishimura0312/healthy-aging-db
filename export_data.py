#!/usr/bin/env python3
"""Export healthy aging DB to JSON for visualization."""
import sqlite3
import json
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'healthy_aging.db')
OUT_PATH = os.path.join(os.path.dirname(__file__), 'visualizer', 'data.js')

def dict_factory(cursor, row):
    return {col[0]: row[idx] for idx, col in enumerate(cursor.description)}

def export():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = dict_factory
    cur = conn.cursor()

    # Factors as nodes
    cur.execute("SELECT * FROM factors ORDER BY layer, domain")
    factors = cur.fetchall()

    # Relations as edges
    cur.execute("SELECT * FROM factor_relations")
    relations = cur.fetchall()

    # Feedback loops
    cur.execute("SELECT * FROM feedback_loops")
    loops = cur.fetchall()

    # Interventions
    cur.execute("""
        SELECT i.*, GROUP_CONCAT(it.factor_id) as target_factor_ids
        FROM interventions i
        LEFT JOIN intervention_targets it ON i.id = it.intervention_id
        GROUP BY i.id
    """)
    interventions = cur.fetchall()

    # Transition points
    cur.execute("SELECT * FROM transition_points")
    transitions = cur.fetchall()

    # Theoretical frameworks
    cur.execute("SELECT * FROM theoretical_frameworks")
    frameworks = cur.fetchall()

    # Measurement indicators
    cur.execute("SELECT * FROM measurement_indicators")
    indicators = cur.fetchall()

    # Survey frame coverage
    cur.execute("SELECT * FROM survey_frame WHERE level = 1")
    coverage = cur.fetchall()

    # Stats
    stats = {
        'total_factors': len(factors),
        'total_relations': len(relations),
        'total_interventions': len(interventions),
        'macro_count': sum(1 for f in factors if f['layer'] == 'macro'),
        'meso_count': sum(1 for f in factors if f['layer'] == 'meso'),
        'micro_count': sum(1 for f in factors if f['layer'] == 'micro'),
    }

    data = {
        'factors': factors,
        'relations': relations,
        'feedback_loops': loops,
        'interventions': interventions,
        'transition_points': transitions,
        'frameworks': frameworks,
        'indicators': indicators,
        'coverage': coverage,
        'stats': stats,
    }

    conn.close()

    with open(OUT_PATH, 'w', encoding='utf-8') as f:
        f.write('const DB_DATA = ')
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write(';\n')

    print(f"Exported to {OUT_PATH}")
    print(f"  Factors: {stats['total_factors']} (macro:{stats['macro_count']}, meso:{stats['meso_count']}, micro:{stats['micro_count']})")
    print(f"  Relations: {stats['total_relations']}")
    print(f"  Interventions: {stats['total_interventions']}")

if __name__ == '__main__':
    export()

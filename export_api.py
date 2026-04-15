#!/usr/bin/env python3
"""Export all API responses as static JSON for GitHub Pages deployment."""
import sqlite3
import json
import os

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'healthy_aging.db')
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'docs')

def dict_factory(cursor, row):
    return {col[0]: row[idx] for idx, col in enumerate(cursor.description)}

def build_survey_tree(frames):
    by_id = {f['id']: {**f, 'children': []} for f in frames}
    roots = []
    for f in frames:
        node = by_id[f['id']]
        if f['parent_id'] and f['parent_id'] in by_id:
            by_id[f['parent_id']]['children'].append(node)
        elif f['level'] == 1:
            roots.append(node)
    return roots

def export():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = dict_factory
    cur = conn.cursor()

    # === stats.json ===
    cur.execute("SELECT layer, domain, COUNT(*) as cnt FROM factors GROUP BY layer, domain ORDER BY layer, domain")
    layer_domain = cur.fetchall()
    cur.execute("SELECT layer, COUNT(*) as cnt FROM factors GROUP BY layer")
    layer_totals = {r['layer']: r['cnt'] for r in cur.fetchall()}
    cur.execute("SELECT name_ja, name_en, estimated_unit_count, actual_count FROM survey_frame WHERE level = 1")
    coverage = cur.fetchall()
    for c in coverage:
        c['coverage_pct'] = round(c['actual_count'] * 100 / max(c['estimated_unit_count'], 1), 1)
    cur.execute("SELECT relation_type, COUNT(*) as cnt FROM factor_relations GROUP BY relation_type ORDER BY cnt DESC")
    relation_types = cur.fetchall()
    cur.execute("SELECT COUNT(*) as cnt FROM factor_relations")
    total_relations = cur.fetchone()['cnt']
    cur.execute("SELECT COUNT(*) as cnt FROM factor_relations WHERE effect_size_value IS NOT NULL")
    relations_with_effect = cur.fetchone()['cnt']
    cur.execute("SELECT evidence_level, COUNT(*) as cnt FROM factor_relations WHERE evidence_level IS NOT NULL GROUP BY evidence_level ORDER BY cnt DESC")
    evidence_dist = cur.fetchall()
    cur.execute("SELECT intervention_type, COUNT(*) as cnt FROM interventions GROUP BY intervention_type ORDER BY cnt DESC")
    intervention_types = cur.fetchall()
    cur.execute("SELECT COUNT(*) as cnt FROM interventions")
    total_interventions = cur.fetchone()['cnt']
    cur.execute("SELECT modifiability, COUNT(*) as cnt FROM factors WHERE modifiability IS NOT NULL GROUP BY modifiability")
    modifiability = cur.fetchall()
    cur.execute("SELECT domain, COUNT(*) as cnt FROM factors GROUP BY domain ORDER BY cnt DESC")
    domains = cur.fetchall()
    cur.execute("SELECT * FROM feedback_loops")
    loops = cur.fetchall()
    cur.execute("SELECT * FROM transition_points")
    transitions = cur.fetchall()
    cur.execute("SELECT * FROM theoretical_frameworks ORDER BY year_proposed")
    frameworks = cur.fetchall()
    cur.execute("SELECT * FROM measurement_indicators")
    indicators = cur.fetchall()
    cur.execute("SELECT academic_table, COUNT(*) as cnt FROM academic_db_links GROUP BY academic_table")
    academic_links = cur.fetchall()
    cur.execute("SELECT COUNT(*) as cnt FROM academic_db_links")
    total_links = cur.fetchone()['cnt']
    cur.execute("SELECT COUNT(*) as total FROM factors")
    total_factors = cur.fetchone()['total']
    factor_cols = ['definition', 'description', 'modifiability', 'time_scale', 'evidence_strength',
                   'key_statistic', 'key_statistic_source', 'keywords_ja', 'keywords_en']
    col_fill = []
    for col in factor_cols:
        cur.execute(f"SELECT COUNT(*) as cnt FROM factors WHERE {col} IS NOT NULL AND {col} != ''")
        cnt = cur.fetchone()['cnt']
        col_fill.append({'column': col, 'filled': cnt, 'total': total_factors,
                        'pct': round(cnt * 100 / max(total_factors, 1), 1)})
    cur.execute("SELECT * FROM survey_frame ORDER BY level, id")
    frames = cur.fetchall()
    tree = build_survey_tree(frames)
    cur.execute("""
        SELECT f.id, f.name_ja, f.name_en, f.layer, f.domain,
               (SELECT COUNT(*) FROM factor_relations WHERE source_factor_id = f.id OR target_factor_id = f.id) as connections
        FROM factors f ORDER BY connections DESC LIMIT 10
    """)
    top_connected = cur.fetchall()

    stats = {
        'total_factors': total_factors, 'total_relations': total_relations,
        'total_interventions': total_interventions, 'total_links': total_links,
        'relations_with_effect': relations_with_effect,
        'layer_totals': layer_totals, 'layer_domain': layer_domain,
        'coverage': coverage, 'relation_types': relation_types,
        'evidence_dist': evidence_dist, 'intervention_types': intervention_types,
        'modifiability': modifiability, 'domains': domains,
        'loops': loops, 'transitions': transitions,
        'frameworks': frameworks, 'indicators': indicators,
        'academic_links': academic_links,
        'col_fill': col_fill, 'survey_tree': tree,
        'top_connected': top_connected,
    }

    # === factors.json (all factors) ===
    cur.execute("SELECT * FROM factors ORDER BY name_ja")
    all_factors = cur.fetchall()

    # Subdomains
    cur.execute("SELECT DISTINCT subdomain FROM factors WHERE subdomain IS NOT NULL ORDER BY subdomain")
    subdomains = [r['subdomain'] for r in cur.fetchall()]

    factors_data = {
        'records': all_factors,
        'total': len(all_factors),
        'page': 1,
        'pages': 1,
        'subdomains': subdomains,
    }

    # === factor details (one JSON per factor) ===
    os.makedirs(os.path.join(OUT_DIR, 'api'), exist_ok=True)

    factor_details = {}
    for f in all_factors:
        fid = f['id']
        cur.execute("""
            SELECT r.*, fs.name_ja as source_name, ft.name_ja as target_name
            FROM factor_relations r
            LEFT JOIN factors fs ON r.source_factor_id = fs.id
            LEFT JOIN factors ft ON r.target_factor_id = ft.id
            WHERE r.source_factor_id = ? OR r.target_factor_id = ?
            ORDER BY r.strength DESC
        """, [fid, fid])
        relations = cur.fetchall()
        cur.execute("""
            SELECT i.* FROM interventions i
            JOIN intervention_targets it ON i.id = it.intervention_id
            WHERE it.factor_id = ?
        """, [fid])
        interventions = cur.fetchall()
        cur.execute("SELECT * FROM academic_db_links WHERE local_id = ?", [fid])
        links = cur.fetchall()
        factor_details[fid] = {
            'factor': f, 'relations': relations,
            'interventions': interventions, 'academic_links': links,
        }

    conn.close()

    # Write static JSON files
    with open(os.path.join(OUT_DIR, 'api', 'stats.json'), 'w', encoding='utf-8') as fp:
        json.dump(stats, fp, ensure_ascii=False, default=str)

    with open(os.path.join(OUT_DIR, 'api', 'factors.json'), 'w', encoding='utf-8') as fp:
        json.dump(factors_data, fp, ensure_ascii=False, default=str)

    with open(os.path.join(OUT_DIR, 'api', 'factor_details.json'), 'w', encoding='utf-8') as fp:
        json.dump(factor_details, fp, ensure_ascii=False, default=str)

    print(f"Exported to {OUT_DIR}/api/")
    print(f"  stats.json: dashboard data")
    print(f"  factors.json: {len(all_factors)} factors")
    print(f"  factor_details.json: {len(factor_details)} detail records")

if __name__ == '__main__':
    export()

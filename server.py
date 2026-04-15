#!/usr/bin/env python3
"""Healthy Aging DB Monitor Server - API + Static files."""
import http.server
import json
import sqlite3
import os
import urllib.parse

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'healthy_aging.db')
STATIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'docs')
PORT = 5202

def dict_factory(cursor, row):
    return {col[0]: row[idx] for idx, col in enumerate(cursor.description)}

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = dict_factory
    return conn

def api_stats():
    conn = get_db()
    cur = conn.cursor()

    # Factor counts by layer and domain
    cur.execute("SELECT layer, domain, COUNT(*) as cnt FROM factors GROUP BY layer, domain ORDER BY layer, domain")
    layer_domain = cur.fetchall()

    # Layer totals
    cur.execute("SELECT layer, COUNT(*) as cnt FROM factors GROUP BY layer")
    layer_totals = {r['layer']: r['cnt'] for r in cur.fetchall()}

    # Coverage from survey_frame
    cur.execute("SELECT name_ja, name_en, estimated_unit_count, actual_count FROM survey_frame WHERE level = 1")
    coverage = cur.fetchall()
    for c in coverage:
        c['coverage_pct'] = round(c['actual_count'] * 100 / max(c['estimated_unit_count'], 1), 1)

    # Relation stats
    cur.execute("SELECT relation_type, COUNT(*) as cnt FROM factor_relations GROUP BY relation_type ORDER BY cnt DESC")
    relation_types = cur.fetchall()
    cur.execute("SELECT COUNT(*) as cnt FROM factor_relations")
    total_relations = cur.fetchone()['cnt']
    cur.execute("SELECT COUNT(*) as cnt FROM factor_relations WHERE effect_size_value IS NOT NULL")
    relations_with_effect = cur.fetchone()['cnt']

    # Evidence level distribution
    cur.execute("SELECT evidence_level, COUNT(*) as cnt FROM factor_relations WHERE evidence_level IS NOT NULL GROUP BY evidence_level ORDER BY cnt DESC")
    evidence_dist = cur.fetchall()

    # Intervention stats
    cur.execute("SELECT intervention_type, COUNT(*) as cnt FROM interventions GROUP BY intervention_type ORDER BY cnt DESC")
    intervention_types = cur.fetchall()
    cur.execute("SELECT COUNT(*) as cnt FROM interventions")
    total_interventions = cur.fetchone()['cnt']

    # Modifiability distribution
    cur.execute("SELECT modifiability, COUNT(*) as cnt FROM factors WHERE modifiability IS NOT NULL GROUP BY modifiability")
    modifiability = cur.fetchall()

    # Domain distribution
    cur.execute("SELECT domain, COUNT(*) as cnt FROM factors GROUP BY domain ORDER BY cnt DESC")
    domains = cur.fetchall()

    # Feedback loops
    cur.execute("SELECT * FROM feedback_loops")
    loops = cur.fetchall()

    # Transition points
    cur.execute("SELECT * FROM transition_points")
    transitions = cur.fetchall()

    # Frameworks
    cur.execute("SELECT * FROM theoretical_frameworks ORDER BY year_proposed")
    frameworks = cur.fetchall()

    # Indicators
    cur.execute("SELECT * FROM measurement_indicators")
    indicators = cur.fetchall()

    # Academic DB links
    cur.execute("SELECT academic_table, COUNT(*) as cnt FROM academic_db_links GROUP BY academic_table")
    academic_links = cur.fetchall()
    cur.execute("SELECT COUNT(*) as cnt FROM academic_db_links")
    total_links = cur.fetchone()['cnt']

    # Data completeness distribution
    cur.execute("""
        SELECT
            CASE
                WHEN data_completeness >= 70 THEN 'high'
                WHEN data_completeness >= 40 THEN 'medium'
                ELSE 'low'
            END as level,
            COUNT(*) as cnt
        FROM factors
        WHERE data_completeness IS NOT NULL
        GROUP BY level
    """)
    completeness_dist = cur.fetchall()

    # Column fill rates for factors
    factor_cols = ['definition', 'description', 'modifiability', 'time_scale', 'evidence_strength',
                   'key_statistic', 'key_statistic_source', 'keywords_ja', 'keywords_en']
    cur.execute("SELECT COUNT(*) as total FROM factors")
    total_factors = cur.fetchone()['total']
    col_fill = []
    for col in factor_cols:
        cur.execute(f"SELECT COUNT(*) as cnt FROM factors WHERE {col} IS NOT NULL AND {col} != ''")
        cnt = cur.fetchone()['cnt']
        col_fill.append({'column': col, 'filled': cnt, 'total': total_factors,
                        'pct': round(cnt * 100 / max(total_factors, 1), 1)})

    # Survey frame tree
    cur.execute("SELECT * FROM survey_frame ORDER BY level, id")
    frames = cur.fetchall()
    tree = build_survey_tree(frames)

    # Top factors by connections
    cur.execute("""
        SELECT f.id, f.name_ja, f.name_en, f.layer, f.domain,
               (SELECT COUNT(*) FROM factor_relations WHERE source_factor_id = f.id OR target_factor_id = f.id) as connections
        FROM factors f
        ORDER BY connections DESC
        LIMIT 10
    """)
    top_connected = cur.fetchall()

    conn.close()

    return {
        'total_factors': total_factors,
        'total_relations': total_relations,
        'total_interventions': total_interventions,
        'total_links': total_links,
        'relations_with_effect': relations_with_effect,
        'layer_totals': layer_totals,
        'layer_domain': layer_domain,
        'coverage': coverage,
        'relation_types': relation_types,
        'evidence_dist': evidence_dist,
        'intervention_types': intervention_types,
        'modifiability': modifiability,
        'domains': domains,
        'loops': loops,
        'transitions': transitions,
        'frameworks': frameworks,
        'indicators': indicators,
        'academic_links': academic_links,
        'completeness_dist': completeness_dist,
        'col_fill': col_fill,
        'survey_tree': tree,
        'top_connected': top_connected,
    }

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

def api_factors(params):
    conn = get_db()
    cur = conn.cursor()

    layer = params.get('layer', [''])[0]
    domain = params.get('domain', [''])[0]
    q = params.get('q', [''])[0]
    sort = params.get('sort', ['name_ja'])[0]
    order = params.get('order', ['asc'])[0]
    page = int(params.get('page', ['1'])[0])
    per_page = int(params.get('per_page', ['50'])[0])

    allowed_sorts = ['name_ja', 'name_en', 'layer', 'domain', 'modifiability', 'evidence_strength', 'data_completeness']
    if sort not in allowed_sorts:
        sort = 'name_ja'
    if order not in ('asc', 'desc'):
        order = 'asc'

    where = []
    args = []
    if layer:
        where.append("layer = ?")
        args.append(layer)
    if domain:
        where.append("domain = ?")
        args.append(domain)
    if q:
        where.append("(name_ja LIKE ? OR name_en LIKE ? OR keywords_ja LIKE ? OR definition LIKE ?)")
        args.extend([f'%{q}%'] * 4)

    where_sql = ' WHERE ' + ' AND '.join(where) if where else ''

    cur.execute(f"SELECT COUNT(*) as cnt FROM factors{where_sql}", args)
    total = cur.fetchone()['cnt']

    cur.execute(f"SELECT * FROM factors{where_sql} ORDER BY {sort} {order} LIMIT ? OFFSET ?",
                args + [per_page, (page - 1) * per_page])
    records = cur.fetchall()

    # Subdomains for filter
    cur.execute("SELECT DISTINCT subdomain FROM factors WHERE subdomain IS NOT NULL ORDER BY subdomain")
    subdomains = [r['subdomain'] for r in cur.fetchall()]

    conn.close()
    return {
        'records': records,
        'total': total,
        'page': page,
        'pages': max(1, (total + per_page - 1) // per_page),
        'subdomains': subdomains,
    }

def api_factor_detail(factor_id):
    conn = get_db()
    cur = conn.cursor()

    cur.execute("SELECT * FROM factors WHERE id = ?", [factor_id])
    factor = cur.fetchone()
    if not factor:
        conn.close()
        return {'error': 'not found'}

    # Relations
    cur.execute("""
        SELECT r.*, fs.name_ja as source_name, ft.name_ja as target_name
        FROM factor_relations r
        LEFT JOIN factors fs ON r.source_factor_id = fs.id
        LEFT JOIN factors ft ON r.target_factor_id = ft.id
        WHERE r.source_factor_id = ? OR r.target_factor_id = ?
        ORDER BY r.strength DESC
    """, [factor_id, factor_id])
    relations = cur.fetchall()

    # Interventions
    cur.execute("""
        SELECT i.*
        FROM interventions i
        JOIN intervention_targets it ON i.id = it.intervention_id
        WHERE it.factor_id = ?
    """, [factor_id])
    interventions = cur.fetchall()

    # Academic links
    cur.execute("SELECT * FROM academic_db_links WHERE local_id = ?", [factor_id])
    links = cur.fetchall()

    conn.close()
    return {
        'factor': factor,
        'relations': relations,
        'interventions': interventions,
        'academic_links': links,
    }

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=STATIC_DIR, **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        params = urllib.parse.parse_qs(parsed.query)

        if path == '/api/stats':
            self._json_response(api_stats())
        elif path == '/api/factors':
            self._json_response(api_factors(params))
        elif path.startswith('/api/factor/'):
            factor_id = urllib.parse.unquote(path[len('/api/factor/'):])
            self._json_response(api_factor_detail(factor_id))
        else:
            super().do_GET()

    def _json_response(self, data):
        body = json.dumps(data, ensure_ascii=False, default=str).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', len(body))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass  # Suppress logging

if __name__ == '__main__':
    print(f"Healthy Aging DB Monitor: http://localhost:{PORT}")
    server = http.server.HTTPServer(('', PORT), Handler)
    server.serve_forever()

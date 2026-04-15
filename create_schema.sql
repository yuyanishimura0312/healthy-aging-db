-- Healthy Life Expectancy Factors Database
-- Schema v1.0
-- Designed based on the integrated conceptual model
-- Compatible with v3 Academic Knowledge DB patterns

PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

-- ============================================================
-- Core Tables
-- ============================================================

-- Factors: central table for all determinants of healthy life expectancy
CREATE TABLE IF NOT EXISTS factors (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    layer TEXT NOT NULL CHECK(layer IN ('macro', 'meso', 'micro')),
    domain TEXT NOT NULL CHECK(domain IN (
        'biological', 'behavioral', 'psychosocial',
        'socioeconomic', 'environmental', 'healthcare_system'
    )),
    subdomain TEXT,
    definition TEXT,
    description TEXT,
    modifiability TEXT CHECK(modifiability IN (
        'non_modifiable', 'partially_modifiable', 'fully_modifiable'
    )),
    time_scale TEXT CHECK(time_scale IN ('acute', 'chronic', 'lifecourse')),
    evidence_strength TEXT CHECK(evidence_strength IN (
        'meta_analysis', 'rct', 'cohort', 'cross_sectional',
        'theoretical', 'expert_consensus'
    )),
    key_statistic TEXT,
    key_statistic_source TEXT,
    keywords_ja TEXT,
    keywords_en TEXT,
    status TEXT DEFAULT 'active',
    source_reliability TEXT DEFAULT 'secondary',
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

-- Factor relations: causal and associative relationships between factors
CREATE TABLE IF NOT EXISTS factor_relations (
    id TEXT PRIMARY KEY,
    source_factor_id TEXT NOT NULL REFERENCES factors(id),
    target_factor_id TEXT NOT NULL REFERENCES factors(id),
    relation_type TEXT NOT NULL CHECK(relation_type IN (
        'causal', 'associative', 'mediating', 'moderating',
        'bidirectional', 'protective', 'risk', 'enabling', 'inhibiting'
    )),
    direction TEXT CHECK(direction IN ('positive', 'negative', 'complex')),
    effect_size_type TEXT,
    effect_size_value REAL,
    effect_size_ci_lower REAL,
    effect_size_ci_upper REAL,
    evidence_level TEXT CHECK(evidence_level IN (
        'meta_analysis', 'rct', 'cohort', 'cross_sectional',
        'theoretical', 'expert_consensus'
    )),
    evidence_source TEXT,
    evidence_year INTEGER,
    sample_size INTEGER,
    feedback_loop_id TEXT,
    description TEXT,
    mechanism TEXT,
    strength INTEGER DEFAULT 5 CHECK(strength BETWEEN 1 AND 10),
    confidence TEXT DEFAULT 'medium' CHECK(confidence IN ('high', 'medium', 'low')),
    created_at TEXT DEFAULT (datetime('now'))
);

-- Interventions: evidence-based programs and policies
CREATE TABLE IF NOT EXISTS interventions (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    intervention_type TEXT NOT NULL CHECK(intervention_type IN (
        'exercise', 'nutrition', 'cognitive', 'social',
        'multicomponent', 'pharmacological', 'environmental',
        'policy', 'digital', 'screening'
    )),
    description TEXT,
    target_population TEXT,
    setting TEXT,
    duration TEXT,
    frequency TEXT,
    primary_outcome TEXT,
    effect_size_type TEXT,
    effect_size_value REAL,
    effect_size_description TEXT,
    cost_effectiveness TEXT,
    roi REAL,
    cost_per_participant TEXT,
    evidence_level TEXT,
    key_study TEXT,
    country TEXT,
    status TEXT DEFAULT 'active',
    created_at TEXT DEFAULT (datetime('now'))
);

-- Intervention targets: which factors an intervention targets
CREATE TABLE IF NOT EXISTS intervention_targets (
    intervention_id TEXT NOT NULL REFERENCES interventions(id),
    factor_id TEXT NOT NULL REFERENCES factors(id),
    target_type TEXT DEFAULT 'primary' CHECK(target_type IN ('primary', 'secondary', 'indirect')),
    mechanism TEXT,
    PRIMARY KEY (intervention_id, factor_id)
);

-- Evidence: individual studies and meta-analyses
CREATE TABLE IF NOT EXISTS evidence (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    title_ja TEXT,
    study_type TEXT NOT NULL CHECK(study_type IN (
        'meta_analysis', 'systematic_review', 'rct', 'cohort',
        'case_control', 'cross_sectional', 'ecological',
        'qualitative', 'mixed_methods'
    )),
    authors TEXT,
    journal TEXT,
    year INTEGER,
    doi TEXT,
    url TEXT,
    sample_size INTEGER,
    country TEXT,
    population TEXT,
    follow_up_years REAL,
    key_finding TEXT,
    key_finding_ja TEXT,
    effect_size_type TEXT,
    effect_size_value REAL,
    quality_score TEXT CHECK(quality_score IN ('high', 'moderate', 'low', 'very_low')),
    created_at TEXT DEFAULT (datetime('now'))
);

-- Transition points: critical life transitions affecting healthy aging
CREATE TABLE IF NOT EXISTS transition_points (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    description TEXT,
    typical_age_range TEXT,
    reversibility TEXT CHECK(reversibility IN (
        'reversible', 'partially_reversible', 'irreversible'
    )),
    reversibility_evidence TEXT,
    key_statistic TEXT,
    prevalence TEXT,
    intervention_window TEXT,
    optimal_interventions TEXT,     -- JSON array
    triggering_factors TEXT,        -- JSON array
    accelerating_factors TEXT,      -- JSON array
    protective_factors TEXT,        -- JSON array
    created_at TEXT DEFAULT (datetime('now'))
);

-- Feedback loops: positive and negative feedback cycles
CREATE TABLE IF NOT EXISTS feedback_loops (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    loop_type TEXT NOT NULL CHECK(loop_type IN ('positive', 'negative')),
    description TEXT,
    factor_sequence TEXT,           -- JSON array of factor IDs
    leverage_points TEXT,           -- JSON array
    breakability TEXT CHECK(breakability IN ('easy', 'moderate', 'difficult')),
    clinical_significance TEXT,
    intervention_strategy TEXT,
    created_at TEXT DEFAULT (datetime('now'))
);

-- Measurement indicators: metrics for healthy life expectancy
CREATE TABLE IF NOT EXISTS measurement_indicators (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    abbreviation TEXT,
    description TEXT,
    what_it_measures TEXT,
    methodology TEXT,
    data_source TEXT,
    frequency TEXT,
    japan_value_male REAL,
    japan_value_female REAL,
    japan_value_year INTEGER,
    global_average REAL,
    global_average_year INTEGER,
    created_at TEXT DEFAULT (datetime('now'))
);

-- Theoretical frameworks: academic frameworks informing the model
CREATE TABLE IF NOT EXISTS theoretical_frameworks (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    originator TEXT,
    year_proposed INTEGER,
    description TEXT,
    key_concepts TEXT,              -- JSON array
    discipline TEXT,
    db_relevance TEXT,
    created_at TEXT DEFAULT (datetime('now'))
);

-- Framework-factor links
CREATE TABLE IF NOT EXISTS framework_factor_links (
    framework_id TEXT NOT NULL REFERENCES theoretical_frameworks(id),
    factor_id TEXT NOT NULL REFERENCES factors(id),
    relevance_type TEXT,
    description TEXT,
    PRIMARY KEY (framework_id, factor_id)
);

-- Links to v3 Academic Knowledge DB
CREATE TABLE IF NOT EXISTS academic_db_links (
    id TEXT PRIMARY KEY,
    local_table TEXT NOT NULL,
    local_id TEXT NOT NULL,
    academic_table TEXT NOT NULL,
    academic_id TEXT NOT NULL,
    link_type TEXT DEFAULT 'related' CHECK(link_type IN (
        'related', 'derived_from', 'applies', 'extends'
    )),
    description TEXT,
    created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_factors_layer ON factors(layer);
CREATE INDEX IF NOT EXISTS idx_factors_domain ON factors(domain);
CREATE INDEX IF NOT EXISTS idx_factors_modifiability ON factors(modifiability);
CREATE INDEX IF NOT EXISTS idx_relations_source ON factor_relations(source_factor_id);
CREATE INDEX IF NOT EXISTS idx_relations_target ON factor_relations(target_factor_id);
CREATE INDEX IF NOT EXISTS idx_relations_type ON factor_relations(relation_type);
CREATE INDEX IF NOT EXISTS idx_relations_loop ON factor_relations(feedback_loop_id);
CREATE INDEX IF NOT EXISTS idx_interventions_type ON interventions(intervention_type);
CREATE INDEX IF NOT EXISTS idx_evidence_year ON evidence(year);
CREATE INDEX IF NOT EXISTS idx_evidence_type ON evidence(study_type);
CREATE INDEX IF NOT EXISTS idx_academic_links ON academic_db_links(academic_table, academic_id);

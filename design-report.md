# 健康寿命延伸要因データベース：設計レポート

## 1. 設計思想

### 1.1 目的

本データベースは、健康寿命延伸に関わるすべての要因とその因果関係を構造化し、以下の問いに回答できることを目指す。

- **ある要因の上流・下流には何があるか？**（因果連鎖の可視化）
- **最もエビデンスが強い介入は何か？**（介入の優先順位付け）
- **どの転換点でどの介入が有効か？**（タイミング最適化）
- **マクロ・メゾ・ミクロのどの層にレバレッジがあるか？**（システム思考的分析）
- **既存の学術理論とどう接続するか？**（v3学術知識DBとの連携）

### 1.2 設計原則

1. **三層構造の反映**：マクロ・メゾ・ミクロの概念モデルをスキーマに直接反映
2. **因果関係のファーストクラス化**：要因間の関係を独立テーブルで表現し、方向性・効果量・エビデンスレベルを格納
3. **v3 DBとの互換性**：既存の学術知識DBと同じ設計パターン（日英バイリンガル、UUID主キー、source_reliability等）を踏襲
4. **フィードバックループの表現**：双方向関係とループ識別子でシステムダイナミクスを表現
5. **修正可能性の明示**：各要因の介入可能性を明示し、政策立案に直結する設計

### 1.3 技術的選択

- **SQLite**：v3 DBとの一貫性、ポータビリティ、エージェントからのアクセス容易性
- **UUID主キー**：v3 DBと同じパターン
- **JSON型カラム**：複雑なメタデータ格納用（SQLiteのJSON1拡張）

---

## 2. データベーススキーマ

### 2.1 テーブル一覧

```
factors                   -- 要因（中心テーブル）
factor_relations          -- 要因間の因果・関連関係
interventions             -- 介入プログラム・施策
intervention_targets      -- 介入と対象要因の紐付け
evidence                  -- エビデンス（研究・メタ分析）
transition_points         -- クリティカル・トランジションポイント
feedback_loops            -- フィードバックループ（正・負）
measurement_indicators    -- 測定指標
theoretical_frameworks    -- 理論的枠組み
framework_factor_links    -- 理論と要因の紐付け
academic_db_links         -- v3学術知識DBへの参照
```

### 2.2 各テーブルの詳細設計

#### factors（要因）

統合的概念モデルの全要因を格納する中心テーブル。

```sql
CREATE TABLE factors (
    id TEXT PRIMARY KEY,              -- UUID
    name_ja TEXT NOT NULL,            -- 日本語名
    name_en TEXT,                     -- 英語名
    
    -- 三層分類
    layer TEXT NOT NULL               -- 'macro' / 'meso' / 'micro'
        CHECK(layer IN ('macro', 'meso', 'micro')),
    
    -- ドメイン分類（6領域）
    domain TEXT NOT NULL              -- 要因の主ドメイン
        CHECK(domain IN (
            'biological',             -- 生物学的
            'behavioral',             -- 行動・生活習慣
            'psychosocial',           -- 心理社会的
            'socioeconomic',          -- 社会経済的
            'environmental',          -- 環境
            'healthcare_system'       -- 医療・介護システム
        )),
    subdomain TEXT,                   -- サブドメイン（例：cellular, genetic, dietary等）
    
    -- 要因の特性
    definition TEXT,                  -- 定義
    description TEXT,                 -- 詳細説明
    modifiability TEXT                -- 修正可能性
        CHECK(modifiability IN (
            'non_modifiable',         -- 修正不可（遺伝、年齢）
            'partially_modifiable',   -- 部分的に修正可能（テロメア、炎症）
            'fully_modifiable'        -- 完全に修正可能（運動、食事）
        )),
    time_scale TEXT                   -- 時間尺度
        CHECK(time_scale IN (
            'acute',                  -- 急性（数日〜数週間）
            'chronic',                -- 慢性（数ヶ月〜数年）
            'lifecourse'              -- ライフコース（数十年）
        )),
    
    -- エビデンスの質
    evidence_strength TEXT            -- 最も強いエビデンスのレベル
        CHECK(evidence_strength IN (
            'meta_analysis',          -- メタ分析
            'rct',                    -- ランダム化比較試験
            'cohort',                 -- コホート研究
            'cross_sectional',        -- 横断研究
            'theoretical',            -- 理論的
            'expert_consensus'        -- 専門家合意
        )),
    
    -- 主要な定量的指標
    key_statistic TEXT,               -- 主要統計量（例："HR=0.57", "死亡リスク50%低下"）
    key_statistic_source TEXT,        -- その出典
    
    -- メタデータ
    keywords_ja TEXT,                 -- 日本語キーワード（カンマ区切り）
    keywords_en TEXT,                 -- 英語キーワード
    status TEXT DEFAULT 'active',     -- 'active' / 'deprecated'
    source_reliability TEXT DEFAULT 'secondary',
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);
```

#### factor_relations（要因間関係）

因果関係・関連関係を格納。フィードバックループ、媒介・調整関係も表現。

```sql
CREATE TABLE factor_relations (
    id TEXT PRIMARY KEY,
    source_factor_id TEXT NOT NULL REFERENCES factors(id),
    target_factor_id TEXT NOT NULL REFERENCES factors(id),
    
    -- 関係の種類
    relation_type TEXT NOT NULL
        CHECK(relation_type IN (
            'causal',                 -- 因果関係（A → B）
            'associative',            -- 関連（相関）
            'mediating',              -- 媒介（A → M → B）
            'moderating',             -- 調整（Aの効果をMが修飾）
            'bidirectional',          -- 双方向因果
            'protective',             -- 保護的（A → Bのリスク低下）
            'risk',                   -- リスク（A → Bのリスク増大）
            'enabling',               -- 条件（AがBを可能にする）
            'inhibiting'              -- 阻害（AがBを阻害する）
        )),
    
    -- 関係の方向と強度
    direction TEXT                    -- 'positive' / 'negative' / 'complex'
        CHECK(direction IN ('positive', 'negative', 'complex')),
    
    -- 定量的効果
    effect_size_type TEXT,            -- 'HR', 'OR', 'RR', 'percentage', 'beta', 'r'
    effect_size_value REAL,           -- 数値
    effect_size_ci_lower REAL,        -- 95%CI下限
    effect_size_ci_upper REAL,        -- 95%CI上限
    
    -- エビデンス
    evidence_level TEXT
        CHECK(evidence_level IN (
            'meta_analysis', 'rct', 'cohort', 
            'cross_sectional', 'theoretical', 'expert_consensus'
        )),
    evidence_source TEXT,             -- 出典（論文名等）
    evidence_year INTEGER,            -- 発表年
    sample_size INTEGER,              -- サンプルサイズ
    
    -- フィードバックループ識別
    feedback_loop_id TEXT,            -- 所属するフィードバックループのID
    
    -- 説明
    description TEXT,                 -- 関係の説明
    mechanism TEXT,                   -- メカニズムの説明
    
    -- メタデータ
    strength INTEGER DEFAULT 5        -- 1-10の主観的評価
        CHECK(strength BETWEEN 1 AND 10),
    confidence TEXT DEFAULT 'medium'
        CHECK(confidence IN ('high', 'medium', 'low')),
    created_at TEXT DEFAULT (datetime('now'))
);
```

#### interventions（介入）

エビデンスベースの介入プログラム・施策を格納。

```sql
CREATE TABLE interventions (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    
    -- 介入の分類
    intervention_type TEXT NOT NULL
        CHECK(intervention_type IN (
            'exercise',               -- 運動プログラム
            'nutrition',              -- 栄養介入
            'cognitive',              -- 認知トレーニング
            'social',                 -- 社会参加プログラム
            'multicomponent',         -- 多面的介入
            'pharmacological',        -- 薬理的介入
            'environmental',          -- 環境整備
            'policy',                 -- 政策・制度
            'digital',               -- デジタルヘルス
            'screening'              -- スクリーニング・健診
        )),
    
    -- 介入の詳細
    description TEXT,
    target_population TEXT,           -- 対象集団
    setting TEXT,                     -- 実施環境（community, clinical, home等）
    duration TEXT,                    -- 期間
    frequency TEXT,                   -- 頻度
    
    -- 効果
    primary_outcome TEXT,             -- 主要アウトカム
    effect_size_type TEXT,
    effect_size_value REAL,
    effect_size_description TEXT,     -- 効果の説明（例："健康寿命+1.2年"）
    
    -- 費用対効果
    cost_effectiveness TEXT,          -- 費用対効果の評価
    roi REAL,                         -- ROI（倍率）
    cost_per_participant TEXT,        -- 参加者1人あたりコスト
    
    -- エビデンス
    evidence_level TEXT,
    key_study TEXT,                   -- 代表的研究
    country TEXT,                     -- 実施国
    
    -- メタデータ
    status TEXT DEFAULT 'active',
    created_at TEXT DEFAULT (datetime('now'))
);
```

#### intervention_targets（介入対象要因）

介入がどの要因を標的とするかを紐付ける。

```sql
CREATE TABLE intervention_targets (
    intervention_id TEXT NOT NULL REFERENCES interventions(id),
    factor_id TEXT NOT NULL REFERENCES factors(id),
    target_type TEXT DEFAULT 'primary'
        CHECK(target_type IN ('primary', 'secondary', 'indirect')),
    mechanism TEXT,                   -- 作用メカニズム
    PRIMARY KEY (intervention_id, factor_id)
);
```

#### evidence（エビデンス）

個別の研究・メタ分析を格納。

```sql
CREATE TABLE evidence (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    title_ja TEXT,
    
    -- 研究の分類
    study_type TEXT NOT NULL
        CHECK(study_type IN (
            'meta_analysis', 'systematic_review', 'rct',
            'cohort', 'case_control', 'cross_sectional',
            'ecological', 'qualitative', 'mixed_methods'
        )),
    
    -- 研究の詳細
    authors TEXT,
    journal TEXT,
    year INTEGER,
    doi TEXT,
    url TEXT,
    sample_size INTEGER,
    country TEXT,
    population TEXT,                  -- 対象集団の記述
    follow_up_years REAL,             -- 追跡期間
    
    -- 主要な知見
    key_finding TEXT,                 -- 主要な発見
    key_finding_ja TEXT,
    effect_size_type TEXT,
    effect_size_value REAL,
    
    -- 評価
    quality_score TEXT                -- 研究の質評価
        CHECK(quality_score IN ('high', 'moderate', 'low', 'very_low')),
    
    -- メタデータ
    created_at TEXT DEFAULT (datetime('now'))
);
```

#### transition_points（クリティカル・トランジションポイント）

健康寿命の軌跡における重大な転換点。

```sql
CREATE TABLE transition_points (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    
    description TEXT,
    
    -- 転換の特性
    typical_age_range TEXT,           -- 典型的な発生年齢範囲
    reversibility TEXT                -- 可逆性
        CHECK(reversibility IN (
            'reversible',             -- 可逆的
            'partially_reversible',   -- 部分的に可逆
            'irreversible'            -- 不可逆的
        )),
    reversibility_evidence TEXT,      -- 可逆性のエビデンス
    
    -- 定量的情報
    key_statistic TEXT,               -- 主要統計量
    prevalence TEXT,                  -- 有病率・発生率
    
    -- 介入の窓
    intervention_window TEXT,         -- 介入の最適タイミング
    optimal_interventions TEXT,       -- 最適な介入（JSON配列）
    
    -- 関連要因
    triggering_factors TEXT,          -- 引き金となる要因（JSON配列）
    accelerating_factors TEXT,        -- 加速要因（JSON配列）
    protective_factors TEXT,          -- 保護要因（JSON配列）
    
    created_at TEXT DEFAULT (datetime('now'))
);
```

#### feedback_loops（フィードバックループ）

正・負のフィードバックループを識別・格納。

```sql
CREATE TABLE feedback_loops (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    
    loop_type TEXT NOT NULL           -- ループの種類
        CHECK(loop_type IN (
            'positive',               -- 正のフィードバック（増幅・好循環）
            'negative'                -- 負のフィードバック（悪循環）
        )),
    
    description TEXT,                 -- ループの説明
    factor_sequence TEXT,             -- 要因の連鎖（JSON配列 of factor IDs）
    
    -- ループの特性
    leverage_points TEXT,             -- レバレッジポイント（JSON配列）
    breakability TEXT                 -- 断ち切りやすさ
        CHECK(breakability IN ('easy', 'moderate', 'difficult')),
    
    -- 臨床的重要性
    clinical_significance TEXT,       -- 臨床的意義
    intervention_strategy TEXT,       -- 推奨される介入戦略
    
    created_at TEXT DEFAULT (datetime('now'))
);
```

#### measurement_indicators（測定指標）

健康寿命関連の測定指標。

```sql
CREATE TABLE measurement_indicators (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    abbreviation TEXT,                -- 略称（HALE, DFLE等）
    
    description TEXT,
    what_it_measures TEXT,            -- 何を測定するか
    methodology TEXT,                 -- 測定方法
    data_source TEXT,                 -- データソース
    frequency TEXT,                   -- 更新頻度
    
    -- 日本の値
    japan_value_male REAL,
    japan_value_female REAL,
    japan_value_year INTEGER,
    
    -- 国際比較
    global_average REAL,
    global_average_year INTEGER,
    
    created_at TEXT DEFAULT (datetime('now'))
);
```

#### theoretical_frameworks（理論的枠組み）

健康寿命研究の理論枠組みを格納。

```sql
CREATE TABLE theoretical_frameworks (
    id TEXT PRIMARY KEY,
    name_ja TEXT NOT NULL,
    name_en TEXT,
    
    originator TEXT,                  -- 提唱者
    year_proposed INTEGER,            -- 提唱年
    
    description TEXT,                 -- 概要
    key_concepts TEXT,                -- 主要概念（JSON配列）
    
    -- 学問分野
    discipline TEXT,                  -- 学問分野
    
    -- データベースへの適用
    db_relevance TEXT,                -- DBとの関連性
    
    created_at TEXT DEFAULT (datetime('now'))
);
```

#### framework_factor_links（理論-要因紐付け）

```sql
CREATE TABLE framework_factor_links (
    framework_id TEXT NOT NULL REFERENCES theoretical_frameworks(id),
    factor_id TEXT NOT NULL REFERENCES factors(id),
    relevance_type TEXT,              -- 理論がこの要因をどう位置づけるか
    description TEXT,
    PRIMARY KEY (framework_id, factor_id)
);
```

#### academic_db_links（v3学術知識DBへの参照）

既存の学術知識DBとの接続テーブル。

```sql
CREATE TABLE academic_db_links (
    id TEXT PRIMARY KEY,
    -- 本DBの要素
    local_table TEXT NOT NULL,        -- 参照元テーブル名
    local_id TEXT NOT NULL,           -- 参照元ID
    -- v3学術知識DBの要素
    academic_table TEXT NOT NULL,     -- 'social_theory', 'humanities_concept', 'natural_discovery'等
    academic_id TEXT NOT NULL,        -- v3 DBのID
    -- 関連の説明
    link_type TEXT DEFAULT 'related'  -- 'related', 'derived_from', 'applies', 'extends'
        CHECK(link_type IN ('related', 'derived_from', 'applies', 'extends')),
    description TEXT,
    created_at TEXT DEFAULT (datetime('now'))
);
```

---

## 3. 初期データの投入計画

### 3.1 要因（factors）の初期投入

レポートから抽出される主要要因を層・ドメイン別に整理する。

#### マクロ層
| name_ja | name_en | domain | subdomain |
|---------|---------|--------|-----------|
| 教育政策 | Education policy | socioeconomic | policy |
| 所得格差 | Income inequality | socioeconomic | structural |
| 医療制度 | Healthcare system | healthcare_system | institutional |
| 予防医療支出比率 | Prevention spending ratio | healthcare_system | fiscal |
| 文化的規範 | Cultural norms | socioeconomic | cultural |
| 大気汚染 | Air pollution | environmental | atmospheric |
| 年齢差別 | Ageism | socioeconomic | cultural |

#### メゾ層
| name_ja | name_en | domain | subdomain |
|---------|---------|--------|-----------|
| ウォーカビリティ | Walkability | environmental | built_environment |
| 社会関係資本 | Social capital | psychosocial | community |
| 通いの場 | Community gathering places | psychosocial | community |
| 医療資源の地域格差 | Regional healthcare disparities | healthcare_system | access |
| 緑地へのアクセス | Green space access | environmental | built_environment |
| 社会的ネットワーク | Social network | psychosocial | network |
| 地域包括ケアシステム | Integrated community care | healthcare_system | system |

#### ミクロ層 - 生物学的
| name_ja | name_en | domain | subdomain |
|---------|---------|--------|-----------|
| テロメア長 | Telomere length | biological | cellular |
| 細胞老化（SASP） | Cellular senescence (SASP) | biological | cellular |
| 慢性炎症 | Chronic inflammation | biological | inflammatory |
| 腸内細菌叢 | Gut microbiome | biological | microbiome |
| エピジェネティック年齢 | Epigenetic age | biological | molecular |
| サルコペニア | Sarcopenia | biological | musculoskeletal |
| 遺伝的素因 | Genetic predisposition | biological | genetic |
| 多疾患併存 | Multimorbidity | biological | clinical |

#### ミクロ層 - 行動
| name_ja | name_en | domain | subdomain |
|---------|---------|--------|-----------|
| 身体活動 | Physical activity | behavioral | exercise |
| 食事・栄養 | Diet and nutrition | behavioral | dietary |
| 睡眠 | Sleep | behavioral | sleep |
| 喫煙 | Smoking | behavioral | substance |
| 飲酒 | Alcohol consumption | behavioral | substance |
| 医療受診行動 | Healthcare seeking behavior | behavioral | medical |

#### ミクロ層 - 心理社会的
| name_ja | name_en | domain | subdomain |
|---------|---------|--------|-----------|
| 生きがい | Ikigai (purpose in life) | psychosocial | purpose |
| 社会的孤立 | Social isolation | psychosocial | isolation |
| 孤独感 | Loneliness | psychosocial | isolation |
| 抑うつ | Depression | psychosocial | mental_health |
| 自己効力感 | Self-efficacy | psychosocial | psychological |
| 認知的関与 | Cognitive engagement | psychosocial | cognitive |
| セルフコンパッション | Self-compassion | psychosocial | psychological |

### 3.2 主要な関係（factor_relations）の初期投入

レポートから抽出される主要な因果関係とその効果量。

| source | target | type | effect | evidence |
|--------|--------|------|--------|----------|
| 社会的つながり | 死亡リスク | protective | 50%低下 | meta_analysis (Holt-Lunstad 2010) |
| 社会参加(3+団体) | 機能障害 | protective | HR=0.57 | cohort (JAGES) |
| 生きがい | 機能障害 | protective | 31%低下 | cohort (JAGES) |
| 生きがい | 認知症 | protective | 36%低下 | cohort (JAGES) |
| 目的意識 | 死亡リスク | protective | HR=0.83 | meta_analysis |
| 身体活動(4000歩) | 全死因死亡 | protective | 36%低下 | meta_analysis (Lancet 2025) |
| 教育年数(+1年) | 全死因死亡 | protective | 1.9%低下 | meta_analysis (Lancet 2024) |
| 社会的孤立 | 死亡リスク | risk | OR=1.29 | meta_analysis (Holt-Lunstad 2015) |
| 孤独感 | 死亡リスク | risk | OR=1.26 | meta_analysis (Holt-Lunstad 2015) |
| 多疾患併存(4+) | フレイル移行 | causal | 30カ月加速 | cohort |
| ウォーカビリティ | 心血管死亡 | protective | 9%低下 | cohort (Canada 15yr) |
| 5健康行動 | 平均寿命 | protective | +7.13年 | cohort |
| 配偶者喪失 | 認知機能低下 | risk | 有意 | cohort (longitudinal) |
| 職位(最低vs最高) | 冠動脈疾患死亡 | risk | 3.6倍 | cohort (Whitehall II) |

### 3.3 v3学術知識DBとの初期リンク

| 本DB要素 | v3 DB概念 | v3テーブル | link_type |
|----------|-----------|-----------|-----------|
| 自己効力感/健康行動 | 健康信念モデル(HBM) | social_theory | applies |
| 生きがい | PERMAモデル | social_theory | related |
| 適応戦略 | SOCモデル | social_theory | applies |
| 予防戦略 | 一次・二次・三次予防モデル | social_theory | derived_from |
| 健康格差の構造 | ハビトゥス | humanities_concept | applies |
| 健康政策の権力構造 | 生政治 | humanities_concept | applies |
| 主観的健康 | 疾患/病い/病気の三分法 | humanities_concept | related |
| テロメア長 | テロメアとテロメラーゼ | natural_discovery | derived_from |
| 細胞老化 | 細胞老化（セネッセンス） | natural_discovery | derived_from |
| 老化メカニズム | 老化の進化理論 | natural_discovery | related |

---

## 4. フィードバックループの初期定義

### ループ1: 孤立-うつ-不活動ループ（負）
```
社会的孤立 → 孤独感 → 抑うつ → 身体活動低下 → 筋力/認知低下 → 社会参加困難 → 社会的孤立
```
レバレッジポイント: 社会参加プログラム（通いの場）

### ループ2: フレイル・カスケード（負）
```
身体活動低下 → サルコペニア → 転倒リスク → 恐怖心 → 活動範囲縮小 → さらなる不活動
```
レバレッジポイント: プレフレイル段階の運動介入

### ループ3: 社会参加-健康好循環（正）
```
社会参加 → 身体活動増加 + 認知刺激 + 生きがい → 機能維持 → 自立生活 → さらなる社会参加
```
レバレッジポイント: コミュニティ拠点の整備

### ループ4: 社会経済的不利の蓄積（負）
```
幼少期の社会経済的不利 → 低教育 → 低所得/不安定雇用 → ストレス → 不健康行動 → 生物学的老化加速
```
レバレッジポイント: 教育政策、上方社会移動の支援

---

## 5. 今後の拡張計画

### Phase 1: 基本構造（本設計）
- スキーマ作成
- レポートからの初期データ投入（約40要因、30関係、10介入、4転換点、4ループ）

### Phase 2: エビデンス充実
- Semantic Scholarからの体系的な論文収集
- 効果量・信頼区間の精密な入力
- メタ分析結果のデータベース化

### Phase 3: エージェント連携
- v3チームのcollect/verify/traceエージェントの適用
- 自動的な新規エビデンスの収集・登録
- 品質検証の自動化

### Phase 4: 可視化・活用
- 因果ネットワークの可視化（D3.js/Cytoscape.js）
- レバレッジポイント分析ツール
- 介入シミュレーション

---

*設計日: 2026年4月15日*
*v3学術知識DBスキーマとの互換性を確認済み*

-- Seed data for Healthy Life Expectancy Factors Database
-- Based on the integrated conceptual model report

-- ============================================================
-- FACTORS
-- ============================================================

-- Macro layer - Socioeconomic
INSERT INTO factors (id, name_ja, name_en, layer, domain, subdomain, definition, modifiability, time_scale, evidence_strength, key_statistic, key_statistic_source, keywords_ja, keywords_en) VALUES
('f_macro_edu', '教育政策', 'Education policy', 'macro', 'socioeconomic', 'policy', '国民の教育水準を規定する政策・制度体系', 'fully_modifiable', 'lifecourse', 'meta_analysis', '教育1年増→死亡リスク1.9%低下', 'Lancet Public Health 2024', '教育,政策,学歴', 'education,policy'),
('f_macro_ineq', '所得格差', 'Income inequality', 'macro', 'socioeconomic', 'structural', '社会における所得分配の不均等度', 'fully_modifiable', 'lifecourse', 'cohort', '職位最低群の死亡率=最高群の3.6倍', 'Whitehall II Study', '格差,所得,不平等', 'inequality,income,disparity'),
('f_macro_culture', '文化的規範', 'Cultural norms', 'macro', 'socioeconomic', 'cultural', '健康行動や医療受診行動に影響する文化的価値観・規範', 'partially_modifiable', 'lifecourse', 'cohort', NULL, NULL, '文化,規範,世間体', 'culture,norms,stigma'),
('f_macro_ageism', '年齢差別', 'Ageism', 'macro', 'socioeconomic', 'cultural', '年齢に基づく偏見・差別・固定観念', 'fully_modifiable', 'chronic', 'cohort', NULL, 'WHO Decade of Healthy Ageing', '年齢差別,偏見', 'ageism,discrimination'),
('f_macro_airpol', '大気汚染', 'Air pollution', 'macro', 'environmental', 'atmospheric', '大気中の有害物質による長期曝露', 'fully_modifiable', 'lifecourse', 'meta_analysis', NULL, NULL, '大気汚染,PM2.5', 'air pollution,PM2.5');

-- Macro layer - Healthcare system
INSERT INTO factors (id, name_ja, name_en, layer, domain, subdomain, definition, modifiability, time_scale, evidence_strength, key_statistic, key_statistic_source, keywords_ja, keywords_en) VALUES
('f_macro_health_sys', '医療制度', 'Healthcare system', 'macro', 'healthcare_system', 'institutional', '国の医療提供体制・保険制度', 'fully_modifiable', 'chronic', 'cohort', NULL, NULL, '医療制度,保険', 'healthcare,insurance'),
('f_macro_prev_spend', '予防医療支出比率', 'Prevention spending ratio', 'macro', 'healthcare_system', 'fiscal', '医療支出に占める予防の割合', 'fully_modifiable', 'chronic', 'cohort', 'OECD平均わずか3%', 'OECD 2024', '予防,支出,投資', 'prevention,spending');

-- Meso layer
INSERT INTO factors (id, name_ja, name_en, layer, domain, subdomain, definition, modifiability, time_scale, evidence_strength, key_statistic, key_statistic_source, keywords_ja, keywords_en) VALUES
('f_meso_walk', 'ウォーカビリティ', 'Walkability', 'meso', 'environmental', 'built_environment', '地域の歩きやすさ（歩道・公園・安全性）', 'fully_modifiable', 'chronic', 'cohort', '心血管死亡9%低下（低SES層で最大効果）', 'Canada 15yr cohort (Lancet 2022)', 'ウォーカビリティ,歩道,公園', 'walkability,sidewalk,park'),
('f_meso_social_cap', '社会関係資本', 'Social capital', 'meso', 'psychosocial', 'community', '地域の信頼・互酬性・ネットワーク', 'partially_modifiable', 'chronic', 'cohort', NULL, 'JAGES', '社会関係資本,信頼', 'social capital,trust'),
('f_meso_kayoinoba', '通いの場', 'Community gathering places', 'meso', 'psychosocial', 'community', '高齢者が定期的に集い体操・食事・会話を行う地域拠点', 'fully_modifiable', 'chronic', 'cohort', '健康寿命延伸：女性+1.2年、男性+0.5年', 'JAGES 10年介入研究', '通いの場,介護予防,地域', 'community salon,prevention'),
('f_meso_care_sys', '地域包括ケアシステム', 'Integrated community care', 'meso', 'healthcare_system', 'system', '医療・介護・予防・住まい・生活支援の一体的提供', 'fully_modifiable', 'chronic', 'cohort', NULL, NULL, '地域包括ケア,統合ケア', 'integrated care'),
('f_meso_med_resource', '医療資源の地域格差', 'Regional healthcare disparities', 'meso', 'healthcare_system', 'access', '地域間の医師・療法士・診療所数の差', 'fully_modifiable', 'chronic', 'cross_sectional', '医師数・歯科医療費と健康寿命が正の相関', 'JAGES', '医療資源,格差,地域', 'medical resources,disparity'),
('f_meso_green', '緑地アクセス', 'Green space access', 'meso', 'environmental', 'built_environment', '公園・緑地への近接性', 'fully_modifiable', 'chronic', 'cohort', NULL, NULL, '緑地,公園', 'green space,park'),
('f_meso_network', '社会的ネットワーク', 'Social network', 'meso', 'psychosocial', 'network', '個人を取り巻く社会的関係の構造', 'partially_modifiable', 'chronic', 'meta_analysis', '社会的関係→死亡リスク50%低下', 'Holt-Lunstad 2010', 'ネットワーク,つながり', 'social network,ties');

-- Micro layer - Biological
INSERT INTO factors (id, name_ja, name_en, layer, domain, subdomain, definition, modifiability, time_scale, evidence_strength, key_statistic, key_statistic_source, keywords_ja, keywords_en) VALUES
('f_micro_telomere', 'テロメア長', 'Telomere length', 'micro', 'biological', 'cellular', '染色体末端の反復配列の長さ。生物学的老化のバイオマーカー', 'partially_modifiable', 'lifecourse', 'cohort', 'ストレス・喫煙・貧困が短縮を加速', 'Blackburn et al.', 'テロメア,老化,バイオマーカー', 'telomere,aging,biomarker'),
('f_micro_senescence', '細胞老化（SASP）', 'Cellular senescence (SASP)', 'micro', 'biological', 'cellular', '細胞の不可逆的増殖停止とSASP分泌', 'partially_modifiable', 'chronic', 'cohort', NULL, 'Hayflick 1961', '細胞老化,SASP,セノリティクス', 'senescence,SASP,senolytics'),
('f_micro_inflammation', '慢性炎症', 'Chronic inflammation (inflammaging)', 'micro', 'biological', 'inflammatory', '加齢に伴う低レベル慢性炎症', 'partially_modifiable', 'chronic', 'meta_analysis', '加齢関連疾患の共通基盤', 'López-Otín 2023', 'インフラメイジング,炎症', 'inflammaging,inflammation'),
('f_micro_microbiome', '腸内細菌叢', 'Gut microbiome', 'micro', 'biological', 'microbiome', '腸内細菌の多様性と組成', 'fully_modifiable', 'chronic', 'cohort', '百寿者は独自のウイルロームを持つ', 'Nature Microbiology 2023', 'マイクロバイオーム,腸内細菌', 'microbiome,gut bacteria'),
('f_micro_epi_age', 'エピジェネティック年齢', 'Epigenetic age', 'micro', 'biological', 'molecular', 'DNAメチル化パターンから推定される生物学的年齢', 'partially_modifiable', 'lifecourse', 'cohort', '社会経済的地位と相関', 'Horvath 2013; Nature Aging 2023', 'エピジェネティクス,メチル化', 'epigenetics,methylation'),
('f_micro_sarcopenia', 'サルコペニア', 'Sarcopenia', 'micro', 'biological', 'musculoskeletal', '加齢に伴う筋肉量・筋力の低下', 'partially_modifiable', 'chronic', 'meta_analysis', NULL, NULL, 'サルコペニア,筋力低下', 'sarcopenia,muscle loss'),
('f_micro_genetic', '遺伝的素因', 'Genetic predisposition', 'micro', 'biological', 'genetic', '寿命に対する遺伝的寄与', 'non_modifiable', 'lifecourse', 'cohort', '寿命への遺伝的寄与は20-30%', '双生児研究', '遺伝,寿命', 'genetics,longevity'),
('f_micro_multimorbid', '多疾患併存', 'Multimorbidity', 'micro', 'biological', 'clinical', '複数の慢性疾患を同時に抱える状態', 'partially_modifiable', 'chronic', 'cohort', '4+疾患でフレイル移行を30カ月加速', 'Age & Ageing 2020', '多疾患,併存疾患', 'multimorbidity,comorbidity'),
('f_micro_frailty', 'フレイル', 'Frailty', 'micro', 'biological', 'clinical', '身体的・心理的・社会的虚弱の複合状態', 'partially_modifiable', 'chronic', 'meta_analysis', '23%がプレフレイルからロバストに回復(3年)', '26カ国メタ分析', 'フレイル,虚弱,介護予防', 'frailty,vulnerability');

-- Micro layer - Behavioral
INSERT INTO factors (id, name_ja, name_en, layer, domain, subdomain, definition, modifiability, time_scale, evidence_strength, key_statistic, key_statistic_source, keywords_ja, keywords_en) VALUES
('f_micro_pa', '身体活動', 'Physical activity', 'micro', 'behavioral', 'exercise', '日常的な身体的運動・活動', 'fully_modifiable', 'chronic', 'meta_analysis', '4000歩/日で全死因死亡36%低下、閾値なし', 'Lancet Public Health 2025', '運動,歩行,身体活動', 'exercise,walking,physical activity'),
('f_micro_diet', '食事・栄養', 'Diet and nutrition', 'micro', 'behavioral', 'dietary', '食事パターンと栄養摂取', 'fully_modifiable', 'chronic', 'meta_analysis', 'タンパク質1.0-1.2g/kg/日推奨', NULL, '食事,栄養,地中海食', 'diet,nutrition,Mediterranean'),
('f_micro_sleep', '睡眠', 'Sleep', 'micro', 'behavioral', 'sleep', '睡眠の質と量', 'fully_modifiable', 'chronic', 'cohort', '睡眠不足はβアミロイド蓄積を促進', NULL, '睡眠,不眠', 'sleep,insomnia'),
('f_micro_smoking', '喫煙', 'Smoking', 'micro', 'behavioral', 'substance', '喫煙習慣', 'fully_modifiable', 'chronic', 'meta_analysis', NULL, NULL, '喫煙,禁煙', 'smoking,cessation'),
('f_micro_alcohol', '飲酒', 'Alcohol consumption', 'micro', 'behavioral', 'substance', '飲酒量と飲酒パターン', 'fully_modifiable', 'chronic', 'meta_analysis', NULL, NULL, '飲酒,アルコール', 'alcohol,drinking'),
('f_micro_social_part', '社会参加', 'Social participation', 'micro', 'behavioral', 'social', '組織・グループ・コミュニティ活動への参加', 'fully_modifiable', 'chronic', 'cohort', '3+団体参加: 機能障害HR=0.57', 'JAGES', '社会参加,ボランティア', 'social participation,volunteer');

-- Micro layer - Psychosocial
INSERT INTO factors (id, name_ja, name_en, layer, domain, subdomain, definition, modifiability, time_scale, evidence_strength, key_statistic, key_statistic_source, keywords_ja, keywords_en) VALUES
('f_micro_ikigai', '生きがい', 'Ikigai (purpose in life)', 'micro', 'psychosocial', 'purpose', '生きることに見出す意味や目的', 'partially_modifiable', 'chronic', 'cohort', '機能障害31%低下、認知症36%低下', 'JAGES (Lancet Regional Health 2022)', '生きがい,目的', 'ikigai,purpose'),
('f_micro_isolation', '社会的孤立', 'Social isolation', 'micro', 'psychosocial', 'isolation', '社会的接触の客観的欠如', 'fully_modifiable', 'chronic', 'meta_analysis', '死亡リスクOR=1.29', 'Holt-Lunstad 2015', '孤立,独居', 'isolation,living alone'),
('f_micro_loneliness', '孤独感', 'Loneliness', 'micro', 'psychosocial', 'isolation', '社会的つながりの主観的不足感', 'fully_modifiable', 'chronic', 'meta_analysis', '死亡リスクOR=1.26', 'Holt-Lunstad 2015', '孤独,寂しさ', 'loneliness'),
('f_micro_depression', '抑うつ', 'Depression', 'micro', 'psychosocial', 'mental_health', '持続的な気分の落ち込みと意欲低下', 'fully_modifiable', 'acute', 'meta_analysis', '配偶者喪失後のうつが5年間の健康リスクを予測', 'HRS study', 'うつ,抑うつ', 'depression'),
('f_micro_self_eff', '自己効力感', 'Self-efficacy', 'micro', 'psychosocial', 'psychological', '特定の行動を遂行できるという信念', 'fully_modifiable', 'chronic', 'cohort', NULL, 'Bandura', '自己効力感', 'self-efficacy'),
('f_micro_cognition', '認知的関与', 'Cognitive engagement', 'micro', 'psychosocial', 'cognitive', '知的活動への持続的関与', 'fully_modifiable', 'chronic', 'cohort', 'インターネット利用が低学歴層の機能低下を抑制', 'JAGES 2016-2019', '認知,知的活動', 'cognition,intellectual');

-- ============================================================
-- FACTOR RELATIONS
-- ============================================================

INSERT INTO factor_relations (id, source_factor_id, target_factor_id, relation_type, direction, effect_size_type, effect_size_value, evidence_level, evidence_source, evidence_year, description, strength, confidence) VALUES
-- Social connections → mortality
('r_network_mortality', 'f_meso_network', 'f_micro_frailty', 'protective', 'positive', 'percentage', 50.0, 'meta_analysis', 'Holt-Lunstad et al. 2010 PLOS Medicine (148 studies, 308000 participants)', 2010, '良好な社会的関係は死亡リスクを50%低下させる。喫煙・肥満と同等の効果量', 10, 'high'),
-- Social participation → functional disability
('r_social_part_func', 'f_micro_social_part', 'f_micro_frailty', 'protective', 'positive', 'HR', 0.57, 'cohort', 'JAGES (3+ organizations)', NULL, '3団体以上の参加で機能障害HR=0.57', 9, 'high'),
-- Ikigai → functional disability
('r_ikigai_func', 'f_micro_ikigai', 'f_micro_frailty', 'protective', 'positive', 'percentage', 31.0, 'cohort', 'JAGES (Lancet Regional Health Western Pacific 2022)', 2022, '生きがいがある高齢者は機能障害リスクが31%低い', 8, 'high'),
-- Ikigai → dementia
('r_ikigai_dementia', 'f_micro_ikigai', 'f_micro_cognition', 'protective', 'positive', 'percentage', 36.0, 'cohort', 'JAGES (Lancet Regional Health Western Pacific 2022)', 2022, '生きがいがある高齢者は認知症リスクが36%低い', 8, 'high'),
-- Purpose in life → mortality
('r_purpose_mortality', 'f_micro_ikigai', 'f_micro_multimorbid', 'protective', 'positive', 'HR', 0.83, 'meta_analysis', '10 prospective studies meta-analysis', NULL, '人生の目的感が高い人の死亡HR=0.83', 8, 'high'),
-- Physical activity → mortality
('r_pa_mortality', 'f_micro_pa', 'f_micro_frailty', 'protective', 'positive', 'percentage', 36.0, 'meta_analysis', 'Lancet Public Health 2025 (daily steps meta-analysis)', 2025, '4000歩/日（vs 2000歩）で全死因死亡36%低下。閾値なし', 9, 'high'),
-- Education → mortality
('r_edu_mortality', 'f_macro_edu', 'f_micro_multimorbid', 'protective', 'positive', 'percentage', 1.9, 'meta_analysis', 'Lancet Public Health 2024 (59 countries)', 2024, '教育年数1年増で全死因死亡リスク1.9%低下', 8, 'high'),
-- Social isolation → mortality
('r_isolation_mortality', 'f_micro_isolation', 'f_micro_frailty', 'risk', 'negative', 'OR', 1.29, 'meta_analysis', 'Holt-Lunstad et al. 2015', 2015, '社会的孤立は死亡リスクをOR=1.29に高める', 9, 'high'),
-- Loneliness → mortality
('r_loneliness_mortality', 'f_micro_loneliness', 'f_micro_frailty', 'risk', 'negative', 'OR', 1.26, 'meta_analysis', 'Holt-Lunstad et al. 2015', 2015, '孤独感は死亡リスクをOR=1.26に高める', 8, 'high'),
-- Multimorbidity → frailty
('r_multimorbid_frailty', 'f_micro_multimorbid', 'f_micro_frailty', 'causal', 'negative', NULL, NULL, 'cohort', 'Age & Ageing 2020 (Newcastle 85+ cohort)', 2020, '4+疾患でフレイル移行を約30カ月加速', 8, 'high'),
-- Walkability → CV mortality
('r_walk_cv', 'f_meso_walk', 'f_micro_pa', 'enabling', 'positive', 'percentage', 9.0, 'cohort', 'Canada 15yr cohort (Lancet 2022)', 2022, '高ウォーカビリティ→心血管死亡9%低下、低SES層で最大効果', 7, 'high'),
-- Inequality → mortality
('r_ineq_mortality', 'f_macro_ineq', 'f_micro_multimorbid', 'risk', 'negative', NULL, NULL, 'cohort', 'Whitehall II Study', 1991, '職位最低群の冠動脈疾患死亡率=最高群の3.6倍', 9, 'high'),
-- Isolation → depression
('r_isolation_depression', 'f_micro_isolation', 'f_micro_depression', 'causal', 'negative', NULL, NULL, 'cohort', '24 countries longitudinal study', NULL, '社会的孤立→うつ→不活動の悪循環', 8, 'high'),
-- Depression → physical activity
('r_depression_pa', 'f_micro_depression', 'f_micro_pa', 'inhibiting', 'negative', NULL, NULL, 'cohort', NULL, NULL, 'うつ症状が身体活動への意欲を低下させる', 7, 'medium'),
-- Kayoinoba → healthy life expectancy
('r_kayoinoba_hle', 'f_meso_kayoinoba', 'f_micro_social_part', 'enabling', 'positive', NULL, NULL, 'cohort', 'JAGES 10yr intervention study', NULL, '通いの場→健康寿命延伸（女性+1.2年、男性+0.5年）', 8, 'high'),
-- Sarcopenia → frailty
('r_sarco_frailty', 'f_micro_sarcopenia', 'f_micro_frailty', 'causal', 'negative', NULL, NULL, 'meta_analysis', NULL, NULL, '筋力低下はフレイルの主要構成要素', 9, 'high'),
-- Inflammation → multimorbidity
('r_inflam_multimorbid', 'f_micro_inflammation', 'f_micro_multimorbid', 'causal', 'negative', NULL, NULL, 'meta_analysis', 'López-Otín 2023', 2023, '慢性炎症は加齢関連疾患の共通基盤', 8, 'high');

-- ============================================================
-- INTERVENTIONS
-- ============================================================

INSERT INTO interventions (id, name_ja, name_en, intervention_type, description, target_population, setting, evidence_level, key_study, country, effect_size_description, roi) VALUES
('i_finger', 'FINGER多面的介入', 'FINGER Multicomponent Intervention', 'multicomponent', '食事・運動・認知トレーニング・社会活動・血管代謝リスク管理の5領域統合介入', '60-77歳の認知症高リスク者', 'community', 'rct', 'FINGER Trial (n=1260, 2yr)', 'Finland', 'QALY+0.043、コスト節約（支配的結果）', NULL),
('i_otago', 'オタゴ運動プログラム', 'Otago Exercise Programme', 'exercise', '17種の筋力・バランス運動と歩行プログラム', '65歳以上、特に80歳以上', 'home/community', 'meta_analysis', '2025 meta-analysis (15 studies, 1278 participants)', 'New Zealand', '転倒35-40%削減、傷害転倒28%削減', NULL),
('i_kayoinoba', '通いの場', 'Community Gathering Places', 'social', '高齢者が定期的に集い体操・食事・会話を行う地域拠点', '後期高齢者', 'community', 'cohort', 'JAGES 10yr intervention study', 'Japan', '健康寿命延伸：女性+1.2年、男性+0.5年', NULL),
('i_social_rx', 'ソーシャル・プリスクライビング', 'Social Prescribing', 'social', '医療機関が地域の社会資源への参加を処方する仕組み', '全年齢', 'community/clinical', 'cohort', 'NHS England national roll-out', 'UK', 'GP受診53%減、救急62.6%減、入院61.7%減', NULL),
('i_healthier_sg', 'Healthier SG', 'Healthier SG', 'policy', '治療中心から予防中心への国家的医療改革', '60歳以上→全年齢', 'national', 'cohort', 'Singapore national program 2023-', 'Singapore', '入院日数3.8→3.5日、院内死亡率3.7→2.9%', NULL),
('i_frailty_screen', 'フレイル健診', 'Frailty Screening', 'screening', '基本チェックリスト(25項目)によるフレイル早期発見', '後期高齢者', 'clinical/community', 'cohort', '2020年度全国実施開始', 'Japan', 'プレフレイルの23%がロバストに回復可能', NULL);

-- Intervention targets
INSERT INTO intervention_targets (intervention_id, factor_id, target_type, mechanism) VALUES
('i_finger', 'f_micro_cognition', 'primary', '認知トレーニングによる認知機能維持'),
('i_finger', 'f_micro_pa', 'primary', '運動プログラムによる身体活動促進'),
('i_finger', 'f_micro_diet', 'primary', '栄養指導による食事改善'),
('i_finger', 'f_micro_social_part', 'secondary', 'グループ活動を通じた社会参加'),
('i_finger', 'f_micro_multimorbid', 'secondary', '血管代謝リスク管理'),
('i_otago', 'f_micro_sarcopenia', 'primary', '筋力・バランス訓練'),
('i_otago', 'f_micro_frailty', 'primary', '転倒予防を通じたフレイル進行抑制'),
('i_kayoinoba', 'f_micro_social_part', 'primary', '地域での社会参加機会の提供'),
('i_kayoinoba', 'f_micro_isolation', 'primary', '孤立防止'),
('i_kayoinoba', 'f_micro_pa', 'secondary', '体操等による身体活動促進'),
('i_social_rx', 'f_micro_isolation', 'primary', '非医療的社会資源への接続'),
('i_social_rx', 'f_micro_depression', 'secondary', '社会参加を通じたうつ予防'),
('i_frailty_screen', 'f_micro_frailty', 'primary', '早期発見・早期介入');

-- ============================================================
-- TRANSITION POINTS
-- ============================================================

INSERT INTO transition_points (id, name_ja, name_en, description, typical_age_range, reversibility, reversibility_evidence, key_statistic, intervention_window, optimal_interventions) VALUES
('tp_prefrail', 'プレフレイル→フレイル移行', 'Pre-frailty to frailty transition', 'フレイルの前段階から虚弱状態への移行。最も介入効果が高い転換点', '70-85歳', 'reversible', '26カ国メタ分析（5万人超）：プレフレイル者の23%が3年でロバストに回復', '23%が3年でロバストに回復、35%のフレイル者が1段階改善', 'プレフレイル段階での早期発見が最適', '["i_otago","i_finger","i_kayoinoba","i_frailty_screen"]'),
('tp_retirement', '退職', 'Retirement', '社会的役割・日課・職場の人間関係の喪失', '60-70歳', 'partially_reversible', '退職後の社会参加の有無が影響を調整', NULL, '退職前後の社会参加移行支援', '["i_kayoinoba","i_social_rx"]'),
('tp_bereavement', '配偶者喪失（死別）', 'Spousal bereavement', '配偶者の死による急激な心理的・身体的健康の悪化', '70歳以上', 'partially_reversible', '死別後のうつ症状の重さが5年間のリスクを予測', '女性:所得22%減・資産10%減、男性:メンタルヘルス悪化', '死別直後のケアが重要', '["i_social_rx"]'),
('tp_multimorbid', '多疾患罹患の発症', 'Onset of multimorbidity', '複数の慢性疾患を同時に抱える状態の発症', '65歳以上', 'partially_reversible', '4+疾患でフレイル移行を30カ月加速', '4+疾患でロバスト→フレイルの直接移行リスク増大', '早期発見と包括的管理', '["i_finger","i_frailty_screen"]');

-- ============================================================
-- FEEDBACK LOOPS
-- ============================================================

INSERT INTO feedback_loops (id, name_ja, name_en, loop_type, description, leverage_points, breakability, clinical_significance, intervention_strategy) VALUES
('loop_isolation', '孤立-うつ-不活動ループ', 'Isolation-depression-inactivity loop', 'negative', '社会的孤立→孤独感→うつ→身体活動低下→筋力/認知低下→社会参加困難→さらなる孤立', '["通いの場（社会参加プログラム）","ソーシャル・プリスクライビング"]', 'moderate', '24カ国の縦断研究で確認。40%の孤立高齢者がうつ症状を発症', '社会参加の機会を制度的に組み込むことでループ構造自体を変更する'),
('loop_frailty', 'フレイル・カスケード', 'Frailty cascade', 'negative', '身体活動低下→サルコペニア→転倒リスク→恐怖心→活動範囲縮小→さらなる不活動', '["プレフレイル段階の運動介入（オタゴ等）","フレイル健診"]', 'moderate', 'フレイルの主要な進行経路。多疾患併存により加速', 'プレフレイル段階での多面的介入（運動+栄養+社会参加）'),
('loop_positive', '社会参加-健康好循環', 'Social participation-health virtuous cycle', 'positive', '社会参加→身体活動増加+認知刺激+生きがい→機能維持→自立生活→さらなる社会参加', '["コミュニティ拠点の整備","通いの場"]', 'easy', '正のフィードバックが確立されれば自己強化的に機能', 'コミュニティ拠点の制度的整備により正のループを起動する'),
('loop_ses', '社会経済的不利の蓄積', 'Cumulative socioeconomic disadvantage', 'negative', '幼少期の社会経済的不利→低教育→低所得→ストレス→不健康行動→生物学的老化加速', '["教育政策","上方社会移動の支援"]', 'difficult', 'ライフコース全体にわたる蓄積的効果。成人期SEPが21-78%を媒介', '教育格差の縮小と上方社会移動の支援。最も困難だが最大の構造的レバレッジ');

-- ============================================================
-- MEASUREMENT INDICATORS
-- ============================================================

INSERT INTO measurement_indicators (id, name_ja, name_en, abbreviation, description, what_it_measures, methodology, data_source, frequency, japan_value_male, japan_value_female, japan_value_year) VALUES
('mi_hale', '健康調整平均余命', 'Health-Adjusted Life Expectancy', 'HALE', 'WHO指標。疾病・障害による損失を健康な年数に換算', '健康状態を考慮した平均余命', 'GBD DALYデータを基礎', 'WHO/GBD', '年次', NULL, NULL, NULL),
('mi_dfle', '障害のない平均余命', 'Disability-Free Life Expectancy', 'DFLE', 'サリバン法による障害のない期間の推計', '障害なく生活できる期間', 'サリバン法（障害割合×生命表）', '各国調査', '不定期', NULL, NULL, NULL),
('mi_jp_hle', '健康寿命（日本）', 'Healthy Life Expectancy (Japan)', NULL, '日常生活に制限のない期間', '自己評価による健康な生活期間', '国民生活基礎調査の自己評価', '厚生労働省', '3年ごと', 72.57, 75.45, 2022),
('mi_kaigo', '要介護認定', 'Long-term Care Certification', NULL, '要支援1-2、要介護1-5の7段階', '介護の必要度', '介護保険制度の認定調査', '厚生労働省', '年次', NULL, NULL, NULL);

-- ============================================================
-- THEORETICAL FRAMEWORKS
-- ============================================================

INSERT INTO theoretical_frameworks (id, name_ja, name_en, originator, year_proposed, description, discipline, db_relevance) VALUES
('tf_successful', '成功的老化モデル', 'Successful Aging Model', 'Rowe & Kahn', 1997, '疾病回避・高機能維持・社会参加の三要素による老化モデル', '老年学', '要因分類の基本枠組み'),
('tf_soc', 'SOCモデル', 'Selection Optimization Compensation', 'Baltes & Baltes', 1990, '選択・最適化・補償による加齢適応モデル', '発達心理学', '適応戦略としての要因分類'),
('tf_who_ic', 'WHO内在的能力モデル', 'WHO Intrinsic Capacity Framework', 'WHO', 2015, '内在的能力×環境=機能的能力という二層モデル', '公衆衛生学', 'マイクロ層の5領域分類の基盤'),
('tf_prevention', '三段階予防モデル', 'Primary-Secondary-Tertiary Prevention', 'Caplan', 1964, '一次・二次・三次予防の枠組み', '公衆衛生学', '介入の分類枠組み'),
('tf_biopolitics', '生政治', 'Biopolitics', 'Foucault', 1976, '人口の健康・寿命を管理する近代的権力', '政治哲学', 'マクロ層の政策分析視座'),
('tf_habitus', 'ハビトゥス', 'Habitus', 'Bourdieu', 1979, '社会構造が内面化された身体化された性向のシステム', '社会学', '健康格差の構造的理解'),
('tf_dis_ill_sick', '疾患/病い/病気の三分法', 'Disease/Illness/Sickness Triad', 'Kleinman', 1988, '生物医学・患者経験・社会制度の三層で健康を理解', '医療人類学', '測定指標の限界の理解'),
('tf_hallmarks', '老化の12のホールマーク', 'Hallmarks of Aging', 'López-Otín et al.', 2013, '老化の分子生物学的基盤を12項目で体系化', '分子生物学', 'ミクロ生物学的要因の分類基盤'),
('tf_complex', '複雑適応系としての老化', 'Aging as Complex Adaptive System', NULL, 2022, 'フィードバックループと非線形ダイナミクスによる老化の理解', '複雑系科学', 'フィードバックループ分析の理論基盤'),
('tf_hbm', '健康信念モデル', 'Health Belief Model', 'Hochbaum, Rosenstock', 1950, '健康行動の採用を6要素で予測するモデル', '健康心理学', '行動要因の理論的基盤');

-- ============================================================
-- ACADEMIC DB LINKS (v3)
-- ============================================================

INSERT INTO academic_db_links (id, local_table, local_id, academic_table, academic_id, link_type, description) VALUES
('link_soc', 'theoretical_frameworks', 'tf_soc', 'social_theory', '9bf43dbb-7969-4e25-bb59-fb19ffaf539c', 'derived_from', 'SOCモデル（選択・最適化・補償）'),
('link_hbm', 'theoretical_frameworks', 'tf_hbm', 'social_theory', '43', 'derived_from', '健康信念モデル（HBM）'),
('link_perma', 'factors', 'f_micro_ikigai', 'social_theory', '88', 'related', 'PERMAウェルビーイングモデル - 生きがいの理論枠組み'),
('link_prevention', 'theoretical_frameworks', 'tf_prevention', 'social_theory', '51', 'derived_from', '一次・二次・三次予防モデル'),
('link_biopolitics', 'theoretical_frameworks', 'tf_biopolitics', 'humanities_concept', 'c033', 'derived_from', '生政治（フーコー）'),
('link_habitus', 'theoretical_frameworks', 'tf_habitus', 'humanities_concept', 'c004', 'derived_from', 'ハビトゥス（ブルデュー）'),
('link_dis_ill', 'theoretical_frameworks', 'tf_dis_ill_sick', 'humanities_concept', 'c036', 'derived_from', '疾患/病い/病気の三分法（クラインマン）'),
('link_telomere', 'factors', 'f_micro_telomere', 'natural_discovery', 'nd_gap2_124', 'derived_from', 'テロメアとテロメラーゼ'),
('link_senescence', 'factors', 'f_micro_senescence', 'natural_discovery', 'nd_gap2_123', 'derived_from', '細胞老化（セネッセンス）'),
('link_aging_evo', 'factors', 'f_micro_genetic', 'natural_discovery', 'db081bcb-78d7-4cd7-8bb2-951dcb891513', 'related', '老化の進化理論'),
('link_aging_mut', 'factors', 'f_micro_genetic', 'natural_discovery', '5c403f1b-c4d6-4b5c-8681-2867e6e17c05', 'related', '突然変異蓄積説'),
('link_aging_ant', 'factors', 'f_micro_genetic', 'natural_discovery', 'c751c8eb-8e74-479c-beab-788a92d80874', 'related', '拮抗的多面発現説'),
('link_aging_soma', 'factors', 'f_micro_genetic', 'natural_discovery', 'a326c9cf-36e7-43c2-b34c-f6024f6698f9', 'related', '使い捨て体細胞説'),
('link_community', 'factors', 'f_meso_kayoinoba', 'humanities_concept', 'c058', 'related', '実践コミュニティ（ウェンガー）');

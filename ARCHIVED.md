# healthy-aging-db — ARCHIVED

**Archived: 2026-05-23** (DUA Wave E Step 0)

## 廃止理由
- factors 255 / evidence 13 / cross_db_refs 14 placeholder / framework_factor_links 0
- 設計のみで実装止まり (Phase 2B 診断 24/100)
- lab-db (Living Behavior) / gpt-qol との重複 60%+

## 統合先
- lab-db (living_behavior.db): healthy_aging_factors_imported 255 rows (sub_category='healthy_aging')
- gpt-qol (qol_sensibility.db): healthy_aging_psychosocial_imported 157 rows (Ikigai/SOC 系)
- academic-knowledge-db: publications 13 件 (evidence DOI 付き)

## 復元
```bash
git checkout archived-2026-05-23
```

## 関連ドキュメント
- 廃止判断: `~/projects/research/agent-registry-db/docs/dua_wave_b_plan.md` (Wave E 統合判断)
- 統合スクリプト: `~/projects/research/agent-registry-db/etl/dua_integrate_healthy_aging.py`

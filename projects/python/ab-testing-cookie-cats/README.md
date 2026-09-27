# A/B Test Analysis: Cookie Cats Gate Placement & Player Retention

**Business question:** Should Cookie Cats move its first progression gate from level 30 to level 40?

**Files:**
- `Cookie_Cats_AB_Test_Analysis.ipynb` — full executed analysis (EDA, hypothesis testing, charts, recommendation)
- `cookie_cats.csv` — dataset (90,189 players), Kaggle: "Mobile Games A/B Testing – Cookie Cats"
- `retention_by_group.png`, `rounds_distribution.png` — exported chart images

**Method:** Two-proportion z-tests on Day 1 and Day 7 retention, α = 0.05, with 95% Wilson confidence intervals.

**Headline result:** Moving the gate to level 40 does not improve retention, and significantly *hurts*
Day 7 retention (18.2% vs 19.0%, p = 0.0016). Recommendation: keep the gate at level 30.

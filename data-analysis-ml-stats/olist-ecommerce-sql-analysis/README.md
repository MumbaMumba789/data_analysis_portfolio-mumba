# Advanced SQL Analysis: Olist E-Commerce (Brazil)

**What this is:** Five deeper business questions that need more than a
single aggregation to answer — cohort tracking, segmentation, and
trend analysis using SQL window functions and multi-step logic.

---

## 1. Are customers who buy once ever coming back — and when?

**What I looked at:** Every customer's first purchase month (their
"cohort"), then tracked how many of that cohort placed another order
in any later month.

**What I found:** Retention is consistently low across every single
monthly cohort — no month stands out as unusually sticky or unusually
leaky. The problem isn't a bad month or a bad campaign; it's structural.

**So what:** This isn't a "fix November" problem — it's a "fix the
whole repeat-purchase system" problem. Loyalty/retention programs would
need to apply business-wide, not to one segment or season.

---

## 2. Does a late first delivery kill future purchases?

**What I looked at:** Repeat-purchase rate for customers whose very
first order arrived after the estimated delivery date, vs. customers
whose first order arrived on time.

**What I found:** Customers whose first delivery was **late repeat at
2.43%**, vs. **3.05%** for on-time customers — roughly a **20% relative
drop** in the odds of ever buying again.

**So what:** First-order delivery experience has a measurable, lasting
effect on customer loyalty. Prioritizing on-time delivery for
first-time buyers specifically (even at some cost) may pay for itself
in retained customers.

---

## 3. Who are our best customers, and who's slipping away?

**What I looked at:** Every customer scored on Recency (how recently
they bought), Frequency (how often), and Monetary value (how much they
spent), then grouped into five segments.

**What I found:** Two segments — **Champions** and **"At Risk (were
loyal)"** — are nearly identical in size and average spend. The At Risk
group alone represents **R$5.4M in past revenue** from customers who
haven't purchased recently.

**So what:** This is close to half of all high-value customers actively
drifting away. A win-back campaign targeted specifically at this
segment addresses the single largest recoverable revenue pool in the
business.

---

## 4. Is growth actually accelerating, or has it plateaued?

**What I looked at:** Month-over-month revenue change across the full
dataset.

**What I found:** Growth was explosive in early 2017 (100%+ month-over-
month), but has flattened to roughly flat or slightly negative
month-over-month change since late 2017 — revenue has plateaued around
R$800K–980K/month.

**So what:** A simple revenue chart makes the business look like it's
still climbing. The month-over-month view tells the real story: growth
has stalled, and the business now depends on retention and
higher-value orders rather than raw new-customer growth to keep
climbing.

---

## 5. Does a bad first-order review predict whether a customer leaves?

**What I looked at:** Repeat-purchase rate grouped by the review score
a customer gave on their very first order (1–5 stars).

**What I found:** Repeat rate stays essentially flat — around 3% —
regardless of whether the first review was 1 star or 5 stars.

**So what:** This is a genuinely counterintuitive, honest finding: churn
here isn't primarily a satisfaction problem. Fixing review scores alone
won't fix retention. The real levers are more likely delivery speed
(see #2) and the absence of any structured repeat-purchase mechanism
(see #1 and #3) — not product/service quality as reflected in reviews.

---

## Summary

| # | Question | Headline finding |
|---|----------|------------------|
| 1 | Cohort retention | Low retention is consistent across every cohort — a structural issue |
| 2 | Delivery lateness vs. loyalty | Late first delivery → ~20% lower repeat rate |
| 3 | RFM segmentation | R$5.4M in revenue sits in an "At Risk" segment of former big spenders |
| 4 | Growth trend | Growth has plateaued since late 2017 despite steady revenue |
| 5 | Reviews vs. churn | Review score has almost no effect on repeat purchase — churn is structural, not satisfaction-driven |

*Built by Mumba — SQL (window functions, CTEs, cohort/RFM analysis). Full queries in `olist_advanced_analysis.sql`.*

# Customer Shopping Behavior Analysis

**Question:** Which customer attributes (subscription, discounts, shipping, demographics, purchase history) actually change how much customers spend per order?

**Short answer:** None of the ones tested. Average order value stays between about $58 and $61 across every split. Revenue differences between groups come from how many customers are in each group, not from how much each one spends.

**Tools:** Python (pandas, SciPy) · MySQL 8 · Power BI



---

## Key findings

| Question | Result | Test |
|---|---|---|
| Do subscribers spend more? | No. $59.49 vs $59.87 per order. Subscribers are 27.0% of customers and 26.9% of revenue | p = 0.66 |
| Do discounts lift order value? | No. $59.28 with a discount vs $60.13 without. 43.0% of orders use a discount | p = 0.27 |
| Does Express shipping mean bigger orders? | Not reliably. $60.48 vs $58.46 (+3.5%) | p = 0.13 |
| Do men and women spend differently? | No. $59.54 vs $60.25. Men are 67.7% of revenue because they place 68% of orders (2,652 of 3,900) | p = 0.38 |
| Does age group matter? | No. Average spend $59.07 to $60.45. Revenue share ranges only 23.9% to 26.7% | ANOVA p = 0.57 |
| Do loyal customers spend more? | No. Quartiles of previous purchases range $59.00 to $60.28 | ANOVA p = 0.74 |
| Are repeat buyers more likely to subscribe? | Weak signal. 27.6% (more than 5 previous purchases) vs 22.4% (5 or fewer). Significant at 0.05 but not after correcting for seven tests; the comparison group is only 424 customers | chi-square p = 0.028 |

Also: the top 5 product ratings (3.78 to 3.86) are tightly clustered around the overall 3.75, and no product accounts for more than 4.4% of orders, so demand is spread evenly. All effect sizes (Cohen's d) are below 0.09, which is negligible.

## What this means

These are hypotheses to test, not proven conclusions.

- **Targeting by these attributes is unlikely to change order value.** Growth is more likely to come from the number of customers and orders.
- **Women spend as much per order as men but are only 32% of orders.** The gap is in acquisition, not spend.
- **Discounts are applied to 43% of orders with no visible lift in order value.** Reducing or targeting discounts is worth testing.
- **Subscriptions show no spend advantage.** Any value would have to come from retention or frequency, which order value does not measure.

## Limitations

- Public dataset of 3,900 transactions, one row per customer. [CONFIRM ON THE PAGE YOU DOWNLOADED FROM, then add: "Source: LINK. The dataset page describes it as synthetic" OR "Source: LINK."] Flat results are common in synthetic data, so do not read this as evidence about a real retailer.
- The dataset does not state whether `purchase_amount` is before or after discount.
- This is observational data, so it shows association only, not cause.
- Seven tests were run, so a Bonferroni-adjusted threshold (0.05 / 7 = 0.0071) was used.

## Approach

1. **Cleaning (Python):** loaded 3,900 rows and 18 columns; filled 37 missing `review_rating` values with the median rating of the same product category (preserves category differences); renamed columns to snake_case; created `age_group` and `purchase_frequency_days`; dropped `promo_code_used` because [ADD RESULT OF THE CROSSTAB CHECK, e.g. "it is identical to discount_applied on every row"].
2. **Analysis (MySQL 8):** 12 queries covering revenue, spend, discounts, shipping, ratings, loyalty tiers, and subscription, using CTEs, `NTILE`, `RANK`, and `SUM() OVER`. Each query has a written finding with the numbers. Loyalty tiers use quartiles from the data, not guessed thresholds.
3. **Statistics (Python, SciPy):** Welch t-tests, one-way ANOVA, and a chi-square test, each with Cohen's d effect size where applicable and a Bonferroni-adjusted threshold.
4. **Dashboard (Power BI):** revenue distribution, subscription impact, customer segments, age-group performance, product performance, and discount behavior.


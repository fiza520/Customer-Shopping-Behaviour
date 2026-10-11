-- Customer Shopping Behavior Analysis
-- Database: MySQL 8.0+ (window functions need 8.0 or later)
-- Table: customer (3,900 rows), cleaned in Python before loading
-- =====================================================================
 
create database if not exists customer_behavior;
use customer_behavior;
 
-- Quick check that the data loaded correctly
select * from customer limit 5;
select count(*) as total_rows from customer;
 
 
-- ---------------------------------------------------------------------
-- check the spread of previous_purchases 
-- ---------------------------------------------------------------------
select min(previous_purchases) as min_prev,
       max(previous_purchases) as max_prev,
       round(avg(previous_purchases), 1) as avg_prev
from customer;
-- Finding:

--  Previous purchases range from 1 to 50, with an average of 25.4.

 
-- ---------------------------------------------------------------------
-- Q1. Revenue by gender (with each gender's share of total revenue)
-- ---------------------------------------------------------------------
select gender,
       count(*) as orders,
       round(sum(purchase_amount), 2) as revenue,
       round(100.0 * sum(purchase_amount) / sum(sum(purchase_amount)) over (), 1) as revenue_pct
from customer
group by gender
order by revenue desc;
-- Finding:
 -- Men contribute 67.7% of total revenue, while women contribute 32.3%. 
--  Men account for 2,652 orders compared with 1,248 orders from women. 
--  If average spending is similar between the two groups, the revenue 
--  gap is primarily associated with the higher number of men's orders rather 
--  than substantially higher spending per order.
 
-- ---------------------------------------------------------------------
-- Q2. Are discounted orders more likely to be above the overall average purchase amount?

-- ---------------------------------------------------------------------
select discount_applied,
       count(*) as orders,
       round(100.0 * count(case when purchase_amount > (select avg(purchase_amount) from customer) then 1 end) / count(*), 1) as pct_above_avg
from customer
group by discount_applied;
-- Finding:
 --   50.0% of discounted orders and 50.6% of non-discounted orders are above the overall average, 
--  so a discount does not make an above-average purchase more or less likely.
 
 
-- ---------------------------------------------------------------------
-- Q3. Top 5 products by average review rating (with order count so thin averages are visible)
-- ---------------------------------------------------------------------
select item_purchased,
       count(*) as orders,
       round(avg(review_rating), 2) as avg_review_rating
from customer
group by item_purchased
order by avg_review_rating desc, orders desc
limit 5;
-- Finding:
--   Product ratings are tightly clustered around the overall average of 3.75. Gloves has the highest average rating at 3.86, 
-- just 0.11 points above the overall average. The small differences suggest that product ratings alone provide limited differentiation 
-- between the top-rated products.
 
-- ---------------------------------------------------------------------
-- Q4. Average purchase amount: Standard vs Express shipping
-- ---------------------------------------------------------------------
select shipping_type,
       count(*) as orders,
       round(avg(purchase_amount), 2) as avg_purchase_amount
from customer
where shipping_type in ('Express', 'Standard')
group by shipping_type
order by avg_purchase_amount desc;
-- Finding:

-- Express orders average $60.48 vs $58.46 for Standard (about 3.5% higher), but the difference is not 
-- statistically significant (p = 0.13), so it could be chance.

-- ---------------------------------------------------------------------
-- Q5. Do subscribers spend more? Average spend, plus share of customers vs share of revenue
-- ---------------------------------------------------------------------
select subscription_status,
       count(*) as customers,
       round(100.0 * count(*) / sum(count(*)) over (), 1) as pct_of_customers,
       round(avg(purchase_amount), 2) as avg_spend,
       round(sum(purchase_amount), 2) as total_revenue,
       round(100.0 * sum(purchase_amount) / sum(sum(purchase_amount)) over (), 1) as pct_of_revenue
from customer
group by subscription_status
order by avg_spend desc;
-- Finding:
--  Subscribers account for 27.0% of customers and 26.9% of total revenue. Their average purchase amount (59.49) is slightly lower 
-- than that of non-subscribers (59.87). Therefore, subscription status is not associated with higher average spending in this dataset.
 

 
-- ---------------------------------------------------------------------
-- Q6. Top 5 products by share of purchases made with a discount
-- ---------------------------------------------------------------------
select item_purchased,
       count(*) as orders,
       round(100.0 * count(case when discount_applied = 'Yes' then 1 end) / count(*), 1) as discount_pct
from customer
group by item_purchased
order by discount_pct desc
limit 5;
-- Finding:
--  Hats have the highest discount rate at 50.0%, compared with the overall discount rate of 43.0%. 
-- The top five products have discount rates between 47.4% and 50.0%, a difference of 4.4–7.0 percentage points 
-- above the overall benchmark. With approximately 150–170 orders per product, these differences alone do not establish that 
-- any product is dependent on discounts.
 
 
 -- ---------------------------------------------------------------------
-- Q7. Loyalty tiers and average spending
-- ---------------------------------------------------------------------

with ranked as (
    select customer_id,
           previous_purchases,
           purchase_amount,
           ntile(4) over (order by previous_purchases) as loyalty_tier
    from customer
)
select loyalty_tier,
       min(previous_purchases) as from_prev,
       max(previous_purchases) as to_prev,
       count(*) as customers,
       round(avg(purchase_amount), 2) as avg_spend
from ranked
group by loyalty_tier
order by loyalty_tier;
-- Finding:
--  Customers were divided into four equally sized tiers based on their previous purchase counts, with 975 customers in each tier.
--  Average spending ranges from 59.00 in Tier 2 to 60.28 in Tier 1. Despite substantial differences in purchase history,
--  average spending remains relatively stable across all four tiers. This suggests that customers with more previous purchases
--  do not necessarily spend more per transaction.
-- ---------------------------------------------------------------------
-- Q8. Top 3 most purchased products within each category 
-- ---------------------------------------------------------------------
with item_counts as (
    select category,
           item_purchased,
           count(customer_id) as total_orders,
           rank() over (partition by category order by count(customer_id) desc) as item_rank
    from customer
    group by category, item_purchased
)
select category, item_rank, item_purchased, total_orders
from item_counts
where item_rank <= 3
order by category, item_rank;
-- Finding:
--  The leading products within each category have relatively similar order counts, with differences of no more than 15 orders 
-- between the top-ranked product and the other displayed leaders. No individual product accounts for more than approximately 4.4% of all 
-- 3,900 orders. This suggests that demand is distributed across multiple products rather than being dominated by a single bestseller.
--  


-- ---------------------------------------------------------------------
-- Q9. Are repeat buyers (more than 5 previous purchases) more likely to subscribe?

-- ---------------------------------------------------------------------
select case when previous_purchases > 5 then 'Repeat buyer (>5)' else 'Other (<=5)' end as buyer_type,
       count(*) as customers,
       round(100.0 * count(case when subscription_status = 'Yes' then 1 end) / count(*), 1) as pct_subscribed
from customer
group by buyer_type;
-- Finding:
--  27.6% of customers with more than 5 previous purchases subscribe, vs 22.4% of others. 
-- The difference is significant at the usual 0.05 level (p = 0.028) but not after correcting for seven tests, 
-- and the comparison group is small (424 customers), so it is weak evidence.
 
-- ---------------------------------------------------------------------
-- Q10. Revenue contribution of each age group (share of revenue, customers, and average spend)
-- ---------------------------------------------------------------------
select age_group,
       count(*) as customers,
       round(avg(purchase_amount), 2) as avg_spend,
       round(sum(purchase_amount), 2) as revenue,
       round(100.0 * sum(purchase_amount) / sum(sum(purchase_amount)) over (), 1) as revenue_pct
from customer
group by age_group
order by revenue desc;
-- Finding:
-- Young adults contribute the highest revenue at 62,143 (26.7%), followed by Middle-aged customers at 59,197 (25.4%), Adults at 55,978 (24.0%), 
-- and Seniors at 55,763 (23.9%). Average spending is relatively similar across all age groups, ranging from 59.07 to 60.45. 
-- Although Young adults contribute the largest revenue share, the differences between age groups are modest, 
-- suggesting that revenue is distributed fairly evenly across the customer age segments.

- ---------------------------------------------------------------------
-- Q11. Discount effectiveness: does using a discount change average spend?
-- ---------------------------------------------------------------------
select discount_applied,
       count(*) as orders,
       round(100.0 * count(*) / sum(count(*)) over (), 1) as pct_of_orders,
       round(avg(purchase_amount), 2) as avg_spend,
       round(sum(purchase_amount), 2) as revenue
from customer
group by discount_applied
order by avg_spend desc;
-- Finding:
--  Non-discounted orders have a higher average purchase amount (60.13) than discounted orders (59.28), 
-- a difference of 0.85. Non-discounted orders account for 57.0% of transactions and generate 133,670 in revenue,
--  while discounted orders account for 43.0% and generate 99,411. Discounts are not associated with larger purchases, 
--  so there is no evidence here that they raise order value. However, this comparison does not establish whether discounts 
--  increase order volume or overall profitability.

 
-- ---------------------------------------------------------------------
-- Q12. Reference points for Q3 and Q6, so "top" is compared with the overall picture
-- ---------------------------------------------------------------------
select round(avg(review_rating), 2) as overall_avg_rating,
       round(100.0 * count(case when discount_applied = 'Yes' then 1 end) / count(*), 1) as overall_discount_pct
from customer;
-- Finding:
-- The overall average review rating is 3.75 and 43.0% of orders use a discount. These are the benchmarks for Q3 and Q6.

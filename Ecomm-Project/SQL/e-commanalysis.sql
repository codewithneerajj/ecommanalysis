CREATE DATABASE ecomm;
USE ecomm;

CREATE TABLE sales(
invoice VARCHAR(20),
sku_code VARCHAR(50),
description TEXT,
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(200),
transaction_type VARCHAR(100),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


CREATE TABLE other_incomes(
invoice VARCHAR(20),
sku_code VARCHAR(50),
description TEXT,
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(200),
transaction_type VARCHAR(200),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(200)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/other_incomes.csv'
INTO TABLE other_incomes
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE transection(
invoice VARCHAR(20),
sku_code VARCHAR(50),
description TEXT,
qty DECIMAL(20,2),
inventory_category VARCHAR(100),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(200),
transaction_type VARCHAR(100),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transection.csv'
INTO TABLE transection
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


CREATE TABLE charges(
invoice VARCHAR(20),
sku_code VARCHAR(50),
description TEXT,
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(200),
transaction_type VARCHAR(100),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/charges.csv'
INTO TABLE charges
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE discount(
invoice VARCHAR(20),
description TEXT,
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(200),
discount_amount DECIMAL(20,2),
transaction_type VARCHAR(100),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/discount.csv'
INTO TABLE discount
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(invoice, description, qty, invoice_date, unit_price, customer_id, country, discount_amount, transaction_type, revenue_amount, customer_status);

CREATE TABLE expenses(
invoice VARCHAR(20),
description TEXT,
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
country VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/expenses.csv'
INTO TABLE expenses
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE marketplaces(
invoice VARCHAR(20),
sku_code VARCHAR(30),
description TEXT,
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(100),
transaction_type VARCHAR(100),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/marketplaces.csv'
INTO TABLE marketplaces
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE return_order(
invoice VARCHAR(20),
sku_code VARCHAR(30),
description TEXT,
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(100),
return_value DECIMAL(20,2),
transaction_type VARCHAR(100),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/return_order.csv'
INTO TABLE return_order
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


CREATE TABLE shipping_charges(
invoice VARCHAR(20),
shipping_code VARCHAR(40),
shipping_type VARCHAR(30),
qty DECIMAL(20,2),
invoice_date DATE,
unit_price DECIMAL(20,2),
customer_id VARCHAR(20),
country VARCHAR(50),
shipping_direction VARCHAR(50),
transaction_type VARCHAR(50),
revenue_amount DECIMAL(20,2),
customer_status VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shipping_charges.csv'
INTO TABLE shipping_charges
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- Sales Metrics

-- 1.  What is total business revenue? A. Sales & B. Other_incomes

CREATE VIEW total_business_revenue AS
SELECT
    ROUND(
        s.total_sales_revenue +
        o.total_otherincomes_revenue,
        2
    ) AS total_ecomm_revenue
FROM
(
    SELECT SUM(revenue_amount) AS total_sales_revenue
    FROM sales
) AS s
CROSS JOIN
(
    SELECT SUM(revenue_amount) AS total_otherincomes_revenue
    FROM other_incomes
) AS o;

SELECT * FROM total_business_revenue;

-- 2. Monthly Sales Trend?

CREATE VIEW Monthly_Sales_Trend AS
SELECT
YEAR (invoice_date),
MONTH(invoice_date),
ROUND(SUM(revenue_amount), 2) AS monthly_sales_revenue
FROM sales
GROUP BY YEAR (invoice_date), MONTH(invoice_date)
ORDER BY YEAR (invoice_date), MONTH(invoice_date) DESC;

SELECT * FROM Monthly_Sales_Trend;

-- 3. Top Revenue BY Country?
CREATE VIEW Top_Revenue_BY_Country AS
SELECT
country,
ROUND(SUM(revenue_amount), 2) AS revenue
FROM sales
GROUP BY country
ORDER BY revenue DESC;

SELECT * FROM Top_Revenue_BY_Country;

-- DEEP Sales Metric

-- 4. Top Product sale on each country?

CREATE VIEW Top_Product_sale_on_each_country AS
WITh product_sales AS (
	SELECT 
		country,
        sku_code,
        description,
        ROUND(SUM(revenue_amount),2) AS total_sale,
        
        ROW_NUMBER() OVER(
        PARTITION BY country
        ORDER BY SUM(revenue_amount) DESC
	) AS rank_num

	FROM sales
	GROUP BY
			country,
            sku_code,
            description
)

SELECT
country,
sku_code,
description,
total_sale
FROM product_sales
WHERE rank_num = 1;

SELECT * FROM Top_Product_sale_on_each_country;


-- 5. Least to No product sale as per country.

CREATE VIEW Least_to_No_product_sale_as_per_country AS 

WITh product_sales AS (
	SELECT 
		country,
        sku_code,
        description,
        ROUND(SUM(revenue_amount),2) AS total_sale,
        
        ROW_NUMBER() OVER(
        PARTITION BY country
        ORDER BY SUM(revenue_amount) ASC
	) AS rank_num

	FROM sales
	GROUP BY
			country,
            sku_code,
            description
)

SELECT
country,
sku_code,
description,
total_sale
FROM product_sales
WHERE rank_num = 1;

SELECT * FROM Least_to_No_product_sale_as_per_country;

-- 6. Sales by country according to month trends.
CREATE VIEW Sales_by_country_according_to_month_trends AS 
SELECT
country,
ROUND(SUM(revenue_amount),2) AS total_sales
FROM sales
GROUP BY country
ORDER BY total_sales DESC;

SELECT * FROM Sales_by_country_according_to_month_trends;



-- 7. Pricing sweet point.
CREATE VIEW Pricing_sweet_point AS
WITH sku_summary AS (

    SELECT
        sku_code,
        description,
        ROUND(AVG(unit_price),2) AS avg_unit_price,
        SUM(qty) AS total_qty_sold,
        ROUND(SUM(revenue_amount),2) AS total_revenue,
        COUNT(DISTINCT invoice) AS total_orders,
        ROUND(
            SUM(revenue_amount)
            /
            NULLIF(COUNT(DISTINCT invoice),0)
        ,2) AS avg_order_value

    FROM sales

    WHERE qty>0
      AND unit_price>0
      AND revenue_amount>0

    GROUP BY sku_code, description
),

thresholds AS (

    SELECT
        ROUND(AVG(avg_unit_price),2) AS median_price,
        ROUND(AVG(total_qty_sold),2) AS median_qty
    FROM sku_summary
)

SELECT

    s.sku_code,
    s.description,
    s.avg_unit_price,
    s.total_qty_sold,
    s.total_revenue,
    s.total_orders,
    s.avg_order_value,

    t.median_price,
    t.median_qty,

    CASE

        WHEN s.avg_unit_price >= t.median_price
        AND s.total_qty_sold >= t.median_qty
        THEN 'Star Product'

        WHEN s.avg_unit_price >= t.median_price
        AND s.total_qty_sold < t.median_qty
        THEN 'Premium Niche'

        WHEN s.avg_unit_price < t.median_price
        AND s.total_qty_sold >= t.median_qty
        THEN 'Volume Driver'
        ELSE 'Review Candidate'
    END AS pricing_segment
FROM sku_summary s
CROSS JOIN thresholds t
ORDER BY s.total_revenue DESC;

SELECT * FROM Pricing_sweet_point;


-- 8. AOV Over Time.
CREATE VIEW AOV_Over_Time AS
SELECT
YEAR(invoice_date),
MONTH(invoice_date),
AVG(revenue_amount) AS avg_revenue
FROM sales
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY YEAR(invoice_date), MONTH(invoice_date) DESC;

SELECT * FROM AOV_Over_Time;

-- Return & Refund

-- 9. Overall return
CREATE VIEW Overall_return AS
SELECT
ROUND(SUM(return_value),2) AS return_order_value
FROM return_order;

SELECT * FROM Overall_return;


-- 10. TOP 20 return SKU.

CREATE VIEW TOP_20_return_SKU AS
SELECT
sku_code,
description,
ROUND(SUM(return_value),2) AS return_order_value
FROM return_order
GROUP BY sku_code, description
ORDER BY return_order_value DESC
LIMIT 20;

SELECT * FROM TOP_20_return_SKU;

-- 11. TOP return from country wise.

CREATE VIEW TOP_return_from_country_wise AS
WITH return_product_country AS (
	SELECT
    sku_code,
    description,
    country,
    ROUND(ABS(SUM(return_value)),2) AS total_return_cost,
    
    ROW_NUMBER() OVER(
    PARTITION BY country
    ORDER BY SUM(return_value) DESC
    ) AS rank_country
	
    FROM return_order
    GROUP BY sku_code, description, country
)
    SELECT
    sku_code,
    description,
    country,
    total_return_cost
    FROM return_product_country
    WHERE rank_country = 1;

SELECT * FROM TOP_return_from_country_wise;
    

-- 12 Return Rate trend over time.
WITH monthly_sales AS (
    SELECT
        YEAR(invoice_date)      AS yr,
        MONTH(invoice_date)     AS mo,
        MONTHNAME(invoice_date) AS month_name,
        COUNT(DISTINCT invoice) AS sales_invoices,
        SUM(revenue_amount)     AS sales_revenue
    FROM sales
    WHERE qty > 0 AND revenue_amount > 0
    GROUP BY yr, mo, month_name
),
monthly_returns AS (
    SELECT
        YEAR(invoice_date)      AS yr,
        MONTH(invoice_date)     AS mo,
        COUNT(DISTINCT invoice) AS return_invoices,
        SUM(ABS(return_value))  AS return_revenue
    FROM return_order
    GROUP BY yr, mo
)
SELECT
    s.yr                                        AS year_num,
    s.mo                                        AS month_num,
    s.month_name,
    s.sales_invoices,
    COALESCE(r.return_invoices, 0)              AS return_invoices,
    ROUND(s.sales_revenue, 2)                   AS sales_revenue,
    ROUND(COALESCE(r.return_revenue, 0), 2)     AS return_revenue,

    ROUND(COALESCE(r.return_invoices, 0) * 100.0 /
          NULLIF(s.sales_invoices, 0), 2)       AS return_rate_by_count_pct,

    ROUND(COALESCE(r.return_revenue, 0) * 100.0 /
          NULLIF(s.sales_revenue, 0), 2)        AS return_rate_by_value_pct,

    ROUND(AVG(
        COALESCE(r.return_invoices, 0) * 100.0 /
        NULLIF(s.sales_invoices, 0)
    ) OVER (
        ORDER BY s.yr, s.mo
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                       AS rolling_3month_return_rate

FROM monthly_sales s
LEFT JOIN monthly_returns r 
    ON s.yr = r.yr AND s.mo = r.mo
ORDER BY s.yr, s.mo;

-- 13. Customer with high return.

SELECT
customer_id,
COUNT(DISTINCT invoice),
SUM(ABS(qty)) AS total_qty_returned,
ROUND(SUM(return_value), 2) AS total_return_value
FROM return_order
GROUP BY customer_id
ORDER BY total_return_value DESC;


-- Cost & Margins
-- 14. Net revenue. (Gross - all other )
WITH monthly_sales AS (
    SELECT
        YEAR(invoice_date)  AS yr,
        MONTH(invoice_date) AS mo,
        MONTHNAME(invoice_date) AS month_name,
        ROUND(SUM(revenue_amount), 2) AS gross_revenue
    FROM sales
    WHERE qty > 0 AND revenue_amount > 0
    GROUP BY yr, mo, month_name
),
monthly_returns AS (
    SELECT YEAR(invoice_date) yr, MONTH(invoice_date) mo,
           ROUND(SUM(ABS(return_value)), 2) AS total_returns
    FROM return_order
    GROUP BY yr, mo
),
monthly_discounts AS (
    SELECT YEAR(invoice_date) yr, MONTH(invoice_date) mo,
           ROUND(SUM(ABS(discount_amount)), 2) AS total_discounts
    FROM discount
    GROUP BY yr, mo
),
monthly_shipping AS (
    SELECT YEAR(invoice_date) yr, MONTH(invoice_date) mo,
           ROUND(SUM(ABS(revenue_amount)), 2) AS shipping_refunds
    FROM shipping_charges
    WHERE qty < 0
    GROUP BY yr, mo
),
monthly_marketplace AS (
    SELECT YEAR(invoice_date) yr, MONTH(invoice_date) mo,
           ROUND(SUM(ABS(revenue_amount)), 2) AS marketplace_fees
    FROM marketplaces
    GROUP BY yr, mo
),
monthly_charges AS (
    SELECT YEAR(invoice_date) yr, MONTH(invoice_date) mo,
           ROUND(SUM(ABS(revenue_amount)), 2) AS bank_charges
    FROM charges
    GROUP BY yr, mo
)
SELECT
    s.yr                                        AS year_num,
    s.mo                                        AS month_num,
    s.month_name,
    s.gross_revenue,

    COALESCE(r.total_returns,      0)           AS total_returns,
    COALESCE(d.total_discounts,    0)           AS total_discounts,
    COALESCE(sh.shipping_refunds,  0)           AS shipping_refunds,
    COALESCE(mk.marketplace_fees,  0)           AS marketplace_fees,
    COALESCE(ch.bank_charges,      0)           AS bank_charges,

    ROUND(
        COALESCE(r.total_returns,     0) +
        COALESCE(d.total_discounts,   0) +
        COALESCE(sh.shipping_refunds, 0) +
        COALESCE(mk.marketplace_fees, 0) +
        COALESCE(ch.bank_charges,     0)
    , 2)                                        AS total_cost_leakage,

    ROUND(
        s.gross_revenue -
        COALESCE(r.total_returns,     0) -
        COALESCE(d.total_discounts,   0) -
        COALESCE(sh.shipping_refunds, 0) -
        COALESCE(mk.marketplace_fees, 0) -
        COALESCE(ch.bank_charges,     0)
    , 2)                                        AS net_revenue,

    ROUND(
        (COALESCE(r.total_returns,     0) +
         COALESCE(d.total_discounts,   0) +
         COALESCE(sh.shipping_refunds, 0) +
         COALESCE(mk.marketplace_fees, 0) +
         COALESCE(ch.bank_charges,     0)) * 100.0 /
        NULLIF(s.gross_revenue, 0)
    , 2)                                        AS leakage_pct_of_gross

FROM monthly_sales s
LEFT JOIN monthly_returns    r  ON s.yr = r.yr  AND s.mo = r.mo
LEFT JOIN monthly_discounts  d  ON s.yr = d.yr  AND s.mo = d.mo
LEFT JOIN monthly_shipping   sh ON s.yr = sh.yr AND s.mo = sh.mo
LEFT JOIN monthly_marketplace mk ON s.yr = mk.yr AND s.mo = mk.mo
LEFT JOIN monthly_charges    ch ON s.yr = ch.yr AND s.mo = ch.mo
ORDER BY s.yr, s.mo;

-- 15. PIE chart of cost distribution.
SELECT
    cost_type,
    ROUND(SUM(cost_value), 2)           AS total_cost,
    ROUND(SUM(cost_value) * 100.0 /
        SUM(SUM(cost_value)) OVER ()
    , 2)                                AS percentage_share

FROM (
    SELECT 
        'Returns'            AS cost_type,
        ABS(return_value)    AS cost_value
    FROM return_order

    UNION ALL

    SELECT 
        'Discounts'          AS cost_type,
        ABS(discount_amount) AS cost_value
    FROM discount

    UNION ALL

    SELECT 
        'Shipping Refunds'   AS cost_type,
        ABS(revenue_amount)  AS cost_value
    FROM shipping_charges
    WHERE qty < 0

    UNION ALL

    SELECT 
        'Marketplace Fees'   AS cost_type,
        ABS(revenue_amount)  AS cost_value
    FROM marketplaces

    UNION ALL

    SELECT 
        'Bank Charges'       AS cost_type,
        ABS(revenue_amount)  AS cost_value
    FROM charges

    UNION ALL

    SELECT 
        'Bad Debt/Expenses'       AS cost_type,
        ABS(qty * unit_price) AS cost_value
    FROM expenses

) all_costs
GROUP BY cost_type
ORDER BY total_cost DESC;

-- 16. Total Discount Given vs Revenue Protected
WITH customer_discounts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice)         AS discount_events,
        ROUND(SUM(ABS(discount_amount)), 2) AS total_discount_given
    FROM discount
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
customer_sales AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice)         AS total_orders,
        ROUND(SUM(revenue_amount), 2)   AS total_revenue,
        MIN(invoice_date)               AS first_order,
        MAX(invoice_date)               AS last_order
    FROM sales
    WHERE qty > 0 AND revenue_amount > 0
    GROUP BY customer_id
)
SELECT
    cd.customer_id,
    cd.discount_events,
    cd.total_discount_given,
    cs.total_orders,
    cs.total_revenue                                        AS revenue_from_customer,

    ROUND(cs.total_revenue / 
          NULLIF(cd.total_discount_given, 0), 2)           AS revenue_per_discount_unit,

    ROUND(cd.total_discount_given * 100.0 /
          NULLIF(cs.total_revenue, 0), 2)                  AS discount_as_pct_of_revenue,

    CASE
        WHEN cs.total_revenue / NULLIF(cd.total_discount_given,0) >= 10
             THEN '✅ High ROI — Discount Justified'
        WHEN cs.total_revenue / NULLIF(cd.total_discount_given,0) >= 5
             THEN '🟡 Medium ROI — Monitor'
        WHEN cs.total_revenue / NULLIF(cd.total_discount_given,0) >= 2
             THEN '🟠 Low ROI — Review Policy'
        ELSE
             '🔴 Negative ROI — Discount Wasted'
    END                                                    AS discount_roi_segment,

    cs.first_order,
    cs.last_order

FROM customer_discounts cd
LEFT JOIN customer_sales cs ON cd.customer_id = cs.customer_id
ORDER BY cd.total_discount_given DESC;

-- Customer Intelligence
-- 17. Registered vs Guest Customer Revenue Split
SELECT
customer_status,
ROUND(SUM(revenue_amount), 2) AS total_revenue
FROM sales
GROUP BY customer_status;

-- 18. Top 25 Customers by Lifetime Revenue
SELECT
customer_id,
ROUND(SUM(revenue_amount),2) AS reveneue
FROM sales
GROUP BY customer_id
ORDER BY reveneue DESC
LIMIT 25;

-- 19. Customer Revenue vs Return Rate
SELECT
    s.customer_id,
    s.customer_status,
    ROUND(SUM(s.revenue_amount), 2)      AS total_revenue,
    COUNT(DISTINCT s.invoice)            AS total_orders,
    COALESCE(r.total_returns, 0)         AS total_returns,
    ROUND(COALESCE(r.total_returns, 0) * 100.0 / 
          NULLIF(COUNT(DISTINCT s.invoice), 0), 2) AS return_rate_pct,

    CASE
        WHEN SUM(s.revenue_amount) >= 1000 
             AND COALESCE(r.total_returns,0) * 100.0 / 
                 NULLIF(COUNT(DISTINCT s.invoice),0) < 10 THEN 'Ideal Customer'
        WHEN SUM(s.revenue_amount) >= 1000 
             AND COALESCE(r.total_returns,0) * 100.0 / 
                 NULLIF(COUNT(DISTINCT s.invoice),0) >= 10 THEN 'High Value High Risk'
        WHEN SUM(s.revenue_amount) < 1000 
             AND COALESCE(r.total_returns,0) * 100.0 / 
                 NULLIF(COUNT(DISTINCT s.invoice),0) >= 10 THEN 'Policy Abuser'
        ELSE 'Regular'
    END AS customer_segment

FROM sales s
LEFT JOIN (
    SELECT customer_id, COUNT(DISTINCT invoice) AS total_returns
    FROM return_order
    GROUP BY customer_id) r
ON s.customer_id = r.customer_id

WHERE s.qty > 0 AND s.customer_id IS NOT NULL
GROUP BY s.customer_id, s.customer_status, r.total_returns
ORDER BY total_revenue DESC;

-- 20. One-Time vs Repeat Buyers
SELECT
	buyer_type,
    COUNT(DISTINCT customer_id) AS unique_customer,
    ROUND(SUM(lifetime_revenue),2) AS order_revenue,
    ROUND(AVG(lifetime_revenue), 2) AS avg_revenue_per_customer
FROM (
		SELECT
        customer_id,
        COUNT(DISTINCT invoice) AS unique_orders_invoice,
        ROUND(SUM(revenue_amount), 2) AS lifetime_revenue,
        CASE
			WHEN COUNT(DISTINCT invoice) = 1 THEN 'One Time Buyer'
            WHEN COUNT(DISTINCT invoice) <=5 THEN 'Occasional Buyer'
            WHEN COUNT(DISTINCT invoice) <=10 THEN 'Regular Buyer'
            ELSE 'Loyal Buyer'
		END AS buyer_type
        
        FROM sales
        WHERE qty > 0 AND revenue_amount > 0 AND customer_id IS NOT NULL
		GROUP BY customer_id
	) AS customer_segmentation
GROUP BY buyer_type
ORDER BY buyer_type;

-- 21. Customer Activity by Country
SELECT
country,
ROUND(SUM(revenue_amount),2) AS total_revenue
FROM sales
GROUP BY country
ORDER BY total_revenue DESC;

-- 22. New vs Returning Customers Monthly
SELECT
    country,
    COUNT(DISTINCT customer_id)          AS unique_customers,
    COUNT(DISTINCT invoice)              AS total_orders,
    ROUND(SUM(revenue_amount), 2)        AS total_revenue,
    ROUND(SUM(revenue_amount) / 
          NULLIF(COUNT(DISTINCT customer_id), 0), 2) AS revenue_per_customer,
    ROUND(SUM(revenue_amount) / 
          NULLIF(COUNT(DISTINCT invoice), 0), 2)     AS avg_order_value

FROM sales
WHERE qty > 0 AND revenue_amount > 0
GROUP BY country
ORDER BY total_revenue DESC;

-- Inventory & Stock Corrections

-- 23. SKUs with Most Stock Corrections
SELECT
    sku_code,
    description,
    inventory_category,
    COUNT(*)                            AS correction_count,
    SUM(CASE WHEN qty < 0 THEN 1 ELSE 0 END) AS negative_corrections,
    SUM(CASE WHEN qty > 0 THEN 1 ELSE 0 END) AS positive_corrections,
    ROUND(SUM(qty), 0)                  AS net_qty_adjustment

FROM transection
GROUP BY sku_code, description, inventory_category
ORDER BY correction_count DESC
LIMIT 30;

-- 24. Positive vs Negative Adjustments by SKU
SELECT
    sku_code,
    description,
    SUM(CASE WHEN qty > 0 THEN qty  ELSE 0 END)  AS total_positive_qty,
    SUM(CASE WHEN qty < 0 THEN qty  ELSE 0 END)  AS total_negative_qty,
    SUM(qty)                                      AS net_qty,
    ROUND(SUM(CASE WHEN qty > 0 THEN qty * unit_price ELSE 0 END), 2) AS positive_value,
    ROUND(SUM(CASE WHEN qty < 0 THEN ABS(qty * unit_price) ELSE 0 END), 2) AS negative_value,
    ROUND(SUM(qty * unit_price), 2)               AS net_value_impact

FROM transection
GROUP BY sku_code, description
ORDER BY negative_value DESC;

-- 25. Stock Correction Volume Over Time
SELECT
    YEAR(invoice_date)                  AS year_num,
    MONTH(invoice_date)                 AS month_num,
    MONTHNAME(invoice_date)             AS month_name,
    COUNT(*)                            AS total_corrections,
    SUM(CASE WHEN qty < 0 THEN 1 ELSE 0 END) AS negative_count,
    SUM(CASE WHEN qty > 0 THEN 1 ELSE 0 END) AS positive_count,
    ROUND(SUM(ABS(qty * unit_price)), 2) AS total_value_adjusted

FROM transection
GROUP BY year_num, month_num, month_name
ORDER BY year_num, month_num;

-- 26. Total Financial Value of Negative Adjustments
SELECT
    sku_code,
    description,
    COUNT(*)                                    AS negative_events,
    SUM(ABS(qty))                               AS total_units_lost,
    ROUND(AVG(unit_price), 2)                   AS avg_unit_price,
    ROUND(SUM(ABS(qty) * unit_price), 2)        AS financial_loss_value,
    ROUND(SUM(ABS(qty) * unit_price) * 100.0 /
        SUM(SUM(ABS(qty) * unit_price)) OVER (), 2) AS pct_of_total_loss

FROM transection
WHERE qty < 0
GROUP BY sku_code, description
ORDER BY financial_loss_value DESC;
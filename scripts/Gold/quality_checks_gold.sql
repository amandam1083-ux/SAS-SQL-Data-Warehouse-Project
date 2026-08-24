/*
===============================================================================
Quality Checks
================================================================================
Script Purpose:
  This script performs quality checks wo validate the intergrity, consistency, 
  and accuracy of the Gold layer.  These checks ensure:
  * uniqueness of surrogate kays in dimension tables.
  * referential integrity between fact and dimension tables.
  * validation of relationshipd in the data model for analytical purposes.

Usaeg Notes:
  * Run these checks after data loading Silver Layer.
  * Investigate and resolve any discrepancies found during the checks.
==============================================================================
*/

--============================================================================
-- Checking 'gold.dim_customers'
--============================================================================
--check for Uniqueness of customer Kay in gold.dim_customers
--Expectation: No results

Select
    customer_key,
  count(*)
  from gold.dim_customers
  group by customer_key
  having count(*)>1;

--================================================================================
-- Checking 'gold.dim_products'
--================================================================================

Select
    product_key,
  count(*)
  from gold.dim_products
  group by product_key
  having count(*)>1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
--Foreign key integrity (Dimensions)  
--expection zero
Select * 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where c.customer_key is null

Select * 
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
where p.product_key is null


-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL 

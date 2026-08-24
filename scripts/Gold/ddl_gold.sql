/*
==============================================================================================
DDL Script: Create Gold View
==============================================================================================
Script Purpose:
  This script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)

  Each view performs transactions and combines data from the Silver layer
  to produce a clean, enriched, and business-ready dataset.

Usage:
  -These views can be queried directly for analyitcs and reporting.
==============================================================================================
*/



--===================================================
--Create customer view
--===================================================
If OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;

GO
  
	CREATE VIEW gold.dim_customers as
	Select
	ROW_NUMBER() OVER (Order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	cl.CNTRY as country,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr ---crm is the Master for gender info
		else COALESCE(ca.gen, 'n/a') --COALESCE will change a null into 'n/a'
	END as gender,
	ci.cst_marital_status as marital_status,
	ca.BDATE as birthdate,
	ci.cst_create_date as create_date
	From silver.crm_cust_info ci
	left join silver.erp_cust_AZ12 ca
	on ci.cst_key = ca.cid
	left join silver.erp_LOC_A101 cl
	on ci.cst_key = cl.cid

--making sure the gender column in the view has the correct values
	Select distinct
	gender
	from gold.dim_customers


	Select
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
	from silver.crm_prd_info pn
	left join silver.erp_PX_CAT_G1V2 pc
	on pn.cat_id = pc.id
	Where pn.prd_end_dt is null --filter out product data that has ended (historical)

	--check uniqueness
	--expect zero
	Select prd_key, count(*) from (
		Select
		pn.prd_id,
		pn.cat_id,
		pn.prd_key,
		pn.prd_nm,
		pn.prd_cost,
		pn.prd_line,
		pn.prd_start_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
		from silver.crm_prd_info pn
		left join silver.erp_PX_CAT_G1V2 pc
		on pn.cat_id = pc.id
		Where pn.prd_end_dt is null --filter out product data that has ended (historical)
		) t
		group by prd_key
		having count(*) >1

--================================================================================
--CREATE Products view
--================================================================================
If OBJECT_ID('gold.dim_products','V') IS NOT NULL
  DROP VIEW gold.dim_products;

GO
  
  
  
  CREATE View gold.dim_products as 
		Select
		row_number() OVER (order by pn.prd_start_dt, pn.prd_key) as product_key,
		pn.prd_id as product_id,
		pn.prd_key as product_number,
		pn.prd_nm as product_name,
		pn.cat_id as category_id,
		pc.cat as category,
		pc.subcat as subcategory,
		pc.maintenance,
		pn.prd_cost as cost,
		pn.prd_line as line,
		pn.prd_start_dt as start_date
		from silver.crm_prd_info pn
		left join silver.erp_PX_CAT_G1V2 pc
		on pn.cat_id = pc.id
		Where pn.prd_end_dt is null 

		select * from gold.dim_products

--=============================================
--Create View gold.fact_sales
--=============================================
IF OBJECT_ID('gold.fact_sales','V') IN NULL
  DROP VIEW gold.fact_sales;

GO
  
Create view gold.fact_sales as
Select 
sl.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sl.sls_order_dt as order_date,
sl.sls_ship_dt as shipping_date,
sl.sls_due_dt as due_date,
sl.sls_sales as sales_amount,
sl.sls_quantity as quantity,
sl.sls_price as price
from silver.crm_sls_details sl
left join gold.dim_products pr
on sl.sls_prd_key = pr.product_number
left join gold.dim_customers cu
on sl.sls_cust_id = cu.customer_id


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

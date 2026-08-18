/*
====================================================================================
Quality Checks
===================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy, 
  and standardization across the 'silver' schema.  It includes checks for:
  -Null or duplicate primary keys
  -Unwanted spaces in string fields
  -Data standardization and consistency
  -Invalid date ranges and orders
  -Data consistency between related fields

Usage Notes:
  -Run these checks after data loading silver layer.
  -Investigate and resolve any discrepancies found during the checks.
========================================================================================

*/


--=======================================
--Checking 'silver.crm_cust_info'
--=======================================
	Select
	cst_id,
	Count(*)
	from silver.crm_cust_info
	group by cst_id
	having count(*) >1 or cst_id is null


--=======================================
--Checking 'silver.crm_prd_info'
--=======================================

	---Checking quality of data inserted
	Select
	prd_id,
	count(*)
	from silver.crm_prd_info
	group by prd_id
	HAVING count(*)>1 or prd_id is null

	--checking for unwanted spaces
	SELECT prd_nm
	from silver.crm_prd_info
	where prd_nm != TRIM(prd_nm)

	--Checking for negative costs or nulls
	Select
	prd_cost
	from silver.crm_prd_info
	Where prd_cost<0 or prd_cost is null

	--Data standardization & consistency
	select distinct prd_line
	from silver.crm_prd_info

	--Check for invalid orders
	Select *
	from silver.crm_prd_info
	where prd_end_dt < prd_start_dt

	Select *
	from silver.crm_prd_info

--=======================================
--Checking 'silver.crm_sls_details'
--=======================================
	
	--checking for leading and trailing id for order number
	Select
	sls_ord_num
	from silver.crm_sls_details
	where sls_ord_num != Trim(sls_ord_num)

	--making sure the keys having alignments in the respective tables
	Select
	sls_prd_key
	from silver.crm_sls_details
	where sls_prd_key not in (select prd_key from silver.crm_prd_info)

	Select
	sls_cust_id
	from silver.crm_sls_details
	where sls_cust_id not in (select cst_id from silver.crm_cust_info)


	-- checking that the order date is is before the shipping date and the shipping date is before the due date.
	Select
	*
	From silver.crm_sls_details
	where sls_order_dt>sls_ship_dt or sls_ship_dt>sls_due_dt or sls_order_dt>sls_due_dt


	--making sure the sales = quantity * price and there are no zeros, negatives or nulls
	Select
	sls_sales,
	sls_quantity,
	sls_price
	from silver.crm_sls_details
	where sls_sales != sls_quantity* sls_price
	or sls_quantity is null
	or sls_sales is null
	or sls_price is null
	or sls_quantity <=0
	or sls_sales <=0
	or sls_price <=0

	Select * from silver.crm_sls_details

--=======================================
--Checking 'silver.erp_cust_AZ12'
--=======================================

--Data Standardization & Consistency
Select Distinct
gen
from silver.erp_cust_AZ12



--=======================================
--Checking 'silver.erp_loc_a101'
--=======================================
--Data Standardization & Consistency

Select Distinct
cntry
from silver.erp_LOC_A101
order by cntry;


--=======================================
--Checking 'silver.erp_px_cat_g1v2'
--=======================================
--Check for unwanted spaces
--Expectation: No results
Select
*
From silver.erp_PX_CAT_G1V2
Where cat != TRIM(cat)
	or subcat != TRIM(subcat)
	or maintenance != TRIM(maintenance);

--Data Standardization & Consistency
Select Distinct
	maintenance
from silver.erp_PX_CAT_G1V2;

/*
=====================================================================================================
Stored Procedure: Load Silver layer (Bronze -> Silver)
=====================================================================================================
Script Purpose:
  This record procedure performs the ETL (Extract, Transform, Load) process to populate
  the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
  -Inserts Silver tables
  -Inserts transformed and cleaned data from Bronze into Silver values.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;

====================================================================================================

*/


Create OR ALTER Procedure silver.load_silver AS
BEGIN
	Declare @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	Begin Try
	SET @batch_start_time = GETDATE();
		---Inserting the data into the created tables---
		--first empty the tables and then bulk load all the data.  Then check the row counts from the bronze tables and the silver tables to make sure they match/make sense--
			PRINT'================================================================';
			Print'LOADING Silver LAYER';
			Print'================================================================';

			Print'----------------------------------------------------------------';
			Print'LOADING CRM TABLES';
			Print'----------------------------------------------------------------';

			Set @start_time = GETDATE();
			PRINT'>>Truncating table silver.crm_cust_info;'
				TRUNCATE TABLE silver.crm_cust_info;
				Print '>>Inserting Data into: silver.crm_cust_info';

				Insert into silver.crm_cust_info (
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date)

				Select
				cst_id,
				cst_key,
				TRIM(cst_firstname) as cst_firstname,  --remove leading and trailing spaces
				TRIM(cst_lastname) as cst_lastname,    --remove leading and trailing spaces
				Case when Upper(TRIM(cst_marital_status)) = 'S' then 'Single'
					 when Upper(Trim(cst_marital_status)) = 'M' then 'Married'
					 else 'n/a'
				End cst_marital_status,  --align full value with abbreviated value
				Case when Upper(TRIM(cst_gndr)) = 'F' then 'Female'
					 when Upper(Trim(cst_gndr)) = 'M' then 'Male'
					 else 'n/a'
				End cst_gndr, --align full value with abbreviated value
				cst_create_date
				from (
				Select
				*,
				row_number() over (Partition by cst_id order by cst_create_date desc) as flag_last
				from bronze.crm_cust_info) t where flag_last = 1
						Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			Print'>>--------------------------'
			
			--Select count(*) as cust_count from silver.crm_cust_info

----------------------------------------------------------------------------------------------
			Set @start_time = GETDATE();
			PRINT'>>Truncating table silver.crm_prd_info;'
				TRUNCATE TABLE silver.crm_prd_info;
				Print '>> Inserting Data into: silver.crm_prd_info';

				Insert into silver.crm_prd_info (
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
				)

				Select
				prd_id,
				replace(SUBSTRING(prd_key, 1, 5),'-','_') as cat_id, --extract category ID
				substring(prd_key,7,len(prd_key)) as prd_key,        --extract product key
				prd_nm,
				isnull(prd_cost,0) as prd_cost,
				CASE UPPER(TRIM(prd_line))
					WHEN 'M' then 'Mountain'
					When 'R' then 'Roads'
					When 'S' then 'Other Sales'
					WHen 'T' then 'Touring'
				else 'n/a'
				end as prd_line,  ---Map product line codes to descriptive values
				prd_start_dt,
				DATEADD(day,-1, (LEAD(prd_start_dt) OVER ( Partition by prd_key Order by prd_start_dt))) as prd_end_dt  --calculate end date as on day before the next start date
				from bronze.crm_prd_info
				Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';
			
			--Select count(*) as sales_count from bronze.ccrm_prd_info

---------------------------------------------------------------------------------------------------
			SET @start_time = GETDATE();
			PRINT'>>Truncating table silver.crm_sls_details;'
				TRUNCATE TABLE silver.crm_sls_details;
				Print '>> Inserting Data into: silver.crm_sls_details';


				Insert into silver.crm_sls_details (
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
				)

				Select
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				case when sls_order_dt = 0 or Len(sls_order_dt) !=8 then null
					else cast(cast(sls_order_dt as varchar) as DATE)
				end as sls_order_dt,
				case when sls_ship_dt = 0 or Len(sls_ship_dt) !=8 then null
					else cast(cast(sls_ship_dt as varchar) as DATE)
				end as sls_ship_dt,
				case when sls_due_dt = 0 or Len(sls_due_dt) !=8 then null
					else cast(cast(sls_due_dt as varchar) as DATE)
				end as sls_due_dt,
				Case when sls_sales is null or sls_sales<=0 or sls_sales != sls_quantity*ABS(sls_price)
							then sls_quantity*ABS(sls_price)	
					else sls_sales
				end as sls_sales,
				sls_quantity,
				Case when sls_price is null or sls_price<=0 then ABS(sls_sales/NULlif(sls_quantity,0))
					else sls_price
				end as sls_price
				from bronze.crm_sls_details
			Set @end_time = GETDATE();

			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';
			--Select count(*) as prd_count from silver.crm_sls_details

			 Print'----------------------------------------------------------------';
			 Print'LOADING ERP TABLES';
			 Print'----------------------------------------------------------------';
			Set @start_time = GETDATE();
			PRINT'>>Truncating table silver.erp_cust_AZ12;'
				TRUNCATE TABLE silver.erp_cust_AZ12;
				Print '>> Inserting Data into: silver.erp_cust_AZ12';

				Insert into silver.erp_cust_AZ12(
				CID,
				BDATE,
				GEN
				)
				Select
				Case when CID like 'NAS%' then substring (CID, 4, len(CID))
					else CID
				End as CID,
				Case when BDATE > GETDATE() then NULL
					else BDATE
				End as BDATE,
				Case When UPPER(TRIM(GEN)) in ('F', 'Female') then 'Female'
					When UPPER(TRIM(GEN)) in ('M', 'Male') then 'Male'
					else 'n/a'
				End as GEN
				from bronze.erp_cust_AZ12
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';

			--Select count(*) as loc_count from silver.erp_cust_AZ12

------------------------------------------------------------------------------------------------------
			Set @start_time = GETDATE();
			PRINT'>>Truncating table silver.erp_LOC_A101;'
				TRUNCATE TABLE silver.erp_LOC_A101;
				Print '>> Inserting Data into: silver.erp_LOC_A101';


				Insert into silver.erp_LOC_A101(
				CID,
				CNTRY)
				Select
				replace(CID,'-','') as CID2,
				Case When TRIM(CNTRY) in ('USA','US') then 'United States'
					When TRIM(CNTRY) in ('DE') then 'Germany'
					When TRIM(CNTRY) ='' or CNTRY IS NULL then 'n/a'
					else TRIM(CNTRY)
				End CNTRY
				from bronze.erp_LOC_A101
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';

			--Select count(*) as cust_count from silver.erp_LOC_A101

----------------------------------------------------------------------------------------------------
			Set @start_time = GETDATE();
			PRINT'>>Truncating table silver.erp_PX_CAT_G1V2;'
				TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
				Print '>> Inserting Data into: silver.erp_PX_CAT_G1V2';

				Insert into silver.erp_PX_CAT_G1V2(
				ID,
				CAT,
				SUBCAT,
				MAINTENANCE)

				Select
				ID,
				CAT,
				SUBCAT,
				MAINTENANCE
				from bronze.erp_PX_CAT_G1V2
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';

			--Select count(*) as PX_count from silver.erp_PX_CAT_G1V2
	SET @batch_end_time = GETDATE();
	Print'==============================================================';
	Print'Loading silver layer is complete';
	Print'>> Total Load Duration: ' +CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) as NVARCHAR) +' seconds';
	Print'==============================================================';
	End Try
	Begin Catch
		Print'==========================================================';
		Print'Error Occured during loading of silver layer';
		Print'Error Message' + Error_message();
		Print'Error Message' + CAST(Error_message() as NVARCHAR);
		Print'Error Message' + CAST(Error_State() as NVARCHAR);
		Print'==========================================================';
	End Catch
END


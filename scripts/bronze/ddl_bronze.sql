/*
===================================================================================================================================
DDL SCRIPT: Create Bronze Tables
===================================================================================================================================
Script Purpose:
  This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
  Run this script to re-define the DDL structure of 'bronze' tables.
===================================================================================================================================
*/


If OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL
	Drop Table bronze.crm_cust_info;

Create table bronze.crm_cust_info (
cst_is INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_material_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

GO

If OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	Drop table bronze.crm_prd_info;
Create Table bronze.crm_prd_info (
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE
);

GO

IF OBJECT_ID ('bronze.crm_sls_details', 'U') IS NOT NULL
	Drop table bronze.crm_sls_details;

Create table bronze.crm_sls_details (
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);


GO

IF OBJECT_ID ('bronze.erp_cust_AZ12', 'U') IS NOT NULL
	Drop table bronze.erp_cust_AZ12;

Create table bronze.erp_cust_AZ12 (
CID NVARCHAR (50),
BDATE Date,
GEN NVARCHAR(50),
);

GO

If OBJECT_ID ('bronze.erp_LOC_A101', 'U') IS NOT NULL
	Drop table bronze.erp_LOC_A101;

Create table bronze.erp_LOC_A101 (
CID NVARCHAR(50),
CNTRY NVARCHAR(50)
);

GO


IF OBJECT_ID ('bronze.erp_PX_CAT_G1V2', 'U') IS NOT NULL
	Drop table bronze.erp_PX_CAT_G1v2;

Create table bronze.erp_PX_CAT_G1V2  (
ID NVARCHAR(50),
CAT NVARCHAR (50),
SUBCAT NVARCHAR (50),
MAINTENANCE NVARCHAR(50),
);






Create OR ALTER Procedure bronze.load_bronze AS
BEGIN
	Declare @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	Begin Try
	SET @batch_start_time = GETDATE();
		---Inserting the data into the created tables---
		--first empty the tables and then bulk load all the data.  Then check the row counts from the csv and the table match/make sense--
			PRINT'================================================================';
			Print'LOADING BRONZE LAYER';
			Print'================================================================';

			Print'----------------------------------------------------------------';
			Print'LOADING CRM TABLES';
			Print'----------------------------------------------------------------';

			Set @start_time = GETDATE();
			PRINT'>>Truncating table: bronze.crm_cust_info';
			TRUNCATE Table bronze.crm_cust_info;

			Print'>>Insert data into: bronze.crm_cust_info';
			BULK insert bronze.crm_cust_info
			From 'C:\Users\mrc90\OneDrive\Documents\Amanda Mitchell Projects Portfolio\2026\Data Warehouse\Data\CRM\cust_info.csv'
			With (
				Firstrow = 2,
				Fieldterminator = ',',
				tablock
				);
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			Print'>>--------------------------'
			
			--Select count(*) as cust_count from bronze.crm_cust_info

			Set @start_time = GETDATE();
			PRINT'>>Truncating table: bronze.crm_sls_details';
			Truncate table bronze.crm_sls_details;

			Print'>>Inserting data into:bronze.crm_sls_details';
			BULK INSERT bronze.crm_sls_details
			from 'C:\Users\mrc90\OneDrive\Documents\Amanda Mitchell Projects Portfolio\2026\Data Warehouse\Data\CRM\sales_details.csv'
			With (
				firstrow = 2,
				Fieldterminator = ',',
				tablock
				);
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';--Select count(*) as sales_count from bronze.crm_sls_details
			
			Set @start_time = GETDATE();
			PRINT'>>Truncating table: bronze.crm_prd_info';
			Truncate table bronze.crm_prd_info;

			Print'>>Inserting data into: bronze.crm_prd_info';
			BULK INSERT bronze.crm_prd_info
			from 'C:\Users\mrc90\OneDrive\Documents\Amanda Mitchell Projects Portfolio\2026\Data Warehouse\Data\CRM\prd_info.csv'
			with(
				firstrow = 2,
				fieldterminator = ',',
				tablock
				);
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';
			--Select count(*) as prd_count from bronze.crm_prd_info

			 Print'----------------------------------------------------------------';
			 Print'LOADING ERP TABLES';
			 Print'----------------------------------------------------------------';
			Set @start_time = GETDATE();
			PRINT'>>Truncating table: bronze.erp_LOC_A101';
			Truncate table bronze.erp_LOC_A101
	
			Print'>>Inserting data into: bronze.erp_LOC_A101';
			Bulk INSERT bronze.erp_LOC_A101
			from 'C:\Users\mrc90\OneDrive\Documents\Amanda Mitchell Projects Portfolio\2026\Data Warehouse\Data\ERP\LOC_A101.csv'
			with(
				firstrow = 2,
				fieldterminator = ',',
				tablock
				);
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';

			--Select count(*) as loc_count from bronze.erp_LOC_A101
			Set @start_time = GETDATE();
			PRINT'>>Truncating table: bronze.erp_cust_AZ12';
			Truncate table bronze.erp_cust_AZ12
		
			Print'>>Inserting data into: bronze.erp_cust_AZ12';
			Bulk Insert bronze.erp_cust_AZ12
			from 'C:\Users\mrc90\OneDrive\Documents\Amanda Mitchell Projects Portfolio\2026\Data Warehouse\Data\ERP\CUST_AZ12.csv'
			with (
				firstrow = 2,
				fieldterminator = ',',
				tablock
				);
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';

			--Select count(*) as cust_count from bronze.erp_cust_AZ12
			Set @start_time = GETDATE();
			PRINT'>>Truncating table: bronze.erp_PX_CAT_G1V2';
			Truncate table bronze.erp_PX_CAT_G1V2
			
			Print'>>Inserting data into: bronze.erp_PX_CAT_G1V2';
			Bulk Insert bronze.erp_PX_CAT_G1V2
			from  'C:\Users\mrc90\OneDrive\Documents\Amanda Mitchell Projects Portfolio\2026\Data Warehouse\Data\ERP\PX_CAT_G1V2.csv'
			with(
				firstrow = 2,
				fieldterminator = ',',
				tablock
				);
			Set @end_time = GETDATE();
			PRINT'>>Load Duration: ' + CAST(Datediff(second, @start_time, @end_time) as NVARCHAR) +' seconds';
			print'>>-------------------';

			--Select count(*) as PX_count from bronze.erp_PX_CAT_G1V2
	SET @batch_end_time = GETDATE();
	Print'==============================================================';
	Print'Loading bronze layer is complete';
	Print'>> Total Load Duration: ' +CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) as NVARCHAR) +' seconds';
	Print'==============================================================';
	End Try
	Begin Catch
		Print'==========================================================';
		Print'Error Occured during loading of bronze layer';
		Print'Error Message' + Error_message();
		Print'Error Message' + CAST(Error_message() as NVARCHAR);
		Print'Error Message' + CAST(Error_State() as NVARCHAR);
		Print'==========================================================';
	End Catch
END

/*
===============================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schems from external csv files.
  It performs the following actions:
  -Truncates the bronze tables before loading data.
  -Uses the 'Bulk Insert' command to load data from csv files to bronze tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return values.

Usage Example:
  EXEC bronze.load_bronze;
================================================================================================
*/
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

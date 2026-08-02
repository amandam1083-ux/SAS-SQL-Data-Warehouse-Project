
/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated.  Additionally, the script sets up three schemas
	within the database: 'bronze,'silver', 'gold'.

WARNING:
	Running this script will drop the enitre 'DataWarehouse' database it if exists.
	All data in the database will be permanently deleted.  Proceed with catuion
	and ensure you have proper backups before running this script.

*/









USE Master;
GO

---Drop and recreate the 'DataWarehouse' database  
----If the database already exists it will delete it 
----and create a new one with the same name
IF EXISTS (Select 1 From sys.databases Where name = 'DataWarehouse')
Begin
	Alter DATABASE DataWarehouse SET SINGLE_USER with rollback immediate;
	Drop DATABASE DataWarehouse;
End;
GO


--- Create Database 'DataWarehouse'

USE master;

CREATE Database DataWarehouse;

Use DataWareHouse;


---Creates the Schema
----a schema provides a logical framework for storing
-----and managing data within a database.
Create SCHEMA bronze;
go
Create SCHEMA silver;
go
Create SCHEMA gold;

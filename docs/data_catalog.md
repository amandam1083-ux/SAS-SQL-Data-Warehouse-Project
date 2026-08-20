Data Dictionary for Gold Layer

  Overview

  The Gold Layer is the business_level data representation, structured to support analytical and reporting use cases. 
  It consists of dimension tables and fact tables for specific business metrics.

  1. gold.dim_customers
  *Purpose Store customer details enriched with demographic and geographic data.
  *Columns:
    Column Name	Data Type	Description
    customer_key	INT	Surragate key uniquely identifying each customer record in the dimension table.
    customer_id	INT	Unique numerical identifier assigned to each customer.
    customer_number	NVARCHAR(50)	Alphanumeric identifier representing the customer, used for tracking and referencing.
    first_name	NVARCHAR(50)	The customer’s first name, as recorded in the system.
    last_name	NVARCHAR(50)	The customer’s last name or family name.
    country	NVARCHAR(50)	The country in the customer’s address
    gender	NVARCHAR(50)	The gender of the customer.
    marital_status	NVARCHAR(50)	Indicates if the customer is married, single or n/a.
    birthdate	NVARCHAR(50)	Date the customer was born.
    create_date	NVARCHAR(50)	Date the customer relationship was made.

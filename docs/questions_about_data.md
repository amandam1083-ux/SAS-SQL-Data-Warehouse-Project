# Questions to ask about the data sources:

## Business Context & Ownership:
 * Who owns the data?
 * What business process it supports?
 * Systems & Data documentation
 * Data model & Data catalog

## Architecture & Technology Stack:
  * How is data stored (SQL Server, Oracle, AWS, Azure...)?
  * What are the intergation capabilities (API, Kafka, File Extract, Direct DB,...)?

## Extract & Load:
 * Incremental vs Full Loads?
 * Data Scape & historical needs?
 * What is the expected size of the extracts?
 * Are there any data volume limitations?
 * How to avoid impacting the source system's performance?
 * Authentication and authoriazation (tokens, SSH keys, VPN, IP whitelisting...)?

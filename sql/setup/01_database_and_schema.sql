-- ============================================================================
-- ITRON INTELLIGENCE AGENT - Database and Schema Setup
-- File: sql/setup/01_database_and_schema.sql
-- Description: Creates the ITRON_DB database, schemas, and warehouse
-- ============================================================================

-- Create the main database
CREATE DATABASE IF NOT EXISTS ITRON_DB;
USE DATABASE ITRON_DB;

-- Create schemas for data organization
-- RAW: Operational data from meters, sensors, and field operations
CREATE SCHEMA IF NOT EXISTS ITRON_DB.RAW;

-- ANALYTICS: Aggregated views, ESG metrics, ML predictions
CREATE SCHEMA IF NOT EXISTS ITRON_DB.ANALYTICS;

-- ONTOLOGY: ESGOnt ontology tables for deterministic rule-based validation
CREATE SCHEMA IF NOT EXISTS ITRON_DB.ONTOLOGY;

-- Create the warehouse
CREATE OR REPLACE WAREHOUSE ITRON_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Itron Intelligence Agent';

USE WAREHOUSE ITRON_WH;
USE SCHEMA ITRON_DB.RAW;

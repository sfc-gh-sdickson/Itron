-- ============================================================================
-- ITRON INTELLIGENCE AGENT - Cortex Search Service
-- File: sql/search/07_create_cortex_search.sql
-- Description: Creates Cortex Search service over ESG documents
-- ============================================================================

USE DATABASE ITRON_DB;
USE WAREHOUSE ITRON_WH;
USE SCHEMA ITRON_DB.ANALYTICS;

-- Create Cortex Search Service for ESG document retrieval
CREATE OR REPLACE CORTEX SEARCH SERVICE ITRON_DB.ANALYTICS.ESG_SEARCH_SERVICE
  ON CONTENT
  ATTRIBUTES DOCUMENT_TYPE, ESG_PILLAR, SDG_GOAL, YEAR
  WAREHOUSE = ITRON_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search over Itron ESG documents, sustainability reports, policies, and frameworks'
AS
  SELECT
    DOCUMENT_ID,
    TITLE,
    CONTENT,
    DOCUMENT_TYPE,
    ESG_PILLAR,
    SDG_GOAL,
    YEAR,
    SOURCE,
    AUTHOR,
    TAGS
  FROM ITRON_DB.ANALYTICS.ESG_DOCUMENTS;

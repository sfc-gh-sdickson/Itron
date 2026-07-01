<img src="Snowflake_Logo.svg" width="200">

# Itron Intelligence Agent - Setup Guide

This guide provides step-by-step instructions to deploy the Itron Intelligence Agent on Snowflake. The agent combines operational meter data, ESG metrics, the ESGOnt ontology, Cortex Search, and ML prediction functions into a unified natural language interface.

---

## 1. Prerequisites

### Account Requirements

<table>
  <tr>
    <th>Requirement</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>Snowflake Edition</td>
    <td>Enterprise or Business Critical</td>
  </tr>
  <tr>
    <td>Cloud Region</td>
    <td>AWS US region (for Cortex Agent and Cortex Search availability)</td>
  </tr>
  <tr>
    <td>Cortex Agent</td>
    <td>Must be enabled for the account (contact Snowflake support if unavailable)</td>
  </tr>
  <tr>
    <td>Cortex Search</td>
    <td>Must be enabled for the account</td>
  </tr>
  <tr>
    <td>Semantic Views</td>
    <td>Must be enabled for the account (Cortex Analyst)</td>
  </tr>
</table>

### Roles and Privileges

<table>
  <tr>
    <th>Role</th>
    <th>Purpose</th>
    <th>Required Privileges</th>
  </tr>
  <tr>
    <td><code>ACCOUNTADMIN</code> or <code>SYSADMIN</code></td>
    <td>Initial setup (database, warehouse, schemas)</td>
    <td>CREATE DATABASE, CREATE WAREHOUSE</td>
  </tr>
  <tr>
    <td><code>SYSADMIN</code></td>
    <td>Create tables, views, functions, search services</td>
    <td>CREATE TABLE, CREATE VIEW, CREATE FUNCTION, CREATE CORTEX SEARCH SERVICE</td>
  </tr>
  <tr>
    <td><code>SYSADMIN</code></td>
    <td>Create the agent</td>
    <td>CREATE AGENT</td>
  </tr>
  <tr>
    <td><code>PUBLIC</code> (or custom role)</td>
    <td>End-user access to the agent</td>
    <td>USAGE on database, schemas, functions; SELECT on tables/views</td>
  </tr>
</table>

### Warehouse

The setup uses a single X-SMALL warehouse named `ITRON_WH`. It is created automatically by the first SQL file. If you prefer a different size or name, modify `sql/setup/01_database_and_schema.sql` before execution.

<table>
  <tr>
    <th>Setting</th>
    <th>Value</th>
  </tr>
  <tr>
    <td>Warehouse Name</td>
    <td><code>ITRON_WH</code></td>
  </tr>
  <tr>
    <td>Size</td>
    <td>X-SMALL</td>
  </tr>
  <tr>
    <td>Auto Suspend</td>
    <td>300 seconds (5 minutes)</td>
  </tr>
  <tr>
    <td>Auto Resume</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>Initially Suspended</td>
    <td>TRUE</td>
  </tr>
</table>

---

## 2. Execution Order

Execute each SQL file in the order below. Do not skip files or change the sequence, as later files depend on objects created by earlier ones.

<table>
  <tr>
    <th>Step</th>
    <th>File</th>
    <th>Description</th>
    <th>Objects Created</th>
  </tr>
  <tr>
    <td>1</td>
    <td><code>sql/setup/01_database_and_schema.sql</code></td>
    <td>Creates the <code>ITRON_DB</code> database, three schemas (<code>RAW</code>, <code>ANALYTICS</code>, <code>ONTOLOGY</code>), and the <code>ITRON_WH</code> warehouse.</td>
    <td>1 database, 3 schemas, 1 warehouse</td>
  </tr>
  <tr>
    <td>2</td>
    <td><code>sql/setup/02_create_tables.sql</code></td>
    <td>Creates all tables across all three schemas: operational tables in <code>RAW</code>, ESG/analytics tables in <code>ANALYTICS</code>, and ontology reference tables in <code>ONTOLOGY</code>.</td>
    <td>7 RAW tables, 8 ANALYTICS tables, 6 ONTOLOGY tables</td>
  </tr>
  <tr>
    <td>3</td>
    <td><code>sql/setup/03_ESGOnt_Ontology.sql</code></td>
    <td>Loads the ESGOnt OWL ontology into relational tables. Populates classes, properties, relationships, SDG mappings, validation rules, metric definitions, and creates the <code>VALIDATE_ESG_METRIC</code> function.</td>
    <td>Ontology data (200+ rows), 1 UDF</td>
  </tr>
  <tr>
    <td>4</td>
    <td><code>sql/data/04_generate_synthetic_data.sql</code></td>
    <td>Generates realistic demo data: 500 meters, 55,000 readings, 100,000 sensor events, 300 grid assets, 5,000 work orders, 250 outage events, 500 customers, ESG metrics (2022-2025), carbon emissions, water conservation, energy efficiency, and 10 ESG documents.</td>
    <td>~165,000+ data rows</td>
  </tr>
  <tr>
    <td>5</td>
    <td><code>sql/views/05_create_views.sql</code></td>
    <td>Creates analytical views for reporting: daily consumption, asset health scores, ESG quarterly summary, carbon intensity, water loss analysis, grid reliability, SDG alignment scorecard, and ontology metric catalog.</td>
    <td>8 analytical views</td>
  </tr>
  <tr>
    <td>6</td>
    <td><code>sql/views/06_create_semantic_views.sql</code></td>
    <td>Creates two semantic views for Cortex Analyst: <code>ITRON_OPERATIONS_SV</code> (meters, assets, outages) and <code>ITRON_ESG_SV</code> (environmental, social, governance metrics).</td>
    <td>2 semantic views</td>
  </tr>
  <tr>
    <td>7</td>
    <td><code>sql/search/07_create_cortex_search.sql</code></td>
    <td>Creates the Cortex Search service over the ESG documents table. Enables natural language retrieval of sustainability reports, policies, and frameworks.</td>
    <td>1 Cortex Search service</td>
  </tr>
  <tr>
    <td>8</td>
    <td><code>sql/models/09_ml_model_functions.sql</code></td>
    <td>Creates 5 ML prediction UDFs: energy demand forecasting, water leak detection, anomaly detection, equipment failure prediction, and carbon emissions forecasting.</td>
    <td>5 UDFs</td>
  </tr>
  <tr>
    <td>9</td>
    <td><code>sql/agent/10_create_agent.sql</code></td>
    <td>Grants permissions and creates the Cortex Agent (<code>ITRON_AGENT</code>) with all tools: 2 Cortex Analyst tools, 1 Cortex Search tool, 5 generic function tools, and 1 data-to-chart visualization tool.</td>
    <td>1 Agent, permission grants</td>
  </tr>
</table>

---

## 3. Step-by-Step Execution with Verification

### Step 1: Database and Schema Setup

Run the file in a Snowflake worksheet or via SnowSQL:

```sql
-- Execute: sql/setup/01_database_and_schema.sql
```

**Verification:**

```sql
-- Confirm database exists
SHOW DATABASES LIKE 'ITRON_DB';

-- Confirm all three schemas
SHOW SCHEMAS IN DATABASE ITRON_DB;

-- Confirm warehouse
SHOW WAREHOUSES LIKE 'ITRON_WH';
```

**Expected result:** 1 database, 3 schemas (`RAW`, `ANALYTICS`, `ONTOLOGY` plus default `PUBLIC` and `INFORMATION_SCHEMA`), 1 warehouse.

---

### Step 2: Create Tables

```sql
-- Execute: sql/setup/02_create_tables.sql
```

**Verification:**

```sql
-- Count tables per schema
SELECT TABLE_SCHEMA, COUNT(*) AS TABLE_COUNT
FROM ITRON_DB.INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
GROUP BY TABLE_SCHEMA
ORDER BY TABLE_SCHEMA;
```

**Expected result:**

<table>
  <tr>
    <th>TABLE_SCHEMA</th>
    <th>TABLE_COUNT</th>
  </tr>
  <tr>
    <td>ANALYTICS</td>
    <td>8</td>
  </tr>
  <tr>
    <td>ONTOLOGY</td>
    <td>6</td>
  </tr>
  <tr>
    <td>RAW</td>
    <td>7</td>
  </tr>
</table>

```sql
-- Verify a specific table structure
DESCRIBE TABLE ITRON_DB.RAW.METERS;
DESCRIBE TABLE ITRON_DB.ANALYTICS.ESG_ENVIRONMENTAL_METRICS;
DESCRIBE TABLE ITRON_DB.ONTOLOGY.ONTOLOGY_CLASSES;
```

---

### Step 3: Load ESGOnt Ontology

```sql
-- Execute: sql/setup/03_ESGOnt_Ontology.sql
```

**Verification:**

```sql
-- Confirm ontology classes loaded
SELECT COUNT(*) AS CLASS_COUNT FROM ITRON_DB.ONTOLOGY.ONTOLOGY_CLASSES;
-- Expected: 37

-- Confirm SDG mappings
SELECT COUNT(*) AS MAPPING_COUNT FROM ITRON_DB.ONTOLOGY.ONTOLOGY_SDG_MAPPINGS;
-- Expected: 29

-- Confirm validation rules
SELECT COUNT(*) AS RULE_COUNT FROM ITRON_DB.ONTOLOGY.ONTOLOGY_VALIDATION_RULES;
-- Expected: 18

-- Confirm metric definitions
SELECT COUNT(*) AS DEF_COUNT FROM ITRON_DB.ONTOLOGY.ONTOLOGY_METRIC_DEFINITIONS;
-- Expected: 20

-- Test the validation function
SELECT ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC('Scope 1 GHG Emissions');
```

**Expected function result:** A JSON object containing `is_valid: true`, `esg_pillar: ENVIRONMENTAL`, `esg_category: EMISSIONS`, and associated SDG goals and validation rules.

---

### Step 4: Generate Synthetic Data

```sql
-- Execute: sql/data/04_generate_synthetic_data.sql
```

**Verification:**

```sql
-- Check row counts for key tables
SELECT 'METERS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM ITRON_DB.RAW.METERS
UNION ALL
SELECT 'METER_READINGS', COUNT(*) FROM ITRON_DB.RAW.METER_READINGS
UNION ALL
SELECT 'SENSOR_EVENTS', COUNT(*) FROM ITRON_DB.RAW.SENSOR_EVENTS
UNION ALL
SELECT 'GRID_ASSETS', COUNT(*) FROM ITRON_DB.RAW.GRID_ASSETS
UNION ALL
SELECT 'WORK_ORDERS', COUNT(*) FROM ITRON_DB.RAW.WORK_ORDERS
UNION ALL
SELECT 'OUTAGE_EVENTS', COUNT(*) FROM ITRON_DB.RAW.OUTAGE_EVENTS
UNION ALL
SELECT 'CUSTOMERS', COUNT(*) FROM ITRON_DB.RAW.CUSTOMERS
UNION ALL
SELECT 'ESG_ENVIRONMENTAL_METRICS', COUNT(*) FROM ITRON_DB.ANALYTICS.ESG_ENVIRONMENTAL_METRICS
UNION ALL
SELECT 'ESG_DOCUMENTS', COUNT(*) FROM ITRON_DB.ANALYTICS.ESG_DOCUMENTS
ORDER BY TABLE_NAME;
```

**Expected approximate row counts:**

<table>
  <tr>
    <th>Table</th>
    <th>Expected Rows</th>
  </tr>
  <tr>
    <td>METERS</td>
    <td>500</td>
  </tr>
  <tr>
    <td>METER_READINGS</td>
    <td>~55,000</td>
  </tr>
  <tr>
    <td>SENSOR_EVENTS</td>
    <td>100,000</td>
  </tr>
  <tr>
    <td>GRID_ASSETS</td>
    <td>300</td>
  </tr>
  <tr>
    <td>WORK_ORDERS</td>
    <td>5,000</td>
  </tr>
  <tr>
    <td>OUTAGE_EVENTS</td>
    <td>250</td>
  </tr>
  <tr>
    <td>CUSTOMERS</td>
    <td>500</td>
  </tr>
  <tr>
    <td>ESG_ENVIRONMENTAL_METRICS</td>
    <td>~126</td>
  </tr>
  <tr>
    <td>ESG_DOCUMENTS</td>
    <td>10</td>
  </tr>
</table>

---

### Step 5: Create Analytical Views

```sql
-- Execute: sql/views/05_create_views.sql
```

**Verification:**

```sql
-- List all views
SHOW VIEWS IN SCHEMA ITRON_DB.ANALYTICS;

-- Test a view returns data
SELECT * FROM ITRON_DB.ANALYTICS.V_ESG_QUARTERLY_SUMMARY
WHERE REPORTING_YEAR = 2024 AND REPORTING_QUARTER = 4
LIMIT 10;

-- Test asset health view
SELECT HEALTH_CATEGORY, COUNT(*) AS ASSET_COUNT
FROM ITRON_DB.ANALYTICS.V_ASSET_HEALTH_SCORES
GROUP BY HEALTH_CATEGORY;
```

**Expected result:** 8 views created. `V_ESG_QUARTERLY_SUMMARY` returns rows with `ESG_PILLAR`, `METRIC_CATEGORY`, `METRIC_NAME`, `METRIC_VALUE`, and `PROGRESS_STATUS` columns.

---

### Step 6: Create Semantic Views

```sql
-- Execute: sql/views/06_create_semantic_views.sql
```

**Verification:**

```sql
-- Confirm semantic views exist
SHOW SEMANTIC VIEWS IN SCHEMA ITRON_DB.ANALYTICS;

-- Describe the operations semantic view
DESCRIBE SEMANTIC VIEW ITRON_DB.ANALYTICS.ITRON_OPERATIONS_SV;

-- Describe the ESG semantic view
DESCRIBE SEMANTIC VIEW ITRON_DB.ANALYTICS.ITRON_ESG_SV;
```

**Expected result:** 2 semantic views (`ITRON_OPERATIONS_SV` and `ITRON_ESG_SV`). Each should show tables, relationships, facts, dimensions, and metrics.

---

### Step 7: Create Cortex Search Service

```sql
-- Execute: sql/search/07_create_cortex_search.sql
```

**Verification:**

```sql
-- Confirm search service exists
SHOW CORTEX SEARCH SERVICES IN SCHEMA ITRON_DB.ANALYTICS;

-- Wait ~60 seconds for initial indexing, then test
-- (The service needs time to build its index)
```

**Expected result:** 1 Cortex Search service named `ESG_SEARCH_SERVICE` with status `ACTIVE`.

> **Note:** The search service requires up to a few minutes for the initial index build. Wait for the status to show `ACTIVE` before proceeding with agent testing.

---

### Step 8: Create ML Model Functions

```sql
-- Execute: sql/models/09_ml_model_functions.sql
```

**Verification:**

```sql
-- List functions in ANALYTICS schema
SHOW USER FUNCTIONS IN SCHEMA ITRON_DB.ANALYTICS;

-- Test demand prediction
SELECT ITRON_DB.ANALYTICS.AGENT_PREDICT_DEMAND(NULL, 'NORTHWEST', 3);

-- Test leak detection
SELECT ITRON_DB.ANALYTICS.AGENT_DETECT_LEAKS(NULL, 2.0);

-- Test anomaly detection
SELECT ITRON_DB.ANALYTICS.AGENT_DETECT_ANOMALIES('ELECTRIC', NULL, 7);

-- Test failure prediction
SELECT ITRON_DB.ANALYTICS.AGENT_PREDICT_FAILURE('TRANSFORMER', NULL, 0.3);

-- Test emissions forecast
SELECT ITRON_DB.ANALYTICS.AGENT_FORECAST_EMISSIONS('SCOPE_1', 4);
```

**Expected result:** Each function returns a JSON array of objects. `AGENT_PREDICT_DEMAND` returns forecast objects with `forecast_date`, `predicted_kwh`, and confidence bounds. Results may vary based on the random synthetic data.

---

### Step 9: Create the Agent

```sql
-- Execute: sql/agent/10_create_agent.sql
```

**Verification:**

```sql
-- Confirm agent exists
SHOW AGENTS IN SCHEMA ITRON_DB.ANALYTICS;

-- Describe the agent
DESCRIBE AGENT ITRON_DB.ANALYTICS.ITRON_AGENT;
```

**Expected result:** 1 agent named `ITRON_AGENT` with `display_name` of "Itron Intelligence Assistant". The DESCRIBE output should show all configured tools and tool resources.

---

## 4. Agent Testing Instructions

After all files have been executed successfully, test the agent using the Snowflake UI (Snowsight) or via SQL.

### Testing via SQL

```sql
-- Basic test: Ask the agent a question
SELECT SNOWFLAKE.CORTEX.INVOKE_AGENT(
    'ITRON_DB.ANALYTICS.ITRON_AGENT',
    'How many meters do we have by type and region?'
);
```

### Sample Questions by Category

<table>
  <tr>
    <th>Category</th>
    <th>Tool Used</th>
    <th>Sample Question</th>
  </tr>
  <tr>
    <td>Operations</td>
    <td>ItronOperationsAnalyst</td>
    <td>"How many meters do we have by type and region?"</td>
  </tr>
  <tr>
    <td>Operations</td>
    <td>ItronOperationsAnalyst</td>
    <td>"What is the average outage duration by cause?"</td>
  </tr>
  <tr>
    <td>Operations</td>
    <td>ItronOperationsAnalyst</td>
    <td>"Show me open high-priority work orders."</td>
  </tr>
  <tr>
    <td>Operations</td>
    <td>ItronOperationsAnalyst</td>
    <td>"What percentage of our meters are DI-enabled?"</td>
  </tr>
  <tr>
    <td>ESG</td>
    <td>ItronESGAnalyst</td>
    <td>"What were our Scope 1 and Scope 2 emissions in 2024?"</td>
  </tr>
  <tr>
    <td>ESG</td>
    <td>ItronESGAnalyst</td>
    <td>"Show the trend in non-revenue water percentage by region."</td>
  </tr>
  <tr>
    <td>ESG</td>
    <td>ItronESGAnalyst</td>
    <td>"What is our board gender diversity percentage?"</td>
  </tr>
  <tr>
    <td>ESG + Ontology</td>
    <td>ItronESGAnalyst + OntologyValidator</td>
    <td>"How does our carbon intensity align with SDG 13 targets?"</td>
  </tr>
  <tr>
    <td>Document Search</td>
    <td>ESGSearch</td>
    <td>"What is Itron's climate transition plan?"</td>
  </tr>
  <tr>
    <td>Document Search</td>
    <td>ESGSearch</td>
    <td>"Tell me about our DEI strategy and workforce goals."</td>
  </tr>
  <tr>
    <td>Prediction</td>
    <td>PredictDemand</td>
    <td>"Predict energy demand for the Northwest region over the next 14 days."</td>
  </tr>
  <tr>
    <td>Prediction</td>
    <td>DetectAnomalies</td>
    <td>"Which water meters are showing anomalous consumption patterns?"</td>
  </tr>
  <tr>
    <td>Prediction</td>
    <td>PredictEquipmentFailure</td>
    <td>"Which transformers have the highest failure probability?"</td>
  </tr>
  <tr>
    <td>Prediction</td>
    <td>ForecastEmissions</td>
    <td>"Forecast our Scope 1 emissions for the next year."</td>
  </tr>
  <tr>
    <td>Multi-tool</td>
    <td>Multiple</td>
    <td>"What was our total GHG emissions reduction compared to our 2019 baseline, and are we on track for our 2035 target?"</td>
  </tr>
</table>

### Testing via Snowsight UI

1. Navigate to **Snowflake Intelligence** in the left sidebar.
2. Select the **Itron Intelligence Assistant** agent.
3. Type any of the sample questions above in the chat interface.
4. Verify that:
   - The agent selects the correct tool(s) for the question.
   - SQL queries generated by Cortex Analyst return valid data.
   - Ontology validation is invoked for ESG classification questions.
   - Predictions return structured JSON with confidence intervals.

---

## 5. Troubleshooting Common Issues

<table>
  <tr>
    <th>Issue</th>
    <th>Symptom</th>
    <th>Resolution</th>
  </tr>
  <tr>
    <td>Agent creation fails</td>
    <td><code>SQL compilation error: Agent feature not enabled</code></td>
    <td>Ensure Cortex Agent is enabled for your account. Contact Snowflake support to request access.</td>
  </tr>
  <tr>
    <td>Semantic view creation fails</td>
    <td><code>Semantic views are not supported</code></td>
    <td>Verify Cortex Analyst is enabled. Check your account region supports the feature.</td>
  </tr>
  <tr>
    <td>Cortex Search not indexing</td>
    <td>Search service shows status <code>PROVISIONING</code> for more than 10 minutes</td>
    <td>Ensure <code>ITRON_WH</code> is running (not suspended). Try <code>ALTER WAREHOUSE ITRON_WH RESUME;</code> and wait.</td>
  </tr>
  <tr>
    <td>Function returns NULL</td>
    <td><code>AGENT_PREDICT_DEMAND</code> or other UDFs return empty arrays</td>
    <td>Ensure Step 4 (synthetic data) was executed. Verify data exists: <code>SELECT COUNT(*) FROM ITRON_DB.RAW.METER_READINGS;</code></td>
  </tr>
  <tr>
    <td>Permission denied</td>
    <td><code>Insufficient privileges to operate on...</code></td>
    <td>Run Step 9 grants with a role that has OWNERSHIP on <code>ITRON_DB</code>. Alternatively, grant to a specific role instead of <code>PUBLIC</code>.</td>
  </tr>
  <tr>
    <td>Agent does not use ontology</td>
    <td>ESG metric responses lack SDG alignment or pillar classification</td>
    <td>Verify the <code>OntologyValidator</code> tool resource points to <code>ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC</code>. Test the function directly: <code>SELECT ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC('Scope 1 GHG Emissions');</code></td>
  </tr>
  <tr>
    <td>Warehouse suspended errors</td>
    <td><code>Warehouse ITRON_WH is suspended</code></td>
    <td>The warehouse auto-resumes, but there can be a brief delay. Retry the query or run <code>ALTER WAREHOUSE ITRON_WH RESUME;</code></td>
  </tr>
  <tr>
    <td>Data is stale or empty</td>
    <td>Agent says "no data found" for recent periods</td>
    <td>Synthetic data is generated relative to <code>CURRENT_DATE()</code>. If deployed long ago, re-run Step 4 to regenerate fresh data.</td>
  </tr>
  <tr>
    <td>Semantic view query errors</td>
    <td>Agent returns SQL errors from Cortex Analyst</td>
    <td>Run <code>DESCRIBE SEMANTIC VIEW ITRON_DB.ANALYTICS.ITRON_OPERATIONS_SV;</code> and verify all referenced tables exist and have data.</td>
  </tr>
  <tr>
    <td>Agent returns wrong tool</td>
    <td>Operations question routed to ESG tool or vice versa</td>
    <td>Rephrase the question with clearer keywords. The agent uses the <code>orchestration</code> instructions to route. Operations keywords: meters, consumption, outage, asset, work order. ESG keywords: emissions, carbon, SDG, sustainability, workforce, governance.</td>
  </tr>
</table>

### Full Reset

If you need to start over completely:

```sql
-- Drop and recreate everything
DROP DATABASE IF EXISTS ITRON_DB;

-- Then re-execute all files from Step 1
```

### Upgrading the Agent

To modify the agent configuration without dropping data:

```sql
-- Only re-run the agent creation file
-- The CREATE OR REPLACE AGENT statement is idempotent
-- Execute: sql/agent/10_create_agent.sql
```

### Checking Agent Tool Configuration

```sql
-- Verify all tool resources are correctly configured
DESCRIBE AGENT ITRON_DB.ANALYTICS.ITRON_AGENT;

-- Test individual tool functions independently
SELECT ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC('Total Energy Consumption');
SELECT ITRON_DB.ANALYTICS.AGENT_PREDICT_DEMAND(NULL, NULL, 3);
SELECT ITRON_DB.ANALYTICS.AGENT_DETECT_ANOMALIES(NULL, NULL, 7);
SELECT ITRON_DB.ANALYTICS.AGENT_PREDICT_FAILURE(NULL, NULL, 0.3);
SELECT ITRON_DB.ANALYTICS.AGENT_FORECAST_EMISSIONS(NULL, 4);
```

---

## Architecture Summary

<table>
  <tr>
    <th>Component</th>
    <th>Object Name</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>Database</td>
    <td><code>ITRON_DB</code></td>
    <td>Central database for all agent data</td>
  </tr>
  <tr>
    <td>Warehouse</td>
    <td><code>ITRON_WH</code></td>
    <td>Compute for queries, functions, and search</td>
  </tr>
  <tr>
    <td>Agent</td>
    <td><code>ITRON_DB.ANALYTICS.ITRON_AGENT</code></td>
    <td>Cortex Agent with natural language interface</td>
  </tr>
  <tr>
    <td>Operations Semantic View</td>
    <td><code>ITRON_DB.ANALYTICS.ITRON_OPERATIONS_SV</code></td>
    <td>Text-to-SQL for meters, assets, outages</td>
  </tr>
  <tr>
    <td>ESG Semantic View</td>
    <td><code>ITRON_DB.ANALYTICS.ITRON_ESG_SV</code></td>
    <td>Text-to-SQL for ESG metrics and SDG tracking</td>
  </tr>
  <tr>
    <td>Search Service</td>
    <td><code>ITRON_DB.ANALYTICS.ESG_SEARCH_SERVICE</code></td>
    <td>Document retrieval for policies and reports</td>
  </tr>
  <tr>
    <td>Ontology Validator</td>
    <td><code>ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC</code></td>
    <td>Deterministic ESG classification and SDG alignment</td>
  </tr>
  <tr>
    <td>Demand Forecast</td>
    <td><code>ITRON_DB.ANALYTICS.AGENT_PREDICT_DEMAND</code></td>
    <td>Energy demand prediction with confidence intervals</td>
  </tr>
  <tr>
    <td>Anomaly Detection</td>
    <td><code>ITRON_DB.ANALYTICS.AGENT_DETECT_ANOMALIES</code></td>
    <td>Multi-type meter anomaly identification</td>
  </tr>
  <tr>
    <td>Failure Prediction</td>
    <td><code>ITRON_DB.ANALYTICS.AGENT_PREDICT_FAILURE</code></td>
    <td>Equipment failure probability scoring</td>
  </tr>
  <tr>
    <td>Emissions Forecast</td>
    <td><code>ITRON_DB.ANALYTICS.AGENT_FORECAST_EMISSIONS</code></td>
    <td>Carbon emissions projection vs SBTi targets</td>
  </tr>
</table>

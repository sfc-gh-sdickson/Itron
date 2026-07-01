-- ============================================================================
-- ITRON INTELLIGENCE AGENT - Semantic Views for Cortex Analyst
-- File: sql/views/06_create_semantic_views.sql
-- Description: Creates semantic views that power the Cortex Analyst text-to-SQL
-- ============================================================================

USE DATABASE ITRON_DB;
USE WAREHOUSE ITRON_WH;
USE SCHEMA ITRON_DB.ANALYTICS;

-- ============================================================================
-- SEMANTIC VIEW 1: Operations (Meters, Assets, Grid, Outages)
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW ITRON_DB.ANALYTICS.ITRON_OPERATIONS_SV

  TABLES (
    meters AS ITRON_DB.RAW.METERS
      PRIMARY KEY (METER_ID)
      WITH SYNONYMS ('endpoints', 'smart meters', 'devices')
      COMMENT = 'Registry of all smart meter endpoints including electric, water, and gas meters',

    meter_readings AS ITRON_DB.RAW.METER_READINGS
      PRIMARY KEY (READING_ID)
      WITH SYNONYMS ('consumption data', 'interval data', 'usage readings')
      COMMENT = 'Interval meter readings with consumption values, quality flags, and sensor data',

    grid_assets AS ITRON_DB.RAW.GRID_ASSETS
      PRIMARY KEY (ASSET_ID)
      WITH SYNONYMS ('infrastructure', 'equipment', 'grid equipment')
      COMMENT = 'Grid and water infrastructure assets including transformers, pipes, and substations',

    work_orders AS ITRON_DB.RAW.WORK_ORDERS
      PRIMARY KEY (WORK_ORDER_ID)
      WITH SYNONYMS ('maintenance', 'service orders', 'repairs')
      COMMENT = 'Field service work orders for maintenance, repairs, and inspections',

    outage_events AS ITRON_DB.RAW.OUTAGE_EVENTS
      PRIMARY KEY (OUTAGE_ID)
      WITH SYNONYMS ('outages', 'service interruptions', 'disruptions')
      COMMENT = 'Grid and water service outage events with duration and customer impact',

    customers AS ITRON_DB.RAW.CUSTOMERS
      PRIMARY KEY (CUSTOMER_ID)
      WITH SYNONYMS ('accounts', 'subscribers', 'utility customers')
      COMMENT = 'Utility customer accounts with service type and DER enrollment status'
  )

  RELATIONSHIPS (
    readings_to_meters AS
      meter_readings (METER_ID) REFERENCES meters,
    work_orders_to_assets AS
      work_orders (ASSET_ID) REFERENCES grid_assets,
    work_orders_to_meters AS
      work_orders (METER_ID) REFERENCES meters,
    meters_to_customers AS
      meters (CUSTOMER_ID) REFERENCES customers
  )

  FACTS (
    meter_readings.reading_value AS READING_VALUE,
    meter_readings.demand_kw AS DEMAND_KW,
    meter_readings.voltage AS VOLTAGE,
    meter_readings.flow_rate AS FLOW_RATE,
    meter_readings.pressure_psi AS PRESSURE_PSI,
    work_orders.actual_cost AS ACTUAL_COST,
    work_orders.cost_estimate AS COST_ESTIMATE,
    outage_events.duration_minutes AS DURATION_MINUTES,
    outage_events.customers_affected AS CUSTOMERS_AFFECTED,
    grid_assets.condition_score AS CONDITION_SCORE,
    grid_assets.capacity_rating AS CAPACITY_RATING
  )

  DIMENSIONS (
    meters.meter_type AS METER_TYPE
      WITH SYNONYMS = ('utility type', 'service type')
      COMMENT = 'Type of meter: ELECTRIC, WATER, or GAS'
      SAMPLE_VALUES ('ELECTRIC', 'WATER', 'GAS')
      IS_ENUM,
    meters.region AS meters.REGION
      WITH SYNONYMS = ('area', 'territory')
      COMMENT = 'Geographic region'
      SAMPLE_VALUES ('NORTHWEST', 'SOUTHWEST', 'MIDWEST', 'NORTHEAST', 'SOUTHEAST')
      IS_ENUM,
    meters.district AS meters.DISTRICT
      COMMENT = 'Operating district within a region',
    meters.status AS meters.STATUS
      COMMENT = 'Meter operational status'
      SAMPLE_VALUES ('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DECOMMISSIONED')
      IS_ENUM,
    meters.communication_type AS COMMUNICATION_TYPE
      WITH SYNONYMS = ('network type', 'connectivity')
      COMMENT = 'Communication network type'
      SAMPLE_VALUES ('GEN6_MESH', 'GEN5_MESH', 'CELLULAR', 'RF')
      IS_ENUM,
    meters.di_enabled AS DI_ENABLED
      COMMENT = 'Whether Distributed Intelligence is enabled on this meter',
    meter_readings.reading_date AS DATE(READING_TIMESTAMP)
      WITH SYNONYMS = ('date', 'reading date', 'measurement date')
      COMMENT = 'Date of the meter reading',
    meter_readings.reading_unit AS READING_UNIT
      COMMENT = 'Unit of measurement for the reading'
      SAMPLE_VALUES ('KWH', 'GALLONS', 'THERMS', 'CUBIC_FEET')
      IS_ENUM,
    meter_readings.quality_flag AS QUALITY_FLAG
      COMMENT = 'Data quality indicator'
      SAMPLE_VALUES ('VALID', 'ESTIMATED', 'SUSPECT', 'MISSING')
      IS_ENUM,
    grid_assets.asset_type AS ASSET_TYPE
      WITH SYNONYMS = ('equipment type', 'infrastructure type')
      COMMENT = 'Type of grid or water infrastructure asset'
      SAMPLE_VALUES ('TRANSFORMER', 'SUBSTATION', 'PIPE_SEGMENT', 'VALVE', 'PUMP_STATION', 'REGULATOR')
      IS_ENUM,
    grid_assets.asset_status AS grid_assets.STATUS
      COMMENT = 'Current operational status of the asset'
      SAMPLE_VALUES ('OPERATIONAL', 'DEGRADED', 'FAILED', 'MAINTENANCE')
      IS_ENUM,
    work_orders.order_type AS ORDER_TYPE
      WITH SYNONYMS = ('work type', 'service type')
      COMMENT = 'Type of work order'
      SAMPLE_VALUES ('PREVENTIVE', 'CORRECTIVE', 'EMERGENCY', 'INSPECTION', 'INSTALL', 'DECOMMISSION')
      IS_ENUM,
    work_orders.priority AS work_orders.PRIORITY
      COMMENT = 'Work order priority level'
      SAMPLE_VALUES ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW')
      IS_ENUM,
    work_orders.wo_status AS work_orders.STATUS
      COMMENT = 'Work order completion status'
      SAMPLE_VALUES ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')
      IS_ENUM,
    outage_events.outage_type AS OUTAGE_TYPE
      COMMENT = 'Type of utility outage'
      SAMPLE_VALUES ('ELECTRIC', 'WATER', 'GAS')
      IS_ENUM,
    outage_events.cause AS outage_events.CAUSE
      WITH SYNONYMS = ('outage cause', 'reason')
      COMMENT = 'Root cause of the outage'
      SAMPLE_VALUES ('WEATHER', 'EQUIPMENT_FAILURE', 'PLANNED', 'VEHICLE', 'ANIMAL', 'UNKNOWN')
      IS_ENUM,
    customers.customer_type AS CUSTOMER_TYPE
      COMMENT = 'Customer segment classification'
      SAMPLE_VALUES ('RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'MUNICIPAL')
      IS_ENUM,
    customers.has_solar AS HAS_SOLAR
      COMMENT = 'Whether customer has rooftop solar installed',
    customers.demand_response_enrolled AS DEMAND_RESPONSE_ENROLLED
      COMMENT = 'Whether customer is enrolled in demand response programs'
  )

  METRICS (
    meter_readings.total_consumption AS SUM(meter_readings.reading_value)
      WITH SYNONYMS = ('total usage', 'total demand', 'aggregate consumption')
      COMMENT = 'Total consumption across all readings',
    meter_readings.avg_consumption AS AVG(meter_readings.reading_value)
      WITH SYNONYMS = ('average usage', 'mean consumption')
      COMMENT = 'Average consumption per reading interval',
    meter_readings.peak_demand AS MAX(meter_readings.demand_kw)
      WITH SYNONYMS = ('max demand', 'peak load')
      COMMENT = 'Maximum demand in kilowatts',
    meter_readings.reading_count AS COUNT(meter_readings.reading_value)
      COMMENT = 'Number of meter readings',
    meters.meter_count AS COUNT(meters.METER_ID)
      WITH SYNONYMS = ('number of meters', 'endpoint count', 'device count')
      COMMENT = 'Count of meters',
    meters.di_meter_count AS COUNT(CASE WHEN meters.DI_ENABLED = TRUE THEN meters.METER_ID END)
      COMMENT = 'Count of Distributed Intelligence enabled meters',
    grid_assets.asset_count AS COUNT(grid_assets.ASSET_ID)
      COMMENT = 'Count of grid/water assets',
    grid_assets.avg_condition_score AS AVG(grid_assets.condition_score)
      COMMENT = 'Average asset condition score (0-100)',
    work_orders.work_order_count AS COUNT(work_orders.WORK_ORDER_ID)
      WITH SYNONYMS = ('number of work orders', 'maintenance count')
      COMMENT = 'Count of work orders',
    work_orders.total_maintenance_cost AS SUM(work_orders.actual_cost)
      WITH SYNONYMS = ('repair cost', 'maintenance spend')
      COMMENT = 'Total actual maintenance cost in USD',
    work_orders.avg_repair_cost AS AVG(work_orders.actual_cost)
      COMMENT = 'Average cost per work order',
    outage_events.outage_count AS COUNT(outage_events.OUTAGE_ID)
      WITH SYNONYMS = ('number of outages', 'interruption count')
      COMMENT = 'Total number of outage events',
    outage_events.total_customers_affected AS SUM(outage_events.customers_affected)
      COMMENT = 'Total number of customers impacted by outages',
    outage_events.avg_outage_duration AS AVG(outage_events.duration_minutes)
      WITH SYNONYMS = ('mean time to restore', 'MTTR', 'average restoration time')
      COMMENT = 'Average outage duration in minutes',
    outage_events.total_customer_minutes AS SUM(outage_events.duration_minutes * outage_events.customers_affected)
      WITH SYNONYMS = ('SAIDI', 'customer minutes interrupted', 'CMI')
      COMMENT = 'Total customer-minutes of interruption (SAIDI proxy)',
    customers.customer_count AS COUNT(customers.CUSTOMER_ID)
      COMMENT = 'Total number of utility customers',
    customers.solar_customer_count AS COUNT(CASE WHEN customers.HAS_SOLAR = TRUE THEN customers.CUSTOMER_ID END)
      COMMENT = 'Number of customers with solar installations',
    customers.dr_enrolled_count AS COUNT(CASE WHEN customers.DEMAND_RESPONSE_ENROLLED = TRUE THEN customers.CUSTOMER_ID END)
      COMMENT = 'Number of customers enrolled in demand response'
  )

  AI_SQL_GENERATION 'When querying consumption data, always include the READING_UNIT dimension to clarify whether values are in KWH, GALLONS, or THERMS. For reliability metrics, calculate SAIDI as total_customer_minutes divided by total customers served. DI-enabled meters are those with Distributed Intelligence capability for edge computing. Itron Gen6 is the latest mesh network platform.'

  AI_QUESTION_CATEGORIZATION 'This semantic view handles operational questions about meters, consumption, grid assets, maintenance, and outages. If a question is about ESG metrics, sustainability, emissions, or SDG alignment, inform the user that those questions should be directed to the ESG semantic view. If a question asks about predictions or forecasts, suggest using the ML prediction tools.'

  COMMENT = 'Itron operations semantic view covering smart meters, consumption data, grid assets, maintenance, and outage events';


-- ============================================================================
-- SEMANTIC VIEW 2: ESG Performance (Environmental, Social, Governance)
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW ITRON_DB.ANALYTICS.ITRON_ESG_SV

  TABLES (
    env_metrics AS ITRON_DB.ANALYTICS.ESG_ENVIRONMENTAL_METRICS
      PRIMARY KEY (METRIC_ID)
      WITH SYNONYMS ('environmental data', 'green metrics', 'sustainability metrics')
      COMMENT = 'Environmental ESG metrics including emissions, energy, water, and waste',

    social_metrics AS ITRON_DB.ANALYTICS.ESG_SOCIAL_METRICS
      PRIMARY KEY (METRIC_ID)
      WITH SYNONYMS ('social data', 'people metrics', 'workforce metrics')
      COMMENT = 'Social ESG metrics including workforce, safety, community, and supply chain',

    gov_metrics AS ITRON_DB.ANALYTICS.ESG_GOVERNANCE_METRICS
      PRIMARY KEY (METRIC_ID)
      WITH SYNONYMS ('governance data', 'compliance metrics', 'board metrics')
      COMMENT = 'Governance ESG metrics including board diversity, compliance, and ethics',

    sdg_progress AS ITRON_DB.ANALYTICS.SDG_PROGRESS
      PRIMARY KEY (PROGRESS_ID)
      WITH SYNONYMS ('SDG data', 'sustainable development goals', 'UN goals')
      COMMENT = 'Progress tracking against UN Sustainable Development Goals',

    carbon_emissions AS ITRON_DB.ANALYTICS.CARBON_EMISSIONS
      PRIMARY KEY (EMISSION_ID)
      WITH SYNONYMS ('carbon data', 'GHG data', 'greenhouse gas')
      COMMENT = 'Detailed monthly carbon emissions by scope, source, and facility',

    water_conservation AS ITRON_DB.ANALYTICS.WATER_CONSERVATION
      PRIMARY KEY (RECORD_ID)
      WITH SYNONYMS ('water savings', 'leak detection results', 'NRW data')
      COMMENT = 'Water conservation metrics including leak detection and NRW reduction',

    energy_efficiency AS ITRON_DB.ANALYTICS.ENERGY_EFFICIENCY
      PRIMARY KEY (RECORD_ID)
      WITH SYNONYMS ('efficiency data', 'grid loss data', 'demand response data')
      COMMENT = 'Energy efficiency metrics including grid loss, DER management, and demand response'
  )

  RELATIONSHIPS (
  )

  FACTS (
    env_metrics.env_value AS METRIC_VALUE,
    env_metrics.env_baseline AS BASELINE_VALUE,
    env_metrics.env_target AS TARGET_VALUE,
    social_metrics.social_value AS METRIC_VALUE,
    social_metrics.social_benchmark AS BENCHMARK_VALUE,
    gov_metrics.gov_value AS METRIC_VALUE,
    carbon_emissions.co2e AS CO2E_METRIC_TONS,
    carbon_emissions.avoided AS CUSTOMER_AVOIDED_EMISSIONS,
    water_conservation.water_saved AS WATER_SAVED_GALLONS,
    water_conservation.leaks_found AS LEAKS_DETECTED,
    water_conservation.nrw_pct AS NRW_PERCENTAGE,
    energy_efficiency.energy_saved AS ENERGY_SAVED_MWH,
    energy_efficiency.der_capacity AS DER_CAPACITY_MW,
    energy_efficiency.dr_mw AS DEMAND_RESPONSE_MW
  )

  DIMENSIONS (
    env_metrics.env_year AS REPORTING_YEAR
      WITH SYNONYMS = ('year', 'fiscal year')
      COMMENT = 'Reporting year',
    env_metrics.env_quarter AS REPORTING_QUARTER
      WITH SYNONYMS = ('quarter', 'Q')
      COMMENT = 'Reporting quarter (1-4)',
    env_metrics.env_category AS METRIC_CATEGORY
      WITH SYNONYMS = ('category', 'ESG category', 'metric type')
      COMMENT = 'Environmental metric category'
      SAMPLE_VALUES ('EMISSIONS', 'ENERGY', 'WATER', 'WASTE', 'BIODIVERSITY')
      IS_ENUM,
    env_metrics.env_metric_name AS METRIC_NAME
      WITH SYNONYMS = ('metric', 'KPI', 'indicator')
      COMMENT = 'Name of the environmental metric',
    env_metrics.env_unit AS METRIC_UNIT
      COMMENT = 'Unit of measurement for the metric',
    env_metrics.env_scope AS SCOPE
      WITH SYNONYMS = ('emission scope', 'GHG scope')
      COMMENT = 'GHG Protocol scope classification'
      SAMPLE_VALUES ('SCOPE_1', 'SCOPE_2', 'SCOPE_3')
      IS_ENUM,
    env_metrics.env_region AS env_metrics.REGION
      COMMENT = 'Geographic region for reporting',
    social_metrics.social_year AS REPORTING_YEAR
      COMMENT = 'Reporting year for social metrics',
    social_metrics.social_quarter AS REPORTING_QUARTER
      COMMENT = 'Reporting quarter for social metrics',
    social_metrics.social_category AS METRIC_CATEGORY
      COMMENT = 'Social metric category'
      SAMPLE_VALUES ('WORKFORCE', 'HEALTH_SAFETY', 'COMMUNITY', 'SUPPLY_CHAIN', 'CUSTOMER_PRIVACY')
      IS_ENUM,
    social_metrics.social_metric_name AS METRIC_NAME
      COMMENT = 'Name of the social metric',
    social_metrics.social_unit AS METRIC_UNIT
      COMMENT = 'Unit for social metric',
    social_metrics.demographic AS DEMOGRAPHIC_GROUP
      COMMENT = 'Demographic group for diversity metrics',
    gov_metrics.gov_year AS REPORTING_YEAR
      COMMENT = 'Reporting year for governance metrics',
    gov_metrics.gov_quarter AS REPORTING_QUARTER
      COMMENT = 'Reporting quarter for governance metrics',
    gov_metrics.gov_category AS METRIC_CATEGORY
      COMMENT = 'Governance metric category'
      SAMPLE_VALUES ('BOARD_DIVERSITY', 'COMPLIANCE', 'ETHICS', 'RISK_MANAGEMENT', 'TRANSPARENCY')
      IS_ENUM,
    gov_metrics.gov_metric_name AS METRIC_NAME
      COMMENT = 'Name of the governance metric',
    gov_metrics.gov_framework AS COMPLIANCE_FRAMEWORK
      COMMENT = 'Applicable reporting framework'
      SAMPLE_VALUES ('GRI', 'ESRS', 'SASB', 'TCFD', 'CDP'),
    sdg_progress.sdg_number AS SDG_GOAL_NUMBER
      WITH SYNONYMS = ('SDG goal', 'UN goal number')
      COMMENT = 'UN SDG goal number (1-17)',
    sdg_progress.sdg_name AS SDG_GOAL_NAME
      COMMENT = 'Name of the SDG goal',
    sdg_progress.sdg_target AS SDG_TARGET
      COMMENT = 'Specific SDG target identifier',
    sdg_progress.sdg_status AS PROGRESS_STATUS
      COMMENT = 'Progress toward SDG target'
      SAMPLE_VALUES ('ON_TRACK', 'AT_RISK', 'OFF_TRACK', 'ACHIEVED')
      IS_ENUM,
    carbon_emissions.carbon_scope AS SCOPE
      COMMENT = 'GHG emission scope',
    carbon_emissions.carbon_source AS EMISSION_SOURCE
      COMMENT = 'Source of carbon emissions',
    carbon_emissions.carbon_category AS EMISSION_CATEGORY
      COMMENT = 'Emission source category'
      SAMPLE_VALUES ('STATIONARY_COMBUSTION', 'MOBILE', 'FUGITIVE', 'PURCHASED_ELECTRICITY', 'TRAVEL', 'COMMUTING', 'SUPPLY_CHAIN'),
    carbon_emissions.carbon_year AS REPORTING_YEAR
      COMMENT = 'Year of emission record',
    carbon_emissions.carbon_month AS REPORTING_MONTH
      COMMENT = 'Month of emission record',
    carbon_emissions.carbon_facility AS FACILITY
      COMMENT = 'Facility where emissions occurred',
    water_conservation.wc_year AS REPORTING_YEAR
      COMMENT = 'Year for water conservation record',
    water_conservation.wc_quarter AS REPORTING_QUARTER
      COMMENT = 'Quarter for water conservation record',
    water_conservation.wc_region AS REGION
      COMMENT = 'Region for water conservation',
    water_conservation.wc_type AS METRIC_TYPE
      COMMENT = 'Type of water conservation metric'
      SAMPLE_VALUES ('NON_REVENUE_WATER', 'LEAK_DETECTION', 'CONSUMPTION_REDUCTION', 'RECYCLING')
      IS_ENUM,
    energy_efficiency.ee_year AS REPORTING_YEAR
      COMMENT = 'Year for energy efficiency record',
    energy_efficiency.ee_quarter AS REPORTING_QUARTER
      COMMENT = 'Quarter for energy efficiency record',
    energy_efficiency.ee_region AS REGION
      COMMENT = 'Region for energy efficiency',
    energy_efficiency.ee_type AS METRIC_TYPE
      COMMENT = 'Type of energy efficiency metric'
      SAMPLE_VALUES ('GRID_LOSS', 'DEMAND_RESPONSE', 'PEAK_REDUCTION', 'DER_INTEGRATION', 'VOLTAGE_OPTIMIZATION')
      IS_ENUM
  )

  METRICS (
    env_metrics.env_metric_value AS SUM(env_metrics.env_value)
      WITH SYNONYMS = ('environmental value', 'env total')
      COMMENT = 'Sum of environmental metric values',
    env_metrics.env_avg_value AS AVG(env_metrics.env_value)
      COMMENT = 'Average environmental metric value',
    social_metrics.social_metric_value AS SUM(social_metrics.social_value)
      WITH SYNONYMS = ('social value', 'social total')
      COMMENT = 'Sum of social metric values',
    social_metrics.social_avg_value AS AVG(social_metrics.social_value)
      COMMENT = 'Average social metric value',
    gov_metrics.gov_metric_value AS SUM(gov_metrics.gov_value)
      COMMENT = 'Sum of governance metric values',
    gov_metrics.gov_avg_value AS AVG(gov_metrics.gov_value)
      COMMENT = 'Average governance metric value',
    carbon_emissions.total_co2e AS SUM(carbon_emissions.co2e)
      WITH SYNONYMS = ('total emissions', 'total carbon', 'total GHG')
      COMMENT = 'Total CO2 equivalent emissions in metric tons',
    carbon_emissions.total_avoided AS SUM(carbon_emissions.avoided)
      WITH SYNONYMS = ('avoided emissions', 'customer savings')
      COMMENT = 'Total customer avoided emissions in metric tons CO2e',
    carbon_emissions.avg_monthly_co2e AS AVG(carbon_emissions.co2e)
      COMMENT = 'Average monthly CO2e emissions',
    water_conservation.total_water_saved AS SUM(water_conservation.water_saved)
      WITH SYNONYMS = ('water savings', 'gallons saved')
      COMMENT = 'Total water saved in gallons',
    water_conservation.total_leaks AS SUM(water_conservation.leaks_found)
      WITH SYNONYMS = ('leaks found', 'leak count')
      COMMENT = 'Total number of leaks detected',
    water_conservation.avg_nrw AS AVG(water_conservation.nrw_pct)
      WITH SYNONYMS = ('non-revenue water', 'water loss rate')
      COMMENT = 'Average non-revenue water percentage',
    energy_efficiency.total_energy_saved AS SUM(energy_efficiency.energy_saved)
      WITH SYNONYMS = ('energy savings', 'MWh saved')
      COMMENT = 'Total energy saved in MWh',
    energy_efficiency.total_der AS SUM(energy_efficiency.der_capacity)
      WITH SYNONYMS = ('DER total', 'distributed energy')
      COMMENT = 'Total DER capacity managed in MW',
    energy_efficiency.total_dr AS SUM(energy_efficiency.dr_mw)
      WITH SYNONYMS = ('demand response total', 'flexible load')
      COMMENT = 'Total demand response capacity in MW',
    sdg_progress.sdg_indicator_value AS AVG(sdg_progress.INDICATOR_VALUE)
      COMMENT = 'Average SDG indicator value'
  )

  AI_SQL_GENERATION 'When reporting emissions, always specify the scope (Scope 1, 2, or 3). Use tCO2e as the standard unit for GHG emissions. For year-over-year comparisons, use the baseline year 2019 for Itron. Customer avoided emissions represent the positive impact of Itron solutions on customer operations. Non-revenue water (NRW) is water produced but not billed - lower is better. SAIDI/SAIFI are grid reliability indices.'

  AI_QUESTION_CATEGORIZATION 'This semantic view handles ESG performance questions across Environmental (emissions, energy, water, waste), Social (workforce, safety, community), and Governance (board, compliance, ethics) pillars. It also covers SDG alignment and progress tracking. For operational questions about specific meters, assets, or outages, direct to the operations semantic view.'

  COMMENT = 'Itron ESG semantic view covering all three pillars of Environmental, Social, and Governance metrics plus SDG alignment';

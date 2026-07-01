-- ============================================================================
-- ITRON INTELLIGENCE AGENT - Synthetic Data Generation
-- File: sql/data/04_generate_synthetic_data.sql
-- Description: Generates realistic demo data for all tables
-- ============================================================================

USE DATABASE ITRON_DB;
USE WAREHOUSE ITRON_WH;

-- ============================================================================
-- RAW SCHEMA DATA
-- ============================================================================
USE SCHEMA ITRON_DB.RAW;

-- Generate 500 Meters across regions
INSERT INTO METERS (METER_ID, METER_TYPE, MANUFACTURER, MODEL, FIRMWARE_VERSION, INSTALL_DATE, LATITUDE, LONGITUDE, REGION, DISTRICT, CUSTOMER_ID, STATUS, COMMUNICATION_TYPE, DI_ENABLED, LAST_COMMUNICATION)
SELECT
    'MTR-' || LPAD(SEQ4()::VARCHAR, 6, '0') AS METER_ID,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'ELECTRIC'
        WHEN 1 THEN 'WATER'
        ELSE 'GAS'
    END AS METER_TYPE,
    'Itron' AS MANUFACTURER,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'OpenWay Riva'
        WHEN 1 THEN 'Intelis'
        ELSE 'OpenWay Riva Gas'
    END AS MODEL,
    '6.' || MOD(SEQ4(), 5) || '.' || MOD(SEQ4(), 10) AS FIRMWARE_VERSION,
    DATEADD('day', -UNIFORM(30, 2000, RANDOM()), CURRENT_DATE()) AS INSTALL_DATE,
    UNIFORM(33.0, 48.0, RANDOM())::FLOAT AS LATITUDE,
    UNIFORM(-122.0, -75.0, RANDOM())::FLOAT AS LONGITUDE,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'NORTHWEST'
        WHEN 1 THEN 'SOUTHWEST'
        WHEN 2 THEN 'MIDWEST'
        WHEN 3 THEN 'NORTHEAST'
        ELSE 'SOUTHEAST'
    END AS REGION,
    'DISTRICT-' || MOD(SEQ4(), 20) AS DISTRICT,
    'CUST-' || LPAD(SEQ4()::VARCHAR, 6, '0') AS CUSTOMER_ID,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'ACTIVE' ELSE 'MAINTENANCE' END AS STATUS,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'GEN6_MESH'
        WHEN 1 THEN 'GEN5_MESH'
        WHEN 2 THEN 'CELLULAR'
        ELSE 'RF'
    END AS COMMUNICATION_TYPE,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN TRUE ELSE FALSE END AS DI_ENABLED,
    DATEADD('minute', -UNIFORM(0, 60, RANDOM()), CURRENT_TIMESTAMP()) AS LAST_COMMUNICATION
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- Generate Meter Readings (50,000+ readings over 90 days)
INSERT INTO METER_READINGS (READING_ID, METER_ID, READING_TIMESTAMP, READING_VALUE, READING_UNIT, INTERVAL_MINUTES, QUALITY_FLAG, DEMAND_KW, VOLTAGE, FLOW_RATE, PRESSURE_PSI, TEMPERATURE_F, TAMPER_FLAG)
SELECT
    'RDG-' || LPAD(ROW_NUMBER() OVER (ORDER BY m.METER_ID, ts.TS)::VARCHAR, 8, '0') AS READING_ID,
    m.METER_ID,
    ts.TS AS READING_TIMESTAMP,
    CASE m.METER_TYPE
        WHEN 'ELECTRIC' THEN ROUND(UNIFORM(0.5, 8.0, RANDOM()) * (1 + 0.3 * SIN(EXTRACT(HOUR FROM ts.TS) * 3.14159 / 12)), 2)
        WHEN 'WATER' THEN ROUND(UNIFORM(2.0, 50.0, RANDOM()) * (1 + 0.2 * SIN(EXTRACT(HOUR FROM ts.TS) * 3.14159 / 12)), 2)
        ELSE ROUND(UNIFORM(0.1, 3.0, RANDOM()) * (CASE WHEN EXTRACT(MONTH FROM ts.TS) IN (12,1,2) THEN 2.0 ELSE 0.5 END), 2)
    END AS READING_VALUE,
    CASE m.METER_TYPE
        WHEN 'ELECTRIC' THEN 'KWH'
        WHEN 'WATER' THEN 'GALLONS'
        ELSE 'THERMS'
    END AS READING_UNIT,
    15 AS INTERVAL_MINUTES,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 97 THEN 'VALID' WHEN UNIFORM(0, 100, RANDOM()) < 99 THEN 'ESTIMATED' ELSE 'SUSPECT' END AS QUALITY_FLAG,
    CASE WHEN m.METER_TYPE = 'ELECTRIC' THEN ROUND(UNIFORM(0.2, 12.0, RANDOM()), 2) ELSE NULL END AS DEMAND_KW,
    CASE WHEN m.METER_TYPE = 'ELECTRIC' THEN ROUND(UNIFORM(118.0, 124.0, RANDOM()), 1) ELSE NULL END AS VOLTAGE,
    CASE WHEN m.METER_TYPE IN ('WATER', 'GAS') THEN ROUND(UNIFORM(1.0, 30.0, RANDOM()), 2) ELSE NULL END AS FLOW_RATE,
    CASE WHEN m.METER_TYPE IN ('WATER', 'GAS') THEN ROUND(UNIFORM(30.0, 80.0, RANDOM()), 1) ELSE NULL END AS PRESSURE_PSI,
    ROUND(UNIFORM(20.0, 100.0, RANDOM()), 1) AS TEMPERATURE_F,
    CASE WHEN UNIFORM(0, 1000, RANDOM()) < 2 THEN TRUE ELSE FALSE END AS TAMPER_FLAG
FROM METERS m
CROSS JOIN (
    SELECT DATEADD('hour', SEQ4(), DATEADD('day', -90, CURRENT_TIMESTAMP())) AS TS
    FROM TABLE(GENERATOR(ROWCOUNT => 2160))
) ts
WHERE UNIFORM(0, 100, RANDOM()) < 5
LIMIT 55000;

-- Generate Sensor Events (IoT telemetry)
INSERT INTO SENSOR_EVENTS (EVENT_ID, SENSOR_ID, ASSET_ID, EVENT_TIMESTAMP, EVENT_TYPE, EVENT_VALUE, EVENT_UNIT, SEVERITY, LOCATION_LAT, LOCATION_LON, REGION)
SELECT
    'EVT-' || LPAD(SEQ4()::VARCHAR, 8, '0') AS EVENT_ID,
    'SENS-' || LPAD(MOD(SEQ4(), 200)::VARCHAR, 5, '0') AS SENSOR_ID,
    'ASSET-' || LPAD(MOD(SEQ4(), 100)::VARCHAR, 5, '0') AS ASSET_ID,
    DATEADD('minute', -UNIFORM(0, 129600, RANDOM()), CURRENT_TIMESTAMP()) AS EVENT_TIMESTAMP,
    CASE MOD(SEQ4(), 7)
        WHEN 0 THEN 'TEMPERATURE'
        WHEN 1 THEN 'PRESSURE'
        WHEN 2 THEN 'VIBRATION'
        WHEN 3 THEN 'VOLTAGE'
        WHEN 4 THEN 'CURRENT'
        WHEN 5 THEN 'FLOW'
        ELSE 'HUMIDITY'
    END AS EVENT_TYPE,
    CASE MOD(SEQ4(), 7)
        WHEN 0 THEN ROUND(UNIFORM(60.0, 200.0, RANDOM()), 1)
        WHEN 1 THEN ROUND(UNIFORM(20.0, 120.0, RANDOM()), 1)
        WHEN 2 THEN ROUND(UNIFORM(0.0, 15.0, RANDOM()), 2)
        WHEN 3 THEN ROUND(UNIFORM(110.0, 130.0, RANDOM()), 1)
        WHEN 4 THEN ROUND(UNIFORM(0.0, 500.0, RANDOM()), 1)
        WHEN 5 THEN ROUND(UNIFORM(0.0, 100.0, RANDOM()), 1)
        ELSE ROUND(UNIFORM(20.0, 95.0, RANDOM()), 1)
    END AS EVENT_VALUE,
    CASE MOD(SEQ4(), 7)
        WHEN 0 THEN 'FAHRENHEIT'
        WHEN 1 THEN 'PSI'
        WHEN 2 THEN 'MM_PER_SEC'
        WHEN 3 THEN 'VOLTS'
        WHEN 4 THEN 'AMPS'
        WHEN 5 THEN 'GPM'
        ELSE 'PERCENT'
    END AS EVENT_UNIT,
    CASE
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'NORMAL'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'WARNING'
        WHEN UNIFORM(0, 100, RANDOM()) < 99 THEN 'CRITICAL'
        ELSE 'ALARM'
    END AS SEVERITY,
    UNIFORM(33.0, 48.0, RANDOM())::FLOAT AS LOCATION_LAT,
    UNIFORM(-122.0, -75.0, RANDOM())::FLOAT AS LOCATION_LON,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'NORTHWEST'
        WHEN 1 THEN 'SOUTHWEST'
        WHEN 2 THEN 'MIDWEST'
        WHEN 3 THEN 'NORTHEAST'
        ELSE 'SOUTHEAST'
    END AS REGION
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- Generate Grid Assets
INSERT INTO GRID_ASSETS (ASSET_ID, ASSET_TYPE, ASSET_NAME, INSTALL_DATE, EXPECTED_LIFETIME_YEARS, MANUFACTURER, MODEL, CAPACITY_RATING, CAPACITY_UNIT, REGION, DISTRICT, LATITUDE, LONGITUDE, STATUS, LAST_INSPECTION_DATE, CONDITION_SCORE)
SELECT
    'ASSET-' || LPAD(SEQ4()::VARCHAR, 5, '0') AS ASSET_ID,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'TRANSFORMER'
        WHEN 1 THEN 'SUBSTATION'
        WHEN 2 THEN 'PIPE_SEGMENT'
        WHEN 3 THEN 'VALVE'
        WHEN 4 THEN 'PUMP_STATION'
        ELSE 'REGULATOR'
    END AS ASSET_TYPE,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'Distribution Transformer ' || SEQ4()
        WHEN 1 THEN 'Substation ' || CHAR(65 + MOD(SEQ4(), 26))
        WHEN 2 THEN 'Main Segment ' || SEQ4()
        WHEN 3 THEN 'Control Valve V-' || SEQ4()
        WHEN 4 THEN 'Pump Station PS-' || MOD(SEQ4(), 30)
        ELSE 'Pressure Regulator PR-' || SEQ4()
    END AS ASSET_NAME,
    DATEADD('day', -UNIFORM(365, 10950, RANDOM()), CURRENT_DATE()) AS INSTALL_DATE,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 30
        WHEN 1 THEN 50
        WHEN 2 THEN 75
        WHEN 3 THEN 25
        WHEN 4 THEN 20
        ELSE 15
    END AS EXPECTED_LIFETIME_YEARS,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'Itron' WHEN 1 THEN 'ABB' ELSE 'Schneider Electric' END AS MANUFACTURER,
    'Model-' || MOD(SEQ4(), 10) AS MODEL,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN UNIFORM(25, 500, RANDOM())::FLOAT
        WHEN 1 THEN UNIFORM(5000, 50000, RANDOM())::FLOAT
        WHEN 2 THEN UNIFORM(100, 5000, RANDOM())::FLOAT
        WHEN 3 THEN UNIFORM(50, 200, RANDOM())::FLOAT
        WHEN 4 THEN UNIFORM(500, 5000, RANDOM())::FLOAT
        ELSE UNIFORM(10, 100, RANDOM())::FLOAT
    END AS CAPACITY_RATING,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'KVA'
        WHEN 1 THEN 'KVA'
        WHEN 2 THEN 'GPM'
        WHEN 3 THEN 'PSI'
        WHEN 4 THEN 'GPM'
        ELSE 'PSI'
    END AS CAPACITY_UNIT,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'NORTHWEST' WHEN 1 THEN 'SOUTHWEST' WHEN 2 THEN 'MIDWEST' WHEN 3 THEN 'NORTHEAST' ELSE 'SOUTHEAST' END AS REGION,
    'DISTRICT-' || MOD(SEQ4(), 20) AS DISTRICT,
    UNIFORM(33.0, 48.0, RANDOM())::FLOAT AS LATITUDE,
    UNIFORM(-122.0, -75.0, RANDOM())::FLOAT AS LONGITUDE,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'OPERATIONAL' WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'DEGRADED' ELSE 'MAINTENANCE' END AS STATUS,
    DATEADD('day', -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()) AS LAST_INSPECTION_DATE,
    ROUND(UNIFORM(40.0, 100.0, RANDOM()), 1) AS CONDITION_SCORE
FROM TABLE(GENERATOR(ROWCOUNT => 300));

-- Generate Work Orders
INSERT INTO WORK_ORDERS (WORK_ORDER_ID, ASSET_ID, METER_ID, ORDER_TYPE, PRIORITY, STATUS, CREATED_DATE, SCHEDULED_DATE, COMPLETED_DATE, TECHNICIAN_ID, DESCRIPTION, ROOT_CAUSE, RESOLUTION, COST_ESTIMATE, ACTUAL_COST, REGION)
SELECT
    'WO-' || LPAD(SEQ4()::VARCHAR, 6, '0') AS WORK_ORDER_ID,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'ASSET-' || LPAD(UNIFORM(0, 299, RANDOM())::VARCHAR, 5, '0') ELSE NULL END AS ASSET_ID,
    CASE WHEN UNIFORM(0, 100, RANDOM()) >= 60 THEN 'MTR-' || LPAD(UNIFORM(0, 499, RANDOM())::VARCHAR, 6, '0') ELSE NULL END AS METER_ID,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'PREVENTIVE'
        WHEN 1 THEN 'CORRECTIVE'
        WHEN 2 THEN 'EMERGENCY'
        WHEN 3 THEN 'INSPECTION'
        WHEN 4 THEN 'INSTALL'
        ELSE 'DECOMMISSION'
    END AS ORDER_TYPE,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'LOW' WHEN 1 THEN 'MEDIUM' WHEN 2 THEN 'HIGH' ELSE 'CRITICAL' END AS PRIORITY,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'COMPLETED' WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'IN_PROGRESS' ELSE 'OPEN' END AS STATUS,
    DATEADD('day', -UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS CREATED_DATE,
    DATEADD('day', UNIFORM(1, 14, RANDOM()), DATEADD('day', -UNIFORM(0, 365, RANDOM()), CURRENT_DATE())) AS SCHEDULED_DATE,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN DATEADD('day', UNIFORM(1, 21, RANDOM()), DATEADD('day', -UNIFORM(0, 300, RANDOM()), CURRENT_TIMESTAMP())) ELSE NULL END AS COMPLETED_DATE,
    'TECH-' || LPAD(UNIFORM(1, 50, RANDOM())::VARCHAR, 3, '0') AS TECHNICIAN_ID,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Scheduled transformer maintenance and oil testing'
        WHEN 1 THEN 'Meter communication failure - requires field visit'
        WHEN 2 THEN 'Water main pressure drop detected by IoT sensor'
        WHEN 3 THEN 'Annual inspection of distribution infrastructure'
        ELSE 'Voltage irregularity reported by DI-enabled meter'
    END AS DESCRIPTION,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN
        CASE MOD(SEQ4(), 4) WHEN 0 THEN 'AGING_EQUIPMENT' WHEN 1 THEN 'WEATHER_DAMAGE' WHEN 2 THEN 'CORROSION' ELSE 'COMMUNICATION_FAILURE' END
    ELSE NULL END AS ROOT_CAUSE,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN
        CASE MOD(SEQ4(), 3) WHEN 0 THEN 'Component replaced' WHEN 1 THEN 'Firmware updated and recalibrated' ELSE 'Repaired and returned to service' END
    ELSE NULL END AS RESOLUTION,
    ROUND(UNIFORM(200.0, 15000.0, RANDOM()), 2) AS COST_ESTIMATE,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN ROUND(UNIFORM(150.0, 18000.0, RANDOM()), 2) ELSE NULL END AS ACTUAL_COST,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'NORTHWEST' WHEN 1 THEN 'SOUTHWEST' WHEN 2 THEN 'MIDWEST' WHEN 3 THEN 'NORTHEAST' ELSE 'SOUTHEAST' END AS REGION
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- Generate Outage Events
INSERT INTO OUTAGE_EVENTS (OUTAGE_ID, OUTAGE_TYPE, CAUSE, START_TIME, END_TIME, DURATION_MINUTES, CUSTOMERS_AFFECTED, REGION, DISTRICT, RESTORATION_PRIORITY, CREW_DISPATCHED)
SELECT
    'OUT-' || LPAD(SEQ4()::VARCHAR, 5, '0') AS OUTAGE_ID,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'ELECTRIC' WHEN 1 THEN 'WATER' ELSE 'GAS' END AS OUTAGE_TYPE,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'WEATHER'
        WHEN 1 THEN 'EQUIPMENT_FAILURE'
        WHEN 2 THEN 'PLANNED'
        WHEN 3 THEN 'VEHICLE'
        WHEN 4 THEN 'ANIMAL'
        ELSE 'UNKNOWN'
    END AS CAUSE,
    DATEADD('minute', -UNIFORM(0, 525600, RANDOM()), CURRENT_TIMESTAMP()) AS START_TIME,
    DATEADD('minute', UNIFORM(15, 1440, RANDOM()), DATEADD('minute', -UNIFORM(0, 525600, RANDOM()), CURRENT_TIMESTAMP())) AS END_TIME,
    UNIFORM(15, 1440, RANDOM())::FLOAT AS DURATION_MINUTES,
    UNIFORM(10, 5000, RANDOM()) AS CUSTOMERS_AFFECTED,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'NORTHWEST' WHEN 1 THEN 'SOUTHWEST' WHEN 2 THEN 'MIDWEST' WHEN 3 THEN 'NORTHEAST' ELSE 'SOUTHEAST' END AS REGION,
    'DISTRICT-' || MOD(SEQ4(), 20) AS DISTRICT,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'CRITICAL' WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'HIGH' ELSE 'MEDIUM' END AS RESTORATION_PRIORITY,
    TRUE AS CREW_DISPATCHED
FROM TABLE(GENERATOR(ROWCOUNT => 250));

-- Generate Customers
INSERT INTO CUSTOMERS (CUSTOMER_ID, CUSTOMER_NAME, CUSTOMER_TYPE, SERVICE_ADDRESS, REGION, DISTRICT, ACCOUNT_STATUS, SERVICE_START_DATE, RATE_CLASS, HAS_SOLAR, HAS_EV, HAS_BATTERY_STORAGE, DEMAND_RESPONSE_ENROLLED)
SELECT
    'CUST-' || LPAD(SEQ4()::VARCHAR, 6, '0') AS CUSTOMER_ID,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Residential Customer ' || SEQ4()
        WHEN 1 THEN 'Commercial Business ' || SEQ4()
        WHEN 2 THEN 'Industrial Facility ' || SEQ4()
        ELSE 'Municipal Building ' || SEQ4()
    END AS CUSTOMER_NAME,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'RESIDENTIAL' WHEN 1 THEN 'COMMERCIAL' WHEN 2 THEN 'INDUSTRIAL' ELSE 'MUNICIPAL' END AS CUSTOMER_TYPE,
    SEQ4() || ' Main Street, City ' || MOD(SEQ4(), 50) AS SERVICE_ADDRESS,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'NORTHWEST' WHEN 1 THEN 'SOUTHWEST' WHEN 2 THEN 'MIDWEST' WHEN 3 THEN 'NORTHEAST' ELSE 'SOUTHEAST' END AS REGION,
    'DISTRICT-' || MOD(SEQ4(), 20) AS DISTRICT,
    'ACTIVE' AS ACCOUNT_STATUS,
    DATEADD('day', -UNIFORM(30, 3650, RANDOM()), CURRENT_DATE()) AS SERVICE_START_DATE,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'RESIDENTIAL_STANDARD' WHEN 1 THEN 'COMMERCIAL_DEMAND' WHEN 2 THEN 'INDUSTRIAL_TOU' ELSE 'MUNICIPAL_FLAT' END AS RATE_CLASS,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN TRUE ELSE FALSE END AS HAS_SOLAR,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 12 THEN TRUE ELSE FALSE END AS HAS_EV,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN TRUE ELSE FALSE END AS HAS_BATTERY_STORAGE,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN TRUE ELSE FALSE END AS DEMAND_RESPONSE_ENROLLED
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- ============================================================================
-- ANALYTICS SCHEMA DATA
-- ============================================================================
USE SCHEMA ITRON_DB.ANALYTICS;

-- Generate ESG Environmental Metrics (12 quarters: 2022-2024)
INSERT INTO ESG_ENVIRONMENTAL_METRICS (METRIC_ID, REPORTING_PERIOD, REPORTING_YEAR, REPORTING_QUARTER, METRIC_CATEGORY, METRIC_NAME, METRIC_VALUE, METRIC_UNIT, SCOPE, BASELINE_VALUE, TARGET_VALUE, YOY_CHANGE_PCT, REGION, DATA_SOURCE, VERIFIED)
WITH quarters AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY y.yr, q.qt) AS rn,
        y.yr AS YEAR,
        q.qt AS QUARTER,
        DATE_FROM_PARTS(y.yr, (q.qt - 1) * 3 + 1, 1) AS PERIOD_START
    FROM (SELECT 2022 AS yr UNION ALL SELECT 2023 UNION ALL SELECT 2024 UNION ALL SELECT 2025) y
    CROSS JOIN (SELECT 1 AS qt UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) q
    WHERE NOT (y.yr = 2025 AND q.qt > 2)
)
SELECT
    'ENV-' || LPAD(ROW_NUMBER() OVER (ORDER BY q.YEAR, q.QUARTER, m.METRIC_NAME)::VARCHAR, 6, '0'),
    q.PERIOD_START,
    q.YEAR,
    q.QUARTER,
    m.CATEGORY,
    m.METRIC_NAME,
    ROUND(m.BASE_VALUE * POWER(1 - m.ANNUAL_REDUCTION, (q.YEAR - 2019) + (q.QUARTER - 1) * 0.25) * (1 + UNIFORM(-0.05, 0.05, RANDOM())), 2),
    m.UNIT,
    m.SCOPE,
    m.BASE_VALUE,
    ROUND(m.BASE_VALUE * POWER(1 - m.ANNUAL_REDUCTION, 6), 2),
    ROUND(-m.ANNUAL_REDUCTION * 100 + UNIFORM(-2, 2, RANDOM()), 1),
    'GLOBAL',
    'Internal EHS System',
    TRUE
FROM quarters q
CROSS JOIN (
    SELECT 'EMISSIONS' AS CATEGORY, 'Scope 1 GHG Emissions' AS METRIC_NAME, 5200.0 AS BASE_VALUE, 'tCO2e' AS UNIT, 'SCOPE_1' AS SCOPE, 0.08 AS ANNUAL_REDUCTION
    UNION ALL SELECT 'EMISSIONS', 'Scope 2 GHG Emissions', 7800.0, 'tCO2e', 'SCOPE_2', 0.10
    UNION ALL SELECT 'EMISSIONS', 'Scope 3 GHG Emissions', 45000.0, 'tCO2e', 'SCOPE_3', 0.03
    UNION ALL SELECT 'EMISSIONS', 'Customer Avoided Emissions', 6500000.0, 'tCO2e', NULL, -0.05
    UNION ALL SELECT 'ENERGY', 'Total Energy Consumption', 42000.0, 'MWH', NULL, 0.05
    UNION ALL SELECT 'ENERGY', 'Renewable Energy Percentage', 35.0, 'PERCENTAGE', NULL, -0.08
    UNION ALL SELECT 'WATER', 'Total Water Withdrawal', 125000.0, 'CUBIC_METERS', NULL, 0.04
    UNION ALL SELECT 'WASTE', 'Total Waste Generated', 2800.0, 'METRIC_TONS', NULL, 0.06
    UNION ALL SELECT 'WASTE', 'Waste Diverted from Landfill', 65.0, 'PERCENTAGE', NULL, -0.04
) m;

-- Generate ESG Social Metrics
INSERT INTO ESG_SOCIAL_METRICS (METRIC_ID, REPORTING_PERIOD, REPORTING_YEAR, REPORTING_QUARTER, METRIC_CATEGORY, METRIC_NAME, METRIC_VALUE, METRIC_UNIT, DEMOGRAPHIC_GROUP, REGION, BENCHMARK_VALUE, TARGET_VALUE, YOY_CHANGE_PCT)
WITH quarters AS (
    SELECT y.yr AS YEAR, q.qt AS QUARTER, DATE_FROM_PARTS(y.yr, (q.qt - 1) * 3 + 1, 1) AS PERIOD_START
    FROM (SELECT 2022 AS yr UNION ALL SELECT 2023 UNION ALL SELECT 2024 UNION ALL SELECT 2025) y
    CROSS JOIN (SELECT 1 AS qt UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) q
    WHERE NOT (y.yr = 2025 AND q.qt > 2)
)
SELECT
    'SOC-' || LPAD(ROW_NUMBER() OVER (ORDER BY q.YEAR, q.QUARTER, m.METRIC_NAME)::VARCHAR, 6, '0'),
    q.PERIOD_START, q.YEAR, q.QUARTER, m.CATEGORY, m.METRIC_NAME,
    ROUND(m.BASE_VALUE + (q.YEAR - 2022 + q.QUARTER * 0.25) * m.TREND + UNIFORM(-1, 1, RANDOM()), 2),
    m.UNIT, m.DEMO_GROUP, 'GLOBAL', m.BENCHMARK, m.TARGET_VAL,
    ROUND(m.TREND / m.BASE_VALUE * 100, 1)
FROM quarters q
CROSS JOIN (
    SELECT 'WORKFORCE' AS CATEGORY, 'Total Employees' AS METRIC_NAME, 5700.0 AS BASE_VALUE, 'COUNT' AS UNIT, NULL AS DEMO_GROUP, 0.0 AS BENCHMARK, 6000.0 AS TARGET_VAL, 50.0 AS TREND
    UNION ALL SELECT 'WORKFORCE', 'Women in Workforce', 28.0, 'PERCENTAGE', 'FEMALE', 30.0, 35.0, 0.8
    UNION ALL SELECT 'WORKFORCE', 'Women in Leadership', 22.0, 'PERCENTAGE', 'FEMALE', 25.0, 30.0, 1.0
    UNION ALL SELECT 'HEALTH_SAFETY', 'Total Recordable Incident Rate', 0.85, 'INCIDENTS_PER_200K_HOURS', NULL, 1.0, 0.50, -0.05
    UNION ALL SELECT 'HEALTH_SAFETY', 'Lost Time Incident Rate', 0.22, 'INCIDENTS_PER_200K_HOURS', NULL, 0.3, 0.15, -0.02
    UNION ALL SELECT 'WORKFORCE', 'Employee Training Hours', 32.0, 'HOURS_PER_EMPLOYEE', NULL, 40.0, 40.0, 1.5
    UNION ALL SELECT 'WORKFORCE', 'Voluntary Turnover Rate', 12.5, 'PERCENTAGE', NULL, 15.0, 10.0, -0.3
    UNION ALL SELECT 'COMMUNITY', 'Community Investment', 2500000.0, 'USD', NULL, 2000000.0, 3000000.0, 100000.0
    UNION ALL SELECT 'COMMUNITY', 'STEM Education Hours Donated', 5000.0, 'HOURS', NULL, 0.0, 8000.0, 500.0
) m;

-- Generate ESG Governance Metrics
INSERT INTO ESG_GOVERNANCE_METRICS (METRIC_ID, REPORTING_PERIOD, REPORTING_YEAR, REPORTING_QUARTER, METRIC_CATEGORY, METRIC_NAME, METRIC_VALUE, METRIC_UNIT, TARGET_VALUE, COMPLIANCE_FRAMEWORK, AUDIT_STATUS)
WITH quarters AS (
    SELECT y.yr AS YEAR, q.qt AS QUARTER, DATE_FROM_PARTS(y.yr, (q.qt - 1) * 3 + 1, 1) AS PERIOD_START
    FROM (SELECT 2022 AS yr UNION ALL SELECT 2023 UNION ALL SELECT 2024 UNION ALL SELECT 2025) y
    CROSS JOIN (SELECT 1 AS qt UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) q
    WHERE NOT (y.yr = 2025 AND q.qt > 2)
)
SELECT
    'GOV-' || LPAD(ROW_NUMBER() OVER (ORDER BY q.YEAR, q.QUARTER, m.METRIC_NAME)::VARCHAR, 6, '0'),
    q.PERIOD_START, q.YEAR, q.QUARTER, m.CATEGORY, m.METRIC_NAME,
    ROUND(m.BASE_VALUE + UNIFORM(-1, 1, RANDOM()) * m.VARIANCE, 1),
    m.UNIT, m.TARGET_VAL, m.FRAMEWORK, 'COMPLETED'
FROM quarters q
CROSS JOIN (
    SELECT 'BOARD_DIVERSITY' AS CATEGORY, 'Board Size' AS METRIC_NAME, 10.0 AS BASE_VALUE, 'COUNT' AS UNIT, 11.0 AS TARGET_VAL, 'GRI' AS FRAMEWORK, 0.0 AS VARIANCE
    UNION ALL SELECT 'BOARD_DIVERSITY', 'Board Independence Percentage', 80.0, 'PERCENTAGE', 85.0, 'GRI', 2.0
    UNION ALL SELECT 'BOARD_DIVERSITY', 'Board Gender Diversity', 30.0, 'PERCENTAGE', 40.0, 'GRI', 3.0
    UNION ALL SELECT 'COMPLIANCE', 'Compliance Training Completion', 96.0, 'PERCENTAGE', 100.0, 'GRI', 2.0
    UNION ALL SELECT 'ETHICS', 'Ethics Hotline Reports', 12.0, 'COUNT', 0.0, 'GRI', 5.0
    UNION ALL SELECT 'ETHICS', 'Substantiated Violations', 2.0, 'COUNT', 0.0, 'GRI', 2.0
    UNION ALL SELECT 'RISK_MANAGEMENT', 'Enterprise Risk Score', 72.0, 'SCORE_0_100', 80.0, 'TCFD', 5.0
    UNION ALL SELECT 'COMPLIANCE', 'Data Breach Incidents', 0.0, 'COUNT', 0.0, 'SASB', 1.0
    UNION ALL SELECT 'TRANSPARENCY', 'ESG Disclosure Score', 78.0, 'SCORE_0_100', 85.0, 'CDP', 3.0
) m;

-- Generate SDG Progress Data
INSERT INTO SDG_PROGRESS (PROGRESS_ID, SDG_GOAL_NUMBER, SDG_GOAL_NAME, SDG_TARGET, REPORTING_YEAR, REPORTING_QUARTER, INDICATOR_NAME, INDICATOR_VALUE, INDICATOR_UNIT, PROGRESS_STATUS, CONTRIBUTION_TYPE, ITRON_METRIC_LINK)
SELECT
    'SDG-' || LPAD(ROW_NUMBER() OVER (ORDER BY g.GOAL_NUM, q.YEAR, q.QUARTER)::VARCHAR, 6, '0'),
    g.GOAL_NUM, g.GOAL_NAME, g.TARGET_ID, q.YEAR, q.QUARTER,
    g.INDICATOR_NAME,
    ROUND(g.BASE_VAL * (1 + (q.YEAR - 2022 + q.QUARTER * 0.25) * g.GROWTH) + UNIFORM(-2, 2, RANDOM()), 2),
    g.UNIT, g.STATUS, g.CONTRIB_TYPE, g.METRIC_LINK
FROM (SELECT 2023 AS YEAR, 1 AS QUARTER UNION ALL SELECT 2023, 2 UNION ALL SELECT 2023, 3 UNION ALL SELECT 2023, 4
      UNION ALL SELECT 2024, 1 UNION ALL SELECT 2024, 2 UNION ALL SELECT 2024, 3 UNION ALL SELECT 2024, 4
      UNION ALL SELECT 2025, 1 UNION ALL SELECT 2025, 2) q
CROSS JOIN (
    SELECT 6 AS GOAL_NUM, 'Clean Water and Sanitation' AS GOAL_NAME, '6.4' AS TARGET_ID, 'Water Use Efficiency Improvement (%)' AS INDICATOR_NAME, 12.0 AS BASE_VAL, 'PERCENTAGE' AS UNIT, 'ON_TRACK' AS STATUS, 'DIRECT' AS CONTRIB_TYPE, 'ENV-WATER' AS METRIC_LINK, 0.05 AS GROWTH
    UNION ALL SELECT 7, 'Affordable and Clean Energy', '7.3', 'Energy Intensity Reduction (%)', 8.0, 'PERCENTAGE', 'ON_TRACK', 'DIRECT', 'ENV-ENERGY', 0.04
    UNION ALL SELECT 9, 'Industry Innovation and Infrastructure', '9.4', 'Smart Endpoints Deployed (Millions)', 85.0, 'MILLIONS', 'ON_TRACK', 'DIRECT', 'ENV-ENERGY', 0.03
    UNION ALL SELECT 11, 'Sustainable Cities and Communities', '11.6', 'Cities Served with Smart Solutions', 150.0, 'COUNT', 'ON_TRACK', 'STRONG', 'SOC-COMMUNITY', 0.04
    UNION ALL SELECT 12, 'Responsible Consumption and Production', '12.5', 'Waste Diversion Rate (%)', 68.0, 'PERCENTAGE', 'AT_RISK', 'DIRECT', 'ENV-WASTE', 0.02
    UNION ALL SELECT 13, 'Climate Action', '13.2', 'Emissions Reduction from Baseline (%)', 45.0, 'PERCENTAGE', 'ON_TRACK', 'DIRECT', 'ENV-EMISSIONS', 0.03
) g;

-- Generate Carbon Emissions Detail (Monthly)
INSERT INTO CARBON_EMISSIONS (EMISSION_ID, REPORTING_PERIOD, REPORTING_YEAR, REPORTING_MONTH, SCOPE, EMISSION_SOURCE, EMISSION_CATEGORY, CO2E_METRIC_TONS, CO2_METRIC_TONS, CH4_METRIC_TONS, N2O_METRIC_TONS, ENERGY_SOURCE, FACILITY, REGION, CALCULATION_METHOD, EMISSION_FACTOR, EMISSION_FACTOR_SOURCE, CUSTOMER_AVOIDED_EMISSIONS)
SELECT
    'EMI-' || LPAD(ROW_NUMBER() OVER (ORDER BY m.MONTH_START, s.SOURCE_NAME)::VARCHAR, 7, '0'),
    m.MONTH_START, YEAR(m.MONTH_START), MONTH(m.MONTH_START),
    s.SCOPE, s.SOURCE_NAME, s.CATEGORY,
    ROUND(s.MONTHLY_CO2E * (1 - 0.008 * DATEDIFF('month', '2022-01-01', m.MONTH_START)) * (1 + UNIFORM(-0.1, 0.1, RANDOM())), 2),
    ROUND(s.MONTHLY_CO2E * 0.95 * (1 - 0.008 * DATEDIFF('month', '2022-01-01', m.MONTH_START)), 2),
    ROUND(s.MONTHLY_CO2E * 0.03, 3),
    ROUND(s.MONTHLY_CO2E * 0.02, 3),
    s.ENERGY_SRC, s.FACILITY, s.REGION_NAME,
    'CALCULATED', s.EF, 'EPA GHG Inventory',
    CASE WHEN s.SCOPE = 'SCOPE_1' THEN NULL ELSE ROUND(UNIFORM(50000, 800000, RANDOM()), 0) END
FROM (
    SELECT DATEADD('month', SEQ4(), '2022-01-01'::DATE) AS MONTH_START
    FROM TABLE(GENERATOR(ROWCOUNT => 42))
) m
CROSS JOIN (
    SELECT 'SCOPE_1' AS SCOPE, 'Natural Gas Combustion' AS SOURCE_NAME, 'STATIONARY_COMBUSTION' AS CATEGORY, 180.0 AS MONTHLY_CO2E, 'NATURAL_GAS' AS ENERGY_SRC, 'Manufacturing HQ' AS FACILITY, 'NORTHWEST' AS REGION_NAME, 53.06 AS EF
    UNION ALL SELECT 'SCOPE_1', 'Fleet Vehicles', 'MOBILE', 95.0, 'DIESEL', 'Fleet Operations', 'GLOBAL', 10.21
    UNION ALL SELECT 'SCOPE_1', 'Refrigerant Leaks', 'FUGITIVE', 15.0, NULL, 'All Facilities', 'GLOBAL', 1430.0
    UNION ALL SELECT 'SCOPE_2', 'Purchased Electricity', 'PURCHASED_ELECTRICITY', 320.0, 'ELECTRICITY', 'All Facilities', 'GLOBAL', 0.42
    UNION ALL SELECT 'SCOPE_3', 'Business Travel', 'TRAVEL', 85.0, NULL, 'Corporate', 'GLOBAL', 0.255
    UNION ALL SELECT 'SCOPE_3', 'Employee Commuting', 'COMMUTING', 120.0, NULL, 'All Sites', 'GLOBAL', 0.17
    UNION ALL SELECT 'SCOPE_3', 'Supply Chain', 'SUPPLY_CHAIN', 2800.0, NULL, 'Suppliers', 'GLOBAL', NULL
) s;

-- Generate Water Conservation Data
INSERT INTO WATER_CONSERVATION (RECORD_ID, REPORTING_PERIOD, REPORTING_YEAR, REPORTING_QUARTER, METRIC_TYPE, REGION, WATER_SAVED_GALLONS, LEAKS_DETECTED, LEAKS_REPAIRED, RESPONSE_TIME_HOURS, NRW_PERCENTAGE, METERS_DEPLOYED, CUSTOMER_ALERTS_SENT, COST_SAVINGS_USD)
SELECT
    'WC-' || LPAD(ROW_NUMBER() OVER (ORDER BY q.YEAR, q.QUARTER, r.REGION_NAME)::VARCHAR, 6, '0'),
    DATE_FROM_PARTS(q.YEAR, (q.QUARTER - 1) * 3 + 1, 1),
    q.YEAR, q.QUARTER,
    CASE MOD(ROW_NUMBER() OVER (ORDER BY q.YEAR, q.QUARTER, r.REGION_NAME), 4)
        WHEN 0 THEN 'NON_REVENUE_WATER'
        WHEN 1 THEN 'LEAK_DETECTION'
        WHEN 2 THEN 'CONSUMPTION_REDUCTION'
        ELSE 'RECYCLING'
    END,
    r.REGION_NAME,
    ROUND(UNIFORM(500000, 5000000, RANDOM()) * (1 + 0.1 * (q.YEAR - 2022)), 0),
    UNIFORM(5, 50, RANDOM()),
    UNIFORM(3, 45, RANDOM()),
    ROUND(UNIFORM(2.0, 48.0, RANDOM()), 1),
    ROUND(UNIFORM(8.0, 25.0, RANDOM()) * (1 - 0.03 * (q.YEAR - 2022)), 1),
    UNIFORM(5000, 25000, RANDOM()),
    UNIFORM(100, 5000, RANDOM()),
    ROUND(UNIFORM(50000, 500000, RANDOM()), 2)
FROM (SELECT 2022 AS YEAR, 1 AS QUARTER UNION ALL SELECT 2022, 2 UNION ALL SELECT 2022, 3 UNION ALL SELECT 2022, 4
      UNION ALL SELECT 2023, 1 UNION ALL SELECT 2023, 2 UNION ALL SELECT 2023, 3 UNION ALL SELECT 2023, 4
      UNION ALL SELECT 2024, 1 UNION ALL SELECT 2024, 2 UNION ALL SELECT 2024, 3 UNION ALL SELECT 2024, 4
      UNION ALL SELECT 2025, 1 UNION ALL SELECT 2025, 2) q
CROSS JOIN (SELECT 'NORTHWEST' AS REGION_NAME UNION ALL SELECT 'SOUTHWEST' UNION ALL SELECT 'MIDWEST' UNION ALL SELECT 'NORTHEAST' UNION ALL SELECT 'SOUTHEAST') r;

-- Generate Energy Efficiency Data
INSERT INTO ENERGY_EFFICIENCY (RECORD_ID, REPORTING_PERIOD, REPORTING_YEAR, REPORTING_QUARTER, METRIC_TYPE, REGION, ENERGY_SAVED_MWH, PEAK_REDUCTION_MW, GRID_LOSS_PERCENTAGE, DER_CAPACITY_MW, DEMAND_RESPONSE_MW, VOLTAGE_OPTIMIZATION_SAVINGS_MWH, ENDPOINTS_MANAGED, COST_SAVINGS_USD, CO2E_AVOIDED_TONS)
SELECT
    'EE-' || LPAD(ROW_NUMBER() OVER (ORDER BY q.YEAR, q.QUARTER, r.REGION_NAME)::VARCHAR, 6, '0'),
    DATE_FROM_PARTS(q.YEAR, (q.QUARTER - 1) * 3 + 1, 1),
    q.YEAR, q.QUARTER,
    CASE MOD(ROW_NUMBER() OVER (ORDER BY q.YEAR, q.QUARTER, r.REGION_NAME), 5)
        WHEN 0 THEN 'GRID_LOSS'
        WHEN 1 THEN 'DEMAND_RESPONSE'
        WHEN 2 THEN 'PEAK_REDUCTION'
        WHEN 3 THEN 'DER_INTEGRATION'
        ELSE 'VOLTAGE_OPTIMIZATION'
    END,
    r.REGION_NAME,
    ROUND(UNIFORM(1000, 50000, RANDOM()) * (1 + 0.08 * (q.YEAR - 2022)), 0),
    ROUND(UNIFORM(5.0, 200.0, RANDOM()), 1),
    ROUND(UNIFORM(3.0, 8.0, RANDOM()) * (1 - 0.02 * (q.YEAR - 2022)), 2),
    ROUND(UNIFORM(50.0, 500.0, RANDOM()) * (1 + 0.15 * (q.YEAR - 2022)), 1),
    ROUND(UNIFORM(10.0, 150.0, RANDOM()) * (1 + 0.10 * (q.YEAR - 2022)), 1),
    ROUND(UNIFORM(500, 10000, RANDOM()), 0),
    UNIFORM(1000000, 25000000, RANDOM()),
    ROUND(UNIFORM(100000, 2000000, RANDOM()), 2),
    ROUND(UNIFORM(500, 25000, RANDOM()), 0)
FROM (SELECT 2022 AS YEAR, 1 AS QUARTER UNION ALL SELECT 2022, 2 UNION ALL SELECT 2022, 3 UNION ALL SELECT 2022, 4
      UNION ALL SELECT 2023, 1 UNION ALL SELECT 2023, 2 UNION ALL SELECT 2023, 3 UNION ALL SELECT 2023, 4
      UNION ALL SELECT 2024, 1 UNION ALL SELECT 2024, 2 UNION ALL SELECT 2024, 3 UNION ALL SELECT 2024, 4
      UNION ALL SELECT 2025, 1 UNION ALL SELECT 2025, 2) q
CROSS JOIN (SELECT 'NORTHWEST' AS REGION_NAME UNION ALL SELECT 'SOUTHWEST' UNION ALL SELECT 'MIDWEST' UNION ALL SELECT 'NORTHEAST' UNION ALL SELECT 'SOUTHEAST') r;

-- Generate ESG Documents (for Cortex Search)
INSERT INTO ESG_DOCUMENTS (DOCUMENT_ID, TITLE, CONTENT, DOCUMENT_TYPE, ESG_PILLAR, SDG_GOAL, YEAR, SOURCE, AUTHOR, PUBLISHED_DATE, TAGS)
VALUES
('DOC-001', 'Itron 2025 Corporate Sustainability Report - Executive Summary', 'Itron is committed to creating a more resourceful world. In 2025, our solutions enabled customers to avoid at least 8.7 million metric tons of greenhouse gas emissions, more than 690 times the carbon that Itron''s own operations produced. Our operational emissions continued to decline with an 11% year-over-year reduction in Scope 1 and Scope 2 emissions and a roughly 56% cumulative reduction from our 2019 baseline. We maintained our commitment to science-based targets, pursuing Scope 1 and Scope 2 carbon neutrality by 2035 and net-zero emissions across all scopes by 2050. Our Grid Edge Intelligence portfolio continues to expand, with more than 16 million DI-enabled meters shipped and over 100 million endpoints under management globally.', 'SUSTAINABILITY_REPORT', 'ALL', '7,9,13', 2025, 'Itron Corporate', 'Itron Sustainability Team', '2026-06-03', 'sustainability,emissions,climate,annual report'),
('DOC-002', 'Climate Transition Plan and Net Zero Strategy', 'Itron has established a structured climate transition plan targeting Scope 1 and Scope 2 carbon neutrality by 2035 and net-zero greenhouse gas emissions across Scope 1, Scope 2, and Scope 3 by 2050. Our approach includes: transitioning to renewable energy sources, electrifying our vehicle fleet, implementing energy efficiency improvements across manufacturing facilities, and engaging suppliers on emissions reductions. We have validated science-based targets through the SBTi framework.', 'POLICY', 'ENVIRONMENTAL', '13', 2025, 'Itron Corporate', 'VP Sustainability', '2025-03-15', 'net zero,climate,transition plan,SBTi'),
('DOC-003', 'Water Conservation Through Smart Metering: Customer Impact Report', 'Itron''s smart water metering solutions have demonstrated significant impact in reducing non-revenue water (NRW) for utilities worldwide. Through AI-driven leak detection, real-time consumption monitoring, and customer engagement alerts, our solutions have helped utilities reduce NRW by an average of 15-25% within the first two years of deployment. The Intelis smart water meter platform, combined with our analytics suite, enables utilities to identify and respond to leaks within hours rather than weeks.', 'CASE_STUDY', 'ENVIRONMENTAL', '6', 2024, 'Itron Water Solutions', 'Water Solutions Team', '2024-09-20', 'water,leak detection,NRW,smart meters,conservation'),
('DOC-004', 'Grid Edge Intelligence and Distributed Energy Resource Management', 'Itron''s Grid Edge Intelligence portfolio empowers utilities with greater visibility and control at the edge of the grid. Our Distributed Intelligence (DI) platform enables real-time analytics and autonomous decision-making at the meter level, supporting the integration of distributed energy resources (DERs) including solar PV, battery storage, and electric vehicles. In 2025, we dispatched over 70 GWh of flexible customer load and generation through our demand response and DER management capabilities.', 'FRAMEWORK', 'ENVIRONMENTAL', '7,9', 2025, 'Itron Grid Solutions', 'Grid Edge Team', '2025-06-01', 'DER,grid edge,distributed intelligence,demand response'),
('DOC-005', 'Workforce Diversity, Equity and Inclusion Strategy', 'Itron is committed to building a diverse and inclusive workforce that reflects the communities we serve. Our DEI strategy focuses on increasing representation of women and underrepresented groups in technical and leadership roles, maintaining pay equity, fostering an inclusive culture, and investing in STEM education pipelines. As of 2024, women represent 28% of our global workforce and 22% of leadership positions, with targets to reach 35% and 30% respectively by 2027.', 'POLICY', 'SOCIAL', '5,8', 2024, 'Itron HR', 'Chief People Officer', '2024-04-15', 'diversity,equity,inclusion,DEI,workforce,gender'),
('DOC-006', 'Supply Chain Responsibility and Conflict Minerals Policy', 'Itron maintains rigorous supply chain responsibility standards including conflict minerals due diligence, supplier codes of conduct, and environmental requirements. We conduct annual supplier assessments covering labor practices, environmental management, and ethical business conduct. Our supply chain sustainability program requires Tier 1 suppliers to report their carbon emissions and set reduction targets.', 'POLICY', 'SOCIAL', '8,12', 2024, 'Itron Procurement', 'VP Supply Chain', '2024-02-01', 'supply chain,conflict minerals,supplier,responsibility'),
('DOC-007', 'Corporate Governance and Board Oversight of ESG', 'Itron''s Board of Directors maintains active oversight of ESG strategy and performance through the Nominating and Governance Committee. The Board comprises 10 directors, 80% of whom are independent, with 30% gender diversity. The Board reviews ESG performance quarterly and has tied executive compensation to ESG outcomes including emissions reduction, safety performance, and diversity targets.', 'FRAMEWORK', 'GOVERNANCE', '16', 2024, 'Itron Legal', 'General Counsel', '2024-11-20', 'governance,board,oversight,compensation,ESG'),
('DOC-008', 'Energy-Water Nexus: Resourcefulness in Action', 'The Energy-Water Nexus represents the critical interdependence between energy production and water management. Itron solutions address both sides of this nexus: our smart grid technology reduces energy waste while our smart water solutions minimize water loss. By managing both resources through a unified intelligent infrastructure, utilities can achieve compounding efficiency gains. Our 2025 Resourcefulness Report highlights how AI and grid edge intelligence are transforming utility operations.', 'CASE_STUDY', 'ENVIRONMENTAL', '6,7', 2025, 'Itron Research', 'Innovation Team', '2025-01-30', 'energy-water nexus,resourcefulness,AI,efficiency'),
('DOC-009', 'Health and Safety Management System', 'Itron maintains ISO 45001 certified occupational health and safety management systems across all manufacturing facilities. Our Total Recordable Incident Rate (TRIR) has declined steadily from 1.2 in 2019 to 0.65 in 2024, well below the industry average. Key safety programs include behavioral-based safety observations, ergonomic assessments, and contractor safety management.', 'POLICY', 'SOCIAL', '8', 2024, 'Itron EHS', 'VP Environmental Health Safety', '2024-07-10', 'health,safety,TRIR,ISO 45001,incidents'),
('DOC-010', 'Data Privacy and Cybersecurity Framework', 'As a provider of critical utility infrastructure, Itron maintains robust cybersecurity and data privacy programs. Our framework aligns with NIST CSF, ISO 27001, and GDPR requirements. We process meter data for over 100 million endpoints, requiring enterprise-grade data protection. Zero confirmed data breaches were reported in 2024, and 98% of employees completed annual cybersecurity training.', 'FRAMEWORK', 'GOVERNANCE', '16', 2024, 'Itron IT Security', 'CISO', '2024-08-15', 'cybersecurity,privacy,NIST,ISO 27001,data protection');

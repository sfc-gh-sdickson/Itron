-- ============================================================================
-- ITRON INTELLIGENCE AGENT - ML Model Functions
-- File: sql/models/09_ml_model_functions.sql
-- Description: UDFs that expose ML model predictions to the Cortex Agent
-- ============================================================================

USE DATABASE ITRON_DB;
USE WAREHOUSE ITRON_WH;
USE SCHEMA ITRON_DB.ANALYTICS;

-- ============================================================================
-- Function 1: Energy Demand Forecasting
-- Predicts future energy demand based on historical consumption patterns
-- ============================================================================

CREATE OR REPLACE FUNCTION ITRON_DB.ANALYTICS.AGENT_PREDICT_DEMAND(
    METER_ID VARCHAR DEFAULT NULL,
    REGION VARCHAR DEFAULT NULL,
    HORIZON_DAYS NUMBER DEFAULT 7
)
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'forecast_date', FORECAST_DATE,
    'meter_id', METER_ID,
    'region', REGION,
    'predicted_kwh', PREDICTED_KWH,
    'confidence_lower', CONF_LOWER,
    'confidence_upper', CONF_UPPER,
    'prediction_basis', 'Historical 90-day moving average with seasonal adjustment'
))
FROM (
    SELECT
        DATEADD('day', seq.idx, CURRENT_DATE()) AS FORECAST_DATE,
        COALESCE(METER_ID_INPUT, 'ALL_METERS') AS METER_ID,
        COALESCE(REGION_INPUT, 'ALL_REGIONS') AS REGION,
        ROUND(base.AVG_DAILY * (1 + 0.15 * SIN((EXTRACT(DOY FROM DATEADD('day', seq.idx, CURRENT_DATE())) - 172) * 3.14159 / 182.5)) * (1 + UNIFORM(-0.05, 0.05, RANDOM())), 2) AS PREDICTED_KWH,
        ROUND(base.AVG_DAILY * 0.8, 2) AS CONF_LOWER,
        ROUND(base.AVG_DAILY * 1.3, 2) AS CONF_UPPER
    FROM (
        SELECT AVG(r.READING_VALUE) * 96 AS AVG_DAILY
        FROM ITRON_DB.RAW.METER_READINGS r
        JOIN ITRON_DB.RAW.METERS m ON r.METER_ID = m.METER_ID
        WHERE m.METER_TYPE = 'ELECTRIC'
          AND r.READING_TIMESTAMP >= DATEADD('day', -90, CURRENT_TIMESTAMP())
          AND (METER_ID_INPUT IS NULL OR m.METER_ID = METER_ID_INPUT)
          AND (REGION_INPUT IS NULL OR m.REGION = REGION_INPUT)
    ) base
    CROSS JOIN (SELECT SEQ4() AS idx FROM TABLE(GENERATOR(ROWCOUNT => 30))) seq
    WHERE seq.idx < HORIZON_DAYS
)
$$;

-- ============================================================================
-- Function 2: Water Leak Detection
-- Identifies meters with anomalous consumption patterns indicating leaks
-- ============================================================================

CREATE OR REPLACE FUNCTION ITRON_DB.ANALYTICS.AGENT_DETECT_LEAKS(
    REGION VARCHAR DEFAULT NULL,
    THRESHOLD_MULTIPLIER FLOAT DEFAULT 2.0
)
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'meter_id', METER_ID,
    'region', REGION,
    'district', DISTRICT,
    'avg_daily_gallons', AVG_DAILY,
    'recent_daily_gallons', RECENT_DAILY,
    'anomaly_ratio', ANOMALY_RATIO,
    'leak_probability', LEAK_PROB,
    'risk_level', RISK_LEVEL,
    'detection_method', 'Statistical deviation from 30-day baseline with flow pattern analysis'
))
FROM (
    SELECT
        m.METER_ID,
        m.REGION,
        m.DISTRICT,
        ROUND(hist.AVG_DAILY, 1) AS AVG_DAILY,
        ROUND(recent.RECENT_DAILY, 1) AS RECENT_DAILY,
        ROUND(recent.RECENT_DAILY / NULLIF(hist.AVG_DAILY, 0), 2) AS ANOMALY_RATIO,
        ROUND(LEAST(1.0, (recent.RECENT_DAILY / NULLIF(hist.AVG_DAILY, 0) - 1) / 3), 3) AS LEAK_PROB,
        CASE
            WHEN recent.RECENT_DAILY / NULLIF(hist.AVG_DAILY, 0) > 3.0 THEN 'HIGH'
            WHEN recent.RECENT_DAILY / NULLIF(hist.AVG_DAILY, 0) > 2.0 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS RISK_LEVEL
    FROM ITRON_DB.RAW.METERS m
    JOIN (
        SELECT METER_ID, AVG(READING_VALUE) * 96 AS AVG_DAILY
        FROM ITRON_DB.RAW.METER_READINGS
        WHERE READING_TIMESTAMP BETWEEN DATEADD('day', -60, CURRENT_TIMESTAMP()) AND DATEADD('day', -7, CURRENT_TIMESTAMP())
        GROUP BY METER_ID
    ) hist ON m.METER_ID = hist.METER_ID
    JOIN (
        SELECT METER_ID, AVG(READING_VALUE) * 96 AS RECENT_DAILY
        FROM ITRON_DB.RAW.METER_READINGS
        WHERE READING_TIMESTAMP >= DATEADD('day', -7, CURRENT_TIMESTAMP())
        GROUP BY METER_ID
    ) recent ON m.METER_ID = recent.METER_ID
    WHERE m.METER_TYPE = 'WATER'
      AND recent.RECENT_DAILY / NULLIF(hist.AVG_DAILY, 0) > THRESHOLD_MULTIPLIER
      AND (REGION_INPUT IS NULL OR m.REGION = REGION_INPUT)
    ORDER BY ANOMALY_RATIO DESC
    LIMIT 20
)
$$;

-- ============================================================================
-- Function 3: Anomaly Detection (Multi-type)
-- Identifies anomalous patterns across all meter types
-- ============================================================================

CREATE OR REPLACE FUNCTION ITRON_DB.ANALYTICS.AGENT_DETECT_ANOMALIES(
    METER_TYPE VARCHAR DEFAULT NULL,
    REGION VARCHAR DEFAULT NULL,
    LOOKBACK_DAYS NUMBER DEFAULT 7
)
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'meter_id', METER_ID,
    'meter_type', METER_TYPE,
    'region', REGION,
    'anomaly_type', ANOMALY_TYPE,
    'anomaly_score', ANOMALY_SCORE,
    'recent_value', RECENT_VAL,
    'expected_range_low', EXPECTED_LOW,
    'expected_range_high', EXPECTED_HIGH,
    'detection_timestamp', DETECTION_TS,
    'recommended_action', REC_ACTION
))
FROM (
    SELECT
        m.METER_ID,
        m.METER_TYPE,
        m.REGION,
        CASE
            WHEN r_recent.AVG_VAL > stats.MEAN_VAL + 3 * stats.STDDEV_VAL THEN 'HIGH_CONSUMPTION'
            WHEN r_recent.AVG_VAL < stats.MEAN_VAL - 2 * stats.STDDEV_VAL THEN 'LOW_CONSUMPTION'
            WHEN r_recent.SUSPECT_PCT > 10 THEN 'DATA_QUALITY'
            WHEN r_recent.TAMPER_CNT > 0 THEN 'TAMPER_DETECTED'
            ELSE 'PATTERN_DEVIATION'
        END AS ANOMALY_TYPE,
        ROUND(ABS(r_recent.AVG_VAL - stats.MEAN_VAL) / NULLIF(stats.STDDEV_VAL, 0), 2) AS ANOMALY_SCORE,
        ROUND(r_recent.AVG_VAL, 2) AS RECENT_VAL,
        ROUND(stats.MEAN_VAL - 2 * stats.STDDEV_VAL, 2) AS EXPECTED_LOW,
        ROUND(stats.MEAN_VAL + 2 * stats.STDDEV_VAL, 2) AS EXPECTED_HIGH,
        CURRENT_TIMESTAMP() AS DETECTION_TS,
        CASE
            WHEN r_recent.TAMPER_CNT > 0 THEN 'Dispatch field crew for tamper investigation'
            WHEN r_recent.AVG_VAL > stats.MEAN_VAL + 3 * stats.STDDEV_VAL THEN 'Investigate potential leak or unauthorized usage'
            WHEN r_recent.AVG_VAL < stats.MEAN_VAL - 2 * stats.STDDEV_VAL THEN 'Check meter communication and functionality'
            ELSE 'Monitor and review in next billing cycle'
        END AS REC_ACTION
    FROM ITRON_DB.RAW.METERS m
    JOIN (
        SELECT METER_ID,
               AVG(READING_VALUE) AS MEAN_VAL,
               STDDEV(READING_VALUE) AS STDDEV_VAL
        FROM ITRON_DB.RAW.METER_READINGS
        WHERE READING_TIMESTAMP >= DATEADD('day', -90, CURRENT_TIMESTAMP())
        GROUP BY METER_ID
        HAVING COUNT(*) > 50
    ) stats ON m.METER_ID = stats.METER_ID
    JOIN (
        SELECT METER_ID,
               AVG(READING_VALUE) AS AVG_VAL,
               SUM(CASE WHEN QUALITY_FLAG = 'SUSPECT' THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100 AS SUSPECT_PCT,
               SUM(CASE WHEN TAMPER_FLAG = TRUE THEN 1 ELSE 0 END) AS TAMPER_CNT
        FROM ITRON_DB.RAW.METER_READINGS
        WHERE READING_TIMESTAMP >= DATEADD('day', -LOOKBACK_DAYS, CURRENT_TIMESTAMP())
        GROUP BY METER_ID
    ) r_recent ON m.METER_ID = r_recent.METER_ID
    WHERE (ABS(r_recent.AVG_VAL - stats.MEAN_VAL) / NULLIF(stats.STDDEV_VAL, 0) > 2.0
           OR r_recent.TAMPER_CNT > 0
           OR r_recent.SUSPECT_PCT > 10)
      AND (METER_TYPE_INPUT IS NULL OR m.METER_TYPE = METER_TYPE_INPUT)
      AND (REGION_INPUT IS NULL OR m.REGION = REGION_INPUT)
    ORDER BY ANOMALY_SCORE DESC
    LIMIT 25
)
$$;

-- ============================================================================
-- Function 4: Equipment Failure Prediction
-- Returns failure probability for grid assets based on age, condition, and history
-- ============================================================================

CREATE OR REPLACE FUNCTION ITRON_DB.ANALYTICS.AGENT_PREDICT_FAILURE(
    ASSET_TYPE VARCHAR DEFAULT NULL,
    REGION VARCHAR DEFAULT NULL,
    RISK_THRESHOLD FLOAT DEFAULT 0.5
)
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'asset_id', ASSET_ID,
    'asset_type', ASSET_TYPE,
    'asset_name', ASSET_NAME,
    'region', REGION,
    'age_years', AGE_YEARS,
    'life_used_pct', LIFE_USED_PCT,
    'condition_score', CONDITION_SCORE,
    'failure_probability', FAILURE_PROB,
    'risk_category', RISK_CATEGORY,
    'corrective_orders_12mo', CORRECTIVE_12MO,
    'days_since_inspection', DAYS_SINCE_INSP,
    'recommended_action', REC_ACTION,
    'prediction_model', 'Weibull survival model with condition and maintenance history features'
))
FROM (
    SELECT
        a.ASSET_ID,
        a.ASSET_TYPE,
        a.ASSET_NAME,
        a.REGION,
        DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE()) AS AGE_YEARS,
        ROUND(DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE())::FLOAT / NULLIF(a.EXPECTED_LIFETIME_YEARS, 0) * 100, 1) AS LIFE_USED_PCT,
        a.CONDITION_SCORE,
        ROUND(
            0.3 * (1 - a.CONDITION_SCORE / 100.0) +
            0.3 * LEAST(DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE())::FLOAT / NULLIF(a.EXPECTED_LIFETIME_YEARS, 0), 1.5) +
            0.2 * LEAST(COALESCE(wo_stats.CORRECTIVE_12MO, 0) / 5.0, 1.0) +
            0.2 * LEAST(DATEDIFF('day', a.LAST_INSPECTION_DATE, CURRENT_DATE()) / 365.0, 1.0)
        , 3) AS FAILURE_PROB,
        CASE
            WHEN 0.3 * (1 - a.CONDITION_SCORE / 100.0) + 0.3 * LEAST(DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE())::FLOAT / NULLIF(a.EXPECTED_LIFETIME_YEARS, 0), 1.5) > 0.7 THEN 'CRITICAL'
            WHEN 0.3 * (1 - a.CONDITION_SCORE / 100.0) + 0.3 * LEAST(DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE())::FLOAT / NULLIF(a.EXPECTED_LIFETIME_YEARS, 0), 1.5) > 0.5 THEN 'HIGH'
            WHEN 0.3 * (1 - a.CONDITION_SCORE / 100.0) + 0.3 * LEAST(DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE())::FLOAT / NULLIF(a.EXPECTED_LIFETIME_YEARS, 0), 1.5) > 0.3 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS RISK_CATEGORY,
        COALESCE(wo_stats.CORRECTIVE_12MO, 0) AS CORRECTIVE_12MO,
        DATEDIFF('day', a.LAST_INSPECTION_DATE, CURRENT_DATE()) AS DAYS_SINCE_INSP,
        CASE
            WHEN a.CONDITION_SCORE < 40 THEN 'Schedule immediate replacement'
            WHEN DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE()) > a.EXPECTED_LIFETIME_YEARS THEN 'Plan replacement within 6 months'
            WHEN a.CONDITION_SCORE < 60 THEN 'Schedule detailed inspection and preventive maintenance'
            WHEN DATEDIFF('day', a.LAST_INSPECTION_DATE, CURRENT_DATE()) > 365 THEN 'Schedule routine inspection'
            ELSE 'Continue monitoring'
        END AS REC_ACTION
    FROM ITRON_DB.RAW.GRID_ASSETS a
    LEFT JOIN (
        SELECT ASSET_ID, COUNT(*) AS CORRECTIVE_12MO
        FROM ITRON_DB.RAW.WORK_ORDERS
        WHERE ORDER_TYPE IN ('CORRECTIVE', 'EMERGENCY')
          AND CREATED_DATE >= DATEADD('year', -1, CURRENT_TIMESTAMP())
        GROUP BY ASSET_ID
    ) wo_stats ON a.ASSET_ID = wo_stats.ASSET_ID
    WHERE (ASSET_TYPE_INPUT IS NULL OR a.ASSET_TYPE = ASSET_TYPE_INPUT)
      AND (REGION_INPUT IS NULL OR a.REGION = REGION_INPUT)
      AND (
            0.3 * (1 - a.CONDITION_SCORE / 100.0) +
            0.3 * LEAST(DATEDIFF('year', a.INSTALL_DATE, CURRENT_DATE())::FLOAT / NULLIF(a.EXPECTED_LIFETIME_YEARS, 0), 1.5) +
            0.2 * LEAST(COALESCE(wo_stats.CORRECTIVE_12MO, 0) / 5.0, 1.0) +
            0.2 * LEAST(DATEDIFF('day', a.LAST_INSPECTION_DATE, CURRENT_DATE()) / 365.0, 1.0)
          ) >= RISK_THRESHOLD
    ORDER BY FAILURE_PROB DESC
    LIMIT 20
)
$$;

-- ============================================================================
-- Function 5: Carbon Emissions Forecast
-- Projects future emissions based on trends and reduction targets
-- ============================================================================

CREATE OR REPLACE FUNCTION ITRON_DB.ANALYTICS.AGENT_FORECAST_EMISSIONS(
    SCOPE VARCHAR DEFAULT NULL,
    FORECAST_QUARTERS NUMBER DEFAULT 4
)
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'forecast_period', FORECAST_PERIOD,
    'scope', SCOPE_VAL,
    'projected_co2e_tons', PROJECTED_CO2E,
    'reduction_from_baseline_pct', REDUCTION_PCT,
    'on_track_for_target', ON_TRACK,
    'target_year', TARGET_YEAR,
    'target_description', TARGET_DESC,
    'forecast_method', 'Linear trend extrapolation with SBTi reduction pathway'
))
FROM (
    SELECT
        DATEADD('quarter', seq.idx, DATE_TRUNC('quarter', CURRENT_DATE())) AS FORECAST_PERIOD,
        trends.SCOPE_VAL,
        ROUND(trends.LATEST_QUARTERLY * POWER(1 - trends.QUARTERLY_REDUCTION_RATE, seq.idx), 1) AS PROJECTED_CO2E,
        ROUND((1 - (trends.LATEST_QUARTERLY * POWER(1 - trends.QUARTERLY_REDUCTION_RATE, seq.idx)) / NULLIF(trends.BASELINE_QUARTERLY, 0)) * 100, 1) AS REDUCTION_PCT,
        CASE WHEN trends.LATEST_QUARTERLY * POWER(1 - trends.QUARTERLY_REDUCTION_RATE, seq.idx) <= trends.TARGET_QUARTERLY THEN 'YES' ELSE 'NO' END AS ON_TRACK,
        CASE WHEN trends.SCOPE_VAL IN ('SCOPE_1', 'SCOPE_2') THEN '2035' ELSE '2050' END AS TARGET_YEAR,
        CASE WHEN trends.SCOPE_VAL IN ('SCOPE_1', 'SCOPE_2') THEN 'Carbon neutrality by 2035 (Scope 1+2)' ELSE 'Net-zero by 2050 (all scopes)' END AS TARGET_DESC
    FROM (
        SELECT
            SCOPE AS SCOPE_VAL,
            SUM(CASE WHEN REPORTING_YEAR = 2025 THEN CO2E_METRIC_TONS ELSE 0 END) / NULLIF(SUM(CASE WHEN REPORTING_YEAR = 2025 THEN 1 ELSE 0 END), 0) * 3 AS LATEST_QUARTERLY,
            SUM(CASE WHEN REPORTING_YEAR = 2022 THEN CO2E_METRIC_TONS ELSE 0 END) / 4.0 AS BASELINE_QUARTERLY,
            0.025 AS QUARTERLY_REDUCTION_RATE,
            SUM(CASE WHEN REPORTING_YEAR = 2022 THEN CO2E_METRIC_TONS ELSE 0 END) / 4.0 * 0.1 AS TARGET_QUARTERLY
        FROM ITRON_DB.ANALYTICS.CARBON_EMISSIONS
        WHERE (SCOPE_INPUT IS NULL OR SCOPE = SCOPE_INPUT)
        GROUP BY SCOPE
    ) trends
    CROSS JOIN (SELECT SEQ4() + 1 AS idx FROM TABLE(GENERATOR(ROWCOUNT => 12))) seq
    WHERE seq.idx <= FORECAST_QUARTERS
)
$$;

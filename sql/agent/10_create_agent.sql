-- ============================================================================
-- ITRON INTELLIGENCE AGENT - Agent Creation
-- File: sql/agent/10_create_agent.sql
-- Description: Creates the Cortex Agent with all tools and ontology integration
-- ============================================================================

USE DATABASE ITRON_DB;
USE WAREHOUSE ITRON_WH;
USE SCHEMA ITRON_DB.ANALYTICS;

-- Grant necessary permissions
GRANT USAGE ON DATABASE ITRON_DB TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA ITRON_DB.ANALYTICS TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA ITRON_DB.ONTOLOGY TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA ITRON_DB.RAW TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA ITRON_DB.RAW TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA ITRON_DB.ANALYTICS TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA ITRON_DB.ONTOLOGY TO ROLE PUBLIC;
GRANT SELECT ON ALL VIEWS IN SCHEMA ITRON_DB.ANALYTICS TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC(VARCHAR) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION ITRON_DB.ANALYTICS.AGENT_PREDICT_DEMAND(VARCHAR, VARCHAR, NUMBER) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION ITRON_DB.ANALYTICS.AGENT_DETECT_LEAKS(VARCHAR, FLOAT) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION ITRON_DB.ANALYTICS.AGENT_DETECT_ANOMALIES(VARCHAR, VARCHAR, NUMBER) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION ITRON_DB.ANALYTICS.AGENT_PREDICT_FAILURE(VARCHAR, VARCHAR, FLOAT) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION ITRON_DB.ANALYTICS.AGENT_FORECAST_EMISSIONS(VARCHAR, NUMBER) TO ROLE PUBLIC;

-- Create the Itron Intelligence Agent
CREATE OR REPLACE AGENT ITRON_DB.ANALYTICS.ITRON_AGENT
  COMMENT = 'Itron Intelligence Agent - ESG and Operations Natural Language Query Tool with ESGOnt Ontology Integration'
  PROFILE = '{"display_name": "Itron Intelligence Assistant", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 360
      tokens: 32000

  instructions:
    response: "You are the Itron Intelligence Assistant, a data-driven AI that helps users explore Itron's operational performance and ESG (Environmental, Social, Governance) metrics. You integrate the ESGOnt ontology as a deterministic rule system to validate all ESG classifications and SDG alignments. When answering questions: (1) Always include the ESG pillar classification and relevant SDG goal alignment. (2) Report emissions in tCO2e, energy in MWh/GWh, water in gallons or cubic meters. (3) Use the ontology validator to confirm metric classifications before responding. (4) Provide data-backed answers with specific numbers and trends. (5) When showing trends, include year-over-year changes and progress toward targets. (6) Reference Itron's 2019 baseline for emissions comparisons. (7) Explain the significance of metrics in the context of utility operations and sustainability."
    orchestration: "Route questions as follows: (1) For questions about meters, consumption, sensor data, grid assets, work orders, maintenance, outages, reliability, or customers, use ItronOperationsAnalyst. (2) For questions about emissions, carbon, energy efficiency, water conservation, ESG metrics, sustainability, workforce, safety, governance, board diversity, compliance, or SDG progress, use ItronESGAnalyst. (3) For questions about policies, reports, strategies, or qualitative ESG information, use ESGSearch. (4) ALWAYS call OntologyValidator when the question involves ESG metric classification, SDG alignment, or reporting standards to ensure deterministic accuracy. (5) For predictions about future demand, use PredictDemand. (6) For leak detection or consumption anomalies, use DetectAnomalies. (7) For equipment health and failure risk, use PredictEquipmentFailure. (8) For emissions projections, use ForecastEmissions. (9) Use data_to_chart to visualize trends, comparisons, and distributions."
    sample_questions:
      - question: "What was our total GHG emissions reduction compared to our 2019 baseline?"
      - question: "Which water meters are showing anomalous consumption patterns this month?"
      - question: "How does our carbon intensity align with SDG 13 targets?"
      - question: "Predict energy demand for the Northwest region over the next 30 days."
      - question: "What is our current grid reliability SAIDI score by region?"
      - question: "Show me the trend in Scope 1 and Scope 2 emissions over the past 3 years."
      - question: "Which assets have the highest failure probability and need replacement?"
      - question: "What percentage of our workforce are women in leadership positions?"
      - question: "How much non-revenue water are we saving through smart meter deployment?"
      - question: "What is our board independence percentage and how does it compare to governance targets?"

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ItronOperationsAnalyst"
        description: "Queries operational data including smart meter readings (electric, water, gas), IoT sensor events, grid asset health, work orders, maintenance records, outage events, and customer accounts. Use for questions about consumption patterns, demand, reliability, field operations, and infrastructure."

    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ItronESGAnalyst"
        description: "Queries ESG performance data across all three pillars: Environmental (GHG emissions by scope, energy consumption, renewable energy, water usage, waste management), Social (workforce diversity, safety TRIR, training, community investment), and Governance (board composition, compliance, ethics). Also covers SDG progress tracking, carbon emissions detail, water conservation metrics, and energy efficiency data."

    - tool_spec:
        type: "cortex_search"
        name: "ESGSearch"
        description: "Searches Itron's ESG document corpus including sustainability reports, climate transition plans, policies, case studies, and frameworks. Use for qualitative information about strategies, commitments, standards, and context that cannot be answered with numeric data alone."

    - tool_spec:
        type: "generic"
        name: "OntologyValidator"
        description: "Validates ESG metric classifications against the ESGOnt ontology. Returns the correct ESG pillar, category, SDG alignment, standard unit of measurement, and applicable validation rules for any metric name. Use this tool to ensure deterministic accuracy when classifying or reporting ESG metrics. Input: metric name string."
        input_schema:
          type: "object"
          properties:
            metric_name:
              type: "string"
              description: "The name of the ESG metric to validate (e.g., 'Scope 1 GHG Emissions', 'Non-Revenue Water')"
          required:
            - metric_name

    - tool_spec:
        type: "generic"
        name: "PredictDemand"
        description: "Forecasts energy demand for specified meters or regions. Returns predicted daily kWh values with confidence intervals for a given time horizon. Input: optional meter_id, optional region, and horizon in days."
        input_schema:
          type: "object"
          properties:
            meter_id:
              type: "string"
              description: "Specific meter ID to forecast (optional, omit for regional/global forecast)"
            region:
              type: "string"
              description: "Region to forecast (NORTHWEST, SOUTHWEST, MIDWEST, NORTHEAST, SOUTHEAST)"
            horizon_days:
              type: "number"
              description: "Number of days to forecast (default 7, max 30)"

    - tool_spec:
        type: "generic"
        name: "DetectAnomalies"
        description: "Identifies meters with anomalous consumption patterns including potential leaks, tamper events, communication failures, and unusual usage. Returns top anomalies ranked by severity with recommended actions."
        input_schema:
          type: "object"
          properties:
            meter_type:
              type: "string"
              description: "Filter by meter type: ELECTRIC, WATER, or GAS (optional)"
            region:
              type: "string"
              description: "Filter by region (optional)"
            lookback_days:
              type: "number"
              description: "Number of days to analyze for anomalies (default 7)"

    - tool_spec:
        type: "generic"
        name: "PredictEquipmentFailure"
        description: "Returns failure probability scores for grid and water infrastructure assets based on age, condition, maintenance history, and inspection status. Identifies assets at highest risk of failure."
        input_schema:
          type: "object"
          properties:
            asset_type:
              type: "string"
              description: "Filter by asset type: TRANSFORMER, SUBSTATION, PIPE_SEGMENT, VALVE, PUMP_STATION, REGULATOR"
            region:
              type: "string"
              description: "Filter by region (optional)"
            risk_threshold:
              type: "number"
              description: "Minimum failure probability to include (0.0-1.0, default 0.5)"

    - tool_spec:
        type: "generic"
        name: "ForecastEmissions"
        description: "Projects future carbon emissions based on historical trends and Itron's science-based targets. Returns quarterly forecasts with reduction trajectories and on-track status for 2035 and 2050 targets."
        input_schema:
          type: "object"
          properties:
            scope:
              type: "string"
              description: "GHG scope to forecast: SCOPE_1, SCOPE_2, or SCOPE_3 (optional, all scopes if omitted)"
            forecast_quarters:
              type: "number"
              description: "Number of quarters to forecast (default 4, max 12)"

    - tool_spec:
        type: "data_to_chart"
        name: "data_to_chart"
        description: "Generates visualizations from query results including line charts for trends, bar charts for comparisons, and pie charts for distributions."

  tool_resources:
    ItronOperationsAnalyst:
      semantic_view: "ITRON_DB.ANALYTICS.ITRON_OPERATIONS_SV"
      execution_environment:
        type: "warehouse"
        warehouse: "ITRON_WH"

    ItronESGAnalyst:
      semantic_view: "ITRON_DB.ANALYTICS.ITRON_ESG_SV"
      execution_environment:
        type: "warehouse"
        warehouse: "ITRON_WH"

    ESGSearch:
      name: "ITRON_DB.ANALYTICS.ESG_SEARCH_SERVICE"
      max_results: "10"
      title_column: "TITLE"
      id_column: "DOCUMENT_ID"
      columns_and_descriptions:
        CONTENT:
          description: "Full text content of ESG documents including sustainability reports, policies, and case studies"
          type: "string"
          searchable: true
          filterable: false
        DOCUMENT_TYPE:
          description: "Type of document. Values: SUSTAINABILITY_REPORT, POLICY, FRAMEWORK, PRESS_RELEASE, CASE_STUDY"
          type: "string"
          searchable: false
          filterable: true
        ESG_PILLAR:
          description: "ESG pillar the document relates to. Values: ENVIRONMENTAL, SOCIAL, GOVERNANCE, ALL"
          type: "string"
          searchable: false
          filterable: true
        SDG_GOAL:
          description: "Related UN SDG goal numbers as comma-separated string"
          type: "string"
          searchable: false
          filterable: true
        YEAR:
          description: "Publication year of the document"
          type: "string"
          searchable: false
          filterable: true

    OntologyValidator:
      type: "function"
      identifier: "ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC"
      execution_environment:
        type: "warehouse"
        warehouse: "ITRON_WH"

    PredictDemand:
      type: "function"
      identifier: "ITRON_DB.ANALYTICS.AGENT_PREDICT_DEMAND"
      execution_environment:
        type: "warehouse"
        warehouse: "ITRON_WH"

    DetectAnomalies:
      type: "function"
      identifier: "ITRON_DB.ANALYTICS.AGENT_DETECT_ANOMALIES"
      execution_environment:
        type: "warehouse"
        warehouse: "ITRON_WH"

    PredictEquipmentFailure:
      type: "function"
      identifier: "ITRON_DB.ANALYTICS.AGENT_PREDICT_FAILURE"
      execution_environment:
        type: "warehouse"
        warehouse: "ITRON_WH"

    ForecastEmissions:
      type: "function"
      identifier: "ITRON_DB.ANALYTICS.AGENT_FORECAST_EMISSIONS"
      execution_environment:
        type: "warehouse"
        warehouse: "ITRON_WH"
  $$;

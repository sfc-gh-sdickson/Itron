-- ============================================================================
-- ITRON INTELLIGENCE AGENT - ESGOnt Ontology Loading
-- File: sql/setup/03_ESGOnt_Ontology.sql
-- Description: Loads the ESGOnt OWL ontology into relational tables
--              establishing deterministic rules for LLM constraint validation
-- Source: https://github.com/ESGOnt/esgontology (CC0-1.0 License)
-- Reference: https://www.sciencedirect.com/science/article/pii/S266691612500074X
-- ============================================================================

USE DATABASE ITRON_DB;
USE WAREHOUSE ITRON_WH;
USE SCHEMA ITRON_DB.ONTOLOGY;

-- ============================================================================
-- SECTION 1: Load ESGOnt OWL Classes into ONTOLOGY_CLASSES
-- These represent the core taxonomy from the ontology
-- ============================================================================

-- Root-level abstract classes
INSERT INTO ONTOLOGY_CLASSES (CLASS_ID, CLASS_NAME, CLASS_URI, PARENT_CLASS_ID, ESG_PILLAR, HIERARCHY_LEVEL, DESCRIPTION) VALUES
('CLS_CATEGORY', 'Category', 'http://www.annasvijaya.com/ESGOnt/esgontology#Category', NULL, NULL, 0, 'Top-level ESG category classification'),
('CLS_ACTION', 'Action', 'http://www.annasvijaya.com/ESGOnt/esgontology#Action', NULL, NULL, 0, 'Actions that can be taken to improve ESG performance'),
('CLS_METRIC', 'Metric', 'http://www.annasvijaya.com/ESGOnt/esgontology#Metric', NULL, NULL, 0, 'Measurable ESG indicators'),
('CLS_ASSESSMENT', 'Assessment', 'http://www.annasvijaya.com/ESGOnt/esgontology#Assessment', NULL, NULL, 0, 'ESG assessment and evaluation'),
('CLS_ASSESSMENT_NODE', 'AssessmentNode', 'http://www.annasvijaya.com/ESGOnt/esgontology#AssessmentNode', 'CLS_ASSESSMENT', NULL, 1, 'Node in an assessment hierarchy'),
('CLS_CALCULATED_VALUE', 'CalculatedValue', 'http://www.annasvijaya.com/ESGOnt/esgontology#CalculatedValue', 'CLS_ASSESSMENT', NULL, 1, 'Calculated assessment value'),
('CLS_SDG', 'SDG', 'http://www.annasvijaya.com/ESGOnt/esgontology#SDG', NULL, NULL, 0, 'UN Sustainable Development Goal'),
('CLS_TARGET', 'Target', 'http://www.annasvijaya.com/ESGOnt/esgontology#Target', NULL, NULL, 0, 'SDG or ESG target'),
('CLS_INDICATOR', 'Indicator', 'http://www.annasvijaya.com/ESGOnt/esgontology#Indicator', NULL, NULL, 0, 'Measurable indicator for tracking progress');

-- Environmental Category Classes
INSERT INTO ONTOLOGY_CLASSES (CLASS_ID, CLASS_NAME, CLASS_URI, PARENT_CLASS_ID, ESG_PILLAR, HIERARCHY_LEVEL, DESCRIPTION) VALUES
('CLS_ENERGY', 'Energy', 'http://www.annasvijaya.com/ESGOnt/esgontology#Energy', 'CLS_CATEGORY', 'ENVIRONMENTAL', 1, 'Energy consumption, efficiency, and renewable energy'),
('CLS_WATER', 'Water', 'http://www.annasvijaya.com/ESGOnt/esgontology#Water', 'CLS_CATEGORY', 'ENVIRONMENTAL', 1, 'Water usage, conservation, and management'),
('CLS_EMISSIONS', 'Emissions', 'http://www.annasvijaya.com/ESGOnt/esgontology#Emissions', 'CLS_CATEGORY', 'ENVIRONMENTAL', 1, 'Greenhouse gas and pollutant emissions'),
('CLS_WASTE', 'Waste', 'http://www.annasvijaya.com/ESGOnt/esgontology#Waste', 'CLS_CATEGORY', 'ENVIRONMENTAL', 1, 'Waste generation, processing, and reduction'),
('CLS_BIODIVERSITY', 'Biodiversity', 'http://www.annasvijaya.com/ESGOnt/esgontology#Biodiversity', 'CLS_CATEGORY', 'ENVIRONMENTAL', 1, 'Biodiversity impact and preservation'),
('CLS_CARBON_EMISSIONS', 'CarbonEmissions', 'http://www.annasvijaya.com/ESGOnt/esgontology#CarbonEmissions', 'CLS_EMISSIONS', 'ENVIRONMENTAL', 2, 'Carbon dioxide and equivalent emissions'),
('CLS_RENEWABLE_ENERGY', 'RenewableEnergy', 'http://www.annasvijaya.com/ESGOnt/esgontology#RenewableEnergy', 'CLS_ENERGY', 'ENVIRONMENTAL', 2, 'Energy from renewable sources'),
('CLS_ENERGY_CONSUMPTION', 'EnergyConsumption', 'http://www.annasvijaya.com/ESGOnt/esgontology#EnergyConsumption', 'CLS_ENERGY', 'ENVIRONMENTAL', 2, 'Total energy consumed by operations'),
('CLS_WATER_USAGE', 'WaterUsage', 'http://www.annasvijaya.com/ESGOnt/esgontology#WaterUsage', 'CLS_WATER', 'ENVIRONMENTAL', 2, 'Volume of water consumed'),
('CLS_WATER_EFFICIENCY', 'WaterEfficiency', 'http://www.annasvijaya.com/ESGOnt/esgontology#WaterEfficiency', 'CLS_WATER', 'ENVIRONMENTAL', 2, 'Water use efficiency improvements'),
('CLS_WATER_RECYCLING', 'WaterRecycling', 'http://www.annasvijaya.com/ESGOnt/esgontology#WaterRecycling', 'CLS_WATER', 'ENVIRONMENTAL', 2, 'Water recycling and reuse'),
('CLS_WASTE_OUTPUT', 'WasteOutput', 'http://www.annasvijaya.com/ESGOnt/esgontology#WasteOutput', 'CLS_WASTE', 'ENVIRONMENTAL', 2, 'Total waste generated'),
('CLS_WASTE_PROCESSING', 'WasteProcessing', 'http://www.annasvijaya.com/ESGOnt/esgontology#WasteProcessing', 'CLS_WASTE', 'ENVIRONMENTAL', 2, 'Waste treatment and processing methods'),
('CLS_WASTE_REDUCTION', 'WasteReduction', 'http://www.annasvijaya.com/ESGOnt/esgontology#WasteReduction', 'CLS_WASTE', 'ENVIRONMENTAL', 2, 'Actions to reduce waste generation'),
('CLS_WASTE_RECYCLING', 'WasteRecycling', 'http://www.annasvijaya.com/ESGOnt/esgontology#WasteRecycling', 'CLS_WASTE', 'ENVIRONMENTAL', 2, 'Waste recycling and recovery');

-- Social Category Classes
INSERT INTO ONTOLOGY_CLASSES (CLASS_ID, CLASS_NAME, CLASS_URI, PARENT_CLASS_ID, ESG_PILLAR, HIERARCHY_LEVEL, DESCRIPTION) VALUES
('CLS_WORKFORCE', 'Workforce', 'http://www.annasvijaya.com/ESGOnt/esgontology#Workforce', 'CLS_CATEGORY', 'SOCIAL', 1, 'Employee-related metrics and management'),
('CLS_COMMUNITY', 'Community', 'http://www.annasvijaya.com/ESGOnt/esgontology#Community', 'CLS_CATEGORY', 'SOCIAL', 1, 'Community engagement and impact'),
('CLS_SUPPLY_CHAIN', 'SupplyChain', 'http://www.annasvijaya.com/ESGOnt/esgontology#SupplyChain', 'CLS_CATEGORY', 'SOCIAL', 1, 'Supply chain responsibility and management'),
('CLS_CUSTOMER_PRIVACY', 'CustomerPrivacy', 'http://www.annasvijaya.com/ESGOnt/esgontology#CustomerPrivacy', 'CLS_CATEGORY', 'SOCIAL', 1, 'Customer data privacy and protection'),
('CLS_HEALTH_SAFETY', 'HealthAndSafety', 'http://www.annasvijaya.com/ESGOnt/esgontology#HealthAndSafety', 'CLS_WORKFORCE', 'SOCIAL', 2, 'Occupational health and safety'),
('CLS_DIVERSITY_INCLUSION', 'DiversityAndInclusion', 'http://www.annasvijaya.com/ESGOnt/esgontology#DiversityAndInclusion', 'CLS_WORKFORCE', 'SOCIAL', 2, 'Workforce diversity and inclusion efforts'),
('CLS_TRAINING_DEVELOPMENT', 'TrainingAndDevelopment', 'http://www.annasvijaya.com/ESGOnt/esgontology#TrainingAndDevelopment', 'CLS_WORKFORCE', 'SOCIAL', 2, 'Employee training and professional development'),
('CLS_LABOR_PRACTICES', 'LaborPractices', 'http://www.annasvijaya.com/ESGOnt/esgontology#LaborPractices', 'CLS_WORKFORCE', 'SOCIAL', 2, 'Fair labor practices and worker rights');

-- Governance Category Classes
INSERT INTO ONTOLOGY_CLASSES (CLASS_ID, CLASS_NAME, CLASS_URI, PARENT_CLASS_ID, ESG_PILLAR, HIERARCHY_LEVEL, DESCRIPTION) VALUES
('CLS_COMPLIANCE', 'Compliance', 'http://www.annasvijaya.com/ESGOnt/esgontology#Compliance', 'CLS_CATEGORY', 'GOVERNANCE', 1, 'Regulatory and legal compliance'),
('CLS_ETHICS', 'Ethics', 'http://www.annasvijaya.com/ESGOnt/esgontology#Ethics', 'CLS_CATEGORY', 'GOVERNANCE', 1, 'Business ethics and conduct'),
('CLS_BOARD_DIVERSITY', 'BoardDiversity', 'http://www.annasvijaya.com/ESGOnt/esgontology#BoardDiversity', 'CLS_CATEGORY', 'GOVERNANCE', 1, 'Board composition and diversity'),
('CLS_RISK_MANAGEMENT', 'RiskManagement', 'http://www.annasvijaya.com/ESGOnt/esgontology#RiskManagement', 'CLS_CATEGORY', 'GOVERNANCE', 1, 'Enterprise risk management including ESG risks'),
('CLS_TRANSPARENCY', 'Transparency', 'http://www.annasvijaya.com/ESGOnt/esgontology#Transparency', 'CLS_CATEGORY', 'GOVERNANCE', 1, 'Reporting transparency and disclosure'),
('CLS_ANTI_CORRUPTION', 'AntiCorruption', 'http://www.annasvijaya.com/ESGOnt/esgontology#AntiCorruption', 'CLS_ETHICS', 'GOVERNANCE', 2, 'Anti-corruption and anti-bribery measures'),
('CLS_DATA_SECURITY', 'DataSecurity', 'http://www.annasvijaya.com/ESGOnt/esgontology#DataSecurity', 'CLS_COMPLIANCE', 'GOVERNANCE', 2, 'Information security and data governance'),
('CLS_STAKEHOLDER_ENGAGEMENT', 'StakeholderEngagement', 'http://www.annasvijaya.com/ESGOnt/esgontology#StakeholderEngagement', 'CLS_TRANSPARENCY', 'GOVERNANCE', 2, 'Engagement with stakeholders on ESG matters');

-- ============================================================================
-- SECTION 2: Load Object Properties
-- ============================================================================

INSERT INTO ONTOLOGY_PROPERTIES (PROPERTY_ID, PROPERTY_NAME, PROPERTY_URI, PROPERTY_TYPE, DOMAIN_CLASS_ID, RANGE_CLASS_ID, DESCRIPTION) VALUES
('PROP_BELONGS_TO_CATEGORY', 'belongsToCategory', 'http://www.annasvijaya.com/ESGOnt/esgontology#belongsToCategory', 'OBJECT', 'CLS_METRIC', 'CLS_CATEGORY', 'Links a metric to its ESG category'),
('PROP_HAS_INDICATOR', 'hasIndicator', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasIndicator', 'OBJECT', 'CLS_TARGET', 'CLS_INDICATOR', 'Links a target to its measurable indicator'),
('PROP_HAS_TARGET', 'hasTarget', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasTarget', 'OBJECT', 'CLS_SDG', 'CLS_TARGET', 'Links an SDG goal to its specific targets'),
('PROP_ASSOCIATES_WITH', 'associatesWith', 'http://www.annasvijaya.com/ESGOnt/esgontology#associatesWith', 'OBJECT', NULL, NULL, 'General association between ontology entities'),
('PROP_HAS_METRIC', 'hasMetric', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasMetric', 'OBJECT', 'CLS_CATEGORY', 'CLS_METRIC', 'Links a category to its metrics'),
('PROP_HAS_ASSESSMENT_VALUE', 'hasAssessmentValue', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasAssessmentValue', 'OBJECT', 'CLS_ASSESSMENT_NODE', 'CLS_CALCULATED_VALUE', 'Links assessment node to its calculated value'),
('PROP_CONTRIBUTES_TO', 'contributesTo', 'http://www.annasvijaya.com/ESGOnt/esgontology#contributesTo', 'OBJECT', 'CLS_ACTION', 'CLS_SDG', 'Links an action to the SDG it supports'),
('PROP_MEASURED_BY', 'measuredBy', 'http://www.annasvijaya.com/ESGOnt/esgontology#measuredBy', 'OBJECT', 'CLS_CATEGORY', 'CLS_INDICATOR', 'Links a category to how it is measured'),
('PROP_IMPACTS_SDG', 'impactsSDG', 'http://www.annasvijaya.com/ESGOnt/esgontology#impactsSDG', 'OBJECT', 'CLS_METRIC', 'CLS_SDG', 'Links a metric to the SDG goals it impacts'),
('PROP_HAS_SCOPE', 'hasScope', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasScope', 'DATA', 'CLS_CARBON_EMISSIONS', NULL, 'Specifies emission scope (1, 2, or 3)'),
('PROP_HAS_UNIT', 'hasUnit', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasUnit', 'DATA', 'CLS_METRIC', NULL, 'Specifies the unit of measurement for a metric'),
('PROP_HAS_VALUE', 'hasValue', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasValue', 'DATA', 'CLS_INDICATOR', NULL, 'The numerical value of an indicator'),
('PROP_HAS_FRAMEWORK', 'hasFramework', 'http://www.annasvijaya.com/ESGOnt/esgontology#hasFramework', 'DATA', 'CLS_METRIC', NULL, 'Links to reporting framework (GRI, ESRS, etc.)');

-- ============================================================================
-- SECTION 3: Load Class Relationships (subClassOf hierarchy)
-- ============================================================================

INSERT INTO ONTOLOGY_RELATIONSHIPS (RELATIONSHIP_ID, SOURCE_CLASS_ID, TARGET_CLASS_ID, RELATIONSHIP_TYPE, PROPERTY_ID, DESCRIPTION) VALUES
-- Environmental hierarchy
('REL_ENERGY_CAT', 'CLS_ENERGY', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Energy is a subcategory of ESG Category'),
('REL_WATER_CAT', 'CLS_WATER', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Water is a subcategory of ESG Category'),
('REL_EMISSIONS_CAT', 'CLS_EMISSIONS', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Emissions is a subcategory of ESG Category'),
('REL_WASTE_CAT', 'CLS_WASTE', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Waste is a subcategory of ESG Category'),
('REL_BIODIVERSITY_CAT', 'CLS_BIODIVERSITY', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Biodiversity is a subcategory of ESG Category'),
('REL_CARBON_EMISSIONS', 'CLS_CARBON_EMISSIONS', 'CLS_EMISSIONS', 'SUBCLASS_OF', NULL, 'Carbon Emissions is a type of Emissions'),
('REL_RENEWABLE_ENERGY', 'CLS_RENEWABLE_ENERGY', 'CLS_ENERGY', 'SUBCLASS_OF', NULL, 'Renewable Energy is a type of Energy'),
('REL_ENERGY_CONSUMPTION', 'CLS_ENERGY_CONSUMPTION', 'CLS_ENERGY', 'SUBCLASS_OF', NULL, 'Energy Consumption is a type of Energy metric'),
('REL_WATER_USAGE', 'CLS_WATER_USAGE', 'CLS_WATER', 'SUBCLASS_OF', NULL, 'Water Usage is a type of Water metric'),
('REL_WATER_EFFICIENCY', 'CLS_WATER_EFFICIENCY', 'CLS_WATER', 'SUBCLASS_OF', NULL, 'Water Efficiency is a type of Water metric'),
('REL_WATER_RECYCLING', 'CLS_WATER_RECYCLING', 'CLS_WATER', 'SUBCLASS_OF', NULL, 'Water Recycling is a type of Water metric'),
('REL_WASTE_OUTPUT', 'CLS_WASTE_OUTPUT', 'CLS_WASTE', 'SUBCLASS_OF', NULL, 'Waste Output is a type of Waste metric'),
('REL_WASTE_REDUCTION_ACT', 'CLS_WASTE_REDUCTION', 'CLS_ACTION', 'SUBCLASS_OF', NULL, 'Waste Reduction is an Action'),
('REL_WASTE_RECYCLING_ACT', 'CLS_WASTE_RECYCLING', 'CLS_ACTION', 'SUBCLASS_OF', NULL, 'Waste Recycling is an Action'),
('REL_WATER_EFFICIENCY_ACT', 'CLS_WATER_EFFICIENCY', 'CLS_ACTION', 'SUBCLASS_OF', NULL, 'Water Efficiency is an Action'),
('REL_WATER_RECYCLING_ACT', 'CLS_WATER_RECYCLING', 'CLS_ACTION', 'SUBCLASS_OF', NULL, 'Water Recycling is an Action'),
-- Social hierarchy
('REL_WORKFORCE_CAT', 'CLS_WORKFORCE', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Workforce is a subcategory of ESG Category'),
('REL_COMMUNITY_CAT', 'CLS_COMMUNITY', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Community is a subcategory of ESG Category'),
('REL_SUPPLY_CHAIN_CAT', 'CLS_SUPPLY_CHAIN', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Supply Chain is a subcategory of ESG Category'),
('REL_CUSTOMER_PRIVACY_CAT', 'CLS_CUSTOMER_PRIVACY', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Customer Privacy is a subcategory of ESG Category'),
('REL_HEALTH_SAFETY', 'CLS_HEALTH_SAFETY', 'CLS_WORKFORCE', 'SUBCLASS_OF', NULL, 'Health and Safety is a type of Workforce metric'),
('REL_DIVERSITY', 'CLS_DIVERSITY_INCLUSION', 'CLS_WORKFORCE', 'SUBCLASS_OF', NULL, 'Diversity and Inclusion is a type of Workforce metric'),
('REL_TRAINING', 'CLS_TRAINING_DEVELOPMENT', 'CLS_WORKFORCE', 'SUBCLASS_OF', NULL, 'Training is a type of Workforce metric'),
('REL_LABOR', 'CLS_LABOR_PRACTICES', 'CLS_WORKFORCE', 'SUBCLASS_OF', NULL, 'Labor Practices is a type of Workforce metric'),
-- Governance hierarchy
('REL_COMPLIANCE_CAT', 'CLS_COMPLIANCE', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Compliance is a subcategory of ESG Category'),
('REL_ETHICS_CAT', 'CLS_ETHICS', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Ethics is a subcategory of ESG Category'),
('REL_BOARD_CAT', 'CLS_BOARD_DIVERSITY', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Board Diversity is a subcategory of ESG Category'),
('REL_RISK_CAT', 'CLS_RISK_MANAGEMENT', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Risk Management is a subcategory of ESG Category'),
('REL_TRANSPARENCY_CAT', 'CLS_TRANSPARENCY', 'CLS_CATEGORY', 'SUBCLASS_OF', NULL, 'Transparency is a subcategory of ESG Category'),
('REL_ANTI_CORRUPTION', 'CLS_ANTI_CORRUPTION', 'CLS_ETHICS', 'SUBCLASS_OF', NULL, 'Anti-Corruption is a type of Ethics'),
('REL_DATA_SECURITY', 'CLS_DATA_SECURITY', 'CLS_COMPLIANCE', 'SUBCLASS_OF', NULL, 'Data Security is a type of Compliance'),
('REL_STAKEHOLDER', 'CLS_STAKEHOLDER_ENGAGEMENT', 'CLS_TRANSPARENCY', 'SUBCLASS_OF', NULL, 'Stakeholder Engagement is a type of Transparency');

-- ============================================================================
-- SECTION 4: Load SDG Mappings (Deterministic Rules)
-- These define which Itron metrics align with which SDG goals
-- ============================================================================

INSERT INTO ONTOLOGY_SDG_MAPPINGS (MAPPING_ID, ESG_METRIC_NAME, ESG_PILLAR, ESG_CATEGORY, SDG_GOAL_NUMBER, SDG_GOAL_NAME, SDG_TARGET, SDG_INDICATOR, MAPPING_STRENGTH, VALIDATION_RULE) VALUES
-- SDG 6: Clean Water and Sanitation
('MAP_001', 'Non-Revenue Water Percentage', 'ENVIRONMENTAL', 'WATER', 6, 'Clean Water and Sanitation', '6.4', '6.4.1', 'DIRECT', 'Water metrics with NRW must map to SDG 6'),
('MAP_002', 'Water Leaks Detected', 'ENVIRONMENTAL', 'WATER', 6, 'Clean Water and Sanitation', '6.4', '6.4.1', 'DIRECT', 'Leak detection metrics must map to SDG 6'),
('MAP_003', 'Smart Water Meters Deployed', 'ENVIRONMENTAL', 'WATER', 6, 'Clean Water and Sanitation', '6.b', '6.b.1', 'STRONG', 'Water meter deployment enables SDG 6 progress'),
('MAP_004', 'Water Saved (Gallons)', 'ENVIRONMENTAL', 'WATER', 6, 'Clean Water and Sanitation', '6.4', '6.4.1', 'DIRECT', 'Water conservation directly supports SDG 6'),
-- SDG 7: Affordable and Clean Energy
('MAP_005', 'Renewable Energy Percentage', 'ENVIRONMENTAL', 'ENERGY', 7, 'Affordable and Clean Energy', '7.2', '7.2.1', 'DIRECT', 'Renewable energy share must map to SDG 7.2'),
('MAP_006', 'Grid Loss Reduction (MWh)', 'ENVIRONMENTAL', 'ENERGY', 7, 'Affordable and Clean Energy', '7.3', '7.3.1', 'DIRECT', 'Energy efficiency from grid loss reduction maps to SDG 7.3'),
('MAP_007', 'DER Capacity Managed (MW)', 'ENVIRONMENTAL', 'ENERGY', 7, 'Affordable and Clean Energy', '7.2', '7.2.1', 'STRONG', 'DER management enables renewable integration'),
('MAP_008', 'Demand Response MW Dispatched', 'ENVIRONMENTAL', 'ENERGY', 7, 'Affordable and Clean Energy', '7.3', '7.3.1', 'STRONG', 'Demand response improves energy efficiency'),
('MAP_009', 'Energy Saved (MWh)', 'ENVIRONMENTAL', 'ENERGY', 7, 'Affordable and Clean Energy', '7.3', '7.3.1', 'DIRECT', 'Energy savings from efficiency programs'),
-- SDG 9: Industry, Innovation and Infrastructure
('MAP_010', 'Smart Endpoints Under Management', 'ENVIRONMENTAL', 'ENERGY', 9, 'Industry Innovation and Infrastructure', '9.4', '9.4.1', 'STRONG', 'Smart infrastructure deployment supports SDG 9'),
('MAP_011', 'Grid Reliability SAIDI', 'ENVIRONMENTAL', 'ENERGY', 9, 'Industry Innovation and Infrastructure', '9.1', '9.1.2', 'DIRECT', 'Grid reliability is infrastructure resilience'),
('MAP_012', 'DI-Enabled Meters Shipped', 'ENVIRONMENTAL', 'ENERGY', 9, 'Industry Innovation and Infrastructure', '9.4', '9.4.1', 'STRONG', 'Distributed Intelligence is infrastructure innovation'),
-- SDG 11: Sustainable Cities and Communities
('MAP_013', 'City Services Managed', 'SOCIAL', 'COMMUNITY', 11, 'Sustainable Cities and Communities', '11.6', '11.6.1', 'STRONG', 'Smart city services support sustainable urbanization'),
('MAP_014', 'Outage Duration Reduction (Minutes)', 'SOCIAL', 'COMMUNITY', 11, 'Sustainable Cities and Communities', '11.5', '11.5.1', 'MODERATE', 'Reduced outages improve community resilience'),
-- SDG 12: Responsible Consumption and Production
('MAP_015', 'Waste Diverted from Landfill (%)', 'ENVIRONMENTAL', 'WASTE', 12, 'Responsible Consumption and Production', '12.5', '12.5.1', 'DIRECT', 'Waste diversion maps to SDG 12.5'),
('MAP_016', 'E-Waste Recycled (Tons)', 'ENVIRONMENTAL', 'WASTE', 12, 'Responsible Consumption and Production', '12.4', '12.4.2', 'DIRECT', 'Electronic waste recycling maps to SDG 12.4'),
-- SDG 13: Climate Action
('MAP_017', 'Scope 1 GHG Emissions (tCO2e)', 'ENVIRONMENTAL', 'EMISSIONS', 13, 'Climate Action', '13.2', '13.2.2', 'DIRECT', 'Direct emissions must map to SDG 13'),
('MAP_018', 'Scope 2 GHG Emissions (tCO2e)', 'ENVIRONMENTAL', 'EMISSIONS', 13, 'Climate Action', '13.2', '13.2.2', 'DIRECT', 'Indirect energy emissions must map to SDG 13'),
('MAP_019', 'Scope 3 GHG Emissions (tCO2e)', 'ENVIRONMENTAL', 'EMISSIONS', 13, 'Climate Action', '13.2', '13.2.2', 'DIRECT', 'Value chain emissions must map to SDG 13'),
('MAP_020', 'Customer Avoided Emissions (tCO2e)', 'ENVIRONMENTAL', 'EMISSIONS', 13, 'Climate Action', '13.2', '13.2.2', 'DIRECT', 'Emissions avoided through Itron solutions'),
('MAP_021', 'Carbon Intensity (tCO2e/Revenue)', 'ENVIRONMENTAL', 'EMISSIONS', 13, 'Climate Action', '13.2', '13.2.2', 'DIRECT', 'Carbon intensity is a climate action metric'),
-- SDG 5: Gender Equality
('MAP_022', 'Women in Leadership (%)', 'SOCIAL', 'WORKFORCE', 5, 'Gender Equality', '5.5', '5.5.2', 'DIRECT', 'Gender diversity in leadership maps to SDG 5'),
('MAP_023', 'Gender Pay Gap Ratio', 'SOCIAL', 'WORKFORCE', 5, 'Gender Equality', '5.1', '5.1.1', 'DIRECT', 'Pay equity maps to SDG 5'),
-- SDG 8: Decent Work and Economic Growth
('MAP_024', 'Total Recordable Incident Rate', 'SOCIAL', 'WORKFORCE', 8, 'Decent Work and Economic Growth', '8.8', '8.8.1', 'DIRECT', 'Workplace safety maps to SDG 8.8'),
('MAP_025', 'Employee Training Hours', 'SOCIAL', 'WORKFORCE', 8, 'Decent Work and Economic Growth', '8.5', '8.5.1', 'MODERATE', 'Training investment supports decent work'),
('MAP_026', 'Voluntary Turnover Rate', 'SOCIAL', 'WORKFORCE', 8, 'Decent Work and Economic Growth', '8.5', '8.5.1', 'MODERATE', 'Employee retention indicates job quality'),
-- SDG 16: Peace, Justice and Strong Institutions
('MAP_027', 'Ethics Violations Reported', 'GOVERNANCE', 'ETHICS', 16, 'Peace Justice and Strong Institutions', '16.5', '16.5.1', 'DIRECT', 'Ethics reporting supports institutional integrity'),
('MAP_028', 'Board Independence Percentage', 'GOVERNANCE', 'BOARD_DIVERSITY', 16, 'Peace Justice and Strong Institutions', '16.6', '16.6.1', 'MODERATE', 'Board independence supports good governance'),
('MAP_029', 'Compliance Training Completion (%)', 'GOVERNANCE', 'COMPLIANCE', 16, 'Peace Justice and Strong Institutions', '16.6', '16.6.1', 'MODERATE', 'Compliance training supports rule of law');

-- ============================================================================
-- SECTION 5: Load Validation Rules (Deterministic Constraints for LLM)
-- ============================================================================

INSERT INTO ONTOLOGY_VALIDATION_RULES (RULE_ID, RULE_NAME, RULE_TYPE, RULE_CATEGORY, CONDITION_FIELD, EXPECTED_VALUE, ERROR_MESSAGE, SEVERITY, IS_ACTIVE) VALUES
-- Classification Rules: Ensure metrics are in the correct ESG pillar
('RULE_001', 'Emissions belong to Environmental', 'CLASSIFICATION', 'EMISSIONS', 'ESG_PILLAR', 'ENVIRONMENTAL', 'GHG emissions metrics must be classified under the ENVIRONMENTAL pillar', 'ERROR', TRUE),
('RULE_002', 'Workforce belongs to Social', 'CLASSIFICATION', 'WORKFORCE', 'ESG_PILLAR', 'SOCIAL', 'Workforce and employee metrics must be classified under the SOCIAL pillar', 'ERROR', TRUE),
('RULE_003', 'Board metrics belong to Governance', 'CLASSIFICATION', 'BOARD_DIVERSITY', 'ESG_PILLAR', 'GOVERNANCE', 'Board composition metrics must be classified under the GOVERNANCE pillar', 'ERROR', TRUE),
('RULE_004', 'Water metrics belong to Environmental', 'CLASSIFICATION', 'WATER', 'ESG_PILLAR', 'ENVIRONMENTAL', 'Water usage and conservation metrics must be classified under the ENVIRONMENTAL pillar', 'ERROR', TRUE),
('RULE_005', 'Energy metrics belong to Environmental', 'CLASSIFICATION', 'ENERGY', 'ESG_PILLAR', 'ENVIRONMENTAL', 'Energy consumption and efficiency metrics must be classified under the ENVIRONMENTAL pillar', 'ERROR', TRUE),
('RULE_006', 'Compliance belongs to Governance', 'CLASSIFICATION', 'COMPLIANCE', 'ESG_PILLAR', 'GOVERNANCE', 'Compliance and regulatory metrics must be classified under the GOVERNANCE pillar', 'ERROR', TRUE),
('RULE_007', 'Community belongs to Social', 'CLASSIFICATION', 'COMMUNITY', 'ESG_PILLAR', 'SOCIAL', 'Community engagement metrics must be classified under the SOCIAL pillar', 'ERROR', TRUE),
-- Unit Validation Rules: Ensure correct units of measurement
('RULE_010', 'Emissions must use tCO2e', 'UNIT', 'EMISSIONS', 'METRIC_UNIT', 'tCO2e OR METRIC_TONS_CO2E', 'GHG emissions must be reported in metric tons of CO2 equivalent (tCO2e)', 'ERROR', TRUE),
('RULE_011', 'Energy must use MWh or GWh', 'UNIT', 'ENERGY', 'METRIC_UNIT', 'MWH OR GWH OR KWH', 'Energy metrics must be reported in MWh, GWh, or kWh', 'ERROR', TRUE),
('RULE_012', 'Water must use gallons or cubic meters', 'UNIT', 'WATER', 'METRIC_UNIT', 'GALLONS OR CUBIC_METERS OR LITERS', 'Water metrics must be reported in gallons, cubic meters, or liters', 'ERROR', TRUE),
('RULE_013', 'Waste must use tons or kg', 'UNIT', 'WASTE', 'METRIC_UNIT', 'METRIC_TONS OR KG OR TONS', 'Waste metrics must be reported in metric tons or kilograms', 'ERROR', TRUE),
('RULE_014', 'Percentages must be 0-100', 'UNIT', 'ALL', 'METRIC_UNIT', 'PERCENTAGE WHERE VALUE BETWEEN 0 AND 100', 'Percentage metrics must have values between 0 and 100', 'ERROR', TRUE),
-- SDG Alignment Rules: Ensure correct SDG mapping
('RULE_020', 'Water metrics map to SDG 6', 'SDG_ALIGNMENT', 'WATER', 'SDG_GOAL_NUMBER', '6', 'Water-related metrics must be aligned with SDG 6 (Clean Water and Sanitation)', 'ERROR', TRUE),
('RULE_021', 'Energy metrics map to SDG 7', 'SDG_ALIGNMENT', 'ENERGY', 'SDG_GOAL_NUMBER', '7', 'Energy-related metrics must be aligned with SDG 7 (Affordable and Clean Energy)', 'ERROR', TRUE),
('RULE_022', 'Emissions metrics map to SDG 13', 'SDG_ALIGNMENT', 'EMISSIONS', 'SDG_GOAL_NUMBER', '13', 'Emissions metrics must be aligned with SDG 13 (Climate Action)', 'ERROR', TRUE),
('RULE_023', 'Waste metrics map to SDG 12', 'SDG_ALIGNMENT', 'WASTE', 'SDG_GOAL_NUMBER', '12', 'Waste metrics must be aligned with SDG 12 (Responsible Consumption)', 'ERROR', TRUE),
('RULE_024', 'Safety metrics map to SDG 8', 'SDG_ALIGNMENT', 'WORKFORCE', 'SDG_GOAL_NUMBER', '8', 'Workplace safety metrics must be aligned with SDG 8 (Decent Work)', 'WARNING', TRUE),
-- Hierarchy Rules: Ensure proper categorization depth
('RULE_030', 'Scope 1 is direct emissions', 'HIERARCHY', 'EMISSIONS', 'SCOPE', 'SCOPE_1 = STATIONARY_COMBUSTION OR MOBILE OR FUGITIVE', 'Scope 1 emissions must be from direct sources (combustion, mobile, fugitive)', 'ERROR', TRUE),
('RULE_031', 'Scope 2 is purchased energy', 'HIERARCHY', 'EMISSIONS', 'SCOPE', 'SCOPE_2 = PURCHASED_ELECTRICITY OR PURCHASED_HEAT', 'Scope 2 emissions must be from purchased electricity or heat', 'ERROR', TRUE),
('RULE_032', 'Scope 3 is value chain', 'HIERARCHY', 'EMISSIONS', 'SCOPE', 'SCOPE_3 = SUPPLY_CHAIN OR TRAVEL OR COMMUTING OR USE_OF_PRODUCTS', 'Scope 3 emissions must be from value chain activities', 'ERROR', TRUE),
-- Threshold Rules: Sanity checks on values
('RULE_040', 'TRIR must be non-negative', 'THRESHOLD', 'WORKFORCE', 'TOTAL_RECORDABLE_INCIDENT_RATE', 'VALUE >= 0', 'Total Recordable Incident Rate cannot be negative', 'ERROR', TRUE),
('RULE_041', 'Emissions reduction from baseline cannot exceed 100%', 'THRESHOLD', 'EMISSIONS', 'REDUCTION_FROM_BASELINE_PCT', 'VALUE <= 100', 'Emissions reduction from baseline cannot exceed 100%', 'ERROR', TRUE),
('RULE_042', 'Board size must be positive', 'THRESHOLD', 'BOARD_DIVERSITY', 'BOARD_SIZE', 'VALUE > 0 AND VALUE < 50', 'Board size must be a positive number less than 50', 'ERROR', TRUE);

-- ============================================================================
-- SECTION 6: Load Metric Definitions (Standard Reference)
-- ============================================================================

INSERT INTO ONTOLOGY_METRIC_DEFINITIONS (DEFINITION_ID, METRIC_NAME, METRIC_DESCRIPTION, ESG_PILLAR, ESG_CATEGORY, ESG_SUBCATEGORY, STANDARD_UNIT, CALCULATION_FORMULA, REPORTING_FRAMEWORK, FRAMEWORK_INDICATOR_ID, DATA_TYPE, FREQUENCY) VALUES
-- Environmental Metrics
('DEF_001', 'Scope 1 GHG Emissions', 'Direct greenhouse gas emissions from owned or controlled sources', 'ENVIRONMENTAL', 'EMISSIONS', 'CARBON_EMISSIONS', 'tCO2e', 'SUM(direct_fuel_combustion + fugitive_emissions + mobile_emissions)', 'GRI', 'GRI 305-1', 'QUANTITATIVE', 'ANNUAL'),
('DEF_002', 'Scope 2 GHG Emissions', 'Indirect emissions from purchased electricity, steam, heating and cooling', 'ENVIRONMENTAL', 'EMISSIONS', 'CARBON_EMISSIONS', 'tCO2e', 'SUM(purchased_electricity_kwh * grid_emission_factor)', 'GRI', 'GRI 305-2', 'QUANTITATIVE', 'ANNUAL'),
('DEF_003', 'Scope 3 GHG Emissions', 'All other indirect emissions in the value chain', 'ENVIRONMENTAL', 'EMISSIONS', 'CARBON_EMISSIONS', 'tCO2e', 'SUM(upstream_emissions + downstream_emissions)', 'GRI', 'GRI 305-3', 'QUANTITATIVE', 'ANNUAL'),
('DEF_004', 'Customer Avoided Emissions', 'GHG emissions avoided by customers using Itron solutions', 'ENVIRONMENTAL', 'EMISSIONS', 'CARBON_EMISSIONS', 'tCO2e', 'SUM(baseline_consumption - actual_consumption) * emission_factor', 'CDP', 'C-SC2.1', 'QUANTITATIVE', 'ANNUAL'),
('DEF_005', 'Total Energy Consumption', 'Total energy consumed within the organization', 'ENVIRONMENTAL', 'ENERGY', 'ENERGY_CONSUMPTION', 'MWH', 'SUM(electricity + natural_gas + diesel + other_fuels)', 'GRI', 'GRI 302-1', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_006', 'Renewable Energy Percentage', 'Percentage of total energy from renewable sources', 'ENVIRONMENTAL', 'ENERGY', 'RENEWABLE_ENERGY', 'PERCENTAGE', '(renewable_energy_mwh / total_energy_mwh) * 100', 'GRI', 'GRI 302-1', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_007', 'Total Water Withdrawal', 'Total volume of water withdrawn from all sources', 'ENVIRONMENTAL', 'WATER', 'WATER_USAGE', 'CUBIC_METERS', 'SUM(municipal_supply + groundwater + surface_water)', 'GRI', 'GRI 303-3', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_008', 'Non-Revenue Water', 'Water that is produced but not billed to customers', 'ENVIRONMENTAL', 'WATER', 'WATER_USAGE', 'PERCENTAGE', '(total_water_produced - total_water_billed) / total_water_produced * 100', 'IWA', 'NRW', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_009', 'Waste Diverted from Landfill', 'Percentage of waste diverted through recycling or reuse', 'ENVIRONMENTAL', 'WASTE', 'WASTE_REDUCTION', 'PERCENTAGE', '(recycled_tons + composted_tons) / total_waste_tons * 100', 'GRI', 'GRI 306-4', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_010', 'Carbon Intensity', 'GHG emissions per unit of revenue', 'ENVIRONMENTAL', 'EMISSIONS', 'CARBON_EMISSIONS', 'tCO2e/M_USD', '(scope1_emissions + scope2_emissions) / revenue_musd', 'TCFD', 'TCFD-M4', 'QUANTITATIVE', 'ANNUAL'),
-- Social Metrics
('DEF_011', 'Total Recordable Incident Rate', 'Number of recordable incidents per 200,000 hours worked', 'SOCIAL', 'WORKFORCE', 'HEALTH_SAFETY', 'INCIDENTS_PER_200K_HOURS', '(recordable_incidents / total_hours_worked) * 200000', 'GRI', 'GRI 403-9', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_012', 'Women in Leadership', 'Percentage of leadership positions held by women', 'SOCIAL', 'WORKFORCE', 'DIVERSITY_INCLUSION', 'PERCENTAGE', '(women_in_leadership / total_leadership) * 100', 'GRI', 'GRI 405-1', 'QUANTITATIVE', 'ANNUAL'),
('DEF_013', 'Employee Training Hours', 'Average hours of training per employee per year', 'SOCIAL', 'WORKFORCE', 'TRAINING_DEVELOPMENT', 'HOURS_PER_EMPLOYEE', 'total_training_hours / total_employees', 'GRI', 'GRI 404-1', 'QUANTITATIVE', 'ANNUAL'),
('DEF_014', 'Voluntary Turnover Rate', 'Percentage of employees who voluntarily left', 'SOCIAL', 'WORKFORCE', 'LABOR_PRACTICES', 'PERCENTAGE', '(voluntary_departures / avg_headcount) * 100', 'SASB', 'TC-HW-330a.2', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_015', 'Community Investment', 'Total value of community investments and donations', 'SOCIAL', 'COMMUNITY', NULL, 'USD', 'SUM(donations + volunteering_value + sponsorships)', 'GRI', 'GRI 413-1', 'QUANTITATIVE', 'ANNUAL'),
-- Governance Metrics
('DEF_016', 'Board Independence', 'Percentage of independent board members', 'GOVERNANCE', 'BOARD_DIVERSITY', NULL, 'PERCENTAGE', '(independent_directors / total_directors) * 100', 'GRI', 'GRI 2-9', 'QUANTITATIVE', 'ANNUAL'),
('DEF_017', 'Board Gender Diversity', 'Percentage of women on the board of directors', 'GOVERNANCE', 'BOARD_DIVERSITY', NULL, 'PERCENTAGE', '(women_directors / total_directors) * 100', 'GRI', 'GRI 405-1', 'QUANTITATIVE', 'ANNUAL'),
('DEF_018', 'Ethics Hotline Reports', 'Number of reports received through ethics reporting channels', 'GOVERNANCE', 'ETHICS', 'ANTI_CORRUPTION', 'COUNT', 'COUNT(ethics_reports)', 'GRI', 'GRI 2-26', 'QUANTITATIVE', 'QUARTERLY'),
('DEF_019', 'Compliance Training Completion', 'Percentage of employees completing required compliance training', 'GOVERNANCE', 'COMPLIANCE', NULL, 'PERCENTAGE', '(employees_completed / employees_required) * 100', 'GRI', 'GRI 205-2', 'QUANTITATIVE', 'ANNUAL'),
('DEF_020', 'Data Breach Incidents', 'Number of confirmed data security breaches', 'GOVERNANCE', 'COMPLIANCE', 'DATA_SECURITY', 'COUNT', 'COUNT(confirmed_breaches)', 'SASB', 'TC-HW-230a.1', 'QUANTITATIVE', 'QUARTERLY');

-- ============================================================================
-- SECTION 7: Create Validation Function (Deterministic Constraint for Agent)
-- ============================================================================

CREATE OR REPLACE FUNCTION ITRON_DB.ONTOLOGY.VALIDATE_ESG_METRIC(METRIC_NAME_INPUT VARCHAR)
RETURNS OBJECT
AS
$$
SELECT OBJECT_CONSTRUCT(
    'metric_name', METRIC_NAME_INPUT,
    'is_valid', CASE WHEN d.DEFINITION_ID IS NOT NULL THEN TRUE ELSE FALSE END,
    'esg_pillar', d.ESG_PILLAR,
    'esg_category', d.ESG_CATEGORY,
    'esg_subcategory', d.ESG_SUBCATEGORY,
    'standard_unit', d.STANDARD_UNIT,
    'reporting_framework', d.REPORTING_FRAMEWORK,
    'framework_indicator_id', d.FRAMEWORK_INDICATOR_ID,
    'calculation_formula', d.CALCULATION_FORMULA,
    'sdg_goals', (
        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
            'sdg_number', m.SDG_GOAL_NUMBER,
            'sdg_name', m.SDG_GOAL_NAME,
            'sdg_target', m.SDG_TARGET,
            'mapping_strength', m.MAPPING_STRENGTH
        ))
        FROM ITRON_DB.ONTOLOGY.ONTOLOGY_SDG_MAPPINGS m
        WHERE m.ESG_METRIC_NAME = METRIC_NAME_INPUT
           OR m.ESG_CATEGORY = d.ESG_CATEGORY
    ),
    'validation_rules', (
        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
            'rule_name', r.RULE_NAME,
            'rule_type', r.RULE_TYPE,
            'expected_value', r.EXPECTED_VALUE,
            'error_message', r.ERROR_MESSAGE
        ))
        FROM ITRON_DB.ONTOLOGY.ONTOLOGY_VALIDATION_RULES r
        WHERE r.RULE_CATEGORY = d.ESG_CATEGORY
          AND r.IS_ACTIVE = TRUE
    ),
    'ontology_class', (
        SELECT OBJECT_CONSTRUCT(
            'class_name', c.CLASS_NAME,
            'class_uri', c.CLASS_URI,
            'hierarchy_level', c.HIERARCHY_LEVEL
        )
        FROM ITRON_DB.ONTOLOGY.ONTOLOGY_CLASSES c
        WHERE c.ESG_PILLAR = d.ESG_PILLAR
          AND c.CLASS_NAME = d.ESG_CATEGORY
        LIMIT 1
    )
)
FROM (SELECT 1) dummy
LEFT JOIN ITRON_DB.ONTOLOGY.ONTOLOGY_METRIC_DEFINITIONS d
    ON UPPER(d.METRIC_NAME) = UPPER(METRIC_NAME_INPUT)
       OR CONTAINS(UPPER(d.METRIC_NAME), UPPER(METRIC_NAME_INPUT))
LIMIT 1
$$;

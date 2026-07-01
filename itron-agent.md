# Snowflake Intelligence Agent Project Template

## Purpose
Itron is asking Snowflake to build a Natural language query tool that integrates their operations data and the ESGOnt Ontology to provide a Deterministic rule set that is used with the Probablistic LLM to provide the highest degree of analysis without hallucinations.  The ESGOnt can be found here: @https://annasvjaya.com/esgont & @https://www.sciencedirect.com/science/article/pii/S266691612500074X?via%3Dihub

## Customer details
Itron
We create a more resourceful world Protecting the world’s resources is essential
Itron is transforming how the world manages energy, water and city services. Our trusted intelligent infrastructure solutions help utilities and cities improve efficiency, build resilience and deliver safe, reliable and affordable service. With edge intelligence, we connect people, data insights and devices so communities can better manage the essential resources they rely on to live and thrive. Join us as we create a more resourceful world.

Innovation is in our DNA
People throughout the industry know us for delivering proven results, at scale, for decades. Leveraging our expertise and innovation, we open the door to more possibilities for energy, water and city service management with more intelligence that’s delivered in the right places, at the right time.

INNOVATION HIGHLIGHTS
Meet our team
Itron’s executive leadership team has spent decades serving energy and water industry. Like all of us at Itron, they are committed to creating more efficient and insightful utilities, smarter cities and a more resourceful world that addresses the sustainability challenges of today and tomorrow.

Our values and behaviors
Protecting the world’s energy and water is essential. To ensure our work has the greatest positive impact on the management of these resources as possible, we align ourselves to a shared set of values and behaviors. These guide not only what we do but how we do it as we create a more resourceful world

CUSTOMER-CENTRIC
we listen; we imagine; we execute; we strive to exceed the expectation of our customers, internal or external

AUTHENTIC
we are respectful; we are direct; we discuss; we debate; we speak up; we tell the truth; we act with integrity, always

ACCOUNTABLE
we are decisive; we own our work – both our results and how they are achieved

AGILE
we prepare; we anticipate; we are flexible; we are resilient; we act with urgency; we are persistent; we drive change

COLLABORATIVE
we push each other forward; we pull each other upward; we are better together; once a decision is made, we support it

INNOVATIVE
we are curious; we look forward; we explore; we take risks; we find a better way; we continuously learn

Resourcefulness in action

2025 Resourcefulness Report
How can utilities embrace the transformative role of data analytics, AI and grid edge intelligence? Download our report to find out.

2025 Corporate Sustainability Report
Explore Itron’s sustainability strategy, progress and results for the most recent reporting year.

2024 Proven Benefits Supplement
Learn how Itron's solutions help address the sustainability challenges of our customers.

New and noteworthy
Itron logl
June 25, 2026
Nominations Now Open for Itron’s Eighth Annual Innovator Award

June 24, 2026
AI Water MetersOpens in new window

June 17, 2026
Leading with a Viewpoint and Grace Opens in new window

June 16, 2026
Itron Collaborates With Watercare Services For New Zealand's Largest Smart Water Meter UpgradeOpens in new window
Powering the next generation
Solving the energy and water challenges of tomorrow will require fresh thinking and new perspectives. Those solutions will rely heavily on STEM education. That's why Itron, as a business leader and STEM employer, has worked with renowned educators to develop Resourcefulness: An Introduction to the Energy-Water Nexus.

## Customer Configuration

**To create a new project, replace these variables throughout:**

| Variable | Description | Example (Cathay Bank) |
|----------|-------------|-------------------|
| `{CUSTOMER_NAME}` | Customer name | Itron |
| `{CUSTOMER_NAME_UPPER}` | Uppercase for SQL objects | Itron |
| `{DATABASE_NAME}` | Main database name | Itron_DB |
| `{WAREHOUSE_NAME}` | Warehouse name | Itron_WH |
| `{AGENT_NAME}` | Agent identifier | Itron_AGENT |
| `{BUSINESS_DOMAIN}` | Customer's business focus | Natural Resource Management Company |
| `{WEB_PRESENCE}`  | Web Address | https://www.itron.com/

---

## Project Instructions

```Build a complete Snowflake Intelligence architecture and implementation plan for `{CUSTOMER_NAME_UPPER}`.

The proposed architecture is a modern, streaming-first Scalable ELT Pipeline designed for near real-time data availability, scalability, and maintainability.  All of the ESG data will stream data into Snowflake and they have the desire to be able to ask questions of their data with Natural Language Queries.

(Note: All project images should be SVG graphics and as you can see in the "Agent Project Structure" section, there should always be architecture.svg, deployment_flow.svg, ml_models.svg at a minimum)
 This Project should encompass all aspects of the details identified on their website @https://www.itron.com. The Agent Project Structure directories should be created in the root github repo directory.
 Additionally, create a "Query Tool Chain" SVG diagram.  This should show examples of the questions and the tool path used to answer.  I am trying to identify when each tool is used and whether the agent used the ontology.
 ```

## Agent Project Structure

```
/
├── README.md                           # Project overview and setup instructions
├── docs/
│   ├── AGENT_SETUP.md                 # Step-by-step agent configuration guide
│   ├── DEPLOYMENT_SUMMARY.md          # Current deployment status
│   ├── questions.md                   # 30+ complex test questions
│   └── images/
│       ├── architecture.svg           # System architecture diagram
│       ├── deployment_flow.svg        # Deployment workflow diagram
│       └── ml_models.svg              # ML pipeline visualization
├── notebooks/
│   └── 08_ml_models.ipynb      # ML model training (optional)
└── sql/
    ├── setup/
    │   ├── 01_database_and_schema.sql # Database, schemas, warehouse
    │   └── 02_create_tables.sql       # All table definitions
    |   └── 03_ESGOnt_Ontology.sql # Create all tables and load the ESGOnt Ontology
    ├── data/
    │   └── 04_generate_synthetic_data.sql # Test data generation
    ├── views/
    │   ├── 05_create_views.sql        # Analytical views
    │   └── 06_create_semantic_views.sql # Semantic views for Cortex Analyst
    ├── search/
    │   └── 07_create_cortex_search.sql # Cortex Search services
    ├── models/
    │   └── 09_ml_model_functions.sql  # ML prediction views and agent functions
    └── agent/
        └── 10_create_agent.sql # Agent creation script
```

---

## File Execution Order

**MUST be executed in this exact order:**

These are examples of what is required.  You may need to add more project defined project.  The documentation should have an SVG image showing the project flow.

1. `sql/setup/01_database_and_schema.sql`
2. `sql/setup/02_create_tables.sql`
3. `sql/data/03_ESGOnt_Ontology.sql`
4. `sql/data/04_generate_synthetic_data.sql`
5. `sql/views/05_create_views.sql`
6. `sql/views/06_create_semantic_views.sql`
7. `sql/search/07_create_cortex_search.sql`
8. `notebooks/08_ml_models.ipynb`
9. `sql/models/09_ml_model_functions.sql`
10. `sql/agent/10_create_agent.sql`

---

## Critical Syntax Reference

### Snowflake Agent YAML Specification (VERIFIED WORKING)

```yaml
CREATE OR REPLACE AGENT {AGENT_NAME}
  COMMENT = '{Customer} intelligence agent'
  PROFILE = '{"display_name": "{Customer} Assistant", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 360
      tokens: 32000

  instructions:
    response: "Response instructions..."
    orchestration: "Tool routing instructions..."
    system: "System role description..."
    sample_questions:
      - question: "Sample question?"
        answer: "How the agent should respond."

  tools:
    # Cortex Analyst (text-to-SQL)
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ToolName"
        description: "Description of what this tool does"

    # Cortex Search
    - tool_spec:
        type: "cortex_search"
        name: "SearchName"
        description: "Description of search capability"

    # Custom Function (generic)
    - tool_spec:
        type: "generic"
        name: "FunctionName"
        description: "Description of function output"

  tool_resources:
    # Cortex Analyst resource
    ToolName:
      semantic_view: "{DATABASE}.{SCHEMA}.{SEMANTIC_VIEW_NAME}"

    # Cortex Search resource
    SearchName:
      name: "{DATABASE}.{SCHEMA}.{SEARCH_SERVICE_NAME}"
      max_results: "10"
      title_column: "column_name"
      id_column: "id_column"

    # Custom Function resource
    FunctionName:
      type: "function"
      identifier: "{DATABASE}.{SCHEMA}.{FUNCTION_NAME}"
      execution_environment:
        type: "warehouse"
        warehouse: "{WAREHOUSE_NAME}"
  $$;
```

### SQL UDF Return Types (VERIFIED)

| Function Returns | Correct Return Type |
|------------------|---------------------|
| `ARRAY_AGG(...)` | `RETURNS ARRAY` |
| `OBJECT_CONSTRUCT(...)` | `RETURNS OBJECT` |
| Single scalar value | `RETURNS VARCHAR/NUMBER/etc` |

**DO NOT USE:**
- `RETURNS VARIANT` for `ARRAY_AGG` or `OBJECT_CONSTRUCT`
- `LANGUAGE SQL` clause in SQL UDFs

### SQL UDF Syntax (VERIFIED)

```sql
-- Correct syntax for scalar UDF returning ARRAY
CREATE OR REPLACE FUNCTION AGENT_GET_DATA()
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'key1', COLUMN1,
    'key2', COLUMN2
)) FROM (SELECT * FROM TABLE LIMIT 50)
$$;

-- Correct syntax for scalar UDF returning OBJECT
CREATE OR REPLACE FUNCTION AGENT_GET_SUMMARY()
RETURNS OBJECT
AS
$$
SELECT OBJECT_CONSTRUCT(
    'metric1', (SELECT COUNT(*) FROM TABLE1),
    'metric2', (SELECT AVG(COLUMN) FROM TABLE2)
)
$$;
```

---

## Lessons Learned (CRITICAL)

### 1. ALWAYS VERIFY SNOWFLAKE SYNTAX BEFORE WRITING CODE

**What went wrong:** Multiple syntax errors because I guessed at syntax instead of verifying against Snowflake documentation.

**Correct approach:**
- Use `snowflake_product_docs` tool to look up syntax BEFORE writing any SQL
- Use `system_instructions` tool for Cortex Agent, Analyst, and other Snowflake products
- Reference working examples

**Specific errors made:**
- Used `RETURNS VARIANT` instead of `RETURNS ARRAY` for `ARRAY_AGG`
- Used `RETURNS VARIANT` instead of `RETURNS OBJECT` for `OBJECT_CONSTRUCT`
- Used `LANGUAGE SQL` clause which is invalid for SQL UDFs
- Used `type: "procedure"` instead of `type: "function"` for agent tools
- Used `search_service:` instead of `name:` for Cortex Search resources
- Used JSON format instead of YAML for agent specification

### 2. COMPLETE ALL FILES BEFORE STOPPING

**What went wrong:** Generated partial files and stopped without completing the project, leaving merge conflicts and incomplete code.

**Correct approach:**
- Review ALL files in the project at the start
- Create a TODO list for every file that needs to be created/modified
- Do not mark a task complete until the file is verified to compile/run
- Verify file completeness before moving to the next task

### 3. NEVER GUESS - ASK OR RESEARCH

**What went wrong:** Made assumptions about:
- Agent YAML syntax
- SQL UDF return types
- Function naming conventions
- Tool resource configuration

**Correct approach:**
- If unsure about syntax, use documentation tools first
- If documentation is unclear, ask the user for clarification
- Reference working examples from similar projects
- Test small pieces of code before combining them

### 4. ASK QUESTIONS WHEN UNCLEAR

**What went wrong:** Proceeded with assumptions instead of asking for clarification on requirements.

**Questions to ask upfront:**
- What business domain/industry is this for?
- What specific ML models or predictions are needed?
- What data sources exist or need to be created?
- What sample questions should the agent answer?
- Are there any existing working examples to reference?

### 5. VERIFY GIT MERGE CONFLICTS

**What went wrong:** Left merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) in SQL files.

**Correct approach:**
- After any file operations, verify no merge conflicts exist
- Search for conflict markers before marking files complete
- Test SQL files compile before considering them done

---

## Component Templates

### Database Setup (01_database_and_schema.sql)

```sql
CREATE DATABASE IF NOT EXISTS {DATABASE_NAME};
USE DATABASE {DATABASE_NAME};

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

CREATE OR REPLACE WAREHOUSE {WAREHOUSE_NAME} WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for {CUSTOMER_NAME} Intelligence Agent';

USE WAREHOUSE {WAREHOUSE_NAME};
```

### Cortex Search Service

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE {SEARCH_SERVICE_NAME}
  ON {text_column}
  ATTRIBUTES {attr1}, {attr2}, {attr3}
  WAREHOUSE = {WAREHOUSE_NAME}
  TARGET_LAG = '1 hour'
  COMMENT = 'Description of search service'
AS
  SELECT
    {columns}
  FROM {TABLE};
```

### Semantic View

```sql
CREATE OR REPLACE SEMANTIC VIEW {SEMANTIC_VIEW_NAME}
  COMMENT = 'Semantic view description'
AS
  SELECT
    {table}.{column} AS {alias}
      WITH SYNONYMS ('{synonym1}', '{synonym2}')
      COMMENT = '{Column description}',
    ...
  FROM {database}.{schema}.{table}
  ...;
```

---

## Checklist for New Projects

### Before Starting
- [ ] Confirm customer name and business domain
- [ ] Identify data sources (existing tables or need synthetic data)
- [ ] Determine ML models needed (LTV, churn, risk, etc.)
- [ ] Collect sample questions the agent should answer
- [ ] Get working example project for reference

### During Development
- [ ] Verify ALL SQL syntax against Snowflake docs before writing
- [ ] Test each SQL file compiles before moving to next
- [ ] Check for merge conflicts after any file operations
- [ ] Complete TODO list for every component

### Before Delivery
- [ ] Run all SQL files in order (01-08)
- [ ] Test agent creation succeeds
- [ ] Verify agent responds to sample questions
- [ ] Update documentation with customer-specific details
- [ ] Remove any placeholder values

---

## Reference Links

- Snowflake Agent Docs: `snowflake_product_docs` → "Cortex Agent"
- SQL UDF Reference: `snowflake_product_docs` → "CREATE FUNCTION SQL"
- Cortex Search: `snowflake_product_docs` → "CREATE CORTEX SEARCH SERVICE"
- Semantic Views: `snowflake_product_docs` → "CREATE SEMANTIC VIEW"

---

## Version History

- **v1.0** - Initial template based on previous Intelligence Agent project
- **Created:** March 2026
- **Lessons Learned:** Documented from previous project issues

---

## DO NOT:
1. Guess at syntax - VERIFY FIRST
2. Use `RETURNS VARIANT` for `ARRAY_AGG` or `OBJECT_CONSTRUCT`
3. Use `LANGUAGE SQL` in SQL UDFs
4. Use JSON format for Agent specification (use YAML)
5. Leave merge conflicts in files
6. Mark tasks complete before verifying they work
7. Assume you know Snowflake syntax without checking
8. Use text based graphic

## DO:
1. Use `snowflake_product_docs` before writing SQL
2. Use `system_instructions` for Cortex products
3. Reference working examples
4. Ask questions when requirements are unclear
5. Test each file compiles before moving on
6. Complete ALL files before stopping
7. Verify no merge conflicts exist
8. Always generate documentation
9. Always generate SVG images for the documentation.
10. Always use html for tables when generating documentation
11. Always generate all files and never placeholders
12. Always put this line of code at the top of all documentation files: <img src="Snowflake_Logo.svg" width="200">

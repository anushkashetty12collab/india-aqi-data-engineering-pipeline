<div align="center">

# 🌫️ AQI Data Engineering Pipeline
### End-to-End Air Quality Intelligence Platform for Indian Cities

[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![dbt](https://img.shields.io/badge/dbt-1.7+-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-GCP-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/bigquery)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Streamlit](https://img.shields.io/badge/Streamlit-Dashboard-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white)](https://streamlit.io)
[![Kestra](https://img.shields.io/badge/Kestra-Orchestration-6B4FBB?style=for-the-badge)](https://kestra.io/)

<br/>

> A production-grade, cloud-native data engineering pipeline that ingests, transforms, warehouses, and visualizes Air Quality Index (AQI) data across 8 major Indian cities from 2010–2023 — fully orchestrated by Kestra and powered by Google Cloud Platform.

</div>

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Infrastructure as Code — Terraform](#-infrastructure-as-code--terraform)
- [Orchestration — Kestra](#-orchestration--kestra)
- [Data Warehouse — BigQuery](#-data-warehouse--bigquery)
- [dbt Transformations](#-dbt-transformations)
- [Dashboard — Streamlit](#-dashboard--streamlit)
- [Project Structure](#-project-structure)
- [How to Run](#-how-to-run-locally)
- [Key Insights](#-key-insights)
- [Author](#-author)

---

## 🧭 Overview

This project delivers a **fully automated, end-to-end data engineering pipeline** tracking air quality across India's major cities. Every stage — from raw CSV ingestion to interactive dashboard — is orchestrated, version-controlled, and cloud-native.

| Stage | Tool | What Happens |
|---|---|---|
| 🏗️ **Infrastructure** | Terraform | Provisions GCS bucket + BigQuery dataset |
| 🎼 **Orchestration** | Kestra | Sets GCP config, creates resources, uploads CSVs to GCS |
| 🗄️ **Storage** | Google Cloud Storage | Stores raw AQI CSV files at `aqi_data/` prefix |
| 🏛️ **Warehouse** | BigQuery | External table → partitioned fact → enriched analytical table |
| 🔄 **Transform** | dbt | Staging → Intermediate → Marts layer |
| 📊 **Visualization** | Streamlit + Plotly | Real-time interactive AQI dashboard |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           AQI Data Pipeline                                  │
│                                                                              │
│  ┌──────────────┐                                                            │
│  │  Terraform   │──────────── Provisions ──────────────────────────┐        │
│  │    (IaC)     │                                                   │        │
│  └──────────────┘                                                   ▼        │
│                                                         ┌───────────────────┐│
│  ┌──────────────┐    ┌──────────────────────────────┐  │  GCS Bucket       ││
│  │  Raw AQI     │───▶│     Kestra Orchestrator       │  │  anushka-aqi-     ││
│  │  CSV Files   │    │                               │──▶  data-bucket     ││
│  └──────────────┘    │  Flow 01: GCP KV Config       │  │  /aqi_data/*.csv  ││
│                      │  Flow 02: Create GCS + BQ     │  └────────┬──────────┘│
│                      │  Flow 03: Upload CSVs → GCS   │           │           │
│                      └──────────────────────────────┘           │           │
│                                                                   ▼           │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                     BigQuery — aqi_dataset                             │  │
│  │                                                                        │  │
│  │  aqi_ext (External → GCS)                                              │  │
│  │       ↓                                                                │  │
│  │  aqi_fact  ←  PARTITION BY MONTH  ·  CLUSTER BY parameter             │  │
│  │       ↓                    stations_info (from metadata/*.csv)         │  │
│  │  aqi_enriched  ←  aqi_fact LEFT JOIN stations_info                     │  │
│  └───────────────────────────────┬────────────────────────────────────────┘  │
│                                  │                                            │
│                                  ▼                                            │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                          dbt Models                                    │  │
│  │                                                                        │  │
│  │  stg_aqi · stg_stations                                                │  │
│  │       ↓                                                                │  │
│  │  int_aqi_long  (wide → long unpivot across 6 pollutants)               │  │
│  │       ↓                                                                │  │
│  │  fact_aqi + dim_stations → aqi_enriched                                │  │
│  │       ↓                                                                │  │
│  │  Marts: aqi_trend · aqi_summary · aqi_category · aqi_yearly           │  │
│  │         aqi_dashboard · aqi_mumbai_yearly_trend                        │  │
│  └───────────────────────────────┬────────────────────────────────────────┘  │
│                                  │                                            │
│                                  ▼                                            │
│                     ┌────────────────────────┐                               │
│                     │   Streamlit Dashboard   │                               │
│                     │  Live BigQuery queries  │                               │
│                     │  Plotly visualizations  │                               │
│                     └────────────────────────┘                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Tech Stack

| Layer | Technology | Detail |
|---|---|---|
| ☁️ Cloud | **Google Cloud Platform** | Project: `anushkadataengineeringproject` |
| 🗄️ Storage | **Google Cloud Storage** | Bucket: `anushka-aqi-data-bucket` · Region: `asia-south1` |
| 🏛️ Warehouse | **BigQuery** | Dataset: `aqi_dataset` · Region: `ASIA-SOUTH1` |
| 🔧 IaC | **Terraform** | Provisions GCS bucket + BigQuery dataset |
| 🎼 Orchestration | **Kestra v1.1** (Docker) | 3 flows: setup → resources → upload |
| 🔄 Transform | **dbt** | Staging → Intermediate → Mart layers |
| 📊 Visualization | **Streamlit + Plotly** | Live BigQuery queries |
| 🐍 Language | **Python, SQL, HCL** | Ingestion, transforms, infrastructure |
|🐳 Containerization | **Docker** |containerize Kestra and its dependencies (PostgreSQL, pgAdmin) |


---

## 🏗️ Infrastructure as Code — Terraform

Terraform provisions all core GCP resources — zero manual console setup required.

```hcl
# main.tf

provider "google" {
  project = "anushkadataengineeringproject"
  region  = "asia-south1"
}

# GCS Bucket — landing zone for raw AQI CSVs
resource "google_storage_bucket" "aqi_bucket" {
  name                        = "anushka-aqi-data-bucket"
  location                    = "ASIA-SOUTH1"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# BigQuery Dataset — houses all tables and dbt models
resource "google_bigquery_dataset" "aqi_dataset" {
  dataset_id                 = "aqi_dataset"
  location                   = "ASIA-SOUTH1"
  delete_contents_on_destroy = true
}
```

```bash
terraform init      # Download providers
terraform plan      # Preview what will be created
terraform apply     # Provision GCS bucket + BigQuery dataset
terraform destroy   # Tear down all resources when done
```

---

## 🎼 Orchestration — Kestra

Kestra manages the pipeline across **3 sequential flows**, running in Docker via `docker-compose`. The local AQI archive is volume-mounted directly into the Kestra container.

```yaml
# docker-compose volume mount
volumes:
  - C:/Users/Anushka/Downloads/archive:/data   # Raw CSVs available inside Kestra as /data/
```

### Flow 01 — GCP Config (`01_gcp_setup`)

Stores all GCP configuration as reusable key-value pairs:

```
GCP_PROJECT_ID  → anushkadataengineeringproject
GCP_LOCATION    → asia-south1
GCP_BUCKET_NAME → anushka-aqi-data-bucket
GCP_DATASET     → aqi_dataset
```

### Flow 02 — Create Resources (`02_gcp_resources`)

Creates the GCS bucket and BigQuery dataset (idempotent — skips if already exists):

```yaml
tasks:
  - create_gcs_bucket   # REGIONAL storage class, ifExists: SKIP
  - create_bq_dataset   # ifExists: SKIP
```

### Flow 03 — Upload CSVs to GCS (`03_aqi_upload`)

Copies all `*.csv` files from the mounted `/data/` volume and uploads each one to GCS:

```yaml
tasks:
  - extract         # cp /data/*.csv to working dir, outputs as Kestra files
  - upload_to_gcs   # EachSequential loop → gs://anushka-aqi-data-bucket/aqi_data/<filename>
```

```bash
# Start Kestra stack
docker-compose up -d

# Access Kestra UI
open http://localhost:8080
# Credentials: admin@kestra.io / Admin1234!
```

---

## 🏛️ Data Warehouse — BigQuery

### Table Architecture

```
aqi_dataset
│
├── aqi_ext           ← External table pointing to gs://anushka-aqi-data-bucket/aqi_data/*.csv
│                        skip_leading_rows=1, allow_jagged_rows, ignore_unknown_values
│
├── aqi_fact          ← Unpivoted pollutants native table
│                        PARTITION BY TIMESTAMP_TRUNC(datetime, MONTH)
│                        CLUSTER BY parameter
│                        Pollutants: PM2.5 · PM10 · NO2 · SO2 · CO · Ozone
│
├── stations_ext      ← External table → gs://anushka-aqi-data-bucket/metadata/*.csv
├── stations_info     ← Native copy of station metadata (city, state, agency)
│
└── aqi_enriched      ← aqi_fact LEFT JOIN stations_info ON station_code = file_name
                         Final analytical table — used by dbt + Streamlit
```

### Partitioning & Clustering

```sql
CREATE OR REPLACE TABLE aqi_dataset.aqi_fact
PARTITION BY TIMESTAMP_TRUNC(datetime, MONTH)
CLUSTER BY parameter
```

| Optimization | Benefit |
|---|---|
| 📅 **Monthly partitioning** | Date-filtered queries scan only relevant month partitions |
| 🗂️ **Clustering by parameter** | Pollutant-specific queries (e.g. PM2.5 only) skip irrelevant data |
| 🔗 **External table** | Raw GCS CSVs are queryable instantly — no load job or cost |

### Station Code Extraction

Station codes are parsed directly from filenames using regex — no manual mapping needed:

```sql
REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv') AS station_code
```

---

## 🔄 dbt Transformations

### Full Model Lineage

```
Source: aqi_source.aqi_ext  (BigQuery external table)
│
├── stg_aqi.sql
│     Cast types, extract station_code from _FILE_NAME, rename pollutant columns
│     → station_code | datetime | pm25 | pm10 | no2 | so2 | co | ozone
│
├── stg_stations.sql
│     Pass-through of stations_info (city, state, agency metadata)
│
├── int_aqi_long.sql
│     UNION ALL unpivot: 6 SELECT blocks → one row per pollutant per reading
│     → station_code | datetime | parameter | value
│
├── fact_aqi.sql             Filter nulls from int_aqi_long
├── dim_stations.sql         Wraps stg_stations
│
├── aqi_enriched.sql
│     fact_aqi LEFT JOIN dim_stations ON station_code = file_name
│     → Adds city, state, agency to every measurement row
│
└── marts/reporting/
    ├── aqi_trend.sql              Yearly avg by city + parameter + AQI category label
    ├── aqi_summary.sql            Overall avg pollutant value by city + parameter
    ├── aqi_category.sql           Row-level AQI category per measurement
    ├── aqi_yearly.sql             Year × city × parameter aggregations
    ├── aqi_dashboard.sql          Dashboard-ready query (city-filterable)
    ├── aqi_mumbai_yearly_trend.sql Mumbai-specific yearly trend
    └── aqi_2016_2019_filter.sql   8-city analysis filtered to 2010–2023
```

### AQI Category Logic (consistent across all mart models)

```sql
CASE
  WHEN AVG(value) <= 50  THEN 'Good'
  WHEN AVG(value) <= 100 THEN 'Moderate'
  WHEN AVG(value) <= 200 THEN 'Poor'
  ELSE                        'Very Poor'
END AS aqi_category
```

### Cities Covered

`Delhi` · `Mumbai` · `Bengaluru` · `Chennai` · `Kolkata` · `Hyderabad` · `Pune` · `Ahmedabad`....`etc`

### Pollutants Tracked

`PM2.5` · `PM10` · `NO2` · `SO2` · `CO` · `Ozone`

```bash
dbt deps           # Install packages
dbt run            # Execute all models in dependency order
dbt test           # Run data quality tests
dbt docs generate  # Build lineage documentation
dbt docs serve     # View DAG in browser
```

---

## 📊 Dashboard — Streamlit

Queries `aqi_dataset.aqi_enriched` live from BigQuery and renders interactive Plotly charts.

### Filters (Sidebar)

- 🏙️ **City** multi-select (default: all 8 cities)
- 🧪 **Parameter** multi-select (default: first 2 pollutants)
- 📅 **Year range** slider — 2010 to 2023

### Visualizations

**📊 KPI Summary Cards**

| Metric | Value |
|---|---|
| Cities | Count of selected cities |
| Parameters | Count of selected pollutants |
| Avg Value (Overall) | Mean across all selected filters |

**📈 Line Charts — Pollutant Trends Over Time**
- One chart rendered per selected parameter
- City-coloured lines with year markers
- Powered by `plotly.express.line`

**🟡 AQI Category Heatmap**
- X-axis: Year · Y-axis: City
- Colour scale: `#2ecc71` (Good=1) → `#e74c3c` (Very Poor=4)
- Shows the most frequent AQI category per city per year

**🗂️ Raw Data Table**
- Full filtered dataframe rendered with `st.dataframe`

```bash
pip install streamlit google-cloud-bigquery pandas plotly db-dtypes
gcloud auth application-default login
streamlit run app.py
```

---

## 📂 Project Structure

```
dbt_aqi/
│
├── 📁 terraform/
│   └── main.tf                          # GCS bucket + BigQuery dataset
│
├── 📁 kestra/
│   ├── 01_gcp_setup.yml                 # Set GCP KV config
│   ├── 02_gcp_resources.yml             # Create GCS + BigQuery resources
│   ├── 03_aqi_upload.yml                # Upload CSVs from /data/ to GCS
│   └── docker-compose.yml              # Kestra + Postgres stack
│
├── 📁 models/
│   ├── staging/
│   │   ├── stg_aqi.sql                  # Raw AQI → typed, renamed columns
│   │   └── stg_stations.sql             # Station metadata passthrough
│   ├── intermediate/
│   │   └── int_aqi_long.sql             # Wide → long unpivot (6 pollutants)
│   └── marts/
│       ├── aqi_enriched.sql             # fact JOIN dim (final model)
│       ├── dim_stations.sql
│       ├── fact_aqi.sql
│       └── reporting/
│           ├── aqi_trend.sql
│           ├── aqi_summary.sql
│           ├── aqi_category.sql
│           ├── aqi_yearly.sql
│           ├── aqi_dashboard.sql
│           ├── aqi_mumbai_yearly_trend.sql
│           └── aqi_2016_2019_filter.sql
│
├── 📁 macros/
├── 📁 analyses/
├── 📁 seeds/
├── 📁 tests/
│
├── dbt_project.yml
├── profiles.yml
├── packages.yml
├── app.py                               # Streamlit dashboard
└── README.md
```

---

## 🚀 How to Run Locally

### Prerequisites

- Google Cloud account · `gcloud` CLI · Docker · Python 3.11+ · dbt-bigquery · Terraform

### Step 1 — Provision Infrastructure

```bash
cd terraform/
terraform init
terraform apply
# Creates: anushka-aqi-data-bucket (GCS) + aqi_dataset (BigQuery)
```

### Step 2 — Start Kestra

```bash
docker-compose up -d
# UI: http://localhost:8080  |  admin@kestra.io / Admin1234!
```

### Step 3 — Run Kestra Flows (in order)

```
01_gcp_setup      → Store project/region/bucket/dataset as KV pairs
02_gcp_resources  → Create GCS bucket + BigQuery dataset
03_aqi_upload     → Upload all CSVs from /data/ to gs://anushka-aqi-data-bucket/aqi_data/
```

### Step 4 — Create BigQuery Tables

Run the warehouse SQL in this order:

```sql
1. CREATE EXTERNAL TABLE aqi_ext          -- points to GCS
2. CREATE TABLE aqi_fact                  -- partitioned + clustered
3. CREATE EXTERNAL TABLE stations_ext     -- metadata from GCS
4. CREATE TABLE stations_info             -- native copy
5. CREATE TABLE aqi_enriched              -- fact JOIN stations
```

### Step 5 — Run dbt

```bash
pip install dbt-bigquery
dbt deps && dbt run && dbt test
```

### Step 6 — Launch Dashboard

```bash
pip install streamlit google-cloud-bigquery pandas plotly db-dtypes
gcloud auth application-default login
streamlit run app.py
```

---

## 📌 Key Insights

- **PM2.5 and NO2** are the dominant pollutants driving poor AQI across all 8 cities
- **Delhi** consistently shows the highest average pollutant values, particularly in winter months
- The **unpivot pattern** in `int_aqi_long.sql` — 6 UNION ALL blocks — transforms wide CSV columns into a clean long-format fact table, enabling flexible aggregation across any pollutant
- **Station codes are parsed directly from filenames** using `REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv')` — no lookup table or manual mapping needed
- **Monthly partitioning + parameter clustering** on `aqi_fact` dramatically reduces query cost for time-filtered, pollutant-specific dashboard queries
- Kestra's **EachSequential loop** in Flow 03 handles any number of CSV files dynamically — no hardcoded filenames

---

## 👩‍💻 Author

<div align="center">

**Anushka Shetty**
*Data Engineering Project — Zoomcamp*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](#)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white)](#)

</div>

---

<div align="center">

*Built with 💙 on Google Cloud Platform · dbt · Terraform · Kestra · Streamlit*

</div>

import streamlit as st
from google.cloud import bigquery
from google.oauth2 import service_account
import pandas as pd
import plotly.express as px

# --- Page Config ---
st.set_page_config(page_title="AQI Dashboard", layout="wide")
st.title("India AQI Dashboard (2010–2023)")

# --- Auth ---

client = bigquery.Client(project="project_id")

# --- Query ---
query = """
SELECT
  city,
  EXTRACT(YEAR FROM datetime) AS year,
  parameter,
  ROUND(AVG(value), 2) AS avg_value,
  CASE
    WHEN AVG(value) <= 50  THEN 'Good'
    WHEN AVG(value) <= 100 THEN 'Moderate'
    WHEN AVG(value) <= 200 THEN 'Poor'
    ELSE 'Very Poor'
  END AS aqi_category
FROM `anushkadataengineeringproject.aqi_dataset.aqi_enriched`
WHERE
  EXTRACT(YEAR FROM datetime) BETWEEN 2010 AND 2023
  AND city IN (
    'Delhi','Mumbai','Bengaluru','Chennai',
    'Kolkata','Hyderabad','Pune','Ahmedabad'
  )
GROUP BY city, year, parameter
ORDER BY city, year
"""

# --- Fetch Data ---
try:
    df = client.query(query).to_dataframe()
except Exception as e:
    st.error(f"BigQuery error: {e}")
    st.stop()

if df.empty:
    st.warning("No data returned.")
    st.stop()

# --- Sidebar Filters ---
st.sidebar.header("Filters")

selected_cities = st.sidebar.multiselect(
    "Select Cities",
    options=df["city"].unique(),
    default=df["city"].unique()
)

selected_params = st.sidebar.multiselect(
    "Select Parameters",
    options=df["parameter"].unique(),
    default=df["parameter"].unique()[:2]   # default to first 2
)

selected_years = st.sidebar.slider(
    "Year Range",
    min_value=2010,
    max_value=2023,
    value=(2010, 2023)
)

# --- Filter DataFrame ---
filtered_df = df[
    (df["city"].isin(selected_cities)) &
    (df["parameter"].isin(selected_params)) &
    (df["year"].between(*selected_years))
]

if filtered_df.empty:
    st.warning("No data for selected filters.")
    st.stop()

# --- KPI Cards ---
st.subheader("📊 Summary")
col1, col2, col3 = st.columns(3)
col1.metric("Cities", filtered_df["city"].nunique())
col2.metric("Parameters", filtered_df["parameter"].nunique())
col3.metric("Avg Value (Overall)", round(filtered_df["avg_value"].mean(), 2))

st.divider()

# --- Line Chart: Avg Value Over Years ---
st.subheader("📈 Average Pollutant Value Over Years")
for param in selected_params:
    param_df = filtered_df[filtered_df["parameter"] == param]
    fig = px.line(
        param_df,
        x="year",
        y="avg_value",
        color="city",
        markers=True,
        title=f"{param} — Avg Value by City",
        labels={"avg_value": "Avg Value", "year": "Year"}
    )
    st.plotly_chart(fig, use_container_width=True)

st.divider()

# --- AQI Category Heatmap ---
st.subheader("🟡 AQI Category by City & Year")
category_order = ["Good", "Moderate", "Poor", "Very Poor"]
color_map = {
    "Good": "#2ecc71",
    "Moderate": "#f1c40f",
    "Poor": "#e67e22",
    "Very Poor": "#e74c3c"
}

pivot_df = filtered_df.groupby(["city", "year"])["aqi_category"].agg(
    lambda x: x.mode()[0]   # most common category per city/year
).reset_index()

fig2 = px.density_heatmap(
    pivot_df,
    x="year",
    y="city",
    z=pivot_df["aqi_category"].map({"Good": 1, "Moderate": 2, "Poor": 3, "Very Poor": 4}),
    color_continuous_scale=["#2ecc71", "#f1c40f", "#e67e22", "#e74c3c"],
    title="AQI Category Heatmap (1=Good → 4=Very Poor)",
    labels={"z": "AQI Level"}
)
st.plotly_chart(fig2, use_container_width=True)

st.divider()

# --- Raw Data Table ---
st.subheader("🗂️ Raw Data")
st.dataframe(filtered_df.reset_index(drop=True), use_container_width=True)

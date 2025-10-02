# Blueprint_BI
The first steps in building a BI Analysis 

# Cohors Analysis

## Overview

This project performs customer analytics on sales data from 2010 for a technology retail chain, inspired by the TECNOMAX case study. It applies RFM (Recency, Frequency, Monetary) and Cohort Analysis techniques to segment customers, track retention patterns, and provide insights for business decisions.

## Business Context

Based on the TECNOMAX case, the project addresses challenges like store closures due to low sales and high costs. It balances perspectives: expanding product variety (CEO Arturo) vs. increasing sales staff (Sales Manager María). The analysis helps identify customer value segments and retention trends to optimize operations and prevent further closures.

## Data Sources

- **Primary Data**: `Ventas+2010+v2+-+copia.xlsx` - Sales transactions from 2010.
- **Processed Databases**: SQLite files like `carmax_FINAL.db`, `carmax_v2.db`, `carmax_v3.db`, `FilgudTransaccional.db` containing cleaned and transformed data.

## Analyses Performed

### RFM Analysis
Segments customers based on:
- **Recency**: Days since last purchase (scored 1-4).
- **Frequency**: Number of purchases (scored 1-4).
- **Monetary**: Total spend (scored 1-4).

Labels include "Más reciente", "Mayor gasto", etc. Implemented in `RFM.sql`.

### Cohort Analysis
Tracks customer states over 12 months (January-December):
- States: Activo, Recompra, Desercion, Regreso, Repite desersion.
- Implemented in `Cohort.sql`, using monthly activity flags.

### Integrated RFM-Cohort Analysis
Combines RFM segments with cohort states per month for a transactional view. Implemented in `Transaccional_RFM_Cohort.sql`.

## File Descriptions

- **SQL Scripts**:
  - `SQLite.sql`: General SQLite queries.
  - `Cohort.sql`: Cohort analysis logic.
  - `RFM.sql`: RFM segmentation.
  - `Transaccional_RFM_Cohort.sql`: Integrated analysis.
  - `Grafica.sql`: Queries for visualizations.
- **Databases**: Various `.db` files for data storage.
- **Outputs**:
  - `dashboard.html`, `Untitled-2.html`: HTML dashboards for insights.
  - `Unpivot_RFM_Cohort.csv`: Exported analysis data.
- **Case Study**: `caso_tecnomax.pdf` - Business case description.
- **Steps**: `Primer paso`, `Segundo paso` - Likely intermediate notes or steps.

## Usage Instructions

1. Ensure SQLite is installed.
2. Load data from Excel into SQLite (refer to scripts).
3. Run SQL scripts in order: Prepare data, then RFM, Cohort, Integrated.
4. View results in databases or export to CSV.
5. Open HTML dashboards in a browser for visualizations.

## Requirements

- SQLite for database operations.
- A tool to run SQL scripts (e.g., DB Browser for SQLite).
- Browser for HTML dashboards.

## Project Context

This is a university assignment for Seventh Semester, Business Intelligence course, Corte 2.

# Olist E-Commerce BI Dashboard — Delivery, Customer & Seller Performance Analytics

A BI Engineer portfolio project analyzing the Olist Brazilian E-Commerce dataset, covering delivery performance, customer value, and seller efficiency through a dbt-modeled star schema and a Power BI dashboard.

## Business Context

Coming from a background in sales administration and inventory operations, this project revisits the kind of operational questions I used to face day-to-day — how fast are we fulfilling orders, which customers actually drive revenue, and are certain sellers underperforming — but applies a proper analytics engineering workflow to answer them at scale, using a real e-commerce marketplace dataset instead of anecdote.

The goal wasn't just to build a dashboard, but to demonstrate the full BI engineering lifecycle: raw data → tested, documented data models → business-ready visualizations.

## Architecture

```
Olist CSV files (Kaggle)
        │
        ▼
   DuckDB (olist.duckdb)
        │
        ▼
   dbt-duckdb
   ├── staging/       (1:1 cleaned source tables)
   ├── intermediate/  (joins between staging models)
   └── marts/         (business-ready fact tables, tested)
        │
        ▼
   Parquet export
        │
        ▼
   Power BI Desktop
```

**Stack:** DuckDB, dbt-core + dbt-duckdb, Power BI Desktop

**A deliberate constraint, not an oversight:** this project was built with no access to Docker or a PostgreSQL server. Rather than treat that as a blocker, the stack was chosen around it — DuckDB's in-process, file-based design eliminates the need for a database server entirely, while still supporting the same dbt workflow (staging → intermediate → marts, testing, documentation) used in production data warehouses. Power BI connects via exported Parquet files rather than a live ODBC connection, since DuckDB's single-writer file lock would otherwise conflict with an active dbt development session.

## Data Model

Following dbt's staging → intermediate → marts convention:

**Staging** (1:1 with source, cleaned and renamed, materialized as views)
`stg_orders`, `stg_order_items`, `stg_customers`, `stg_sellers`

**Intermediate** (joins, no aggregation)
`int_customer_order_value` — orders joined to customers with per-order totals
`int_order_items_joined_to_sellers` — order items joined to sellers and order dates

**Marts** (business-ready, tested, materialized as tables)

| Mart | Grain | Key Metrics |
|---|---|---|
| `fct_orders` | One row per order | Fulfillment time (days), on-time delivery flag |
| `fct_customer_ltv` | One row per customer | Lifetime value, total orders |
| `fct_seller_performance` | One row per seller | Avg. fulfillment time, items sold |

All marts have dbt tests (`unique`, `not_null`, `accepted_range`) confirming primary key integrity and rejecting impossible values (e.g. negative fulfillment days).

## Key Insights

**1. Customers are overwhelmingly one-time buyers.**
Average orders per customer sits at 1.035 — meaning "lifetime value" in this dataset is close to average order value, not a signal of loyalty. A retention/loyalty program would have limited leverage here; growth is more likely to come from increasing average order value or acquiring new high-ticket customers. The highest-value customer in the dataset (R$13,440) placed a single large order, not a series of repeat purchases.

**2. Seller volume does not correlate with slower fulfillment — if anything, the opposite.**
Plotting fulfillment time against items sold per seller shows that high-volume sellers (500–2,000+ items) cluster tightly around 10–20 day fulfillment times, while the widest variance and slowest outliers come from low-volume sellers. An early read of just the top 5 sellers by volume suggested busier sellers might be slower — that didn't hold up once the full population of 2,970 sellers was visualized, a useful reminder to validate patterns against the full dataset before drawing conclusions.

**3. Outliers were investigated, not deleted.**
One seller shows an average fulfillment time of 190 days on a single item — confirmed as an isolated case, not a data quality issue affecting other sellers. It remains in the underlying data and mart (for transparency) but is filtered out of the scatter chart's visual scale so it doesn't compress the readability of the broader pattern.

## Dashboard

Three pages, each covering one business domain:

- **Logistics** — average fulfillment time, on-time delivery rate, trend over time
- **Customers** — average CLV, average orders per customer, top 10 customers by value
- **Sellers** — fulfillment time vs. sales volume scatter plot, seller performance table

*(Screenshots to be added here)*

## Limitations

- **Snapshot, not live-connected:** Power BI reads from exported Parquet files, not a live DuckDB connection. Re-running the dbt pipeline requires re-exporting before the dashboard reflects updated data.
- **Sell-through rate was dropped.** Olist is an order-marketplace dataset with no true inventory/stock-on-hand data, so a real sell-through metric couldn't be computed without introducing simulated data. Rather than present a fabricated number as fact, this metric was excluded and replaced with the seller performance and CLV metrics above.
- **CLV is historical, not predictive.** Given the short dataset window (2016–2018) and the one-time-buyer pattern, a predictive CLV model would be built on too little repeat-purchase signal to be meaningful. Historical/observed CLV is used instead and documented as such.
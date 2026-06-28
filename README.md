# Superstore-End-to-End-Analytics-Pipeline-SQL-Python-Power-BI-

## Project Overview
This project delivers a comprehensive end-to-end data analysis of the US Superstore business model. It covers the entire data lifecycle: from designing a clean relational database structure and running exploratory data analysis to discovering critical financial leaks and building an interactive executive dashboard.

---

## Data Pipeline Architecture & Tech Stack

- **SQL (Data Modeling & DWH):** Cleaned raw business transactions and transformed a flat table into an optimized **Star Schema**. Designed dimension tables (`dim_customers`, `dim_products`, `dim_date`) and a central fact table (`sales_orders`). Performed advanced metrics including **RFM marketing analysis** and **Pareto (80/20) rule** business logic.
- **Python / Pandas (Exploratory Data Analysis):** Used for advanced data inspection, rapid aggregations, processing datetime attributes, and mathematical validation of corporate business hypotheses.
- **Power BI (Business Intelligence & Reporting):** Developed a multi-page highly interactive dashboard using a modern dark-mode UI, custom DAX metrics, cohort visualization, and time-intelligence trends.

---

## Key Business Insights Uncovered

1. **The Discount Trap:** Python and Power BI analytics mathematically proved that aggressive discounting ($\ge$ 20%) completely destroys profitability, generating a massive total net loss. Meanwhile, low-discount orders remain highly stable, driving the bulk of net profit.
2. **Revenue ≠ Profit (The VIP Illusion):** Customer segmentation revealed severe operational leaks. Certain high-volume clients who appear to be top buyers are actually deeply unprofitable due to excessive discount stacking.
3. **Product Margin Inefficiencies:** Identified specific high-revenue items in furniture and technology categories that act as cash drains, carrying negative profit margins.
4. **Regional Powerhouses:** The **West** region acts as the primary driver of corporate health, leading in both gross sales and net profit, whereas the **Central** region shows the lowest profitability margins despite solid sales volumes.

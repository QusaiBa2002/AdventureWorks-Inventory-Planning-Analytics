
# AdventureWorks-Inventory-Planning-Analytics

End-to-end data analytics and supply chain project focusing on advanced inventory management, FIFO stock aging, stockout tracking, and planning using Power BI and advanced DAX.

<p align="left">
  <img src="https://img.shields.io/badge/POWER%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black" />
  <img src="https://img.shields.io/badge/DAX-00758F?style=for-the-badge&logo=dax&logoColor=white" />
  <img src="https://img.shields.io/badge/ADVANCED-FF5722?style=for-the-badge&logo=databricks&logoColor=white" />
  <img src="https://img.shields.io/badge/DATA%20MODELING-4CAF50?style=for-the-badge&logo=snowflake&logoColor=white" />
  <img src="https://img.shields.io/badge/FIFO%20AGING-3F51B5?style=for-the-badge&logo=supplychain&logoColor=white" />
</p>

## 📌 Business Overview

This project simulates enterprise-level supply chain and inventory control operations using the AdventureWorks dataset. The primary objective is to transform raw inventory movements and sales transactional data into strategic insights through advanced DAX modeling, FIFO stock valuation, and predictive reorder planning.

## 🔑 Key Analytical Models & Features

### 1. Stock Aging & Capital Allocation
* **Total Units Inventory:** Dynamically calculates active inventory units up to any selected date using FIFO movement tracking.
* **Ending Inventory Value:** Computes real-time financial valuation of closing stock based on FIFO layer costs.
* **Aging Categorization:** Classifies inventory health into *Healthy (0-90 days)*, *Watch (91-365 days)*, *Slow (1-2 years)*, and *Dead Stock (Over 2 years)*.
* **Stock Health Ratios:** Tracks capital lockup percentages comparing dead stock value against total inventory value.

### 2. Inventory Turnover & Rotational Velocity
* **Inventory Turnover & DSI:** Evaluates inventory turnover velocity and Days Sales of Inventory to measure how rapidly stock is sold and replaced.
* **Product Rotational Speed Range:** Automatically categorizes items into *Fast Moving*, *Medium Moving*, *Slow Moving*, or *Non-Moving*.
* **ABC Cumulative Pareto:** Implements multi-tier inventory classification (A, B, C classes) based on cumulative sales contribution.

### 3. Safety Stock, ROP & Lead Time Planning
* **Daily Consumption:** Determines average daily demand rates based on historical sales windows.
* **Statistical Safety Stock:** Applies a service-factor formula ($Z = 1.65$ for 95% service level) factoring in demand volatility and lead times.
* **Days on Hand (DOH):** Projects operational runway indicating how many days current stock will last.
* **Reorder Point (ROP):** Establishes automated replenishment triggers by balancing lead-time demand and safety buffers.

### 4. GMROI & Stockout Rate Analysis
* **GMROI:** Measures gross margin return on inventory investment to evaluate capital efficiency.
* **Stockout Rate Percentage:** Tracks daily product unavailability across the timeline to measure fulfillment efficiency.

## 📂 Documentation

* **[DAX_Documentation.md](DAX_Documentation.md):** Complete code and detailed breakdown for all custom DAX measures used in this project.

## Author
**Qusai Al-Barnouti**

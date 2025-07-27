# Retail Sales Data Analysis in R

This repository contains an end-to-end analysis of a retail store's performance using sales, product, inventory, and store data. The project answers key business questions such as sales trends, revenue leaders, inventory distribution, and price sensitivity — all using the R programming language.

---

## Dataset Overview

The project uses the following CSV files:

| File Name       | Description                                      |
|------------------|--------------------------------------------------|
| `sales.csv`      | Sales transactions with units and dates          |
| `products.csv`   | Product-level info: name, cost, and price        |
| `inventory.csv`  | Product stock levels across store locations      |
| `stores.csv`     | Store info including names, cities, and locations|

---

## Required R Packages

Before running the analysis, make sure to install the following packages:

```r
install.packages(c("readr", "dplyr", "lubridate", "tidyr"))
```

---

## Data Cleaning

- Removed `$` symbols and converted `Product_Cost` and `Product_Price` to numeric
- Converted `Units` to numeric and parsed `Date` as date
- Ensured `Stock_On_Hand` is numeric for inventory data

---

## Business Questions Answered

### Q1(i) — Number of Transactions in 2017
- Filtered `sales.csv` for year `2017`
- Counted total transactions in that year

---

### Q1(ii) — Product with the Highest Revenue
- Merged `sales.csv` and `products.csv`
- Calculated `Revenue = Product_Price * Units`
- Identified the product with the **highest total revenue**
- Listed the product name and the store(s) where it was available

---

### Q1(iii) — Cities, Locations & Distribution
- Counted total unique cities and distribution points
- Summarized quantity of each product delivered in each city

---

### Q1(iv) — Lowest Average Inventory Store
- Calculated the average `Stock_On_Hand` per store
- Found the store with the **lowest average inventory**

---

### Q1(v) — Monthly Sales & Profit, Top/Bottom Stores
- Computed monthly `Sales` and `Profit`
- Identified:
  - Best and worst performing stores
  - Cities with highest and lowest sales/profit

---

###  Q1(vi) — Most Expensive Products
- Ranked products by `Product_Cost`
- Reported the **3rd most expensive** product by name
- Noted: Product names do **not** include brand separators (`-`), so splitting was skipped

---

### Q1(vii) — Price Elasticity of Demand (PED)

- Calculated:
  - % change in quantity sold and price month-to-month
  - `PED = (%Δ Quantity) / (%Δ Price)`
- Identified:
  - Top 3 most **price-sensitive (elastic)** products
  - Top 3 most **price-insensitive (inelastic)** products

 **Strategy Suggestion**:
- **Elastic products**: Lower prices to drive volume (e.g. during promotions)
- **Inelastic products**: Raise prices moderately to increase profit without losing sales

---
## Repository Structure

```
.
├── README.md
├── retail_analysis.R        # R script containing all questions & answers
├── data/
│   ├── sales.csv
│   ├── products.csv
│   ├── inventory.csv
│   └── stores.csv
└── output/
    └── (optional CSV/tables if you choose to save results)
```

---

## Author

- **Altagi Abdallah Bakheit Abdelgadir**

---

## 📄 License

This project is for educational purposes only, submitted as coursework for the course **Statistical Programming** at Albukhary International University.


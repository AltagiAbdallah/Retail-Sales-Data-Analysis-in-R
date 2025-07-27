# Load necessary packages at the very beginning
library(readr)
library(dplyr)
library(lubridate)
library(tidyr) 

################################################################################
# DATA IMPORT AND INITIAL CLEANING
################################################################################

# Import all four datasets

# Import all four datasets using read.csv() and print their summaries
sales_data <- read.csv("C:/Users/HP/Desktop/sem2-yr2/SPrograming/Assignment/sales.csv")
cat("\nSummary of sales_data:\n")
summary(sales_data)

products_data <- read.csv("C:/Users/HP/Desktop/sem2-yr2/SPrograming/Assignment/products.csv")
cat("\nSummary of products_data:\n")
summary(products_data)

inventory_data <- read.csv("C:/Users/HP/Desktop/sem2-yr2/SPrograming/Assignment/inventory.csv")
cat("\nSummary of inventory_data:\n")
summary(inventory_data)

stores_data <- read.csv("C:/Users/HP/Desktop/sem2-yr2/SPrograming/Assignment/stores.csv")
cat("\nSummary of stores_data:\n")
summary(stores_data)


# --- Comprehensive Data Cleaning (Apply to all relevant dataframes once) ---

# Clean 'products_data': Remove '$' from Product_Cost and Product_Price, then convert to numeric
products_data <- products_data %>%
  mutate(
    Product_Cost = as.numeric(gsub("\\$", "", Product_Cost)),
    Product_Price = as.numeric(gsub("\\$", "", Product_Price))
  )

# Clean 'sales_data': Ensure 'Units' is numeric and 'Date' is a proper date format
sales_data <- sales_data %>%
  mutate(
    Units = as.numeric(Units),
    Date = ymd(Date) # Assuming YYYY-MM-DD format
  )

# Clean 'inventory_data': Ensure 'Stock_On_Hand' is numeric (it usually imports correctly, but good practice)
inventory_data <- inventory_data %>%
  mutate(Stock_On_Hand = as.numeric(Stock_On_Hand))

print("All datasets imported and initially cleaned.")
# You can uncomment these to see the head of cleaned dataframes
# print(head(sales_data)); print(head(products_data)); print(head(inventory_data)); print(head(stores_data))


################################################################################
# QUESTION 1 (i): Filter sales for 2017/2020, count transactions.
################################################################################

# Filter sales transactions for the year 2017 (or 2020 as per assignment, lecturer's choice was 2017 earlier)
sales_filtered_year <- sales_data %>%
  filter(year(Date) == 2017) # Change to 2020 if that's the final year you're using

num_transactions_filtered_year <- nrow(sales_filtered_year)

cat("\n--- Question 1 (i) ---\n")
print(paste("Number of sales transactions in 2017:", num_transactions_filtered_year))


################################################################################
# QUESTION 1 (ii): Total revenue per product, highest revenue product, its details.
################################################################################

# Calculate Total Revenue for each product and find the highest revenue product
product_revenue <- sales_data %>%
  inner_join(products_data, by = "Product_ID") %>% # Join to get Product_Price
  mutate(Revenue = Product_Price * Units) %>%      # Calculate Revenue
  group_by(Product_ID) %>%                         # Group by Product_ID
  summarise(TotalRevenue = sum(Revenue, na.rm = TRUE)) %>% # Sum revenue for each product
  ungroup() %>%
  arrange(desc(TotalRevenue)) # Arrange to easily find highest

highest_revenue_product <- product_revenue %>% slice(1)
highest_revenue_product_id <- highest_revenue_product$Product_ID

product_name_highest_revenue <- products_data %>%
  filter(Product_ID == highest_revenue_product_id) %>%
  select(Product_Name)

stores_with_highest_revenue_product <- inventory_data %>%
  filter(Product_ID == highest_revenue_product_id) %>%
  distinct(Store_ID)

cat("\n--- Question 1 (ii) ---\n")
print("Total Revenue for Each Product (top few):")
print(head(product_revenue))
print("Product with the Highest Total Revenue:")
print(highest_revenue_product)
print(paste("The Product_ID with the highest total revenue is:", highest_revenue_product_id))
print("Product Name for the Highest Revenue Product_ID:")
print(product_name_highest_revenue)


################################################################################
# QUESTION 1 (iii): Cities/Locations count, total quantity per product per city.
################################################################################

# Count unique cities and locations
num_cities <- stores_data %>% distinct(Store_City) %>% nrow()
num_locations <- stores_data %>% distinct(Store_Location) %>% nrow()

# Calculate total quantity of each product distributed in each city
product_quantity_by_city <- inventory_data %>%
  inner_join(stores_data, by = "Store_ID") %>% # Join to get Store_City
  group_by(Store_City, Product_ID) %>%
  summarise(TotalQuantityDistributed = sum(Stock_On_Hand, na.rm = TRUE)) %>%
  ungroup()

cat("\n--- Question 1 (iii) ---\n")
print(paste("Number of cities where stores are operating:", num_cities))
print(paste("Number of unique distribution locations where stores are operating:", num_locations))
print("Total quantity of each product distributed in each city (top few):")
print(head(product_quantity_by_city))


################################################################################
# QUESTION 1 (iv): Average quantity per store, lowest average quantity store.
################################################################################

# Calculate average Stock_On_Hand for each Store_ID
average_quantity_by_store <- inventory_data %>%
  group_by(Store_ID) %>%
  summarise(AverageQuantityAvailable = mean(Stock_On_Hand, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(AverageQuantityAvailable) # Arrange to find lowest easily

lowest_average_quantity_store <- average_quantity_by_store %>% slice(1)
lowest_avg_quantity_store_id <- lowest_average_quantity_store$Store_ID

cat("\n--- Question 1 (iv) ---\n")
print("Average Quantity Available per Store_ID (top few):")
print(head(average_quantity_by_store))
print("Store_ID with the Lowest Average Quantity Available:")
print(lowest_average_quantity_store)
print(paste("The Store_ID with the lowest average quantity available is:", lowest_avg_quantity_store_id))


################################################################################
# QUESTION 1 (v): Sales/Profit by month, highest/lowest by store/location/city.
################################################################################

# Calculate Total Sales (Revenue) and Profit by Month
sales_profit_data_combined <- sales_data %>%
  inner_join(products_data, by = "Product_ID") %>%
  mutate(
    Sales = Product_Price * Units,
    Profit = (Product_Price - Product_Cost) * Units,
    Month = month(Date, label = TRUE, abbr = FALSE)
  )

monthly_summary <- sales_profit_data_combined %>%
  group_by(Month) %>%
  summarise(
    TotalSales = sum(Sales, na.rm = TRUE),
    TotalProfit = sum(Profit, na.rm = TRUE),
    .groups = 'drop'
  )

cat("\n--- Question 1 (v) ---\n")
cat("1. Total Sales and Profit by Month:\n")
print(monthly_summary)

# Identify Store and Location with Highest/Lowest Total Sales and Profit
store_location_summary <- sales_profit_data_combined %>%
  inner_join(stores_data, by = "Store_ID") %>%
  group_by(Store_ID, Store_Name, Store_Location) %>%
  summarise(
    TotalSales = sum(Sales, na.rm = TRUE),
    TotalProfit = sum(Profit, na.rm = TRUE),
    .groups = 'drop'
  )

# Extract highest/lowest performers for stores
highest_sales_store <- store_location_summary %>% arrange(desc(TotalSales)) %>% slice(1)
lowest_sales_store <- store_location_summary %>% arrange(TotalSales) %>% slice(1)
highest_profit_store <- store_location_summary %>% arrange(desc(TotalProfit)) %>% slice(1)
lowest_profit_store <- store_location_summary %>% arrange(TotalProfit) %>% slice(1)

cat("\n2. Store and Location Performance:\n")
cat("   - Highest Sales Store:\n")
print(highest_sales_store)
cat("   - Lowest Sales Store:\n")
print(lowest_sales_store)
cat("   - Highest Profit Store:\n")
print(highest_profit_store)
cat("   - Lowest Profit Store:\n")
print(lowest_profit_store)


# Identify City with Highest/Lowest Sales and Profit
city_summary <- sales_profit_data_combined %>%
  inner_join(stores_data, by = "Store_ID") %>%
  group_by(Store_City) %>%
  summarise(
    TotalSales = sum(Sales, na.rm = TRUE),
    TotalProfit = sum(Profit, na.rm = TRUE),
    .groups = 'drop'
  )

# Extract highest/lowest performers for cities
highest_sales_city <- city_summary %>% arrange(desc(TotalSales)) %>% slice(1)
lowest_sales_city <- city_summary %>% arrange(TotalSales) %>% slice(1)
highest_profit_city <- city_summary %>% arrange(desc(TotalProfit)) %>% slice(1)
lowest_profit_city <- city_summary %>% arrange(TotalProfit) %>% slice(1)

cat("\n3. City Performance:\n")
cat("   - Highest Sales City:\n")
print(highest_sales_city)
cat("   - Lowest Sales City:\n")
print(lowest_sales_city)
cat("   - Highest Profit City:\n")
print(highest_profit_city)
cat("   - Lowest Profit City:\n")
print(lowest_profit_city)



################################################################################
# QUESTION 1 (vi) - Arrange products by cost, separate ProductName, find 3rd expensive brand.
################################################################################

# Arrange products by Product_Cost in descending order and find the Product_Name of the 3rd most expensive one
third_most_expensive_product_name_result <- products_data %>%
  arrange(desc(Product_Cost)) %>% # Arrange in descending order of cost
  slice(3) %>% # Select the third row
  pull(Product_Name) # Extract just the Product_Name value

cat("\n--- Question 1 (vi) ---\n")
print(paste("The Product Name of the third most expensive product is:", third_most_expensive_product_name_result))

# Explanation for the original issue:
# The original instruction to "separate ProductName into Product and Brand where Brand follows '-'"
# could not be fulfilled because the 'products.csv' data does not contain
# the " - " delimiter in the Product_Name column.
# Therefore, we identified the full Product_Name of the third most expensive product instead.




################################################################################
# QUESTION 1 (vii): Analyze Price Elasticity of Demand
################################################################################


# --- Essential Code for Question 1 (vii) ---

# Step 1: Join sales_data with products_data and Calculate Revenue
sales_product_joined <- sales_data %>%
  inner_join(products_data, by = "Product_ID") %>%
  mutate(Revenue = Product_Price * Units)

# Step 2: Aggregate Sales Data by Product_ID and Month
monthly_product_summary <- sales_product_joined %>%
  mutate(YearMonth = floor_date(Date, "month")) %>%
  group_by(Product_ID, YearMonth) %>%
  summarise(
    Total_Quantity_Sold = sum(Units, na.rm = TRUE),
    Total_Revenue = sum(Revenue, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(Average_Price = Total_Revenue / Total_Quantity_Sold) %>%
  filter(!is.na(Average_Price) & !is.infinite(Average_Price) & Total_Quantity_Sold > 0) %>%
  arrange(Product_ID, YearMonth)

# Step 3: Calculate Percentage Changes and Price Elasticity
ped_data <- monthly_product_summary %>%
  group_by(Product_ID) %>%
  arrange(YearMonth) %>%
  mutate(
    Lag_Total_Quantity_Sold = lag(Total_Quantity_Sold),
    Lag_Average_Price = lag(Average_Price),
    Pct_Change_Quantity = ((Total_Quantity_Sold - Lag_Total_Quantity_Sold) / Lag_Total_Quantity_Sold) * 100,
    Pct_Change_Price = ((Average_Price - Lag_Average_Price) / Lag_Average_Price) * 100
  ) %>%
  ungroup() %>%
  filter(!is.na(Pct_Change_Quantity) & !is.na(Pct_Change_Price) & Pct_Change_Price != 0) %>%
  mutate(
    PED = Pct_Change_Quantity / Pct_Change_Price,
    Abs_PED = abs(PED)
  ) %>%
  filter(Abs_PED < 100) # Filter out extremely high elasticity values

# Step 4: Identify Most and Least Sensitive Products
average_ped_by_product <- ped_data %>%
  group_by(Product_ID) %>%
  summarise(
    Average_Abs_PED = mean(Abs_PED, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  inner_join(products_data %>% select(Product_ID, Product_Name), by = "Product_ID") %>%
  filter(!is.na(Average_Abs_PED))

most_sensitive_products <- average_ped_by_product %>%
  arrange(desc(Average_Abs_PED)) %>%
  slice(1:3) # Top 3 most sensitive products (can adjust number)

least_sensitive_products <- average_ped_by_product %>%
  arrange(Average_Abs_PED) %>%
  slice(1:3) # Top 3 least sensitive products (can adjust number)

# --- Print Key Results ---
cat("\n--- QUESTION 2 (vii): Price Elasticity of Demand Analysis ---\n")

cat("\nMost Price-Sensitive (Elastic) Products:\n")
print(most_sensitive_products)

cat("\nLeast Price-Sensitive (Inelastic) Products:\n")
print(least_sensitive_products)

# --- Step 5: Concise Discussion on Pricing Strategies ---
cat("\n--- Concise Discussion on Pricing Strategies ---\n")
cat("Price elasticity of demand (PED) measures how sensitive quantity sold is to price changes.\n\n")

cat("For **Elastic Products** (|PED| > 1, like those listed as 'Most Price-Sensitive'):\n")
cat("  - Demand changes significantly with price. Consider price reductions to boost sales volume and total revenue (e.g., during promotions).\n")
cat("  - Price increases can lead to substantial drops in sales. Be cautious with price hikes.\n")

cat("\nFor **Inelastic Products** (|PED| < 1, like those listed as 'Least Price-Sensitive'):\n")
cat("  - Demand is less affected by price changes. Small price increases can boost profit margins and total revenue without losing many sales.\n")
cat("  - Discounts may not significantly increase sales volume, making them less effective as a primary strategy.\n")

cat("\nOverall, the retail chain can use this analysis for **differentiated pricing**, applying targeted promotions for elastic items and considering strategic price adjustments for inelastic items to optimize overall revenue and profit.\n")
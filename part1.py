import numpy as np
import pandas as pd

list_orders = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\List_of_Orders.csv", index_col = 0)

print(list_orders.head())
print(list_orders)
print(list_orders.isnull().sum())

list_cleaned = list_orders.dropna(how="all")
print(list_cleaned.isnull().sum())
print(list_cleaned)

list_cleaned.to_csv("List_orders_cleaned.csv")

order_datails = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\Order_Details.csv", index_col = 0)

print(order_datails)
print(order_datails.isnull().sum())

sales = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\Sales_target.csv", header = 0)

sales['Month of Order Date'] = pd.to_datetime(sales['Month of Order Date'], format='%b-%y')

print(sales)

sales.to_csv("Sales_target.csv", index = False)

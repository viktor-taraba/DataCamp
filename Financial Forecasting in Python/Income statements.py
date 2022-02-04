# Set the sales variable and cost of goods sold (cogs) variables
sales = 8000
cogs = 5400

# Calculate the gross profit (gross_profit)
gross_profit = sales - cogs

# Print the gross profit
print("The gross profit is {}.".format(gross_profit))

# Calculate the gross profit margin
gross_profit_margin = gross_profit / sales

# Print the gross profit margin
print("The gross profit margin is {}.".format(gross_profit_margin))

# Create and print the opex list
opex = [admin, travel, training, marketing, insurance]
print(opex)

# Calculate and print net profit
net_profit = gross_profit - sum(opex)
print("The net profit is {}.".format(net_profit))

# Set variables units sold and sales price of the T-shirts (basic and custom)
salesprice_basic = 15
salesprice_custom = 25

# Calculate the combined sales price taking into account the sales mix
average_sales_price = (salesprice_basic * 0.6) + (salesprice_custom * 0.4)

# Calculate the total sales for next month
sales_USD = forecast_units * average_sales_price

# Print the total sales
print("Next month's forecast sales figure is {:.2f} USD.".format(sales_USD))

# Forecast the sales of January
sales_january = units_january * sales_price

# Forecast the discounted price
dsales_price = sales_price * 0.6

# Forecast the sales of February
sales_february = (sales_price * units_february * 0.55) + (dsales_price * units_february * 0.45)

# Print the forecast sales for January and February
print("The forecast sales for January and February are {} and {} USD respectively.".format(sales_january, sales_february))

# From previous step
fixed_costs = machine_rental 
variable_costs_per_unit = material_costs_per_unit + labor_costs_per_unit
cogs_jan = (units_jan * variable_costs_per_unit) + fixed_costs
cogs_feb = (units_feb * variable_costs_per_unit) + fixed_costs

# Calculate the unit cost for January and February
unit_cost_jan = cogs_jan / units_jan
unit_cost_feb = cogs_feb / units_feb

# Print the January and February cost per unit
print("The cost per unit for January and February are {} and {} USD respectively.".format(unit_cost_jan, unit_cost_feb))

# Calculate the break-even point (in units) for Wizit
break_even = fixed_costs /(sales_price - variable_costs_per_unit)

# Print the break even point in units
print("The break even point is {} units.".format(break_even))

# Forecast the gross profit for January and February
gross_profit_jan = (sales_price*units_jan) - cogs_jan
gross_profit_feb = (sales_price*units_feb) - cogs_feb 

# Print the gross profit for January and February
print("The gross profit for January and February are {} and {} USD respectively.".format(gross_profit_jan, gross_profit_feb))

# Choose some interesting metrics
interesting_metrics = ['Revenue', 'Gross profit', 'Total operating expenses', 'Net income']

# Filter for rows containing these metrics
filtered_income_statement = income_statement[income_statement.metric.isin(interesting_metrics)]

# See the result
print(filtered_income_statement)

revenue_metric = ['Revenue']

# Filter for rows containing the revenue metric
filtered_income_statement = income_statement[income_statement.metric.isin(revenue_metric)]

# Get the number of columns in filtered_income_statement
n_cols = len(filtered_income_statement.columns)

# Insert a column in the correct position containing the column 'Forecast'
filtered_income_statement.insert(7, 'Forecast', 13000) 

# See the result
print(filtered_income_statement)

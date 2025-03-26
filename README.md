# Indian-Sales-Analysis
**ЧАСТИНА 1 ПІДГОТОВКА В Python**

Так як у cvs файлів є пусті рядки, через які я не можу коректно підв’язати дані до постгре, я використаю пайтон, щоб очистити їх. Через sql це важче, адже потрібно вчурну все робити, міняти формати і тд

1. Використовую Visual Studio

```python
import numpy as np
import pandas as pd
```

1. Підключаю файл

```python
list_orders = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\List_of_Orders.csv", index_col = 0)

print(list_orders.head())
print(list_orders)
print(list_orders.isnull().sum())
```

1. Тобто є 60 пустих значень, які потрібно видалити. В цьому випадку це просто пусті ядки на всі стовбчики

```python
list_cleaned = list_orders.dropna(how="all")
print(list_cleaned.isnull().sum())
print(list_cleaned)
```

1. Зайве почистили, отримати 500 значень. Тепер можна зберегти готову таблицю

```python
list_cleaned.to_csv("List_orders_cleaned.csv")
```

1. Перевіряю наступіні дві таблиці. В них немає null значень.

```python
import numpy as np
import pandas as pd

order_datails = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\Order_Details.csv", index_col = 0)

print(order_datails)
print(order_datails.isnull().sum())
```

1. Але у таблиці sales_target є колонка з датою, формат якої потрібно змінити на правильний.

```python
import numpy as np
import pandas as pd

sales = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\Sales_target.csv", header = 0)

sales['Month of Order Date'] = pd.to_datetime(sales['Month of Order Date'], format='%b-%y')

print(sales)

sales.to_csv("Sales_target.csv", index = False)
```

**ЧАСТИНА 2 ПІДКЛЮЧЕННЯ**

1. Скачала файли з кегля https://www.kaggle.com/datasets/benroshan/ecommerce-data?select=List+of+Orders.csv
2. Створила нову базу даних в постгре
3. Створюю 3 таблиці

```sql
CREATE TABLE list_of_orders (
Order_ID TEXT PRIMARY KEY,
Order_date DATE,
Customer_name TEXT,
State TEXT,
City TEXT
);

CREATE TABLE order_details (
Order_ID TEXT,
Amount NUMERIC,
Profit NUMERIC,
Quantity INT,
Category TEXT,
Sub_category TEXT
);

CREATE TABLE sales_target (
Date_of_order DATE,
Category TEXT,
Target NUMERIC
);
```

1. Підключаю csv файли до таблиць

![image.png](attachment:92f14c85-9825-4048-b388-5d0e19e05dae:d99bbc5f-04d8-466c-8ad3-72b2a6eecfb5.png)

1. Переглядаю таблиці, так як там вцілому не багато даних, тому легко передивитись. Також, за допомогою ф-ї DISTINCT() переглядаю в категорія, містах, регіонах чи немає помилок і не коректних даних. Дані готові для подальшої роботи.

```sql
SELECT *
FROM list_of_orders
```

```sql
SELECT *
FROM order_details
```

```sql
SELECT *
FROM sales_target
```

```sql
SELECT DISTINCT(order_details.sub_category)
FROM order_details
ORDER BY sub_category
```

**ЧАСТИНА 3 СТВОРЕННЯ ОДНІЄЇ ТАБЛИЦІ**

1. Таблиця sales_target зараз особливо не цікавить, так як у ній зведені результати по категоріям і місяцям. Тому поки працюватиму лише з таблицею list_of_orders та orders_details. Хочу зробити одну загальну таблицю, щоб потім було зручно працювати в табло.

```sql
CREATE TABLE orders AS
SELECT lo.*, od.amount, od.profit, od.quantity, od.category, od.sub_category
FROM list_of_orders AS lo
JOIN order_details AS od
ON lo.order_id = od.order_id
```

Отримала таблицю з 1500 рядками. 

1. Змінюю назву колонки amount на price

```sql
ALTER TABLE orders
RENAME COLUMN amount TO price
```

1. Так, як у таблиці є лише стовбчик профіту( тобто чистого прибутку), вирішила додати стовбці собівартості та доходу на кожну підкатегорію товаів.

```sql
ALTER TABLE orders
ADD COLUMN subcat_cost NUMERIC,
ADD COLUMN subcat_revenue NUMERIC,
ADD COLUMN cost_per_unit NUMERIC
```

Для зручності створила стобчик собівартості на одиницю підкатегорії.

```sql
UPDATE orders
SET cost_per_unit = price - (profit/quantity)

UPDATE orders
SET cost_per_unit = ROUND(cost_per_unit,2)
```

Розраховую повну собівартість підкатегорії

```sql
UPDATE orders
SET subcat_cost = cost_per_unit * quantity
```

Прибуток з підкатегорії

```sql
UPDATE orders
SET subcat_revenue = price*quantity
```

1. Змінюю штат для міста Hyderabad на правильний

```sql
UPDATE orders
SET state = 'Telangana'
WHERE city = 'Hyderabad'
```

1. Всі інші розрахунки робитиму безпосередньо в Tableau.

**ЧАСТИНА 4 АНАЛІЗ В TABLEAU**

Підключаю файли orders та sales_target до Tableau Public через Text File.

***ЛИСТИ ДЛЯ ПЕРШОГО ДАШБОРДУ (Executive Summary)***

1. **Лист 1 ( КРІ indicators)**
- *Загальний дохід* (Total revenue) Тут розраховую через sum([subcat_revenue]) - автоматично;
- *Загальний прибуток* (Total profit) Аналогічно доходу;
- *Рентабельність (%) ROS* (Роблю через Calculated Field: `SUM([profit])/SUM([subcat_revenue])` і формат змінюю через налаштування);
- *Середній чек* (Роблю через Calculated Field: Total revenue/Number of orders);

*Number of orders теж розраховую через Calculated Field: `COUNTD([order_id]))`;

- *Кількість унікальних замовників* (Calculated Field: `COUNTD([customer_name]))`;
1. **Лист 2 (Revenue Trend by Month (лінійний графік))** 

*Спочатку хотіла зробити revenue та profit  на одному графіку (з подвійною віссю), але виглядає не дуже, спотворюються результати, адже профіт набагато менший за revenue.

1. **Лист 3 (Revenue & Profit Trend by Month (bar char))**
2. **Лист 4 (Sales Map by State (теплова карта прибутку))**

*Тут помітила, що у вихідних даних місто Hyderabad відноситься не до того штату, тому повертаюсь в постгре і змінюю

***ЛИСТИ ДЛЯ ДРУГОГО ДАШБОРТУ (Geographic Sales Analysis)***

1. **Лист 1 (Sales Map by State (теплова карта прибутку))**

*Тут помітила, що у вихідних даних місто Hyderabad відноситься не до того штату, тому повертаюсь в постгре і змінюю

1. **Лист 2 ТОП-10 штатів за к-тю замовлень (горизонтальні стовпчасті діаграми).**
2. **Лист 3 ТОП-10 міст за к-тю замовлень (горизонтальні стовпчасті діаграми).**

*Тут було складно налаштувати всі інтерактиви, тому використала параметр - розрахункове поле ранк, а ще акшнс в дашборді.

***ЛИСТИ ДЛЯ ТРЕТЬОГО ДАШБОРДУ (Product Analysis)***

1. **Лист 1 Частка категорій у загальному прибутку (кругова діаграма).**
2. **Лист 2 ТОП-5 підкатегорій за продажами (бар-чарт).**
3. **Лист 3 Кількість проданих одиниць vs. прибуток (Scatter plot).**

Готовий дашборд: https://public.tableau.com/app/profile/yevheniia.nechai/viz/IndianSalesAnalysis/Salesandprofitabilityanalysis?publish=yes

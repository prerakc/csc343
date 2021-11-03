-- Best and Worst Categories

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
    month TEXT NOT NULL,
    highestCategory TEXT NOT NULL,
    highestSalesValue FLOAT NOT NULL,
    lowestCategory TEXT NOT NULL,
    lowestSalesValue FLOAT NOT NULL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS LineItemSales CASCADE;
DROP VIEW IF EXISTS MonthlyCategorySalesOverZero CASCADE;
DROP VIEW IF EXISTS Months CASCADE;
DROP VIEW IF EXISTS Categories CASCADE;
DROP VIEW IF EXISTS MonthsCategoriesCP CASCADE;
DROP VIEW IF EXISTS MonthlyCategorySales CASCADE;
DROP VIEW IF EXISTS HighestMonthlyCategories CASCADE;
DROP VIEW IF EXISTS LowestMonthlyCategories CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW LineItemSales AS
SELECT d, Item.IID, category, price, quantity, price * quantity as sale
FROM
    Purchase
    JOIN LineItem ON Purchase.PID = LineItem.PID
    JOIN Item ON LineItem.IID = Item.IID
WHERE EXTRACT(YEAR FROM d) = '2020';

CREATE VIEW MonthlyCategorySalesOverZero AS
SELECT to_char(d, 'MM') AS month, category, sum(sale) as sales
FROM LineItemSales
GROUP BY month, category
ORDER BY month ASC, sales DESC;

CREATE VIEW Months AS
SELECT to_char(DATE '2014-01-01' + (interval '1 month' * generate_series(0,11)), 'MM') AS month;

CREATE VIEW Categories AS
SELECT DISTINCT category
FROM Item;

CREATE VIEW MonthsCategoriesCP AS
SELECT *
FROM Months CROSS JOIN Categories;

CREATE VIEW MonthlyCategorySales AS
SELECT month, category, COALESCE(sales, 0) as sales
FROM MonthlyCategorySalesOverZero RIGHT JOIN MonthsCategoriesCP USING (month, category);

CREATE VIEW HighestMonthlyCategories AS
SELECT month, category as highestCategory, sales as highestSalesValue
FROM MonthlyCategorySales X 
WHERE sales >= ALL (
    SELECT sales
    FROM MonthlyCategorySales Y
    WHERE X.month = Y.month
);

CREATE VIEW LowestMonthlyCategories AS
SELECT month, category as lowestCategory, sales as lowestSalesValue
FROM MonthlyCategorySales X 
WHERE sales <= ALL (
    SELECT sales
    FROM MonthlyCategorySales Y
    WHERE X.month = Y.month
);


-- Your query that answers the question goes below the "insert into" line:
insert into q4
(
    SELECT *
    FROM HighestMonthlyCategories JOIN LowestMonthlyCategories USING (month)
);

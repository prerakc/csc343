-- Best and Worst Categories

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q4 CASCADE;
DROP TABLE IF EXISTS months CASCADE;

CREATE TABLE months (
    month INTEGER
);

INSERT INTO months VALUES 
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

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
DROP VIEW IF EXISTS PurchaseDates CASCADE;
DROP VIEW IF EXISTS PurchaseExistCat CASCADE;
DROP VIEW IF EXISTS placeholder CASCADE;
DROP VIEW IF EXISTS PurchaseCat CASCADE;
DROP VIEW IF EXISTS highest CASCADE;
DROP VIEW IF EXISTS highestCat CASCADE;
DROP VIEW IF EXISTS lowest CASCADE;
DROP VIEW IF EXISTS lowestCat CASCADE;

---- create month category placeholder
Create VIEW placeholder AS
Select month, category, 0 as totalPrice from
((select DISTINCT category from Item) as item cross join (select month from months) as month) as monthCat;  

---- purchases for each month that exists:
Create VIEW PurchaseDates AS
select PID, IID, category, quantity, price*quantity as totalPrice, EXTRACT(MONTH FROM d) as month
FROM Purchase NATURAL JOIN LineItem NATURAL JOIN Item
WHERE EXTRACT(YEAR FROM d) = 2020
Order BY month;

---- purchases ordered by categories for each month that exists:
Create VIEW PurchaseExistCat AS
select month, category, sum(totalPrice) as totalPrice
from PurchaseDates
GROUP BY category, month
order by month;

---- purchases ordered by categories for each month that exists:
Create VIEW PurchaseCat AS
(select * from placeholder 
where not exists (select month from PurchaseExistCat 
    where placeholder.month = PurchaseExistCat.month
    and placeholder.category = PurchaseExistCat.category) 
UNION select * from PurchaseExistCat)
order by month;

---- highest for each month
Create VIEW highest AS
select month, max(totalPrice) as highestSalesValue from PurchaseCat
GROUP by month;

---- highest cat for each month
Create VIEW highestCat AS
select month as highMonth, category as highestCategory, totalPrice as highestSalesValue from PurchaseCat 
where exists (select month, highestSalesValue
    from highest 
    where PurchaseCat.month = highest.month and PurchaseCat.totalPrice = highest.highestSalesValue)
Order by month;

---- lowest for each month
Create VIEW lowest AS
select month, min(totalPrice) as lowestSalesValue from PurchaseCat
GROUP by month;

---- lowest cat for each month
Create VIEW lowestCat AS
select month, category as lowestCategory, totalPrice as lowestSalesValue from PurchaseCat 
where exists (select month, lowestSalesValue
    from lowest 
    where PurchaseCat.month = lowest.month and PurchaseCat.totalPrice = lowest.lowestSalesValue)
Order by month;

---- lowest cat and highest cat for each month
Create VIEW LowHighCat AS
Select month, highestCategory, highestSalesValue, lowestCategory, lowestSalesValue
from highestCat cross join lowestCat 
where highestCat.highmonth = lowestCat.month;

-- Your query that answers the question goes below the "insert into" line:
insert into q4(
    select * from LowHighCat
)
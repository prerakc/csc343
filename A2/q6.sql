--Year-over-year sales

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6 (
    IID INT NOT NULL,
    Year1 INT NOT NULL,
    Year1Average FLOAT NOT NULL,
    Year2 INT NOT NULL,
    Year2Average FLOAT NOT NULL,
    YearOverYearChange FLOAT NOT NULL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Months CASCADE;
DROP VIEW IF EXISTS earliestYear CASCADE;
DROP VIEW IF EXISTS latestYear CASCADE;
DROP VIEW IF EXISTS YearRange CASCADE;
DROP VIEW IF EXISTS YearMonthItemCombos CASCADE;
DROP VIEW IF EXISTS TotalUnitSalesOverZero CASCADE;
DROP VIEW IF EXISTS TotalUnitSales CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW Months AS
SELECT generate_series(1,12) AS month;

CREATE VIEW earliestYear AS
SELECT EXTRACT(YEAR FROM d) as ey
FROM Purchase
ORDER BY EXTRACT(YEAR FROM d) ASC
LIMIT 1;

CREATE VIEW latestYear AS
SELECT EXTRACT(YEAR FROM d) as ly
FROM Purchase
ORDER BY EXTRACT(YEAR FROM d) DESC
LIMIT 1;

CREATE VIEW YearRange AS
SELECT generate_series(
    CAST(ey AS INTEGER),
    CAST(ly AS INTEGER)
) AS year
FROM earliestYear, latestYear;

CREATE VIEW YearMonthItemCombos AS
SELECT *
FROM (SELECT * FROM YearRange, Months) YearMonths, (SELECT IID FROM Item) Items;

CREATE VIEW TotalUnitSalesOverZero AS
SELECT
    CAST(EXTRACT(YEAR FROM d) AS INTEGER) AS year,
    CAST(EXTRACT(MONTH FROM d) AS INTEGER) AS month,
    Item.IID,
    sum(quantity) as sales
FROM
    Purchase
    JOIN LineItem ON Purchase.PID = LineItem.PID
    JOIN Item ON LineItem.IID = Item.IID
GROUP BY EXTRACT(YEAR FROM d), EXTRACT(MONTH FROM d), Item.IID;

CREATE VIEW TotalUnitSales AS
SELECT year, month, IID, COALESCE(sales, 0) as sales
FROM TotalUnitSalesOverZero RIGHT JOIN YearMonthItemCombos USING (year, month, IID);

CREATE VIEW AverageMonthlyUnitSales AS
SELECT year, IID, avg(sales) as average
FROM TotalUnitSales
GROUP BY (year, IID);


-- Your query that answers the question goes below the "insert into" line:
insert into q6
(
    SELECT
        X.IID,
        X.year AS firstYear,
        X.average AS firstNameAverage,
        Y.year AS secondYear,
        Y.average AS secondYearAverage,
        CASE
            WHEN X.average = 0.0 AND Y.average != 0.0 THEN FLOAT 'Infinity'
            WHEN X.average != 0.0 AND Y.average = 0.0 THEN FLOAT '-100'
            WHEN X.average = 0.0 AND Y.average = 0.0 THEN FLOAT '0'
            ELSE (100*(Y.average - X.average)/X.average)::FLOAT
        END AS change
    FROM AverageMonthlyUnitSales X, AverageMonthlyUnitSales Y
    WHERE Y.year - X.year = 1 AND X.IID = Y.IID
);

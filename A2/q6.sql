--Year-over-year sales

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q6 CASCADE;
DROP TABLE IF EXISTS months CASCADE;

CREATE TABLE months (
    month INTEGER
);

INSERT INTO months VALUES 
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

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
DROP VIEW IF EXISTS itemMonthPlaceholder CASCADE;
DROP VIEW IF EXISTS purchaseTotal CASCADE;
DROP VIEW IF EXISTS unitSales CASCADE;
DROP VIEW IF EXISTS avgSales CASCADE;
DROP VIEW IF EXISTS FixAvgSales CASCADE;
DROP VIEW IF EXISTS yoySales CASCADE;
DROP VIEW IF EXISTS sales CASCADE;

-- Define views for your intermediate steps here:

---- list of items, months and sales with placeholders
Create VIEW itemMonthPlaceholder AS
select IID, month, EXTRACT(YEAR FROM d) as year, 0 as sales
 from Purchase cross join (Select * from months cross join (select IID from Item) as items)
  as itemM
order by month, year;

---- purchases for each month that exists:
Create VIEW purchaseTotal AS
select IID, EXTRACT(MONTH FROM d) as month, EXTRACT(YEAR FROM d) as year, sum(quantity) as sales
FROM Purchase NATURAL JOIN LineItem NATURAL JOIN Item
group by IID, month, year
Order BY month;

---- list of items, months and sales
Create VIEW unitSales AS
(select * from itemMonthPlaceholder 
where not exists (select IID, MONTH, YEAR from purchaseTotal
    where itemMonthPlaceholder.IID = purchaseTotal.IID and
    itemMonthPlaceholder.month = purchaseTotal.month and
    itemMonthPlaceholder.year = purchaseTotal.year)  UNION select * from purchaseTotal)
order by month;

---- list of items, avg sale by year
Create VIEW avgSales AS
select IID, year, sum(sales)/12 as avgUnitSales from unitSales
group by IID, year
order by IID, year ASC;

---- list of items, avg sale by year with placeholder year
Create VIEW FixAvgSales AS
select * from avgSales 
UNION 
select DISTINCT IID, (min(year)-1) as year, 0 as avgUnitSales from avgSales
group by IID;


---- year over year sales
Create VIEW yoySales AS
select IID, year, avgUnitSales,
 LAG(avgUnitSales) OVER (ORDER BY IID, year ASC) As lastYearSales, 
 LAG(year) OVER (ORDER BY IID, year ASC) As prevYear
From FixAvgSales
order by IID, year ASC;

---- year over year sales with percentages
Create VIEW sales AS
select IID, year, avgUnitSales, lastYearSales, prevYear,
CASE 
    WHEN (lastYearSales = 0 and avgUnitSales > 0) THEN 'Infinity'
    WHEN (lastYearSales > 0 and avgUnitSales = 0) THEN -100
    WHEN (lastYearSales = 0 and avgUnitSales = 0) THEN 0
    WHEN ((avgUnitSales-lastYearSales)/NULLIF(avgUnitSales,0))*100 < -100 THEN -100
    WHEN ((avgUnitSales-lastYearSales)/NULLIF(avgUnitSales,0))*100 > 100 THEN 100
    ELSE ((avgUnitSales-lastYearSales)/NULLIF(avgUnitSales,0))*100 
END AS percent
from yoySales
WHERE year != (select min(year) from yoySales);

-- Your query that answers the question goes below the "insert into" line:
insert into q6(
    select IID, prevYear as Year1, 
        lastYearSales as Year1Average, year as Year2, 
        avgUnitSales as Year2Average, percent as YearOverYearChange 
    from sales
    where prevYear != (select min(year) from yoySales)
)
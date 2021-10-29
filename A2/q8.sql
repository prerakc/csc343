-- SALE!SALE!SALE!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.


-- Define views for your intermediate steps here:


-- Your SQL code that performs the necessary updates goes here:
UPDATE Item
SET price = CASE
        WHEN price BETWEEN 10 and 50 THEN 0.8 * price
        WHEN price > 50 AND price < 100 THEN 0.7 * price
        WHEN price >= 100 THEN 0.5 * price
        ELSE price
    END
WHERE IID IN (
    SELECT Item.IID
    FROM Item, LineItem
    WHERE Item.IID = LineItem.IID
    GROUP BY Item.IID
    HAVING sum(quantity) >= 10
);

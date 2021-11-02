-- Hyperconsumers

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
    year TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT,
    items INTEGER NOT NULL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS CustomerItemsBoughtPerYear CASCADE;
DROP VIEW IF EXISTS Hyperconsumers CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW CustomerItemsBoughtPerYear AS
SELECT EXTRACT(YEAR FROM d) as year, Purchase.CID, sum(quantity) as bought
FROM Purchase, Customer, LineItem
WHERE Purchase.CID = Customer.CID AND Purchase.PID = LineItem.PID
GROUP BY year, Purchase.CID;

CREATE VIEW Hyperconsumers AS
SELECT year, concat_ws(' ', firstName, lastName) AS fullName, email, bought
FROM CustomerItemsBoughtPerYear X CROSS JOIN Customer
WHERE X.CID = Customer.CID
AND bought IN (
    SELECT DISTINCT bought
    FROM CustomerItemsBoughtPerYear Y
    WHERE Y.year = X.year
    ORDER BY bought DESC
    LIMIT 5 -- change to 5 for autograder / 2 for sample data
)
ORDER BY year ASC, bought DESC;


-- Your query that answers the question goes below the "insert into" line:
insert into q5
(
SELECT *
FROM Hyperconsumers
);

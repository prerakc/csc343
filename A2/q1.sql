-- Unrated products.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF exists q1 CASCADE;

CREATE TABLE q1(
    CID INTEGER,
    firstName TEXT NOT NULL,
	lastName TEXT NOT NULL,
    email TEXT	
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS CustomerItemPurchases CASCADE;
DROP VIEW IF EXISTS NonReviewedPurchases CASCADE;


-- Define views for your intermediate steps here:

CREATE VIEW CustomerItemPurchases AS
SELECT DISTINCT Purchase.CID, firstName, lastName, email, LineItem.IID
FROM Purchase, Customer, LineItem
WHERE Purchase.CID = Customer.CID AND Purchase.PID = LineItem.PID;

CREATE VIEW NonReviewedPurchases AS
SELECT CID, firstName, lastName, email
FROM CustomerItemPurchases
WHERE IID NOT IN (
    SELECT DISTINCT IID
    FROM Review
)
GROUP BY CID, firstName, lastName, email
HAVING count(distinct iid) >= 3;


-- Your query that answers the question goes below the "insert into" line:
insert into q1
(
    SELECT *
    FROM NonReviewedPurchases
);

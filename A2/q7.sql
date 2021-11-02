-- Fraud Prevention

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS PastDayPurchases CASCADE;
DROP VIEW IF EXISTS InterestedCreditCards CASCADE;
DROP VIEW IF EXISTS InterestedPurchases CASCADE;
DROP VIEW IF EXISTS PurchasesToRemove CASCADE;
DROP VIEW IF EXISTS LineItemsToRemove CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW PastDayPurchases AS
SELECT *
FROM Purchase
WHERE d >= NOW() - INTERVAL '24 HOURS';

CREATE VIEW InterestedCreditCards AS
SELECT cNumber
FROM PastDayPurchases
GROUP BY cNumber
HAVING count(PID) > 5;

CREATE VIEW InterestedPurchases AS
SELECT *
FROM PastDayPurchases
WHERE cNumber IN (SELECT * FROM InterestedCreditCards);

CREATE VIEW PurchasesToRemove AS
SELECT *
FROM InterestedPurchases X
WHERE PID NOT IN (
    SELECT PID
    FROM InterestedPurchases Y
    WHERE X.cNumber = Y.cNumber
    ORDER BY d ASC
    LIMIT 5
);

CREATE VIEW LineItemsToRemove AS
SELECT *
FROM LineItem
WHERE PID IN (SELECT PID FROM PurchasesToRemove);


-- Your SQL code that performs the necessary deletions goes here:
DELETE FROM LineItem
WHERE PID IN (SELECT PID FROM LineItemsToRemove);

DELETE FROM Purchase
WHERE PID IN (SELECT PID FROM PurchasesToRemove);

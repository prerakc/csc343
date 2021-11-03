-- Customer Apreciation Week

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Last24HoursPurchases CASCADE;
DROP VIEW IF EXISTS EarliestPurchases CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW Last24HoursPurchases AS
SELECT *
FROM Purchase
WHERE d >= TIMESTAMP 'yesterday' AND d < TIMESTAMP 'today';

CREATE VIEW EarliestPurchases AS
SELECT *
FROM Last24HoursPurchases X
WHERE d <= ALL (
    SELECT d
    FROM Last24HoursPurchases Y
    WHERE X.CID = Y.CID
);


-- Your SQL code that performs the necessary insertions goes here:
INSERT INTO Item
(
    SELECT
        max(IID) + 1 AS IID,
        'Housewares' AS category,
        'Company logo mug' AS description,
        0.00 AS price
    FROM Item
);

INSERT INTO LineItem
(
    SELECT PID, IID, 1 AS quantity
    FROM EarliestPurchases, (SELECT max(IID) AS IID FROM Item) ItemIID
);

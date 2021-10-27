-- Curators

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    CID INT NOT NULL,
    categoryName TEXT NOT NULL,
    PRIMARY KEY(CID, categoryName)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS ActualPurchases CASCADE;
DROP VIEW IF EXISTS ExpectedPurchases CASCADE;
DROP VIEW IF EXISTS DidNotPurchase CASCADE;
DROP VIEW IF EXISTS PurchasedAll CASCADE;
DROP VIEW IF EXISTS Reviewed CASCADE;
DROP VIEW IF EXISTS NotReviewed CASCADE;
DROP VIEW IF EXISTS ReviewedAll CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW ActualPurchases AS
SELECT DISTINCT Purchase.CID, Item.IID, category
FROM Purchase, LineItem, Item
WHERE Purchase.PID = LineItem.PID AND LineItem.IID = Item.IID;

CREATE VIEW ExpectedPurchases AS
SELECT *
FROM (SELECT CID FROM Customer) cmer CROSS JOIN (SELECT IID, category FROM Item) it;

CREATE VIEW DidNotPurchase AS
(SELECT * FROM ExpectedPurchases) EXCEPT (SELECT * FROM ActualPurchases);

CREATE VIEW PurchasedAll AS
SELECT *
FROM ActualPurchases
WHERE ROW(CID, category) NOT IN (SELECT DISTINCT CID, category FROM DidNotPurchase);

CREATE VIEW Reviewed AS
SELECT Review.CID, Review.IID, category
FROM PurchasedAll, Review
WHERE PurchasedAll.CID = Review.CID
AND PurchasedAll.IID = Review.IID
AND comment IS NOT NULL;

CREATE VIEW NotReviewed AS
(SELECT * FROM PurchasedAll) EXCEPT (SELECT * FROM Reviewed);

CREATE VIEW ReviewedAll AS
(SELECT DISTINCT cid, category FROM PurchasedAll)
EXCEPT
(SELECT DISTINCT cid, category from NotReviewed);


-- Your query that answers the question goes below the "insert into" line:
insert into q3
(
    SELECT *
    FROM ReviewedAll
);

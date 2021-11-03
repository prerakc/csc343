-- Customer Apreciation Week

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- Custom UDF that generates a new unique IID
DROP FUNCTION IF EXISTS generateNewIID() CASCADE;

CREATE OR REPLACE FUNCTION generateNewIID()
    RETURNS INTEGER
    LANGUAGE plpgsql
    AS
$$
DECLARE
newIID INTEGER := floor(random() * ((2147483647::bigint) - (-2147483648::bigint) + 1::bigint) + (-2147483648::bigint))::int;
BEGIN
    WHILE newIID IN (SELECT IID FROM Recommender.Item)
        LOOP
            RAISE NOTICE 'IID: %', newIID;
            newIID := floor(random() * ((2147483647::bigint) - (-2147483648::bigint) + 1::bigint) + (-2147483648::bigint))::int;
        END LOOP;
    RETURN newIID;
END
$$;


-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Last24HoursPurchases CASCADE;
DROP VIEW IF EXISTS EarliestPurchases CASCADE;


-- Needs to be TABLE, not a VIEW, because otherwise
-- a new IID is generated everytime the function is called
-- (both insert queries below call the function when selecting from VIEW NewItemRecord)
DROP TABLE IF EXISTS NewItemRecord CASCADE;

CREATE TABLE NewItemRecord AS
SELECT
    generateNewIID AS IID,
    'Housewares' AS category,
    'Company logo mug' AS description,
    0.00 AS price
FROM generateNewIID();


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
    SELECT * FROM NewItemRecord
);

INSERT INTO LineItem
(
    SELECT PID, IID, 1 AS quantity
    FROM EarliestPurchases, (SELECT IID FROM NewItemRecord) ItemIID
);

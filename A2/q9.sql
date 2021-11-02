-- Customer Apreciation Week

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS allOrders CASCADE;

-- Define views for your intermediate steps here:

---- earliest orders from yesterday from each user
CREATE VIEW allOrders as 
select pid, m.cid, d from (select cid, min(d) as mn from Purchase
where d > TIMESTAMP 'yesterday'
group by cid) t join Purchase m ON m.cid = t.cid and t.mn=m.d;

-- Your SQL code that performs the necessary insertions goes here:

INSERT INTO Item VALUES 
((select MAX(iid) from Item)+1, 'Housewares', 'Company logo mug', 0.00);

INSERT INTO LineItem VALUES
((select pid from allOrders), (select max(iid) from Item), 1);

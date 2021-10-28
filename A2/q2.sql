-- Helpfulness

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q2 CASCADE;

create table q2(
    CID INTEGER,
    firstName TEXT NOT NULL,
    helpfulness_category TEXT	
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS NoReviews CASCADE;
DROP VIEW IF EXISTS HelpfulReviews CASCADE;
DROP VIEW IF EXISTS TotalReviews CASCADE;
DROP VIEW IF EXISTS HelpfulnessRating CASCADE;
DROP VIEW IF EXISTS NHRatings CASCADE;
DROP VIEW IF EXISTS VHRatings CASCADE;
DROP VIEW IF EXISTS SHRatings CASCADE;

-- Define views for your intermediate steps here:

----Customers with no reviews
CREATE VIEW NoReviews AS
Select CID as reviewer, 0 AS ratingScore
FROM Customer
WHERE CID NOT IN (Select DISTINCT reviewer From Helpfulness);

----Helpful ratings on Customers reviews
CREATE VIEW HelpfulReviews AS
Select reviewer, IID, count(helpfulness) AS helpful
From Helpfulness 
Where helpfulness = True
GROUP BY reviewer, IID;

----Total ratings Customers reviews
CREATE VIEW TotalReviews AS
Select reviewer, IID, count(helpfulness) AS totalRatings
From Helpfulness 
GROUP BY reviewer, IID;

----RatingScores of Customers with reviews
CREATE VIEW HelpfulnessRating AS
(Select reviewer, (cast(helpful AS float) / cast(totalRatings AS float)) AS ratingScore
FROM HelpfulReviews NATURAL JOIN TotalReviews) UNION (Select * from NoReviews);

----Very helpful Ratings
CREATE VIEW VHRatings AS
Select *, 'very helpful' as helpfulness 
from HelpfulnessRating
where ratingScore >= 0.8;

----Somewhat helpful Ratings
CREATE VIEW SHRatings AS
Select *, 'somewhat helpful' as helpfulness 
from HelpfulnessRating
where ratingScore >= 0.5  and reviewer NOT IN (select reviewer from VHRatings);

----Not helpful Ratings
CREATE VIEW NHRatings AS
Select *, 'not helpful' as helpfulness 
from HelpfulnessRating
where ratingScore < 0.5;


-- Your query that answers the question goes below the "insert into" line:
insert into q2
(
    SELECT * 
    FROM ((select * from VHRatings) UNION (select * from SHRatings) UNION (select * from NHRatings)) as helpfulRatings
)
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
DROP VIEW IF EXISTS ZeroHelpfulness CASCADE;
DROP VIEW IF EXISTS ReviewMetrics CASCADE;
DROP VIEW IF EXISTS HelpfulnessPercentage CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW ZeroHelpfulness AS
(
    SELECT CID, firstName, 0 AS helpfulness
    FROM Customer
    WHERE CID NOT IN (SELECT DISTINCT CID FROM Review)
)
UNION
(
    SELECT CID, firstName, 0 AS helpfulness
    FROM Customer
    WHERE CID NOT IN (SELECT DISTINCT reviewer FROM Helpfulness)
);

CREATE VIEW ReviewMetrics AS
SELECT
    reviewer,
    IID,
    COALESCE(helpful, 0) as helpful,
    COALESCE(notHelpful, 0) as notHelpful
FROM
(
    Select reviewer, IID, count(helpfulness) AS helpful
    From Helpfulness 
    Where helpfulness = True
    GROUP BY reviewer, IID
) HelpfulReviews
FULL JOIN
(
    Select reviewer, IID, count(helpfulness) AS notHelpful
    From Helpfulness 
    Where helpfulness = False
    GROUP BY reviewer, IID
) NotHelpfulReviews
USING (reviewer, IID);

CREATE VIEW HelpfulnessPercentage AS
SELECT
    CID,
    firstName,
    (cast(helpfulReviews AS float) / cast(totalReviews AS float)) AS helpfulness
FROM
(
    SELECT reviewer as CID, firstName, count(*) as helpfulReviews
    FROM ReviewMetrics JOIN Customer ON reviewer = CID
    WHERE helpful > notHelpful
    GROUP BY reviewer, firstName
) TimesHelpful
JOIN
(
    SELECT CID, count(*) as totalReviews
    FROM Review
    GROUP BY CID
) TimesReviewed
USING (CID);


-- Your query that answers the question goes below the "insert into" line:
insert into q2
(
    SELECT
        CID,
        firstName,
        CASE
            WHEN helpfulness < 0.5 THEN 'not helpful'
            WHEN helpfulness >= 0.5 AND helpfulness < 0.8 THEN 'somewhat helpful'
            WHEN helpfulness >= 0.8 THEN 'very helpful'
        END AS helpfulness
    FROM
    (
        (SELECT * FROM HelpfulnessPercentage)
        UNION
        (SELECT * FROM ZeroHelpfulness)
    ) HelpfullnessMetricsNumerical
);

-- Set search path to project's schema and drop investivative query table
SET SEARCH_PATH TO projectschema;
DROP TABLE IF EXISTS iq1 CASCADE;

-- Create investivative query table

-- Tuples representing the continents for each year with the best average MPG:
-- year is the year in the dataset
-- continentName is the continent
-- numModels is how many different car models were produced
-- avgMPG is the average MPG of the produced models
-- avgAccel is the average acceleration of the produced models
CREATE TABLE iq1 (
    year INT NOT NULL,
    continentName TEXT NOT NULL,
    numModels INT NOT NULL,
    highestAvgMPG FLOAT NOT NULL,
    avgAccel FLOAT NOT NULL
);

-- Drop intermediate views
DROP VIEW IF EXISTS MetricsPerYearContinent CASCADE;

-- Define views for your intermediate steps here:

-- Desired yearly metrics for every continent in the dataset:
-- year is the year in the dataset
-- continentName is the continent
-- numModels is how many different car models were produced
-- avgMPG is the average MPG of the produced models
-- avgAccel is the average acceleration of the produced models
CREATE VIEW MetricsPerYearContinent AS
SELECT year, continentName, count(*) as numModels, avg(mpg) AS avgMPG, avg(acceleration) as avgAccel
FROM
    Parameters
    NATURAL JOIN
    CARS
    NATURAL JOIN
    Models
    NATURAL JOIN
    Manufacturers
    NATURAL JOIN
    Countries
    NATURAL JOIN
    Continents
GROUP BY year, continentName
ORDER BY year ASC;

-- Insert into investivative query table
INSERT INTO iq1
(
    SELECT *
    FROM MetricsPerYearContinent X
    WHERE X.avgMPG >= ALL (
        SELECT avgMPG
        FROM MetricsPerYearContinent Y
        WHERE Y.year = X.year
    )
);

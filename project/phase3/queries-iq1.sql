SET SEARCH_PATH TO projectschema;
DROP TABLE IF EXISTS iq1 CASCADE;

CREATE TABLE iq1 (
    year INT NOT NULL,
    continentName TEXT NOT NULL,
    numModels INT NOT NULL,
    highestAvgMPG FLOAT NOT NULL,
    avgAccel FLOAT NOT NULL
);

DROP VIEW IF EXISTS MetricsPerYearContinent CASCADE;

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

SELECT * FROM iq1;

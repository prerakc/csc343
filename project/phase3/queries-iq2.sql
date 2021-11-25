SET SEARCH_PATH TO projectschema;
DROP TABLE IF EXISTS iq2 CASCADE;

CREATE TABLE iq2 (
    year INT NOT NULL,
    make TEXT NOT NULL,
    cylinders INT NOT NULL,
    horsepower INT NOT NULL,
    weight INT NOT NULL,
    powerToWeightRatio FLOAT NOT NULL
);

DROP VIEW IF EXISTS NoHorsepowerNull CASCADE;
DROP VIEW IF EXISTS MetricsPerCar CASCADE;

CREATE VIEW NoHorsepowerNull AS
SELECT *
FROM Parameters
WHERE horsepower IS NOT NULL;

CREATE VIEW MetricsPerCar AS
SELECT
    year,
    make,
    cylinders,
    horsepower,
    weight,
    CAST(horsepower AS FLOAT) / CAST(weight AS FLOAT) AS ratio
FROM NoHorsepowerNull NATURAL JOIN Cars;

INSERT INTO iq2
(
    SELECT *
    FROM MetricsPerCar X
    WHERE X.ratio >= ALL (
        SELECT ratio
        FROM MetricsPerCar Y
        WHERE Y.year = X.year
    )
);

SELECT * FROM iq2;

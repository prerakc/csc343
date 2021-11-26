-- Set search path to project's schema and drop investivative query table
SET SEARCH_PATH TO projectschema;
DROP TABLE IF EXISTS iq2 CASCADE;

-- Create investivative query table
CREATE TABLE iq2 (
    year INT NOT NULL,
    make TEXT NOT NULL,
    cylinders INT NOT NULL,
    horsepower INT NOT NULL,
    weight INT NOT NULL,
    powerToWeightRatio FLOAT NOT NULL
);

-- Drop intermediate views
DROP VIEW IF EXISTS NoHorsepowerNull CASCADE;
DROP VIEW IF EXISTS MetricsPerCar CASCADE;

-- Define views for your intermediate steps here:
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

-- Insert into investivative query table
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

-- Show investivative query's results
SELECT * FROM iq2;

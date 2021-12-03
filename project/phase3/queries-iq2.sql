-- Set search path to project's schema and drop investivative query table
SET SEARCH_PATH TO projectschema;
DROP TABLE IF EXISTS iq2 CASCADE;

-- Create investivative query table

-- Tuples describing the car with the best power to weight ratio for every year:
-- year is the year the car was made
-- make is the car’s make description
-- cylinders is the number of cylinders
-- horsepower is the car's horsepower
-- weight is the car's weight
-- ratio is the car's power to weight ratio
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

-- All tuples in Parameters relation that do not have a NULL in the horsepower column:
-- See schema.ddl for explanation of columns in Parameters relation
CREATE VIEW NoHorsepowerNull AS
SELECT *
FROM Parameters
WHERE horsepower IS NOT NULL;

-- Desired metrics per car in dataset:
-- year is the year the car was made
-- make is the car’s make description
-- cylinders is the number of cylinders
-- horsepower is the car's horsepower
-- weight is the car's weight
-- ratio is the car's power to weight ratio
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

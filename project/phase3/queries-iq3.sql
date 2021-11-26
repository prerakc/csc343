-- Set search path to project's schema and drop investivative query table
SET SEARCH_PATH TO projectschema;
DROP TABLE IF EXISTS iq3 CASCADE;

-- Create investivative query table
CREATE TABLE iq3 (
    Year INT NOT NULL,
    A_make TEXT NOT NULL,
    A_displacement Int NOT NULL,
    A_mpg FLOAT NOT NULL,
    A_cylinders INT NOT NULL,
    B_make Text NOT NULL,
    B_displacement Int NOT NULL,
    B_mpg FLOAT NOT NULL,
    B_cylinders INT NOT NULL,
    MPG_Difference FLOAT NOT NULL,
    displacement_Difference INT NOT NULL
);

-- Drop intermediate views
DROP VIEW IF EXISTS highestYearlyCylinder CASCADE;
DROP VIEW IF EXISTS lowestYearlyCylinder CASCADE;
DROP VIEW IF EXISTS carHYC CASCADE;
DROP VIEW IF EXISTS carLYC CASCADE;
DROP VIEW IF EXISTS lowEfficiencyMakehelper CASCADE;
DROP VIEW IF EXISTS highEfficiencyMakehelper CASCADE;
DROP VIEW IF EXISTS highCylEfficiency CASCADE;
DROP VIEW IF EXISTS lowCylEfficiency CASCADE;
DROP VIEW IF EXISTS joinHelper CASCADE;

-- Define views for your intermediate steps here:

CREATE VIEW highestYearlyCylinder AS
SELECT Max(cylinders) as highest, year
FROM Parameters
Group by year
order by year;

CREATE VIEW lowestYearlyCylinder AS
SELECT Min(cylinders) as lowest, year
FROM Parameters
Group by year
order by year;

CREATE VIEW carHYC AS
select CarID, highest, displacement, mpg, Parameters.year as year 
from Parameters INNER JOIN highestYearlyCylinder on
Parameters.cylinders = highestYearlyCylinder.highest
and
Parameters.year = highestYearlyCylinder.year;

CREATE VIEW carLYC AS
select CarID, lowest, displacement, mpg, Parameters.year as year 
from Parameters INNER JOIN lowestYearlyCylinder on
Parameters.cylinders = lowestYearlyCylinder.lowest
and
Parameters.year = lowestYearlyCylinder.year;

CREATE VIEW lowEfficiencyMakehelper AS
select carLYC.carID, year, make, displacement, mpg, lowest
from carLYC INNER JOIN Cars on
carLYC.carID = Cars.carID
order by year;

CREATE VIEW highEfficiencyMakehelper AS
select carHYC.carID, year, make, displacement, mpg, highest
from carHYC INNER JOIN Cars on
carHYC.carID = Cars.carID
order by year;

CREATE VIEW highestEfficiency AS
select year, max(mpg) as mpg
from carHYC 
Group by year
order by year;

CREATE VIEW lowestEfficiency AS
select year, min(mpg) as mpg
from carLYC 
Group by year
order by year;

CREATE VIEW highCylEfficiency AS
select carID, highestEfficiency.year as A_year, make as A_make, 
displacement as A_displacement, highestEfficiency.mpg as A_mpg, highest as A_cylinders
from highEfficiencyMakehelper INNER JOIN highestEfficiency on
highEfficiencyMakehelper.year = highestEfficiency.year
and 
highEfficiencyMakehelper.mpg = highestEfficiency.mpg
order by A_year;

CREATE VIEW lowCylEfficiency AS
select carID, lowestEfficiency.year as B_year, make as B_make, displacement as B_displacement,
 lowestEfficiency.mpg as B_mpg, lowest as B_cylinders
from lowEfficiencyMakehelper INNER JOIN lowestEfficiency on
lowEfficiencyMakehelper.year = lowestEfficiency.year
and 
lowEfficiencyMakehelper.mpg = lowestEfficiency.mpg
order by B_year;

CREATE VIEW joinHelper AS 
select A_year as year, A_make, A_displacement, A_mpg, A_cylinders, 
        B_make, B_displacement, B_mpg, B_cylinders
 from highCylEfficiency cross join lowCylEfficiency 
 where A_year = B_year;

-- Insert into investivative query table
insert into iq3
(
    SELECT year,
    A_make,
    A_displacement,
    A_mpg,
    A_cylinders,
    B_make,
    B_displacement,
    B_mpg,
    B_cylinders,
    ROUND((B_mpg - A_mpg)::numeric, 2) as MPG_Difference,
    ROUND((B_displacement - A_displacement)::numeric, 2) as displacement_Difference   
    FROM joinHelper
);

-- Show investivative query's results
SELECT * FROM iq3;

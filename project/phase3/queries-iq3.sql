-- Set search path to project's schema and drop investivative query table
SET SEARCH_PATH TO projectschema;
DROP TABLE IF EXISTS iq3 CASCADE;

-- Create investivative query table

-- Set of every combinations from Cars with the lowest number of cylinders and lowest efficiency 
-- and Cars with the highest number of cylinders and highest efficiency
-- along with the MPG and engine displacement differences:
-- year is the year the car was made
-- A_cylinders is number of cylinders for the highest cylinders and highest efficiency cars
-- A_make is the car’s make description for the highest cylinders and highest efficiency cars
-- A_displacement is the displacement volume in cubic inches for each car in the highest cylinders and highest efficiency cars
-- A_mpg is the mileage per gallon for each car in the highest cylinders and highest efficiency cars
-- B_cylinders is number of cylinders for the lowest cylinders and lowest efficiency cars
-- B_make is the car’s make description for the lowest cylinders and lowest efficiency cars
-- B_displacement is the displacement volume in cubic inches for each car in the lowest cylinders and lowest efficiency cars
-- B_mpg is the mileage per gallon for each car in the lowest cylinders and lowest efficiency cars
-- MPG_Difference is the difference in MPG between Car B and Car A (i.e. B_mpg - A_mpg)
-- displacement_Difference is the difference in engine displacement between Car B and Car A (i.e. B_displacement - A_displacement)
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
DROP VIEW IF EXISTS lowestEfficiency CASCADE;
DROP VIEW IF EXISTS highestEfficiency CASCADE;
DROP VIEW IF EXISTS highCylEfficiency CASCADE;
DROP VIEW IF EXISTS lowCylEfficiency CASCADE;
DROP VIEW IF EXISTS joinHelper CASCADE;

-- Define views for your intermediate steps here:

-- Highest cylinder cars every year:
-- highest is number of cylinders
-- year is the year the car was made
CREATE VIEW highestYearlyCylinder AS
SELECT Max(cylinders) as highest, year
FROM Parameters
Group by year
order by year;

-- Lowest cylinder cars every year:
-- lowest is number of cylinders
-- year is the year the car was made
CREATE VIEW lowestYearlyCylinder AS
SELECT Min(cylinders) as lowest, year
FROM Parameters
Group by year
order by year;

-- Cars with the highest number of cylinders along with their other parameters:
-- CarID is the identifier
-- highest is number of cylinders
-- displacement is the displacement volume in cubic inches for each car
-- mpg is the mileage per gallon for each car
-- year is the year the car was made
CREATE VIEW carHYC AS
select CarID, highest, displacement, mpg, Parameters.year as year 
from Parameters INNER JOIN highestYearlyCylinder on
Parameters.cylinders = highestYearlyCylinder.highest
and
Parameters.year = highestYearlyCylinder.year;

-- Cars with the lowest number of cylinders along with their other car parameters:
-- CarID is the identifier
-- lowest is number of cylinders
-- displacement is the displacement volume in cubic inches for each car
-- mpg is the mileage per gallon for each car
-- year is the year the car was made
CREATE VIEW carLYC AS
select CarID, lowest, displacement, mpg, Parameters.year as year 
from Parameters INNER JOIN lowestYearlyCylinder on
Parameters.cylinders = lowestYearlyCylinder.lowest
and
Parameters.year = lowestYearlyCylinder.year;


-- Cars with the lowest number of cylinders along with their other car parameters and make description:
-- CarID is the identifier
-- lowest is number of cylinders
-- make is the car’s make description
-- displacement is the displacement volume in cubic inches for each car
-- mpg is the mileage per gallon for each car
-- year is the year the car was made
CREATE VIEW lowEfficiencyMakehelper AS
select carLYC.carID, year, make, displacement, mpg, lowest
from carLYC INNER JOIN Cars on
carLYC.carID = Cars.carID
order by year;

-- Cars with the highest number of cylinders along with their other car parameters and make description:
-- CarID is the identifier
-- highest is number of cylinders
-- make is the car’s make description
-- displacement is the displacement volume in cubic inches for each car
-- mpg is the mileage per gallon for each car
-- year is the year the car was made
CREATE VIEW highEfficiencyMakehelper AS
select carHYC.carID, year, make, displacement, mpg, highest
from carHYC INNER JOIN Cars on
carHYC.carID = Cars.carID
order by year;

-- Cars with the highest fuel efficiency according to mpg:
-- mpg is the highest miles per gallon from each set of cars grouped by year
-- year is the year the car was made
CREATE VIEW highestEfficiency AS
select year, max(mpg) as mpg
from carHYC 
Group by year
order by year;

-- Cars with the lowest fuel efficiency according to mpg:
-- mpg is the lowest miles per gallon from each set of cars grouped by year
-- year is the year the car was made
CREATE VIEW lowestEfficiency AS
select year, min(mpg) as mpg
from carLYC 
Group by year
order by year;

-- Cars with the highest number of cylinders and highest efficiency 
-- along with their other car parameters:
-- CarID is the identifier
-- A_cylinders is number of cylinders
-- A_make is the car’s make description
-- A_displacement is the displacement volume in cubic inches for each car
-- A_mpg is the mileage per gallon for each car
-- A_year is the year the car was made
CREATE VIEW highCylEfficiency AS
select carID, highestEfficiency.year as A_year, make as A_make, 
displacement as A_displacement, highestEfficiency.mpg as A_mpg, highest as A_cylinders
from highEfficiencyMakehelper INNER JOIN highestEfficiency on
highEfficiencyMakehelper.year = highestEfficiency.year
and 
highEfficiencyMakehelper.mpg = highestEfficiency.mpg
order by A_year;

-- Cars with the lowest number of cylinders and lowest efficiency 
-- along with their other car parameters:
-- CarID is the identifier
-- B_cylinders is number of cylinders
-- B_make is the car’s make description
-- B_displacement is the displacement volume in cubic inches for each car
-- B_mpg is the mileage per gallon for each car
-- B_year is the year the car was made
CREATE VIEW lowCylEfficiency AS
select carID, lowestEfficiency.year as B_year, make as B_make, displacement as B_displacement,
 lowestEfficiency.mpg as B_mpg, lowest as B_cylinders
from lowEfficiencyMakehelper INNER JOIN lowestEfficiency on
lowEfficiencyMakehelper.year = lowestEfficiency.year
and 
lowEfficiencyMakehelper.mpg = lowestEfficiency.mpg
order by B_year;

-- Set of every combinations from Cars with the lowest number of cylinders and lowest efficiency 
-- and Cars with the highest number of cylinders and highest efficiency:
-- year is the year the car was made
-- A_cylinders is number of cylinders for the highest cylinders and highest efficiency cars
-- A_make is the car’s make description for the highest cylinders and highest efficiency cars
-- A_displacement is the displacement volume in cubic inches for each car in the highest cylinders and highest efficiency cars
-- A_mpg is the mileage per gallon for each car in the highest cylinders and highest efficiency cars
-- B_cylinders is number of cylinders for the lowest cylinders and lowest efficiency cars
-- B_make is the car’s make description for the lowest cylinders and lowest efficiency cars
-- B_displacement is the displacement volume in cubic inches for each car in the lowest cylinders and lowest efficiency cars
-- B_mpg is the mileage per gallon for each car in the lowest cylinders and lowest efficiency cars
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

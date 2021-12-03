
-- Importing a file such as this will let you quickly create a demo to hand
-- in. You may edit this to customize it.  For instance, you may have your
-- data in a csv file and need a different command to load it in, you
-- may differently named files, or you may have your queries split into more
-- files than expected here.
--
\echo -------------------- Loading schema and data: -------------------- 
\echo
\i schema.ddl
\echo
\echo  -------------------- Investigative Question 1: ------------------ 
\echo
\i queries-iq1.sql
\echo MetricsPerYearContinent
SELECT * FROM MetricsPerYearContinent;
\echo iq1
SELECT * FROM iq1;
\echo
\echo  -------------------- Investigative Question 2: ------------------ 
\echo
\i queries-iq2.sql
\echo NoHorsepowerNull
SELECT * FROM NoHorsepowerNull;
\echo MetricsPerCar
SELECT * FROM MetricsPerCar;
\echo iq2
SELECT * FROM iq2;
\echo
\echo  -------------------- Investigative Question 3: ------------------
\echo
\i queries-iq3.sql
\echo highestYearlyCylinder
select * from highestYearlyCylinder;
\echo lowestYearlyCylinder
select * from lowestYearlyCylinder;
\echo carHYC
select * from carHYC;
\echo carLYC
select * from carLYC;
\echo lowEfficiencyMakehelper
select * from lowEfficiencyMakehelper;
\echo highEfficiencyMakehelper
select * from highEfficiencyMakehelper;
\echo lowestEfficiency
SELECT * FROM lowestEfficiency;
\echo highestEfficiency
SELECT * FROM highestEfficiency;
\echo highCylEfficiency
select * from highCylEfficiency;
\echo lowCylEfficiency
select * from lowCylEfficiency;
\echo joinHelper
select * from joinHelper;
\echo iq3
SELECT * FROM iq3;
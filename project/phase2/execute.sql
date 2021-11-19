-- (a) load schema and data
\i schema.ddl

-- (b) run \d for each table
\d Continents
\d Countries
\d Manufacturers
\d Models
\d Cars
\d Parameters

-- (c) run select count(*) for each table
SELECT count(*) FROM Continents;
SELECT count(*) FROM Countries;
SELECT count(*) FROM Manufacturers;
SELECT count(*) FROM Models;
SELECT count(*) FROM Cars;
SELECT count(*) FROM Parameters;

-- (d) run a select * for each table
SELECT * FROM Continents;
SELECT * FROM Countries;
SELECT * FROM Manufacturers WHERE manufacturerID <= 15;
SELECT * FROM Models WHERE modelID <= 15;
SELECT * FROM Cars WHERE carID <= 15;
SELECT * FROM Parameters WHERE carID <= 15;

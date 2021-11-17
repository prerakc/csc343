-- Change nothing in this file.

DROP SCHEMA IF EXISTS projectschema CASCADE;
CREATE SCHEMA projectschema;
SET SEARCH_PATH TO projectschema;

-- All continents where cars in the dataset are made or produced:
-- continentID is the identifier for continents
-- continentName is the continent name
CREATE TABLE Continents (
	continentID INT NOT NULL,
	continentName TEXT NOT NULL,
	PRIMARY KEY (continentID)
);

-- All countries where cars in the dataset are made or produced:
-- countryID is the identifier for continents
-- countryName is the continent name
-- continentID is the identifier for continents
CREATE TABLE Countries(
	countryID INT NOT NULL,
	countryName TEXT NOT NULL,
	continentID INT NOT NULL,
	PRIMARY KEY(countryID),
	FOREIGN KEY (continentID) REFERENCES Continents(continentID)
);

-- Car Manufacturers :
-- manufacturerID is identifier for car manufacturers, 
-- nickName is car manufacturer’s nickname, 
-- fullName car manufacturer’s full name
-- countryID is the the car manufacturer’s home country
CREATE TABLE Manufacturers (
	manufacturerID INT NOT NULL,
	nickName TEXT NOT NULL,
	fullName TEXT NOT NULL,
	countryID INT NOT NULL,
	PRIMARY KEY (manufacturerID),
	FOREIGN KEY (countryID) REFERENCES Countries(countryID) 
);

-- Car Models :
-- modelID is the identifier for car models 
-- manufacturerID is the identifier for car manufacturers, 
-- modelName is the name of car model
CREATE TABLE Models (
	modelID INT NOT NULL,
	manufacturerID INT NOT NULL,
	modelName TEXT NOT NULL,
	PRIMARY KEY(modelID),
	FOREIGN KEY (manufacturerID) REFERENCES Manufacturers(manufacturerID)
);

-- All the different cars:
-- carID is the identifier for cars 
-- modelID is the identifier for car models 
-- make is the car’s make description
CREATE TABLE Cars (
	carID INT NOT NULL,
	modelID INT NOT NULL,
	make TEXT NOT NULL,
	PRIMARY KEY (carID),
	FOREIGN KEY (modelID) REFERENCES Models(modelID)
);

-- Car Parameters which include all the specifics about the vehicles:
-- carID is the identifier for cars
-- mpg is the mileage per gallon for each car
-- cylinders is the number of engine cylinders the car has
-- displacement engine is the displacement volume in cubic inches for each car
-- horsepower car's engine power in horsepower
-- weight is the car’s weight in pounds
-- acceleration is the car's 0-60mph acceleration time in seconds
-- year is the car’s year of production
CREATE TABLE Parameters (
	carID INT NOT NULL,
	mpg FLOAT CHECK (mpg > 0),
	cylinders INT NOT NULL CHECK (cylinders > 0),
	displacement FLOAT NOT NULL CHECK (displacement > 0),
	horsepower INT CHECK (horsepower > 0),
	weight INT NOT NULL CHECK (weight > 0),
	acceleration FLOAT NOT NULL CHECK (acceleration > 0),
	year INT NOT NULL CHECK (year > 0),
	PRIMARY KEY (carID),
	FOREIGN KEY (carID) REFERENCES Cars(carID)
);

\COPY Continents FROM 'continents.csv' WITH DELIMITER ',' CSV HEADER

\COPY Countries FROM 'countries.csv' WITH DELIMITER ',' CSV HEADER

\COPY Manufacturers FROM 'car-makers.csv' WITH DELIMITER ',' CSV HEADER

\COPY Models FROM 'model-list.csv' WITH DELIMITER ',' CSV HEADER

\COPY Cars FROM 'car-names.csv' WITH DELIMITER ',' CSV HEADER

\COPY Parameters FROM 'cars-data.csv' WITH DELIMITER ',' CSV HEADER
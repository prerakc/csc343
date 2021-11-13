-- Change nothing in this file.

DROP SCHEMA IF EXISTS cars CASCADE;
CREATE SCHEMA cars;
SET SEARCH_PATH TO cars;
	
-- Car Manufacturers :
-- ManufacturerID is identifier for car manufacturers, 
-- NickName is car manufacturer’s nickname, 
-- FullName car manufacturer’s full name
-- CountryID is the the car manufacturer’s home country
CREATE TABLE Manufacturers (
	manufacturerID INT NOT NULL,
	nickName TEXT NOT NULL,
	fullName TEXT NOT NULL,
	countryID INT NOT NULL,
	PRIMARY KEY (manufacturerID, fullName)
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
-- CarID is the identifier for cars 
-- modelID is the identifier for car models 
-- make  is the car’s make description
CREATE TABLE Cars (
	carID INT NOT NULL,
	modelID INT NOT NULL,
	make TEXT NOT NULL,
	PRIMARY KEY (carID),
	FOREIGN KEY (modelID) REFERENCES Models(modelID)
);

-- Car Parameters which include all the specifics about the vehicles:
-- carID is the identifier for cars 
-- cylinders is the number of engine cylinders the car has
-- displacement engine is the displacement volume in cubic inches for each car
-- weight is the car’s weight in pounds
-- Acceleration is the car's 0-60mph acceleration time in seconds
-- Horsepower car's engine power in horsepower
-- MPG is the mileage per gallon for each car
-- Year is the car’s year of production
CREATE TABLE Parameters (
	carID INT NOT NULL,
	cylinders INT NOT NULL,
	displacement INT NOT NULL CHECK (displacement > 0),
	weight INT NOT NULL CHECK (weight > 0),
	acceleration FLOAT NOT NULL CHECK (acceleration > 0),
	horsepower INT CHECK (horsepower > 0 or horsepower = NULL),
	mpg INT CHECK (mpg > 0 or mpg = NULL),
	year INT NOT NULL CHECK (year >= 0),
	PRIMARY KEY (carID),
	FOREIGN KEY (carID) REFERENCES Cars(carID)
);

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
	PRIMARY KEY(countryID)
	FOREIGN KEY (continentID) REFERENCES Continents(continentID)
);

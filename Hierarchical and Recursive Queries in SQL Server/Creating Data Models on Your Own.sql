-- Creating a table

/*
In this exercise, you will create a new table Person. For this task, you have to
define the table by using CREATE TABLE define the necessary fields of the desired table
An example for creating a table Employee is shown below:
CREATE TABLE Employee (
    ID INT,
    Name CHAR(32)
);
Your task is to create a new table, Person, with the fields IndividualID,Firstname,Lastname, Address, and City.
*/

-- Define the table Person
CREATE TABLE Person (
  	-- Define the Individual ID
  	IndividualID INT NOT NULL,
  	-- Set Firstname and Lastname not to be NULL of type VARCHAR(255)
	Firstname VARCHAR(255) NOT NULL,
	Lastname VARCHAR(255) NOT NULL,
	Address VARCHAR(255) NOT NULL,
  	City CHAR(32) NOT NULL,
   	-- Define Birthday as DATE
  	Birthday DATE
);

SELECT * 
FROM Person;

-- Inserting and updating a table

/*
A very important task when working with tables is inserting and updating the values in a database. 
The syntax for both operations is shown below.
Insert value1 and value2 into the Employee table:
INSERT INTO Employee 
VALUES (value1, value2);
Update field1 from table Employee with value1 for the ID=1:
UPDATE Employee 
SET field1 = value1 
WHERE ID = 1;
Your task is to insert two new values into the Person table and to update the entries of the table.
*/

INSERT INTO Person 
VALUES (1,'Andrew','Anderson','Union Ave 10','New York','1986-12-30');
INSERT INTO Person 
VALUES (2,'Peter','Jackson','342 Flushing st','New York','1986-12-30');

-- Set the person's first name to Jones for ID = 1
UPDATE Person
SET Firstname = 'Jones'
WHERE ID = 1;

-- Update the birthday of the person with the last name Jackson
UPDATE Person
SET birthday = '1980-01-05'
WHERE Lastname = 'Jackson';

SELECT * 
FROM Person;

-- Deleting data and dropping table

/*
Besides being able to CREATE, INSERT, or UPDATE, it is also important to know how to DELETE and DROP a table. 
With DELETE, it is possible to delete a certain line of the table and with DROP TABLE, it is possible to erase the entire table and its definition.
The syntax for both operators is as follows.
Delete the line where lineID = 1 from the Employee table:
DELETE FROM Employee 
WHERE lineID = 1;
Drop the entire Employee table:
DROP TABLE Employee
Your task is to delete some lines of the previously defined Person table and finally, to drop the entire table.
*/

INSERT INTO Person 
VALUES ( 1, 'Andrew', 'Anderson', 'Address 1', 'City 1', '1986-12-30');
INSERT INTO Person 
VALUES ( 2, 'Peter', 'Jackson', 'Address 2', 'City 2', '1986-12-30');
INSERT INTO Person 
VALUES ( 3, 'Michaela', 'James', 'Address 3', 'City 3', '1976-03-07');

DELETE FROM Person 
WHERE ID = 1;
DELETE FROM Person 
WHERE Lastname = 'Jackson';

-- Drop the table Person
DROP TABLE Person;

SELECT * 
FROM Person;

-- Changing a table structure

/*
Another basic SQL operation is to add or delete a column from a table. 
This can be done using the ALTER TABLE syntax followed by the desired operation. 
The syntax for these operations is defined as follows.
To add a column named new to the Employee table:
ALTER TABLE Employee 
ADD new;
To delete a column named old from Employee:
ALTER TABLE Employee 
DROP COLUMN old
You have the task to add a new column Email and drop the column Birthday from the Person table.
*/

-- Add the column EMail to Person
ALTER TABLE Person
ADD Email VARCHAR(255);

-- Delete the column Birthday of Person
ALTER TABLE Person
DROP COLUMN Birthday;

-- Check the table definition
SELECT * 
FROM Person;

-- Defining primary and foreign keys

/* 
A very important concept of relational databases is the use of primary and foreign keys. 
In this exercise, you will define a two new tables. 
A table Person, with a PRIMARY KEY and another table, History, with a PRIMARY KEY and a FOREIGN KEY referencing the Person table.
*/

CREATE TABLE Person (
  	-- Define the primary key for Person of type INT
  	PersonID INT NOT NULL PRIMARY KEY,
	Firstname VARCHAR(255) NOT NULL,
	Lastname VARCHAR(255) NOT NULL,
);

CREATE TABLE History (   
    -- Define the primary key for History
  	OrderID INT NOT NULL PRIMARY KEY,
    Item VARCHAR(255) NOT NULL,
    Price INT NOT NULL,
  	-- Define the foreign key for History
    PersonID INT FOREIGN KEY REFERENCES Person(PersonID)    
);

SELECT * 
FROM History;

-- Inserting data to person and order history

/*
Next, you will insert data into the two newly generated tables, Person and History. Enter the following orders:
Andrew Anderson bought an iPhone XS for 1000
Sam Smith bought a MacBook Pro for 1800
When inserting the customers and their orders into the tables make sure that:
the primary key is unique
you use the correct foreign key
*/

-- Insert new data into the table Person
INSERT INTO Person 
VALUES (1,'Andrew','Anderson','Union Ave 10','New York','1986-12-30');
INSERT INTO Person 
VALUES (2,'Sam','Smith','Flushing Ave 342','New York','1986-12-30');

-- Insert new data into the table History
INSERT INTO History 
VALUES (1,'iPhone XS',1000,1);
INSERT INTO History 
VALUES (2,'MacBook Pro',1800,2);

SELECT * 
FROM History;

-- Getting the number of orders & total costs

/*
In this exercise, you will JOIN two tables to get the total number of orders for each person and the sum of prices of all orders. 
You have to join the Person and History tables on the primary and foreign keys to get all required information.
*/

INSERT INTO Person  
VALUES (1, 'Andrew', 'Anderson','Union Ave 10','New York','1986-12-30');
INSERT INTO Person 
VALUES (2, 'Sam', 'Smith','Flushing Ave 342','New York','1986-12-30');

INSERT INTO History VALUES ( 1, 'IPhone XS', 1000, 1);
INSERT INTO History VALUES ( 2, 'MacBook Pro', 1800, 1);
INSERT INTO History VALUES ( 5, 'IPhone XR', 600, 2);
INSERT INTO History VALUES ( 6, 'IWatch 4', 400, 1);

SELECT 
    Person.ID,
    -- Count the number of orders
    COUNT(*) as Orders,
    -- Add the total price of all orders
    SUM(Price) as Costs
FROM Person
	-- Join the tables Person and History on their IDs
	JOIN History 
	ON Person.ID = History.PersonID
-- Aggregate the information on the ID
GROUP BY Person.ID;

-- Creating a hierarchical data model

/*
In this exercise, you will construct a simple hierarchical data model by creating the hierarchy of IT assets. 
An asset can be either Hardware or Software. A Software asset can be split up into Application or Tools and so on. 
To model this hierarchy, a suitable data structure is needed. 
This structure can be accomplished by using a data model that consists of the child record ID and the parent record ParentID. 
The IDs are consecutive values from 1 to 10.
Your task is to create the corresponding Equipment table and to insert the assets Software, Monitor, and Microsoft Office into the table. 
Keep in mind that you have to set the correct IDs for each asset to achieve the desired hierarchy of assets.
*/

CREATE TABLE Equipment (   
    -- Define ID and ParentID 
	ID INT NOT NULL,
    Equipment VARCHAR(255) NOT NULL,
    ParentID INT NULL 
);

INSERT INTO Equipment VALUES (1,'Asset',NULL);
INSERT INTO Equipment VALUES (2,'Hardware',1);
-- Insert the type Software
INSERT INTO Equipment VALUES (3,'Software',1);
INSERT INTO Equipment VALUES (4,'Application',3);
INSERT INTO Equipment VALUES (5,'Tool',3);
INSERT INTO Equipment VALUES (6,'PC',2);
-- Insert the type Monitor 
INSERT INTO Equipment VALUES (7,'Monitor',2);
INSERT INTO Equipment VALUES (8,'Phone',2);
INSERT INTO Equipment VALUES (9,'IPhone',8);
-- Insert the type Microsoft Office 
INSERT INTO Equipment VALUES (10,'Microsoft Office',4);

SELECT * 
FROM Equipment;

-- Creating a networked data model

/*
In this last exercise, you will create a networked data model. 
A use case for this is finding all possible paths a bus can take from one location to another. 
Each route has a departure and destination location. 
A departure and destination location can appear multiple times. 
For example, you can go from San Francisco to New York, or from New York to Washington.
Your task is to create the Trip table, insert some routes into this table, and finally, select all possible departure locations from the table.
*/

CREATE TABLE Trip (   
    -- Define the Departure
  	Departure VARCHAR(255) NOT NULL,
    BusName VARCHAR(255) NOT NULL,
    -- Define the Destination
    Destination VARCHAR(255) NOT NULL,
);

-- Insert a route from San Francisco to New York
INSERT INTO Trip VALUES ( 'San Francisco' , 'Bus 1' , 'New York');
-- Insert a route from Florida to San Francisco
INSERT INTO Trip VALUES ( 'Florida', 'Bus 9' , 'San Francisco');
INSERT INTO Trip VALUES ( 'San Francisco', 'Bus 2','Texas');
INSERT INTO Trip VALUES ( 'San Francisco', 'Bus 3','Florida');
INSERT INTO Trip VALUES ( 'San Francisco', 'Bus 4','Washington');
INSERT INTO Trip VALUES ( 'New York', 'Bus 5','Texas');
INSERT INTO Trip VALUES ( 'New York', 'Bus 6','Washington');
INSERT INTO Trip VALUES ( 'Florida', 'Bus 7','New York');
INSERT INTO Trip VALUES ( 'Florida', 'Bus 8','Toronto');

-- Get all possible departure locations
SELECT DISTINCT Departure 
FROM Trip;

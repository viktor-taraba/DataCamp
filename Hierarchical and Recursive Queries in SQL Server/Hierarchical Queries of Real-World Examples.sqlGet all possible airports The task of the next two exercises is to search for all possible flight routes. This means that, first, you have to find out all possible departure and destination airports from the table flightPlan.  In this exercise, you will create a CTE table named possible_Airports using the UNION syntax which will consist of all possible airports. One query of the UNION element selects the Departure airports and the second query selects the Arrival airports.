-- Get all possible airports

/*
The task of the next two exercises is to search for all possible flight routes. 
This means that, first, you have to find out all possible departure and destination airports from the table flightPlan.
In this exercise, you will create a CTE table named possible_Airports using the UNION syntax which will consist of all possible airports. 
One query of the UNION element selects the Departure airports and the second query selects the Arrival airports.
*/

-- Definition of the CTE table
WITH possible_Airports (Airports) AS (
  	-- Select the departure airports
  	SELECT Departure
  	FROM flightPlan
  	-- Combine the two queries
  	UNION ALL 
  	-- Select the destination airports
  	SELECT Arrival
  	FROM flightPlan)

-- Get the airports from the CTE table
SELECT distinct Airports
FROM possible_Airports;

-- All flight routes from Vienna

/*
Previously, you looked at how the flight data is structured. 
You have already identified the necessary fields from the flightPlan table. 
These will be used in this exercise for the anchor and the recursive query.
The task of this exercise is to combine this knowledge to create a recursive query that:
gets all possible flights from Vienna
has a travel cost under 500 Euro
has fewer than 5 stops
You should output only the destinations and the corresponding costs!
*/

-- Define totalCost
WITH flight_route (Departure, Arrival, stops, totalCost, route) AS(
	SELECT 
	  	f.Departure, f.Arrival, 
	  	0,
	  	-- Define the totalCost with the flight cost of the first flight
	  	f.Cost,
	  	CAST(Departure + ' -> ' + Arrival AS NVARCHAR(MAX))
	FROM flightPlan f
	WHERE Departure = 'Vienna'
	UNION ALL
	SELECT 
	  	p.Departure, f.Arrival, 
	  	p.stops + 1,
	  	-- Add the cost for each layover to the total costs
	  	p.totalCost + f.Cost,
	  	p.route + ' -> ' + f.Arrival
	FROM flightPlan f, flight_route p
	WHERE p.Arrival = f.Departure AND 
	      p.stops < 5)

SELECT 
	DISTINCT Arrival, 
    totalCost
FROM flight_route
-- Limit the total costs to 500
WHERE totalCost < 500;

-- Create the parts list

/*
The first step in creating a bill of material is to define a hierarchical data model. 
To do this, you have to create a table BillOfMaterial with the following fields:
Your task is to define the field PartID as primary key, to define the field Cost, and to insert the following to records into the table:
Component: SUV, Title: BMW X1, Vendor: BMW, ProductKey: F48, Cost: 50000, Quantity: 1
Component: Wheels, Title: M-Performance 19/255, Vendor: BMW, ProductKey: MKQ134098URZ, Cost: 400, Quantity: 4
*/

CREATE TABLE Bill_Of_Material (
	-- Define PartID as primary key of type INT
  	PartID INT NOT NULL PRIMARY KEY,
	SubPartID INT,
	Component VARCHAR(255) NOT NULL,
	Title  VARCHAR(255) NOT NULL,
	Vendor VARCHAR(255) NOT NULL,
  	ProductKey CHAR(32) NOT NULL,
  	-- Define Cost of type INT and NOT NULL
  	Cost INT NOT NULL,
	Quantity INT NOT NULL);

-- Insert the root element SUV as described
INSERT INTO Bill_Of_Material
VALUES (1,NULL,'SUV','BMW X1','BMW','F48',50000,1);
INSERT INTO Bill_Of_Material
VALUES (2,1,'Engine','V6BiTurbro','BMW','EV3891ASF',3000,1);
INSERT INTO Bill_Of_Material
VALUES (3,1,'Body','AL_Race_Body','BMW','BD39281PUO',5000,1);
INSERT INTO Bill_Of_Material
VALUES (4,1,'Interior Decoration','All_Leather_Brown','BMW','ZEU198292',2500,1);
-- Insert the entry Wheels as described
INSERT INTO Bill_Of_Material
VALUES (5,1,'Wheels','M-Performance 19/255','BMW','MKQ134098URZ',400,4);

SELECT * 
FROM Bill_Of_Material;

-- Create a car's bill of material

/*
In this exercise, you will answer the following question: What are the levels of the different components that build up a car?
For example, an SUV (1st level), is made of an engine (2nd level), and a body (2nd level), and the body is made of a door (3rd level) and a hood (3rd level).
Your task is to create a query to get the hierarchy level of the table partList. 
You have to create the CTE construction_Plan and should keep track of the position of a component in the hierarchy. 
Keep track of all components starting at level 1 going up to level 2.
*/

-- Define CTE with the fields: PartID, SubPartID, Title, Component, Level
WITH construction_Plan (PartID, SubPartID, Title, Component, Level) AS (
	SELECT 
  		PartID,
  		SubPartID,
  		Title,
  		Component,
  		-- Initialize the field Level
  		1
	FROM partList
	WHERE PartID = '1'
	UNION ALL
	SELECT 
		CHILD.PartID, 
  		CHILD.SubPartID,
  		CHILD.Title,
  		CHILD.Component,
  		-- Increment the field Level each recursion step
  		PARENT.Level + 1
	FROM construction_Plan PARENT, partList CHILD
  	WHERE CHILD.SubPartID = PARENT.PartID
  	-- Limit the number of iterations to Level < 2
	  AND PARENT.Level < 2)

SELECT DISTINCT PartID, SubPartID, Title, Component, Level
FROM construction_Plan
ORDER BY PartID, SubPartID, Level;

-- Build up a BMW?

/*
In this exercise, you will answer the following question: 
What is the total required quantity Total of each component to build the car until level 3 in the hierarchy?
Your task is to create the CTE construction_Plan to track the level of components and to calculate the total quantity of components in the field Total. 
The table is set up by the fields PartID, SubPartID, Level, Component, and Total. 
You have to consider all components starting from level 1 up to level 3.
*/

-- Define CTE with the fields: PartID, SubPartID, Level, Component, Total
WITH construction_Plan (PartID, SubPartID, Level, Component, Total) AS (
	SELECT 
  		PartID,SubPartID,
  		0,
  		Component,
  		-- Initialize Total
  		Quantity
	FROM partList
	WHERE PartID = '1'
	UNION ALL
	SELECT 
		CHILD.PartID, CHILD.SubPartID,
  		PARENT.Level + 1,
  		CHILD.Component,
  		-- Increase Total by the quantity of the child element
  		PARENT.Total + CHILD.Quantity
	FROM construction_Plan PARENT, partList CHILD
  	WHERE CHILD.SubPartID = PARENT.PartID
	  AND PARENT.Level < 3)
      
SELECT 
    PartID, SubPartID,Component,
    -- Calculate the sum of total on the aggregated information
    SUM(Total)
FROM construction_Plan
GROUP BY PartID, SubPartID, Component
ORDER BY PartID, SubPartID;

-- Create a power grid

/*
In this exercise, you will create the structure table. 
This table describes how power lines are connected to each other. 
For this task, three ID values are needed:
EquipmentID: the unique key
EquipmentID_To: the first end of the power line with ID of the connected line
EquipmentID_From: the second end of the power line with ID of the connected line
The other fields to describe a power line, such as VoltageLevel and ConditionAssessment, are already defined.
For the line with EquipmentID = 3 the field EquipmentID_To is 4 and the field EquipmentID_From is 2.
*/

-- Create the table
CREATE TABLE structure (
    -- Define the field EquipmentID 
  	EquipmentID INT NOT NULL PRIMARY KEY,
    EquipmentID_To INT ,
    EquipmentID_From INT, 
    VoltageLevel TEXT NOT NULL,
    Description TEXT NOT NULL,
    ConstructionYear INT NOT NULL,
    InspectionYear INT NOT NULL,
    ConditionAssessment TEXT NOT NULL
);

-- Insert the record for line 1 as described
INSERT INTO structure
VALUES ( 1, 2, NULL, 'HV', 'Cable', 2000, 2016, 'good');
INSERT INTO Structure
VALUES ( 2, 3 , 1, 'HV', 'Overhead Line', 1968, 2016, 'bad');
INSERT INTO Structure
VALUES ( 3, 14, 2, 'HV', 'TRANSFORMER', 1972, 2001, 'good');
-- Insert the record for line 14 as described
INSERT INTO Structure
VALUES ( 14, 15, 3 , 'MV', 'Cable', 1976, 2002, 'bad');

SELECT * 
FROM structure

-- Get power lines to maintain

/*
In the provided GridStructure table, the fields that describe the connection between lines 
(EquipmentID,EquipmentID_To,EquipmentID_From) and the characteristics of the lines (e.g. Description, ConditionAssessment, VoltageLevel) are already defined.
Now, your task is to find the connected lines of the line with EquipmentID = 3 that have 
bad or repair as ConditionAssessment and have a VoltageLevel equal to HV. 
By doing this, you can answer the following question:
Which lines have to be replaced or repaired according to their description and their current condition?
You have to create a CTE to find the connected lines and finally, to filter on the desired characteristics.
*/

-- Define the table CTE
WITH maintenance_List (Line, Destination, Source, Description, ConditionAssessment, VoltageLevel) AS (
	SELECT 
  		EquipmentID,
  		EquipmentID_To,
  		EquipmentID_From,
  		Description,
  		ConditionAssessment,
  		VoltageLevel
  FROM GridStructure
 	-- Start the evaluation for line 3
	WHERE EquipmentID = 3
	UNION ALL
	SELECT 
		Child.EquipmentID, 
  		Child.EquipmentID_To,
  		Child.EquipmentID_FROM,
  		Child.Description,
  		Child.ConditionAssessment,
  		Child.VoltageLevel
	FROM GridStructure Child
  		-- Join GridStructure with CTE on the corresponding endpoints
  JOIN maintenance_List 
    	ON maintenance_List.Line = Child.EquipmentID_FROM)
SELECT Line, Description, ConditionAssessment 
FROM maintenance_List
-- Filter the lines based on ConditionAssessment and VoltageLevel
WHERE 
    (ConditionAssessment LIKE '%exchange%' OR ConditionAssessment LIKE '%repair%') AND 
     VoltageLevel LIKE '%HV%';

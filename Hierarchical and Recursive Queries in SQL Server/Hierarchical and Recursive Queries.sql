-- Create the alphabet recursively

/*
The task of this exercise is to create the alphabet by using a recursive CTE.
To solve this task, you need to know that you can represent the letters from A to Z 
by a series of numbers from 65 to 90. Accordingly, A is represented by 65 and C by 67. 
The function char(number) can be used to convert a number its corresponding letter.
*/

WITH alphabet AS (
	SELECT 
  		-- Initialize letter to A
	    65 AS number_of_letter
	-- Statement to combine the anchor and the recursive query
  UNION ALL
	SELECT 
  		-- Add 1 each iteration
	    number_of_letter + 1
  	-- Select from the defined CTE alphabet
	FROM alphabet
  	-- Limit the alphabet to A-Z
  WHERE number_of_letter < 90)
    
SELECT char(number_of_letter)
FROM alphabet;

-- Create a time series of a year

/*
The goal of this exercise is to create a series of days for a year. For this task you have to use the following 
two time/date functions:
GETDATE()
DATEADD(datepart, number, date)
With GETDATE() you get the current time (e.g. 2019-03-14 20:09:14) and with DATEADD(month, 1, GETDATE()) you get 
current date plus one month (e.g. 2019-04-14 20:09:14).
To get a series of days for a year you need 365 recursion steps. Therefore, increase the number of iterations 
by OPTION (MAXRECURSION n) where n represents the number of iterations.
*/

WITH time_series AS (
	SELECT 
  		-- Get the current time
	    GETDATE() AS time
  	UNION ALL
	SELECT 
	    DATEADD(day, 1, time)
  	-- Call the CTE recursively
	FROM time_series
  	-- Limit the time series to 1 year minus 1 (365 days -1)
  	WHERE time < GETDATE() + 364)
    
SELECT time
FROM time_series
-- Increase the number of iterations (365 days)
OPTION(MAXRECURSION 365)

-- Who is your manager?

/*
In this exercise, we are going to use the dataset of an IT-organization which is provided in the table employee. 
The table has the fields ID (ID number of the employee), Name (the employee's name), and Supervisor (ID number of the supervisor).
The IT-organization consists of different roles and levels.
The organization has one IT director (ID=1, Heinz Griesser, Supervisor=0) with many subordinate employees. 
Under the IT director you can find the IT architecture manager (ID=10, Andreas Sternig, Supervisor=1) with three subordinate employees.
For Andreas Sternig Supervisor=1 which is the IDof the IT-Director.
First, we want to answer the question: Who are the supervisors for each employee?
We are going to solve this problem by recursively querying the dataset.
*/

-- Create the CTE employee_hierarchy
WITH employee_hierarchy AS (
	SELECT
		ID, 
  		NAME,
  		Supervisor
	FROM employee
  	-- Start with the IT Director
	WHERE Supervisor = 0
	UNION ALL
	SELECT 
  		emp.ID,
  		emp.NAME,
  		emp.Supervisor
	FROM employee emp
  	JOIN employee_hierarchy
  		ON emp.Supervisor = employee_hierarchy.ID)
    
SELECT 
    cte.Name as EmployeeName,
    emp.Name as ManagerName
FROM employee_hierarchy as cte
JOIN employee as emp
	-- Perform the JOIN on Supervisor and ID
	ON cte.Supervisor = emp.ID;
	
-- Get the hierarchy position

/*
An important problem when dealing with recursion is tracking the level of recursion. 
In the IT organization, this means keeping track of the position in the hierarchy of each employee.
For this, you will use a LEVEL field which keeps track of the current recursion step. 
You have to introduce the field in the anchor member, and increment this value on each recursion step in the recursion member.
Keep in mind, the first hierarchy level is 0, the second level is 1 and so on.
*/

WITH employee_hierarchy AS (
	SELECT
		ID, 
  		NAME,
  		Supervisor,
  		-- Initialize the field LEVEL
  		1 as LEVEL
	FROM employee
  	-- Start with the supervisor ID of the IT Director
	WHERE Supervisor = 0
	UNION ALL
	SELECT 
  		emp.ID,
  		emp.NAME,
  		emp.Supervisor,
  		-- Increment LEVEL by 1 each step
  		LEVEL + 1
	FROM employee emp
	JOIN employee_hierarchy
  		-- JOIN on supervisor and ID
  		ON emp.supervisor = employee_hierarchy.ID)
    
SELECT 
	cte.Name, cte.Level,
    emp.Name as ManagerID
FROM employee_hierarchy as cte
JOIN employee as emp
	ON cte.Supervisor = emp.ID 
ORDER BY Level;

-- Which supervisor do I have?

/* 
In this exercise, we want to get the path from the boss at the top of the hierarchy, to the employees at the bottom of the hierarchy. 
For this task, we have to combine the information obtained in each step into one field. 
You can do this by combining the IDs using CAST() from number to string. 
An example is CAST(ID AS VARCHAR(MAX)) to convert ID of type number to type char.
The task is now to find the path for employees Chris Feierabend with ID=18 and Jasmin Mentil with ID=16 all the way to the top of the organization. 
The output should look like this: boss_first_level -> boss_second_level .... The IDs of the employees and not their names should be selected.
*/

WITH employee_Hierarchy AS (
	SELECT
		ID, 
  		NAME,
  		Supervisor,
  		-- Initialize the Path with CAST
  		CAST('0' AS VARCHAR(MAX)) as Path
	FROM employee
	WHERE Supervisor = 0
	-- UNION the anchor query 
  	UNION ALL
    -- Select the recursive query fields
	SELECT 
  		emp.ID,
  		emp.Name,
  		emp.Supervisor,
  		-- Add the supervisor in each step. CAST the supervisor.
        Path + '->' + CAST(emp.Supervisor AS VARCHAR(MAX))
	FROM employee emp
	INNER JOIN employee_Hierarchy
  		ON emp.Supervisor = employee_Hierarchy.ID
)

SELECT Path
FROM employee_Hierarchy
-- Select the employees Chris Feierabend and Jasmin Mentil
WHERE ID = 16 OR ID = 18;

-- Get the number of generations?

/*
In this exercise, we are going to look at a random family tree. 
The dataset family consists of three columns, the ID, the name, and the ParentID. 
Your task is to calculate the number of generations. 
You will do this by counting all generations starting from the person with ParentID = 101.
For this task, you have to calculate the LEVEL of the recursion which represents the current level in the generation hierarchy. 
After that, you need to count the number of LEVELs by using COUNT().
*/

WITH children AS (
    	SELECT 
  		ID, 
  		Name,
  		ParentID,
  		0 as LEVEL
    	FROM family 
  	-- Set the targeted parent as recursion start
	WHERE ParentID = 101
    	UNION ALL
    	SELECT 
  		child.ID,
  		child.NAME,
  		child.ParentID,
  		-- Increment LEVEL by 1 each step
  		LEVEL + 1
  	FROM family child
  	INNER JOIN children 
		-- Join the anchor query with the CTE   
  		ON child.ParentID = children.ID)
    
SELECT
	-- Count the number of generations
	count(*) as Generations
FROM children
OPTION(MAXRECURSION 300);

-- Get all possible parents in one field?

/*
Your final task in this chapter is to find all possible parents starting from one ID and combine the IDs of all found generations into one field.
To do this, you will search recursively for all possible members and add this information to one field. 
You have to use the CAST() operator to combine IDs into a string. You will search for all family members starting from ID = 290. 
In total there are 300 entries in the table family.
*/

WITH tree AS (
	SELECT 
  		ID,
  		Name, 
  		ParentID, 
  		CAST('0' AS VARCHAR(MAX)) as Parent
	FROM family
  	-- Initialize the ParentID to 290 
  	WHERE ParentID = 290    
    	UNION ALL
    	SELECT 
  		Next.ID, 
  		Next.Name, 
  		Parent.ID,
    	CAST(CASE WHEN Parent.ID = ''
        	  -- Set the Parent field to the current ParentID
                  THEN(CAST(Next.ParentID AS VARCHAR(MAX)))
        	  -- Add the ParentID to the current Parent in each iteration
             	  ELSE(Parent.Parent + ' -> ' + CAST(Next.ParentID AS VARCHAR(MAX)))
    		  END AS VARCHAR(MAX))
        FROM family AS Next
        INNER JOIN tree AS Parent 
  		ON Next.ParentID = Parent.ID)
        
-- Select the Name, Parent from tree
SELECT Name, Parent
FROM tree;

-- A CTE for IT-positions

/* 
To practice writing CTEs, let's start with a simple example. You will use the employee table which is built up of fields such as ID, Name, and Position. 
The task for you is to create a CTE called ITjobs (keep in mind the syntax WITH CTE_Name As) that finds employees starting with A whose job titles start with IT. 
Finally, a new query will retrieve all IT positions and names from the ITJobs CTE.

To search for a pattern, you have to use the LIKE statement and % representing the search direction. For example, using a WHERE statement with LIKE 'N%' will 
find patterns starting with N.
*/

-- Define the CTE ITjobs by the WITH operator
WITH ITjobs (ID, Name, Position) AS (
    SELECT 
  		ID, 
  		Name,
  		Position
    FROM employee
    -- Find IT jobs and names starting with A
  	WHERE Position LIKE 'IT%' AND Name LIKE 'A%')
    
SELECT * 
FROM ITjobs;

-- A CTE for high-paid IT-positions

/*
In the previous exercise, you created a CTE to find IT positions. Now, you will combine these results with another CTE on the salary table. 
You will use multiple CTE definitions in a single query. Notice that a comma is used to separate the CTE query definitions. 
The salary table contains some more information about the ID and salary of employees. Your task is to create a second CTE named ITsalary and JOIN 
both CTE tables on the employees ID. The JOIN should select only records having matching values in both tables. Finally, the task is to find only 
employees earning more than 3000.
*/

WITH ITjobs (ID, Name, Position) AS (
    SELECT 
  		ID, 
  		Name,
  		Position
    FROM employee
    WHERE Position like 'IT%'),
    
-- Define the second CTE table ITsalary with the fields ID and Salary
ITsalary (ID, Salary) AS (
    SELECT
        ID,
        Salary
    FROM Salary
  	-- Find salaries above 3000
    WHERE Salary > 3000)
    
SELECT 
	ITjobs.NAME,
	ITjobs.POSITION,
    ITsalary.Salary
FROM ITjobs
    -- Combine the two CTE tables the correct join variant
    INNER JOIN ITsalary
    -- Execute the join on the ID of the tables
    ON ITjobs.ID = ITsalary.ID;

-- Calculate the factorial of 5

/*
A very important mathematical operation is the calculation of the factorial of a positive integer n. In general, the factorial operation is used 
in many areas of mathematics, notably in combinatorics, algebra, and mathematical analysis.
The factorial of n is defined by the product of all positive integers less than or equal to n. For example, the factorial of 3 (denoted by n!) is defined as:
3! = 1 x 2 x 3 = 6
To calculate the factorial of n, many different solutions exist. In this exercise, you will determine the factorial of 5 iteratively with SQL.
*/

-- Define the target factorial number
DECLARE @target float = 5
-- Initialization of the factorial result
DECLARE @factorial float = 1

WHILE @target > 0 
BEGIN
	-- Calculate the factorial number
	SET @factorial = @factorial * @target
	-- Reduce the termination condition  
	SET @target = @target - 1
END

SELECT @factorial;

-- How to query the factorial of 6 recursively

/*
In the last exercise, you queried the factorial 5! with an iterative solution. Now, you will calculate 6! recursively. 
We reduce the problem into smaller problems of the same type to define the factorial n! recursively. For this the following definition can be used:
0! = 1 for step = 0
(n+1)! = n! * (step+1) for step > 0
With this simple definition you can calculate the factorial of every number. In this exercise, n! is represented by factorial.
You are going to leverage the definition above with the help of a recursive CTE.
*/

WITH calculate_factorial AS (
	SELECT 
		-- Initialize step and the factorial number      
      	1 AS step,
        1 AS factorial
	UNION ALL
	SELECT 
	 	step + 1,
		-- Calculate the recursive part by n!*(n+1)
	    factorial * (step + 1)
	FROM calculate_factorial        
	-- Stop the recursion reaching the wanted factorial number
	WHERE step < 6)
    
SELECT factorial 
FROM calculate_factorial;

-- Counting numbers recursively

/* In this first exercise after the video, we will start with a very simple math function. 
It is the simple series from 1 to target and in our case we set the target value to 50.
This means the task is to count from 1 to 50 using a recursive query. You have to define:
the CTE with the definition of the anchor and recursive query and
set the appropriate termination condition for the recursion
*/

-- Define the CTE
WITH counting_numbers AS ( 
	SELECT 
  		-- Initialize number
  		1 AS number
  	UNION ALL 
  	SELECT 
  		-- Increment number by 1
  		number + 1 
  	FROM counting_numbers
	-- Set the termination condition
  	WHERE number < 50)

SELECT number
FROM counting_numbers;

-- Calculate the sum of potencies

/*
In this exercise, you will calculate the sum of potencies recursively. This mathematical series is defined as:
result=1 for step = 1
result + step^step for step > 1
The numbers in this series are getting large very quickly and the series does not converge. 
The task of this exercise is to calculate the sum of potencies for step = 9.
*/

-- Define the CTE calculate_potencies with the fields step and result
WITH calculate_potencies (step, result) AS (
    SELECT 
  		-- Initialize step and result
  		1 as step,
  		1 as result
    UNION ALL
    SELECT 
  		step + 1,
  		-- Add the POWER calculation to the result 
  		result + POWER(step + 1, step + 1)
    FROM calculate_potencies
    WHERE step < 9)
    
SELECT 
	step, 
    result
FROM calculate_potencies;

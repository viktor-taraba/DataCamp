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




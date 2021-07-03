-- Select all columns from the INFORMATION_SCHEMA.TABLES system database. Limit results that have a public table_schema

 -- Select all columns from the TABLES system database
 SELECT * 
 FROM INFORMATION_SCHEMA.TABLES
 -- Filter by schema
 WHERE table_schema = 'public';
 
 -- Select all columns from the INFORMATION_SCHEMA.COLUMNS system database. Limit by table_name to actor
 
  -- Select all columns from the COLUMNS system database
 SELECT * 
 FROM INFORMATION_SCHEMA.COLUMNS 
 WHERE table_name = 'actor';
 
 -- Select the column name and data type from the INFORMATION_SCHEMA.COLUMNS system database. Limit results to only include the customer table.
 
 -- Get the column name and data type
SELECT
 	column_name, 
    data_type
-- From the system database information schema
FROM INFORMATION_SCHEMA.COLUMNS 
-- For the customer table
WHERE table_name = 'customer';

-- Select the rental date and return date from the rental table. Add an INTERVAL of 3 days to the rental_date to calculate the expected return date`.

SELECT
 	-- Select the rental and return dates
	rental_date,
	return_date,
 	-- Calculate the expected_return_date
	rental_date + INTERVAL '3 days' AS expected_return_date
FROM rental;

-- Select all films that have a special feature Trailers by filtering on the first index of the special_features ARRAY.

-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[1] = 'Trailers';

-- Now let's select all films that have Deleted Scenes in the second index of the special_features ARRAY.

-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[2] = 'Deleted Scenes';

-- Match 'Trailers' in any index of the special_features ARRAY regardless of position.

SELECT
  title, 
  special_features 
FROM film 
-- Modify the query to use the ANY function 
WHERE 'Trailers' = ANY (special_features);

-- Use the contains operator to match the text Deleted Scenes in the special_features column.

SELECT 
  title, 
  special_features 
FROM film 
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];


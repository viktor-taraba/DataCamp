-- Query the right table in information_schema
SELECT table_name 
FROM information_schema.tables
-- Specify the correct table_schema value
WHERE table_schema = 'public';

-- Query the right table in information_schema to get columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'university_professors' AND table_schema = 'public';

-- Create a table for the professors entity type
CREATE TABLE professors (
 firstname text,
 lastname text
);

-- Create a table for the universities entity type
CREATE TABLE universities (
    university_shortname text,
    university text,
    university_city text
);

-- Add the university_shortname column
ALTER TABLE professors
ADD COLUMN university_shortname text;

-- Print the contents of this table
SELECT * 
FROM professors

-- Rename the organisation column
ALTER TABLE affiliations
RENAME COLUMN organisation TO organization;

-- Delete the university_shortname column
ALTER TABLE affiliations
DROP COLUMN university_shortname;

-- Insert unique professors into the new table
INSERT INTO professors 
SELECT DISTINCT firstname, lastname, university_shortname 
FROM university_professors;

-- Doublecheck the contents of professors
SELECT * 
FROM professors;

-- Insert unique affiliations into the new table
INSERT INTO affiliations 
SELECT DISTINCT firstname, lastname, function, organization 
FROM university_professors;

-- Doublecheck the contents of affiliations
SELECT * 
FROM affiliations;

-- Delete the university_professors table
DROP TABLE university_professors;

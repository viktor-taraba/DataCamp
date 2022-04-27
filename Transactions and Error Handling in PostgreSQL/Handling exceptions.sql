-- Writing do statements

/* Commonly when cleaning data, we'll get data that will have bad dates in it. This would 
cause an exception and halt our SQL statement; however, by using a DO function with an exception 
handler, our statement will run to completion. Let's see how we can handle that type of exception 
with the patients table and the created_on column. This will also give us a chance to use a DO 
style function. */

-- Create a DO $$ function
DO $$
-- BEGIN a transaction block
BEGIN 
    INSERT INTO patients (a1c, glucose, fasting, created_on) 
    VALUES (5.8, 89, TRUE, '37-03-2020 01:15:54');
-- Add an EXCEPTION
EXCEPTION
-- For all all other type of errors
WHEN others THEN 
    INSERT INTO errors (msg, detail) 
    VALUES ('failed to insert', 'bad date');
END;
-- Make sure to specify the language
$$ language 'plpgsql';

-- Select all the errors recorded
SELECT * FROM errors;

-- Handling exceptions

/* In the slides, we discussed providing proper context for resolution. One area that is 
often overlooked when recording messages is the deeper reasoning for them. Oftentimes errors 
are generic like "Bad value" or "Invalid date." However, we can use details and context to 
enrich those messages.

Here we are going to work with A1C which is the percentage of red blood cells that have 
sugar attached to the hemoglobin. Typically fasting ranges are below 5.7% for non-affected 
patients, 5.7% to 6.4% for prediabetes, and over 6.5% is typically an indicator of unmanaged 
diabetes. */

-- Add a DO function
DO $$ 
-- BEGIN a transaction block
BEGIN 
    INSERT INTO patients (a1c, glucose, fasting) 
    values (20, 89, TRUE);

-- Add an EXCEPTION                   
EXCEPTION 
-- Catch all exception types
WHEN others THEN
    INSERT INTO errors (msg, detail, context) VALUES 
  (
    'failed to insert', 
    'This a1c value is higher than clinically accepted norms.', 
    'a1c is typically less than 14'
  );
END;
-- Make sure to specify the language
$$ language 'plpgsql';

-- Select all the errors recorded
SELECT * FROM errors;

-- Multiple exception blocks

/* Since ROLLBACK TO and SAVEPOINT can not be used in functions with exception handlers, 
we have a way to emulate the same behavior though using nested blocks. These nested blocks 
are used to group and order the statements in the order that they depend on each other. Here 
you are going to insert a block of records with an exception handler which emulates a SAVEPOINT, 
then update a record with an exception handler. That update statement will error, and the 
exception handler will automatically rollback just that block. */

-- Make a DO function
DO $$
-- Open a transaction block
BEGIN
    -- Open a nested block
    BEGIN
    	INSERT INTO patients (a1c, glucose, fasting) 
        VALUES (5.6, 93, TRUE), (6.3, 111, TRUE), (4.7, 65, TRUE);
    -- Catch all exception types
    EXCEPTION WHEN others THEN
    	INSERT INTO errors (msg) VALUES ('failed to insert');
    -- End nested block
    END;
    -- Begin the second nested block
	BEGIN
    	UPDATE patients SET fasting = 'true' WHERE id=1;
    -- Catch all exception types
    EXCEPTION WHEN others THEN
        INSERT INTO errors (msg) VALUES ('Inserted string into boolean.');
    -- End the second nested block
    END;
-- END the outer block
END;
$$ language 'plpgsql';
SELECT * FROM errors;

-- Capturing specific exceptions
/* Let's build a DO function that captures when glucose is set to null, and logs a 
message stating explicitly that Glucose can not be null. */

-- Make a DO function
DO $$
-- Open a transaction block
BEGIN
    INSERT INTO patients (a1c, glucose, fasting) 
    VALUES (7.5, null, TRUE);
-- Catch an Exception                                                               
EXCEPTION
	-- Make it catch not_null_constraint exception types
    WHEN not_null_violation THEN
    	-- Insert the proper msg and detail
       INSERT INTO errors (msg, detail) 
       VALUES ('failed to insert', 'Glucose can not be null.');
END$$;
                                                                     
-- Select all the errors recorded
SELECT * FROM errors;

-- Logging messages on specific exceptions

/* One of the best uses of catching multiple specific exception is to distinctly 
handle and log unique error message that help you understand exactly why an exception 
occurred. Let's apply this in a scenario where both error conditions are possible. 
We'll discuss after the exercise why it capture the specific message it did. */

-- Make a DO function
DO $$
-- Open a transaction block
BEGIN
    INSERT INTO patients (a1c, glucose, fasting) values (20, null, TRUE);
-- Catch an Exception                                                               
EXCEPTION
	-- Make it catch check_violation exception types
    WHEN check_violation THEN
    	-- Insert the proper msg and detail
       INSERT INTO errors (msg, detail)
       VALUES ('failed to insert', 'A1C is higher than clinically accepted norms.');
    -- Make it catch not_null_violation exception types
    WHEN not_null_violation THEN
    	-- Insert the proper msg and detail
       INSERT INTO errors (msg, detail) 
       VALUES ('failed to insert', 'Glucose can not be null.');
END$$;
                                                                     
-- Select all the errors recorded
SELECT * FROM errors;

-- Graceful degradation

/* Now that you've seen how to handle and raise exceptions, how can you use that to 
gracefully fall back to save data points when they exceed database constraints or hit 
another error? Let's see how you can gracefully fall back to the maximum accepted value 
when we are out of range. */

-- Start a DO statement with $$ as the end marker
DO $$
-- Begin a code block
BEGIN
     -- Insert the data into patients
     INSERT INTO patients (a1c, glucose, fasting) values (20, 800, False);
-- Catch a check_violation exception
EXCEPTION WHEN check_violation THEN
    -- RAISE the violation notice
    INSERT INTO errors (msg) values ('This A1C is not valid, should be between 0-13');
    -- INSERT the max A1C value
    INSERT INTO patients (a1c, glucose, fasting) VALUES (13, 800, False);
    -- Record an error that you overrode the prior data insert
    INSERT INTO errors (msg) VALUES ('Set A1C to the maximum of 13');

-- END the code block and declare the language
END; 
$$ language 'plpgsql';

SELECT * from errors;

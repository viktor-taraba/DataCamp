-- Getting stacked diagnostics

/* Stacked diagnostics can get the internal PostgreSQL error message and exception details. 
Let's revisit our patients table and try to add an A1C that is above the testing limit. 
This will cause a check constraint exception that we can capture. We can use the stacked 
diagnostics in the exception handler to enrich our error recording. */

DO $$ 
-- Declare our text variables: exc_message and exc_detail 
DECLARE
   exc_message text;
   exc_detail text;
BEGIN 
    INSERT INTO patients (a1c, glucose, fasting) 
    values (20, 89, TRUE);
EXCEPTION 
WHEN others THEN
    -- Get the exception message and detail via stacked diagnostics
	GET STACKED DIAGNOSTICS 
    	exc_message = MESSAGE_TEXT,
        exc_detail = PG_EXCEPTION_DETAIL;
    -- Record the exception message and detail in the errors table
    INSERT INTO errors (msg, detail) VALUES (exc_message, exc_detail);
END;
$$ language 'plpgsql';

-- Select all the errors recorded
SELECT * FROM errors;

-- Capturing a context stack

/* Getting the stack context, which is like a stack trace in other languages, 
is a powerful way to debug complex and nested functions.

In the code below, we want to capture the stack context and record it in the exception 
handlers of both nested blocks. Then, we want to review its output in the errors table 
to help debug what's causing the exception in this function. */

DO $$
DECLARE
   exc_message text;
   exc_details text;
   -- Declare a variable, exc_context to hold the exception context
   exc_context text;
BEGIN
    BEGIN
    	INSERT INTO patients (a1c, glucose, fasting) values (5.6, 93, TRUE),
        	(6.3, 111, TRUE),(4.7, 65, TRUE);
    EXCEPTION
        WHEN others THEN
        -- Store the exception context in exc_context
        GET STACKED DIAGNOSTICS exc_message = MESSAGE_TEXT,
                                exc_context = PG_EXCEPTION_CONTEXT;
        -- Record both the msg and the context
        INSERT INTO errors (msg, context) 
           VALUES (exc_message, exc_context);
    END;
	BEGIN
    	UPDATE patients set fasting = 'true' where id=1;
    EXCEPTION
        WHEN others THEN
        -- Store the exception detail in exc_details
        GET STACKED DIAGNOSTICS exc_message = MESSAGE_TEXT,
                                exc_details = PG_EXCEPTION_DETAIL;
        INSERT INTO errors (msg, detail) 
           VALUES (exc_message, exc_context);
    END;
END$$;
SELECT * FROM errors;

-- Creating named functions and declaring variables

/* Now that you've seen a powerful debugging function in action, let's build one of your own. 
First, start by using defining the function signature which supplied the function name, 
any parameters, and a return type. After that point, it's the same as a DO function. */

-- Define our function signature
CREATE OR REPLACE FUNCTION debug_statement(
    sql_stmt TEXT
)
-- Declare our return type
RETURNS BOOLEAN AS $$
    DECLARE
        exc_state   TEXT;
        exc_msg     TEXT;
        exc_detail  TEXT;
        exc_context TEXT;
    BEGIN
        BEGIN
            -- Execute the statement passed in
            EXECUTE sql_stmt;
        EXCEPTION WHEN others THEN
            GET STACKED DIAGNOSTICS
                exc_state   = RETURNED_SQLSTATE,
                exc_msg     = MESSAGE_TEXT,
                exc_detail  = PG_EXCEPTION_DETAIL,
                exc_context = PG_EXCEPTION_CONTEXT;
            INSERT into errors (msg, state, detail, context) values (exc_msg, exc_state, exc_detail, exc_context);
            -- Return True to indicate the statement was debugged
            RETURN TRUE;
        END;
        -- Return False to indicate the statement was not debugged
        RETURN FALSE;
    END;
$$ LANGUAGE plpgsql;
SELECT debug_statement('INSERT INTO patients (a1c, glucose, fasting) values (20, 89, TRUE);')

-- Putting it all together

/* Now you're ready to put together what you learned in Chapter 4 with the stacked 
diagnostics functions from the previous exercises. I've already created the patients table 
from the prior exercise as well as the debug_statement function. You'll begin by debugging 
another exception type. Then you'll combine a DO function, SQL statements stored in a variable, 
and trigger debugging on an exception. */

DO $$
-- Begin a code block
DECLARE
    stmt VARCHAR(100) := 'INSERT INTO patients (a1c, glucose, fasting) VALUES (20, 800, False)';
BEGIN
     -- Insert the data into patients by running the statement
     EXECUTE stmt;
-- Catch a check_violation exception and perform the debug_statement function on it. 
EXCEPTION WHEN OTHERS THEN
    PERFORM debug_statement(stmt);
-- END the code block and declare the language
END; $$ language 'plpgsql';
-- Select from the errors table
SELECT * FROM errors;

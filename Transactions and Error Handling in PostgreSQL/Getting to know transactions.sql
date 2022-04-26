-- Making our first transaction

/* Now you're ready to build your first transaction. As mentioned in the slides, you are working 
with data from the FFEIC, which is the organization in the US that sets bank standards and reporting formats. 
Recently they changed the rules for reporting if you provide consumer deposit accounts to being true 
only if you have more than $5,000,000 in brokered deposits.

Let's use a transaction to make that update safely. The "Provides Consumer Deposits" flag is 
in the RCONP752 column and the brokered deposits is in the RCON2365 column. */

-- Begin a new transaction
BEGIN;

-- Update RCOP752 to true if RCON2365 is over 5000000
UPDATE ffiec_reci
SET RCONP752 = 'true'
WHERE RCON2365 > 5000000;

-- Commit the transaction
COMMIT;

-- Select a count of records now true
SELECT COUNT(RCONP752)
FROM ffiec_reci
WHERE RCONP752 = 'true';

# Multiple statement transactions

/* Now let's use multiple statements in a transaction to set a flag in FIELD48 based on if it holds US 
state government assets represented in RCON2203, foreign assets represented in RCON2236, or both.

The values for FIELD48 should be 'US-STATE-GOV', 'FOREIGN', or 'BOTH' respectively. Flag fields like 
this are common in government data sets, and are great for categorizing records. */

-- Begin a new transaction
BEGIN;

-- Update FIELD48 flag status if US State Government deposits are held
UPDATE ffiec_reci
SET FIELD48 = 'US-STATE-GOV'
WHERE RCON2203 > 0;

-- Update FIELD48 flag status if Foreign deposits are held
UPDATE ffiec_reci
SET FIELD48 = 'FOREIGN'
WHERE RCON2236 > 0;

-- Update FIELD48 flag status if US State Government and Foreign deposits are held
UPDATE ffiec_reci
SET FIELD48 = 'BOTH'
WHERE RCON2203 > 0
AND RCON2236 > 0;

-- Commit the transaction
COMMIT;

-- Select a count of records where FIELD48 is now BOTH
SELECT COUNT(FIELD48)
FROM ffiec_reci
WHERE FIELD48 = 'BOTH';

# Single statement transactions

/* Now you will work with a single statement transaction. Some types of saving accounts hold money 
that cannot be withdrawn on demand for individuals and corporations. The amount of the heldback money 
is stored in the RCONB550 field. These types of accounts promote bank stability and generate dependable 
revenue for the financial institution via fees and loan proceeds. Let's update FIELD48 to be '1' for 
each of these institutions to signify that they have this stability when it's over $100M. */

-- Update records to indicate nontransactionals over 100,000,000
UPDATE ffiec_reci
SET FIELD48 = '1'
WHERE RCONB550 > 100000000;

-- Select a count of records where the flag field is not '1'
SELECT COUNT(*)
FROM ffiec_reci
WHERE FIELD48 != '1' or FIELD48 is null;

# Using an isolation level

/* As seen in the video, sometimes it's important to be able to select an isolation level for an 
individual transaction. It's best to use START TRANSACTION to do this which is an alias 
of BEGIN TRANSACTION to make it clear something is different. You can specify an ISOLATION LEVEL 
when starting the transaction.

Here we are going to use REPEATABLE READ which protects us from dirty reads, nonrepeatable reads, 
and phantom reads. In the FFEIC data, RCON2210 is the demand deposits field, and tracks all outstanding 
checking accounts, bank-issued checks and unposted credits. They can be a liability to a bank if there 
was a funds rush for any reason. Let's find all those banks with over $100,000,000 in demand deposits. */

-- Create a new transaction with an isolation level of repeatable read
START TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Count of records over 100000000
SELECT Count(RCON2210)
FROM ffiec_reci
WHERE RCON2210 > 100000000;

-- Count of records still over 100000000
SELECT Count(RCON2210)
FROM ffiec_reci
WHERE RCON2210 > 100000000;

-- Commit the transaction
COMMIT;

# Isolation levels and transactions

/* SERIALIZABLE is an isolation level that takes a snapshot of the record when the first query 
or update statement is issued, and errors if the data is altered in any way outside of the transaction. 
Note that the transaction can do other work, such as declare variables, prior to the first query.

You'll be using the FFIEC dataset again to work with data where the annual change in savings deposits 
RCON0352 is affected by a large offset. */

-- Create a new transaction with a serializiable isolation level
START TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Update records with a 50% reduction if greater than 100000
UPDATE ffiec_reci
SET RCON0352 = RCON0352 * 0.5
WHERE RCON0352 > 100000;

-- Commit the transaction
COMMIT;

-- Select a count of records still over 100000
SELECT count(RCON0352)
FROM ffiec_reci
WHERE RCON0352 > 100000;

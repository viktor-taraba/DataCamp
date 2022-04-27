-- Using rollbacks

/* Recently the FFIEC changed the reporting requirement for bank's that provide consumer 
deposit accounts if they have more than $5,000,000 in brokered deposits. Let's use a transaction 
to make that update safely. The "Provides Consumer Deposits" flag is in the RCONP752 column and 
the amount of brokered deposits is in the RCON2365 column. */

-- Begin a new transaction
BEGIN;

-- Update RCONP752 to true if RCON2365 is over 5000
UPDATE ffiec_reci
SET RCONP752 = 'true'
WHERE RCON2365 > 5000;

-- Oops that was supposed to be 5000000 undo the statement
ROLLBACK;

-- Update RCOP752 to true if RCON2365 is over 5000000
UPDATE ffiec_reci
SET RCONP752 = 'true'
WHERE RCON2365 > 5000000;

-- Commit the transaction
COMMIT;

-- Select a count of records now true
SELECT count(RCONP752)
FROM ffiec_reci
WHERE RCONP752 = 'true';

-- Multistatement Rollbacks

/* Now let's use multiple statements in a transaction to set a flag in FIELD48 based on if 
it holds US state government assets represented in RCON2203, foreign assets represented in 
RCON2236, or both. The values for FIELD48 should be 'US-STATE-GOV', 'FOREIGN', or 'BOTH' 
respectively. However, You've made a mistake in the statement for both. */

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
SET FIELD48 = 'BOOTH'
WHERE RCON2236 > 0
AND RCON2203 > 0;

-- Undo the mistake
ROLLBACK; 

-- Select a count of records that are booth (it should be 0)
SELECT COUNT(FIELD48)
FROM ffiec_reci
WHERE FIELD48 = 'BOOTH';

-- Working with a single savepoint

/* Banks that carry large value in Money Market Deposit Accounts (MMDA) are often resilient 
to downturns in the economy. In order to classify banks, we'll use a flag field such as FIELD48 
to store information useful for further processing. Let's flag banks with over 5000000. */

BEGIN;

-- Set the flag to indicate that they hold MMDAs where more than $5 million
UPDATE ffiec_reci 
SET FIELD48 = 'MMDA' 
WHERE RCON6810 > 5000000;

-- Set a savepoint
SAVEPOINT mmda_flag_set;

-- Rollback the whole transaction
ROLLBACK;

COMMIT;

-- Rolling back with a savepoint

/* Building upon the last exercise, it turns out that banks with more than $6 million 
in MMDAs are twice as likely to sustain during a downturn than those with between $5 and 
6 million in that same asset class. Here I've made a mistake in the sample code, and we 
need to rollback to the save point to maintain data integrity. */

BEGIN;

-- Set the flag to MMDA+ where the value is greater than $6 million
UPDATE ffiec_reci set FIELD48 = 'MMDA+' where RCON6810 > 6000000;

-- Set a Savepoint
SAVEPOINT mmdaplus_flag_set;

-- Mistakenly set the flag to MMDA+ where the value is greater than $5 million
UPDATE ffiec_reci set FIELD48 = 'MMDA+' where RCON6810 > 5000000;

-- Rollback to savepoint
ROLLBACK TO mmdaplus_flag_set;

COMMIT;

-- Select count of records where the flag is MMDA+
SELECT count(FIELD48) from ffiec_reci where FIELD48 = 'MMDA+';

-- Multiple savepoints

/* A risky area for banks during a distressed market is the number of maturing time deposits 
in the near future. It's highly likely that these timed deposits will be withdrawn to make 
other financial moves by the depositor. RCONHK07 + RCONHK12 stores those maturing in the 
next three months and RCONHK08 + RCONHK13 stores those expiring between 3 and 12 months.

If the total amounts in these columns are higher than $10 million it can be a drag on 
available funds to cover withdrawals and would receive a negative rating. Additionally, 
if there is less than $2 million, it has been shown to be a positive factor. */

BEGIN;

-- Update FIELD48 to indicate a positive maturity rathing when less than $2 million of maturing deposits.
UPDATE ffiec_reci 
SET FIELD48 = 'mature+' 
WHERE RCONHK07 + RCONHK12 + RCONHK08 + RCONHK13 < 2000000;

-- Set a savepoint
SAVEPOINT matureplus_flag_set;

-- Update FIELD48 to indicate a negative maturity rathing when between $2 and $10 million 
UPDATE ffiec_reci 
SET FIELD48 = 'mature-' 
WHERE RCONHK07 + RCONHK12 + RCONHK08 + RCONHK13 BETWEEN 2000000 AND 10000000;

-- Set a savepoint
SAVEPOINT matureminus_flag_set;

-- Update FIELD48 to indicate a double negative maturity rathing when more than $10 million
UPDATE ffiec_reci 
SET FIELD48 = 'mature--' 
WHERE RCONHK07 + RCONHK12 + RCONHK08 + RCONHK13 > 10000000;

COMMIT;

-- Count the records where FIELD48 is a positive indicator
SELECT count(FIELD48) 
FROM ffiec_reci 
WHERE FIELD48 = 'mature+';

-- Savepoints and rolling back

/* Continuing to think about the amount of maturing time deposits in the near future. 
The ones over 250K have the most impact on the outcomes seen during the 2008 market.

RCONHK12 (>=250k) stores those maturing in the next three months and RCONHK13 (>=250k) 
stores those expiring between 3 and 12 months. If these are higher than $1 million dollars 
it can cause a funds shortage at a bank as these are typically larger customers of the bank 
who might also pull other assets. Again, there is a positive factor if these 
are less than $500K.

I've made a few mistakes in my code by setting the wrong value for those over $500 thousand! */

BEGIN;

-- Update FIELD48 to indicate a positive maturity rathing when less than $500 thousand.
UPDATE ffiec_reci 
SET FIELD48 = 'mature+' 
WHERE RCONHK12 + RCONHK13 < 500000;

-- Set a savepoint
SAVEPOINT matureplus_flag_set;

-- Update FIELD48 to indicate a negative maturity rathing when between $500 thousand and $1 million.
UPDATE ffiec_reci 
SET FIELD48 = 'mature-' 
WHERE RCONHK12 + RCONHK13 BETWEEN 500000 AND 1000000;

-- Set a savepoint
SAVEPOINT matureminus_flag_set;

-- Accidentailly update FIELD48 to indicate a double negative maturity rating when more than 100K
UPDATE ffiec_reci 
SET FIELD48 = 'mature--' 
WHERE RCONHK12 + RCONHK13 > 100000;

-- Rollback to before the last mistake
ROLLBACK TO matureminus_flag_set;

-- Select count of records with a double negative indicator
SELECT count(FIELD48) 
from ffiec_reci 
WHERE FIELD48 = 'mature--';

-- Working with repeatable read

/* With the video in mind, let's do some hands on work with a repeatable read transaction. 
We want to set a "stability" factor for a bank's in-house assets if they allow consumer 
deposits. We'll do this by setting a custom field, FIELD48, equal to a retainer value if 
the bank allows consumer deposit accounts as indicated in RCONP752.

Interference from an external transaction would alter the application of our factor. 
Repeatable read protects your transaction from outside sources changing data that was 
available to us when we ran our first query in the transaction. */

-- Create a new transaction with a repeatable read isolation level
START TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Update records for banks that allow consumer deposit accounts
UPDATE ffiec_reci 
SET FIELD48 = 100 
WHERE RCONP752 = 'true';

-- Update records for banks that do not allow consumer deposit accounts
UPDATE ffiec_reci 
SET FIELD48 = 50 
WHERE RCONP752 = 'false';

-- Commit the transaction
COMMIT;

-- Savepoint's effect on isolation levels

/* Now that you've explored savepoints, let's use them to set up a series of transactions 
that all need to work from the same initial snapshot of the data. REPEATABLE READ is an 
isolation level that enables us to give each statement inside the transaction the same data 
as the first statement operated on instead of the data as a result of the prior statement(s).

Recently, the FFEIC allowed for a progressive curtailment of foreign deposits, field RCON2203 
in thousands, in the dataset. The new curtailment is 35% for more than $1 billion, 25% for 
more than $500 million, and 13% for more than $300 million. It's possible to order these 
statements to avoid reducing the data more than once. However, statements have the data 
before any adjustments with REPEATABLE READ. */

-- Create a new transaction with a repeatable read isolation level
START TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Update records with a 35% reduction if greater than 1000000000
UPDATE ffiec_reci 
SET RCON2203 = CAST(RCON2203 AS FLOAT) * .65 
WHERE CAST(RCON2203 AS FLOAT) > 1000000000;

SAVEPOINT million;

-- Update records with a 25% reduction if greater than 500000000
UPDATE ffiec_reci 
SET RCON2203  = CAST(RCON2203 AS FLOAT) * .75 
WHERE CAST(RCON2203 AS FLOAT) > 500000000;

SAVEPOINT five_hundred;

-- Update records with a 13% reduction if greater than 300000000
UPDATE ffiec_reci 
SET RCON2203  = CAST(RCON2203 AS FLOAT) * .87 
WHERE CAST(RCON2203 AS FLOAT) > 300000000;

SAVEPOINT three_hundred;

-- Commit the transaction
COMMIT;

-- Select SUM the RCON2203 field
SELECT SUM(CAST(RCON2203 AS FLOAT)) 
FROM ffiec_reci 

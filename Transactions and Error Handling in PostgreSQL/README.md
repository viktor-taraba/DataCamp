# **Transactions and Error Handling in PostgreSQL**

Link: https://app.datacamp.com/learn/courses/transactions-and-error-handling-in-postgresql

## **Course Description**

Being able to leverage transactions and find and handle errors is critical to building resilient SQL scripts and working with databases. Transactions provide the protection needed to ensure that your data is consistent and operations work on the desired data in concurrent environments. Improper error handling can cause many serious and unexpected issues. Without the proper use of transactions and error handling, it's possible to make decisions based on incorrect data leading to false outcomes. In this course, we'll cover proper ways to use transactions and handle errors with a record of what went wrong. Additionally, we discuss how concurrently plays into the use of transactions and data outcomes. We'll practice these concepts on the FFEIC bank health data and with a patient data table.

## **Course Structure**

| № | Module | Description |
| - | - | - |
| 1 | Getting to know transactions | This chapter focuses on learning about single and multistatement transactions and the read committed isolation level |
| 2 | Rolling back and Savepoints | How to rollback when an error is encountered in a transaction block and setting savepoints |
| 3 | Handling exceptions | In this chapter, you'll learn about exceptions and how to handle them |
| 4 | Stacked Diagnostics | With stacked diagnostics, you can get all the information available from PostgreSQL about an exception |

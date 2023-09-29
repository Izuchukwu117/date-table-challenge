# date-table-challenge
Creation of a date table using MSSQL. This is in response to a challenge posed on twitter to create a date table with the following columns:
1. date
2. year
3. day of year
4. quarter
5. quarter start date
6. quarter end date
7. month number
8. month name
9. month start date
10. month end date
11. week number (in year)
12. weekday name
13. weekday name short
14. weekday number
15. day (in month)
16. week start date
17. weekend date
18. year-month
19. year-quarter
20. fiscal year
21. fiscal quarter
22. is_holiday
23. is_weekend
Here is a screenshot of part of the table created with SQL code.
![Media Player 29_09_2023 22_46_08](https://github.com/Izuchukwu117/date-table-challenge/assets/105235855/c79be22c-6776-41da-8da5-d142ef32d304)
The query was optimized to run at a click. This was done by creating the date table (with 23 columns) using the CREATE TABLE command. Then a truncate command was introduced to clear any existing table content before inserting new contents into the table using a set of query commands from a Common Table Expressions (CTE).
The CTE contains a list of dates from 1/1/2023 to 31/12/2023.

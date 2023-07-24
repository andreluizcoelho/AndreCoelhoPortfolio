-- Selecting the Data
SELECT* 
FROM greenenergy.greenenergyshare;

SELECT* 
FROM greenenergy.greenenergyshare
ORDER BY 4 DESC;

SELECT*
FROM shareelecbysource;

SELECT* 
FROM shareelecbysource
ORDER BY 4,5,6 DESC;

-- First looking into the greenenergyshare data 
-- Count the number of rows (records) in the data
-- Thre are 4787 records in the data
SELECT COUNT(*)
FROM greenenergyshare;

-- Count the number of columns (fields or attributes) in the data
-- There are 4 fields in the data 
SELECT COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'greenenergy' AND TABLE_NAME = 'greenenergyshare';


/* Let's see how the countries are for the year 2022 in renewables (% equivalent primary energy) on greenenergyshare
 As for the shareelecbysource some countries do not have the complete dates
*/

SELECT* 
FROM greenenergyshare
ORDER BY 4 DESC;


SELECT* 
FROM greenenergyshare
WHERE Year = 2022
ORDER BY 4 DESC;

-- Keep the rows in the Code column that does not have empty rows, also only for the Year 2022, 
-- Also ordering in descending order by Renewables (%) showing only the top 10 
SELECT * 
FROM greenenergyshare
WHERE Code <> ''
HAVING Year = 2022
ORDER BY 4 DESC
LIMIT 10;

-- Duplicate an existing column and renaming it 
ALTER TABLE greenenergyshare
ADD COLUMN `Renewables` DOUBLE AFTER `Renewables (% equivalent primary energy)`;

UPDATE greenenergyshare
SET `Renewables` = `Renewables (% equivalent primary energy)`;

-- *if there is a need to drop a column
-- ALTER TABLE greenenergyshare 
-- DROP COLUMN Renewables;


-- round to 2 decimal places
UPDATE greenenergyshare
SET `Renewables` = ROUND(`Renewables`, 2);


-- dropping the column  `Renewables (% equivalent primary energy)`,
-- I could've renamed and rounded the column but I wanted to duplicate it, then I decided to drop it
ALTER TABLE greenenergyshare 
DROP COLUMN `Renewables (% equivalent primary energy)`;

/* The results of top 10 Renewables (% equivalent primary energy) by descending order follows:
Norway      71.63%
Sweden      53.31%
Brazil      48.74%
New Zealand 43.07%
Denmark     43.04%
Finland     38.5%
Austria     36.61%
Switzerland 33.08%
Colombia    30.85%
Canada      30.62%
*/

SELECT * 
FROM greenenergyshare
WHERE Code <> ''
HAVING Year = 2022
ORDER BY 4 DESC;

-- Now looking at the shareelecbysource data
SELECT*
FROM shareelecbysource;


SELECT * 
FROM shareelecbysource
WHERE Code <> ''
HAVING Year = 2022
ORDER BY 4 DESC;

-- INNER JOIN ON both data using the code column
SELECT*
FROM shareelecbysource as s
INNER JOIN greenenergyshare as g
ON s.code = g.code;

-- There are 3 common columns that are duplicated, I need to keep one of them to create a table with the saved join
SELECT s.Entity AS entitysharelec, s.Code AS codesharelec, s.Year AS yearsharelec, `Coal (% electricity)`, `Gas (% electricity)`, `Hydro (% electricity)`, `Solar (% electricity)`, `Wind (% electricity)`, `Oil (% electricity)`, `Nuclear (% electricity)`, `Other renewables excluding bioenergy (% electricity)`, `Bioenergy (% electricity)`, g.Entity AS entity_greenshare, g.Code AS code_greenshare, g.Year AS year_greenshare, Renewables
FROM shareelecbysource as s
INNER JOIN greenenergyshare as g
ON s.code = g.code;


-- create a table from the inner join 
CREATE TABLE greenenergyjoin AS
SELECT s.Entity AS entitysharelec, s.Code AS codesharelec, s.Year AS yearsharelec, `Coal (% electricity)`, `Gas (% electricity)`, `Hydro (% electricity)`, `Solar (% electricity)`, `Wind (% electricity)`, `Oil (% electricity)`, `Nuclear (% electricity)`, `Other renewables excluding bioenergy (% electricity)`, `Bioenergy (% electricity)`, g.Entity AS entity_greenshare, g.Code AS code_greenshare, g.Year AS year_greenshare, Renewables
FROM shareelecbysource as s
INNER JOIN greenenergyshare as g
ON s.code = g.code;

-- now selecting the joined table 

SELECT * 
FROM greenenergyjoin
ORDER BY codesharelec DESC;

-- Checking if the columns have the same values 
SELECT * 
FROM greenenergyjoin
WHERE codesharelec = code_greenshare;

-- dropping the code_greenshare column

ALTER TABLE greenenergyjoin
DROP COLUMN code_greenshare;

SELECT * 
FROM greenenergyjoin;


SELECT * 
FROM greenenergyjoin
ORDER BY yearsharelec, year_greenshare DESC;

-- checking if the two columns have the same values, it results in fewer rows, so it does not 
SELECT * 
FROM greenenergyjoin
WHERE entitysharelec = entity_greenshare;

-- getting rid of null values in the codesharelec column, and keep the year_greenshare = 2022 and yearshareelec = 2022
-- and creating a new table
CREATE TABLE greenjoinotnull AS
SELECT * 
FROM greenenergyjoin
WHERE codesharelec <> ''
HAVING year_greenshare = 2022 AND yearsharelec = 2022
ORDER BY codesharelec DESC;

-- Looking into the new table
-- The new table now has 51 rows
SELECT * 
FROM greenjoinotnull
ORDER BY Renewables DESC;

-- Checking if the entitysharelec column has the same name as the entity_greenshare
SELECT * 
FROM greenjoinotnull
WHERE entitysharelec = entity_greenshare
ORDER BY Renewables DESC;

-- And it does, nice

-- Looking more into this greenjoinnotnull data

SELECT * 
FROM greenjoinotnull;

-- dropping two columns that are the same 
ALTER TABLE greenjoinotnull 
DROP COLUMN entity_greenshare, 
DROP COLUMN year_greenshare;

SELECT * 
FROM greenjoinotnull;

-- renaming the column renewables so I do not forget it is in %, in fact the original column name is
-- Renewables (% equivalent primary energy)

ALTER TABLE greenjoinotnull
CHANGE COLUMN Renewables `Renewables (%)` DOUBLE;

-- then I decided to rename it as the original name
ALTER TABLE greenjoinotnull 
CHANGE COLUMN `Renewables (%)` `Renewables (% equivalent primary energy)` DOUBLE;


SELECT * 
FROM greenjoinotnull;

SELECT COUNT(*)
FROM greenjoinotnull;
-- 51 records (rows)

SELECT COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'greenenergy' AND TABLE_NAME = 'greenjoinotnull';
-- 13 fields (columns)


-- Checking if it really adds to 100%
-- First I need to create the new column 


ALTER TABLE greenjoinotnull
ADD COLUMN `Resources (% electricity)` DOUBLE;


UPDATE greenjoinotnull
SET `Resources (% electricity)` = `Coal (% electricity)`+`Gas (% electricity)`+`Hydro (% electricity)`+`Solar (% electricity)`+`Wind (% electricity)`+`Oil (% electricity)`+`Nuclear (% electricity)`+`Other renewables excluding bioenergy (% electricity)`+`Bioenergy (% electricity)`;


ALTER TABLE greenjoinotnull
MODIFY COLUMN `Resources (% electricity)` INT;
-- most rows adds up to 100% after adding all the column with % electricity, the ones that does not adds up to 
-- 101% or 99%, pretty close
-- in fact they do not all add up to exactly 100% according to the original data, and not because of something done with the original data

-- Checking the entitysharelec column that starts with the letter 'A'
SELECT *
FROM greenjoinotnull
WHERE entitysharelec LIKE 'A%';

-- Checking the entitysharelec column that ends with the letter 'A'
SELECT *
FROM greenjoinotnull
WHERE entitysharelec LIKE '%A';

-- Checking the entitysharelec column that have the letter 'A' in the middle somewhere
SELECT *
FROM greenjoinotnull
WHERE entitysharelec LIKE '%A%';


-- Checking the entitysharelec column that have the letter 'A' in as the second character
SELECT *
FROM greenjoinotnull
WHERE entitysharelec LIKE '_A%';

-- Checking the entitysharelec column that have the letter 'A' in as the penultimate character
SELECT *
FROM greenjoinotnull
WHERE entitysharelec LIKE '%A_';

-- Checking the entitysharelec column that have the letter 'A' in as the antepenultimate character
SELECT *
FROM greenjoinotnull
WHERE entitysharelec LIKE '%A__';


-- Display information about the columns 
DESCRIBE greenjoinotnull;
SHOW COLUMNS FROM greenjoinotnull;

-- Some columns have 0 value
SELECT *
FROM greenjoinotnull
WHERE `Coal (% electricity)` = 0;

-- But do not have null values, it does not have empty rows
SELECT *
FROM greenjoinotnull
WHERE `Coal (% electricity)` IS NULL;

SELECT *
FROM greenjoinotnull;

-- Looking at some simple summary statistics
SELECT
  AVG(`Coal (% electricity)`) AS mean_coal,
  MAX(`Coal (% electricity)`) AS max_coal,
  MIN(`Coal (% electricity)`) AS min_coal,
  SUM(`Coal (% electricity)`) AS sum_coal,
  COUNT(`Coal (% electricity)`) AS count_coal,
  AVG(`Gas (% electricity)`) AS mean_gas,
  MAX(`Gas (% electricity)`) AS max_gas,
  MIN(`Gas (% electricity)`) AS min_gas,
  SUM(`Gas (% electricity)`) AS sum_gas,
  COUNT(`Gas (% electricity)`) AS count_gas
FROM greenjoinotnull;

-- transposing it to look nicer vertically 
SELECT 'mean_coal' AS statistic, AVG(`Coal (% electricity)`) AS value
FROM greenjoinotnull
UNION
SELECT 'max_coal', MAX(`Coal (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'min_coal', MIN(`Coal (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'sum_coal', SUM(`Coal (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'count_coal', COUNT(`Coal (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'mean_gas', AVG(`Gas (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_gas', MAX(`Gas (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'min_gas', MIN(`Gas (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'sum_gas', SUM(`Gas (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'count_gas', COUNT(`Gas (% electricity)`)
FROM greenjoinotnull;

-- Most of the cases the min value is 0 and the sum does not make sense because it is %, the count is always 51
-- Only mean and max of all resources will look nicer as below 

SELECT 'mean_coal' AS statistic, AVG(`Coal (% electricity)`) AS value
FROM greenjoinotnull
UNION
SELECT 'max_coal', MAX(`Coal (% electricity)`)
FROM greenjoinotnull
UNION

SELECT 'mean_gas', AVG(`Gas (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_gas', MAX(`Gas (% electricity)`)
FROM greenjoinotnull
UNION

SELECT 'mean_hydro', AVG(`Hydro (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_hydro', MAX(`Hydro (% electricity)`)
FROM greenjoinotnull

UNION
SELECT 'mean_solar', AVG(`Solar (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_solar', MAX(`Solar (% electricity)`)
FROM greenjoinotnull

UNION
SELECT 'mean_wind', AVG(`Wind (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_wind', MAX(`Wind (% electricity)`)
FROM greenjoinotnull

UNION
SELECT 'mean_oil', AVG(`Oil (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_oil', MAX(`Oil (% electricity)`)
FROM greenjoinotnull

UNION
SELECT 'mean_nuclear', AVG(`Nuclear (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_nuclear', MAX(`Nuclear (% electricity)`)
FROM greenjoinotnull


UNION
SELECT 'mean_othernotbioenergy', AVG(`Other renewables excluding bioenergy (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_othernotbioenergy', MAX(`Other renewables excluding bioenergy (% electricity)`)
FROM greenjoinotnull


UNION
SELECT 'mean_bioenergy', AVG(`Bioenergy (% electricity)`)
FROM greenjoinotnull
UNION
SELECT 'max_bioenergy', MAX(`Bioenergy (% electricity)`)
FROM greenjoinotnull;

/* The highest maximums for renewables resources as % electricity is 
Hydro 88.27% 
Wind 55% 
Nuclear 63%

The highest means are
Hydro 20.81%
Wind 10.04%
Nuclear 13.04%
*/

-- Ordering by top 10 highest percent of each source by % electricity
SELECT *
FROM greenjoinotnull
ORDER BY `Coal (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Gas (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Hydro (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Solar (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Wind (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Oil (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Nuclear (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Other renewables excluding bioenergy (% electricity)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull
ORDER BY `Bioenergy (% electricity)` DESC
LIMIT 10;

-- And again Renewables (% equivalent primary energy) 
SELECT *
FROM greenjoinotnull
ORDER BY `Renewables (% equivalent primary energy)` DESC
LIMIT 10;

SELECT *
FROM greenjoinotnull;

-- Showing the green energy not 0, select max and group by
-- it shows the top ten countries with diverse green energy sources 
-- Germany, France, Netherlands, Japan, United States, Hungary, Mexico, Taiwan, South Korea, South Africa
SELECT entitysharelec, `Hydro (% electricity)`, `Solar (% electricity)`, `Wind (% electricity)`, `Nuclear (% electricity)`,`Other renewables excluding bioenergy (% electricity)`,`Bioenergy (% electricity)`, `Renewables (% equivalent primary energy)`
FROM greenjoinotnull
WHERE `Hydro (% electricity)`>0 AND `Solar (% electricity)`>0 AND `Wind (% electricity)`>0 AND `Nuclear (% electricity)`>0 AND`Other renewables excluding bioenergy (% electricity)`>0 AND`Bioenergy (% electricity)`>0
GROUP BY  `Renewables (% equivalent primary energy)`
HAVING entitysharelec <> 'World'
ORDER BY `Renewables (% equivalent primary energy)` DESC;

-- creating a table to save the results from the last query

CREATE TABLE mostdiversegreenenergycountries AS
SELECT entitysharelec, `Hydro (% electricity)`, `Solar (% electricity)`, `Wind (% electricity)`, `Nuclear (% electricity)`,`Other renewables excluding bioenergy (% electricity)`,`Bioenergy (% electricity)`, `Renewables (% equivalent primary energy)`
FROM greenjoinotnull
WHERE `Hydro (% electricity)`>0 AND `Solar (% electricity)`>0 AND `Wind (% electricity)`>0 AND `Nuclear (% electricity)`>0 AND`Other renewables excluding bioenergy (% electricity)`>0 AND`Bioenergy (% electricity)`>0
GROUP BY  `Renewables (% equivalent primary energy)`
HAVING entitysharelec <> 'World'
ORDER BY `Renewables (% equivalent primary energy)` DESC;


SELECT *
FROM greenjoinotnull;

-- This gives the same results for the max renewables (% equivalent primary energy) because it is in descending order
SELECT entitysharelec, `Hydro (% electricity)`, `Solar (% electricity)`, `Wind (% electricity)`, `Nuclear (% electricity)`,`Other renewables excluding bioenergy (% electricity)`,`Bioenergy (% electricity)`, MAX(`Renewables (% equivalent primary energy)`) AS maxrenewprimaryenergy
FROM greenjoinotnull
WHERE `Hydro (% electricity)`>0 AND `Solar (% electricity)`>0 AND `Wind (% electricity)`>0 AND `Nuclear (% electricity)`>0 AND`Other renewables excluding bioenergy (% electricity)`>0 AND`Bioenergy (% electricity)`>0
GROUP BY  `Renewables (% equivalent primary energy)`
HAVING entitysharelec <> 'World'
ORDER BY maxrenewprimaryenergy DESC;

-- Creating View to store data for later visualizations 

CREATE VIEW mostdiversegreenenergycountriesview AS
SELECT entitysharelec, `Hydro (% electricity)`, `Solar (% electricity)`, `Wind (% electricity)`, `Nuclear (% electricity)`,`Other renewables excluding bioenergy (% electricity)`,`Bioenergy (% electricity)`, `Renewables (% equivalent primary energy)`
FROM greenjoinotnull
WHERE `Hydro (% electricity)`>0 AND `Solar (% electricity)`>0 AND `Wind (% electricity)`>0 AND `Nuclear (% electricity)`>0 AND`Other renewables excluding bioenergy (% electricity)`>0 AND`Bioenergy (% electricity)`>0
GROUP BY  `Renewables (% equivalent primary energy)`
HAVING entitysharelec <> 'World'
ORDER BY `Renewables (% equivalent primary energy)` DESC;

SELECT *
FROM greenjoinotnull;


-- Showing the worst top ten countries when it comes to green energy sources (highest in Coal (% electricity))
-- Poland, North Macedonia, Australia, Philippines, Taiwan, Bulgaria, Turkey, South Korea, Germany, Slovenia
SELECT entitysharelec, `Coal (% electricity)`, `Gas (% electricity)`, `Oil (% electricity)`, `Renewables (% equivalent primary energy)`
FROM greenjoinotnull
WHERE `Coal (% electricity)`>0 AND `Gas (% electricity)`>0 AND `Oil (% electricity)`>0
GROUP BY  `Renewables (% equivalent primary energy)`
HAVING entitysharelec <> 'World'
ORDER BY `Coal (% electricity)` DESC
LIMIT 10;


CREATE TABLE worstgreenenergycountries AS
SELECT entitysharelec, `Coal (% electricity)`, `Gas (% electricity)`, `Oil (% electricity)`, `Renewables (% equivalent primary energy)`
FROM greenjoinotnull
WHERE `Coal (% electricity)`>0 AND `Gas (% electricity)`>0 AND `Oil (% electricity)`>0
GROUP BY  `Renewables (% equivalent primary energy)`
HAVING entitysharelec <> 'World'
ORDER BY `Coal (% electricity)` DESC
LIMIT 10;


SELECT * 
FROM greenjoinotnull;




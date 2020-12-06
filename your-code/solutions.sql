use publications;
/* CHALLENGE 1: Most profiting authors
In order to solve this problem, it is important for you to keep the following points in mind:
In table sales, a title can appear several times. The royalties need to be calculated for each sale.
Despite a title can have multiple sales records, the advance must be calculated only once for each title.
In your eventual solution, you need to sum up the following profits for each individual author:
All advances, which are calculated exactly once for each title.
All royalties in each sale.
Therefore, you will not be able to achieve the goal with a single SELECT query, you will need to use subqueries. Instead, you will need to follow several steps in order to achieve the solution. There is an overview of the steps below:
Calculate the royalty of each sale for each author and the advance for each author and publication.
Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.
Using the output from Step 2 as a subquery, calculate the total profits of each author by aggregating the advances and total royalties of each title.
Below we'll guide you through each step. In your solutions.sql, please include the SELECT queries of each step so that your TA can review your problem-solving process.
*/
/* Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
Write a SELECT query to obtain the following output:
Title ID
Author ID
Advance of each title and author
The formula is:
advance = titles.advance * titleauthor.royaltyper / 100
Royalty of each sale
The formula is:
sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100
Note that titles.royalty and titleauthor.royaltyper are divided by 100 respectively because they are percentage numbers instead of floats.
In the output of this step, each title may appear more than once for each author. This is because a title can have more than one sale.
*/
SELECT a.au_id, a.title_id, (b.advance * a.royaltyper / 100) as advance, 
SUM((b.price * c.qty * b.royalty / 100 * a.royaltyper / 100)) as sales_royalty
FROM titleauthor a 
INNER JOIN titles b ON a.title_id = b.title_id
INNER JOIN sales c ON b.title_id = c.title_id
GROUP BY a.au_id, a.title_id;

/* Step 2: Aggregate the total royalties for each title and author
Using the output from Step 1, write a query, containing a subquery, to obtain the following output:
Title ID
Author ID
Aggregated royalties of each title for each author
Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author.
*/
SELECT au_title_royalty.au_id, au_title_royalty.title_id, SUM(au_title_royalty.advance) as agg_advance, SUM(au_title_royalty.sales_royalty) as agg_royalty 
FROM 
(SELECT a.au_id, a.title_id, (b.advance * a.royaltyper / 100) as advance, 
SUM((b.price * c.qty * b.royalty / 100 * a.royaltyper / 100)) as sales_royalty
FROM titleauthor a 
INNER JOIN titles b ON a.title_id = b.title_id
INNER JOIN sales c ON b.title_id = c.title_id
GROUP BY a.au_id, a.title_id) as au_title_royalty
GROUP BY au_title_royalty.au_id, au_title_royalty.title_id;

/* Step 3: Calculate the total profits of each author
Now that each title has exactly one row for each author where the advance and royalties are available, we are ready to obtain the eventual output. 
Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:
Author ID
Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3.
*/

SELECT final.au_id, max((final.agg_advance + final.agg_royalty)) as profit 
FROM(SELECT au_title_royalty.au_id, au_title_royalty.title_id, SUM(au_title_royalty.advance) as agg_advance, SUM(au_title_royalty.sales_royalty) as agg_royalty 
FROM 
(SELECT a.au_id, a.title_id, (b.advance * a.royaltyper / 100) as advance, 
SUM((b.price * c.qty * b.royalty / 100 * a.royaltyper / 100)) as sales_royalty
FROM titleauthor a 
INNER JOIN titles b ON a.title_id = b.title_id
INNER JOIN sales c ON b.title_id = c.title_id
GROUP BY a.au_id, a.title_id) as au_title_royalty
GROUP BY au_title_royalty.au_id, au_title_royalty.title_id) as final
GROUP BY final.au_id
ORDER BY profit DESC
LIMIT 3;
/* Challenge 2 - Alternative Solution
Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
Include your alternative solution in solutions.sql.*/
-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
DROP TABLE IF EXISTS royalty_auth_pub;
CREATE TEMPORARY TABLE royalty_auth_pub
SELECT a.au_id, a.title_id, (b.advance * a.royaltyper / 100) as advance, 
(b.price * c.qty * b.royalty / 100 * a.royaltyper / 100) as sales_royalty
FROM titleauthor a 
INNER JOIN titles b ON a.title_id = b.title_id
INNER JOIN sales c ON b.title_id = c.title_id;
SELECT * FROM royalty_auth_pub;
-- Step 2: Aggregate the total royalties for each title and author
DROP TABLE IF EXISTS title_auth_agg;
CREATE TEMPORARY TABLE title_auth_agg
SELECT royalty_auth_pub.au_id, royalty_auth_pub.title_id, 
SUM(royalty_auth_pub.advance) as agg_advance, 
SUM(royalty_auth_pub.sales_royalty) as agg_sales_royalty
FROM royalty_auth_pub
GROUP BY royalty_auth_pub.au_id, royalty_auth_pub.title_id;
SELECT * FROM title_auth_agg;
-- Step 3: Calculate the total profits of each author
DROP TABLE IF EXISTS profitable_au;
CREATE TEMPORARY TABLE profitable_au
SELECT title_auth_agg.au_id, sum((title_auth_agg.agg_advance + title_auth_agg.agg_sales_royalty)) as profit 
FROM title_auth_agg
GROUP BY title_auth_agg.au_id
ORDER BY title_auth_agg.au_id DESC
LIMIT 3;
SELECT * FROM profitable_au;
/* CHALLENGE 3: Most profiting authors */
DROP TABLE IF EXISTS most_profiting_authors;
CREATE TABLE most_profiting_authors
(author_id VARCHAR(255),
profits FLOAT);
INSERT INTO most_profiting_authors (author_id, profits) VALUES
("998-72-3567", 10638.456000000000),
("899-46-2035", 12128.132000000000),
("846-92-7186", 4050.000000000000);
SELECT * FROM most_profiting_authors;
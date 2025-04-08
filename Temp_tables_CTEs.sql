USE Sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer.
--  The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW IF EXISTS rental_info;

CREATE VIEW rental_info AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS name,
    c.email,
	COUNT(r.rental_id) AS rental_count  
FROM 
    customer c
JOIN 
    rental r ON c.customer_id = r.customer_id 
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;  
SELECT * FROM rental_info;


-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 
-- to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_paid AS
SELECT 
    r.customer_id,
    r.name,
    r.email,
    SUM(p.amount) AS total_paid
FROM 
    rental_info r
JOIN 
    payment p ON r.customer_id = p.customer_id
GROUP BY 
    r.customer_id, r.name, r.email;

select * from total_paid;


-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.


WITH customer_summary AS (
    SELECT 
        r.name,        
        r.email,            
        r.rental_count,     
        tp.total_paid       
    FROM rental_info r
    JOIN total_paid tp ON r.customer_id = tp.customer_id)

-- Next, using the CTE, create the query to generate the final customer summary report, which should include:
-- customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.

SELECT 
    cs.name,                            
    cs.email,                                
    cs.rental_count,                         
    cs.total_paid,                           
    ROUND(cs.total_paid / cs.rental_count, 2) AS average_payment_per_rental  
FROM customer_summary cs;


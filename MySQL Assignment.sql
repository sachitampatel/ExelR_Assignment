use classicmodels;

#MYSQL Assignment


#Q1SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

#a)
SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep' AND reportsTo = 1102;

#b)
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';

#Q2CASE STATEMENTS for Segmentation

SELECT customerNumber, customerName, 
       CASE 
           WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
       END AS CustomerSegment
FROM customers;


#Q3Group By with Aggregation functions and Having clause, Date and Time functions

#a)
SELECT productCode, SUM(quantityOrdered) AS total_quantity
FROM orderdetails
GROUP BY productCode
ORDER BY total_quantity DESC
LIMIT 10;

#b)
SELECT MONTHNAME(paymentDate) AS month, COUNT(*) AS total_payments
FROM payments
GROUP BY month
HAVING total_payments > 20
ORDER BY total_payments DESC;


#Q4CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default

#a)
CREATE DATABASE Customers_Orders;
USE Customers_Orders;

CREATE TABLE Customers1 (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

select * from customers1;

#b)
CREATE TABLE Orders2 (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2) CHECK (total_amount > 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);


#Q5Jions

SELECT c.country, COUNT(o.orderNumber) AS order_count
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY order_count DESC
LIMIT 5;


#Q6Self Join

CREATE TABLE Project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    ManagerID INT);
   INSERT INTO Project (EmployeeID, FullName, Gender, ManagerID) VALUES
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3);

SELECT 
    m.FullName AS Manager_Name, 
    e.FullName AS Emp_Name
FROM 
    Project e
JOIN 
    Project m 
ON 
    e.ManagerID = m.EmployeeID;


#Q7DDL Commands: Create, Alter, Rename

CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(50),
    Country VARCHAR(50)
);
ALTER TABLE facility ADD PRIMARY KEY (Facility_ID);
ALTER TABLE facility MODIFY Facility_ID INT AUTO_INCREMENT;
ALTER TABLE facility ADD COLUMN city VARCHAR(50) NOT NULL AFTER Name;


#Q8Views in SQL

CREATE VIEW product_category_sales AS
SELECT p.productLine, 
       SUM(od.quantityOrdered * od.priceEach) AS total_sales,
       COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM productlines pl
JOIN products p ON pl.productLine = p.productLine
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p.productLine;


#Q9Stored Procedures in SQL with parameters

DELIMITER //
CREATE PROCEDURE Get_country_payments(IN year INT, IN country VARCHAR(50))
BEGIN
    SELECT YEAR(p.paymentDate) AS payment_year, c.country, 
           ROUND(SUM(p.amount) / 1000, 0) AS total_amount_K
    FROM payments p
    JOIN customers c ON p.customerNumber = c.customerNumber
    WHERE YEAR(p.paymentDate) = year AND c.country = country
    GROUP BY payment_year, c.country;
END //
DELIMITER ;


#Q10Window functions - Rank, dense_rank, lead and lag

#a)
SELECT c.customerNumber, c.customerName, COUNT(o.orderNumber) AS order_count,
       RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName;

#b)
SELECT YEAR(orderDate) AS order_year, 
       MONTHNAME(orderDate) AS order_month, 
       COUNT(orderNumber) AS order_count,
       LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)) AS prev_year_count,
       ROUND(((COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate))) * 100) / 
             LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)), 0) AS YoY_Percentage
FROM orders
GROUP BY order_year, order_month;


#Q11.Subqueries and their applications

SELECT productLine, COUNT(*) AS product_count
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine;


#Q12ERROR HANDLING in SQL

DELIMITER //
CREATE PROCEDURE Insert_Emp_EH(IN emp_id INT, IN emp_name VARCHAR(50), IN email VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred' AS Message;
    END;
    
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress) VALUES (emp_id, emp_name, email);
END //
DELIMITER ;


#Q13TRIGGERS

CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);
INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);
select * from Emp_BIT;

DELIMITER //

CREATE TRIGGER before_insert_Emp_BIT
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    -- Ensure Working_hours is positive
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END;

//

DELIMITER ;
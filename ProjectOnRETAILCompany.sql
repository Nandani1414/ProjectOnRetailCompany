/*
================================================
-- project overview: Fictional Retail Company
================================================
--create database 
*/

create database OnlineRetailDB;
Go
--use the database 
use OnlineRetailDB;
-- create customers table
CREATE  TABLE 
Customers ( CustomerID INT PRIMARY KEY IDENTITY(1,1),
FirstName NVARCHAR(50),
LastName NVARCHAR(50),
Email NVARCHAR(100),
Phone NVARCHAR(50),
Address NVARCHAR(255),
City NVARCHAR(50),
State NVARCHAR(50),
ZipCode NVARCHAR(50),
Country NVARCHAR(50),
CreatedAt DATETIME DEFAULT GETDATE() 
);

-- CREATE THE PRODUCT TABLE
CREATE TABLE Products (
ProductID INT PRIMARY KEY IDENTITY(1,1),
ProductName NVARCHAR(100),

CategoryID INT,
Price DECIMAL(10,2),
Stock INT,
CreatedAt DATETIME DEFAULT GETDATE()
);
-- CREATE THE CATEGORIES TABLE
CREATE TABLE Categories (

CategoryID INT PRIMARY KEY IDENTITY(1,1),
CategoryName NVARCHAR(100),
Description NVARCHAR(255),

);

--CREATE ORDERS  TABLES
CREATE TABLE Orders (
OrderId INT PRIMARY KEY IDENTITY(1,1),
CustomerId int,

OrderDate DATETIME DEFAULT GETDATE(),
TotalAmount Decimal(10,2),
-- we use foreign key here for data sharing 
foreign key (CustomerID) REFERENCES Customers(CustomerID)
);

--ALTER/RENAME THE COLUMN NAME

EXEC sp_rename 'OnlineRetailDB.dbo.Orders.CustomerId', 'CustomerID', 'ColUMN';
--create the orderItems table 
CREATE TABLE OrderItems (
OrderItemID INT PRIMARY KEY IDENTITY (1,1),
OrderID INT,
ProductID INT ,
Quantity INT ,
Price decimal(10,2),
Foreign key (ProductID) REFERENCES Products(ProductID),
Foreign key (OrderId) REFERENCES Orders(OrderID)
);



-- INSERT SAMPLE DATA INTO CATEGORIES TABLE
INSERT INTO Categories (CategoryName , Description)
VALUES 
('Electronics','Devices and Gadgets'),
('Clothing','Apparel  and Accessories'),
('Books','Printed and Electronic Books');


-- insert sample data into products table
INSERT INTO Products (ProductName, CategoryID, Price,Stock)
VALUES ('Smartphone' , 1, 699.99, 50),
('Laptop' , 1, 999.99, 30),
('T-shirt' , 2, 19.99, 100),
('Jeans' , 2, 49.99, 60),
('Fiction Novel' , 3, 14.99, 200),
('Science Journal' , 3, 29.99, 150);


-- Insert sample data into customers table
INSERT INTO Customers(FirstName , LastName, Email,Phone,Address,City,
State,ZipCode,Country)

VALUES
('Sameer' , 'Khanna', 'sameer.khanna@example.com',
 '123-456-7890','123 Elm St.' , 'Springfield', 'IL','62701' , 'USA'),
 ('Jane' , 'Smith', 'jane.smith@example.com',
 '234-567-8901','456 Oak St.' , 'Madison', 'WI','53703' , 'USA'),
 ('Harshad' , 'patel', 'harshad.patel@example.com',
 '345-678-9012','789 Dalal St.' , 'Mumbai', 'Maharashtra','41520' , 'India');

 -- insert sample data into Orders Table 

 INSERT INTO Orders(CustomerID , OrderDate , TotalAmount)
 VALUES (1, GETDATE(), 719.98),
        (2, GETDATE(),49.99),
        (3, GETDATE(), 44.98);
		-- INSERT SAMPLE DATA INTO OrderItems table 



		INSERT INTO  OrderItems( OrderID, ProductID,Quantity, Price)

		VALUES 
		(1,1,1,699.99),
		(1,3,1,19.99),
		(2,4,1,49.99),
		(3,5,1,14.99),
		(3,6,1,29.99);
		
    
 -- QUERY 1: Retrieve all orders for a specific customer
 select o.OrderID, o.OrderDate, o.TotalAmount,oi.ProductID,p.ProductName,Quantity,
 oi.Price from Orders o join 
 OrderItems oi ON o.OrderId = oi.OrderID
 join Products p ON oi.ProductID = p.ProductID 
 where o.CustomerID = 1;


    -- QUERY 2:Find the total sales for each product 

	SELECT  p.ProductID, p.ProductName ,SUM( oi.Quantity * oi.Price) as
	TotalSales
	from OrderItems oi 
	JOIN Products p 
	on oi.productid = p.ProductID 
	group by p.productid , p.productname 
	Order BY TotalSales DESC;




	-- QUERY 3:Calculate the average order value 
	select avg(TotalAmount)  as averageOrderValue from Orders;

	-- QUERY 4:List the top 5 customers by total spending 
	SELECT 
	
	top 5 
	c.CustomerID,c.FirstName, c.LastName , sum( o.TotalAmount) as TotalSpent
	from Customers c 
	join Orders o 
	on c.customerID = o.CustomerID
	group by c.customerid , c.firstname, c.LastName
	order by TotalSpent desc 
	
    -- QUERY 5:Retreive the most popular product category
      select 

	CategoryID, CategoryName, TotalQuantitySold,rn
	
	
	from (
	
	SELECT C.CategoryID, C.categoryName ,  Sum( oi.Quantity)

	as totalQuantitySold,
	ROW_NUMBER() OVER (ORDER BY SUM(OI.QUANTITY) DESC) AS rn
	
	from orderitems oi join products p  on oi.productid = p.productid 
	join categories c on 
	p.categoryid = c.categoryid 
	group by c.categoryid , c.categoryName) sub
	where rn = 1;

	-- to insert a product with zero stock
	 INSERT INTO Products (ProductName, CategoryID, Price,Stock)
       VALUES ('Keyboard' , 1, 39.99, 0);

	-- QUERY 6: List all prdoucts that are out of stock i.e. stock =  0
	 
	 select * from products 
	 where stock = 0;

	 select productid , productname , stock  from products where stock = 0
	 -- with category name 
	 select p.productid, p.productname, c.categoryname, p.stock
	 from products p join categories c 
	 on p.categoryid =  c.categoryid
	 where stock = 0


	-- QUERY 7:find customers who placed orders in the last 30 days
	select  c.customerid, c.firstname, c.lastname, c.email , c.phone 
	from customers c join orders o 
	on c.customerid = o.customerid
	 where o.orderdate >=  DATEADD(day,-30,GETDATE());

	-- QUERY 8:calculate the total number of orders placed each month 


	  select  year(orderdate) as orderyear,
	month(orderdate) as ordermonth,
	COUNT(OrderID) as totalorders
	 from orders
	group by year(orderdate) ,month(orderdate)

	order by orderyear , ordermonth;

	-- QUERY 9:Retrieve the details of the most recent order
	select    top 2 o.orderid, o.orderdate, o.totalamount, c.firstname, c.lastname
	from orders o join customers c 
	on o.customerid = c.customerid 
	order by o .orderdate desc;

	-- QUERY 10: find the average price of products in each category
	--same as query 6 little bit different 
	 --select p.productid, p.productname, c.categoryname, p.stock
	 --from products p join categories c 
	 --on p.categoryid =  c.categoryid
	 --where stock = 0

	 select c.categoryID , c.categoryName , AVG(p.price) as averagePrice 
	 from categories c join products p
	  
	 on  c.categoryID = p.productID
	 group by c.categoryID , c.categoryname

	 -- inserting new customer to perform query number 11

	 INSERT INTO Customers(FirstName , LastName, Email,Phone,Address,City,
State,ZipCode,Country)

VALUES
     ('Nikhil' , 'sharma', 'nikhilsharma@example.com',
 '999888777','123 Elm St.' , 'Springfield', 'IL','62701' , 'USA');
 select * from customers
 select * from orders
	-- QUERY 11:list customers who have never placed an order
	select c.customerid , c.firstname, c.lastname , c.email , c.phone ,
	o.totalamount
	from customers c full  join orders o 
	on c.customerid = o.customerid 
	--where o.orderid IS NULL;

	-- another way 
	select c.customerid , c.firstname, c.lastname , c.email , c.phone ,
	o.totalamount
	from customers c left join orders o 
	on c.customerid = o.customerid 
	where o.orderid IS NULL;

	-- QUERY 12:Retrieve the total quantity sold for each product 
	select p.productid, p.productname , sum(oi.quantity) as totalQuantitySold 
	from orderitems oi join products  p 
	on oi.productid = p.productid 
	group by p.productid , p.productname 
	order by p.productname

	
	-- QUERY 13:calculate the total revenue generated from each category
	select c.categoryid , c.categoryname , sum(oi.quantity * oi.price) as totalrevenue
	from orderitems oi join products p 
	on oi.productid = p.productid 
	join categories c 
	on c.categoryid = p.categoryid 
	group by c.categoryid , c.categoryname 
	order by totalrevenue desc;

	-- QUERY 14:find the highest-priced product in each category
	select c.categoryid , c.categoryname , p1.productid , p1.productname ,
	 p1.price from categories c join products p1 
	 on c.categoryid = p1.categoryid 
	 where p1.price = (select max(price) from products p2
	  where p2.categoryid  = p1.categoryid ) 
	  order by p1.price desc
	

	-- QUERY-15:Retrieve orders with a total amount greater than a specific value (e.g, $500)

	select o.orderid ,c.customerid , c.firstname , c.lastname , o.totalamount 
	from orders o join customers c 
	on o.customerid = c.customerid 
	where o.totalamount > 500
	order by o.totalamount desc;

    -- QUERY-16:list products along with the number of orders they appear in 
	select p.productid , p.productname, count(oi.orderid) as ordercount 
	from products p join orderitems oi 
	on p.productid = oi.productid 
	group by p.productid , p.productname
	order by ordercount desc;

	-- QUERY-17:find the top 3 most frequently ordered products



	select top 3 p.productid , p.productname, count(oi.orderid) as ordercount 
	from    orderitems oi  join products p
	on  oi.productid =  p.productid 
	group by p.productid , p.productname
	order by ordercount desc;

	-- QUERY-18:calculate the total number of customers from each country

	select country , count(customerid) as TotalCustomers 
	from customers group by country order by  TotalCustomers desc

	-- QUERY-19:retrieve the list of customers along with their total spending
	select c.customerid  , c.firstname , c.lastname , sum (o.totalAmount) as Totalspending
	from customers c join orders o 
	on 
	c.customerid = o.customerid group by c.customerid , c.firstname , c.lastname;

-- QUERY-20:list orders with more than a specified number of items(e.g.. 5 items)

select o.orderid , c.customerid , c.firstname, c.lastname
,count(oi.orderItemID) as NumberOfItems 
from Orders o join OrderItems oi 
on o.orderid = oi.orderid 
join customers c 
on o.customerid = c.customerid 
group by o.orderid , c.customerid , c.firstname , c.lastname 
having count(oi.OrderItemID) >= 1
order by NumberOfItems;


/* lets create additional queries that involve updating , deleting, and maintaining logs 
of these operations in the OnlineRetailDB database*/

 /* To automatically log changes in the database, you can use triggers in sql server
Triggers are special types of stored procedures that automatically execute in response 
to certain events on a table , such as INSERT , UPDATE, and DELETE operations for the tables in the 
OnlineRetailDb . 


here how you can create triggers to log INSERT , UPDATE AND DELETE OPERATIONS 
we will start by adding a table to keep logs of update and deletions 

step 1: create a log table 
step 2 : create Triggers for each table 
         

		 A. Triggers for Products table 
		 -- Trigger for INSERT on Products table 
		 -- Trigger for UPDATE on Products table 
		 -- Trigger for DELETE  on Products table 


		 B.Triggers for Customers table
		 
		 -- Trigger for INSERT on Customer table
		 -- Trigger for UPDATE on Customer table 
		 -- Trigger for DELETE  on Customer table

		 */
		 -- create a Log Table 
		 CREATE TABLE ChangeLog (
		 LogID INT PRIMARY KEY IDENTITY(1,1),
		 TableName NVARCHAR(50),
		 Operation NVARCHAR(10),
		 RecordID INT , 
		 ChangeDate DATETIME DEFAULT GETDATE(),
		 ChangedBy NVARCHAR(100)
		 
		 
		 );
		 GO


		-- A. Triggers for Products table 
		 -- Trigger for INSERT on Products table 

GO
CREATE  TRIGGER trg_Insert_Product 
      ON Products 
      AFTER INSERT 
       AS
BEGIN
    -- insert a record into ChangeLog Table 
    INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
    SELECT 'Products', 'INSERT', inserted.ProductID, SYSTEM_USER 
    FROM inserted;

	
END;
GO
-- try to insert one record into Products Table 

INSERT INTO Products(ProductName , CategoryID, Price, Stock)

values(' Wireless Mouse',1, 4.99, 20);

INSERT INTO Products(ProductName , CategoryID, Price, Stock)

values(' SpiderMan Multiverse Comic',3, 2.50, 150);
select * from Products

select * from ChangeLog


 -- Trigger for UPDATE on Products table 
 CREATE  TRIGGER trg_Update_Product 
      ON Products 
      AFTER UPDATE 
       AS
BEGIN
    -- insert a record into ChangeLog Table 
    INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
    SELECT 'Products', 'UPDATE', inserted.ProductID, SYSTEM_USER 
    FROM inserted;
	-- display a message indicating that the trigger has fired
	print 'UPDATE operation logged for Product Table';


	
END;
GO

-- try to update any record from products table 

UPDATE Products SET Price =  Price - 300  where ProductID = 2;



		 -- Trigger for DELETE  a record  from Products table 
		DROP TRIGGER trg_delete_Product;
GO

CREATE TRIGGER trg_delete_Product 
ON Products 
AFTER DELETE
AS
BEGIN
    INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
    SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER 
    FROM deleted;

    PRINT 'DELETE operation logged for Product Table';
END;
GO

GO

--- altering the trigger 
ALTER TRIGGER trg_delete_Product 
ON Products 
AFTER DELETE
AS
BEGIN
    INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
    SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER  
    FROM deleted;

    PRINT 'DELETE operation logged for Product Table';
END;
GO




DELETE FROM PRODUCTS WHERE ProductID = '10';

select * from products

select * from ChangeLog

 --B.Triggers for Customers table
		 
		 -- Trigger for INSERT on Customer table


		 GO
CREATE  TRIGGER trg_Insert_Customers
      ON Customers
      AFTER INSERT 
       AS
BEGIN
    -- insert a record into ChangeLog Table 
    INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
    SELECT 'Customers', 'INSERT', inserted.CustomerID, SYSTEM_USER 
    FROM inserted;

	--display a message indicating that the trigger has fired 
	print 'INSERT operation logged for Customers table';

	
END;
GO

-- try to insert a new record to see the effect of trigger

INSERT INTO Customers(FirstName , LastName, Email,Phone,Address,City,
State,ZipCode,Country)

VALUES
('Shivani' , 'Jha', 'Shivani.jha@example.com',
 '123-456-7890','South Delhi' , 'Delhi', 'DELHI','5456665' , 'INDIA');

 select * from customers
 select * from ChangeLog


		 -- Trigger for UPDATE on Customer table


		 CREATE  TRIGGER trg_Update_Customers
      ON Customers
      AFTER UPDATE 
       AS
BEGIN
    -- update a record into ChangeLog Table 
    INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
    SELECT 'Customers', 'UPDATE', inserted.CustomerID, SYSTEM_USER 
    FROM inserted;

	--display a message indicating that the trigger has fired 
	print 'UPDATE operation logged for Customers table';

	
END;
GO

-- try to update an existing record in customers table
update customers set state = 'Florida' where state = 'IL';

		 
		 
 -- Trigger for DELETE  on Customer table

 CREATE TRIGGER trg_delete_Customers 
ON Customers
AFTER DELETE
AS
BEGIN
    INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
    SELECT 'Customers', 'DELETE', deleted.CustomerID, SYSTEM_USER 
    FROM deleted;

    PRINT 'DELETE operation logged for Customer Table';
END;
GO

-- try to delete an existing record to see the effect of triggers
delete from customers where customerid = 5;

select * from customers
 select * from ChangeLog

 /*  ======================
     Implementing Indexes
     =====================


	 Indexes are crucial for optimizing the performance of your sql server database,
	 especially for read-heavy operations like SELECT queries.


	 let's create indexes for the OnlineDB database to improve query performance.

	 A. Indexes on categories table 
	 1.Clustered Index on CategoryID:  usually created automatically with the primary key */


	 -- Clustered index on categories table(CategoryID)
	 USE OnlineRetailDB;
	 GO
	 CREATE CLUSTERED INDEX IDX_Categories_CategoryID ON Categories(CategoryID) 
	 GO
/*
	 B.Indexes on Products Table 
	 1.Clustured Index on CategoryID:this is usually created automatically when the 
	 primary key is defined 
	 2.Non- Clustered Index on CategoryID: to speed up queries filtering 
	 by CategoryID.
	 3.Non-clustered index on price: to speed up queries filtering on sorting by price.
	 */

	 --drop Foreign Key Constraint from OrderItems table - ProductID 
	 alter table orderitems drop CONSTRAINT FK__OrderItem__Produ__1BFD2C07

	 --Clustered index on product table(productid)

	 Create CLUSTERED INDEX IDX_Products_ProductID ON Products(ProductID)
	 GO

	-- 2.Non- Clustered Index on CategoryID: to speed up queries filtering  by CategoryID.
	create NONCLUSTERED INDEX IDX_Products_CategoryID 
	on Products(CategoryID);
	GO
	-- 3.Non-clustered index on price: to speed up queries filtering on sorting by price.
	 
	 create NONCLUSTERED INDEX IDX_Products_Price
	on Products(Price);
	GO

	-- Recreate foreign key Constrain on OrderItems (ProductID column)

	ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Products
	FOREIGN KEY  (ProductID) REFERENCES Products(ProductID);
	GO
	 /*
	 C.Indexes on orders TABLE 
	 1.Clustered index on ordeerID: Usually created with the primary key 

	*/
	
     --drop Foreign Key Constraint from OrderItems table - OrderID
	 alter table orderitems drop CONSTRAINT FK__OrderItem__Order__1CF15040

	-- Clustered index on orderID:
	create CLUSTERED INDEX IDX_Orders_OrderID 
	on Orders(OrderID);
	GO
	--Non-clustered index CustomerID: to speed up queries filtering by customerID.

	create NONCLUSTERED INDEX IDX_Orders_CustomerID 
	on Orders(CustomerID);
	GO
	-- 3.Non-Clustered index on OrderDate: to speed up queries filtering or sorting by OrderDate.
	 
	 create NONCLUSTERED INDEX IDX_Orders_OrderDate
	on Orders(OrderDate);
	GO

	--PK-Orders(unique, non-clustered)

CREATE UNIQUE NONCLUSTERED INDEX IDX_Orders_CustomerID_OrderDate
ON Orders (CustomerID, OrderDate);


-- Recreate foreign key Constrain on OrderItems (OrderID column)

	ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_OrderID
	FOREIGN KEY  (OrderID) REFERENCES Orders(OrderID);
	GO
 /*
 D Indexes on OrderItems Table
  

 
 
  */
  --1.Clustered Index on OrderItemID:Usually created with the primary key
  create CLUSTERED INDEX IDX_OrderItems_OrderItemID
	on OrderItems(OrderItemID);
	GO
	
	--2.Non-clustered index OrderID: to speed up queries filtering by OrderID.
	create NONCLUSTERED INDEX IDX_OrderItems_OrderID
	on OrderItems(OrderID);
	GO
	-- 3.Non-Clustered index on ProductID: to speed up queries filtering by ProductID .
	 
	 create NONCLUSTERED INDEX IDX_OrderItems_ProductID
	on OrderItems(ProductID);
	GO


	 
	--E. Indexes on Customers Table 
	--1.Clustered Index ON CustomerID:Usually Created with the primary key 
	create CLUSTERED INDEX IDX_Customers_CustomerID
	on Customers(CustomerID);
	GO
	
	-- drop foreign key Constrain from Orders table - customer id

	ALTER TABLE Orders drop CONSTRAINT FK__Orders__Customer__1920BF5C
	


	-- Recreate foreign key Constrain on OrderItems (OrderID column)

	ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_OrderID
	FOREIGN KEY  (OrderID) REFERENCES Orders(OrderID);
	GO

	
	
	--2.Non-Clustered Index ON email.To speed up queries filtering by Email

	create NONCLUSTERED INDEX IDX_Customers_Email
	on Customers(Email);;
	GO


    --3.Non-Clustered Index on Country: To Speed up queries filtering by country.
	create NONCLUSTERED INDEX IDX_Customers_Country
	ON Customers(Country);
	GO



	-- Recreate foreign key Constraint on Orders (OrderID column)

	ALTER TABLE Orders ADD CONSTRAINT FK_Orders_CustomerID
	FOREIGN KEY  (CustomerID) REFERENCES Customers(CustomerID);
	GO

	/*
	=====================
	 Implementing Views
	=====================

	Views are virtual tables that represent the result of a query.
	They can simplify complex queries and enhance security by restricting access to specific date.
	*/
	-- View for product Details:A view combining product details with category names.
	CREATE VIEW vw_ProductDetails as
	SELECT p.ProductID , p.ProductName , p.Price, p.Stock , c.CategoryName
	FROM Products p INNER JOIN Categories c 
	on p.CategoryID = c.CategoryID
	GO
	--Display product details with category names using view
	SELECT * FROM vw_ProductDetails;

--View for Customer Orders: A view to get a summary of orders placed by each customer.
CREATE VIEW vw_CustomerOrders
AS
SELECT c.CustomerID , c.FirstName , COUNT(o.OrderID) AS TotalOrders ,
SUM(oi.Quantity * p.Price) as TotalAmount
FROM Customers c 
INNER JOIN Orders o on c.CustomerID = o.CustomerID 
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID 
INNER JOIN Products p on oi.ProductID = p.ProductID 
GROUP BY c.CustomerID , c.FirstName, c.LastName;
GO 

select * from vw_CustomerOrders

--View for Recent Orders:A  view to display orders placed in the last 30  days.
	
	CREATE VIEW vw_RecentOrders 
	as 
	SELECT o.OrderID , o.OrderDate , c.CustomerID , c.FirstName , c.LastName ,
	SUM(oi.Quantity * oi.Price) as OrderAmount FROM Customers c 
	INNER JOIN Orders o ON c.CustomerID = o.CustomerID 
	INNER JOIN OrderItems oi on o.OrderID = oi.OrderID 
	GROUP BY o.OrderID , o.OrderDate , c.CustomerID , c.FirstName , c.LastName;
	GO 
	select * from vw_RecentOrders
	
	--Query 31: Retrieve  All Products with Category Names 
	--Using the vw_ProductDetails view to get a list of all products along with their 
	--category names 
	select * from vw_ProductDetails
	
	

	--Query 32 : Retreive products details within a specific Price Range
	--Using the vw_ProductDetails view to count the number of products in eaach category $100 and $500
	 
	 select * from vw_ProductDetails WHERE Price Between 10 and 500;
     
    	--Query 33: Count the number of products in each category 
	-- Using the vw_ProductsDetails view to count the number of products in each category .
	SELECT CategoryName , Count(ProductID) AS ProductCount
	from vw_ProductDetails GROUP BY CategoryName;

	--Query 34: Retreive Customers with more than 5 Orders
	-- Using the vw_CustomerOrders view to find customers who have placed more than 1 orders.
	
	 SELECT * FROM vw_CustomerOrders WHERE TotalOrders > 1;

	 --Query 35 : Retrieve the total Amount		Spent BY Each Customer
	 --Using the vw_CustomerOrders view to get the total amount spent  by each customer.
	 

	 SELECT CustomerID , FirstName , TotalAmount FROM vw_CustomerOrders
	 ORDER BY TotalAmount DESC;

	 --Query 36:Retreive the Total Amount Spent by Each Customer
	 -- Using the vw_RecentOrders view to find recent orders where teh total amount is greater than $1000.
	 SELECT * FROM vw_RecentOrders WHERE OrderAmount > 1000;
		
		 --Quer 37: Retreive the latest orders for each customer 
		 --Uisng the vw_RecentOrders view to find the latest order placed by each customer.
		 
		 SELECT ro.OrderID , ro.OrderDate , ro.CustomerID , ro.FirstName ,
		 ro.LastName , ro.OrderAmount 
		 FROM vw_RecentOrders ro 
		 INNER JOIN 
		 (SELECT CustomerID , Max(OrderDate) as LatestOrderDate FROM vw_RecentOrders GROUP BY CustomerID)
		 Latest ON ro.CustomerID = latest.CustomerID AND ro.OrderDate = latest.LatestOrderDate
		 ORDER BY ro.OrderDate DESC; 
		 GO
		    
--Query 38: Retrieve Products in a Specific Category 
--Using the vw_ProductDetails view to get all products in a Sepcific Category , such as 'Electronics'.

 SELECT * FROM vw_ProductDetails WHERE CategoryName = 'Books';


--Query 39:Retreive total sales for each category 
--uisng the vw_ProductDetails and vw_CustomerOrders views to calculate the total sales for each category

SELECT pd.CategoryName , SUM(oi.Quantity * p.Price) AS TotalSales 
FROM OrderItems oi 
INNER JOIN Products p ON oi.ProductID = p.ProductID 
INNER JOIN vw_ProductDetails pd on p.ProductID = pd.ProductID 
GROUP BY pd.CategoryName 
ORDER BY TotalSales DESC;


--Query 40:Retreive Customer Orders with Product details
--using the vw_CustomerOrders and  vw_ProductDetails views to get customer order along with the details of the 

SELECT co.CustomerID , co.FirstName  , o.OrderID , o.OrderDate,
pd.ProductName , oi.Quantity , pd.Price 
FROM Orders o 
INNER JOIN OrderItems OI ON o.OrderID = oi.OrderID 
INNER JOIN vw_ProductDetails pd ON oi.ProductID = pd.ProductID
INNER JOIN vw_CustomerOrders co ON o.CustomerID = co.CustomerID 
ORDER BY o.OrderDate DESC;


--Query 41:Retrieve the top 5 Customers by total spending
--using the vw_CustomerOrders view to find the top 5 customers bases on their total spendings
SELECT TOP 5 CustomerID , FirstName  , TotalAmount
from vw_CustomerOrders ORDER BY TotalAmount DESC;


--Query 42:Retreive products with low stack 
--Using the vw_ProductDetails view to find products with stock below a certain threshold, such as 10 units

Select * from vw_ProductDetails where Stock < 50;

--Query 43:Retreive orders placed in the last 7 days 
--Using the vw_RecentOrders view to find orders placed in the last 7 days
	
	Select * from vw_RecentOrders where OrderDate >= DATEADD(DAY, -10,GETDATE());
		 
--Query 44:Retrieve Sold in the last month 
--using the vw_RecentOrders view to find products sold in the last month.

	 SELECT p.ProductID , p.ProductName , SUM(oi.Quantity) AS TotalSold
	 from Orders o
	 INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID 
	 INNER JOIN Products p ON oi.ProductID = p.ProductID 
	 WHERE o.OrderDate >= DATEADD(MONTH , -1, GETDATE())
	 GROUP BY p.ProductID , p.ProductName 
	 ORDER BY TotalSold DESC;

	 




















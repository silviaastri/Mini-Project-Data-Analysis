Use Northwind

--Adding the Unit Cost column to Order Details table--
ALTER TABLE [Order Details]
ADD UnitCost real

--Update the Unit Cost column with random numbers--
UPDATE [Order Details]
SET
[UnitCost] = ROUND(UnitPrice*(0.75 + ROUND(0.1 * RAND(convert(varbinary, newid())),2)),2)

--Creating an empty table for main Orders--
CREATE TABLE OrdersMain (
		OrderID INT,
		CustomerID VARCHAR(10),
		ClientName NVARCHAR(40),
		ProductID INT,
		UnitPrice MONEY,
		UnitCost MONEY,
		Quantity SMALLINT,
		Discount REAL,
		DiscountValue MONEY,
		Revenue MONEY,
		CostOfGoods MONEY,
		DiscountedRevenue MONEY,
		Freight MONEY,
		FreightByProduct MONEY,
		OrderDate DATETIME,
		RequiredDate DATETIME,
		ShippedDate DATETIME,
		ShipName NVARCHAR(40),
		ShipCity NVARCHAR(20),
		ShipCountry NVARCHAR(20),
		shipper_company NVARCHAR(40),
		ClientContact NVARCHAR(30),
		ContactTitle NVARCHAR(30),
		ClientCity NVARCHAR(15),
		ClientCountry NVARCHAR(15),
		EmployeeName NVARCHAR(40),
		EmployeeTitle NVARCHAR(30),
		EmployeeCity NVARCHAR(30),
		EmployeeCountry NVARCHAR(30),
		Territory NCHAR(50),
		Region NCHAR(50)
);
--In Case to delete the above table--
DROP TABLE dbo.OrdersMain

WITH number_of_product_cte (OrderID, NumberOfProducts)
AS
(
SELECT o.OrderID,
	   COUNT(o.OrderID) AS NumberOfProducts
FROM Orders AS o
INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY o.OrderID
)

INSERT INTO OrdersMain
SELECT 
	o.OrderID,
    o.CustomerID,
    c.CompanyName AS ClientName,
    od.ProductID,
    od.UnitPrice,
	od.UnitCost,
    od.Quantity,
    od.Discount,
	od.Discount*(od.UnitPrice*od.Quantity) AS DiscountValue,
	od.UnitPrice*od.Quantity AS Revenue,
	od.UnitCost*Quantity AS CostOfGoods,
	od.UnitPrice*od.Quantity*(1-od.Discount) AS DiscountedRevenue,
    o.Freight,
    o.Freight/np.NumberOfProducts AS FreightByProduct,
	o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    o.ShipName,
	o.ShipCity,
	o.ShipCountry,
	s.CompanyName AS shipper_company,
	c.ContactName AS ClientContact,
	c.ContactTitle,
	c.City AS ClientCity,
	c.Country AS ClientCountry,
	CONCAT(e.FirstName, ' ',e.LastName) AS EmployeeName,
    e.Title AS EmployeeTitle,
    e.City AS EmployeeCity,
    e.Country AS EmployeeCountry,
    t.TerritoryDescription AS Territory,
    r.RegionDescription AS Region
FROM Orders o
INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
INNER JOIN Shippers AS s ON o.ShipVia = s.ShipperID
INNER JOIN Customers AS c ON o.CustomerID = c.CustomerID
INNER JOIN number_of_product_cte AS np ON o.OrderID = np.OrderID
INNER JOIN Employees AS e ON o.EmployeeID = e.EmployeeID
INNER JOIN EmployeeTerritories AS et ON e.EmployeeID = et.EmployeeID 
INNER JOIN Territories AS t ON et.TerritoryID = t.TerritoryID
INNER JOIN Region AS r ON t.RegionID = r.RegionID

SELECT * FROM OrdersMain

--Creating an empty table for main Products--
CREATE TABLE ProductsMain (
		ProductID INT,
		ProductName NVARCHAR(40),
		Supplier NVARCHAR(40),
		CategoryID INT,
		CategoryName NVARCHAR(15),
		ProdUnitPrice MONEY,
		UnitsInStock SMALLINT,
		UnitsOnOrder SMALLINT,
		ReorderLevel SMALLINT,
		Discontinued BIT,
		SupplierContact NVARCHAR(30),
		ContactTitle NVARCHAR(30),
		SupplierCity NVARCHAR(20),
		SupplierCountry NVARCHAR(20)
		);

--In Case to delete the above table--
DROP TABLE dbo.ProductsMain

INSERT INTO ProductsMain
SELECT
		p.ProductID,
		p.ProductName,
		sp.CompanyName AS Supplier,
		p.CategoryID,
		cat.CategoryName,
		p.UnitPrice AS ProdUnitPrice,
		p.UnitsInStock,
		p.UnitsOnOrder,
		p.ReorderLevel,
		p.Discontinued,
		sp.ContactName AS SupplierContact,
		sp.ContactTitle,
		sp.City AS SupplierCity,
		sp.Country AS SupplierCountry
FROM Products AS p
INNER JOIN Categories AS cat ON p.CategoryID = cat.CategoryID
INNER JOIN Suppliers AS sp ON p.SupplierID = sp.SupplierID

SELECT * FROM ProductsMain
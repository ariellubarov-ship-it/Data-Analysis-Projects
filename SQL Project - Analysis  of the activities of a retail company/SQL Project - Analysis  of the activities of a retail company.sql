--" ניתוח פעילות עסקית של חברה קמעונאית "--



-- זיהוי לקוחות פוטנציאליים לנטישה על סמך דפוסי ההזמנות שלהם	

--WITH OrderGaps AS (
--    SELECT
--        o.CustomerID,
--        c.CustomerName,
--        o.OrderDate,
--        LAG(o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate) AS PreviousOrderDate,
--        DATEDIFF(day,
--                 LAG(o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate),
--                 o.OrderDate) AS GapDays
--    FROM sales.Orders o
--    JOIN sales.Customers c ON o.CustomerID = c.CustomerID
--),
--AvgGaps AS (
--    SELECT
--        CustomerID,
--        CustomerName,
--        MAX(OrderDate) AS LastOrderDate,
--        AVG(GapDays) AS AvgDaysBetweenOrders
--    FROM OrderGaps
--    WHERE GapDays IS NOT NULL
--    GROUP BY CustomerID, CustomerName
--)
--SELECT
--    a.CustomerID,
--    a.CustomerName,
--    a.LastOrderDate AS OrderDate,
--    og.PreviousOrderDate,
--    DATEDIFF(day, a.LastOrderDate, (SELECT MAX(OrderDate) FROM sales.Orders)) AS DaysSinceLastOrder,
--    a.AvgDaysBetweenOrders,
--    CASE
--        WHEN DATEDIFF(day, a.LastOrderDate, (SELECT MAX(OrderDate) FROM sales.Orders)) 
--             > 2 * a.AvgDaysBetweenOrders
--            THEN 'Potential Churn'
--        ELSE 'Active'
--    END AS CustomerStatus
--FROM AvgGaps a
--LEFT JOIN OrderGaps og
--    ON og.CustomerID = a.CustomerID
--    AND og.OrderDate = a.LastOrderDate
--ORDER BY 
--    CASE 
--        WHEN DATEDIFF(day, a.LastOrderDate, (SELECT MAX(OrderDate) FROM sales.Orders)) 
--             > 2 * a.AvgDaysBetweenOrders THEN 1
--        ELSE 2
--    END,
--    a.CustomerID,
--    a.LastOrderDate

--------------------------------------------------------------------------


-- בחינת הסיכון העסקי של החברה לפי קטגוריות לקוחות


--WITH NormalizedCustomers AS (
--    SELECT
--        CASE
--            WHEN c.CustomerName LIKE 'Wingtip%' THEN 'Wingtip Group'
--            WHEN c.CustomerName LIKE 'Tailspin%' THEN 'Tailspin Group'
--            ELSE c.CustomerName
--        END AS NormalizedCustomerName,
--        cc.CustomerCategoryName
--    FROM Sales.Customers c
--    JOIN Sales.CustomerCategories cc
--        ON c.CustomerCategoryID = cc.CustomerCategoryID
--),

--CategoryDistribution AS (
--    SELECT
--        CustomerCategoryName,
--        COUNT(DISTINCT NormalizedCustomerName) AS CustomerCOUNT
--    FROM NormalizedCustomers
--    GROUP BY CustomerCategoryName
--),

--TotalCount AS (
--    SELECT SUM(CustomerCOUNT) AS TotalCustCount
--    FROM CategoryDistribution
--)

--SELECT
--    cd.CustomerCategoryName,
--    cd.CustomerCOUNT,
--    tc.TotalCustCount,
--    CONCAT(
--        FORMAT( (cd.CustomerCOUNT * 100.0) / tc.TotalCustCount, 'N2'),
--        '%'
--    ) AS DistributionFactor
--FROM CategoryDistribution cd
--CROSS JOIN TotalCount tc
--ORDER BY cd.CustomerCOUNT DESC

--------------------------------------------------------------------------


-- מחשבת את סכום המכירות השנתי

--with cte_Yearly_Data 
--as(
--select year(InvoiceDate) as Sales_year,sum(ExtendedPrice - TaxAmount)as IncomePerYear,count (distinct(MONTH(InvoiceDate))) as NumberOfMonthes,

--sum(ExtendedPrice - TaxAmount) / count(distinct(MONTH(InvoiceDate))) * 12 as YearlyLinearIncome

--from sales.InvoiceLines il left JOIN Sales.Invoices l
--							on il.InvoiceID = l.InvoiceID

--group by year(InvoiceDate)
--)

--select Sales_year,IncomePerYear,NumberOfMonthes,FORMAT(YearlyLinearIncome,'n2')as Yearly_LinearI_ncome, 
--(((YearlyLinearIncome - LAG(YearlyLinearIncome)over(order by sales_year)) 
--/ LAG(YearlyLinearIncome)over(order by sales_year))) * 100 as GrowthPercentage
--from cte_Yearly_Data

--------------------------------------------------------------------------------

 -- מציגה את חמשת הלקוחות המובילים בכל רבעון בשנה לפי הכנסה נטו

--with Quaterly_Income AS(
--select YEAR(i.InvoiceDate) AS TheYear,
--		((MONTH(i.InvoiceDate) - 1) / 3) + 1 AS TheQuarter,
--		c.CustomerName,
--		SUM(ExtendedPrice - TaxAmount) AS IncomePerYear	
--from [Sales].Invoices AS i
--right join sales.InvoiceLines AS il 
--			ON i.InvoiceID = il.InvoiceID
--right join sales.Customers AS C 
--			ON i.CustomerID = C.CustomerID
--group by c.CustomerName,YEAR(i.InvoiceDate),
--((MONTH(InvoiceDate) - 1) / 3) + 1
--),
--Ranked AS (
--    SELECT
--        TheYear,
--        TheQuarter,
--        CustomerName,
--        IncomePerYear,
--        RANK() OVER (
--            PARTITION BY TheYear, TheQuarter
--            ORDER BY IncomePerYear DESC) AS DNR
--    FROM Quaterly_Income
--)
--SELECT *
--FROM Ranked
--WHERE DNR <= 5
--ORDER BY TheYear, TheQuarter, DNR

-------------------------------------------------------------------------

-- מאתרת את 10 המוצרים שהניבו את הרווח הכולל הגבוה ביותר 
 

--SELECT TOP (10) il.StockItemID, si.StockItemName,
--    SUM(il.ExtendedPrice - il.TaxAmount) AS TotalProfit
--FROM Sales.InvoiceLines AS il
--left JOIN Warehouse.StockItems AS si
--        ON il.StockItemID = si.StockItemID
--GROUP BY il.StockItemID, si.StockItemName
--ORDER BY TotalProfit DESC


-----------------------------------------------------------------------------

--  איתור כל פריטי המלאי שעדיין בתוקף, חישוב רווח
-- נומינלי של כל פריט 

--with t1 AS(
--select ROW_NUMBER()OVER(order by unitprice desc) AS RN,
--StockItemID,StockItemName,UnitPrice,
--SUM(RecommendedRetailPrice) AS RecommededRetailPrice,
--SUM(RecommendedRetailPrice-UnitPrice) AS NominalProductProfit
--from [Warehouse].[StockItems]
--group by StockItemID,StockItemName,UnitPrice
--)

-- select RN,StockItemID,StockItemName,UnitPrice,RecommededRetailPrice,NominalProductProfit
-- ,DENSE_RANK()OVER(order by NominalProductProfit DESC) AS DNR
-- from t1

------------------------------------------------------------------------------------

 -- שאילתה שמציגה עבור כל קוד ספק ושם ספק את רשימת המוצרים במלאי עבור אותו
--ספק, כשהרשימה מופרדת באמצעות ' , / '. 

--SELECT
--    CONCAT(s.SupplierID, ' - ', s.SupplierName) AS SupplierDetails,
--    STRING_AGG(CONCAT(si.StockItemID, ' ', si.StockItemName), ' / , ')
--        WITHIN GROUP (ORDER BY si.StockItemID) AS ProductDetails
--FROM purchasing.suppliers AS s
--JOIN warehouse.stockitems AS si
--    ON si.SupplierID = s.SupplierID
--GROUP BY s.SupplierID, s.SupplierName

--------------------------------------------------------------------------

-- חמשת הלקוחות המובילים לפי הסכום הכולל
   
--SELECT TOP (5)
--    c.CustomerID,
--    ct.CityName,
--    co.CountryName,
--    co.Continent,
--    co.Region, FORMAT(SUM(il.ExtendedPrice), 'N2') AS TotalExtendedPrice
--FROM Sales.Invoices AS i
--join Sales.InvoiceLines AS il
--    on i.InvoiceID = il.InvoiceID
--join Sales.Customers AS c
--    on i.CustomerID = c.CustomerID
--join Application.Cities AS ct
--    on c.DeliveryCityID = ct.CityID
--join Application.StateProvinces AS sp
--    on ct.StateProvinceID = sp.StateProvinceID
--join Application.Countries AS co
--    on sp.CountryID = co.CountryID
--group by 
--    c.CustomerID,
--    ct.CityName,
--    co.CountryName,
--    co.Continent,
--    co.Region
--order by
--    SUM(il.ExtendedPrice) DESC

--------------------------------------------------------------------------

-- מציג את סכום המוצרים בהזמנה עבור כל חודש בשנה

--SELECT 
--    OrderYear,
--    OrderMonth,
--    FORMAT(MonthlyTotal, 'N2') AS MonthlyTotal,
--    FORMAT(CumulativeTotal, 'N2') AS CumulativeTotal
--FROM (
--    SELECT 
--        YEAR(i.InvoiceDate) AS OrderYear,
--        MONTH(i.InvoiceDate) AS OrderMonth,
--        SUM(il.ExtendedPrice) AS MonthlyTotal,
--        SUM(SUM(il.ExtendedPrice)) OVER (
--            PARTITION BY YEAR(i.InvoiceDate)
--            order by MONTH(i.InvoiceDate)
--        ) AS CumulativeTotal
--    FROM Sales.Invoices AS i
--    join Sales.InvoiceLines AS il
--        ON i.InvoiceID = il.InvoiceID
--    group by 
--        YEAR(i.InvoiceDate),
--        MONTH(i.InvoiceDate)
--) AS X
--order by OrderYear, OrderMonth


--------------------------------------------------------------------------

-- הצגת מטריצה של מספר ההזמנות שנעשו בכל חודש בשנה

--SELECT 
--    OrderMonth AS OrderMonth,
--    [2013],
--    [2014],
--    [2015],
--    [2016]
--FROM (
--    SELECT 
--        YEAR(OrderDate) AS OrderYear,
--        MONTH(OrderDate) AS OrderMonth,
--        OrderID
--    FROM Sales.Orders) AS src
--PIVOT (
--    COUNT(OrderID)
--    FOR OrderYear IN ([2013],[2014],[2015],[2016])) AS p
--ORDER BY OrderMonth

--SELECT
--    cd.CustomerCategoryName,
--    cd.CustomerCOUNT,
--    tc.TotalCustCount,
--    CONCAT(
--        FORMAT( (cd.CustomerCOUNT * 100.0) / tc.TotalCustCount, 'N2'),
--        '%'
--    ) AS DistributionFactor
--FROM CategoryDistribution cd
--CROSS JOIN TotalCount tc
--ORDER BY cd.CustomerCOUNT DESC
---------------------------------------------------------------------------
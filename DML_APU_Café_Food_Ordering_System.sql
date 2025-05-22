USE DBM_Assignment;

-- i. List the food(s) which has the highest rating. Show food id, food name and the rating.
SELECT FB.FoodID, M.FoodName, AVG(Rating) AS Rating
FROM Feedbacks AS FB
INNER JOIN Menu AS M
ON FB.FoodID = M.FoodID
GROUP BY FB.FoodID, M.FoodName
ORDER BY AVG(Rating) DESC;


-- ii. Find the total number of feedback per member. Show member id, member name and total number of feedbacks per member.
SELECT FB.MemberID, MB.MemberName AS Name, COUNT(FB.Rating) AS NumOfFeedbacks
FROM Feedbacks AS FB
INNER JOIN Members AS MB
ON FB.MemberID = MB.MemberID
GROUP BY FB.MemberID, MB.MemberName;

-- iii. Find members who have not made any orders. Show member id, member name and the total order.
--memberNumOrder(@numOrder INT, @operator NVARCHAR(2))
SELECT * FROM memberNumOrder(0, '=');

-- iv. Find the total number of food(meal) ordered by manager from each chef.
--NumOfFood ordered by chef only, excluding order that is pending and just confirmed (not read)
SELECT M.ChefID, EMP.EmployeeName AS Name, SUM(CI.Quantity) AS NumOfFood, O.OrderManagerID
FROM Orders AS O
INNER JOIN OrderStatus AS OS
ON O.OrderID = OS.OrderID AND OS.DeliveryStatus NOT IN('Pending', 'Waiting', 'Confirmed')
INNER JOIN CartItems AS CI
ON O.CartID = CI.CartID
INNER JOIN Menu AS M
ON CI.FoodID = M.FoodID
INNER JOIN Employees AS EMP
ON M.ChefID = EMP.EmployeeID
GROUP BY M.ChefID, EMP.EmployeeName, O.OrderManagerID;

-- v. Find the total number of food(meal) cooked by each chef. Show chef id, chef name, and number of meals cooked.
--NumOfFood ordered by chef only, excluding order that is pending and just confirmed (not read)
SELECT M.ChefID, EMP.EmployeeName AS Name, COUNT(CM.FoodID) AS NumOfFood
FROM CookedMeals AS CM
INNER JOIN Menu AS M
ON CM.FoodID = M.FoodID
INNER JOIN Employees AS EMP
ON M.ChefID = EMP.EmployeeID
GROUP BY M.ChefID, EMP.EmployeeName;

--NumOfFood ordered by chef and food, excluding order that is pending and just confirmed (not read)
SELECT M.ChefID, EMP.EmployeeName AS Name, M.FoodID, M.FoodName, SUM(CI.Quantity) AS NumOfFood, O.OrderManagerID
FROM Orders AS O
INNER JOIN OrderStatus AS OS
ON O.OrderID = OS.OrderID AND OS.DeliveryStatus NOT IN('Pending', 'Waiting', 'Confirmed')
INNER JOIN CartItems AS CI
ON O.CartID = CI.CartID
INNER JOIN Menu AS M
ON CI.FoodID = M.FoodID
INNER JOIN Employees AS EMP
ON M.ChefID = EMP.EmployeeID
GROUP BY M.ChefID, EMP.EmployeeName, M.FoodID, M.FoodName, O.OrderManagerID;

-- vi. List all the food where its average rating is more than the average rating of all food. 
SELECT FB.FoodID, M.FoodName, AVG(FB.Rating) AS AverageRating
FROM Feedbacks AS FB
INNER JOIN Menu AS M
ON FB.FoodID = M.FoodID
GROUP BY FB.FoodID, M.FoodName
HAVING AVG(FB.Rating) > (
	SELECT AVG(Rating) FROM Feedbacks
);


-- vii. Find the top 3 bestselling food(s). The list should include id, name, price and quantity sold.
SELECT TOP 3 CI.FoodID, M.FoodName, M.Price, SUM(CI.Quantity) AS QuantitySold
FROM CartItems AS CI
INNER JOIN Orders AS O
ON CI.CartID = O.CartID
INNER JOIN OrderStatus AS OS
ON O.OrderID = OS.OrderID AND OS.DeliveryStatus <> 'Pending'
INNER JOIN Menu AS M
ON CI.FoodID = M.FoodID
GROUP BY CI.FoodID, M.FoodName, M.Price
ORDER BY SUM(CI.Quantity) DESC, CI.FoodID ASC;


-- viii. Show the top 3 members who spent most on ordering food. List should include id and name and whether they student or staff.
SELECT TOP 3 MB.MemberID, MB.Name, MB.Gender, MB.Age, MB.RegisterDate, MB.Email, MB.EmailPassword, DBM_Assignment.dbo.studentOrStaff(MB.MemberID) AS Role
FROM EncryptedMember_vw AS MB
INNER JOIN Orders AS O
ON MB.MemberID = O.MemberID
INNER JOIN OrderStatus AS OS
ON OS.OrderID = O.OrderID AND OS.DeliveryStatus <> 'Pending'
INNER JOIN Payments AS PY
ON PY.PaymentID = O.PaymentID
GROUP BY MB.MemberID, MB.Name, MB.Gender, MB.Age, MB.Gender, MB.RegisterDate, MB.Email, MB.EmailPassword
ORDER BY SUM(PY.Amount) DESC;

--for checking
SELECT MB.MemberID, MB.Name, MB.Gender, MB.Age, MB.RegisterDate, MB.Email, MB.EmailPassword, DBM_Assignment.dbo.studentOrStaff(MB.MemberID) AS Role, SUM(PY.Amount) AS TotalSpendOnFood
FROM EncryptedMember_vw AS MB
INNER JOIN Orders AS O
ON MB.MemberID = O.MemberID
INNER JOIN OrderStatus AS OS
ON OS.OrderID = O.OrderID AND OS.DeliveryStatus <> 'Pending'
INNER JOIN Payments AS PY
ON PY.PaymentID = O.PaymentID
GROUP BY MB.MemberID, MB.Name, MB.Gender, MB.Age, MB.Gender, MB.RegisterDate, MB.Email, MB.EmailPassword
ORDER BY SUM(PY.Amount) DESC;


-- ix. Show the total members based on gender who are registered as members. List should include id, name, role(student/staff) and gender.
SELECT MB.MemberID, MB.MemberName AS Name, MB.MemberGender AS Gender,
DBM_Assignment.dbo.studentOrStaff(MB.MemberID) AS Role,
COUNT(MB.MemberGender) OVER (PARTITION BY MemberGender) AS TotalMemberGenderBased
FROM Members AS MB
ORDER BY Gender ASC, MemberID ASC;

-- x. Show a list of ordered food which has not been delivered to members. The list should show member id, role(student/staff), contact number, food id, food name, quantity, date, and status of delivery.
SELECT O.MemberID, DBM_Assignment.dbo.studentOrStaff(MB.MemberID) AS Role, MB.Name AS Name, MB.Email, MB.EmailPassword, CI.FoodID, M.FoodName, CI.Quantity, CI.ItemDateTime, OS.DeliveryStatus
FROM EncryptedMember_vw AS MB
INNER JOIN Orders AS O
ON O.MemberID = MB.MemberID
INNER JOIN OrderStatus AS OS
ON O.OrderID = OS.OrderID AND OS.DeliveryStatus = 'Waiting'
INNER JOIN ShoppingCarts AS SC
ON O.CartID = SC.CartID
INNER JOIN CartItems AS CI
ON CI.CartID = SC.CartID
INNER JOIN Menu AS M
ON CI.FoodID = M.FoodID
INNER JOIN CookedMeals AS CM
ON CM.FoodID = CI.FoodID
WHERE CI.CartID <> CM.CartID OR (CI.CartID = CM.CartID AND CI.FoodID <> CM.FoodID);

-- xi. Show a list of members who made more than 2 orders. The list should show their member id, name, and role(student/staff) and total orders.
--memberNumOrder(@numOrder INT, @operator NVARCHAR(2))
SELECT MB.MemberID, MB.MemberName AS Name, DBM_Assignment.dbo.studentOrStaff(MB.MemberID) AS Role, MNO.TotalOrder
FROM Members AS MB
INNER JOIN memberNumOrder(2, '>') AS MNO
ON MNO.MemberID = MB.MemberID;

-- xii. Find the monthly sales totals for the past year. The list should show order year, order month and total cost for that month.
SELECT YEAR(PY.PaymentDateTime) AS OrderYear, CASE MONTH(PY.PaymentDateTime)
	WHEN 1 THEN 'January'
	WHEN 2 THEN 'February'
	WHEN 3 THEN 'March'
	WHEN 4 THEN 'April'
	WHEN 5 THEN 'May'
	WHEN 6 THEN 'June'
	WHEN 7 THEN 'July'
	WHEN 8 THEN 'August'
	WHEN 9 THEN 'September'
	WHEN 10 THEN 'October'
	WHEN 11 THEN 'November'
	WHEN 12 THEN 'December'
END AS OrderMonth, SUM(PY.Amount) AS MonthlySales
FROM Payments AS PY
WHERE YEAR(PY.PaymentDateTime) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PY.PaymentDateTime), MONTH(PY.PaymentDateTime);

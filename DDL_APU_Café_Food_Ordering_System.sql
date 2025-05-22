CREATE DATABASE DBM_Assignment;
USE DBM_Assignment;

--CREATING TABLES
CREATE TABLE Employees(
	EmployeeID NVARCHAR(10) NOT NULL PRIMARY KEY,
	EmployedDate DATETIME,
	EmployeeName NVARCHAR(100) NOT NULL,
	ContactDetails NVARCHAR(20),
	EmployeeBirthDate DATE,
	EmployeeGender NVARCHAR(20) CONSTRAINT validEmployeeGender CHECK(
		LOWER(EmployeeGender) IN('male', 'female', 'prefer not to say')
	)
);


CREATE TABLE Managers(
	ManagerID NVARCHAR(10) NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES Employees(EmployeeID),
	Year DATE NOT NULL,
	ManagerExperience NVARCHAR(10),
	ManagerQualifications NVARCHAR(100)
);


CREATE TABLE Chefs(
	ChefID NVARCHAR(10) NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES Employees(EmployeeID),
	Station NVARCHAR(50),
	ChefSkills NVARCHAR(300),
	ChefExperience NVARCHAR(10),
	ChefCertifications NVARCHAR(100)
);


CREATE TABLE DispatchWorkers(
	WorkerID NVARCHAR(10) NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES Employees(EmployeeID),
	WorkerSkills NVARCHAR(300),
	WorkerCertifications NVARCHAR(100)
);


CREATE TABLE Members(
	MemberID NVARCHAR(10) NOT NULL PRIMARY KEY,
	MemberName NVARCHAR(100) NOT NULL,
	MemberBirthDate DATE,
	MemberGender NVARCHAR(20) CONSTRAINT validMemberGender CHECK(
		LOWER(MemberGender) IN('male', 'female', 'prefer not to say')
	),
	RegisterDate DATETIME,
	Email NVARCHAR(100),
	EmailPassword NVARCHAR(100),
	Allergies NVARCHAR(100)
);


CREATE TABLE Lecturers(
	MemberID NVARCHAR(10) FOREIGN KEY REFERENCES Members(MemberID) NULL UNIQUE,
	StaffID NVARCHAR(10) NOT NULL PRIMARY KEY,
	Department NVARCHAR(100)
);


CREATE TABLE Students(
	MemberID nvarchar(10) FOREIGN KEY REFERENCES Members(MemberID) NULL UNIQUE,
	TPNumber nvarchar(10) NOT NULL PRIMARY KEY,
	Course nvarchar(100),
	LevelOfStudies nvarchar(100)
);


CREATE TABLE ShoppingCarts(
	CartID NVARCHAR(10) NOT NULL PRIMARY KEY,
	MemberID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
	CartDateTime DATETIME
);


CREATE TABLE MenuCategory(
	MenuCategoryID NVARCHAR(10) NOT NULL PRIMARY KEY,
	CategoryName NVARCHAR(50) NOT NULL UNIQUE,
	CategoryLastDateUpdated DATETIME
);


CREATE TABLE Menu(
	FoodID NVARCHAR(10) NOT NULL PRIMARY KEY,
	FoodType NVARCHAR(10),
	FoodName NVARCHAR(100) NOT NULL UNIQUE,
	FoodDescription NVARCHAR(MAX),
	UnitPrice DECIMAL(10,2),
	FoodLastDateUpdated DATETIME,
	MenuCategoryID NVARCHAR(10) FOREIGN KEY REFERENCES MenuCategory(MenuCategoryID),
	ChefID NVARCHAR(10) FOREIGN KEY REFERENCES Chefs(ChefID)
);


CREATE TABLE CartItems(
	CartID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES ShoppingCarts(CartID),
	FoodID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES MENU(FoodID),
	Quantity INT,
	ItemDateTime DATETIME,
	PRIMARY KEY (CartID, FoodID)
);


CREATE TABLE Payments(
	PaymentID NVARCHAR(10) NOT NULL PRIMARY KEY,
	MemberID NVARCHAR(10)NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
	CartID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES ShoppingCarts(CartID) UNIQUE,
	Amount DECIMAL(10, 2),
	PaymentDateTime DATETIME
);


CREATE TABLE PaymentMethods(
	PaymentID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Payments(PaymentID) UNIQUE,
	PaymentMethod NVARCHAR(50)
);


CREATE TABLE Orders(
	OrderID NVARCHAR(10) NOT NULL PRIMARY KEY,
	PaymentID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Payments(PaymentID) UNIQUE,
	MemberID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
	CartID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES ShoppingCarts(CartID),
	OrderDate DATE,
	OrderStartTime TIME,
	OrderEndTime TIME,
	TableNumber NVARCHAR(10),
	OrderManagerID NVARCHAR(10) FOREIGN KEY REFERENCES Managers(ManagerID),
);


CREATE TABLE CookedMeals(
	CookedMealsID NVARCHAR(10) NOT NULL PRIMARY KEY,
	OrderID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
	CartID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES ShoppingCarts(CartID),
	FoodID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Menu(FoodID),
	WorkerID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES DispatchWorkers(WorkerID),
	MealDateTime DATETIME,
	DeliveryStartTime TIME,
	DeliveryEndTime TIME,
); 


CREATE TABLE OrderStatus(
	MemberID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
	OrderID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Orders(OrderID) UNIQUE,
	CartID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES ShoppingCarts(CartID) UNIQUE,
	DeliveryStatus NVARCHAR(20) CONSTRAINT validStatus CHECK(DeliveryStatus IN('Pending', 'Confirmed', 'Waiting', 'Read', 'Preparing', 'Completed'))
	PRIMARY KEY (MemberID, OrderID, CartID)
);


CREATE TABLE Feedbacks(
	FeedbackID NVARCHAR(10) NOT NULL PRIMARY KEY,
	MemberID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
	OrderID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
	FoodID NVARCHAR(10) NOT NULL FOREIGN KEY REFERENCES Menu(FoodID),
	Rating INT CONSTRAINT validRating CHECK(
		Rating BETWEEN 1 AND 5
	),
	Review NVARCHAR(MAX),
	FeedbackDate DATE
);


--INSERTING DATA INTO TABLES

INSERT INTO Employees VALUES
	('MID01', '2004-02-01', 'Rowena.D', '0126455455', '1968-05-14', 'Female'),
	('CFID01', '2004-07-11', 'Wesley.S', '0126533566', '1971-03-29', 'Male'),
	('CFID02', '2004-09-23', 'Susana.R', '0173264595', '1974-08-21', 'Female'),
	('CFID03', '2006-10-17', 'Otto.A', '0143962525', '1973-02-08', 'Male'),
	('WID01', '2004-10-20', 'Elena.R', '0114888923', '1996-11-24', 'Female'),
	('WID02', '2004-11-18', 'Rob.E', '0196587423', '1994-07-05', 'Male'),
	('WID03', '2006-11-24', 'Joseph.B', '0162354815', '1998-10-09', 'Male');


INSERT INTO Managers VALUES
	('MID01', '2004', '18 Years', 'Master of Business Administration (MBA)');


INSERT INTO Chefs VALUES
	('CFID01', 'Hot Kitchen', 'Cooking techniques like frying, stir-frying, and grilling', '9 Years', 'Culinary Arts Diploma'),
	('CFID02', 'Beverage', 'Attention to detail for ensuring consistent drink quality and presentation', '5 Years', 'Food Safety and Sanitation Certification'),
	('CFID03', 'Light Meal', 'Experience with preparing breakfast dishes', '7 Years', 'Basic Culinary Skills Certification');


INSERT INTO DispatchWorkers VALUES
	('WID01', 'Problem-Solving Skills', 'Customer Service Certification'),
	('WID02', 'Time Management and Organization', 'Delivery Dispatch Certification'),
	('WID03', 'Communication Skills', 'Customer Service Certification');

--DATETIME FORMAT: 2024-05-07 08:09:10.123
INSERT INTO Members VALUES
	('MB0001', 'Ali', '1994-10-08', 'Male', '2023-01-10 08:09:10.123', 'ali08@gmail.com', 'rduferie0', NULL),
	('MB0002', 'Rainbow', '1999-05-14', 'Female', '2023-01-20 14:22:11.124', 'bow20@gmail.com', 'dA1! mRJ', 'Peanut'),
	('MB0003', 'Sarah', '1965-03-20', 'Female', '2023-01-27 13:09:56.243', 's1714@gmail.com', 'S@r13', 'Seafood'),
	('MB0004', 'Jason', '1985-02-14', 'Prefer not to say', '2023-02-15 10:12:12.453', 'j171n@gmail.com', 'JaSaN2003', NULL),
	('MB0005', 'K.Vince', '2004-12-11', 'Male', '2023-02-21 16:44:04.444', 'kv0566@gmail.com', 'pP4#5jjC', 'Milk'),
	('MB0006', 'MacHill', '1975-04-08', 'Male', '2023-02-24 4:44:04.448', 'mh0008@gmail.com', 'P@ssw673', 'Peach'),
	('MB0007', 'J.Wenton', '1994-09-24', 'Prefer not to say', '2023-03-01 6:56:06.666', 'jw3687@gmail.com', 'JW!1994?', 'Banana'),
	('MB0008', 'Micheal', '2005-06-09', 'Female', '2023-03-15 18:46:06.668', 'm1988@gmail.com', 'tD4!} Msi', NULL),
	('MB0009', 'Shanan', '1977-11-11', 'Female', '2023-03-26 17:33:13.426', 'shan17@gmail.com', 'sMarTmE844', NULL),
	('MB0010', 'S.Hanson', '1971-07-16', 'Male', '2023-03-05 15:23:45.231', 'sh1234@gmail.com', 'IdkWhat1971', 'Seafood');


INSERT INTO Lecturers VALUES
	('MB0003', 'EMP100023', 'Academic Administration'),
	('MB0004', 'EMP102054', 'Finance'),
	('MB0006', 'EMP100889', 'School of Business'),
	('MB0009', 'EMP107888', 'School of Technology'),
	('MB0010', 'EMP104566', 'Human Resources'),
	(NULL, 'EMP103893', 'Psychology');


INSERT INTO Students VALUES
	('MB0001', 'TP075966', 'Account', 'Master'),
	('MB0002', 'TP054411', 'Software Engineering', 'PhD'),
	('MB0005', 'TP045533', 'Design and Media', 'Diploma'),
	('MB0007', 'TP062248', 'Data Informatics', 'Diploma'),
	('MB0008', 'TP088422', 'Cybersecurity', 'Degree'),
	(NULL, 'TP645834', 'Artificial Intelligence', 'Degree');


INSERT INTO ShoppingCarts VALUES
	('CID001', 'MB0005', '2023-03-15 11:29:00.123'),
	('CID002', 'MB0002', '2023-03-20 13:02:10.453'),
	('CID003', 'MB0006', '2023-03-30 12:07:09.001'),
	('CID004', 'MB0008', '2023-07-02 11:44:34.907'),
	('CID005', 'MB0010', '2023-07-09 12:59:10.291'),
	('CID006', 'MB0007', '2023-07-18 12:12:37.241'),
	('CID007', 'MB0003', '2024-06-06 11:37:02.874'), --Preparing
	('CID008', 'MB0001', '2024-06-06 12:16:23.542'), --Read
	('CID009', 'MB0005', '2024-06-06 12:27:13.379'), --Waiting
	('CID010', 'MB0007', '2024-06-06 13:02:43.124'), --Confirmed
	('CID011', 'MB0007', '2024-06-06 13:41:29.431'); --Pending


INSERT INTO MenuCategory VALUES 
	('MC01', 'Malay', '2023-01-15'),
	('MC02', 'Chinese', '2023-01-15'),
	('MC03', 'India', '2023-01-15'), 
	('MC04', 'Western', '2023-01-15'), 
	('MC05', 'Dessert', '2023-01-15'), 
	('MC06', 'Beverage', '2023-01-15');


INSERT INTO Menu VALUES
	('F001', 'Food', 'Nasi Lemak', 'Nasi Lemak with Kacang, Ikan Bilis, Cucumber, Half Hard-Boiled Egg & Sambal.', 3.00, '2024-03-15', 'MC01', 'CFID01'),
	('F002', 'Food', 'Nasi Goreng', 'Rice that is stir-fried with soy sauce, beaten egg, chopped meat, and vegetables.', 5.00, '2024-03-15', 'MC02', 'CFID01'),
	('F003', 'Food', 'Roti Canai', 'A flatbread made from dough that is composed of fat, flour, and water.', 1.50, '2024-03-15', 'MC03', 'CFID01'),
	('F004', 'Food', 'Waffles', 'Crisp raised cake baked in a waffle iron.', 4.50, '2024-03-15', 'MC05', 'CFID03'),
	('F005', 'Food', 'Fried Noodle', 'Noodles stir-fried in cooking oil with garlic, onion, chicken, chili, and cabbages.', 6.00, '2024-03-15', 'MC02', 'CFID01'),
	('F006', 'Food', 'Spaghetti Bolognese', 'Spaghetti with meat sauce made with minced beef, and tomatoes, served with Parmesan cheese.', 8.50, '2024-03-15', 'MC04', 'CFID01'),
	('F007', 'Food', 'Chicken Chop', 'Marinated breaded boneless chicken that is fried to golden perfection, then drowned in a sauce.', 9.00, '2024-03-15', 'MC04', 'CFID01'),
	('F008', 'Drink', 'Milk Tea', 'Tea with milk added.', 3.90, '2024-03-15', 'MC06', 'CFID02'),
	('F009', 'Drink', 'Kopi', 'A beverage brewed from roasted coffee beans.', 2.00, '2024-03-15', 'MC06', 'CFID02'),
	('F010', 'Drink', 'Tea', 'A beverage produced by steeping in freshly boiled water the tea pack.', 2.00, '2024-03-15', 'MC06', 'CFID02');



INSERT INTO CartItems VALUES
	('CID001', 'F001', 2, '2023-03-15 11:30:31.010'),
	('CID001', 'F009', 3, '2023-03-15 11:31:32.012'),
	('CID001', 'F004', 1, '2023-03-15 11:31:50.210'),
	('CID002', 'F006', 2, '2023-03-20 13:04:05.012'),
	('CID002', 'F008', 4, '2023-03-20 13:05:01.002'),
	('CID003', 'F007', 3, '2023-03-30 12:07:53.101'),
	('CID003', 'F010', 2, '2023-03-30 12:08:32.124'),
	('CID004', 'F002', 1, '2023-07-02 11:45:23.672'),
	('CID005', 'F007', 3, '2023-07-09 13:00:43.001'),
	('CID006', 'F006', 2, '2023-07-18 12:13:16.118'),
	('CID006', 'F004', 1, '2023-07-18 12:13:50.001'),
	('CID007', 'F001', 2, '2024-06-06 11:38:01.245'),
	('CID008', 'F003', 1, '2024-06-06 12:17:08.224'),
	('CID008', 'F009', 1, '2024-06-06 12:18:23.108'),
	('CID009', 'F002', 3, '2024-06-06 12:28:16.139'),
	('CID010', 'F007', 2, '2024-06-06 13:03:23.193'),
	('CID011', 'F006', 2, '2024-06-06 13:42:30.537');


INSERT INTO Payments VALUES
	('PYID001', 'MB0005', 'CID001', 16.50, '2023-03-15 11:40:23.600'),
	('PYID002', 'MB0002', 'CID002', 32.60, '2023-03-20 13:10:09.080'),
	('PYID003', 'MB0006', 'CID003', 31.00, '2023-03-30 12:13:52.700'),
	('PYID004', 'MB0008', 'CID004', 5.00, '2023-07-02 11:50:53.006'),
	('PYID005', 'MB0010', 'CID005', 27.00, '2023-07-09 13:06:46.430'),
	('PYID006', 'MB0007', 'CID006', 21.50, '2023-07-18 13:16:13.230'),
	('PYID007', 'MB0003', 'CID007', 6.00, '2024-06-06 11:45:37:913'),
	('PYID008', 'MB0001', 'CID008', 3.50, '2024-06-06 12:24:53:519'),
	('PYID009', 'MB0005', 'CID009', 15.00, '2024-06-06 12:36:17:802'),
	('PYID010', 'MB0007', 'CID010', 18.00, '2024-06-06 13:11:21:643'),
	('PYID011', 'MB0007', 'CID011', 17.00, '2024-06-06 13:50:34:561');


INSERT INTO PaymentMethods VALUES
	('PYID001', 'Pay at Counter'),
	('PYID002', 'Online Banking'),
	('PYID003', 'Pay at Counter'),
	('PYID004', 'Online Banking'),
	('PYID005', 'Online Banking'),
	('PYID006', 'Pay at Counter'),
	('PYID007', 'Online Banking'),
	('PYID008', 'Pay at Counter'),
	('PYID009', 'Pay at Counter'),
	('PYID010', 'Online Banking'),
	('PYID011', 'Online Banking');


INSERT INTO Orders VALUES
	('OID001', 'PYID001', 'MB0005', 'CID001', '2023-03-15', '11:31:51.291', '11:35:01.551', 31, 'MID01'),
	('OID002', 'PYID002', 'MB0002', 'CID002', '2023-03-20', '13:05:55.253', '13:09:51.591', 8, 'MID01'),
	('OID003', 'PYID003', 'MB0006', 'CID003', '2023-03-30', '12:09:05.324', '12:10:21.223', 27, 'MID01'),
	('OID004', 'PYID004', 'MB0008', 'CID004', '2023-07-02', '11:46:30.201', '11:48:47.112', 84, 'MID01'),
	('OID005', 'PYID005', 'MB0010', 'CID005', '2023-07-09', '13:02:05.324', '13:04:56.888', 66, 'MID01'),
	('OID006', 'PYID006', 'MB0007', 'CID006', '2023-07-18', '12:14:55.364', '12:15:41.666', 47, 'MID01'),
	('OID007', 'PYID007', 'MB0003', 'CID007', '2024-06-06', '11:42:53.204', '11:43:31.125', 12, 'MID01'),
	('OID008', 'PYID008', 'MB0001', 'CID008', '2024-06-06', '12:20:12.110', '12:21:40.523', 25, 'MID01'),
	('OID009', 'PYID009', 'MB0005', 'CID009', '2024-06-06', '12:31:24.802', '12:33:12.316', 18, 'MID01'),
	('OID010', 'PYID010', 'MB0007', 'CID010', '2024-06-06', '13:07:52.671', '13:09:03.632', 77, 'MID01'),
	('OID011', 'PYID011', 'MB0007', 'CID011', '2024-06-06', '13:45:06.185', '13:47:36.472', 39, 'MID01');


--cooked meal deliver within 15 min
INSERT INTO CookedMeals VALUES
	('CMID001', 'OID001', 'CID001', 'F001', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567'), --F001 X 2
	('CMID002', 'OID001', 'CID001', 'F001', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567'),
	('CMID003', 'OID001', 'CID001', 'F009', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567'), --F009 X 3
	('CMID004', 'OID001', 'CID001', 'F009', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567'),
	('CMID005', 'OID001', 'CID001', 'F009', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567'),
	('CMID006', 'OID001', 'CID001', 'F004', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567'), --F004 X 1
	('CMID007', 'OID002', 'CID002', 'F006', 'WID03', '13:18:36.256', '13:25:32.404', '13:55:46.356'), --F006 X 2
	('CMID008', 'OID002', 'CID002', 'F006', 'WID03', '13:18:36.256', '13:25:32.404', '13:55:46.356'),
	('CMID009', 'OID002', 'CID002', 'F008', 'WID03', '13:18:36.256', '13:25:32.404', '13:55:46.356'), --F008 X 4
	('CMID010', 'OID002', 'CID002', 'F008', 'WID03', '13:18:36.256', '13:25:32.404', '13:55:46.356'),
	('CMID011', 'OID002', 'CID002', 'F008', 'WID03', '13:18:36.256', '13:25:32.404', '13:55:46.356'),
	('CMID012', 'OID002', 'CID002', 'F008', 'WID03', '13:18:36.256', '13:25:32.404', '13:55:46.356'),
	('CMID013', 'OID003', 'CID003', 'F007', 'WID01', '12:25:38.468', '12:27:36.346', '12:39:24.676'), --F007 X 3
	('CMID014', 'OID003', 'CID003', 'F007', 'WID01', '12:25:38.468', '12:27:36.346', '12:39:24.676'),
	('CMID015', 'OID003', 'CID003', 'F007', 'WID01', '12:25:38.468', '12:27:36.346', '12:39:24.676'),
	('CMID016', 'OID003', 'CID003', 'F010', 'WID01', '12:25:38.468', '12:27:36.346', '12:39:24.676'), --F010 X 2
	('CMID017', 'OID003', 'CID003', 'F010', 'WID01', '12:25:38.468', '12:27:36.346', '12:39:24.676'),
	('CMID018', 'OID004', 'CID004', 'F002', 'WID01', '12:00:56.672', '12:02:16.552', '12:09:34.542'), --F002 X 1
	('CMID019', 'OID005', 'CID005', 'F007', 'WID03', '13:15:56.996', '13:25:54.872', '13:43:34.756'), --F007 X 3
	('CMID020', 'OID005', 'CID005', 'F007', 'WID03', '13:15:56.996', '13:25:54.872', '13:43:34.756'),
	('CMID021', 'OID005', 'CID005', 'F007', 'WID03', '13:15:56.996', '13:25:54.872', '13:43:34.756'),
	('CMID022', 'OID006', 'CID006', 'F006', 'WID02', '12:24:34.243', '12:25:56.514', '12:33:13.871'), --F006 X 2
	('CMID023', 'OID006', 'CID006', 'F006', 'WID02', '12:24:34.243', '12:25:56.514', '12:33:13.871'),
	('CMID024', 'OID006', 'CID006', 'F004', 'WID02', '12:24:34.243', '12:25:56.514', '12:33:13.871'); --F004 X 1


INSERT INTO OrderStatus VALUES
	('MB0005', 'OID001', 'CID001', 'Completed'),
	('MB0002', 'OID002', 'CID002', 'Completed'),
	('MB0006', 'OID003', 'CID003', 'Completed'),
	('MB0008', 'OID004', 'CID004', 'Completed'),
	('MB0010', 'OID005', 'CID005', 'Completed'),
	('MB0007', 'OID006', 'CID006', 'Completed'),
	('MB0003', 'OID007', 'CID007', 'Preparing'),
	('MB0001', 'OID008', 'CID008', 'Read'),
	('MB0005', 'OID009', 'CID009', 'Waiting'),
	('MB0007', 'OID010', 'CID010', 'Confirmed'),
	('MB0007', 'OID011', 'CID011', 'Pending');


INSERT INTO Feedbacks VALUES
	('FID001', 'MB0005', 'OID001', 'F001', 5, 'The Nasi Lemak is very nice and tasty :P', '2023-03-16'),
	('FID002', 'MB0005', 'OID001', 'F009', 3, 'Just normal kopi', '2023-03-16'),
	('FID003', 'MB0005', 'OID001', 'F004', 2, 'The waffle is too sweet for me!', '2023-03-16'),
	('FID004', 'MB0002', 'OID002', 'F006', 1, 'Although the food is not bad, but the delivery is too slow and the food has been cold already :(', '2023-03-23'),
	('FID005', 'MB0002', 'OID002', 'F008', 1, 'Although the food is not bad, but the delivery is too slow and the food has been cold already :(', '2023-03-23'),
	('FID006', 'MB0006', 'OID003', 'F007', 4, 'The chicken chop is crispy and delicious :)', '2023-03-31'),
	('FID007', 'MB0006', 'OID003', 'F010', 4, 'The tea is okey.', '2023-03-31'),
	('FID008', 'MB0008', 'OID004', 'F002', 5, 'The nasi goreng is very delicious, I like the taste of it!', '2023-07-05'),
	('FID009', 'MB0010', 'OID005', 'F007', 2, 'Very disappointed as the delivery is too slow, and promised that only 15 minutes required for delivery.', '2023-07-12'),
	('FID010', 'MB0007', 'OID006', 'F006', 4, 'The spaghetti is tasty and the portion is very worth for it =P', '2023-07-21'),
	('FID011', 'MB0007', 'OID006', 'F004', 4, 'The waffle also taste good.', '2023-07-21');

--(A) TRIGGER TEST ON COOKED MEALS
TRUNCATE TABLE CookedMeals
--Exceed quantity of food ordered
--OID001, CID001, F001 X 2
INSERT INTO CookedMeals VALUES -- cooked 2 F001
	('CMID001', 'OID001', 'CID001', 'F001', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567'),
	('CMID002', 'OID001', 'CID001', 'F001', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567');

INSERT INTO CookedMeals VALUES -- cooked 3rd F001 (more than ordered)
	('CMID003', 'OID001', 'CID001', 'F001', 'WID02', '11:50:08.901', '11:51:36.751', '12:02:11.567');

--(B) TRIGGER TEST ON FEEDBACKS
TRUNCATE TABLE Feedbacks
--MB005, OID001, F001/F009/F004
--Incorrect OrderID
INSERT INTO Feedbacks VALUES
	('FID001', 'MB0005', 'OID002', 'F001', 5, 'The Nasi Lemak is very nice and tasty :P', '2023-03-16');

--Incorrect FoodID
INSERT INTO Feedbacks VALUES
	('FID001', 'MB0005', 'OID002', 'F005', 5, 'The Nasi Lemak is very nice and tasty :P', '2023-03-16');

--Two Feedback for the same food by the same member
INSERT INTO Feedbacks VALUES --1st feedback
	('FID001', 'MB0005', 'OID001', 'F001', 5, 'The Nasi Lemak is very nice and tasty :P', '2023-03-16');

INSERT INTO Feedbacks VALUES --2nd feedback
	('FID002', 'MB0005', 'OID001', 'F001', 4, 'The Nasi Lemak is very nice and tasty :D', '2023-04-16');

--DROPPING TABLES
DROP TABLE Feedbacks;
DROP TABLE OrderStatus;
DROP TABLE CookedMeals;
DROP TABLE Orders;
DROP TABLE PaymentMethods;
DROP TABLE Payments;
DROP TABLE CartItems;
DROP TABLE Menu;
DROP TABLE MenuCategory;
DROP TABLE ShoppingCarts;
DROP TABLE Students;
DROP TABLE Lecturers;
DROP VIEW EncryptedMember_vw;
DROP TABLE Members;
DROP TABLE DispatchWorkers;
DROP TABLE Chefs;
DROP TABLE Managers;
DROP TABLE Employees;



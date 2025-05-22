USE DBM_Assignment;
--VIEWS
--Encrypted Members Table View
CREATE VIEW EncryptedMember_vw
WITH SCHEMABINDING
AS
SELECT MB.MemberID, MB.MemberName AS Name, MB.MemberGender AS Gender, DATEDIFF(YEAR, MB.MemberBirthDate, GETDATE()) AS Age, MB.RegisterDate,
REPLICATE('*', CHARINDEX('@', MB.Email, 0) - 1) + SUBSTRING(MB.Email, CHARINDEX('@', MB.Email, 0), LEN(MB.Email) - (CHARINDEX('@', MB.Email, 0) - 1)) AS Email, 
REPLICATE('*', LEN(MB.EmailPassword)) AS EmailPassword, MB.Allergies
FROM dbo.Members AS MB;

DROP VIEW EncryptedMember_vw;


--FUNCTIONS
--Number Of Orders By Member
CREATE FUNCTION memberNumOrder(@numOrder INT, @operator NVARCHAR(2))
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN(
	SELECT MB.MemberID, MB.MemberName AS Name, COUNT(O.OrderID) AS TotalOrder
	FROM dbo.Members AS MB
	LEFT JOIN dbo.Orders AS O
	ON O.MemberID = MB.MemberID
	GROUP BY MB.MemberID, MB.MemberName
	HAVING(
		(@operator = '=' AND COUNT(O.OrderID) = @numOrder) OR
		(@operator = '<' AND COUNT(O.OrderID) < @numOrder) OR
		(@operator = '>' AND COUNT(O.OrderID) > @numOrder) OR
		(@operator = '<=' AND COUNT(O.OrderID) <= @numOrder) OR
		(@operator = '>=' AND COUNT(O.OrderID) >= @numOrder)
	)
);

DROP FUNCTION memberNumOrder

--Determine Students and Lecturers
CREATE FUNCTION studentOrStaff(@memberID nvarchar(10))
RETURNS nvarchar(10)
AS
BEGIN
	DECLARE @role nvarchar(10)
	DECLARE @tpnumber nvarchar(10)
	DECLARE @staffID nvarchar(10)
	SET @tpnumber = (
		SELECT S.TPNumber
		FROM Members AS MB
		LEFT JOIN Students AS S
		ON S.MemberID = MB.MemberID
		LEFT JOIN Lecturers AS L
		ON L.MemberID = MB.MemberID
		WHERE MB.MemberID = @memberID
	);
	SET @staffID = (
		SELECT L.StaffID
		FROM Members AS MB
		LEFT JOIN Students AS S
		ON S.MemberID = MB.MemberID
		LEFT JOIN Lecturers AS L
		ON L.MemberID = MB.MemberID
		WHERE MB.MemberID = @memberID
	);

	IF (@tpnumber IS NOT NULL AND @staffID IS NULL)
	BEGIN
		 SET @role = 'Student'
	END
	ELSE IF (@staffID IS NOT NULL AND @tpnumber IS NULL)
	BEGIN
		 SET @role = 'Staff'
	END
	ELSE
	BEGIN
		SET @role = 'Unknown'
	END

	RETURN @role
END

DROP FUNCTION studentOrStaff


--TRIGGERS
--Number of Cooked Meals
CREATE TRIGGER count_cookedMeals ON CookedMeals
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON --supress the 'X rows affected' message
	BEGIN TRY
		DECLARE @mealID nvarchar(10)
		DECLARE @cartID nvarchar(10)
		DECLARE @foodID nvarchar(10)
		DECLARE @validn INT
		DECLARE @n INT
		SELECT @mealID = INSERTED.CookedMealsID, @cartID = INSERTED.CartID, @foodID = INSERTED.FoodID 
		FROM INSERTED

		SELECT @validn = Quantity 
		FROM CartItems
		WHERE CartID = @cartID AND FoodID = @foodID

		SELECT @n = COUNT(FoodID)
		FROM CookedMeals
		WHERE CartID = @cartID AND FoodID = @foodID
	
		--create user-defined error message, raise error in CATCH block if an error is caught
		IF @n > @validn 
		BEGIN
			DECLARE @EM NVARCHAR(100)
			DECLARE @El INT
			SET @EM ='Exceed Quantity Ordered Error: CartID = %s, FoodID = %s' --user-defined error message, %s: string placeholder
			SET @El = ERROR_LINE() --system-detected error line number
			--'16': user-reported/user-specified error severity to the system, there is 0-25
			--'1': user-speccified/user-reported error state value, there is 0-255
			--@cartID, @foodID: two string values to be substituted into @EM
			RAISERROR(@EM, 16, 1, @cartID, @foodID);

			DELETE FROM CookedMeals --delete wrongly inserted record
			WHERE CookedMealsID = @mealID
		END
	END TRY
	BEGIN CATCH --error handling
		DECLARE @ErrorMessage NVARCHAR(4000) 
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		DECLARE @ErrorLine INT

		SELECT
			@ErrorMessage = ERROR_MESSAGE(), --ERROR_MESSAGE() retrieves system-defined error message
			@ErrorSeverity = ERROR_SEVERITY(), --ERROR_SEVERITY() retrieves system-defined error severity (according to user-specified error severity)
			@ErrorState = ERROR_STATE(), --ERROR_STATE() retrieves system-defined error state (according yo user-specified error state)
			@ErrorLine = ERROR_LINE() --ERROR_LINE() retrieves the error line number

		PRINT('An Error Occured :( ' + @ErrorMessage) --print user-defined error message @EM defined in RAISERROR in TRY block
		--display system-generated error message
	END CATCH
END

DROP TRIGGER count_cookedMeals;

--Valid Feedback (Accurate MemberID, OrderID, and FoodID) & (One Member One Feedback Per Food)
CREATE TRIGGER valid_feedback ON Feedbacks
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON --surpress the 'X rows affected' message
	BEGIN TRY
		DECLARE @memberID NVARCHAR(10)
		DECLARE @orderID NVARCHAR(10)
		DECLARE @foodID NVARCHAR(10)
		DECLARE @feedbackID NVARCHAR(10)
		DECLARE @cartID NVARCHAR(10)
		DECLARE @n INT
		SELECT @feedbackID = INSERTED.FeedbackID, @memberID = INSERTED.MemberID, @orderID = INSERTED.OrderID, @foodID = INSERTED.FoodID
		FROM INSERTED

		--get cart id
		SELECT @cartID = O.CartID
		FROM Orders AS O
		WHERE O.MemberID = @memberID AND O.OrderID = @orderID

		--count the number of feedback given to the same food id by that member
		SELECT @n = COUNT(FB.FoodID)
		FROM Feedbacks AS FB
		WHERE FB.MemberID = @memberID AND FB.FoodID = @foodID

		DECLARE @EM NVARCHAR(100)
		DECLARE @El INT
		IF @orderID NOT IN(
			SELECT O.OrderID
			FROM Orders AS O
			WHERE O.MemberID = @memberID
		)
		OR @foodID NOT IN(
			SELECT CI.FoodID
			FROM CartItems AS CI
			WHERE CI.CartID = @cartID
		)
		BEGIN
			SET @EM = 'Invalid Order ID or FoodID Error: MemberID = %s, OrderID =%s, FoodID =%s'
			SET @El = ERROR_LINE()
			RAISERROR(@EM, 16, 1, @memberID, @orderID, @foodID);

			DELETE FROM Feedbacks
			WHERE FeedbackID = @feedbackID
		END

		ELSE IF @n > 1
		BEGIN
			SET @EM = 'One Member One Feedback Per Food Error: MemberID = %s, OrderID = %s, FoodID = %s'
			SET @El = ERROR_LINE()
			RAISERROR(@EM, 16, 1, @memberID, @orderID, @foodID);

			DELETE FROM Feedbacks
			WHERE FeedbackID = @feedbackID
		END
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		DECLARE @ErrorLine INT

		SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE(),
			@ErrorLine = ERROR_LINE();

		PRINT('An Error Occured :( ' + @ErrorMessage)
	END CATCH
END

DROP TRIGGER valid_feedback;

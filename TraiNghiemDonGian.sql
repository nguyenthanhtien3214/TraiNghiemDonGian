CREATE DATABASE TraiNghiemDonGian

USE TraiNghiemDonGian

CREATE TABLE Users(
	UserID INT IDENTITY(1,1) PRIMARY KEY,
	DisplayName NVARCHAR(255) NOT NULL,
	USERNAME VARCHAR(255) NOT NULL,
	PASSWORD_HASH VARBINARY(512) NOT NULL,
	BirthDATE DATE NOT NULL,
	CCCD VARCHAR(12) NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	Email VARCHAR(255) NOT NULL
);


CREATE TABLE PasswordResetTokens (
    TokenID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ResetToken UNIQUEIDENTIFIER NOT NULL,
    ExpiryDate DATETIME NOT NULL
);




-- Bảng lưu danh mục món ăn
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX) NULL
);

-- Bảng lưu món ăn
CREATE TABLE MonAn (
    FoodID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    ImageUrl NVARCHAR(255) NULL, -- Đường dẫn ảnh
    Price DECIMAL(10,2) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID)
);

-- Bảng lưu đơn hàng
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalPrice DECIMAL(10,2) NULL,
    Status NVARCHAR(50) DEFAULT N'Chờ xác nhận' -- Trạng thái đơn hàng
);

-- Bảng lưu chi tiết đơn hàng
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    FoodID INT FOREIGN KEY REFERENCES MonAn(FoodID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);

-- Bảng đánh giá món ăn
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    FoodID INT FOREIGN KEY REFERENCES MonAn(FoodID),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ReviewText NVARCHAR(MAX) NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5), -- Đánh giá 1-5 sao
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng lưu trạng thái đơn hàng (để cập nhật trạng thái cụ thể của mỗi đơn hàng)
CREATE TABLE OrderStatusLogs (
    StatusLogID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    Status NVARCHAR(50) NOT NULL, -- Ví dụ: "Đang làm món", "Đang giao hàng", "Hoàn thành"
    UpdatedAt DATETIME DEFAULT GETDATE()
);



INSERT INTO Users (DisplayName, Username, Password_Hash, BirthDate, CCCD, PhoneNumber, Email)
VALUES 
('Nguyen Van A', 'nguyenvana', HASHBYTES('SHA2_256', 'password123'), '1990-01-01', '123456789012', '0912345678', 'vana@example.com'),
('Tran Thi B', 'tranthib', HASHBYTES('SHA2_256', 'password456'), '1995-05-15', NULL, '0912345679', 'thib@example.com');

INSERT INTO Categories (Name, Description)
VALUES 
('Món chính', 'Các món ăn chính'),
('Tráng miệng', 'Các món tráng miệng'),
('Đồ uống', 'Các loại đồ uống');

select *from MonAn
INSERT INTO MonAn (Name, Description, ImageUrl, Price, CategoryID)
VALUES 
('Phở bò', 'Phở bò tái chín thơm ngon', '/images/pho_bo.jpg', 50000, 1),
('Bánh flan', 'Bánh flan mềm mịn', '/images/banh_flan.jpg', 20000, 2),
('Coca Cola', 'Nước ngọt Coca Cola lon', '/images/coca_cola.jpg', 15000, 3);


INSERT INTO Orders (UserID, TotalPrice, Status)
VALUES (1, 85000, N'Chờ xác nhận'); -- UserID = 1 là "Nguyen Van A"


INSERT INTO OrderDetails (OrderID, FoodID, Quantity, UnitPrice)
VALUES 
(1, 1, 1, 50000), -- Phở bò (FoodID = 1)
(1, 2, 1, 20000), -- Bánh flan (FoodID = 2)
(1, 3, 1, 15000); -- Coca Cola (FoodID = 3)


SELECT o.OrderID, o.OrderDate, o.TotalPrice, o.Status, 
       od.FoodID, m.Name AS FoodName, od.Quantity, od.UnitPrice
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN MonAn m ON od.FoodID = m.FoodID
WHERE o.UserID = 1; -- Lọc đơn hàng của UserID = 1


SELECT osl.OrderID, osl.Status, osl.UpdatedAt
FROM OrderStatusLogs osl
WHERE osl.OrderID = 1;

SELECT r.ReviewID, m.Name AS FoodName, u.DisplayName AS UserName, r.ReviewText, r.Rating, r.CreatedAt
FROM Reviews r
JOIN MonAn m ON r.FoodID = m.FoodID
JOIN Users u ON r.UserID = u.UserID;



INSERT INTO OrderStatusLogs (OrderID, Status)
VALUES 
(1, N'Đã xác nhận'),
(1, N'Đang làm món'),
(1, N'Đang giao hàng'),
(1, N'Hoàn thành');

UPDATE Orders
SET Status = N'Hoàn thành'
WHERE OrderID = 1;


INSERT INTO Reviews (FoodID, UserID, ReviewText, Rating)
VALUES 
(1, 1, N'Phở bò rất ngon, nước dùng đậm đà.', 5), -- Đánh giá cho Phở bò
(2, 2, N'Bánh flan mềm và ngọt vừa phải.', 4);    -- Đánh giá cho Bánh flan

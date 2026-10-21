-- 1) จำนวนผู้ใช้ตามสาขา
SELECT Department, COUNT(*) AS total_users
FROM User
GROUP BY Department
ORDER BY total_users DESC;

-- 2) รายการที่ยืมล่าสุด (ทุกรายการที่ยืมในวันล่าสุดของข้อมูล) พร้อมผู้ยืมและอุปกรณ์ที่ยืมไปด้วยกัน
SELECT Time.ItemID, User.Name, User.Surname,
       Time.BorrowDate, Time.BorrowTime,
       GROUP_CONCAT(Item.ItemName SEPARATOR ', ') AS items
FROM Time
JOIN User ON Time.ID = User.ID
JOIN Detail ON Time.ItemID = Detail.ItemID
JOIN Item   ON Detail.AssetID = Item.AssetID
WHERE Time.BorrowDate = (SELECT MAX(BorrowDate) FROM Time)
GROUP BY Time.ItemID, User.Name, User.Surname, Time.BorrowDate, Time.BorrowTime
ORDER BY Time.BorrowTime DESC;

-- 3) 5 อันดับอุปกรณ์ที่ถูกยืมมากที่สุด
SELECT Item.ItemName, COUNT(*) AS times_borrowed
FROM Detail
JOIN Item ON Detail.AssetID = Item.AssetID
GROUP BY Item.ItemName
ORDER BY times_borrowed DESC
LIMIT 5;

-- 4) การยืมอุปกรณ์ตามประเภท
SELECT Item.Category, COUNT(*) AS times_borrowed
FROM Detail
JOIN Item ON Detail.AssetID = Item.AssetID
GROUP BY Item.Category
ORDER BY times_borrowed DESC
LIMIT 5;

-- 5) ผู้ใช้ที่ยืมของบ่อยที่สุด (5 อันดับ ถ้าต้องการคนเดียวเปลี่ยน LIMIT 5 เป็น LIMIT 1)
SELECT User.ID, User.Name, User.Surname, User.Department,
       COUNT(*) AS borrow_count
FROM User
JOIN Time ON User.ID = Time.ID
GROUP BY User.ID, User.Name, User.Surname, User.Department
ORDER BY borrow_count DESC
LIMIT 5;

-- 6) จำนวนการยืมในแต่ละเดือน
SELECT DATE_FORMAT(BorrowDate, '%Y-%m') AS month, COUNT(*) AS borrow_count
FROM Time
GROUP BY month
ORDER BY month;

-- 7) วันที่มีคนยืมของมากที่สุด (5 อันดับแรก)
SELECT BorrowDate, COUNT(*) AS borrow_count
FROM Time
GROUP BY BorrowDate
ORDER BY borrow_count DESC
LIMIT 5;

-- 8) อุปกรณ์ที่มักถูกยืมไปคู่กัน (นับตามชื่ออุปกรณ์ 5 อันดับ)
--    ต้องใช้ Detail และ Item สองรอบ (d1/d2 คือชิ้นที่ 1 และ 2, i1/i2 คือชื่อของแต่ละชิ้น)
SELECT i1.ItemName AS item1, i2.ItemName AS item2,
       COUNT(DISTINCT d1.ItemID) AS times_together
FROM Detail d1
JOIN Detail d2 ON d1.ItemID = d2.ItemID AND d1.AssetID < d2.AssetID
JOIN Item i1 ON d1.AssetID = i1.AssetID
JOIN Item i2 ON d2.AssetID = i2.AssetID
WHERE i1.ItemName <> i2.ItemName
GROUP BY i1.ItemName, i2.ItemName
ORDER BY times_together ASC
LIMIT 5;

-- 9) อุปกรณ์ที่ถูกยืมน้อยที่สุด (5 อันดับ)
SELECT Item.ItemName, COUNT(Detail.ItemID) AS times_borrowed
FROM Item
LEFT JOIN Detail ON Item.AssetID = Detail.AssetID
GROUP BY Item.ItemName
ORDER BY times_borrowed ASC
LIMIT 5;

-- 10) รายการที่ยืมและคืนวันเดียวกัน
SELECT Time.ItemID, User.Name, User.Surname,
       Time.BorrowDate, Time.BorrowTime, Time.ReturnTime,
       GROUP_CONCAT(Item.ItemName SEPARATOR ', ') AS items
FROM Time
JOIN User ON Time.ID = User.ID
JOIN Detail ON Time.ItemID = Detail.ItemID
JOIN Item   ON Detail.AssetID = Item.AssetID
WHERE Time.ReturnDate = Time.BorrowDate
GROUP BY Time.ItemID, User.Name, User.Surname,
         Time.BorrowDate, Time.BorrowTime, Time.ReturnTime
ORDER BY Time.BorrowDate, Time.BorrowTime;
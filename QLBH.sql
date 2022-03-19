CREATE DATABASE QLBH;
GO
USE QLBH;

CREATE TABLE CUSTOMER (
	MaKH NVARCHAR(100) PRIMARY KEY,
	HoTen NVARCHAR(100),
	Email NVARCHAR(100),
	Phone INT,
	DiaChi NVARCHAR(100)
);

CREATE TABLE PRODUCT (
	MaSP NVARCHAR(100) PRIMARY KEY,
	TenSP NVARCHAR(100),
	MoTa NVARCHAR(100),
	GiaSP INT, 
	SoluongSP INT
);

CREATE TABLE PAYMENT (
	MaPTTT NVARCHAR(100) PRIMARY KEY,
	TenPTTT NVARCHAR(100),
	PhiTT INT
);

CREATE TABLE DONHANG (
	MaDH NVARCHAR(100) PRIMARY KEY,
	NgayDH DATE,
	Trangthai NVARCHAR(100),
	TongTien INT,
	MaKH NVARCHAR(100),
	MaSP NVARCHAR(100),
	FOREIGN KEY (MaKH) REFERENCES CUSTOMER(MaKH),
	FOREIGN KEY (MaSP) REFERENCES PRODUCT(MaSP)
);

CREATE TABLE CHITIETHOADON (
	MaCTHD NVARCHAR(100) PRIMARY KEY,
	SoLuong INT,
	GiaSPmua INT,
	ThanhTien INT,
	MaDH NVARCHAR(100),
	MaSP NVARCHAR(100),
	FOREIGN KEY (MaDH) REFERENCES DONHANG(MaDH),
	FOREIGN KEY (MaSP) REFERENCES PRODUCT(MaSP)
);

INSERT INTO PAYMENT VALUES
('TT01',N'Thanh toán khi nhận hàng',30000),
('TT02',N'Thanh toán qua thẻ',0);


INSERT INTO CUSTOMER VALUES 
('KH001',    N'Nguyễn Mi Xi',  N'ntm@gmail.com' ,	  '0354111111',   N'Đà Nẵng'        ),
('KH002',    N'Nguyễn Bô',     N'nguyenb@gmail.com',  '0313232323',   N'Huế'            ),
('KH003',    N'Nguyễn Snake',  N'nguyenc@gmail.com',  '0354333333',   N'Quảng Ngãi'     ),
('KH004',    N'Trần Dần'  ,    N'trana@gmail.com',    '0354444444',   N'Đà Nẵng'        ),
('KH005',    N'Trần Bộ Binh'  ,N'tranb@gmail.com',    '0354555555',   N'Quảng Nam'      );


INSERT INTO PRODUCT VALUES
('SP001',   N'Trứng',            N'Trứng vĩ 6 lốc',        20000 ,15),
('SP002',   N'Xúc Xích',         N'Bịch xúc xích 5 cây ',   10000 ,20),
('SP003',   N'Rau Xanh',         N'Hộp Rau Xanh', 9000 ,25),
('SP004',   N'Trái cây',         N'Trái cây đóng hộp',    150000, 50),
('SP005',   N'Nước Ngọt',         N'Lon Nước Ngọt cho mùa hè nóng bức',    10000, 50);



INSERT INTO DONHANG VALUES
('DH001', '2022-02-28', N'Đang giao' ,  40000, 'KH001', 'SP001'),
('DH002', '2022-01-27', N'Đang giao',  200000, 'KH002', 'SP002'),
('DH003','2022-03-05',N'Đang giao',120000,'KH001','SP003'),
('DH004','2022-03-06',N'Đã giao',240000,'KH001','SP003'),
('DH005','2022-03-06',N'Đã giao',150000,'KH001','SP004');


INSERT INTO CHITIETHOADON VALUES
('CT001',2,20000,40000,'DH001','SP001'),
('CT002',2,100000,200000,'DH002','SP002'),
('CT003',1,120000,120000,'DH003','SP003'),
('CT004',2,120000,240000,'DH004','SP003'),
('CT005',1,150000,150000,'DH005','SP004');

/* SQL NANG CAO */
-- Câu 1 SQL - Thảo: Hiển thị thông tin khách hàng có họ Nguyễn và địa chỉ ở Đà Nẵng
SELECT * FROM CUSTOMER WHERE HoTen LIKE N'Nguyễn%' and DiaChi LIKE N'Đà Nẵng'

-- Câu 2  SQL - Thảo: Hiển thị thông tin khách hàng có thông tin đơn hàng là đang giao\
SELECT DISTINCT c.* FROM CUSTOMER c JOIN DONHANG d on c.MaKH = d.MaKH 
WHERE d.Trangthai LIKE N'Đang giao'

/* VIEW */

-- Câu 3 VIEW - Mi : Hiển thị thông tin của khách hàng và đơn hàng đã mua 
CREATE VIEW V_DONHANG
AS
SELECT KH.MaKH,KH.DiaChi,KH.HoTen, DH.MaDH, DH.Trangthai, DH.TongTien FROM CUSTOMER KH JOIN DONHANG DH ON KH.MaKH = DH.MaKH 
GO

SELECT * FROM V_DONHANG

GO

-- Câu 4 VIEW - Mi: Thông tin những đơn hàng được đặt trong năm nay

CREATE VIEW CUSTOMER_VIEW AS
SELECT MaKH, HoTen, Email, Phone, DiaChi
FROM  CUSTOMER;

SELECT * FROM CUSTOMER_VIEW

GO



/* Stored */ 

-- Câu 5 PROC - Trọng: Truy xuất thông tin sản phẩm theo mã sản phẩm
CREATE PROCEDURE sp_ThongtinSP 
@MaSP NVARCHAR(100)
AS
BEGIN
SELECT * FROM PRODUCT WHERE MaSP = @MaSP
END
GO
EXEC sp_ThongtinSP'SP003'

EXEC sp_ThongtinSP'SP007'

-- Câu 6 PROC - Toàn : Kiểm tra trạng thái của một đơn hàng
CREATE PROC sp_Status(@mahang NVARCHAR(100))
AS
BEGIN
     IF(@mahang NOT IN(SELECT MaDH FROM DONHANG))
	 PRINT N'Đơn hàng không tồn tại.'
	 ELSE
	    BEGIN
	       DECLARE @trangthai NVARCHAR(100)
	       SELECT @trangthai=Trangthai
	       FROM DONHANG
	       WHERE MaDH = @mahang
	       PRINT @mahang+N' có trạng thái là: '+@trangthai
	     END
END
GO
EXEC sp_Status 'DH006'


 -- Câu 7 PROC - Hoàn Vũ :  liet ke MaDH, TongTien tu bang DONHANG bat dau tu 1 ngay bat ky nhap vao tro di --
create procedure sp_orderInfo
as
BEGIN
 select ct.MaKH, ct.HoTen, dh.MaDH, dh.Trangthai, dh.TongTien 
 from dbo.DONHANG dh LEFT JOIN dbo.CUSTOMER ct
 ON dh.MaKH = ct.MaKH
 where Trangthai like N'Đã giao' 
 order by MaDH
 END
 GO

 exec sp_orderInfo


---- Câu 8: PROCEDURE - Hưng Tổng sl bán ra của sp bất kì
CREATE PROCEDURE Proc_PRODUCT (
	@MaSP NVARCHAR(100)
)
AS
BEGIN
    SELECT pd.MaSP, pd.TenSP, SUM(od.SoLuong) AS Total_PRODUCT
	FROM dbo.PRODUCT pd LEFT JOIN dbo.CHITIETHOADON od
	ON od.MaSP = pd.MaSP
	WHERE pd.MaSP = @MaSP
	GROUP BY pd.MaSP, pd.TenSP
END
GO
EXECUTE dbo.Proc_PRODUCT @MaSP = 'SP001' 

SELECT * FROM dbo.PRODUCT
SELECT * FROM dbo.CHITIETHOADON

go




/* FUNCTION */
-- Câu 9 FUNCTION - Hoàn Vũ: liet ke MaDH, TongTien tu bang DONHANG bat dau tu 1 ngay bat ky nhap vao tro di --
CREATE FUNCTION uf_donhang(@NgayDH DATE)
RETURNS TABLE
AS
RETURN(
SELECT DONHANG.MaDH, DONHANG.TongTien FROM DONHANG WHERE @NgayDH <= DONHANG.NgayDH)

SELECT * FROM uf_donhang('2022-02-28')

-- Câu 10 FUNCTION - Toàn: Tổng giá trị tiền đã mua của khách hàng 
CREATE FUNCTION uf_tienDaMua (@MaKH nvarchar(100))
RETURNS INT
AS
BEGIN
	DECLARE @TongTien INT
	SELECT @TongTien = SUM(CHITIETHOADON.ThanhTien)
	FROM CUSTOMER 
		JOIN DONHANG ON CUSTOMER.MaKH=DONHANG.MaKH
		JOIN CHITIETHOADON ON CHITIETHOADON.MaDH=DONHANG.MaDH
	WHERE CUSTOMER.MaKH=@MaKH 
	RETURN @TongTien
END
GO

SELECT MaKH,dbo.uf_tienDaMua(MaKH) AS [Tiền hàng đã mua] FROM CUSTOMER

-- Câu 11 FUNCTION - Trọng: Hiển thị thông tin khách hàng đặt hàng nhiều nhất
CREATE FUNCTION uf_muaNhieuNhat ()
RETURNS TABLE
AS
	RETURN SELECT CUSTOMER.*
	       FROM CUSTOMER
		   JOIN ( SELECT TOP 1 CUSTOMER.MaKH, Count(*) as soLuongDat FROM CUSTOMER JOIN DONHANG ON CUSTOMER.MaKH=DONHANG.MaKH GROUP BY CUSTOMER.MaKH) 
		   AS t ON t.MaKH= CUSTOMER.MaKH 
GO

SELECT * FROM dbo.uf_muaNhieuNhat()

-- Câu 12 FUNCTION - Hưng . Viết hàm trả về 1 giá trị những đơn hàng từ 100000 trở lên
CREATE FUNCTION udf_hoadon
(
  @ThanhTien INT
  )
  RETURNS BIT
  AS
  BEGIN
  DECLARE @hoadon BIT; 
  if @ThanhTien >= 100000
     SET @hoadon =1 
	 ELSE 
	 SET @hoadon = 0;
	 RETURN @hoadon;
  END
  go

  SELECT * FROM
(SELECT *, dbo.udf_hoadon(ThanhTien) AS HOADON FROM CHITIETHOADON ) AS A
 WHERE HOADON = 1;



--TUẦN 2 : TRIGGER - EVENT

--Thảo
	--Trigger: Tạo Trigger kiểm tra khi thêm đơn hàng tổng tiền phải lớn hơn 0
CREATE TRIGGER	ADD_HOADON 
on DONHANG
for insert	
as 
 if	(select TongTien from inserted) < 0
 begin 
 print 'Tong tien phai lon hon 0'
 rollback tran
end

insert into DONHANG values ('DH006','2022-12-22','Dang giao','-100','KH002','SP003')

	--Event: tạo event thêm đơn hàng
CREATE EVENT ADD_DONHANG
    ON SCHEDULE AT CURRENT_TIMESTAMP
    DO
      INSERT INTO DONHANG VALUES ('DH006', '2022-03-19',N'Đang giao','KH003','SP004'
);

--Toàn
	--Trigger: tạo trigger k cho phép thêm số lượng của sản phẩm nhỏ hơn 0
create trigger add_product
on PRODUCT
for insert
as
	if ( select SoluongSP from inserted) < 0
	begin
	print 'So luong san pham phai lon hon 0'
	rollback tran
end

insert into PRODUCT values ('SP006','Sp6','san pham 6','30000','-10')

	--Event: tạo event thêm product sau 10s
CREATE EVENT ADD_PRODUCT
    ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 10 SECOND
    DO
      INSERT INTO PRODUCT VALUES ('SP006', N'Sản phẩm 6',N'Gồm sản phẩm 6','200000','30'
);

--Kim Mi
-- TẠO TRIGGER trigg_1 kiểm tra MADH có tồn tại trong bảng DONHANG khi UPDATE ---
alter TRIGGER trigg_1
ON DONHANG
for UPDATE
AS
BEGIN
	IF NOT EXISTS (SELECT MaDH FROM inserted)
	begin
		ROLLBACK
		PRINT N'Không tồn tại mã đơn hàng'
		RETURN 
	end
END

update DONHANG SET Trangthai = N'thành công' WHERE MaDH = 'DH003'
select * from DONHANG

-- tạo event chèn dữ liệu vào bảng `khachhang`--

create event event_1
on schedule at current_timestamp()
do 
	INSERT INTO `khachhang` VALUES ( 'KH006', 'tran mai', 'tranmai@gmail.com', '012121211', 'Quang Nam');
 select * from `khachhang`   ;

 -- Hoàn vũ
 -- TRIGGER: thay doi so luong san pham ton kho sau khi dat hang --
CREATE TRIGGER UTG_SOLUONG
ON dbo.CHITIETHOADON FOR INSERT
AS
BEGIN
	DECLARE @SLC INT;
	DECLARE @SLB INT;
	SELECT @SLB=Inserted.SoLuong FROM Inserted;
	SELECT @SLC=dbo.PRODUCT.SoluongSP 
		FROM Inserted, dbo.PRODUCT 
		WHERE Inserted.MaSP=dbo.PRODUCT.MaSP;
	IF(@SLB>@SLC)
	BEGIN
		ROLLBACK TRANSACTION
		PRINT 'So luong SP khong du'
	END
	ELSE
	BEGIN
		UPDATE dbo.PRODUCT SET SoluongSP=SoluongSP-@SLB 
		FROM dbo.PRODUCT, Inserted 
		WHERE Inserted.MaSP=dbo.PRODUCT.MaSP;
	END
END
SELECT * FROM PRODUCT
INSERT INTO dbo.CHITIETHOADON
	(MaCTHD ,SoLuong ,GiaSPmua ,ThanhTien,MaDH,MaSP)
VALUES ('CT009',55,20000,40000,'DH001','SP004')

-- EVENT: them don hang --
CREATE SCHEMA QLBH;
USE QLBH;

SET GLOBAL event_scheduler = ON;

CREATE TABLE `DONHANG` (
	MaDH VARCHAR(100) PRIMARY KEY,
	NgayDH DATE,
	Trangthai VARCHAR(100),
	TongTien INT,
	MaKH VARCHAR(100),
	MaSP VARCHAR(100)
);
INSERT INTO `DONHANG` VALUES
('DH001', '2022-02-28', 'Đang giao' ,  40000, 'KH001', 'SP001'),
('DH002', '2022-01-27', 'Đang giao',  200000, 'KH002', 'SP002'),
('DH003','2022-03-05','Đang giao',120000,'KH001','SP003'),
('DH004','2022-03-06','Đã giao',240000,'KH001','SP003'),
('DH005','2022-03-06','Đã giao',150000,'KH001','SP004');

CREATE EVENT EV_DONHANG
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
ON COMPLETION PRESERVE
DO
   INSERT INTO `DONHANG`(MaDH,NgayDH,Trangthai,TongTien,MaKH,MaSP)
   VALUES('DH007','2022-03-06','Đã giao',150000,'KH001','SP002');

SHOW EVENTS FROM QLBH;
SELECT * FROM QLBH.DONHANG;

--Hưng
--TRIGGER GIỚI HẠN SỐ LƯỢNG SẢN PHẨM THÊM VÀO TỐI ĐA 10 SẢN PHẨM: 


CREATE TRIGGER LIMIT
ON dbo.PRODUCT FOR INSERT 
AS 
BEGIN
DECLARE @SP INT;
SELECT @SP = dbo.PRODUCT.SoLuongSP FROM dbo.PRODUCT;
IF @SP>10
BEGIN
RAISERROR(N'VƯỢT QUÁ SỐ LƯỢNG SẢN PHẦM CHO PHÉP',16,1)
ROLLBACK TRANSACTION

END

END

go

-- Tạo 1 event tự động cập nhật số lượng SP trong 
-- bảng SANPHAM mỗi loại hàng đều là 100 sp sau 0h sáng hằng ngày
   CREATE EVENT EV_CAPNHAT
   ON schedule
   EVERY '1' DAY
   STARTS '2022-03-18 00:00:00'
   ON COMPLETION PRESERVE
   DO
   UPDATE PRODUCT SP SET SoLuongSP = 100
   WHERE MSP  lIKE 'SP%'

--Tuyến
------------------------------------------------------------------------------------------
-- Trigger : Khi thêm một sản phẩm thì số lượng không quá 100
CREATE TRIGGER Trg_CHECK 
ON PRODUCT 
FOR INSERT
AS
DECLARE @SoLuong int
SELECT @SoLuong = SoluongSP FROM inserted
IF(@SoLuong > 100)
BEGIN
PRINT N'Số lượng sản phẩm lớn hơn 100'
ROLLBACK TRAN
END
--test 1
INSERT INTO PRODUCT VALUES ('SP006',N'Sữa tươi',N'Sữa Milo thơm ngon',10000,110);
--test 2
INSERT INTO PRODUCT VALUES ('SP006',N'Sữa tươi',N'Sữa Milo thơm ngon',10000,90);

---------------------------------------------------------------------------------------------------------
--tạo event sau 5s thêm 1 khách hàng
CREATE EVENT event_Add
    ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 5 SECOND
	ON COMPLETION PRESERVE
    DO
      insert into	CUSTOMER values ('KH006',    N'Nguyễn Mi Xo',  N'nttm@gmail.com' ,	  '0354111119',   N'Đà Nẵng')
SELECT * FROM CUSTOMER

-- Tạ Ngọc Trọng
-- Trigger : Kiểm tra email của khách hàng
CREATE TRIGGER Trg_CHECK_KH 
ON CUSTOMER 
FOR INSERT
AS
BEGIN
  DECLARE @email NVARCHAR(100), @phone NVARCHAR(100)
  SELECT @email = i.email FROM inserted AS i;

  IF (@email NOT LIKE '%@%')
  BEGIN
    PRINT 'Email khong hop le'
    ROLLBACK TRAN
    RETURN
  END;
END;
--test 1
INSERT INTO CUSTOMER VALUES ('KH006', 'Ta Ngoc Trong', 'ngtrong.gmail.com', '0123456789', 'Da Nang');
--test 2
INSERT INTO CUSTOMER VALUES ('KH006', 'Ta Ngoc Trong', 'ngtrong@gmail.com', '0123456789', 'Da Nang');
--------------------------------------------------------------------------------------------------------------
-- Event: Tạo 1 event cứ mỗi 15 ngày sẽ cập nhật lại  GiaSP của bảng PRODUCT 1 lần với GiaSP cố định là 1000 trên mỗi SP. 
create EVENT EV_UPDATE   
ON SCHEDULE EVERY 15 day
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 MONTH
DO
UPDATE PRODUCT SET GiaSP = GiaSP + 1000;
      
select * from PRODUCT;

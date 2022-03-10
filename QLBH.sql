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
-- SQL: Hiển thị thông tin khách hàng có họ Nguyễn và địa chỉ ở Đà Nẵng
SELECT * FROM CUSTOMER WHERE HoTen LIKE N'Nguyễn%' and DiaChi LIKE N'Đà Nẵng'

-- SQL: Hiển thị thông tin khách hàng có thông tin đơn hàng là đang giao\
SELECT DISTINCT c.* FROM CUSTOMER c JOIN DONHANG d on c.MaKH = d.MaKH 
WHERE d.Trangthai LIKE N'Đang giao'

/* VIEW */

-- VIEW: Hiển thị thông tin của khách hàng và đơn hàng đã mua 
CREATE VIEW V_DONHANG
AS
SELECT KH.MaKH,KH.DiaChi,KH.HoTen, DH.MaDH, DH.Trangthai, DH.TongTien FROM CUSTOMER KH JOIN DONHANG DH ON KH.MaKH = DH.MaKH 
GO

SELECT * FROM V_DONHANG

GO

-- VIEW: Thông tin những đơn hàng được đặt trong năm nay
CREATE VIEW V_Infooder
AS 
    SELECT DISTINCT CUSTOMER.MaKH, 
	DONHANG.MaDH, DONHANG.MaSP, DONHANG.NgayDH, DONHANG.TongTien, 
	DONHANG.Trangthai, CHITIETHOADON.SoLuong
	FROM CUSTOMER
		JOIN DONHANG ON DONHANG.MaKH=CUSTOMER.MaKH
		JOIN CHITIETHOADON ON CHITIETHOADON.MaDH=DONHANG.MaDH
		JOIN PRODUCT ON PRODUCT.MaSP=CHITIETHOADON.MaSP
	WHERE YEAR(DONHANG.NgayDH) = YEAR(GETDATE())
GO

SELECT * FROM V_Infooder

GO

-- VIEW: Thông tin khách hàng
CREATE VIEW CUSTOMER_VIEW AS
SELECT MaKH, HoTen, Email, Phone, DiaChi
FROM  CUSTOMER;




/* STORED */ 

-- STORED Tổng sl bán ra của sp bất kì
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


-- STORED: Truy xuất thông tin sản phẩm theo mã sản phẩm
CREATE PROCEDURE sp_ThongtinSP 
@MaSP NVARCHAR(100)
AS
BEGIN
SELECT * FROM PRODUCT WHERE MaSP = @MaSP
END
GO
EXEC sp_ThongtinSP'SP003'

EXEC sp_ThongtinSP'SP007'

-- STORED: Kiểm tra trạng thái của một đơn hàng
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


-- STORED: thông tin đơn hàng với trạng thái đã giao
 create procedure orderInfo as
 select * from DONHANG where Trangthai like N'Đã giao' order by MaDH

 exec orderInfo

 -- STORED:  liet ke MaDH, TongTien tu bang DONHANG bat dau tu 1 ngay bat ky nhap vao tro di --
CREATE PROC sp_donhang 
	@NgayDH DATE
AS
BEGIN
	SELECT DONHANG.MaDH, DONHANG.TongTien FROM DONHANG WHERE @NgayDH <= DONHANG.NgayDH
END
EXEC dbo.sp_donhang @NgayDH= '2022-02-28'





/* FUNCTION */
-- FUNCTION: liet ke MaDH, TongTien tu bang DONHANG bat dau tu 1 ngay bat ky nhap vao tro di --
CREATE FUNCTION uf_donhang(@NgayDH DATE)
RETURNS TABLE
AS
RETURN(
SELECT DONHANG.MaDH, DONHANG.TongTien FROM DONHANG WHERE @NgayDH <= DONHANG.NgayDH)

SELECT * FROM uf_donhang('2022-02-28')

-- FUNCTION: Tổng giá trị tiền đã mua của khách hàng 
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

-- FUNCTION: Hiển thị thông tin khách hàng đặt hàng nhiều nhất
CREATE FUNCTION uf_muaNhieuNhat ()
RETURNS TABLE
AS
	RETURN SELECT CUSTOMER.*
	       FROM CUSTOMER
		   JOIN ( SELECT TOP 1 CUSTOMER.MaKH, Count(*) as soLuongDat FROM CUSTOMER JOIN DONHANG ON CUSTOMER.MaKH=DONHANG.MaKH GROUP BY CUSTOMER.MaKH) 
		   AS t ON t.MaKH= CUSTOMER.MaKH 
GO

SELECT * FROM dbo.uf_muaNhieuNhat()

-- FUNCTION: Viết hàm trả về 1 giá trị những đơn hàng từ 100000 trở lên
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

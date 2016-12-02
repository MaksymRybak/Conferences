-- =============================================
-- Author:      Gianluca Sartori - @spaghettidba
-- Create date: 2016-09-07
-- Description: Setup
-- =============================================
USE tempdb;
GO

IF OBJECT_ID('Customers')  IS NOT NULL DROP TABLE Customers;
IF OBJECT_ID('Orders')     IS NOT NULL DROP TABLE Orders;


CREATE TABLE Customers (
	 customer_id   INT            NOT NULL PRIMARY KEY CLUSTERED
	,name          NVARCHAR(100)  NOT NULL
	,address       NVARCHAR(50)   NOT NULL
	,ZIP           CHAR(5)        NOT NULL
	,city          NVARCHAR(50)   NOT NULL
	,state_id      CHAR(2)        NOT NULL
	,country_id    CHAR(3)        NOT NULL
)
GO


CREATE TABLE Orders (
	 order_id      INT            NOT NULL PRIMARY KEY CLUSTERED
	,order_date    DATETIME       NOT NULL 
	,customer_id   INT            NOT NULL 
	,status_id     CHAR(2)        NOT NULL 
	,priority_id   TINYINT        NOT NULL
)
GO


INSERT INTO Customers  VALUES (1, 'Scarpamondo',  'via XXIV Maggio 121/F', '31015', 'Conegliano', 'TV', 'IT'),
                              (2, 'Scarpa Sport', 'via del palleggio 231', '56365', 'Verona',     'VR', 'IT'),
							  (3, 'Il duca',      'via dei nobili 12/A',   '64533', 'Pordenone',  'PN', 'IT');

INSERT INTO Orders     VALUES (1, '20160319', 1, 'CO', 1),
                              (2, '20160401', 1, 'IN', 4),
							  (3, '20160521', 1, 'AN', 2),
							  (4, '20160611', 1, 'CO', 1),
							  (5, '20160213', 2, 'SO', 1),
							  (6, '20160710', 2, 'CO', 1),
							  (7, '20160912', 2, 'IN', 1);



--SQL Saturday 566. Parma 26 november 2016. 
--2. String split 

--demo is running on a database called Test. Change destination as you prefer
USE Test;
GO

--Create data table
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RegionList' AND schema_id = SCHEMA_ID('dbo')) 
DROP TABLE dbo.ListaRegioni;

CREATE TABLE dbo.RegionList (
	RegionId smallint IDENTITY(1,1) PRIMARY KEY,
	RegionName nvarchar(75) NOT NULL,
	Province nvarchar(4000) NOT NULL
);
GO

INSERT INTO dbo.RegionList(RegionName, Province)
VALUES (N'Valle d''Aosta',N'Aosta'),
(N'Piemonte',N'Torino|Asti|Vercelli|Novara|Cuneo|Verbano-Cusio-Ossola|Alessandria|Biella'),
(N'Liguria',N'Genova|Imperia|Savona|La Spezia'),
(N'Lombardia',N'Milano|Varese|Como|Sondrio|Bergamo|Brescia|Como|Cremona|Lecco|Lodi|Mantova|Monza Brianza|Pavia'),
(N'Veneto',N'Venezia|Belluno|Padova|Rovigo|Treviso|Verona|Vicenza'),
(N'Trentino Alto Adige',N'Trento|Bolzano'),
(N'Friuli Venezia Giulia',N'Trieste|Gorizia|Pordenone|Udine'),
(N'Emilia-Romagna',N'Bologna|Ferrara|Forlì-Cesena|Modena|Parma|Piacenza|Ravenna|Reggio nell''Emilia|Rimini'),
(N'Toscana',N'Firenze|Arezzo|Grosseto|Livorno|Lucca|Massa-Carrara|Pisa|Pistoia|Prato|Siena'),
(N'Umbria',N'Perugia|Terni'),
(N'Marche',N'Ancona|Ascoli Piceno|Fermo|Macerata|Pesaro e Urbino'),
(N'Lazio',N'Roma|Frosinone|Latina|Rieti|Viterbo'),
(N'Abruzzo',N'L''Aquila|Chieti|Pescara|Teramo'),
(N'Molise',N'Campobasso|Isernia'),
(N'Campania',N'Napoli|Avellino|Benevento|Caserta|Salerno'),
(N'Basilicata',N'Potenza|Matera'),
(N'Calabria',N'Catanzaro|Cosenza|Crotone|Reggio di Calabria|Vibo Valentia'),
(N'Puglia',N'Bari|Barletta-Andria-Trani|Brindisi|Foggia|Lecce|Taranto'),
(N'Sicilia',N'Palermo|Agrigento|Caltanissetta|Catania|Enna|Messina|Palermo|Ragusa|Siracusa|Trapani'),
(N'Sardegna',N'Cagliari|Carbonia-Iglesias|Medio Campidano|Nuoro|Ogliastra|Olbia-Tempio|Oristano|Sassari')
;

SELECT * FROM dbo.RegionList;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ufn_Split') AND type = 'IF')
DROP FUNCTION dbo.ufn_Split;
GO
/**************************************************************************************
inline TVF to split the string. The function accepts two parameters: 
the string to be splitted and text separator
***************************************************************************************/
CREATE FUNCTION [dbo].[ufn_Split](@String NVARCHAR(4000),@Delimiter NCHAR(1)
)
RETURNS TABLE
AS
RETURN
(
    WITH Split(stpos,endpos)
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1)
            FROM Split
            WHERE endpos > 0
    )
    SELECT 'Id' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'Data' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split
);
GO

--APPLY the function to the table, to split the row into columns
SELECT 
	rl.RegionName,
	split.Id,
	split.Data
FROM dbo.RegionList rl 
CROSS APPLY dbo.ufn_Split(Province,'|') AS split;
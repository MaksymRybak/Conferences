--SQL Saturday 566. Parma 26 november 2016. 
--11. XML Shredding

USE Test;
GO

DECLARE @XmlString XML;
SET @XMLstring = '
	<Regioni>
		<Regione name = "Veneto">
			<Province>
				<Provincia name = "Belluno" sigla = "BL"/> 
				<Provincia name = "Padova" sigla = "PD"/>
				<Provincia name = "Rovigo" sigla = "RO"/>
				<Provincia name = "Treviso" sigla = "TV"/> 
				<Provincia name = "Verona" sigla = "VR"/>
				<Provincia name = "Venezia" sigla = "VE"/>
				<Provincia name = "Vicenza" sigla = "VI"/>
			</Province>
		</Regione>	
		<Regione name = "Campania">
			<Province>
				<Provincia name = "Benevento" sigla = "BN"/> 
				<Provincia name = "Caserta" sigla = "CE"/>
				<Provincia name = "Napoli" sigla = "NA"/>
				<Provincia name = "Avellino" sigla = "AV"/> 
				<Provincia name = "Salerno" sigla = "SA"/>
			 </Province>
		</Regione>    
	</Regioni>
'
;
--SELECT @XmlString;

--Simple CROSS APPLY at the root level.  
--SELECT 
--	Regione.rowset.value('@name', 'NVARCHAR(20)') AS rr
--FROM @XmlString.nodes('./Regioni/Regione') Regione (rowset)
--	CROSS APPLY Regione.rowset.nodes('.') Provincia (rowset)

--The first CROSS APPLY returns the objects at the root level 
--and passes the input to the second CROSS APPLY at a deeper level
SELECT 
	lista.NomeRegione,
	lista.NomeProvincia,
	lista.SiglaProvincia
FROM @XmlString.nodes('./Regioni/Regione') Regione (rowset)
	CROSS APPLY Regione.rowset.nodes('./Province/Provincia') Provincia (rowset)
	CROSS APPLY (
		SELECT 
			Regione.rowset.value('@name', 'NVARCHAR(20)'),
			Provincia.rowset.value('@name', 'NVARCHAR(20)'),
			Provincia.rowset.value('@sigla', 'CHAR(2)')
	) lista (NomeRegione,NomeProvincia,SiglaProvincia)

----------------------------------------------------------------------------------------------------------------------
USE AdventureWorks2014;
GO

--In the Product Model table there is the field Instructions in XML format
SELECT * FROM Production.ProductModel WHERE ProductModelID = 7

SELECT 
	p.Name,
	C.query('.') AS result 
FROM Production.ProductModel p
OUTER APPLY Instructions.nodes('
	declare namespace ns = "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions";
	/ns:root/ns:Location') AS T(C)


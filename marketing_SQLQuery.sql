SELECT * FROM dbo.products;

SELECT MIN(Price) FROM dbo.products;

SELECT MAX(Price) FROM dbo.products;

SELECT ProductID,ProductName,Price,
	CASE
		WHEN Price<50 THEN 'Low'
		WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
		ELSE 'HIGH'
	END AS PriceCategory
From dbo.products;

SELECT * FROM dbo.customers;

SELECT * FROM dbo.geography;

SELECT c.CustomerID,c.CustomerName,c.Email,c.Gender,C.Age,g.Country,g.City
FROM dbo.customers as c
LEFT JOIN
dbo.geography as g
ON c.GeographyID = g.GeographyID;

SELECT * FROM dbo.customer_reviews;

SELECT ReviewID,CustomerID,ProductID,ReviewDate,Rating,
		REPLACE(ReviewText,'  ',' ') AS ReviewText
FROM dbo.customer_reviews;

SELECT * FROM dbo.engagement_data;

SELECT EngagementID,ContentID,CampaignID,ProductID,
		UPPER(REPLACE(ContentType,'Socialmedia','Social Media')) AS ContentType,
		LEFT(ViewsClicksCombined,CHARINDEX('-',ViewsClicksCombined)-1) AS Views,
		RIGHT(ViewsClicksCombined,LEN(ViewsClicksCombined)-CHARINDEX('-',ViewsClicksCombined)) AS Clicks,
		Likes,
		FORMAT(CONVERT(DATE,EngagementDate),'dd.mm.yyyy') AS EngagementDate
FROM dbo.engagement_data WHERE ContentType != 'newsletter';

SELECT * FROM dbo.customer_journey;

WITH DuplicateRecords AS(
	SELECT
		JourneyID,
		CustomerID,
		ProductID,
		VisitDate,
		Stage,
		Action,
		Duration,
		ROW_NUMBER() OVER(
		PARTITION BY CustomerID,ProductID,VisitDate,Stage,Action
		ORDER BY JourneyID) AS Row_num
		FROM dbo.customer_journey
)
SELECT * FROM DuplicateRecords
ORDER BY JourneyID;

SELECT JourneyID,CustomerID,ProductID,VisitDate,Stage,Action,
COALESCE(Duration,Avg_Duration) as Duration
FROM(
SELECT JourneyID,CustomerID,ProductID,VisitDate,
UPPER(Stage) AS Stage,
Action,Duration,
AVG(Duration) OVER(PARTITION BY VisitDate) AS avg_Duration,
ROW_NUMBER() OVER(
PARTITION BY CustomerID,ProductID,VisitDate,UPPER(Stage),Action
ORDER BY JourneyID) AS Row_num
FROM dbo.customer_journey) AS subquery WHERE Row_num=1;


CREATE OR REPLACE VIEW summary AS 
SELECT 
C.*,
A.favorite_album,A.favorite_artist,
G.favorite_genre
FROM (
SELECT c.CustomerID, c.Country,c.State,c.city,
MAX(i.InvoiceDate) AS recent_purchase, 
COUNT(DISTINCT(i.InvoiceId)) AS Frequency, 
SUM(ROUND(il.UnitPrice*il.Quantity,2)) AS total_spending,
NTILE(5) OVER (ORDER BY MAX(i.InvoiceDate)DESC) AS recency_group,
        NTILE(5) OVER (ORDER BY COUNT(DISTINCT(i.InvoiceId)) DESC) AS frequency_group,
        NTILE(5) OVER (ORDER BY SUM(ROUND(il.UnitPrice*il.Quantity,2)) DESC) AS monetary_group,
COUNT(DISTINCT(t.TrackId)) AS Track_bought,COUNT(DISTINCT(a.AlbumId)) AS Album_covered, 
COUNT(DISTINCT(ar.ArtistId)) AS number_artist_interested
FROM customer c
JOIN invoice i ON c.CustomerId=i.CustomerId
JOIN invoiceline il ON i.InvoiceId=il.InvoiceId
JOIN track t ON il.TrackId=t.TrackId
JOIN album a ON t.AlbumId=a.AlbumId
JOIN artist ar ON a.ArtistId=ar.ArtistId
GROUP BY c.CustomerID
) C 
LEFT JOIN (
SELECT * 
FROM (
SELECT 
c.CustomerId,a.Title AS favorite_album,ar.name AS favorite_artist,
ROW_NUMBER()OVER(PARTITION BY c.CustomerId ORDER BY COUNT(*) DESC ) AS rn 
FROM customer c
JOIN invoice i ON c.CustomerId=i.CustomerId
JOIN invoiceline il ON i.InvoiceId=il.InvoiceId
JOIN track t ON il.TrackId=t.TrackId
JOIN album a ON t.AlbumId=a.AlbumId
JOIN artist ar ON a.ArtistId=ar.ArtistId
GROUP BY c.CustomerId,a.Title,ar.name
) t 
WHERE rn=1
) A ON C.CustomerId=A.CustomerId
LEFT JOIN (
SELECT * 
FROM (
SELECT 
c.CustomerId,g.Name AS favorite_genre,
ROW_NUMBER()OVER(PARTITION BY c.CustomerId ORDER BY COUNT(*) DESC ) AS rn 
FROM customer c
JOIN invoice i ON c.CustomerId=i.CustomerId
JOIN invoiceline il ON i.InvoiceId=il.InvoiceId
JOIN track t ON il.TrackId=t.TrackId
JOIN genre g on t.GenreId=g.GenreId
GROUP BY c.CustomerId,g.Name
) t 
WHERE rn=1
) G ON C.CustomerId=G.CustomerId;

SELECT*FROM summary;


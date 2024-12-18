/* Requirement 1: Client wants to know which generes of music are popular, and within these geners which albums have the most tracks. 
Also, filter out any tracks that are too short for dancing.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
genres: Columns are GenreId, Name (genre name)
albums: Colums are AlbumId, Title, ArtistId*/

select * from tracks
    limit 5;

select * from genres
    limit 2;

---to find out which genres have most tracks (note top 3)
select GenreId, COUNT(*) AS Genre_Count
    from tracks
    GROUP BY GenreId
    ORDER BY COUNT(*) DESC; -- 1, 7, 3

---to find names of top 3 genres (by number of tracks)
select Name, GenreId from genres
    WHERE GenreId IN (1,3,7);

---to find out top 3 albumId (by number of tracks) for top 3 Genres
select AlbumId, COUNT(*) AS Track_Count, GenreId
    FROM tracks
    WHERE GenreId IN (1,3,7)
    GROUP BY AlbumId
    ORDER BY Track_Count DESC
    LIMIT 3; -- Album Id 141, 23, 24

---to filter out tracks that are too short (less than 3 minutes)
select t.AlbumId, a.Title as Album_Name, t.Name as Track_Name, t.TrackId, t.Milliseconds as duration
    from tracks t
    join albums a ON a.AlbumId = t.AlbumId
    where t.AlbumId IN (141, 23, 24) ---top 3 albums
    group by t.TrackId
    having t.Milliseconds > 180000;

/*
So the top generes of music are Rock, Metal and Latin (based on most number of tracks). 
Top albums within the top generes (based on most tracks) are Greatest Hits, Minha Historia and Afrociberdelia.
ALso, the final query creates a list of tracks within the top Albums of the top geres that are over 3 minutes long
*/



/* Requirement 2: Client wants to know CustomerId and full name of customers where the sum of their total invoices are greater than the average total invoices for all customers.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
invoices: Columns are InvoiceId, CustomerId, InvoiceDate, BillingAdress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total (Invoice amount)
customers: CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId 
*/

---CTE to simplify query by creating temp tables for CustomerTotals and AverageInvoiceTotals to be used in main query
WITH CustomerTotals AS (SELECT CustomerId, Sum(Total) AS TotalSpent FROM invoices GROUP BY CustomerId),
AverageInvoiceTotal AS (SELECT Avg(Total) AS AvgTotal FROM invoices)
---main query to generate full name and combine with CTE tables and generate list of customers whose total invoices are greater than average total invoice for all customers
SELECT c.CustomerId, c.FirstName || " " || c.LastNAme AS Full_Name
FROM customers c
JOIN CustomerTotals ct ON ct.CustomerId = c.CustomerId
WHERE ct.TotalSpent > (SELECT AvgTotal FROM AverageInvoiceTotal);

/* Requirement 3: Client wants to retreive the names of all the tracks along with each track's genre name.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
genres: Columns are GenreId, Name (genre name)
*/

SELECT tracks.Name AS Track_Name, genres.Name AS Genre_Name
FROM tracks
INNER JOIN genres ON genres.GenreId = tracks.GenreId;

/* Requirement 4: Client wants to retreive the names of all the tracks from the album 'Let there be Rock'.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
albums: Colums are AlbumId, Title, ArtistId
*/

SELECT t.Name as Track_Name, a.Title as Album_Name
from tracks t
JOIN albums a 
ON a.AlbumId = t.AlbumId
WHERE Album_Name = "Let There Be Rock";

/* Requirement 5: Client wants to find the total number of tracks for each ARTIST and sort them in descending order.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
albums: Colums are AlbumId, Title, ArtistId
artists: Columns are ArtictId, Name (artict name)
*/

SELECT COUNT(t.trackId) AS Total_Tracks, a.Name FROM tracks t
JOIN albums al ON al.AlbumId = t.AlbumId
JOIN artists a ON a.ArtistId = al.ArtistId
GROUP BY a.Name
ORDER BY Total_Tracks DESC;

/* Requirement 6: Client wants to find the average track length per album.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
albums: Colums are AlbumId, Title, ArtistId
*/
WITH AverageTrackLength AS (SELECT AlbumId, AVG(Milliseconds) AS Avg_Track_Length FROM tracks GROUP BY AlbumId)
SELECT al.Title as Album_Name, av.Avg_Track_Length FROM albums al
JOIN AverageTrackLength av ON al.AlbumId = av.AlbumId;

/* Requirement 7: Client wants to find the total sales for each USA customer.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
invoices: Columns are InvoiceId, CustomerId, InvoiceDate, BillingAdress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total (Invoice amount)
customers: CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId
*/

WITH TotalSales AS (SELECT CustomerId, SUM(Total) AS Total_Sales FROM invoices GROUP BY CustomerId),
    USA_Customer AS (SELECT CustomerId, FirstName, LastName, Country FROM customers WHERE Country = "USA")
SELECT u.FirstName, u.LastName, ts.Total_Sales, u.Country FROM USA_Customer u
JOIN TotalSales ts ON ts.CustomerId = u.CustomerId
ORDER BY ts.Total_Sales DESC;


/* Requirement 8: Client wants to find the average invoice total by customer, Top 10 customers (full names) with the most invoices (count), top 10 customers by purchase amount.
Total sales by country.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
invoices: Columns are InvoiceId, CustomerId, InvoiceDate, BillingAdress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total (Invoice amount)
customers: CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId
*/

---Avg invoice total by customer
select c.FirstName || ' ' || c.LastName as FullName, i.CustomerId, round(avg(i.Total),2) as Avg_Invoice_Total
from invoices i
JOIN customers c ON c.CustomerId = i.CustomerId
group by i.CustomerId
having Avg_Invoice_Total > 6
ORDER BY Avg_Invoice_Total DESC;

---Top 10 customers (full names) with the most invoices (count)
select i.CustomerId, c.FirstName || ' ' || c.LastName as FullName, count(i.InvoiceId) as InvoiceCount
    from invoices i
    JOIN customers c ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
    ORDER BY InvoiceCount DESC
    LIMIT 10;
    
---top 10 customers by purchase amount
select i.CustomerId, c.FirstName || ' ' || c.LastName as FullName, SUM(Total)
    from invoices i
    JOIN customers c ON c.CustomerId = i.CustomerId
    GROUP BY i.CustomerId
    ORDER BY SUM(Total) DESC
    LIMIT 10;

---Total sales by country
select BillingCountry, SUM(Total)
    from invoices
    group by BillingCountry
    order by SUM(Total) DESC;
    

/* Requirement 9: Client wants to analyse their sales data to to provide insights to help the store increase its revenue.
1. Calculate the total sales for each month in the year 2012.
2. Calculate the running total of sales for each customer.
3. Identify the highest spending customer in each country.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
invoices: Columns are InvoiceId, CustomerId, InvoiceDate, BillingAdress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total (Invoice amount)
customers: CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId
*/

---total sales for each month in the year 2012
with monthsales as (
select sum(Total) as MonthlyTotal,
        STRFTIME('%m', InvoiceDate) as Month
from invoices
where STRFTIME('%Y', InvoiceDate) = '2012'
group by Month
order by Month
)
select MonthlyTotal, Month
from monthsales;

---the running total of sales for each customer
select c.FirstName || " " || LastName as FullName,
        i.InvoiceDate, i.Total as InvoiceTotal,
        sum(i.Total) OVER(partition by c.CustomerId order by i.InvoiceDate) as RunningTotal
from customers c
JOIN invoices i on i.CustomerId = c.CustomerId
order by FullName, InvoiceDate;

---highest spending customer in each country
WITH HighSpendCustomer AS (
    SELECT CustomerId, BillingCountry, SUM(Total) as TotalSpend
    from invoices
    GROUP BY BillingCountry
    ),
      CustomerDemo AS (
      SELECT CustomerId, FirstName || " " || LastName as FullName, Country
      from customers
      )
SELECT c.Country, c.FullName, h.TotalSpend
from CustomerDemo c
JOIN HighSpendCustomer h
ON h.CustomerId = c.CustomerId
GROUP BY c.CustomerId
ORDER BY h.TotalSpend DESC;

---alternately - highest spending customer in each country
with customerspending as (
select c.FirstName || " " || c.LastName as FullName,
        c.Country, sum(i.Total) as TotalSpending
        from customers c
        JOIN invoices i ON c.CustomerId = i.CustomerId
        group by country, c.CustomerId),
rankedspending as (
select country, FullName, TotalSpending,
        RANK() OVER(partition by Country order by TotalSpending DESC) as SpendingRank
        from customerspending)
select Country, FullName, TotalSpending from rankedspending
where SpendingRank = 1;          

/* Requirement 10: Client wants to List tracks by AlbumId and their duration. Also display cumulitive sum by tracks per album.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
*/

SELECT AlbumId, TrackId, Name, Milliseconds, 
    SUM(Milliseconds) OVER(partition by AlbumId order by name) as CumulitiveSumTrackDuration
    from tracks;


/* Requirement 11: Client wants to list tracks by AlbumId and their duration. Also display row number of track within album.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
*/
select AlbumId, TrackId, Name, Milliseconds,
    ROW_number() OVER(partition by AlbumId order by Milliseconds DESC) as RowNumberofTrack
    from tracks;

/* Requirement 12: Client wants to assign a row number to each customer's invoice. The invoice that is the highest amount should be numbered first.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
invoices: Columns are InvoiceId, CustomerId, InvoiceDate, BillingAdress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total (Invoice amount)
*/

select InvoiceId, CustomerId, Total,
    Row_Number() OVER(partition by CustomerId order by Total DESC) as row_num
    from invoices;

/* Requirement 13: Client wants to Rank each invoice a customer has with a 1 for their highest invoice amount. Invoice with same amount should be ranked the same number. 
---Also add Dense rank that ranks invoice after the same rank invoices as the next sequential number.
---Also add a Lag for each customer's invoice total by 1.
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
invoices: Columns are InvoiceId, CustomerId, InvoiceDate, BillingAdress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total (Invoice amount)
*/

select InvoiceId, CustomerId, Total,
    Row_Number() OVER(partition by CustomerId order by Total DESC) as row_num,
    RANK() OVER(partition by CustomerId order by Total DESC) as rank,
    DENSE_RANK() OVER(partition by CustomerId order by Total DESC) as dense_rank,
    LAG(Total, 1, 0) OVER(partition by CustomerId order by CustomerId DESC) as lag
    from invoices;

/* Requirement 14: Client wants to create a list of tracks with their album titles and artist names in upper case, trimmed and substringed to show only the first 10 characters.
---Also include the rank of each track within its album
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
albums: Colums are AlbumId, Title, ArtistId
artists: Columns are ArtictId, Name (artict name)
*/

SELECT t.Name, UPPER(SUBSTR(TRIM(al.Title),1,10)) as Title_10, UPPER(SUBSTR(TRIM(ar.Name),1,10)) as Name_10,
    RANK() OVER(partition by al.AlbumId order by t.TrackId) as Rank
    from tracks t
    JOIN albums al ON al.AlbumId = t.AlbumId
    JOIN artists ar ON ar.ArtistId = al.ArtistId;

/* Requirement 15: Client wants to list down tracks with their duration and ctaegorise these tracks as Long (more than 5 minutes), Medium (3 to 5 minutes) or Short (less than 3 minutes) based on duration
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
*/

select TrackId, Name, Milliseconds,
    case
    when Milliseconds < 180000 then 'Short'
    when Milliseconds between 180000 and 300000 then 'Medium'
    else 'Long'
    end as Duration_Category
from tracks;


/* Requirement 15: Client wants to list down tracks with their MediaType and ctaegorise them as Purchased or Protected or Other
Database - Chinook database -a data model that represents a digital media store (like Gaana.com), including tables for artists, albums, media tracks, invoices, and customers
for this requirement, we use the following tables:
tracks: Columns are trackId, Name (track name), AlbumId, MediaTyp, GenreId, Composer, Millisecond (track length), Bytes (size), UnitPrice
*/

select TrackId, Name, MediaTypeId,
    case
    when MediaTypeId = 1 then 'Purchased'
    when MediaTypeId = 2 then 'Protected'
    else 'Other'
    end as Track_label
from tracks;

 

select c.FirstName || ' ' || c.LastName as FullName, i.CustomerId, round(avg(i.Total),2) as Avg_Invoice_Total
from invoices i
JOIN customers c ON c.CustomerId = i.CustomerId
group by i.CustomerId
having Avg_Invoice_Total > 6
ORDER BY Avg_Invoice_Total DESC;

select i.CustomerId, c.FirstName || ' ' || c.LastName as FullName, count(i.InvoiceId) as InvoiceCount
    from invoices i
    JOIN customers c ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
    ORDER BY InvoiceCount DESC
    LIMIT 10;
    

select i.CustomerId, c.FirstName || ' ' || c.LastName as FullName, SUM(Total)
    from invoices i
    JOIN customers c ON c.CustomerId = i.CustomerId
    GROUP BY i.CustomerId
    ORDER BY SUM(Total) DESC
    LIMIT 10;

select BillingCountry, SUM(Total)
    from invoices
    group by BillingCountry
    order by SUM(Total) DESC;
    



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



select c.FirstName || " " || LastName as FullName,
        i.InvoiceDate, i.Total as InvoiceTotal,
        sum(i.Total) OVER(partition by c.CustomerId order by i.InvoiceDate) as RunningTotal
from customers c
JOIN invoices i on i.CustomerId = c.CustomerId
order by FullName, InvoiceDate;


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



--Checking Datasets

select * from album

select * from album2

select *from customer

select * from customer where company is null or state is null or postal_code is null or phone is null or fax is null
--Most of the data in terms of company is lost it can be filled with hand.


select * from employee 

select * from genre

select * from invoice
--invoice date column should be more plain

select * from invoice_line where invoice_line_id is null or invoice_id is null or track_id is null or unit_price is null or quantity is null -- there is no null value

select * from media_type

select * from playlist where playlist_id is null 

select * from playlist_track

select * from track --Most of Composers are null.



--DATA EXPLORATION

--Who is the senior Manager based on his/her title?

select * from employee where title  like '%Senior%'

--Which Countries has the most invoices?

select top 5 billing_country,COUNT(invoice_id) invoice_amount 
from invoice group by billing_country order by 2 desc

--What are top 3 values of total invoice?

select * from invoice 
order by total desc

--Which city has the most revenue?

select  top 1 billing_city total_revenue from invoice
group by billing_city order by sum(total) desc


--Which customer spend most money?

select  top 1 c.first_name +' '+ c.last_name NAMEOFCUSTOMER   from (select   customer_id,billing_city,total total_revenue from invoice) A 
join customer c on A.customer_id=c.customer_id
group by c.first_name,c.last_name order by sum(A.total_revenue) desc


--Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

select  c.first_name,c.last_name,g.name from customer c
join invoice i on i.customer_id=c.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id = t.track_id
join genre g on g.genre_id=t.genre_id
where g.name like 'Rock'
group by c.first_name,c.last_name,g.name,c.email
order by c.email

--Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

select top 10 ar.name from artist ar
join album a on a.artist_id=ar.artist_id
join track tr on tr.album_id=a.album_id
join genre g on g.genre_id=tr.genre_id
where g.name like '%Rock'
group by  ar.name
order by COUNT(tr.album_id) desc


--Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select tr.name,tr.milliseconds from artist ar
join album a on a.artist_id=ar.artist_id
join track tr on tr.album_id=a.album_id
join genre g on g.genre_id=tr.genre_id
where LEN(tr.name)>(select SUM(LEN(trim(name)))/COUNT(name) AVG_length from track)
group by tr.name,tr.milliseconds
order by len(tr.name) desc

--Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select c.first_name CUSTOMER_NAME,c.last_name CUSTOMER_SURNAME,ar.name ARTIST_NAME,sum(i.total) TOTALSPEND from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id=t.track_id
join album a on a.album_id=t.album_id
join artist ar on ar.artist_id = a.artist_id
group by c.first_name,c.last_name,ar.name
order by 3 desc


--We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

drop table if exists #temptable
create table #temptable(country varchar(100),genre_name varchar(100),total_revenue float)

insert into #temptable select c.country,g.name,SUM(i.total) total_revenue from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id=t.track_id
join genre g on g.genre_id=t.genre_id
join album a on a.album_id=t.album_id
join artist ar on ar.artist_id = a.artist_id
group by c.country,g.name   -- I do not want to write same querry thats why i created temp table


WITH Ranked_Genres as (select country,genre_name,total_revenue,
row_number() over(partition by country order by total_revenue desc) as rank_ 
from #temptable)
select country,genre_name from Ranked_Genres where rank_=1


--Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

drop table if exists #temptable2 
create table #temptable2(country varchar(100),Customer_name varchar(100),Customer_Surname varchar(100),Revenue float)


insert into #temptable2
select c.country,c.first_name,c.last_name,SUM(i.total) total_revenue from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id=t.track_id
join genre g on g.genre_id=t.genre_id
join album a on a.album_id=t.album_id
join artist ar on ar.artist_id = a.artist_id
group by c.country,c.first_name,c.last_name,g.name



WITH RANKED_CUSTOMER as (
select country,Customer_name,Customer_Surname,Revenue,ROW_NUMBER() over(partition by country order by Revenue desc)
as rank_ from #temptable2) select country,Customer_name,Customer_Surname,Revenue from Ranked_Customer where rank_=1
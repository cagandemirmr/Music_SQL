# DATASET INFORMATION

The dataset consists of 12 CSV files, each representing different aspects of a music store database. These files are used for data exploration and querying. Below is the list of CSV files used:

- **album.csv**  
- **album2.csv**  
- **customer.csv**  
- **employee.csv**  
- **genre.csv**  
- **invoice.csv**  
- **invoice_line.csv**  
- **media_type.csv**  
- **playlist.csv**  
- **playlist_track.csv**  
- **track.csv**  
- **artist.csv**  

# DATA EXPLORATION QUERIES

- **Senior Manager Query:**  
  Who is the senior manager based on their job title?

  ```sql
  select * from employee where title  like '%Senior%'
  ```

  ![image](https://github.com/user-attachments/assets/dd2c9eb2-1c77-49a1-b1e9-784b0270ed90)

- **Countries with Most Invoices:**  
  Which countries have the highest number of invoices?

  ```sql
  select top 5 billing_country,COUNT(invoice_id) invoice_amount 
  from invoice group by billing_country order by 2 desc
  ```

  ![image](https://github.com/user-attachments/assets/f8f1b9a0-f532-4399-83c0-f6d074573ecd)


- **Top 3 Invoices by Total Value:**  
  What are the top 3 invoices with the highest total value?

  ```sql
  select  top 3 * from invoice 
  order by total desc
  ```

  ![image](https://github.com/user-attachments/assets/f0e072f1-9638-441f-9ea8-2179d9f5be0c)


- **City with Most Revenue:**  
  Which city generates the most revenue based on invoices?

  ```sql
  select  top 1 billing_city total_revenue from invoice
  group by billing_city order by sum(total) desc
  ```

  ![image](https://github.com/user-attachments/assets/9af13e47-4020-488b-b24c-8c6d6246e97c)



- **Customer Who Spends the Most Money:**  
  Which customer has spent the most money?

  ```sql
  select  top 1 c.first_name +' '+ c.last_name NAMEOFCUSTOMER   from (select   customer_id,billing_city,total total_revenue from invoice) A 
  join customer c on A.customer_id=c.customer_id
  group by c.first_name,c.last_name order by sum(A.total_revenue) desc
  ```

  ![image](https://github.com/user-attachments/assets/2cf3d714-1ced-4fba-9699-30df2d4c3b80)


- **Rock Music Listeners:**  
  List the email, first name, last name, and genre of all Rock music listeners, ordered alphabetically by email starting with 'A'.

  ```sql
  select  c.first_name,c.last_name,g.name from customer c
  join invoice i on i.customer_id=c.customer_id
  join invoice_line il on il.invoice_id=i.invoice_id
  join track t on il.track_id = t.track_id
  join genre g on g.genre_id=t.genre_id
  where g.name like 'Rock'
  group by c.first_name,c.last_name,g.name,c.email
  order by c.email
  ```

  ![image](https://github.com/user-attachments/assets/b59fd064-2f76-4c27-85cb-f30cdb349ff0)



- **Top Rock Bands:**  
  Identify the top 10 rock bands based on the total track count.

  ```sql
  select top 10 ar.name from artist ar
  join album a on a.artist_id=ar.artist_id
  join track tr on tr.album_id=a.album_id
  join genre g on g.genre_id=tr.genre_id
  where g.name like '%Rock'
  group by  ar.name
  order by COUNT(tr.album_id) desc
  ```
  ![image](https://github.com/user-attachments/assets/57444c43-bf66-44ce-a1bc-c58c9002ef7b)

- **Tracks Longer Than Average:**  
  Return all track names that have a song length longer than the average song length, ordered by length.

  ```sql
  select tr.name,tr.milliseconds from artist ar
  join album a on a.artist_id=ar.artist_id
  join track tr on tr.album_id=a.album_id
  join genre g on g.genre_id=tr.genre_id
  where LEN(tr.name)>(select SUM(LEN(trim(name)))/COUNT(name) AVG_length from track)
  group by tr.name,tr.milliseconds
  order by len(tr.name) desc
  ```

  ![image](https://github.com/user-attachments/assets/b2abe41a-6822-4829-92d3-0c67a581549b)


- **Customer Spending on Artists:**  
  Find out how much each customer has spent on artists. Return customer name, artist name, and total spent.

  ```sql
  select c.first_name CUSTOMER_NAME,c.last_name CUSTOMER_SURNAME,ar.name ARTIST_NAME,sum(i.total) TOTALSPEND from customer c
  join invoice i on c.customer_id=i.customer_id
  join invoice_line il on il.invoice_id=i.invoice_id
  join track t on il.track_id=t.track_id
  join album a on a.album_id=t.album_id
  join artist ar on ar.artist_id = a.artist_id
  group by c.first_name,c.last_name,ar.name
  order by 3 des
  ```

  ![image](https://github.com/user-attachments/assets/feb27280-3a9c-4dc5-a972-5baf7c4794d5)


- **Most Popular Genre by Country:**  
  Determine the most popular music genre for each country based on total revenue from purchases.

  ```sql
  drop table if exists #temptable --In case i want to use table later
  create table #temptable(country varchar(100),genre_name varchar(100),total_revenue float) -- I do not want to write same querry thats why i created temp table

  insert into #temptable select c.country,g.name,SUM(i.total) total_revenue from customer c
  join invoice i on c.customer_id=i.customer_id
  join invoice_line il on il.invoice_id=i.invoice_id
  join track t on il.track_id=t.track_id
  join genre g on g.genre_id=t.genre_id
  join album a on a.album_id=t.album_id
  join artist ar on ar.artist_id = a.artist_id
  group by c.country,g.name   


  WITH Ranked_Genres as (select country,genre_name,total_revenue,
  row_number() over(partition by country order by total_revenue desc) as rank_ 
  from #temptable)
  select country,genre_name from Ranked_Genres where rank_=1
  ```

  ![image](https://github.com/user-attachments/assets/1c2090c2-a756-49e3-b24c-8c4c11ee0812)


- **Top Customer per Country:**  
  Identify the top customer who has spent the most on music in each country, including their spending amount.

  ```sql
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
  ```


  ![image](https://github.com/user-attachments/assets/aa191b13-7fe2-4b33-b2c7-f1205bc6acb4)

--1. Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

--2. Which countries have the most Invoices?

select count(billing_country), billing_country
from invoice
group by billing_country
order by count(billing_country) desc;

--3. What are top 3 values of total invoice? 

select total
from invoice
order by total desc
limit 3;


--4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

select sum(total), billing_city
from invoice
group by billing_city
order by sum(total) desc
limit 1;


--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that 
--returns the person who has spent the most money 

select c.customer_id, c.first_name, c.last_name, sum(i.total) 
from customer as c
join invoice as i on i.customer_id = c.customer_id
group by c.customer_id
order by sum(i.total) desc
limit 1;


--1. Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A

select track_id 
from track as t
join genre as g on t.genre_id = g.genre_id
where g.name like 'Rock';


select distinct email, first_name, last_name
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id
join genre as g on t.genre_id = g.genre_id
where g.name like 'Rock'
order by email;


-- OR --

select distinct email, first_name, last_name
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
where track_id in(
		select track_id 
		from track as t
		join genre as g on t.genre_id = g.genre_id
		where g.name like 'Rock'
)
order by email;

--2. Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands 


select a.name, count(g.name)
from artist as a
join album as ab on a.artist_id = ab.artist_id
join track as t on ab.album_id = t.album_id
join genre as g on t.genre_id = g.genre_id
where g.name like 'Rock'
group by a.name
order by count(g.name) desc
limit 10;


--3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first 

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track) 
order by milliseconds desc;


--1. Find how much amount spent by each customer on artists? Write a query to return 
--customer name, artist name and total spent


WITH best_artist as (
	select a.artist_id, a.name, SUM(il.unit_price*il.quantity)
	from invoice_line as il
	join track as t on il.track_id = t.track_id
	join album as ab on t.album_id = ab.album_id
	join artist as a on ab.artist_id = a.artist_id
	group by 1
	order by 3 desc
)
select c.first_name, c.last_name, ba.name as artist_name, 
SUM(il.unit_price*il.quantity) as total_sales
from invoice as i
join customer as c  on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id
join album as ab on t.album_id = ab.album_id
join best_artist as ba on ba.artist_id = ab.artist_id
group by 1,2,3
order by 4 desc;


--2. We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres.


WITH most_populr_genre as(
		select count(il.quantity) as purchases, c.country as country_name, g.name as genre_name, g.genre_id,
		ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY count(il.quantity) DESC) AS row_no
		from customer as c
		join invoice as i on c.customer_id = i.customer_id
		join invoice_line as il on i.invoice_id = il.invoice_id
		join track as t on il.track_id = t.track_id
		join genre as g on t.genre_id = g.genre_id
		group by 2,3,4
		order by 2 asc, 1 desc
)

select * from most_populr_genre 
where row_no <= 1;


--3. Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how 
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount

WITH most_spent_customers as (
		select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(total),
		ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY sum(total) DESC) AS row_no
		from invoice as i
		join customer as c on c.customer_id = i.customer_id
		group by 1,2,3,4
		order by 4 asc, 5 desc
)
select * from most_spent_customers where row_no <= 1;

select * from album
select * from artist
select * from customer
select * from employee
select * from genre
select * from invoice
select * from invoice_line
select * from media_type
select * from playlist
select * from playlist_track
select * from track


-----1)Who is the senior most employee based on job title? 

SELECT * FROM employee
ORDER BY levels DESC LIMIT 1


	


-------2)	Which countries have the most Invoices? 

SELECT COUNT(*) AS most_invoices,billing_country
	FROM invoice
GROUP BY billing_country
ORDER BY most_invoices DESC LIMIT 10;




---3)What are top 3 values of total invoice? 
SELECT total 
	FROM invoice
ORDER BY total DESC 
LIMIT 3;




--4)•	Which city has the best customers? We would like to throw a promotional Music Festival
---	in the city we made the most money. 
---	Write a query that returns one city that has the highest sum of invoice totals. 
---	Return both the city name & sum of all invoice totals 

select * from customer
select * from invoice

SELECT billing_city,SUM(total) AS Invoice_Total
FROM invoice
GROUP BY billing_city
ORDER BY Invoice_Total DESC;



5)--Who is the best customer? The customer who has spent the most money
---	will be declared the best customer. 
---	Write a query that returns the person who has spent the most money 

SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(invoice.total) AS total
FROM customer JOIN
invoice ON
customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC LIMIT 1;


----6)Write a query to return the email, first name, 
---last name, and genre of the top 10 listeners who enjoy Rock music. 

SELECT DISTINCT first_name, last_name,email
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY first_name  limit 10;


---7)•	Let's invite the artists who have written the most rock 
--music in our dataset. Write a query that returns the Artist name 
---and total track count of the top 10 rock bands 

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


---8)Return top 5 the track names that have a song length longer 
----than the average song length. Return the Name and Milliseconds for each track. 
---Order by the song length with the longest songs listed first 

select name,milliseconds
	from track
WHERE milliseconds >(
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track)
	ORDER BY milliseconds DESC 
LIMIT 5;


----9)We want to find out the most popular music Genre for top 5 country. 
--We determine the most popular genre as the genre with the highest amount of 
--purchases. Write a query that returns each country along with the top Genre.
--For countries where the maximum number of purchases is shared return all Genres 

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC 
)
SELECT * FROM popular_genre WHERE RowNo <= 1
order by country limit 5



--10)Write a query that determines the customer that has spent the most
--on music for each country. Write a query that returns the country along 
---	with the top customer and how much they spent. For countries where the top
---	amount spent is shared, provide all customers who spent this amount 

	WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

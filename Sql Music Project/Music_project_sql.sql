--Who is the senior most employee based on job title?
SELECT
	TITLE,
	FIRST_NAME,
	LAST_NAME
FROM
	EMPLOYEE
ORDER BY
	LEVELS DESC
LIMIT
	1;

--Which countries have the most Invoices?
SELECT
	BILLING_COUNTRY,
	COUNT(*) AS TOTAL
FROM
	INVOICE
GROUP BY
	BILLING_COUNTRY
ORDER BY
	TOTAL DESC;

--What are top 3 values of total invoice?
SELECT
	TOTAL
FROM
	INVOICE
ORDER BY
	TOTAL DESC
LIMIT
	3;

/*Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/
SELECT
	SUM(TOTAL) AS TOTAL,
	BILLING_CITY
FROM
	INVOICE
GROUP BY
	BILLING_CITY
ORDER BY
	TOTAL DESC
LIMIT
	1;

/*Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/
SELECT
	B.CUSTOMER_ID,
	B.FIRST_NAME,
	B.LAST_NAME,
	SUM(A.TOTAL) AS TOTAL
FROM
	INVOICE A,
	CUSTOMER B
WHERE
	A.CUSTOMER_ID = B.CUSTOMER_ID
GROUP BY
	B.CUSTOMER_ID
ORDER BY
	TOTAL DESC
LIMIT
	1;



/*Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A*/
SELECT
	C.FIRST_NAME,
	C.LAST_NAME,
	C.EMAIL
FROM
	CUSTOMER C
	JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
	JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
WHERE
	IL.TRACK_ID IN (
		SELECT
			TRACK_ID
		FROM
			TRACK T
			JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
		WHERE
			G.NAME = 'Rock'
	)
ORDER BY
	EMAIL;

SELECT
	C.FIRST_NAME,
	C.LAST_NAME,
	C.EMAIL
FROM
	CUSTOMER C
	JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
	JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
WHERE
	IL.TRACK_ID = 1;

/*Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/

SELECT
	AR.NAME,
	AR.ARTIST_ID,
	COUNT(AR.ARTIST_ID) AS ARTIST_TOTAL
FROM
	ARTIST AR
	JOIN ALBUM AB ON AR.ARTIST_ID = AB.ARTIST_ID
	JOIN TRACK TR ON TR.ALBUM_ID = AB.ALBUM_ID
WHERE
	TR.GENRE_ID IN (
		SELECT
			GENRE_ID
		FROM
			GENRE
		WHERE
			NAME LIKE 'Rock'
	)
GROUP BY
	AR.ARTIST_ID
ORDER BY
	ARTIST_TOTAL DESC
LIMIT
	10;

/*Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed firs*/
SELECT
	*
FROM
	PLAYLIST;

SELECT
	*
FROM
	PLAYLIST_TRACK;

SELECT
	*
FROM
	TRACK
ORDER BY
	GENRE_ID;

SELECT
	NAME,
	MILLISECONDS
FROM
	TRACK
WHERE
	MILLISECONDS > (
		SELECT
			AVG(MILLISECONDS) AS AVG_TRACK_LENGTH
		FROM
			TRACK
	)
ORDER BY
	MILLISECONDS DESC;

/*Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

SELECT
	C.CUSTOMER_ID,
	C.FIRST_NAME,
	C.LAST_NAME,
	A.NAME,
	SUM(IL.UNIT_PRICE * IL.QUANTITY) AMOUNT
FROM
	INVOICE_LINE IL,
	ARTIST A,
	CUSTOMER C,
	ALBUM D,
	INVOICE IV,
	TRACK T
WHERE
	D.ARTIST_ID = A.ARTIST_ID
	AND C.CUSTOMER_ID = IV.CUSTOMER_ID
	AND IV.INVOICE_ID = IL.INVOICE_ID
	--and c.customer_id  = .customer_id
	AND T.ALBUM_ID = D.ALBUM_ID
	AND IL.TRACK_ID = T.TRACK_ID
GROUP BY
	C.CUSTOMER_ID,
	C.FIRST_NAME,
	C.LAST_NAME,
	A.NAME
ORDER BY
	C.CUSTOMER_ID DESC;

/*We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres*/
WITH
	POPULAR_GENRE AS (
		SELECT
			COUNT(INVOICE_LINE.QUANTITY) AS PURCHASES,
			CUSTOMER.COUNTRY,
			GENRE.NAME,
			GENRE.GENRE_ID,
			ROW_NUMBER() OVER (
				PARTITION BY
					CUSTOMER.COUNTRY
				ORDER BY
					COUNT(INVOICE_LINE.QUANTITY) DESC
			) AS ROWNO
		FROM
			INVOICE_LINE
			JOIN INVOICE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
			JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
			JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
			JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
		GROUP BY
			CUSTOMER.COUNTRY,
			GENRE.NAME,
			GENRE.GENRE_ID,
		ORDER BY
			CUSTOMER.COUNTRY ASC,
			1 DESC
	)
SELECT
	*
FROM
	POPULAR_GENRE
WHERE
	ROWNO <= 1 ;

/*Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH
	CUSTOMTER_WITH_COUNTRY AS (
		SELECT
			CUSTOMER.CUSTOMER_ID,
			FIRST_NAME,
			LAST_NAME,
			BILLING_COUNTRY,
			SUM(TOTAL) AS TOTAL_SPENDING,
			ROW_NUMBER() OVER (
				PARTITION BY
					BILLING_COUNTRY
				ORDER BY
					SUM(TOTAL) DESC
			) AS ROWNO
		FROM
			INVOICE
			JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
		GROUP BY
			CUSTOMER.CUSTOMER_ID,
			FIRST_NAME,
			LAST_NAME,
			BILLING_COUNTRY
		ORDER BY
			BILLING_COUNTRY ASC,
			SUM(TOTAL) DESC
	)
SELECT
	*
FROM
	CUSTOMTER_WITH_COUNTRY
WHERE
	ROWNO <= 1 ;
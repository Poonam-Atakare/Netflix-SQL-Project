CREATE TABLE netflix (
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
)

SELECT * FROM netflix;

SELECT 
	COUNT(*) AS Total_Count
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT 
type, 
COUNT(type)as total_count
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT * 
FROM netflix
WHERE type = 'Movie'
AND 
duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix 
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

 
-- 9. Count the number of content items in each genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Find all content without a director

SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
  
-- 14. Find the top 10 actors who have appeared in the hiSghest number of movies produced in India.

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

--“Poonam_Atakare_Insights”

-- 16. Which directors have worked across the most number of unique genres?
-- (Find out which directors have the most diverse creative portfolio.)

SELECT director, COUNT(DISTINCT genre) AS unique_genres
FROM (
    SELECT 
        director, 
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
    WHERE director IS NOT NULL
) AS sub
GROUP BY director
ORDER BY unique_genres DESC
LIMIT 5;


-- 17. Which actor pairs have appeared together the most on Netflix?
-- (Identify the most frequent on-screen duos.)

WITH actor_pairs AS (
    SELECT 
        LOWER(LEAST(a1, a2)) || ' & ' || LOWER(GREATEST(a1, a2)) AS pair
    FROM (
        SELECT 
            show_id,
            TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS a1
        FROM netflix
        WHERE casts IS NOT NULL
    ) a
    JOIN (
        SELECT 
            show_id,
            TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS a2
        FROM netflix
        WHERE casts IS NOT NULL
    ) b ON a.show_id = b.show_id AND a1 < a2
)
SELECT pair, COUNT(*) AS appearances
FROM actor_pairs
GROUP BY pair
ORDER BY appearances DESC
LIMIT 10;



-- 18. In which month does Netflix add the most content?
-- (Discover the trend of content release throughout the year.)

SELECT 
    TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Month') AS month,
    COUNT(*) AS content_count
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY month
ORDER BY content_count DESC;


-- 19. What is the most popular genre for each year?
-- (Determine which genre dominated each release year.)

WITH genre_count AS (
    SELECT 
        release_year,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
        COUNT(*) AS total
    FROM netflix
    WHERE release_year IS NOT NULL
    GROUP BY release_year, genre
),
ranked_genre AS (
    SELECT *,
           RANK() OVER (PARTITION BY release_year ORDER BY total DESC) AS rnk
    FROM genre_count
)
SELECT release_year, genre, total
FROM ranked_genre
WHERE rnk = 1
ORDER BY release_year;



-- 20. What is the average duration of movies for each genre?
-- (Compare average movie lengths across genres.)

SELECT 
    genre,
    ROUND(AVG(duration_min)) AS avg_duration_min
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
        CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS duration_min
    FROM netflix
    WHERE type = 'Movie' AND duration ILIKE '%min%'
) AS movie_genres
GROUP BY genre
ORDER BY avg_duration_min DESC;

-- 21. Which genres are most popular in each country?
-- (Analyze regional preferences for content genres.)

SELECT 
    country,
    genre,
    COUNT(*) AS total
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
    WHERE country IS NOT NULL
) AS sub
GROUP BY country, genre
ORDER BY total DESC
LIMIT 15;


-- 22. How has the number of Netflix releases changed year by year?
-- (Track Netflix’s yearly content growth.)

SELECT 
    release_year,
    COUNT(*) AS content_count
FROM netflix
GROUP BY release_year
ORDER BY release_year;


-- 23. Which genres have the highest amount of mature-rated content (R or TV-MA)?
-- (Identify potentially controversial or adult genres.)

SELECT 
    genre,
    COUNT(*) AS mature_content
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
    WHERE rating IN ('R', 'TV-MA')
) AS sub
GROUP BY genre
ORDER BY mature_content DESC
LIMIT 10;


-- 24. Are there any duplicate titles on Netflix?
-- (Check if the same title exists multiple times, possibly due to remakes or name reuse.)

SELECT title, COUNT(*) AS count
FROM netflix
GROUP BY title
HAVING COUNT(*) > 1;


-- 25. Which content has very short or unclear descriptions?
-- (Identify titles with poor or missing metadata that may need cleaning or improvement.)

SELECT *
FROM netflix
WHERE LENGTH(description) < 30;


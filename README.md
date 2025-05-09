# Netflix Data Analysis Project

## Project Overview

> **Note:** This is a guided project with 15 pre-defined business problems and 10 additional problems solved independently, making a total of 25 problems. The project analyzes the Netflix dataset from **Kaggle** using **SQL** to extract meaningful insights about content distribution, genre analysis, actor appearances, and content release patterns.

## Features
- Data exploration and content analysis using SQL.
- Detailed analysis of Netflix content based on genre, country, rating, and duration.
- Extraction of valuable insights for business decision-making.
- Structured query flow for effective data analysis.

## 📂 Dataset Overview
- Dataset Source: [Kaggle - Netflix Dataset](https://www.kaggle.com/datasets)
- Key Columns:
  - `show_id`: Unique identifier for each show.
  - `type`: Type of content (Movie or TV Show).
  - `title`: Title of the content.
  - `director`: Director(s) of the content.
  - `casts`: Cast members of the content.
  - `country`: Country of origin.
  - `date_added`: Date the content was added to Netflix.
  - `release_year`: Year the content was released.
  - `rating`: Content rating (e.g., PG, R, TV-MA).
  - `duration`: Duration of the content.
  - `listed_in`: Content genres.
  - `description`: Content description.

## Installation
1. Clone the repository:
```bash
  git clone https://github.com/yourusername/Netflix-Data-Analysis.git
```

2. Import the `netflix_data.sql` file into your preferred SQL environment (e.g., PostgreSQL, MySQL).

3. Execute the SQL queries in the provided order to explore and analyze the dataset.

## Usage
- Open the SQL file and execute each query sequentially to explore and analyze the dataset.
- Modify the queries to further explore the dataset and derive additional insights.

## Problem Statements and Solutions

### Problem 1: Count the Number of Movies vs TV Shows
```sql
SELECT 
  type, 
  COUNT(type) AS total_count
FROM netflix
GROUP BY type;
```

### Problem 2: Find the Most Common Rating for Movies and TV Shows
```sql
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
```

### Problem 3: List All Movies Released in 2020
```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

### Problem 4: Top 5 Countries with the Most Content on Netflix
```sql
SELECT 
  UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
  COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;
```

### Problem 5: Identify the Longest Movie
```sql
SELECT * 
FROM netflix
WHERE type = 'Movie'
  AND duration = (SELECT MAX(duration) FROM netflix);
```

---

### Additional Problems and Solutions

### Problem 16: Directors with the Most Diverse Portfolios
```sql
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
```

### Problem 17: Actor Pairs with Most Appearances Together
```sql
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
```

### Problem 18: Month with Most Content Added
```sql
SELECT 
    TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Month') AS month,
    COUNT(*) AS content_count
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY month
ORDER BY content_count DESC;
```

## Conclusion
The Netflix Data Analysis Project leverages SQL to explore key content metrics, identify viewing trends, and extract actionable insights from the dataset. With 25 comprehensive problem statements and solutions, the project serves as a valuable addition to a data analyst’s portfolio, showcasing proficiency in data exploration, data transformation, and advanced SQL query techniques.



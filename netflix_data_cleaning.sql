
-- =====================================================
-- NETFLIX TITLES DATA CLEANING PROJECT (MySQL)
-- =====================================================

-- 1. Create a Staging Table (Protect Raw Data)
CREATE TABLE netflix_titles2 LIKE netflix_titles;

INSERT INTO netflix_titles2 
SELECT * FROM netflix_titles;

-- 2. Check for Duplicate IDs & Duplicate Content
SELECT show_id, COUNT(*) 
FROM netflix_titles2 
GROUP BY show_id 
HAVING COUNT(*) > 1;

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY title, type, release_year, director 
               ORDER BY show_id
           ) AS row_num
    FROM netflix_titles2
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

-- 3. Trim Leading & Trailing Whitespace
UPDATE netflix_titles2
SET 
    show_id = TRIM(show_id),
    type = TRIM(type),
    title = TRIM(title),
    director = TRIM(director),
    cast = TRIM(cast),
    country = TRIM(country),
    date_added = TRIM(date_added),
    rating = TRIM(rating),
    duration = TRIM(duration),
    listed_in = TRIM(listed_in);

-- 4. Fix UTF-8 Character Encoding Issues (Mojibake)
UPDATE netflix_titles2
SET 
    title = CONVERT(BINARY CONVERT(title USING latin1) USING utf8mb4),
    director = CONVERT(BINARY CONVERT(director USING latin1) USING utf8mb4),
    cast = CONVERT(BINARY CONVERT(cast USING latin1) USING utf8mb4),
    country = CONVERT(BINARY CONVERT(country USING latin1) USING utf8mb4),
    description = CONVERT(BINARY CONVERT(description USING latin1) USING utf8mb4)
WHERE 
    title LIKE '%Ã%' 
    OR director LIKE '%Ã%' 
    OR cast LIKE '%Ã%' 
    OR country LIKE '%Ã%' 
    OR description LIKE '%Ã%';

-- 5. Convert Empty Strings to NULL & Standardize Missing Values
UPDATE netflix_titles2 SET director = NULL WHERE director = '';
UPDATE netflix_titles2 SET cast = NULL WHERE cast = '';
UPDATE netflix_titles2 SET country = NULL WHERE country = '';
UPDATE netflix_titles2 SET date_added = NULL WHERE date_added = '';
UPDATE netflix_titles2 SET rating = NULL WHERE rating = '';

UPDATE netflix_titles2
SET 
    director = COALESCE(director, 'Unknown'),
    cast = COALESCE(cast, 'Unknown'),
    country = COALESCE(country, 'Unknown'),
    rating = COALESCE(rating, 'Unknown');

-- 6. Check & Fix Shifted Rating/Duration Values
SELECT show_id, title, rating, duration 
FROM netflix_titles2 
WHERE rating LIKE '%min%';

UPDATE netflix_titles2
SET 
    duration = rating,
    rating = 'Unknown'
WHERE rating LIKE '%min%';

-- 7. Standardize Date Format & Column Data Type
UPDATE netflix_titles2
SET date_added = STR_TO_DATE(date_added, '%M %d, %Y')
WHERE date_added IS NOT NULL 
  AND date_added NOT LIKE '____-__-__';

ALTER TABLE netflix_titles2 
MODIFY COLUMN date_added DATE;

-- 8. Final Verification
SELECT * FROM netflix_titles2;


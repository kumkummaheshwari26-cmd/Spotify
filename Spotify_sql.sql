create database spotify_db;
use spotify_db;

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min VARCHAR(50),
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes varchar(10),
    comments varchar(50),
    licensed varchar(10),
    official_video varchar(10),
    stream varchar(10),
    energy_liveness VARCHAR(50),
    most_played_on VARCHAR(50)
);


SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_dataset.csv'
INTO TABLE spotify
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SHOW VARIABLES LIKE 'secure_file_priv';

-- Find distinct album types
SELECT DISTINCT album_type 
FROM spotify;

-- Find maximum duration
SELECT MAX(duration_min) 
FROM spotify;

-- Find minimum duration
SELECT MIN(duration_min) 
FROM spotify;

-- Check records where duration is 0
SELECT * 
FROM spotify
WHERE duration_min = 0;

-- Delete records where duration is 0
DELETE FROM spotify
WHERE duration_min = 0;

-- Verify if any zero duration rows remain
SELECT * 
FROM spotify
WHERE duration_min = 0;

-- -------------------------------
-- Data Analysis -Easy Category

-- Retrieve the names of all tracks that have more than 1 billion streams.
-- List all albums along with their respective artists.
-- Get the total number of comments for tracks where licensed = TRUE.
-- Find all tracks that belong to the album type single.
-- Count the total number of tracks by each artist.

-- Q.1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
WHERE stream > 1000000000;

-- Q.2 List all albums along with their respective artists.

SELECT
    DISTINCT album, artist
FROM spotify
ORDER BY 1;

-- Get the total number of comments for tracks where licensed = TRUE.

-- SELECT DISTINCT licensed FROM spotify

SELECT
    SUM(comments) as total_comments
FROM spotify
WHERE licensed = 'true';

-- Q.4 Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = 'single';

-- Q.5 Count the total number of tracks by each artist.

SELECT
    artist,      
    COUNT(*) as total_no_songs   
FROM spotify
GROUP BY artist
ORDER BY 2;

/*
-- ---------------------
Medium Level
-- ---------------------

Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q.6 Calculate the average danceability of tracks in each album.
SELECT
    album,
    AVG(danceability) as avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

-- Q.7 Find the top 5 tracks with the highest energy values.

SELECT
    track,
    MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q.8 List all tracks along with their views and likes where official_video = TRUE.

SELECT
    track,
    SUM(views) as total_views,
    SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q.9 For each album, calculate the total views of all associated tracks.

SELECT
    album,
    track,
    SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(
    SELECT
        track,
        COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
    FROM spotify
    GROUP BY 1
) as t1
WHERE
    streamed_on_spotify > streamed_on_youtube;
    
    
-- ------------------------------------------
-- Advanced Problems
-- ------------------------------------------

/*
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- Q.11 Find the top 3 most-viewed tracks for each artist using window functions.

-- each artists and total view for each track
-- track with highest view for each artist (we need top)
-- dense rank
-- cte and filter rank <=3

WITH ranking_artist
AS
(
    SELECT
        artist,
        track,
        SUM(views) as total_view,
        DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank_
    FROM spotify
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC
)

SELECT * FROM ranking_artist
WHERE rank_ <= 3;

-- Q.12 Write a query to find tracks where the liveness score is above the average.

SELECT
    track,
    artist,
    liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);


-- Q.13
-- Use a WITH clause to calculate the difference between the
-- highest and lowest energy values for tracks in each album.

WITH cte
AS
(
    SELECT
        album,
        MAX(energy) as highest_energy,
        MIN(energy) as lowest_energy
    FROM spotify
    GROUP BY 1
)

SELECT
    album,
    highest_energy - lowest_energy as energy_diff
FROM cte;











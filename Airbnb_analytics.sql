CREATE TABLE raw.raw_listings (
    id BIGINT PRIMARY KEY,
    listing_url TEXT,
    scrape_id BIGINT,
    last_scraped DATE,
    source TEXT,
    name TEXT,
    description TEXT,
    neighborhood_overview TEXT,
    picture_url TEXT,
    host_id BIGINT,
    host_url TEXT,
    host_profile_id BIGINT,
    host_profile_url TEXT,
    host_name TEXT,
    host_since DATE,
    hosts_time_as_user_years INT,
    hosts_time_as_user_months INT,
    hosts_time_as_host_years INT,
    hosts_time_as_host_months INT,
    host_location TEXT,
    host_about TEXT,
    host_response_time TEXT,
    host_response_rate TEXT,
    host_acceptance_rate TEXT,
    host_is_superhost BOOLEAN,
    host_thumbnail_url TEXT,
    host_picture_url TEXT,
    host_neighbourhood TEXT,
    host_listings_count INT,
    host_total_listings_count INT,
    host_verifications TEXT,
    host_has_profile_pic BOOLEAN,
    host_identity_verified BOOLEAN,
    neighbourhood TEXT,
    neighbourhood_cleansed TEXT,
    neighbourhood_group_cleansed TEXT,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    property_type TEXT,
    room_type TEXT,
    accommodates INT,
    bathrooms NUMERIC(3,1),
    bathrooms_text TEXT,
    bedrooms INT,
    beds INT,
    amenities TEXT,
    price NUMERIC(10,2),
    minimum_nights INT,
    maximum_nights INT,
    minimum_minimum_nights INT,
    maximum_minimum_nights INT,
    minimum_maximum_nights INT,
    maximum_maximum_nights INT,
    minimum_nights_avg_ntm NUMERIC(12,2),
    maximum_nights_avg_ntm NUMERIC(12,2),
    calendar_updated TEXT,
    has_availability BOOLEAN,
    availability_30 INT,
    availability_60 INT,
    availability_90 INT,
    availability_365 INT,
    calendar_last_scraped DATE,
    number_of_reviews INT,
    number_of_reviews_ltm INT,
    number_of_reviews_l30d INT,
    availability_eoy INT,
    number_of_reviews_ly INT,
    estimated_occupancy_l365d NUMERIC(10,2),
    estimated_revenue_l365d NUMERIC(14,2),
    first_review DATE,
    last_review DATE,
    review_scores_rating NUMERIC(4,2),
    review_scores_accuracy NUMERIC(4,2),
    review_scores_cleanliness NUMERIC(4,2),
    review_scores_checkin NUMERIC(4,2),
    review_scores_communication NUMERIC(4,2),
    review_scores_location NUMERIC(4,2),
    review_scores_value NUMERIC(4,2),
    license TEXT,
    instant_bookable BOOLEAN,
    calculated_host_listings_count INT,
    calculated_host_listings_count_entire_homes INT,
    calculated_host_listings_count_private_rooms INT,
    calculated_host_listings_count_shared_rooms INT,
    reviews_per_month NUMERIC(6,2)
);

COPY raw.raw_listings
FROM 'C:\\import\\listings.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE raw.raw_calendar (
    listing_id BIGINT,
    date DATE,
    available BOOLEAN,
    price NUMERIC(10,2),
    adjusted_price NUMERIC(10,2),
    minimum_nights INT,
    maximum_nights INT
);

COPY raw.raw_calendar
FROM 'C:\\import\\calendar.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE raw.raw_reviews (
    listing_id BIGINT,
    id BIGINT PRIMARY KEY,
    date DATE,
    reviewer_id BIGINT,
    reviewer_name TEXT,
    comments TEXT
);

COPY raw.raw_reviews
FROM 'C:\\import\\reviews.csv'
DELIMITER ','
CSV HEADER;

CREATE SCHEMA analytics;

CREATE TABLE analytics.calendar_clean AS 
SELECT
    listing_id,
    date,
    CASE WHEN available = 't' THEN 1 ELSE 0 END AS available_flag,
    CAST(REPLACE(REPLACE(price::TEXT, '$', ''), ',', '') AS NUMERIC) AS price_clean
FROM raw.raw_calendar;

SELECT * FROM analytics.calendar_clean LIMIT 10;

SELECT 
    available,
    CASE WHEN available = 't' THEN 1 ELSE 0 END AS available_flag
FROM raw.raw_calendar
LIMIT 10;

DROP TABLE IF EXISTS analytics.calendar_clean;

CREATE TABLE analytics.calendar_clean AS
SELECT
    listing_id,
    date,
    CASE 
        WHEN available = TRUE THEN 1 
        ELSE 0 
    END AS available_flag
FROM raw.raw_calendar;

SELECT * FROM analytics.calendar_clean LIMIT 10;

DROP TABLE IF EXISTS analytics.calendar_enriched;

CREATE TABLE analytics.calendar_enriched AS
SELECT
    listing_id,
    date,
    available_flag,
    (1 - available_flag) AS occupied_flag
FROM analytics.calendar_clean;

SELECT * FROM analytics.calendar_enriched LIMIT 10;

DROP TABLE IF EXISTS analytics.listings_clean;

CREATE TABLE analytics.listings_clean AS
SELECT
    id AS listing_id,
    price AS price_clean
FROM raw.raw_listings;

SELECT * FROM analytics.listings_clean LIMIT 10;

DROP TABLE IF EXISTS analytics.listing_metrics;

CREATE TABLE analytics.listing_metrics AS
SELECT
    listing_id,

    COUNT(*) AS total_days,

    SUM(occupied_flag) AS total_occupied_days,

    SUM(occupied_flag) * 1.0 / COUNT(*) AS occupancy_rate

FROM analytics.calendar_enriched
GROUP BY listing_id;

SELECT * FROM analytics.listing_metrics LIMIT 10;

DROP TABLE IF EXISTS analytics.listing_final;

CREATE TABLE analytics.listing_final AS
SELECT
    l.id AS listing_id,
    l.neighbourhood_cleansed,
    l.room_type,
    l.accommodates,
    l.number_of_reviews,
    l.review_scores_rating,
    l.host_is_superhost,

    m.total_days,
    m.total_occupied_days,
    m.occupancy_rate

FROM raw.raw_listings l
LEFT JOIN analytics.listing_metrics m
ON l.id = m.listing_id;

SELECT * FROM analytics.listing_final LIMIT 10;

--Preguntas de negocio--
--¿Los superhost tienen mayor ocupación?--

SELECT 
    host_is_superhost, 
    AVG(occupancy_rate) AS avg_occupancy,
    COUNT(*) AS listings_count
FROM analytics.listing_final
GROUP BY host_is_superhost;

--Room Type--

SELECT 
    room_type, 
    AVG(occupancy_rate) AS avg_occupancy_rate,
    COUNT(*) AS listings_count
FROM analytics.listing_final
GROUP BY room_type
ORDER BY avg_occupancy_rate DESC;

--Superhost y Roomtype--

SELECT 
    host_is_superhost, 
    room_type, 
    AVG(occupancy_rate) AS avg_occupancy_rate,
    COUNT(*) AS listings_count 
FROM analytics.listing_final
GROUP BY host_is_superhost, room_type
ORDER BY avg_occupancy_rate DESC;

--¿Rating impacta la ocupación?--

SELECT 
    CASE 
        WHEN review_scores_rating >= 5 THEN 'High Rating'
        WHEN review_scores_rating >= 3 THEN 'Medium Rating'
        ELSE 'Low Rating' 
    END AS rating_segment,
    AVG(occupancy_rate) AS avg_occupancy, 
    COUNT(*) AS listings_count
FROM analytics.listing_final
WHERE review_scores_rating IS NOT NULL
GROUP BY rating_segment 
ORDER BY avg_occupancy DESC;

--¿Número de reviews impacta la ocupación?--

SELECT 
    CASE 
        WHEN number_of_reviews >= 100 THEN 'High Reviews'
        WHEN number_of_reviews >= 30 THEN 'Medium Reviews'
        ELSE 'Low Reviews' 
    END AS review_volume_segment,
    AVG(occupancy_rate) AS avg_occupancy_rate,
    COUNT(*) AS listings_count
FROM analytics.listing_final
GROUP BY review_volume_segment 
ORDER BY avg_occupancy_rate DESC;

--Driver de ubicación--

SELECT 
neighbourhood_cleansed,
AVG(occupancy_rate) AS avg_occupancy,
COUNT(*) AS listings_count
FROM analytics.listing_final 
GROUP BY neighbourhood_cleansed 
HAVING COUNT(*) > 50
ORDER BY avg_occupancy DESC
LIMIT 10;

--¿Tiene algo que ver la ocupación con los listings?--

SELECT 
     CASE 
	     WHEN accommodates <= 2 THEN 'Small'
		 WHEN accommodates <= 4 THEN 'Medium'
		 ELSE 'Large(+5)' END AS size_segment,

		 AVG(occupancy_rate) AS avg_occupancy,
		 COUNT(*) AS listings_count 

FROM analytics.listing_final
GROUP BY size_segment 
ORDER BY avg_occupancy DESC;

--¿El rating influye en el impacto de la propiedad?--

SELECT 
    room_type,
    host_is_superhost,
    CASE
        WHEN review_scores_rating >= 5 THEN 'High'
        WHEN review_scores_rating >= 3 THEN 'Medium'
        ELSE 'Low' 
    END AS rating_segment,
    AVG(occupancy_rate) AS avg_occupancy_rate,
    COUNT(*) AS listings_count
FROM analytics.listing_final
WHERE review_scores_rating IS NOT NULL
GROUP BY room_type, host_is_superhost, rating_segment
ORDER BY room_type, host_is_superhost, avg_occupancy_rate DESC;

SELECT 
    neighbourhood_cleansed,
    room_type,
    AVG(occupancy_rate) AS avg_occupancy_rate, 
    COUNT(*) AS listings_count
FROM analytics.listing_final
GROUP BY neighbourhood_cleansed, room_type
HAVING COUNT(*) > 30
ORDER BY avg_occupancy_rate DESC
LIMIT 10;

SELECT *
FROM analytics.listing_final;


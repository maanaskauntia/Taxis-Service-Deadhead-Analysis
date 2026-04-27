WITH data_prep AS
 (
  SELECT 
    taxi_id,
    trip_start_timestamp,
    trip_end_timestamp,
    dropoff_community_area,
    LEAD(trip_start_timestamp) OVER (PARTITION BY taxi_id ORDER BY trip_start_timestamp ASC) AS next_trip_start,
    --- Using a window function to add a column that answers 'When did the next trip start?', for all trips

    CONCAT(
            CAST(FLOOR(EXTRACT(HOUR FROM trip_end_timestamp) / 2) * 2 AS STRING), 
            ':00 - ', 
            CAST(FLOOR(EXTRACT(HOUR FROM trip_end_timestamp) / 2) * 2 + 2 AS STRING), 
           ':00'
          ) AS time_window
    --- Adds an hour-based time window to every trip_end_timestamp (e.g. '14:00 - 16:00' for a trip ending at 15:32:00) 

  FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE trip_seconds > 60   --- Making sure only trips lasting more than a minute are considered
    AND trip_miles > 0.1  --- Making sure only trips greater than 1/10th of a mile are considered
    AND fare > 0 --- Making sure the trip had non-negative fare to remove erroneous/anomalous data         
 ),

 Deadhead_calc AS
 (
  SELECT *, TIMESTAMP_DIFF(next_trip_start, trip_end_timestamp, MINUTE) AS deadhead_minutes
  --- Calculating time-difference in end of one trip and start of the next trip as 'deadhead_minutes'
  --- This is the time that a driver spent waiting for the next ride
 
  FROM data_prep
 )
 
SELECT 
    dropoff_community_area, 
    time_window, 
    ROUND(AVG(deadhead_minutes), 2) AS avg_wait_mins, 
    --- Aggregating dead_minutes by average for each dropoff_community_area/time_window pair
 
    COUNT(*) AS trips_considered --- Displaying the sample size of trips considered for the deadhead time avg
 
FROM Deadhead_calc
WHERE deadhead_minutes > 0 --- Filtering negative wait-times
  AND deadhead_minutes < 90 
  --- Filtering out wait times greater than 90 mins, considering them as lunch-breaks/shift-ends
  
 AND dropoff_community_area IS NOT NULL -- Cleaning up the null locations
GROUP BY 1, 2 --- Making dropoff_community_area/time_window pairs that other metrics are grouped by
HAVING trips_considered > 50 -- Filtering out one-off long wait time incidents
ORDER BY avg_wait_mins DESC --- Displaying the longest wait time locations+time_window combinations first

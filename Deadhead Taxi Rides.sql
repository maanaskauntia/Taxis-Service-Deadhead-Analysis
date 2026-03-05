WITH Table_one AS
 (
  SELECT 
    taxi_id,
    trip_start_timestamp,
    trip_end_timestamp,
    dropoff_community_area,
    LEAD(trip_start_timestamp) OVER (PARTITION BY taxi_id ORDER BY trip_start_timestamp ASC) AS next_trip_start,
    CONCAT(
            CAST(FLOOR(EXTRACT(HOUR FROM trip_end_timestamp) / 2) * 2 AS STRING), 
            ':00 - ', 
            CAST(FLOOR(EXTRACT(HOUR FROM trip_end_timestamp) / 2) * 2 + 2 AS STRING), 
           ':00'
          ) AS time_window -- For each ride, this is the 2 hr time window in which the ride ended in a particular location
  FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE trip_seconds > 60   -- Filtering out "accidental" clicks < 1 min
    AND trip_miles > 0.1    -- Filtering out non-movements
    AND fare > 0            -- Filtering out non-commercial trips
    AND trip_start_timestamp = '2021-01-01' -- Limiting data usage to post-covid!
 ),

 Deadhead_calc AS
 (
  SELECT *, TIMESTAMP_DIFF(next_trip_start, trip_end_timestamp, MINUTE) AS deadhead_minutes
  FROM Table_one
 )
 
SELECT dropoff_community_area, time_window, AVG(deadhead_minutes) AS avg_deadhead_time,
       COUNT(*) AS total_trips -- Added this to show "Sample Size"
FROM Deadhead_calc
WHERE deadhead_minutes > 0 AND -- Ensure we don't have negative time or 0
      deadhead_minutes < 90 -- Threshold: Anything over 90 mins is a break, not a 'wait' 
GROUP BY dropoff_community_area, time_window
HAVING total_trips > 100 -- Ignore the areas with tiny data
ORDER BY AVG(deadhead_minutes) DESC
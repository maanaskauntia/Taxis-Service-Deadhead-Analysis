## Project Overview:

In 2023, the City of Chicago (in its role as a regulatory agency) released the [Chicago Taxi Trips (2013-2023)](https://data.cityofchicago.org/Transportation/Taxi-Trips-2013-2023-/wrvz-psew/about_data) dataset. The dataset contained 210M+ rows of data on individual taxi trips recorded over a decade.

Here's the business question that this project attempts to answer:

_Which drop off locations have the highest 'deadhead times' (i.e. the idle time spent by drivers finding their next ride), and at what hours in the day?_

For instance, if the dataset had Delhi data, the query could reveal that Jahangirpuri (North West Delhi) has the highest deadhead time between 8 p.m. and 10 p.m., meaning that its the dropoff location after which drivers have to struggle the most to find the next pickup, especially in the night.

There could be many use-cases for such information. One primary use case for a profit-making enterprise (Uber, Ola, Rapido and such) could be to build benefits and costs into their pricing model based on deadhead times of specific locations. Basically, they could **charge higher rates for rides to areas with significantly higher deadhead times** and lower rates for areas where finding pickups is much quicker and easier. This would benefit both the driver and the company (trying to make the best economic use of each driver's 8-10 hour shifts).

## Cleaning the Data for Accuracy:

As a quick reference, the SQL query utilized for the analysis can be found [here](https://github.com/maanaskauntia/Taxis-Service-Deadhead-Analysis/blob/main/Deadhead%20Taxi%20Rides.sql).

The dataset originally had 23 columns and 210M+ rows. However, significant amounts of filtering was required to reach reliable insights. Here are the details of the cleaning process:

<dl>
  <dd>
    
&#8211; Filtered out trips that were less than a minute long (17M rows)

&#8211; Further filtered out trips covering less than 0.1 miles in distance (another 33M rows)

&#8211; Further filtered out trips with negative fare value (another 41,000 rows)

</dd>
</dl>

From here, we were left with ~160M entries. Deadhead minutes were calculated for each of these entries. However, another round of filtering was required to get accurate results:


<dl>
  <dd>
&#8211; Filtered out trips with negative deadhead time (41M rows). These were rows which showed that the next trip started before the previous trip had ended, which indicates misreporting
    
&#8211; Further filtered out trips with greater than 90 mins deadhead time (30M rows). The logic here is that a wait time of >90 mins indicates either a meal break or a shift change. If we had let this data into our analysis, it would have falsely skewed the numbers towards the higher end

&#8211; Further filtered out trips where the dropoff location is NULL (9M rows)

&#8211; Finally, after the aggregations were complete, we only considered average deadhead times that were based on at least 3650 trips, to focus only on 'locations+time slot' pairs that had a significant business impact. Across 10 years, if there were locations where we did not even do one trip a day, the business impact of those might not be nearly as much as of the ones where we are waiting too much, multiple times a day
</dd>
</dl>

That was the cleaning process. The final analysis thus presents insights based on data for ~80M rows, spanning 10 years (2013-2023). The resulting .csv has only 550 rows, which represent the most significant deadhead location-time pairs.

## Key Findings and Recommendations:

The results csv file can be found [here](https://drive.google.com/file/d/1TI7968qD6lBhajAZmwleC3oyaLMh3Dle/view?usp=sharing).

1) Dropoff community area 76 consistently ranks high for deadhead time across multiple time windows throughout the day. The business impact is significant (500+ hours spent waiting for bookings every single day). Similarly, community area 56 is a deadhead trap from 6 am to 10 am, and so is community area 12, from 4 pm to 6 pm.

<div align="center">
  <img src="https://drive.google.com/thumbnail?id=1YTcUF095uNGij18QTyUNNBJt2k-K5XFz&sz=w800" width="700" alt="Chicago Taxi Analysis">
</div>

> <u>Recommendation</u>: The price for the trips to these 3 locations (76, 56, and 12) at the time windows mentioned above should be increased in order to compensate for the time lost waiting for the next pickup.

2) Dropoff community areas 32, 28, 24, 7 and 8 have the least wait times of any location late night (2 am to 4 am).

<div align="center">
  <img src="https://drive.google.com/thumbnail?id=1gdZwCa0QIlQRkAKlKTAyvEhDDFwXesC9&sz=w800" width="700" alt="Chicago Taxi Deadhead Analysis Map">
</div>

> <u>Recommendation</u>: The price for trips to these 5 locations (32, 28, 24, 7, 8) should be lowered especially at 2 am in the morning to beat price offerings from other companies. We can earn more even by lowering our prices if we win every bid (involving other companies) by completing a higher number of trips to all these locations at between 2 and 4 am.

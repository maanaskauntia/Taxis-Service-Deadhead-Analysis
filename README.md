# 🚖 Chicago Taxi "Deadhead" Analytics
**Optimizing Driver Efficiency using BigQuery & SQL Window Functions**

## 📌 Project Overview
This project analyzes **210 Million+ rows** of Chicago taxi data to identify "Deadhead Traps"—geographic areas and time windows where drivers experience the longest idle times between fares. 

## 🛠 The Data Funnel (Audit Results)
Before analysis, I performed a rigorous data audit to ensure metric integrity:
* **Initial Dataset:** 210.8 Million rows.
* **Filter 1 (Technical Errors):** Removed 10.7M rows with 0-second durations.
* **Filter 2 (Ghost Trips):** Identified and removed 53.5k trips with >10 miles but 0 seconds.
* **Filter 3 (Stationary):** Removed 30M rows with 0 miles (idle/parked).
* **Final Analysis Set:** Focused on high-integrity trips from 2021–Present.

## 🧠 Logical Architecture
To calculate the "Deadhead" (unpaid idle time), I utilized the following SQL logic:
1. **Window Function:** Used `LEAD()` partitioned by `taxi_id` to find the gap between Trip A's end and Trip B's start.
2. **Time Bucketing:** Categorized trips into **2-hour blocks** to identify supply/demand shifts throughout the day.
3. **Behavioral Threshold:** Implemented a **90-minute cap**. Anything longer is categorized as a "Driver Break" rather than "Market Wait Time."

## 🚀 Strategic Recommendations (Hypothesized)
Based on preliminary data trends:
* **O'Hare (Area 76):** High volume but high deadhead. **Action:** Implement "Queue-Jump" incentives for drivers to move to nearby high-demand zones.
* **Residential Areas:** Late-night drop-offs create "One-way traps." **Action:** Suggest deadheading back to the Loop during the 22:00-00:00 window.

---
*Note: This project was built using Google BigQuery. Due to the massive scale of the public dataset (1TB+ scan volume), query optimization and partitioning were prioritized to manage compute resources.*

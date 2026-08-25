-- ============================================================
-- VitaCure Healthcare — SQL Analysis
-- Analyst: A. Shanthan Kumar | Oct 2025 – Jan 2026
-- Database: vitacure.db (SQLite)
-- Table: bookings (950 rows × 14 columns)
-- ============================================================

-- ============================================================
-- SECTION 1: DATASET OVERVIEW
-- ============================================================

-- 1.1 Total bookings and overall no-show rate
SELECT
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS total_noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct,
    ROUND(AVG(Lead_Time_Days), 1) AS avg_lead_time_days,
    ROUND(AVG(Prior_Cancellations), 2) AS avg_prior_cancellations
FROM bookings;

-- 1.2 Booking count by session type
SELECT
    Session_Type,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Session_Type
ORDER BY noshow_rate_pct DESC;

-- 1.3 Bookings and no-shows by city
SELECT
    Location,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Location
ORDER BY noshow_rate_pct DESC;

-- ============================================================
-- SECTION 2: THERAPIST PERFORMANCE
-- ============================================================

-- 2.1 Therapist-wise no-show rate (ranked worst to best)
SELECT
    Therapist,
    Therapist_Experience_Years,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Therapist
ORDER BY noshow_rate_pct DESC;

-- 2.2 Does experience reduce no-shows? (correlation check)
SELECT
    CASE
        WHEN Therapist_Experience_Years <= 3 THEN '0-3 yrs (Junior)'
        WHEN Therapist_Experience_Years <= 8 THEN '4-8 yrs (Mid)'
        ELSE '9+ yrs (Senior)'
    END AS experience_band,
    COUNT(*) AS total_bookings,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY experience_band
ORDER BY noshow_rate_pct DESC;

-- ============================================================
-- SECTION 3: PATIENT BEHAVIOUR ANALYSIS
-- ============================================================

-- 3.1 No-show rate by prior cancellation count
SELECT
    Prior_Cancellations,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Prior_Cancellations
ORDER BY Prior_Cancellations;

-- 3.2 High-risk patients (2+ prior cancellations) — flagged list
SELECT
    Patient_ID,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    MAX(Prior_Cancellations) AS max_prior_cancellations,
    ROUND(AVG(No_Show) * 100, 2) AS personal_noshow_rate_pct
FROM bookings
WHERE Prior_Cancellations >= 2
GROUP BY Patient_ID
HAVING COUNT(*) > 1
ORDER BY personal_noshow_rate_pct DESC
LIMIT 10;

-- 3.3 Reminder impact on no-show rate
SELECT
    CASE WHEN Reminder_Sent = 1 THEN 'Reminder Sent' ELSE 'No Reminder' END AS reminder_status,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Reminder_Sent;

-- ============================================================
-- SECTION 4: BOOKING TIMING ANALYSIS
-- ============================================================

-- 4.1 No-show rate by day of week
SELECT
    Day_of_Week,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Day_of_Week
ORDER BY noshow_rate_pct DESC;

-- 4.2 No-show rate by hour of day (grouped into time slots)
SELECT
    CASE
        WHEN Hour BETWEEN 9 AND 11 THEN 'Morning (9-11)'
        WHEN Hour BETWEEN 12 AND 14 THEN 'Midday (12-14)'
        WHEN Hour BETWEEN 15 AND 17 THEN 'Afternoon (15-17)'
        ELSE 'Evening (18+)'
    END AS time_slot,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY time_slot
ORDER BY noshow_rate_pct DESC;

-- 4.3 Lead time impact (grouped into bands)
SELECT
    CASE
        WHEN Lead_Time_Days <= 3 THEN '1-3 days'
        WHEN Lead_Time_Days <= 7 THEN '4-7 days'
        WHEN Lead_Time_Days <= 10 THEN '8-10 days'
        ELSE '11-14 days'
    END AS lead_time_band,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY lead_time_band
ORDER BY noshow_rate_pct DESC;

-- ============================================================
-- SECTION 5: CONDITION-WISE ANALYSIS
-- ============================================================

-- 5.1 No-show rate by medical condition
SELECT
    Condition,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Condition
ORDER BY noshow_rate_pct DESC;

-- 5.2 High-risk combinations (Condition + Session Type)
SELECT
    Condition,
    Session_Type,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY Condition, Session_Type
HAVING COUNT(*) >= 20
ORDER BY noshow_rate_pct DESC
LIMIT 10;

-- ============================================================
-- SECTION 6: WEEKLY DEMAND TRENDS
-- ============================================================

-- 6.1 Weekly booking volume
SELECT
    strftime('%Y-%W', Scheduled_Date) AS week,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    COUNT(*) - SUM(No_Show) AS completed_sessions
FROM bookings
GROUP BY week
ORDER BY week;

-- 6.2 Month-wise summary
SELECT
    strftime('%Y-%m', Scheduled_Date) AS month,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct,
    ROUND(AVG(Lead_Time_Days), 1) AS avg_lead_time
FROM bookings
GROUP BY month
ORDER BY month;

-- ============================================================
-- SECTION 7: RISK SEGMENTATION (Business-Ready View)
-- ============================================================

-- 7.1 Risk score buckets based on known risk factors
SELECT
    CASE
        WHEN Prior_Cancellations >= 2
             AND Reminder_Sent = 0
             AND Lead_Time_Days >= 10 THEN 'Very High Risk'
        WHEN Prior_Cancellations >= 2
             OR (Reminder_Sent = 0 AND Lead_Time_Days >= 10) THEN 'High Risk'
        WHEN Reminder_Sent = 0
             OR Lead_Time_Days >= 10 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_segment,
    COUNT(*) AS total_bookings,
    SUM(No_Show) AS actual_noshows,
    ROUND(AVG(No_Show) * 100, 2) AS noshow_rate_pct
FROM bookings
GROUP BY risk_segment
ORDER BY noshow_rate_pct DESC;

-- 7.2 Bookings needing immediate outreach today
-- (high-risk bookings scheduled in next 3 days)
SELECT
    Booking_ID,
    Patient_ID,
    Therapist,
    Condition,
    Scheduled_Date,
    Prior_Cancellations,
    Reminder_Sent,
    Lead_Time_Days
FROM bookings
WHERE No_Show = 0
  AND Prior_Cancellations >= 2
  AND Reminder_Sent = 0
ORDER BY Scheduled_Date
LIMIT 10;

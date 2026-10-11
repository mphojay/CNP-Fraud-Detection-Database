-- Question: Which time of the day is the riskiest?
-- Returns: transactions grouped into time-of-day bands, with the number flagged,
-- total value and average risk score.
-- Business value: Generally, fraudsters operate at night when customers are asleep.
-- Knowing the riskiest hours helps the institution schedule analyst shifts and tighten prevention measures at those times.

SELECT 
    CASE
        WHEN HOUR(t.TRANSACTION_DATE) BETWEEN 0 AND 5 
            THEN '1. Night (00-06)'
        WHEN HOUR(t.TRANSACTION_DATE) BETWEEN 6 AND 11 
            THEN '2. Morning (06-12)'
        WHEN HOUR(t.TRANSACTION_DATE) BETWEEN 12 AND 17 
            THEN '3. Afternoon (12-18)'
        ELSE '4. Evening (18-24)'
    END AS TIME_BAND,
    
    COUNT(*) AS TOTAL_TRANSACTIONS,
    SUM(fra.IS_FLAGGED) AS FLAGGED,
    ROUND(SUM(t.TRANSACTION_AMOUNT), 2) AS TOTAL_VALUE,
    ROUND(AVG(fra.RISK_SCORE), 2) AS AVG_RISK_SCORE

FROM CNP_TRANSACTION t

INNER JOIN FRAUD_RISK_ASSESSMENT fra
    ON fra.TRANSACTION_ID = t.TRANSACTION_ID

GROUP BY TIME_BAND
ORDER BY TIME_BAND;
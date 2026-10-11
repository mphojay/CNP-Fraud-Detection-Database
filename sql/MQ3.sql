-- Question: Is fraud rising? And is the flagging stable over time?
-- Returns: the transactions, flagged transactions, flag rate and average risk score per month.
-- Business value: reveals fraud trends and seasonal spikes,
-- and shows whether the system's flagging rate is stable over time.


SELECT 
    DATE_FORMAT(t.TRANSACTION_DATE, '%Y-%m') AS TRANSACTION_MONTH,
    COUNT(*) AS TOTAL_TRANSACTIONS,
    SUM(fra.IS_FLAGGED) AS FLAGGED,
    ROUND(
        100 * SUM(fra.IS_FLAGGED) / COUNT(*), 
        1
    ) AS FLAG_RATE_PCT,
    ROUND(AVG(fra.RISK_SCORE), 2) AS AVG_RISK_SCORE
FROM CNP_TRANSACTION t
INNER JOIN FRAUD_RISK_ASSESSMENT fra
    ON fra.TRANSACTION_ID = t.TRANSACTION_ID
GROUP BY DATE_FORMAT(t.TRANSACTION_DATE, '%Y-%m')
ORDER BY TRANSACTION_MONTH;
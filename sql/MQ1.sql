-- Question: Which CNP transaction channels are the riskiest?
-- Returns: the number, value and average/maximum the risk scores of transactions per channel.
-- Business value: shows which CNP channels carry the most risk, so the institution can 
-- implement additional CNP-fraud prevention strategies at the riskiest channels.

SELECT 
    t.TRANSACTION_CHANNEL,
    COUNT(*) AS TOTAL_TRANSACTIONS,
    SUM(fra.IS_FLAGGED) AS FLAGGED_TRANSACTIONS,
    ROUND(SUM(t.TRANSACTION_AMOUNT), 2) AS TOTAL_VALUE,
    ROUND(AVG(fra.RISK_SCORE), 2) AS AVG_RISK_SCORE,
    MAX(fra.RISK_SCORE) AS MAX_RISK_SCORE
FROM CNP_TRANSACTION t
INNER JOIN FRAUD_RISK_ASSESSMENT fra
    ON fra.TRANSACTION_ID = t.TRANSACTION_ID
GROUP BY t.TRANSACTION_CHANNEL
ORDER BY AVG_RISK_SCORE DESC;


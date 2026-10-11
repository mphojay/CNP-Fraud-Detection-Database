-- Question: Which are the most predictive risk factors?
-- Returns: risk factors seen in 3+ closed investigations where at least 50% of those investigations confirmed fraud,
-- with the average risk score.
-- Business value: shows which risk factors most reliably indicate real fraud.
-- This is useful for tuning the prediction model and prioritising future alerts.

SELECT 
    rf.FACTOR_NAME,
    COUNT(*) AS CLOSED_CASES,
    SUM(
        fi.INVESTIGATION_OUTCOME = 'Fraudulent'
    ) AS FRAUD_CASES,
    
    ROUND(
        100 * SUM(
            fi.INVESTIGATION_OUTCOME = 'Fraudulent'
        ) / COUNT(*),
        1
    ) AS FRAUD_RATE_PCT,
    
    ROUND(
        AVG(fra.RISK_SCORE),
        2
    ) AS AVG_RISK_SCORE

FROM RISK_FACTOR rf

INNER JOIN INVESTIGATION_RISK_FACTOR irf
    ON irf.FACTOR_ID = rf.FACTOR_ID

INNER JOIN FRAUD_INVESTIGATION fi
    ON fi.INVESTIGATION_ID = irf.INVESTIGATION_ID

INNER JOIN FRAUD_RISK_ASSESSMENT fra
    ON fra.TRANSACTION_ID = fi.TRANSACTION_ID

WHERE fi.INVESTIGATION_STATUS = 'Closed'

GROUP BY 
    rf.FACTOR_ID,
    rf.FACTOR_NAME

HAVING 
    COUNT(*) >= 3
    AND SUM(
        fi.INVESTIGATION_OUTCOME = 'Fraudulent'
    ) / COUNT(*) >= 0.5

ORDER BY 
    FRAUD_RATE_PCT DESC,
    FRAUD_CASES DESC;
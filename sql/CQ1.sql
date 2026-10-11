-- CQ1: 
-- Question: Which customer accounts might be compromised?
-- Returns: customers with at least one confirmed fraudulent transaction 
-- AND either 3+ flagged transactions OR a risk score of 90+, with the value lost to fraud.
-- Business value: points out compromised cards
-- or accounts that should be reissued or placed under enhanced monitoring. 


SELECT 
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    COUNT(*) AS TOTAL_TRANSACTIONS,
    SUM(fra.IS_FLAGGED) AS FLAGGED_TRANSACTIONS,
    SUM(
        fi.INVESTIGATION_OUTCOME = 'Fraudulent'
    ) AS CONFIRMED_FRAUD,
    MAX(fra.RISK_SCORE) AS HIGHEST_RISK_SCORE,
    
    ROUND(
        SUM(
            CASE 
                WHEN fi.INVESTIGATION_OUTCOME = 'Fraudulent'
                THEN t.TRANSACTION_AMOUNT
                ELSE 0
            END
        ), 
        2
    ) AS FRAUD_VALUE

FROM CUSTOMER c

INNER JOIN CNP_TRANSACTION t
    ON t.CUSTOMER_ID = c.CUSTOMER_ID

INNER JOIN FRAUD_RISK_ASSESSMENT fra
    ON fra.TRANSACTION_ID = t.TRANSACTION_ID

LEFT JOIN FRAUD_INVESTIGATION fi
    ON fi.TRANSACTION_ID = t.TRANSACTION_ID

GROUP BY 
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME

HAVING 
    SUM(fi.INVESTIGATION_OUTCOME = 'Fraudulent') >= 1
    AND (
        SUM(fra.IS_FLAGGED) >= 3
        OR MAX(fra.RISK_SCORE) >= 90
    )

ORDER BY 
    CONFIRMED_FRAUD DESC,
    FRAUD_VALUE DESC;
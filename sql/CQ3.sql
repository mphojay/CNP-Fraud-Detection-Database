-- Question: Do cases that are worked on by multiple analysts get better outcomes that single-analyst cases?
-- Returns: closed investigations grouped by how many analysts worked on them, with average days to close, 
-- fraud rate and average transaction value.
-- Business value: shows whether assigning more than one analyst leads to faster or more decisive outcomes.
-- This can inform how the institution allocate analysts for complex cases.

SELECT 
    CASE 
        WHEN team.ANALYST_COUNT = 1 
            THEN 'Solo'
        ELSE 'Team (2+)'
    END AS INVESTIGATION_TYPE,

    COUNT(*) AS CLOSED_CASES,

    ROUND(
        AVG(
            DATEDIFF(
                fi.CLOSED_DATE,
                fi.START_DATE
            )
        ),
        1
    ) AS AVG_DAYS_TO_CLOSE,

    ROUND(
        100 * SUM(
            fi.INVESTIGATION_OUTCOME = 'Fraudulent'
        ) / COUNT(*),
        1
    ) AS FRAUD_RATE_PCT,

    SUM(
        fi.INVESTIGATION_OUTCOME = 'Further Review'
    ) AS LEFT_FOR_FURTHER_REVIEW,

    ROUND(
        AVG(t.TRANSACTION_AMOUNT),
        2
    ) AS AVG_TRANSACTION_VALUE

FROM (
    SELECT 
        INVESTIGATION_ID,
        COUNT(*) AS ANALYST_COUNT
    FROM INVESTIGATION_ANALYST
    GROUP BY INVESTIGATION_ID
) AS team

INNER JOIN FRAUD_INVESTIGATION fi
    ON fi.INVESTIGATION_ID = team.INVESTIGATION_ID

INNER JOIN CNP_TRANSACTION t
    ON t.TRANSACTION_ID = fi.TRANSACTION_ID

WHERE fi.INVESTIGATION_STATUS = 'Closed'

GROUP BY INVESTIGATION_TYPE

HAVING COUNT(*) >= 3

ORDER BY INVESTIGATION_TYPE;
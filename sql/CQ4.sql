-- Question: Which analysts take longer to solve cases?
-- Returns: analysts (with 2+ closed cases) whose average days-to-close is above the institution average.
-- Business value: identifies the slowest analysts. Slow investigations delay customer refunds and card blocks,
-- so these analysts may need support, training or lighter caseloads.

SELECT 
    CONCAT(
        fa.ANALYST_FNAME,
        ' ',
        fa.ANALYST_LNAME
    ) AS ANALYST,

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

    MAX(
        DATEDIFF(
            fi.CLOSED_DATE,
            fi.START_DATE
        )
    ) AS LONGEST_CASE_DAYS

FROM FRAUD_ANALYST fa

INNER JOIN INVESTIGATION_ANALYST ia
    ON ia.ANALYST_ID = fa.ANALYST_ID

INNER JOIN FRAUD_INVESTIGATION fi
    ON fi.INVESTIGATION_ID = ia.INVESTIGATION_ID

WHERE fi.INVESTIGATION_STATUS = 'Closed'

GROUP BY 
    fa.ANALYST_ID,
    fa.ANALYST_FNAME,
    fa.ANALYST_LNAME

HAVING 
    COUNT(*) >= 2

    AND AVG(
        DATEDIFF(
            fi.CLOSED_DATE,
            fi.START_DATE
        )
    ) > (
        SELECT AVG(
            DATEDIFF(
                CLOSED_DATE,
                START_DATE
            )
        )
        FROM FRAUD_INVESTIGATION
        WHERE INVESTIGATION_STATUS = 'Closed'
    )

ORDER BY AVG_DAYS_TO_CLOSE DESC;
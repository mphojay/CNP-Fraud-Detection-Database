
-- Question: Is work spread fairly across the fraud analysts?
-- Returns: the number of investigations per analyst and the date range they worked in,
-- including analysts with no investigations
-- Business value: Imbalances in workload distribution amongst analysts is unfair. 
-- This query supports fair workload allocation and staffing decisions.

SELECT 
    CONCAT(fa.ANALYST_FNAME, ' ', fa.ANALYST_LNAME) AS ANALYST,
    fi_inst.INSTITUTION_NAME,
    COUNT(ia.INVESTIGATION_ID) AS INVESTIGATIONS_ASSIGNED,
    MIN(fi.START_DATE) AS FIRST_INVESTIGATION,
    MAX(fi.START_DATE) AS LATEST_INVESTIGATION
FROM FRAUD_ANALYST fa
INNER JOIN FINANCIAL_INSTITUTION fi_inst
    ON fi_inst.INSTITUTION_ID = fa.INSTITUTION_ID
LEFT JOIN INVESTIGATION_ANALYST ia
    ON ia.ANALYST_ID = fa.ANALYST_ID
LEFT JOIN FRAUD_INVESTIGATION fi
    ON fi.INVESTIGATION_ID = ia.INVESTIGATION_ID
GROUP BY 
    fa.ANALYST_ID,
    fa.ANALYST_FNAME,
    fa.ANALYST_LNAME,
    fi_inst.INSTITUTION_NAME
ORDER BY INVESTIGATIONS_ASSIGNED DESC;

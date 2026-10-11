-- Show the total number of on-going investigations 
SELECT COUNT(*) as Number_of_Active_Cases
FROM FRAUD_INVESTIGATION
WHERE INVESTIGATION_STATUS LIKE "In Progress";

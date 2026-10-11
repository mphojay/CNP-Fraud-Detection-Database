-- Show the top three most used transaction channels
SELECT TRANSACTION_CHANNEL, COUNT(*) as Number_of_Transactions
FROM CNP_TRANSACTION
GROUP BY TRANSACTION_CHANNEL
ORDER BY Number_of_Transactions DESC
LIMIT 3;

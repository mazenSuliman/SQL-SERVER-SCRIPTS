DECLARE @CODE VARCHAR(50) = '134'

SELECT  I.Code
		,I.EngName
		,(SELECT Code FROM AccountsMain WHERE ID = @CODE)
		,(SELECT EngName FROM AccountsMain WHERE ID = @CODE)
		,CASE WHEN M.CreditPrice IS NOT NULL THEN IIF(G.ApplyDiscountOut = 1, M.CreditPrice - (M.CreditPrice * (G.CreditDiscountOut/100)), M.CreditPrice)
					ELSE I.CreditPrice - (I.CreditPrice * (ISNULL(G.CreditDiscountOut, 0)/100))
					END AS CREDIT_PRICE_OUT
		,CASE WHEN M.CreditPrice IS NOT NULL THEN IIF(G.ApplyDiscountIN = 1, M.CreditPrice - (M.CreditPrice * (G.CreditDiscountIN/100)), M.CreditPrice)
					ELSE I.CreditPrice - (I.CreditPrice * (ISNULL(G.CreditDiscountIN, 0)/100))
					END AS CREDIT_PRICE_IN
		
FROM ServiceItems I
	LEFT JOIN AccountsMainGroupsDiscs G 
		ON G.ServiceGroupID		= I.ServiceGroupID	AND G.AccountMainID		= (SELECT ID FROM AccountsMain WHERE CODE = @CODE)
	LEFT OUTER JOIN AccountsMainItemsDiscs M 
		ON M.ServiceItemID		= I.ID				AND M.AccountMainID		= (SELECT ID FROM AccountsMain WHERE CODE = @CODE)

WHERE I.CancelDate IS NULL
ORDER BY M.AccountMainID, I.Code
	

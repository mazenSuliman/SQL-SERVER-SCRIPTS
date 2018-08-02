SELECT DISTINCT I.Code AS ITEM_CODE, I.EngName AS ITEM_ENG_NAME, I.ArbName AS ITEM_ARB_NAME,I.CashPrice, I.CreditPrice, G.EngName
FROM TransDtl D
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN TransHdr H ON D.TransHdrID = H.ID
	JOIN ServiceGroups G ON I.ServiceGroupID = G.ID
	LEFT JOIN  AccountsMainItemsDiscs AMD ON AMD.ServiceItemID = I.ID
	LEFT JOIN AccountsMain AM ON AMD.AccountMainID = AM.ID
	LEFT JOIN AccountsContracts AC  ON AC.AccountMainID = AM.ID
WHERE H.AccountID = (SELECT ID FROM Accounts WHERE Code = '9900002')
	AND I.ID NOT IN (SELECT DISTINCT I.ID 
FROM 
	--JOIN ServiceItems I ON D.ServiceItemID = I.ID
	--JOIN TransHdr H ON D.TransHdrID = H.ID
	ServiceItems I	
	JOIN ServiceGroups G ON I.ServiceGroupID = G.ID
	LEFT JOIN  AccountsMainItemsDiscs AMD ON AMD.ServiceItemID = I.ID
	LEFT JOIN AccountsMain AM ON AMD.AccountMainID = AM.ID
	LEFT JOIN AccountsContracts AC  ON AC.AccountMainID = AM.ID
WHERE AC.AccountID = (SELECT ID FROM Accounts WHERE Code = '9900002'))
ORDER BY G.EngName


	
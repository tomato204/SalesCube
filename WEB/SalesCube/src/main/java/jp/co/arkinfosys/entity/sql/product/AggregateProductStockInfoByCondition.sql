SELECT
	/*aggregateMonthsRange*/ AS AGGREGATE_MONTHS_RANGE
	,M.NUM_DEC_ALIGNMENT
	,M.UNIT_PRICE_DEC_ALIGNMENT
	,M.STATS_DEC_ALIGNMENT
	,M.PRICE_FRACT_CATEGORY
	,M.PRODUCT_FRACT_CATEGORY
	,P.PRODUCT_CODE
	,P.PRODUCT_NAME
	,P.RACK_CODE
	,R.RACK_NAME
	,IFNULL(P.AVG_SHIP_COUNT, 0) AS AVG_SHIP_COUNT
	,IFNULL(P.MAX_STOCK_NUM, 0) AS MAX_STOCK_NUM
	,IFNULL(P.PO_NUM, 0) AS PO_NUM
	,IFNULL(P.PO_LOT, 0) AS PO_LOT
	,P.SUPPLIER_PRICE_YEN
	,P.SUPPLIER_PRICE_DOL
	,P.RETAIL_PRICE
	,IFNULL(P.LEAD_TIME, 0) AS LEAD_TIME
	,IFNULL(P.SALES_STANDARD_DEVIATION, 0) AS SALES_STANDARD_DEVIATION
	,IFNULL(P.MINE_SAFETY_STOCK, 0) AS MINE_SAFETY_STOCK
	,IFNULL(P.ENTRUST_SAFETY_STOCK, 0) AS ENTRUST_SAFETY_STOCK

	,IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) AS STOCK_QUANTITY_EAD_UNCLOSED	                                                            -- 未締の入出庫数量
	,IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) AS STOCK_QUANTITY_EAD_CLOSED                                                                    -- 前月締時点の在庫数
	,IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) AS CURRENT_STOCK_QUANTITY  -- 現在庫数
	,IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) -
	 IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0) AS AVAILABLE_STOCK_QUANTITY                                                                                       -- 引当可能数

	,IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) AS STOCK_QUANTITY_ENTRUST_EAD                                                                 -- 委託在庫数
	,IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0) AS REST_QUANTITY_RO                                                                                               -- 受注残数

	,IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) AS REST_QUANTITY_PO_SHIP                                                                                -- AIR便発注残数
	,IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) AS REST_QUANTITY_PO_AIR                                                                                   -- 船便発注残数
	,IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) AS REST_QUANTITY_PO_DELIVERY                                                                    -- 宅配便発注残数
	,IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) +
	 IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) AS REST_QUANTITY_PO                                                                             -- 発注残数
	,IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) AS REST_QUANTITY_ENTRUST                                                                                -- 委託発注残数

	,DELIVERY_DATE.DELIVERY_DATE AS DELIVERY_DATE                                                                                                                   -- 最短入荷日

	,IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) +	-- 現在庫数
 	 IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +	-- 委託在庫数
 	 IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) + 	-- 発注残数
 	 IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -	-- 委託発注残
 	 IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0)	-- 受注残数
 		AS HOLDING_STOCK_QUANTITY	-- 保有数

 	/*IF aggregateMonthsRange == null*/
	,(IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) +
 	 IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +
 	 IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) +
 	 IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -
 	 IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0) )	-- 保有数
	  / P.AVG_SHIP_COUNT AS HOLDING_STOCK_MONTH	-- 保有月数
	/*END*/

	/*IF aggregateMonthsRange != null*/
	,(IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) +
 	 IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +
 	 IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) +
 	 IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -
 	 IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0) )	-- 保有数
	  / ( IFNULL(SALES_QUANTITY.SALES_QUANTITY, 0) / (/*aggregateMonthsRange*/ + 1) ) AS HOLDING_STOCK_MONTH	-- 保有月数
	,IFNULL(RO_QUANTITY.RO_QUANTITY, 0) AS RO_QUANTITY
	,IFNULL(SALES_QUANTITY.SALES_QUANTITY, 0) AS SALES_QUANTITY
	,IFNULL(MAX_SALES_QUANTITY.MAX_SALES_QUANTITY, 0) AS MAX_SALES_QUANTITY
	,IFNULL(RETAIL_PRICE_TOTAL.RETAIL_PRICE_TOTAL, 0) AS RETAIL_PRICE_TOTAL
	,IFNULL(GROSS_MARGIN_TOTAL.GROSS_MARGIN_TOTAL, 0) AS GROSS_MARGIN_TOTAL
	/*END*/

 	,((IFNULL(P.LEAD_TIME, 0) + IFNULL(M.MAX_ENTRUST_PO_TIMELAG, 0)) * IFNULL(P.AVG_SHIP_COUNT / 30, 0)) - (
	IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) +
 	IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +
 	IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) +
 	IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -
 	IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0)) + IFNULL(P.ENTRUST_SAFETY_STOCK, 0) AS ENTRUST_PO_NUM															-- 委託在庫の発注数

	/*IF addPOrderInfo == true */
	,POS.PO_SLIP_ID
	/*END*/
FROM
	MINE_MST_/*$domainId*/ M, PRODUCT_MST_/*$domainId*/ P
	LEFT OUTER JOIN RACK_MST_/*$domainId*/ R
		ON P.RACK_CODE = R.RACK_CODE
	LEFT OUTER JOIN
	-- [未締の入出庫数量]
	(
		SELECT
			IFNULL(SUM(CASE WHEN ES.EAD_CATEGORY = '1' THEN EL.QUANTITY WHEN ES.EAD_CATEGORY = '2' THEN (-1) * EL.QUANTITY END), 0) AS STOCK_QUANTITY_EAD_UNCLOSED
			,EL.PRODUCT_CODE
    	FROM
    		EAD_LINE_TRN_/*$domainId*/ EL INNER JOIN EAD_SLIP_TRN_/*$domainId*/ ES ON EL.EAD_SLIP_ID = ES.EAD_SLIP_ID
    		INNER JOIN RACK_MST_/*$domainId*/ R ON EL.RACK_CODE = R.RACK_CODE
    	WHERE
    		ES.STOCK_PDATE IS NULL AND R.RACK_CATEGORY = '1'
    		AND ES.EAD_DATE <= CURDATE()	-- 未来日伝票は除外
    	GROUP BY EL.PRODUCT_CODE
	) AS STOCK_QUANTITY_EAD_UNCLOSED
	ON P.PRODUCT_CODE = STOCK_QUANTITY_EAD_UNCLOSED.PRODUCT_CODE
	LEFT OUTER JOIN
   	-- [前月締時点の在庫数]
	(
		SELECT
			IFNULL(SUM(PS.STOCK_NUM), 0) AS STOCK_QUANTITY_EAD_CLOSED
			,PS.PRODUCT_CODE
    	FROM
    		PRODUCT_STOCK_TRN_/*$domainId*/ PS LEFT OUTER JOIN RACK_MST_/*$domainId*/ R ON PS.RACK_CODE = R.RACK_CODE AND R.RACK_CATEGORY = '1'
    		INNER JOIN (SELECT PS2.PRODUCT_CODE, MAX(PS2.STOCK_PDATE) AS STOCK_PDATE FROM PRODUCT_STOCK_TRN_/*$domainId*/ PS2 GROUP BY PS2.PRODUCT_CODE) A
    		ON A.PRODUCT_CODE = PS.PRODUCT_CODE AND A.STOCK_PDATE = PS.STOCK_PDATE
        GROUP BY PS.PRODUCT_CODE
    ) AS STOCK_QUANTITY_EAD_CLOSED
	ON P.PRODUCT_CODE = STOCK_QUANTITY_EAD_CLOSED.PRODUCT_CODE
	LEFT OUTER JOIN
    -- [委託在庫数]
    (
    	SELECT
			IFNULL(SUM(EEL.QUANTITY), 0) AS STOCK_QUANTITY_ENTRUST_EAD
			,EEL.PRODUCT_CODE
    	FROM
    		ENTRUST_EAD_LINE_TRN_/*$domainId*/ EEL
    	WHERE
    		EEL.ENTRUST_EAD_CATEGORY = '1' AND EEL.REL_ENTRUST_EAD_LINE_ID IS NULL
    	GROUP BY EEL.PRODUCT_CODE
    ) AS STOCK_QUANTITY_ENTRUST_EAD
	ON P.PRODUCT_CODE = STOCK_QUANTITY_ENTRUST_EAD.PRODUCT_CODE
	LEFT OUTER JOIN
    -- [受注残数]
    (
		SELECT
			IFNULL(SUM(RO_TOTAL.REST_QUANTITY), 0) AS REST_QUANTITY_RO
			,RO_TOTAL.PRODUCT_CODE
		FROM
			(
			-- [受注伝票の数量]
				SELECT
					RL.PRODUCT_CODE
					,RL.QUANTITY AS REST_QUANTITY
				FROM
					RO_LINE_TRN_/*$domainId*/ RL
			-- [売上伝票の数量]
				UNION ALL
				SELECT
					SL.PRODUCT_CODE AS PRODUCT_CODE
					,-SL.QUANTITY AS REST_QUANTITY
				FROM
					SALES_SLIP_TRN_/*$domainId*/ SS
					INNER JOIN SALES_LINE_TRN_/*$domainId*/ SL ON SS.SALES_SLIP_ID = SL.SALES_SLIP_ID
				WHERE
					SS.SALES_DATE <= CURDATE()	-- 未来日伝票は除外
					AND SL.RO_LINE_ID IS NOT NULL
			-- [受注伝票の数量（セット品を分解）]
				UNION ALL
				SELECT
					PS.PRODUCT_CODE
					,RL.QUANTITY * PS.QUANTITY AS REST_QUANTITY
				FROM
					RO_LINE_TRN_/*$domainId*/ RL
					INNER JOIN PRODUCT_SET_MST_/*$domainId*/ PS ON RL.PRODUCT_CODE = PS.SET_PRODUCT_CODE
			-- [売上伝票の数量（セット品を分解）]
				UNION ALL
				SELECT
					PS.PRODUCT_CODE AS PRODUCT_CODE
					,-SL.QUANTITY * PS.QUANTITY AS REST_QUANTITY
				FROM
					SALES_SLIP_TRN_/*$domainId*/ SS
					INNER JOIN SALES_LINE_TRN_/*$domainId*/ SL ON SS.SALES_SLIP_ID = SL.SALES_SLIP_ID
					INNER JOIN PRODUCT_SET_MST_/*$domainId*/ PS ON SL.PRODUCT_CODE = PS.SET_PRODUCT_CODE
				WHERE
					SS.SALES_DATE <= CURDATE()	-- 未来日伝票は除外
					AND SL.RO_LINE_ID IS NOT NULL
			) RO_TOTAL
		GROUP BY
			RO_TOTAL.PRODUCT_CODE
		HAVING
			IFNULL(SUM(RO_TOTAL.REST_QUANTITY), 0) <> 0
	) AS REST_QUANTITY_RO
	ON P.PRODUCT_CODE = REST_QUANTITY_RO.PRODUCT_CODE
	LEFT OUTER JOIN
    -- [船便発注残数]
    (
		SELECT
			IFNULL(SUM(PX.QUANTITY),0) AS REST_QUANTITY_PO_SHIP
			,PX.PRODUCT_CODE
		FROM
		(
			-- [発注伝票の数量]
			SELECT
				PL.QUANTITY AS QUANTITY
				,PL.PRODUCT_CODE
	    	FROM
			PO_LINE_TRN_/*$domainId*/ PL
			INNER JOIN PO_SLIP_TRN_/*$domainId*/ PS ON PL.PO_SLIP_ID = PS.PO_SLIP_ID
			WHERE
	    		PS.TRANSPORT_CATEGORY ='1'
			-- [仕入伝票の数量]
			UNION ALL
			SELECT
				-SL.QUANTITY AS QUANTITY
				,SL.PRODUCT_CODE
			FROM
				SUPPLIER_LINE_TRN_/*$domainId*/ SL
				INNER JOIN SUPPLIER_SLIP_TRN_/*$domainId*/ SS ON SS.SUPPLIER_SLIP_ID = SL.SUPPLIER_SLIP_ID
				INNER JOIN PO_SLIP_TRN_/*$domainId*/ PS ON SS.PO_SLIP_ID = PS.PO_SLIP_ID
			WHERE
				SS.SUPPLIER_DATE <= CURDATE()	-- 未来日伝票は除外
	    		AND PS.TRANSPORT_CATEGORY ='1'
		) PX
		GROUP BY PX.PRODUCT_CODE
		HAVING IFNULL(SUM(PX.QUANTITY),0) <> 0
    ) AS REST_QUANTITY_PO_SHIP
    ON P.PRODUCT_CODE = REST_QUANTITY_PO_SHIP.PRODUCT_CODE
    LEFT OUTER JOIN
    -- [AIR便発注残数]
    (
		SELECT
			IFNULL(SUM(PX.QUANTITY),0) AS REST_QUANTITY_PO_AIR
			,PX.PRODUCT_CODE
		FROM
		(
			-- [発注伝票の数量]
			SELECT
				PL.QUANTITY AS QUANTITY
				,PL.PRODUCT_CODE
	    	FROM
			PO_LINE_TRN_/*$domainId*/ PL
			INNER JOIN PO_SLIP_TRN_/*$domainId*/ PS ON PL.PO_SLIP_ID = PS.PO_SLIP_ID
			WHERE
	    		PS.TRANSPORT_CATEGORY ='2'
			-- [仕入伝票の数量]
			UNION ALL
			SELECT
				-SL.QUANTITY AS QUANTITY
				,SL.PRODUCT_CODE
			FROM
				SUPPLIER_LINE_TRN_/*$domainId*/ SL
				INNER JOIN SUPPLIER_SLIP_TRN_/*$domainId*/ SS ON SS.SUPPLIER_SLIP_ID = SL.SUPPLIER_SLIP_ID
				INNER JOIN PO_SLIP_TRN_/*$domainId*/ PS ON SS.PO_SLIP_ID = PS.PO_SLIP_ID
			WHERE
				SS.SUPPLIER_DATE <= CURDATE()	-- 未来日伝票は除外
	    		AND PS.TRANSPORT_CATEGORY ='2'
		) PX
		GROUP BY PX.PRODUCT_CODE
		HAVING IFNULL(SUM(PX.QUANTITY),0) <> 0
	) AS REST_QUANTITY_PO_AIR
    ON P.PRODUCT_CODE = REST_QUANTITY_PO_AIR.PRODUCT_CODE
    LEFT OUTER JOIN
    -- [宅配便発注残数]
    (
		SELECT
			IFNULL(SUM(PX.QUANTITY),0) AS REST_QUANTITY_PO_DELIVERY
			,PX.PRODUCT_CODE
		FROM
		(
			-- [発注伝票の数量]
			SELECT
				PL.QUANTITY AS QUANTITY
				,PL.PRODUCT_CODE
	    	FROM
			PO_LINE_TRN_/*$domainId*/ PL
			INNER JOIN PO_SLIP_TRN_/*$domainId*/ PS ON PL.PO_SLIP_ID = PS.PO_SLIP_ID
			WHERE
	    		PS.TRANSPORT_CATEGORY ='4'
			-- [仕入伝票の数量]
			UNION ALL
			SELECT
				-SL.QUANTITY AS QUANTITY
				,SL.PRODUCT_CODE
			FROM
				SUPPLIER_LINE_TRN_/*$domainId*/ SL
				INNER JOIN SUPPLIER_SLIP_TRN_/*$domainId*/ SS ON SS.SUPPLIER_SLIP_ID = SL.SUPPLIER_SLIP_ID
				INNER JOIN PO_SLIP_TRN_/*$domainId*/ PS ON SS.PO_SLIP_ID = PS.PO_SLIP_ID
			WHERE
				SS.SUPPLIER_DATE <= CURDATE()	-- 未来日伝票は除外
	    		AND PS.TRANSPORT_CATEGORY ='4'
		) PX
		GROUP BY PX.PRODUCT_CODE
		HAVING IFNULL(SUM(PX.QUANTITY),0) <> 0
	) AS REST_QUANTITY_PO_DELIVERY
    ON P.PRODUCT_CODE = REST_QUANTITY_PO_DELIVERY.PRODUCT_CODE
    LEFT OUTER JOIN
    -- [委託発注残数]
    (
		SELECT
        	IFNULL(SUM(PL.REST_QUANTITY), 0) AS REST_QUANTITY_ENTRUST
        	,PL.PRODUCT_CODE
    	FROM
    		PO_LINE_TRN_/*$domainId*/ PL INNER JOIN PO_SLIP_TRN_/*$domainId*/ PS ON PL.PO_SLIP_ID = PS.PO_SLIP_ID
		WHERE
    		PL.STATUS <> '9' AND PS.TRANSPORT_CATEGORY = '3'
    	GROUP BY PL.PRODUCT_CODE
	    ) AS REST_QUANTITY_ENTRUST
	ON P.PRODUCT_CODE = REST_QUANTITY_ENTRUST.PRODUCT_CODE
	LEFT OUTER JOIN
   	    -- [最短入荷日]
    (
		SELECT
			MIN(PL.DELIVERY_DATE) AS DELIVERY_DATE
			,PL.PRODUCT_CODE
		FROM
			PO_LINE_TRN_/*$domainId*/ PL
		WHERE
			PL.STATUS <> '9'
		GROUP BY PL.PRODUCT_CODE
    ) AS DELIVERY_DATE
	ON P.PRODUCT_CODE = DELIVERY_DATE.PRODUCT_CODE
    /*IF aggregateMonthsRange != null*/
	LEFT OUTER JOIN
    -- [受注数量]
    (
		SELECT
			IFNULL(SUM(RL.QUANTITY), 0) AS RO_QUANTITY
			,RL.PRODUCT_CODE
		FROM
			RO_SLIP_TRN_/*$domainId*/ RS INNER JOIN RO_LINE_TRN_/*$domainId*/ RL ON RS.RO_SLIP_ID = RL.RO_SLIP_ID
		WHERE
			RS.RO_DATE BETWEEN DATE_FORMAT(DATE_SUB(now(), interval /*aggregateMonthsRange*/ month), '%Y-%m-01') AND now()
		GROUP BY RL.PRODUCT_CODE
    ) AS RO_QUANTITY
    ON P.PRODUCT_CODE = RO_QUANTITY.PRODUCT_CODE
    LEFT OUTER JOIN
    -- [出荷数量]
    (
		SELECT
			IFNULL(SUM(SL.QUANTITY), 0) AS SALES_QUANTITY
			,SL.PRODUCT_CODE
		FROM
			SALES_SLIP_TRN_/*$domainId*/ SS INNER JOIN SALES_LINE_TRN_/*$domainId*/ SL ON SS.SALES_SLIP_ID = SL.SALES_SLIP_ID
		WHERE
			SS.SALES_DATE BETWEEN DATE_FORMAT(DATE_SUB(now(), interval /*aggregateMonthsRange*/ month), '%Y-%m-01') AND now()
		GROUP BY SL.PRODUCT_CODE
    ) AS SALES_QUANTITY
	ON P.PRODUCT_CODE = SALES_QUANTITY.PRODUCT_CODE
	LEFT OUTER JOIN
    -- [過去最大出荷数量]
	(
		SELECT
			IFNULL(MAX(SL.QUANTITY), 0) AS MAX_SALES_QUANTITY
			,SL.PRODUCT_CODE
		FROM
			SALES_LINE_TRN_/*$domainId*/ SL
		GROUP BY SL.PRODUCT_CODE
	) AS MAX_SALES_QUANTITY
	ON P.PRODUCT_CODE = MAX_SALES_QUANTITY.PRODUCT_CODE
	LEFT OUTER JOIN
	-- [売上金額]
	(
		SELECT
			IFNULL(SUM(SL.RETAIL_PRICE), 0) AS RETAIL_PRICE_TOTAL
			,SL.PRODUCT_CODE
		FROM
			SALES_SLIP_TRN_/*$domainId*/ SS INNER JOIN SALES_LINE_TRN_/*$domainId*/ SL ON SS.SALES_SLIP_ID = SL.SALES_SLIP_ID
		WHERE
			SS.SALES_DATE BETWEEN DATE_FORMAT(DATE_SUB(now(), interval /*aggregateMonthsRange*/ month), '%Y-%m-01') AND now()
		GROUP BY SL.PRODUCT_CODE
	) AS RETAIL_PRICE_TOTAL
	ON P.PRODUCT_CODE = RETAIL_PRICE_TOTAL.PRODUCT_CODE
	LEFT OUTER JOIN
	-- [粗利益]
	(
		SELECT
			IFNULL(SUM(SL.GM), 0) AS GROSS_MARGIN_TOTAL
			,SL.PRODUCT_CODE
		FROM
			SALES_SLIP_TRN_/*$domainId*/ SS INNER JOIN SALES_LINE_TRN_/*$domainId*/ SL ON SS.SALES_SLIP_ID = SL.SALES_SLIP_ID
		WHERE
			SS.SALES_DATE BETWEEN DATE_FORMAT(DATE_SUB(now(), interval /*aggregateMonthsRange*/ month), '%Y-%m-01') AND now()
		GROUP BY SL.PRODUCT_CODE
	) AS GROSS_MARGIN_TOTAL
	ON P.PRODUCT_CODE = GROSS_MARGIN_TOTAL.PRODUCT_CODE
	/*END*/
	/*IF addPOrderInfo == true */
	INNER JOIN PO_LINE_TRN_/*$domainId*/ POL ON POL.PRODUCT_CODE = P.PRODUCT_CODE INNER JOIN PO_SLIP_TRN_/*$domainId*/ POS ON POL.PO_SLIP_ID = POS.PO_SLIP_ID
	/*END*/
/*BEGIN*/
WHERE
	/*IF addPOrderInfo == true */
	AND POS.TRANSPORT_CATEGORY = '3' -- 委託在庫発注
	AND POL.STATUS = '2' -- 委託在庫生産完了
	/*END*/

	/*IF roExists == true*/
	AND EXISTS (
		SELECT 1 FROM RO_LINE_TRN_/*$domainId*/ PL WHERE PL.PRODUCT_CODE=P.PRODUCT_CODE
	)
	/*END*/

	/*IF productCode != null*/
	AND P.PRODUCT_CODE = /*productCode*/	-- 商品コード
	/*END*/

	/*IF supplierCode != null*/
	AND P.SUPPLIER_CODE = /*supplierCode*/	-- 仕入先コード
	/*END*/

	/*IF setTypeCategory != null*/
	AND P.SET_TYPE_CATEGORY = /*setTypeCategory*/	-- セット商品区分
	/*END*/

	/*IF productStatusCategory != null*/
	AND P.PRODUCT_STATUS_CATEGORY = /*productStatusCategory*/	-- 販売
	/*END*/

	/*IF stockCtlCategory != null*/
	AND P.STOCK_CTL_CATEGORY = /*stockCtlCategory*/	-- 在庫管理
	/*END*/

	/*IF productStockCategory != null*/
	AND P.PRODUCT_STOCK_CATEGORY = /*productStockCategory*/	-- 自社在庫品
	/*END*/

	/*IF productStandardCategory != null*/
	AND P.PRODUCT_STANDARD_CATEGORY = /*productStandardCategory*/	-- 標準品
	/*END*/

	/*IF rackMultiFlag != null*/
	AND R.MULTI_FLAG = /*rackMultiFlag*/	-- 重複可能棚
	/*END*/

	/*IF holdingStockLessThanPoNum == true */
	AND (IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) +	-- 現在庫数
	 	IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +	-- 委託在庫数
	 	IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) + 	-- 発注残数
	 	IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -	-- 委託発注残
	 	IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0)) <= PO_NUM
	/*END*/

	/*IF entrustStockZero == true */
	AND IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) = 0
	/*END*/

	/*IF entrustStockLargerThanZero == true */
	AND IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) >= 1
	/*END*/

	/*IF entrustPOrderQuantityLargerThanZero == true */
	AND ((IFNULL(P.LEAD_TIME, 0) + IFNULL(M.MAX_ENTRUST_PO_TIMELAG, 0)) * IFNULL(P.AVG_SHIP_COUNT / 30, 0)) - (			-- (委託在庫の最大調達期間×平均出荷数(日)) - 保有数 + 委託安全在庫
		IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) +
	 	IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +
	 	IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) +
	 	IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -
	 	IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0)) + IFNULL(P.ENTRUST_SAFETY_STOCK, 0) > 0
	/*END*/

	/*IF excludeHoldingStockZero == true */
	AND (IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) + -- 保有数 <> 0
	 	IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +
	 	IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) +
	 	IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -
	 	IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0)) <> 0
	/*END*/

	/*IF excludeAvgShipCountZero == true */
	AND IFNULL(P.AVG_SHIP_COUNT, 0) <> 0
	/*END*/

	/*IF excludeAvgLessThanHoldingStock == true */
	AND (IFNULL(STOCK_QUANTITY_EAD_UNCLOSED.STOCK_QUANTITY_EAD_UNCLOSED, 0) + IFNULL(STOCK_QUANTITY_EAD_CLOSED.STOCK_QUANTITY_EAD_CLOSED, 0) + -- 保有数 <= 平均出荷数
	 	IFNULL(STOCK_QUANTITY_ENTRUST_EAD.STOCK_QUANTITY_ENTRUST_EAD, 0) +
	 	IFNULL(REST_QUANTITY_PO_SHIP.REST_QUANTITY_PO_SHIP, 0) + IFNULL(REST_QUANTITY_PO_AIR.REST_QUANTITY_PO_AIR, 0) + IFNULL(REST_QUANTITY_PO_DELIVERY.REST_QUANTITY_PO_DELIVERY, 0) +
	 	IFNULL(REST_QUANTITY_ENTRUST.REST_QUANTITY_ENTRUST, 0) -
	 	IFNULL(REST_QUANTITY_RO.REST_QUANTITY_RO, 0)) <= P.AVG_SHIP_COUNT
	/*END*/
/*END*/
/*BEGIN*/
ORDER BY
	/*IF sortColumn != null && sortOrder != null  */
		/*$sortColumn*/
		/*$sortOrder*/
	/*END*/
/*END*/

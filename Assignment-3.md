# SQL Assignment 3

### 1 Completed Sales Orders (Physical Items)

**Business Problem:**  
Merchants need to track only physical items (requiring shipping and fulfillment) for logistics and shipping-cost analysis.

**Fields to Retrieve:**  
- `ORDER_ID`  
- `ORDER_ITEM_SEQ_ID`  
- `PRODUCT_ID`  
- `PRODUCT_TYPE_ID`  
- `SALES_CHANNEL_ENUM_ID`  
- `ORDER_DATE`  
- `ENTRY_DATE`  
- `STATUS_ID`  
- `STATUS_DATETIME`  
- `ORDER_TYPE_ID`  
- `PRODUCT_STORE_ID`  

**SQL:** 
```sql
SELECT 
    OI.ORDER_ID,
    OI.ORDER_ITEM_SEQ_ID,
    OI.PRODUCT_ID,
    P.PRODUCT_TYPE_ID,
    OH.SALES_CHANNEL_ENUM_ID,
    OH.ORDER_DATE,
    OH.ENTRY_DATE,
    OH.STATUS_ID,
    OS.STATUS_DATETIME,
    OH.ORDER_TYPE_ID,
    OH.PRODUCT_STORE_ID
FROM ORDER_HEADER OH 
JOIN ORDER_ITEM OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN ORDER_STATUS OS ON OH.ORDER_ID = OS.ORDER_ID 
JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
JOIN PRODUCT_TYPE  PT ON P.PRODUCT_TYPE_ID = PT.PRODUCT_TYPE_ID
WHERE OH.STATUS_ID = "ORDER_COMPLETED" AND  OH.ORDER_TYPE_ID = "SALES_ORDER"
AND PT.IS_PHYSICAL = "Y";
```
**Execution Plan:**

<img width="939" height="332" alt="1" src="https://github.com/user-attachments/assets/6cc078a3-3287-47ac-8bec-4dc13626d0fe" />


### 2 Completed Return Items

**Business Problem:**  
Customer service and finance often need insights into **returned items** to manage refunds, replacements, and inventory restocking.

**Fields to Retrieve:**  
- `RETURN_ID`  
- `ORDER_ID`  
- `PRODUCT_STORE_ID`  
- `STATUS_DATETIME`  
- `ORDER_NAME`  
- `FROM_PARTY_ID`
- `RETURN_DATE`  
- `ENTRY_DATE`  
- `RETURN_CHANNEL_ENUM_ID`
**SQL:** 
```sql
SELECT 
	RH.RETURN_ID,
	OH.ORDER_ID,
	OH.PRODUCT_STORE_ID,
	RS.STATUS_DATETIME,
	OH.ORDER_NAME,
	RH.FROM_PARTY_ID,
	RH.RETURN_DATE,
	RH.ENTRY_DATE,
	RH.RETURN_CHANNEL_ENUM_ID 
FROM RETURN_HEADER RH
JOIN RETURN_ITEM RI ON RI.RETURN_ID = RH.RETURN_ID AND RI.STATUS_ID = "RETURN_COMPLETED"
JOIN ORDER_HEADER OH ON RI.ORDER_ID = OH.ORDER_ID
JOIN RETURN_STATUS RS ON RH.RETURN_ID = RS.RETURN_ID AND RS.STATUS_ID = "RETURN_COMPLETED";
```
**Execution Plan:**

<img width="712" height="332" alt="2" src="https://github.com/user-attachments/assets/a2452dcc-9dbb-470c-aaa8-0da4fae52fb4" />


### 3 Single-Return Orders (Last Month)

**Business Problem:**  
The mechandising team needs a list of orders that only have one return.

**Fields to Retrieve:**  
- `PARTY_ID`  
- `FIRST_NAME`
**SQL:** 
```sql
SELECT DISTINCT
    PR.PARTY_ID,
    PR.FIRST_NAME
FROM RETURN_HEADER RH
JOIN PERSON PR ON RH.FROM_PARTY_ID = PR.PARTY_ID
JOIN RETURN_ITEM RI ON RI.RETURN_ID = RH.RETURN_ID
WHERE RH.FROM_PARTY_ID != '_NA_' AND MONTH(RH.RETURN_DATE) = MONTH(CURRENT_DATE) - 1
GROUP BY RH.RETURN_ID
HAVING COUNT(RI.ORDER_ID) = 1;
```
**Execution Plan:**

<img width="657" height="417" alt="3" src="https://github.com/user-attachments/assets/c5fbab31-9a1a-40dc-bc9a-c258fcc5f22d" />


### 4 Returns and Appeasements 

**Business Problem:**  
The retailer needs the total amount of items, were returned as well as how many appeasements were issued.

**Fields to Retrieve:**  
- `TOTAL RETURNS`
- `RETURN $ TOTAL`
- `TOTAL APPEASEMENTS`
- `APPEASEMENTS $ TOTAL`
**SQL:** 
```sql
SELECT 
    COUNT(RI.RETURN_ID) AS TOTAL_RETURN,
    SUM(RI.RETURN_PRICE * RI.RETURN_QUANTITY) AS TOTAL_RETURN_VALUE,
    COUNT(RA.RETURN_ID) AS TOTAL_APPEASEMENT,
    SUM(RA.AMOUNT) AS TOTAL_APPEASEMENT_VALUE
FROM RETURN_ITEM RI
JOIN RETURN_ADJUSTMENT RA ON RA.RETURN_ID = RI.RETURN_ID;
```
**Execution Plan:**

<img width="362" height="328" alt="4" src="https://github.com/user-attachments/assets/43cd06db-7a91-4be3-b051-d4c43c6044d2" />


### 5 Detailed Return Information

**Business Problem:**  
Certain teams need granular return data (reason, date, refund amount) for analyzing return rates, identifying recurring issues, or updating policies.

**Fields to Retrieve:**  
- `RETURN_ID`  
- `ENTRY_DATE`  
- `RETURN_ADJUSTMENT_TYPE_ID` (refund type, store credit, etc.)  
- `AMOUNT`  
- `COMMENTS`  
- `ORDER_ID`  
- `ORDER_DATE`  
- `RETURN_DATE`  
- `PRODUCT_STORE_ID`
**SQL:** 
```sql
SELECT 
    RH.RETURN_ID,
    RH.ENTRY_DATE,
    RA.RETURN_ADJUSTMENT_TYPE_ID,
    RA.AMOUNT,
    RA.COMMENTS,
    OH.ORDER_ID,
    OH.ORDER_DATE,
    RH.RETURN_DATE,
    OH.PRODUCT_STORE_ID
FROM RETURN_ITEM RI
JOIN ORDER_HEADER OH ON RI.ORDER_ID = OH.ORDER_ID
JOIN RETURN_HEADER RH ON RI.RETURN_ID = RH.RETURN_ID
JOIN RETURN_ADJUSTMENT RA ON RA.RETURN_ID = RI.RETURN_ID;
```
**Execution Plan:**

<img width="712" height="328" alt="5" src="https://github.com/user-attachments/assets/14fadbf6-b6a9-4214-8f98-b06b1fa10f1c" />

### 6 Orders with Multiple Returns

**Business Problem:**  
Analyzing orders with multiple returns can identify potential fraud, chronic issues with certain items, or inconsistent shipping processes.

**Fields to Retrieve:**  
- `ORDER_ID`  
- `RETURN_ID`  
- `RETURN_DATE`  
- `RETURN_REASON`  
- `RETURN_QUANTITY`
**SQL:** 
```sql
SELECT 
	RI.ORDER_ID,
	RI.RETURN_ID,
	RH.RETURN_DATE,
	RR.DESCRIPTION AS RETURN_REASON,
	RI.RETURN_QUANTITY
FROM RETURN_HEADER RH 
JOIN RETURN_ITEM RI ON RH.RETURN_ID = RI.RETURN_ID
JOIN RETURN_REASON RR ON RI.RETURN_REASON_ID = RR.RETURN_REASON_ID
WHERE RI.ORDER_ID  IN (
    SELECT ORDER_ID  FROM RETURN_ITEM GROUP BY ORDER_ID HAVING COUNT(RETURN_ID) > 1
);
```
**Execution Plan:**

<img width="682" height="578" alt="6" src="https://github.com/user-attachments/assets/75778134-f5fa-47d4-bb1b-af9d60a575d1" />

### 7 Store with Most One-Day Shipped Orders (Last Month)

**Business Problem:**  
Identify which facility (store) handled the highest volume of “one-day shipping” orders in the previous month, useful for operational benchmarking.

**Fields to Retrieve:**  
- `FACILITY_ID`
- `FACILITY_NAME`  
- `TOTAL_ONE_DAY_SHIP_ORDERS`  
- `REPORTING_PERIOD`
**SQL:** 
```sql
SELECT 
    F.FACILITY_ID,
    F.FACILITY_NAME,
    COUNT(OSIG.ORDER_ID) AS TOTAL_ONE_DAY_SHIP_ORDERS
FROM FACILITY F 
JOIN ORDER_ITEM_SHIP_GROUP  OSIG ON F.FACILITY_ID = OSIG.FACILITY_ID AND OSIG.SHIPMENT_METHOD_TYPE_ID = "NEXT_DAY"
JOIN ORDER_HEADER OH ON OH.ORDER_ID = OSIG.ORDER_ID
WHERE OH.ORDER_DATE >= DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '23-%M-01') AND OH.ORDER_DATE < DATE_FORMAT(NOW(), '23-%M-01')
GROUP BY F.FACILITY_ID , F.FACILITY_NAME 
ORDER BY TOTAL_ONE_DAY_SHIP_ORDERS DESC
LIMIT 1;
```
**Execution Plan:**

<img width="671" height="417" alt="7" src="https://github.com/user-attachments/assets/6ba1674d-babc-454c-87bd-bfabc31f8ad0" />

### 8 List of Warehouse Pickers

**Business Problem:**  
Warehouse managers need a list of employees responsible for picking and packing orders to manage shifts, productivity, and training needs.

**Fields to Retrieve:**  
- `PARTY_ID` (or Employee ID)  
- `NAME` (First/Last)  
- `ROLE_TYPE_ID` (e.g., “WAREHOUSE_PICKER”)  
- `FACILITY_ID` (assigned warehouse)  
- `STATUS` (active or inactive employee)
**SQL:** 
```sql
SELECT DISTINCT
    (P.PARTY_ID),
    CONCAT(P.FIRST_NAME, ' ', P.LAST_NAME),
    PLR.ROLE_TYPE_ID,
    PL.FACILITY_ID,
    CASE
        WHEN
            PLR.THRU_DATE IS NULL OR PLR.THRU_DATE > CURRENT_DATE()
        THEN
            'ACTIVE'
        ELSE 'INACTIVE'
    END AS STATUS
FROM PICKLIST PL 
JOIN PICKLIST_ROLE PLR ON PL.PICKLIST_ID = PLR.PICKLIST_ID
JOIN PERSON P ON PLR.PARTY_ID = P.PARTY_ID;
```
**Execution Plan:**

<img width="511" height="417" alt="8" src="https://github.com/user-attachments/assets/9f4753fa-cfe7-4e56-ae34-1cddc1b94618" />

---

### 9 Total Facilities That Sell the Product

**Business Problem:**  
Retailers want to see how many (and which) facilities (stores, warehouses, virtual sites) currently offer a product for sale.

**Fields to Retrieve:**  
- `PRODUCT_ID`  
- `PRODUCT_NAME` (or `INTERNAL_NAME`)  
- `FACILITY_COUNT` (number of facilities selling the product)  
- (Optionally) a **list of FACILITY_IDs** if more detail is needed
**SQL:** 
```sql
SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_NAME,
    COUNT(PF.FACILITY_ID) AS FACILITY_COUNT
FROM PRODUCT P
JOIN PRODUCT_FACILITY PF ON P.PRODUCT_ID = PF.PRODUCT_ID
GROUP BY P.PRODUCT_ID, P.PRODUCT_NAME;
```
**Execution Plan:**

<img width="336" height="417" alt="9" src="https://github.com/user-attachments/assets/1ec600d8-a04a-48b3-a80e-dae784be8036" />

---

### 10 Total Items in Various Virtual Facilities

**Business Problem:**  
Retailers need to study the relation of inventory levels of products to the type of facility it's stored at. Retrieve all inventory levels for products at locations and include the facility type Id. Do not retrieve facilities that are of type Virtual.

**Fields to Retrieve:**  
- `PRODUCT_ID`  
- `FACILITY_ID`
- `FACILITY_TYPE_ID`
- `QOH` (Quantity on Hand)  
- `ATP` (Available to Promise)
**SQL:** 
```sql
	SELECT 
	    F.FACILITY_ID,
	    PF.PRODUCT_ID,
	    F.FACILITY_TYPE_ID,
	    SUM(II.AVAILABLE_TO_PROMISE_TOTAL) AS AVAILABLE_TO_PROMISE,
	    SUM(II.QUANTITY_ON_HAND_TOTAL) AS QUANTITY_ON_HAND
	FROM PRODUCT_FACILITY PF
	JOIN INVENTORY_ITEM II ON PF.PRODUCT_ID = II.PRODUCT_ID AND PF.FACILITY_ID = II.FACILITY_ID
	JOIN FACILITY F ON PF.FACILITY_ID = F.FACILITY_ID
	JOIN FACILITY_TYPE FT ON FT.FACILITY_TYPE_ID = F.FACILITY_TYPE_ID 
    WHERE FT.PARENT_TYPE_ID <> 'VIRTUAL_FACILITY'
	GROUP BY
	    F.FACILITY_ID,
	    PF.PRODUCT_ID,
	    F.FACILITY_TYPE_ID;   
```
**Execution Plan:**

<img width="712" height="421" alt="10" src="https://github.com/user-attachments/assets/67330805-9df1-483d-b8c7-41975b34dc1b" />

### 11 Transfer Orders Without Inventory Reservation

**Business Problem:**  
When transferring stock between facilities, the system should reserve inventory. If it isn’t reserved, the transfer may fail or oversell.

**Fields to Retrieve:**  
- `TRANSFER_ORDER_ID`  
- `FROM_FACILITY_ID`  
- `TO_FACILITY_ID`  
- `PRODUCT_ID`  
- `REQUESTED_QUANTITY`  
- `RESERVED_QUANTITY`  
- `TRANSFER_DATE`  
- `STATUS`
**SQL:** 
```sql
SELECT
    IT.INVENTORY_TRANSFER_ID AS TRANSFER_ORDER_ID,
    IT.FACILITY_ID AS FROM_FACILITY_ID,
    IT.FACILITY_ID_TO AS TO_FACILITY_ID,
    ITI.QUANTITY AS RESERVED_QUANTITY,
    IT.SEND_DATE AS TRANSFER_DATE,
    IT.STATUS_ID
FROM INVENTORY_TRANSFER IT
JOIN INVENTORY_ITEM II ON IT.INVENTORY_ITEM_ID = IT.INVENTORY_ITEM_ID 
JOIN ITEM_ISSUANCE ITI ON IT.ITEM_ISSUANCE_ID = ITI.ITEM_ISSUANCE_ID;
```
**Execution Plan:**

<img width="487" height="328" alt="11" src="https://github.com/user-attachments/assets/e0373f1c-52f9-47aa-8ddb-3c98501ee129" />

### 12 Orders Without Picklist

**Business Problem:**  
A picklist is necessary for warehouse staff to gather items. Orders missing a picklist might be delayed and need attention.

**Fields to Retrieve:**  
- `ORDER_ID`  
- `ORDER_DATE`  
- `ORDER_STATUS`  
- `FACILITY_ID`
- `DURATION` (How long has the order been assigned at the facility)
**SQL:** 
```sql
SELECT 
    OH.ORDER_ID,
    OISG.FACILITY_ID,
    OH.ORDER_DATE,
    OH.STATUS_ID,
    PL.STATUS_ID,
    DATEDIFF(DATE(OH.ENTRY_DATE), DATE(OH.ORDER_DATE)) AS DURATION
FROM ORDER_HEADER OH
JOIN ORDER_ITEM_SHIP_GROUP OISG ON OISG.ORDER_ID = OH.ORDER_ID
JOIN PICKLIST PL ON PL.FACILITY_ID = OISG.FACILITY_ID AND PL.STATUS_ID IS NULL; 
```
**Execution Plan:**

<img width="587" height="332" alt="12" src="https://github.com/user-attachments/assets/4fb44eb4-63c7-44c5-a7ae-146fdb712ffd" />

---

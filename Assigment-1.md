# SQL Assignment 1

### 1 New Customers Acquired in June 2023

**Business Problem:**  
The marketing team ran a campaign in June 2023 and wants to see how many new customers signed up during that period.

**Fields to Retrieve:**  
- `PARTY_ID`  
- `FIRST_NAME`  
- `LAST_NAME`  
- `EMAIL`  
- `PHONE`  
- `ENTRY_DATE`

**SQL :** 
```SQL
SELECT 
    per.PARTY_ID,
    DATE(pr.CREATED_STAMP) AS ENTRY_DATE,
    per.FIRST_NAME,
    per.LAST_NAME,
    (SELECT 
            cm.INFO_STRING
        FROM
            contact_mech cm
                JOIN
            party_contact_mech pcm ON per.PARTY_ID = pcm.PARTY_ID
                AND cm.CONTACT_MECH_ID = pcm.CONTACT_MECH_ID
                AND CONTACT_MECH_TYPE_ID = 'EMAIL_ADDRESS'
        LIMIT 1) AS EMAIL,
    (SELECT 
            contact_number
        FROM
            telecom_number tn
                JOIN
            party_contact_mech pcm ON pcm.party_id = per.party_id
                AND tn.contact_mech_id = pcm.contact_mech_id
        LIMIT 1) AS PHONE
FROM
    person AS per
        JOIN
    party_role AS pr ON per.PARTY_ID = pr.PARTY_ID
        AND pr.role_type_id = 'CUSTOMER'
        AND pr.CREATED_STAMP BETWEEN '2023-06-1 00:00:00' AND '2023-07-01 00:00:01';
```
**Execution Plan:**

![ag-01](https://github.com/user-attachments/assets/b4af2128-5e92-43e7-9bf5-09f3128787d4)


### 2 List All Active Physical Products

**Business Problem:**  
Merchandising teams often need a list of all physical products to manage logistics, warehousing, and shipping.

**Fields to Retrieve:**  
- `PRODUCT_ID`  
- `PRODUCT_TYPE_ID`  
- `INTERNAL_NAME`

**SQL :** 
```SQL
  SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_TYPE_ID,
    p.INTERNAL_NAME
FROM
    product p
        JOIN
    product_type pt ON p.PRODUCT_TYPE_ID = pt.PRODUCT_TYPE_ID
        AND IS_PHYSICAL = 'Y';
```

**Execution Plan:**

![ag-02](https://github.com/user-attachments/assets/84e15c47-7687-4be8-bc2c-655968ae4ad9)

### 3 Products Missing NetSuite ID

**Business Problem:**  
A product cannot sync to NetSuite unless it has a valid NetSuite ID. The OMS needs a list of all products that still need to be created or updated in NetSuite.

**Fields to Retrieve:**  
- `PRODUCT_ID`  
- `INTERNAL_NAME`  
- `PRODUCT_TYPE_ID`  
- `NETSUITE_ID` (or similar field indicating the NetSuite ID; may be `NULL` or empty if missing)

**SQL :** 
```SQL
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_TYPE_ID,
    p.INTERNAL_NAME,
    gi.ID_VALUE AS NETSUITE_ID
FROM
    product p
        LEFT JOIN
	good_identification gi ON gi.PRODUCT_ID = p.PRODUCT_ID AND gi.GOOD_IDENTIFICATION_TYPE_ID = 'ERP_ID' AND (gi.ID_VALUE IS NULL OR gi.ID_VALUE = '');
```

**Execution Plan:**

<img width="362" height="337" alt="ag-03" src="https://github.com/user-attachments/assets/03b942ad-f0fd-4522-a56e-55d61f12eaaf" />


### 4 Product IDs Across Systems

**Business Problem:**  
To sync an order or product across multiple systems (e.g., Shopify, HotWax, ERP/NetSuite), the OMS needs to know each system’s unique identifier for that product. This query retrieves the Shopify ID, HotWax ID, and ERP ID (NetSuite ID) for all products.

**Fields to Retrieve:**  
- `PRODUCT_ID` (internal OMS ID)  
- `SHOPIFY_ID`  
- `HOTWAX_ID`  
- `ERP_ID` or `NETSUITE_ID` (depending on naming)

**SQL :** 
```SQL
SELECT 
    p.PRODUCT_ID, 
    erpgi.ID_VALUE AS ERP_ID, 
    spgi.ID_VALUE AS SHOPIFY_PRODUCT_ID
FROM product p
JOIN good_identification erpgi ON erpgi.PRODUCT_ID = p.PRODUCT_ID  and erpgi.GOOD_IDENTIFICATION_TYPE_ID = 'ERP_ID'
JOIN good_identification spgi ON spgi.PRODUCT_ID = p.PRODUCT_ID and spgi.GOOD_IDENTIFICATION_TYPE_ID = 'SHOPIFY_PROD_ID';
```

**Execution Plan:**

<img width="587" height="334" alt="AG-04" src="https://github.com/user-attachments/assets/a586cee4-5f86-4810-aefb-11d1948a6f17" />


### 5 Completed Orders in August 2023

**Business Problem:**  
After running similar reports for a previous month, you now need all completed orders in August 2023 for analysis.

**Fields to Retrieve:**  
- `PRODUCT_ID`  
- `PRODUCT_TYPE_ID`  
- `PRODUCT_STORE_ID`  
- `TOTAL_QUANTITY`  
- `INTERNAL_NAME`  
- `FACILITY_ID`  
- `EXTERNAL_ID`  
- `FACILITY_TYPE_ID`  
- `ORDER_HISTORY_ID`  
- `ORDER_ID`  
- `ORDER_ITEM_SEQ_ID`  
- `SHIP_GROUP_SEQ_ID`

**SQL :** 
```SQL
select p.product_id,
       p.product_type_id,
       oh.product_store_id,
       oi.quantity AS TotalQuantity,
       p.internal_name,
       f.facility_id,
       f.external_id,
       f.facility_type_id,
       orh.order_history_id,
       orh.order_id,
       orh.order_item_seq_id,
       orh.ship_group_seq_id
from Order_Header oh JOIN order_item oi ON oi.order_id=oh.order_id
JOIN product p ON p.product_id=oi.product_id 
JOIN order_history orh ON orh.order_id=oi.order_id and oi.ORDER_ITEM_SEQ_ID = orh.ORDER_ITEM_SEQ_ID
JOIN order_item_ship_group oisg ON oisg.ship_group_seq_id=oi.ship_group_seq_id and oisg.order_id=oi.order_id
JOIN facility f ON f.facility_id=oisg.facility_id 
JOIN order_status os ON os.order_id=oh.order_id
WHERE os.status_id='ORDER_COMPLETED' and date(os.status_datetime)>=date('2023-08-01') AND date(os.status_datetime)<=date('2023-08-31');
```

**Execution Plan:**

<img width="1339" height="333" alt="ag-05" src="https://github.com/user-attachments/assets/69968e92-65c3-4539-b83e-a5559b57ae4b" />


### 6 Newly Created Sales Orders and Payment Methods

**Business Problem:**  
Finance teams need to see new orders and their payment methods for reconciliation and fraud checks.

**Fields to Retrieve:**  
- `ORDER_ID`
- `TOTAL_AMOUNT`
- `PAYMENT_METHOD`  
- `Shopify Order ID` (if applicable)

**SQL :** 
```SQL
SELECT 
    oh.ORDER_ID,
    oh.GRAND_TOTAL AS TOTAL_AMOUNT,
    opp.PAYMENT_METHOD_TYPE_ID AS PAYMENT_METHOD,
    sp.SHOPIFY_ORDER_ID
FROM
    order_header oh
        JOIN
    order_payment_preference opp ON opp.ORDER_ID = oh.ORDER_ID
        JOIN
    shopify_shop_order sp ON sp.ORDER_ID = oh.ORDER_ID;    
```

**Execution Plan:**

<img width="537" height="337" alt="ag-06" src="https://github.com/user-attachments/assets/24f6e3b1-5ca4-46b5-8c95-94ffa5916c4d" />


### 7 Payment Captured but Not Shipped

**Business Problem:**  
Finance teams want to ensure revenue is recognized properly. If payment is captured but no shipment has occurred, it warrants further review.

**Fields to Retrieve:**  
- `ORDER_ID`  
- `ORDER_STATUS`  
- `PAYMENT_STATUS`  
- `SHIPMENT_STATUS`

**SQL :** 
```SQL
SELECT
    oh.ORDER_ID,
    oh.STATUS_ID AS ORDER_STATUS,
    opp.STATUS_ID AS PAYMENT_STATUS,
    sh.STATUS_ID AS SHIPMENT_STATUS
FROM order_header oh
JOIN order_payment_preference opp ON oh.ORDER_ID = opp.ORDER_ID 
JOIN order_shipment os ON oh.ORDER_ID = os.ORDER_ID 
JOIN shipment sh ON os.SHIPMENT_ID = sh.SHIPMENT_ID 
WHERE opp.STATUS_ID = "PAYMENT_SETTLED" AND sh.STATUS_ID != "SHIPMENT_SHIPPED";
```

**Execution Plan:**

![Uploading ag-07.png…]()


### 8 Orders Completed Hourly

**Business Problem:**  
Operations teams may want to see how orders complete across the day to schedule staffing.

**Fields to Retrieve:**  
- `TOTAL ORDERS`  
- `HOUR`

**SQL :** 
```SQL
SELECT
    oh.ORDER_ID,
    oh.STATUS_ID AS ORDER_STATUS,
    opp.STATUS_ID AS PAYMENT_STATUS,
    sh.STATUS_ID AS SHIPMENT_STATUS
FROM order_header oh
JOIN order_payment_preference opp ON oh.ORDER_ID = opp.ORDER_ID 
JOIN order_shipment os ON oh.ORDER_ID = os.ORDER_ID 
JOIN shipment sh ON os.SHIPMENT_ID = sh.SHIPMENT_ID 
WHERE opp.STATUS_ID = "PAYMENT_SETTLED" AND sh.STATUS_ID != "SHIPMENT_SHIPPED";
```

**Execution Plan:**

<img width="752" height="337" alt="AG-08" src="https://github.com/user-attachments/assets/6822f3e2-4a21-4abd-b37d-6c44931d010a" />


### 9 BOPIS Orders Revenue (Last Year)

**Business Problem:**  
**BOPIS** (Buy Online, Pickup In Store) is a key retail strategy. Finance wants to know the revenue from BOPIS orders for the previous year.

**Fields to Retrieve:**  
- `TOTAL ORDERS`  
- `TOTAL REVENUE`

**SQL :** 
```SQL
SELECT 
    COUNT(oh.order_id) AS TOTAL_ORDERS,
    SUM(oh.grand_total) AS TOTAL_REVENUE
FROM
    order_header oh
        JOIN
    order_item_ship_group oisg ON oh.ORDER_ID = oisg.ORDER_ID
        AND oisg.SHIPMENT_METHOD_TYPE_ID = 'STOREPICKUP'
        AND YEAR(oh.entry_date) = YEAR(CURRENT_DATE()) - 1;
```

**Execution Plan:**

<img width="386" height="336" alt="AG-09" src="https://github.com/user-attachments/assets/c86f5d16-e9aa-4138-83f9-1226d821dddc" />


### 10 Canceled Orders (Last Month)

**Business Problem:**  
The merchandising team needs to know how many orders were canceled in the previous month and their reasons.

**Fields to Retrieve:**  
- `TOTAL ORDERS`  
- `CANCELATION REASON`

**SQL :** 
```SQL
select 
  count(*) as TOTAL_ORDER, 
  os.CHANGE_REASON 
from order_status os
where os.status_id = 'ORDER_CANCELLED' and date(STATUS_DATETIME)<="2025-05-31" and date(STATUS_DATETIME)>"2025-04-30"
group by os.CHANGE_REASON;
```

**Execution Plan:**

<img width="211" height="304" alt="AG-10" src="https://github.com/user-attachments/assets/f539edfb-137c-435e-83c6-51a4a8a9514d" />


### 11 Product Threshold Value

**Business Problem**
The retailer has set a threshild value for products that are sold online, in order to avoid over selling. 

**Fields to Retrieve:**
- `PRODUCT ID`
- `THRESHOLD`

**SQL :** 
```SQL
SELECT 
    product_id, minimum_stock AS THRESHOLD
FROM product_facility pf
WHERE minimum_stock IS NOT NULL;
```

**Execution Plan:**

<img width="161" height="201" alt="ag-11" src="https://github.com/user-attachments/assets/d38ac21c-12b2-4e1a-a252-cf9b82f4824a" />



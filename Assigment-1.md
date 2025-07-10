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
    p.PRODUCT_ID, gi.ID_VALUE AS ERP_ID, sp.SHOPIFY_PRODUCT_ID
FROM
    good_identification gi
        JOIN
    product p ON gi.PRODUCT_ID = p.PRODUCT_ID
        JOIN
    shopify_product sp ON sp.PRODUCT_ID = p.PRODUCT_ID;
```

**Execution Plan:**

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
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_TYPE_ID,
    oh.PRODUCT_STORE_ID,
    oi.QUANTITY AS TOTAL_QUANTITY,
    p.INTERNAL_NAME,
    f.FACILITY_ID,
    oi.EXTERNAL_ID,
    f.FACILITY_TYPE_ID,
    ohis.ORDER_HISTORY_ID,
    oh.ORDER_ID,
    oi.ORDER_ITEM_SEQ_ID,
    ohis.SHIP_GROUP_SEQ_ID
FROM
    order_header oh
        JOIN
    order_item oi ON oh.ORDER_ID = oi.ORDER_ID
        AND oh.STATUS_ID = 'ORDER_COMPLETED'
        JOIN
    order_history ohis ON ohis.ORDER_ITEM_SEQ_ID = oi.ORDER_ITEM_SEQ_ID
        AND ohis.CREATED_DATE BETWEEN '2023-08-1 00:00:00' AND '2023-09-01 00:00:01'
        JOIN
    product p ON p.PRODUCT_ID = oi.PRODUCT_ID
        JOIN
    facility f ON f.FACILITY_ID = oh.ORIGIN_FACILITY_ID;
```

**Execution Plan:**

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
    oh.ORDER_ID, oh.STATUS_ID, opp.STATUS_ID, s.STATUS_ID
FROM
    order_header oh
        JOIN
    order_payment_preference opp ON opp.ORDER_ID = oh.ORDER_ID
        JOIN
    item_issuance ii ON opp.ORDER_ID = ii.ORDER_ID
        JOIN
    shipment s ON s.SHIPMENT_ID = ii.SHIPMENT_ID;
```

**Execution Plan:**

### 8 Orders Completed Hourly

**Business Problem:**  
Operations teams may want to see how orders complete across the day to schedule staffing.

**Fields to Retrieve:**  
- `TOTAL ORDERS`  
- `HOUR`

**SQL :** 
```SQL
SELECT 
    DATE(oh.entry_date) AS dates,
    HOUR(oh.entry_date) AS hours,
    COUNT(oh.ORDER_ID) AS TOTAL_ORDERS
FROM
    order_header oh
WHERE
    oh.STATUS_ID = 'ORDER_COMPLETED'
        AND entry_date <= CURRENT_DATE()
GROUP BY dates , hours
ORDER BY dates , hours;
```

**Execution Plan:**

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

### 10 Canceled Orders (Last Month)

**Business Problem:**  
The merchandising team needs to know how many orders were canceled in the previous month and their reasons.

**Fields to Retrieve:**  
- `TOTAL ORDERS`  
- `CANCELATION REASON`

**SQL :** 
```SQL
SELECT 
    COUNT(iid.REASON_ENUM_ID) AS TOTAL_ORDERS,
    iid.REASON_ENUM_ID AS CANCELATION_REASON
FROM
    order_header oh
        JOIN
    inventory_item_detail iid ON iid.ORDER_ID = oh.ORDER_ID
WHERE
    oh.STATUS_ID = 'ORDER_CANCELLED'
        AND MONTH(oh.entry_date) = MONTH(CURRENT_DATE()) - 1
        AND YEAR(oh.entry_date) = YEAR(CURRENT_DATE())
GROUP BY iid.REASON_ENUM_ID;      
```

**Execution Plan:**

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
FROM
    product_facility pf
WHERE
    minimum_stock IS NOT NULL;
```

**Execution Plan:**

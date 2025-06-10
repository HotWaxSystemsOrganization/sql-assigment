# SQL Assignment 2

---

## Mixed Party + Order Queries

### 1. Shipping Addresses for October 2023 Orders

**Business Problem:**  
Customer Service might need to verify addresses for orders placed or completed in October 2023. This helps ensure shipments are delivered correctly and prevents address-related issues.

**Fields to Retrieve:**  
- `ORDER_ID` 
- `PARTY_ID` (Customer ID)  
- `CUSTOMER_NAME` (or FIRST_NAME / LAST_NAME)  
- `STREET_ADDRESS`  
- `CITY` 
- `STATE_PROVINCE`
- `POSTAL_CODE`  
- `COUNTRY_CODE`  
- `ORDER_STATUS`  
- `ORDER_DATE`
**SQL:** 
```sql
SELECT 
    oh.ORDER_ID,
    p.PARTY_ID,
    CONCAT(p.first_name, ' ', p.last_name) AS CUSTOMER_NAME,
    pa.ADDRESS1 AS STREET_ADDRESS,
    pa.CITY,
    pa.STATE_PROVINCE_GEO_ID AS STATE_PROVINCE,
    pa.POSTAL_CODE,
    pa.COUNTRY_GEO_ID COUNTRY_CODE,
    oh.STATUS_ID AS ORDER_STATUS,
    oh.ORDER_DATE
FROM
    order_header oh
        JOIN
    order_contact_mech ocm ON oh.ORDER_ID = ocm.ORDER_ID
        JOIN
    party_contact_mech pcm ON pcm.CONTACT_MECH_ID = ocm.CONTACT_MECH_ID
        LEFT JOIN
    person p ON pcm.PARTY_ID = p.PARTY_ID
        LEFT JOIN
    postal_address pa ON pa.CONTACT_MECH_ID = ocm.CONTACT_MECH_ID
WHERE
    ocm.CONTACT_MECH_PURPOSE_TYPE_ID = 'SHIPPING_LOCATION';
-- and oh.ENTRY_DATE BETWEEN '2023-10-1 00:00:00' AND '2023-11-01 00:00:00';
```
**Cost: **

### 2. Orders from New York

**Business Problem:**  
Companies often want region-specific analysis to plan local marketing, staffing, or promotions in certain areas—here, specifically, New York.

**Fields to Retrieve:**  
- `ORDER_ID` 
- `CUSTOMER_NAME` 
- `STREET_ADDRESS` (or shipping address detail)  
- `CITY`  
- `STATE_PROVINCE`
- `POSTAL_CODE` 
- `TOTAL_AMOUNT`
- `ORDER_DATE`  
- `ORDER_STATUS`
**SQL:** 
```sql
SELECT 
    oh.ORDER_ID,
    CONCAT(p.first_name, ' ', p.last_name) AS CUSTOMER_NAME,
    pa.ADDRESS1 AS STREET_ADDRESS,
    pa.CITY,
    pa.STATE_PROVINCE_GEO_ID AS STATE_PROVINCE,
    pa.POSTAL_CODE,
    pa.COUNTRY_GEO_ID COUNTRY_CODE,
    oh.STATUS_ID AS ORDER_STATUS,
    oh.ORDER_DATE
FROM
    order_header oh
        JOIN
    order_contact_mech ocm ON oh.ORDER_ID = ocm.ORDER_ID
        JOIN
    party_contact_mech pcm ON pcm.CONTACT_MECH_ID = ocm.CONTACT_MECH_ID
        LEFT JOIN
    person p ON pcm.PARTY_ID = p.PARTY_ID
        LEFT JOIN
    postal_address pa ON pa.CONTACT_MECH_ID = ocm.CONTACT_MECH_ID
WHERE
    ocm.CONTACT_MECH_PURPOSE_TYPE_ID = 'SHIPPING_LOCATION'
        AND pa.STATE_PROVINCE_GEO_ID = 'NY'
        AND oh.STATUS_ID = 'ORDER_COMPLETED';

```
**Cost: **
---

### 3. Top-Selling Product in New York

**Business Problem:**  
Merchandising teams need to identify the best-selling product(s) in a specific region (New York) for targeted restocking or promotions.

**Fields to Retrieve:**  
- `PRODUCT_ID`  
- `INTERNAL_NAME`
- `TOTAL_QUANTITY_SOLD`  
- `CITY` / `STATE` (within New York region) 
- `REVENUE` (optionally, total sales amount)
**SQL:** 
```sql
SELECT 
    p.PRODUCT_ID,
    p.INTERNAL_NAME,
    pa.CITY,
    pa.STATE_PROVINCE_GEO_ID AS STATE_PROVINCE,
    SUM(oi.QUANTITY) AS TOTAL_QUANTITY_SOLD,
    SUM(oi.QUANTITY * oi.UNIT_PRICE) AS REVENUE
FROM
    order_item oi
        JOIN
    product p ON p.PRODUCT_ID = oi.PRODUCT_ID
        JOIN
    order_contact_mech ocm ON oi.ORDER_ID = ocm.ORDER_ID
        LEFT JOIN
    postal_address pa ON pa.CONTACT_MECH_ID = ocm.CONTACT_MECH_ID
WHERE
    pa.STATE_PROVINCE_GEO_ID = 'NY'
        AND oi.STATUS_ID = 'ITEM_COMPLETED'
GROUP BY p.PRODUCT_ID , pa.CITY;

```
**Cost: **

### 4. Store-Specific (Facility-Wise) Revenue

**Business Problem:**  
Different physical or online stores (facilities) may have varying levels of performance. The business wants to compare revenue across facilities for sales planning and budgeting.

**Fields to Retrieve:**  
- `FACILITY_ID`
- `FACILITY_NAME`  
- `TOTAL_ORDERS` 
- `TOTAL_REVENUE`  
- `DATE_RANGE` 
**SQL:** 
```sql
SELECT 
    f.FACILITY_ID,
    f.FACILITY_NAME,
    COUNT(oi.ORDER_ITEM_SEQ_ID) AS TOTAL_ORDERS,
    SUM(oi.ORDER_ITEM_SEQ_ID * oi.UNIT_PRICE) AS TOTAL_REVENUE
FROM
    order_item oi
        JOIN
    order_item_ship_group oisg ON oisg.ORDER_ID = oi.ORDER_ID
        JOIN
    facility f ON f.FACILITY_ID = oisg.FACILITY_ID
WHERE
    oi.STATUS_ID = 'ITEM_COMPLETED'
        AND oisg.CREATED_STAMP BETWEEN '2000-10-1 00:00:00' AND '2024-10-01 00:00:00'
GROUP BY f.FACILITY_ID;

```
**Cost: **

## Inventory Management & Transfers

### 5. Lost and Damaged Inventory

**Business Problem:**  
Warehouse managers need to track “shrinkage” such as lost or damaged inventory, to reconcile physical vs. system counts.

**Fields to Retrieve:**  
- `INVENTORY_ITEM_ID` 
- `PRODUCT_ID` 
- `FACILITY_ID` 
- `QUANTITY_LOST_OR_DAMAGED` 
- `REASON_CODE` (Lost, Damaged, Expired, etc.)  
- `TRANSACTION_DATE`
**SQL:** 
```sql
SELECT 
    p.PRODUCT_ID,
    ii.INVENTORY_ITEM_ID,
    ii.FACILITY_ID,
    iid.REASON_ENUM_ID,
    COUNT(ii.INVENTORY_ITEM_ID) AS TOTAL,
    iid.EFFECTIVE_DATE
FROM
    product p
        JOIN
    inventory_item ii ON p.PRODUCT_ID = ii.PRODUCT_ID
        LEFT JOIN
    inventory_item_detail iid ON iid.INVENTORY_ITEM_ID = ii.INVENTORY_ITEM_ID
WHERE
    iid.REASON_ENUM_ID = 'VAR_DAMAGED'
        OR iid.REASON_ENUM_ID = 'VAR_LOST'
        OR iid.REASON_ENUM_ID = 'VAR_stolen'
GROUP BY ii.INVENTORY_ITEM_ID , iid.INVENTORY_ITEM_DETAIL_SEQ_ID;

```
**Cost: **

### 6. Low Stock or Out of Stock Items Report

**Business Problem:**  
Avoiding out-of-stock situations is critical. This report flags items that have fallen below a certain reorder threshold or have zero available stock.

**Fields to Retrieve:**  
- `PRODUCT_ID`
- `PRODUCT_NAME` 
- `FACILITY_ID`  
- `QOH` (Quantity on Hand)  
- `ATP` (Available to Promise)  
- `REORDER_THRESHOLD` 
- `DATE_CHECKED`
**SQL:** 
```sql
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    pf.FACILITY_ID,
    ii.AVAILABLE_TO_PROMISE_TOTAL,
    ii.QUANTITY_ON_HAND_TOTAL,
    pf.MINIMUM_STOCK AS REORDER_THRESHOLD,
    ii.LAST_UPDATED_STAMP DATE_CHECKED
FROM
    inventory_item ii
        JOIN
    product p ON p.PRODUCT_ID = ii.PRODUCT_ID
        JOIN
    product_facility pf ON pf.PRODUCT_ID = p.PRODUCT_ID
WHERE
    pf.MINIMUM_STOCK > ii.QUANTITY_ON_HAND_TOTAL
        AND QUANTITY_ON_HAND_TOTAL IS NOT NULL;
```
**Cost: **

### 7. Retrieve the Current Facility (Physical or Virtual) of Open Orders

**Business Problem:**  
The business wants to know where open orders are currently assigned, whether in a physical store or a virtual facility (e.g., a distribution center or online fulfillment location).

**Fields to Retrieve:**  
- `ORDER_ID`  
- `ORDER_STATUS`
- `FACILITY_ID`  
- `FACILITY_NAME`  
- `FACILITY_TYPE_ID`
**SQL:** 
```sql
SELECT 
    oi.ORDER_ID,
    oi.STATUS_ID,
    pf.FACILITY_ID,
    f.FACILITY_NAME,
    f.FACILITY_TYPE_ID,
    ft.PARENT_TYPE_ID
FROM
    order_item oi
        JOIN
    product_facility pf ON pf.PRODUCT_ID = oi.PRODUCT_ID
        JOIN
    facility f ON f.FACILITY_ID = pf.FACILITY_ID
        JOIN
    facility_type ft ON ft.FACILITY_TYPE_ID = f.FACILITY_TYPE_ID;
```
**Cost: **

### 8. Items Where QOH and ATP Differ

**Business Problem:**  
Sometimes the **Quantity on Hand (QOH)** doesn’t match the **Available to Promise (ATP)** due to pending orders, reservations, or data discrepancies. This needs review for accurate fulfillment planning.

**Fields to Retrieve:**  
- `PRODUCT_ID`
- `FACILITY_ID`
- `QOH` (Quantity on Hand)  
- `ATP` (Available to Promise)  
- `DIFFERENCE` (QOH - ATP)
**SQL:** 
```sql
SELECT 
    p.PRODUCT_ID,
    pf.FACILITY_ID,
    ii.AVAILABLE_TO_PROMISE_TOTAL,
    ii.QUANTITY_ON_HAND_TOTAL,
    (ii.QUANTITY_ON_HAND_TOTAL - ii.AVAILABLE_TO_PROMISE_TOTAL) AS DIFFERENCE
FROM
    inventory_item ii
        JOIN
    product p ON p.PRODUCT_ID = ii.PRODUCT_ID
        JOIN
    product_facility pf ON pf.PRODUCT_ID = p.PRODUCT_ID
WHERE
    pf.MINIMUM_STOCK > ii.QUANTITY_ON_HAND_TOTAL
        AND QUANTITY_ON_HAND_TOTAL != 0;
```
**Cost: **

### 9. Order Item Current Status Changed Date-Time

**Business Problem:**  
Operations teams need to audit when an order item’s status (e.g., from “Pending” to “Shipped”) was last changed, for shipment tracking or dispute resolution.

**Fields to Retrieve:**  
- `ORDER_ID` 
- `ORDER_ITEM_SEQ_ID` 
- `CURRENT_STATUS_ID` 
- `STATUS_CHANGE_DATETIME`
- `CHANGED_BY`
**SQL:** 
```sql
SELECT 
    ORDER_ID,
    ORDER_ITEM_SEQ_ID,
    STATUS_ID AS CURRENT_STATUS_ID,
    STATUS_DATETIME AS STATUS_CHANGE_DATETIME,
    STATUS_USER_LOGIN as CHANGED_BY
FROM
    ORDER_STATUS;
```
**Cost: **

### 10. Total Orders by Sales Channel

**Business Problem:**  
Marketing and sales teams want to see how many orders come from each channel (e.g., web, mobile app, in-store POS, marketplace) to allocate resources effectively.

**Fields to Retrieve:**  
- `SALES_CHANNEL`
- `TOTAL_ORDERS`
- `TOTAL_REVENUE`
- `REPORTING_PERIOD` 
**SQL:** 
```sql
SELECT 
    SALES_CHANNEL_ENUM_ID,
    COUNT(order_id) AS TOTAL_ORDERS,
    GRAND_TOTAL AS TOTAL_REVENUE,
    ENTRY_DATE AS REPORTING_PERIOD
FROM
    order_header
GROUP BY ORDER_ID;
```
**Cost: **

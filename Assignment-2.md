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
SELECT distinct
  oh.ORDER_ID,
  orl.PARTY_ID,
  CONCAT(p.first_name, ' ', p.last_name) AS CUSTOMER_NAME,
  pa.ADDRESS1 as STREET_ADDRESS,
  pa.CITY,
  pa.STATE_PROVINCE_GEO_ID as STATE_PROVINCE,
  pa.POSTAL_CODE,
  tn.COUNTRY_CODE,
  oh.STATUS_ID as ORDER_STATUS,
  oh.ORDER_DATE
FROM order_header oh 
join order_role orl on oh.ORDER_ID = orl.ORDER_ID 
join person p on orl.PARTY_ID = p.PARTY_ID
join order_contact_mech ocm on  oh.ORDER_ID = ocm.ORDER_ID 
AND ocm.CONTACT_MECH_PURPOSE_TYPE_ID='SHIPPING_LOCATION' 
join order_contact_mech as oc on oh.ORDER_ID = oc.ORDER_ID AND oc.CONTACT_MECH_PURPOSE_TYPE_ID = "PHONE_SHIPPING"
join telecom_number   tn on oc.CONTACT_MECH_ID = tn.CONTACT_MECH_ID 
join postal_address pa on ocm.CONTACT_MECH_ID = pa.CONTACT_MECH_ID
join order_status  os on oh.ORDER_ID = os.ORDER_ID
where oh.order_type_id = 'SALES_ORDER'
AND oh.STATUS_ID IN ('ORDER_COMPLETED','ORDER_CREATED')
AND os.STATUS_DATETIME BETWEEN '2023-10-01 00:00:00' AND '2023-10-31 23:59:59';
```
**Execution Plan: **

<img width="1490" height="421" alt="1" src="https://github.com/user-attachments/assets/a81dbd67-2977-4ede-b91a-99efaf6d2f6a" />


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
SELECT distinct
 oh.ORDER_ID,
 p.FIRST_NAME,
 p.LAST_NAME,
 pa.ADDRESS1 as STREET_ADDRESS,
 pa.CITY,
 pa.STATE_PROVINCE_GEO_ID as STATE_PROVINCE,
 pa.POSTAL_CODE,
 oh.GRAND_TOTAL as TOTAL_AMOUNT,
 oh.ORDER_DATE,
 oh.STATUS_ID as ORDER_STATUS
FROM order_header oh 
join order_role  orl on orl.ORDER_ID = oh.ORDER_ID
join person p on orl.PARTY_ID = p.PARTY_ID
join order_contact_mech ocm on ocm.ORDER_ID = oh.ORDER_ID
join contact_mech cm on ocm.CONTACT_MECH_ID = cm.CONTACT_MECH_ID
join postal_address pa on pa.CONTACT_MECH_ID = cm.CONTACT_MECH_ID
where pa.STATE_PROVINCE_GEO_ID = "NY";
```
**Execution Plan: **

<img width="1138" height="421" alt="2" src="https://github.com/user-attachments/assets/357ac65b-488b-4ccc-b20b-94cbb34ffad0" />


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
FROM order_item oi
JOIN product p ON p.PRODUCT_ID = oi.PRODUCT_ID
JOIN order_contact_mech ocm ON oi.ORDER_ID = ocm.ORDER_ID
LEFT JOIN postal_address pa ON pa.CONTACT_MECH_ID = ocm.CONTACT_MECH_ID
WHERE pa.STATE_PROVINCE_GEO_ID = 'NY' AND oi.STATUS_ID = 'ITEM_COMPLETED'
GROUP BY p.PRODUCT_ID, p.INTERNAL_NAME, pa.CITY, pa.STATE_PROVINCE_GEO_ID;
```
**Execution Plan: **

<img width="788" height="421" alt="3" src="https://github.com/user-attachments/assets/b4506a13-100c-4228-852e-2c3dd8040536" />


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
select 
    f.facility_id,
    f.facility_name,
    count(oh.order_id) as TOTAL_ORDERS,
    sum(oh.grand_total) as TOTAL_REVENUE
from facility f 
join order_header oh on oh.ORIGIN_FACILITY_ID = f.FACILITY_ID
where oh.STATUS_ID = "ORDER_COMPLETED"
group by f.FACILITY_ID , f.FACILITY_NAME;
```
**Execution Plan: **

<img width="386" height="421" alt="4" src="https://github.com/user-attachments/assets/c883d093-7f55-4f89-a9f0-805e875de1a5" />


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
    ii.inventory_item_id,
    ii.product_id,
    ii.facility_id,
    iiv.QUANTITY_ON_HAND_VAR as quantity_lost_or_damaged,
    iiv.variance_reason_id as reason_code,
    iiv.created_stamp as TRANSACTION_DATE
from inventory_item ii
join inventory_item_variance iiv on ii.INVENTORY_ITEM_ID = iiv.INVENTORY_ITEM_ID AND iiv.VARIANCE_REASON_ID in ("VAR_LOST","VAR_DAMAGED","VAR_STOLEN")

```
**Execution Plan: **

<img width="336" height="328" alt="5" src="https://github.com/user-attachments/assets/d3405c67-ea47-4732-81de-cc7e64dddcb9" />


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
select 
    p.product_id,
    p.product_name,
    ii.facility_id,
    ii.QUANTITY_ON_HAND_TOTAL,
    ii.AVAILABLE_TO_PROMISE_TOTAL,
    pf.minimum_stock as  reorder_threshold,
    current_timestamp() as Date_checked
from inventory_item ii
join product p on ii.PRODUCT_ID = p.PRODUCT_ID
join product_facility pf on p.PRODUCT_ID = pf.PRODUCT_ID and ii.FACILITY_ID = pf.FACILITY_ID
where ii.QUANTITY_ON_HAND_TOTAL <= pf.MINIMUM_STOCK or ii.QUANTITY_ON_HAND_TOTAL = 0;
```
**Execution Plan: **

<img width="511" height="328" alt="6" src="https://github.com/user-attachments/assets/fd7a7c89-c73a-4450-bbb9-d5b59ac7ab83" />


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
    oh.ORDER_ID,
    oh.STATUS_ID as ORDER_STATUS,
    f.FACILITY_ID,
    f.FACILITY_NAME,
    f.FACILITY_TYPE_ID
FROM order_header oh
join order_item oi on oi.order_id = oh.order_id
join order_item_ship_group_assoc  on oi.ORDER_ID = oisga.ORDER_ID and oi.order_item_seq_id = oisga.order_item_seq_id
join order_item_ship_group oisg on oisga.ORDER_ID = oisg.ORDER_ID and oisga.ship_group_seq_id = oisg.ship_group_seq_id
join facility f on oisg.FACILITY_ID = f.FACILITY_ID
where oh.STATUS_ID in ('ORDER_CREATED' , 'ORDER_APPROVED');
```
**Execution Plan: **

<img width="927" height="332" alt="7" src="https://github.com/user-attachments/assets/a8d912a9-9ccb-442e-8971-f48c2f53d9ef" />

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
    PRODUCT_ID,
    FACILITY_ID,
    SUM(AVAILABLE_TO_PROMISE_TOTAL) as AVAILABLE_TO_PROMISE,
    sum(QUANTITY_ON_HAND_TOTAL) as QUANTITY_ON_HAND,
    (sum(QUANTITY_ON_HAND_TOTAL) - SUM(AVAILABLE_TO_PROMISE_TOTAL)) AS DIFFERENCE
FROM inventory_item ii
group by PRODUCT_ID, FACILITY_ID
having sum(QUANTITY_ON_HAND_TOTAL) <> SUM(AVAILABLE_TO_PROMISE_TOTAL);
```
**Execution Plan: **

<img width="161" height="284" alt="8" src="https://github.com/user-attachments/assets/f9084d9f-640e-4397-8916-900864c2894e" />


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
**Execution Plan: **

<img width="161" height="199" alt="9" src="https://github.com/user-attachments/assets/6eed29ca-db59-45a9-8676-01baea6453bf" />


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
    SUM(GRAND_TOTAL) AS TOTAL_REVENUE,
    current_timestamp() AS REPORTING_PERIOD
FROM order_header
GROUP BY SALES_CHANNEL_ENUM_ID;
```
**Execution Plan: **

<img width="161" height="304" alt="10" src="https://github.com/user-attachments/assets/3ee100b9-a223-4912-aa8e-dfb988407c54" />

---

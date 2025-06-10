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
    P.PRODUCT_ID,
    P.PRODUCT_TYPE_ID,
    oh.SALES_CHANNEL_ENUM_ID,
    oh.ORDER_DATE,
    oh.ENTRY_DATE,
    os.STATUS_ID,
    os.STATUS_DATETIME,
    oh.ORDER_TYPE_ID,
    f.PRODUCT_STORE_ID
FROM
    order_header oh
        JOIN
    order_item oi ON oi.ORDER_ID = oh.ORDER_ID
        JOIN
    order_status os ON os.ORDER_ITEM_SEQ_ID = oi.order_item_seq_id
        JOIN
    product p ON p.PRODUCT_ID = oi.PRODUCT_ID
        JOIN
    facility f ON f.FACILITY_ID = p.FACILITY_ID
        JOIN
    facility_type ft ON f.FACILITY_TYPE_ID = ft.FACILITY_TYPE_ID
WHERE
    ft.PARENT_TYPE_ID = 'PHYSICAL_STORE';
```
**Cost: 15911**

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
SELECT DISTINCT
    oh.order_id,
    ri.return_id,
    oh.product_store_id,
    oh.order_name,
    rh.from_party_id,
    rh.entry_date,
    rh.return_date,
    rh.return_channel_enum_id
FROM
    order_item oi
        JOIN
    order_header oh ON oh.order_id = oi.order_id
        JOIN
    return_item ri ON oi.order_id = ri.order_id
        AND oi.ORDER_ITEM_SEQ_ID = ri.ORDER_ITEM_SEQ_ID
        JOIN
    return_header rh ON rh.return_id = ri.RETURN_ID;

```
**Cost: 15911**

### 3 Single-Return Orders (Last Month)

**Business Problem:**  
The mechandising team needs a list of orders that only have one return.

**Fields to Retrieve:**  
- `PARTY_ID`  
- `FIRST_NAME`
**SQL:** 
```sql
SELECT DISTINCT
    pr.party_id, pr.FIRST_NAME
FROM
    return_header rh
        JOIN
    person pr ON rh.FROM_PARTY_ID = pr.PARTY_ID
        JOIN
    return_item ri ON ri.RETURN_ID = rh.RETURN_ID
WHERE
    rh.FROM_PARTY_ID != '_NA_'
        AND MONTH(rh.return_date) = MONTH(CURRENT_DATE) - 1
GROUP BY rh.RETURN_ID
HAVING COUNT(ri.order_id) = 1;
```
**Cost: 15911**

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
    COUNT(ri.RETURN_ID) AS TOTAL_RETURN,
    SUM(ri.RETURN_PRICE * ri.RETURN_QUANTITY) AS TOTAL_RETURN_VALUE,
    COUNT(ra.RETURN_ID) AS TOTAL_APPEASEMENT,
    SUM(ra.AMOUNT) AS TOTAL_APPEASEMENT_VALUE
FROM
    return_item ri
        JOIN
    return_adjustment ra ON ra.RETURN_ID = ri.RETURN_ID;
```
**Cost: 15911**

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
    rh.RETURN_ID,
    rh.ENTRY_DATE,
    ra.RETURN_ADJUSTMENT_TYPE_ID,
    ra.AMOUNT,
    ra.COMMENTS,
    oh.ORDER_ID,
    oh.ORDER_DATE,
    rh.RETURN_DATE,
    oh.PRODUCT_STORE_ID
FROM
    return_item ri
        JOIN
    order_header oh ON ri.ORDER_ID = oh.order_id
        JOIN
    return_header rh ON ri.RETURN_ID = rh.RETURN_ID
        JOIN
    return_adjustment ra ON ra.RETURN_ID = ri.RETURN_ID;

```
**Cost: 15911**

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
    ri.ORDER_ID,
    rh.RETURN_ID,
    rh.RETURN_DATE,
    ri.RETURN_REASON_ID,
    ri.RETURN_QUANTITY
FROM
    return_item ri
        JOIN
    return_header rh ON rh.return_id = ri.RETURN_ID
WHERE
    ri.ORDER_ID IN (SELECT 
            ORDER_ID
        FROM
            return_item
        GROUP BY order_id
        HAVING COUNT(ORDER_ID) > 1);

```
**Cost: 15911**

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
SELECT DISTINCT
    SHIPMENT_METHOD_TYPE_ID
FROM
    order_item_ship_group;
SELECT 
    f.FACILITY_ID,
    f.FACILITY_NAME,
    COUNT(oisg.ORDER_ID) AS TOTAL_ONE_DAY_SHIP_ORDERS,
    oh.ENTRY_DATE REPORTING_PERIOD
FROM
    order_header oh
        JOIN
    order_item_ship_group oisg ON oh.ORDER_ID = oisg.ORDER_ID
        AND oisg.SHIPMENT_METHOD_TYPE_ID = 'NEXT_DAY'
        AND oh.STATUS_ID = 'ORDER_COMPLETED'
        AND (MONTH(oh.ENTRY_DATE) = MONTH(CURDATE()) - 1)
        AND YEAR(oh.ENTRY_DATE) = YEAR(CURDATE())
        JOIN
    facility f ON oisg.FACILITY_ID = f.FACILITY_ID
GROUP BY f.FACILITY_ID , f.FACILITY_NAME , oh.ENTRY_DATE;

```
**Cost: 15911**

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
    (p.PARTY_ID),
    CONCAT(p.first_name, ' ', p.last_name),
    plr.ROLE_TYPE_ID,
    pl.FACILITY_ID,
    CASE
        WHEN
            plr.THRU_DATE IS NULL
                OR plr.THRU_DATE > CURRENT_DATE()
        THEN
            'ACTIVE'
        ELSE 'INACTIVE'
    END AS STATUS
FROM
    picklist pl
        JOIN
    picklist_role plr ON pl.PICKLIST_ID = plr.PICKLIST_ID
        JOIN
    person p ON plr.PARTY_ID = p.PARTY_ID;

```
**Cost: 15911**

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
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    COUNT(pf.FACILITY_ID) AS FACILITY_COUNT
FROM
    product p
        JOIN
    product_facility pf ON p.PRODUCT_ID = pf.PRODUCT_ID
GROUP BY p.PRODUCT_ID;

```
**Cost: 15911**

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
    f.FACILITY_ID,
    pf.PRODUCT_ID,
    f.FACILITY_TYPE_ID,
    ii.AVAILABLE_TO_PROMISE_TOTAL,
    ii.QUANTITY_ON_HAND_TOTAL
FROM
    product_facility pf
        JOIN
    inventory_item ii ON pf.PRODUCT_ID = ii.PRODUCT_ID
        JOIN
    facility f ON pf.FACILITY_ID = f.FACILITY_ID
        JOIN
    facility_type ft ON ft.FACILITY_TYPE_ID = f.FACILITY_TYPE_ID
        AND ft.PARENT_TYPE_ID = 'VIRTUAL_FACILITY';

```
**Cost: 15911**

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

```
**Cost: 15911**

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
    oh.Order_id,
    oisg.facility_id,
    oh.order_date,
    oh.status_id,
    pl.STATUS_ID,
    DATEDIFF(DATE(oh.entry_date), DATE(oh.order_Date)) AS duration
FROM
    order_header oh
        JOIN
    order_item_ship_group oisg ON oisg.ORDER_ID = oh.ORDER_ID
        JOIN
    picklist pl ON pl.FACILITY_ID = oisg.FACILITY_ID
        AND pl.STATUS_ID IS NULL;  
```
**Cost: 15911**

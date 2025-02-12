SELECT f.FACILITY_ID,
f.FACILITY_NAME,
count(oi.ORDER_ITEM_SEQ_ID) as TOTAL_ORDERS,
sum(oi.ORDER_ITEM_SEQ_ID * oi.UNIT_PRICE) as TOTAL_REVENUE
FROM 
order_item oi join order_item_ship_group oisg on oisg.ORDER_ID=oi.ORDER_ID join facility f on f.FACILITY_ID=oisg.FACILITY_ID where oi.STATUS_ID="ITEM_COMPLETED"
 group by f.FACILITY_ID;
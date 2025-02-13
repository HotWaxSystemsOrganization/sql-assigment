select distinct SHIPMENT_METHOD_TYPE_ID from order_item_ship_group;
select 
f.FACILITY_ID,
f.FACILITY_NAME,
count(oisg.ORDER_ID) as TOTAL_ONE_DAY_SHIP_ORDERS
from order_header oh join order_item_ship_group oisg on oh.ORDER_ID=oisg.ORDER_ID and oisg.SHIPMENT_METHOD_TYPE_ID="NEXT_DAY" and oh.STATUS_ID="ORDER_COMPLETED" and (month(oh.ENTRY_DATE)=month(curdate()-1) and year(oh.ENTRY_DATE)=year(curdate()))
join facility f on oisg.FACILITY_ID=f.FACILITY_ID group by f.FACILITY_ID, f.FACILITY_NAME;
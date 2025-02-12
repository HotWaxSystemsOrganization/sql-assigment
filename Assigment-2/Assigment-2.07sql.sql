SELECT 
oh.ORDER_ID
,oh.STATUS_ID
,f.FACILITY_ID
,f.FACILITY_NAME
,f.FACILITY_TYPE_ID
,ft.PARENT_TYPE_ID
from order_header oh join order_item oi on oi.order_id = oh.ORDER_ID join product p on p.PRODUCT_ID=oi.PRODUCT_ID join facility f on f.FACILITY_ID=p.FACILITY_ID join facility_type ft on ft.FACILITY_TYPE_ID=f.FACILITY_TYPE_ID;
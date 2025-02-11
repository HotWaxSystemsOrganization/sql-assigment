select count(oh.order_id) as TOTAL_ORDERS, sum(oh.grand_total) as TOTAL_REVENUE
from order_header oh join order_item_ship_group oisg on oh.ORDER_ID=oisg.ORDER_ID 
and oisg.SHIPMENT_METHOD_TYPE_ID="STOREPICKUP" AND year(oh.entry_date)=YEAR(current_date())-1;
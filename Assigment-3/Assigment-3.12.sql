select oh.Order_id , 
	   oisg.facility_id,
       oh.order_date,
       oh.status_id,
       datediff(date(oh.entry_date),date(oh.order_Date)) as duration
from order_header oh join order_item_ship_group oisg on oisg.ORDER_ID = oh.ORDER_ID;       
select 
rh.RETURN_ID,
rh.ENTRY_DATE,
ra.RETURN_ADJUSTMENT_TYPE_ID, 
ra.AMOUNT,
ra.COMMENTS,
oh.ORDER_ID,
oh.ORDER_DATE,
rh.RETURN_DATE,
oh.PRODUCT_STORE_ID
from return_item ri join order_header oh on ri.ORDER_ID=oh.order_id  join return_header rh on ri.RETURN_ID=rh.RETURN_ID
join return_adjustment ra on ra.RETURN_ID=ri.RETURN_ID;
select 
ri.ORDER_ID,
rh.RETURN_ID,
rh.RETURN_DATE,
ri.RETURN_REASON_ID,
ri.RETURN_QUANTITY 
from return_item ri join return_header rh on rh.return_id = ri.RETURN_ID where ri.ORDER_ID in (select ORDER_ID from return_item group by order_id having count(ORDER_ID)>1);
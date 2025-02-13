SELECT distinct oh.order_id,
	   ri.return_id,
       oh.product_store_id,
       oh.order_name,
       rh.from_party_id,
       rh.entry_date,
       rh.return_date,
       rh.return_channel_enum_id
FROM order_item oi
JOIN order_header oh ON oh.order_id=oi.order_id
JOIN return_item ri ON oi.order_id=ri.order_id and oi.ORDER_ITEM_SEQ_ID = ri.ORDER_ITEM_SEQ_ID
JOIN return_header rh ON rh.return_id=ri.RETURN_ID;


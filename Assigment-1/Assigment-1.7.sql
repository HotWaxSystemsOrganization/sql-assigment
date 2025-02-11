select oh.ORDER_ID, oh.STATUS_ID,opp.STATUS_ID, s.STATUS_ID from order_header oh join order_payment_preference opp
on opp.ORDER_ID=oh.ORDER_ID join item_issuance ii on opp.ORDER_ID=ii.ORDER_ID join shipment s on s.SHIPMENT_ID=ii.SHIPMENT_ID;

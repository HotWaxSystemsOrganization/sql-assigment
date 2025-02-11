select oh.ORDER_ID, oh.GRAND_TOTAL as TOTAL_AMOUNT,opp.PAYMENT_METHOD_TYPE_ID as PAYMENT_METHOD , sp.SHOPIFY_ORDER_ID from order_header oh join order_payment_preference opp
on opp.ORDER_ID=oh.ORDER_ID join shopify_shop_order sp on sp.ORDER_ID=oh.ORDER_ID;

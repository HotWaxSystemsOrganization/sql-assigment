select SALES_CHANNEL_ENUM_ID,
count(order_id) as TOTAL_ORDERS,
GRAND_TOTAL as TOTAL_REVENUE,
ENTRY_DATE as REPORTING_PERIOD from order_header group by ORDER_ID;
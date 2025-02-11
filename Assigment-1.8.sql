select date(oh.entry_date) as dates, hour(oh.entry_date) as hours ,count(oh.ORDER_ID) as TOTAL_ORDERS  from order_header oh where oh.STATUS_ID="ORDER_COMPLETED" 
and entry_date<=current_date() group by dates, hours order by dates, hours ;

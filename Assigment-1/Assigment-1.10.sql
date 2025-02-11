select 
	count(iid.REASON_ENUM_ID) as TOTAL_ORDERS, 
    iid.REASON_ENUM_ID as CANCELATION_REASON 
    from order_header oh join inventory_item_detail iid 
    on iid.ORDER_ID=oh.ORDER_ID 
	where oh.STATUS_ID="ORDER_CANCELLED" and month(oh.entry_date)=month(current_date())-1 and year(oh.entry_date)=YEAR(current_date()) 
	group by iid.REASON_ENUM_ID; 
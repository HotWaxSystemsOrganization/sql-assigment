select distinct STATUS_ID from order_header;
select distinct STATUS_ID from order_item;
select distinct * from facility_type;
select OI.ORDER_ID,OI.ORDER_ITEM_SEQ_ID,P.PRODUCT_ID,P.PRODUCT_TYPE_ID,oh.SALES_CHANNEL_ENUM_ID,oh.ORDER_DATE,oh.ENTRY_DATE,os.STATUS_ID,os.STATUS_DATETIME,oh.ORDER_TYPE_ID,f.PRODUCT_STORE_ID
from order_header oh join order_item oi on oi.ORDER_ID=oh.ORDER_ID join order_status os on os.ORDER_ITEM_SEQ_ID=oi.order_item_seq_id join product p on p.PRODUCT_ID=oi.PRODUCT_ID join facility f on f.FACILITY_ID=p.FACILITY_ID
join facility_type ft on f.FACILITY_TYPE_ID=ft.FACILITY_TYPE_ID where ft.PARENT_TYPE_ID="PHYSICAL_STORE";

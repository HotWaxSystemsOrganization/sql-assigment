SELECT oi.ORDER_ID,oi.STATUS_ID,pf.FACILITY_ID,f.FACILITY_NAME,f.FACILITY_TYPE_ID,ft.PARENT_TYPE_ID
from order_item oi 
join product_facility pf on pf.PRODUCT_ID=oi.PRODUCT_ID 
join facility f on f.FACILITY_ID=pf.FACILITY_ID 
join facility_type ft on ft.FACILITY_TYPE_ID=f.FACILITY_TYPE_ID;
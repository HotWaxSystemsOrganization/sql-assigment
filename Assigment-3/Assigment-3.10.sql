select 
	f.FACILITY_ID,
    pf.PRODUCT_ID,
	f.FACILITY_TYPE_ID,
	ii.AVAILABLE_TO_PROMISE_TOTAL,
	ii.QUANTITY_ON_HAND_TOTAL
from product_facility pf  
join inventory_item ii on pf.PRODUCT_ID=ii.PRODUCT_ID 
join facility f on pf.FACILITY_ID=f.FACILITY_ID 
join facility_type ft on ft.FACILITY_TYPE_ID=f.FACILITY_TYPE_ID and ft.PARENT_TYPE_ID="VIRTUAL_FACILITY";
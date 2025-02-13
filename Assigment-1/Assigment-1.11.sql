select product_id, minimum_stock as THRESHOLD from product_facility pf where minimum_stock is NOT NULL;
-- select pf.product_id, pf.minimum_stock as THRESHOLD from facility f join facility_type ft on f.FACILITY_TYPE_ID=ft.FACILITY_TYPE_ID and ft.PARENT_TYPE_ID="VIRTUAL_FACILITY"
-- join product_facility pf on pf.FACILITY_ID=f.FACILITY_ID ;

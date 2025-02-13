-- select
-- p.PRODUCT_ID,
-- p.PRODUCT_NAME,
-- count(pa.FACILITY_ID) as FACILITY_COUNT
-- from product p join product pa on p.PRODUCT_ID=pa.PRODUCT_ID group by pa.PRODUCT_ID;

select
p.PRODUCT_ID,
p.PRODUCT_NAME,
count(pf.FACILITY_ID) as FACILITY_COUNT
from product p join product_facility pf on p.PRODUCT_ID=pf.PRODUCT_ID group by p.PRODUCT_ID;
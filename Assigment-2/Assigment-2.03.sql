--  join product p on p.PRODUCT_ID=oi.PRODUCT_ID
SELECT p.PRODUCT_ID, p.INTERNAL_NAME,pa.CITY,pa.STATE_PROVINCE_GEO_ID as STATE_PROVINCE, sum(oi.QUANTITY) as TOTAL_QUANTITY_SOLD, sum(oi.QUANTITY * oi.UNIT_PRICE) as REVENUE
from order_item oi join product p on p.PRODUCT_ID=oi.PRODUCT_ID join order_contact_mech ocm on oi.ORDER_ID=ocm.ORDER_ID 
left join postal_address pa on pa.CONTACT_MECH_ID=ocm.CONTACT_MECH_ID where pa.STATE_PROVINCE_GEO_ID="NY" and oi.STATUS_ID="ITEM_COMPLETED"
group by p.PRODUCT_ID, pa.CITY; 
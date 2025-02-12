SELECT oh.ORDER_ID, concat(p.first_name," ",p.last_name) as CUSTOMER_NAME,pa.ADDRESS1 as STREET_ADDRESS,pa.CITY,
pa.STATE_PROVINCE_GEO_ID as STATE_PROVINCE,
pa.POSTAL_CODE,pa.COUNTRY_GEO_ID COUNTRY_CODE,oh.STATUS_ID as ORDER_STATUS,oh.ORDER_DATE
from order_header oh join order_contact_mech ocm on oh.ORDER_ID=ocm.ORDER_ID 
join party_contact_mech pcm on pcm.CONTACT_MECH_ID=ocm.CONTACT_MECH_ID 
left join person p on pcm.PARTY_ID=p.PARTY_ID 
left join postal_address pa on pa.CONTACT_MECH_ID=ocm.CONTACT_MECH_ID where ocm.CONTACT_MECH_PURPOSE_TYPE_ID="SHIPPING_LOCATION" and pa.STATE_PROVINCE_GEO_ID="NY" and oh.STATUS_ID="ORDER_COMPLETED";
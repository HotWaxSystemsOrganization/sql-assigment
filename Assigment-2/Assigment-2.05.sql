SELECT 
p.PRODUCT_ID,ii.INVENTORY_ITEM_ID
,ii.FACILITY_ID
,iid.REASON_ENUM_ID 
,COUNT(ii.INVENTORY_ITEM_ID) AS TOTAL
,iid.EFFECTIVE_DATE 
from product p join inventory_item ii on p.PRODUCT_ID=ii.PRODUCT_ID left join inventory_item_detail iid on iid.INVENTORY_ITEM_ID=ii.INVENTORY_ITEM_ID
where iid.REASON_ENUM_ID="VAR_DAMAGED" or iid.REASON_ENUM_ID="VAR_LOST" OR iid.REASON_ENUM_ID="VAR_stolen" GROUP BY ii.INVENTORY_ITEM_ID,iid.INVENTORY_ITEM_DETAIL_SEQ_ID;
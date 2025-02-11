select p.PRODUCT_ID, p.PRODUCT_TYPE_ID, p.INTERNAL_NAME from product p join product_type pt on p.PRODUCT_TYPE_ID = pt.PRODUCT_TYPE_ID and IS_PHYSICAL="Y";


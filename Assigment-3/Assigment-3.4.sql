select count(ri.RETURN_ID) as TOTAL_RETURN, 
	   sum(ri.RETURN_PRICE * ri.RETURN_QUANTITY) as TOTAL_RETURN_VALUE , 
	   count(ra.RETURN_ID) as TOTAL_APPEASEMENT, 
       sum(ra.AMOUNT) as TOTAL_APPEASEMENT_VALUE 
from return_item ri 
join return_adjustment ra on ra.RETURN_ID=ri.RETURN_ID;
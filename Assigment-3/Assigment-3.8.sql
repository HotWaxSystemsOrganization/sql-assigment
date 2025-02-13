SELECT 
distinct (p.PARTY_ID),
concat(p.first_name, " ",p.last_name),
plr.ROLE_TYPE_ID,
pl.FACILITY_ID,
case
	when plr.THRU_DATE is null or plr.THRU_DATE>current_date() then "ACTIVE"
    else "INACTIVE" 
END as STATUS
from picklist pl join picklist_role plr on pl.PICKLIST_ID=plr.PICKLIST_ID join person p on plr.PARTY_ID= p.PARTY_ID 
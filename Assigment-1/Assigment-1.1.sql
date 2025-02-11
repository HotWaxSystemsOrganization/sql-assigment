select p.PARTY_ID, p.FIRST_NAME, p.LAST_NAME , cm.INFO_STRING as EMAIL ,p.CREATED_STAMP as ENTRY_DATE, tn.CONTACT_NUMBER as PHONE from
person p join party_role pr on p.party_id = pr.party_id and (pr.ROLE_TYPE_ID="CUSTOMER") and p.CREATED_STAMP BETWEEN '2023-06-1 00:00:00' AND '2023-07-01 00:00:01'
join party_contact_mech pcm on p.PARTY_ID = pcm.PARTY_ID join contact_mech cm on pcm.CONTACT_MECH_ID = cm.CONTACT_MECH_ID left join telecom_number tn on cm.CONTACT_MECH_ID=tn.CONTACT_MECH_ID;




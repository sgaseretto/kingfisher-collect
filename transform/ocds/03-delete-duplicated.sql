delete from ocds.award where data_id in (
select a.data_id from ocds.procurement a
join ocds.procurement b on a.ocid = b.ocid and a.id < b.id);

delete from ocds.award_items where data_id in (
select a.data_id from ocds.procurement a
join ocds.procurement b on a.ocid = b.ocid and a.id < b.id);

delete from ocds.tender_items where data_id in (
select a.data_id from ocds.procurement a
join ocds.procurement b on a.ocid = b.ocid and a.id < b.id);

delete from ocds.contract where data_id in (
select a.data_id from ocds.procurement a
join ocds.procurement b on a.ocid = b.ocid and a.id < b.id);

delete from ocds.parties where data_id in (
select a.data_id from ocds.procurement a
join ocds.procurement b on a.ocid = b.ocid and a.id < b.id);

delete from ocds.procurement where data_id in (
select a.data_id from ocds.procurement a
join ocds.procurement b on a.ocid = b.ocid and a.id < b.id);

 -- delete from ocds.data;
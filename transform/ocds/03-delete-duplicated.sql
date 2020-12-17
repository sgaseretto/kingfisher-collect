

refresh materialized view ocds.unique_suppliers;

create table if not exists ocds.precios_pre_pandemia as (
    select avg(ai.unit_price)             as promedio,
           ai.classification_id,
           ai.attributes -> 1 ->> 'value' as presentacion,
           ai.unit_name,
           ai.unit_price_currency
    from ocds.award_items as ai
             join ocds.procurement as t on t.ocid = ai.ocid
    where t.tender_date_published < '2020-03-01'
    group by ai.classification_id, ai.attributes -> 1 ->> 'value', ai.unit_name, ai.unit_price_currency
);

 delete from ocds.data;
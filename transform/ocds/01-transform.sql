INSERT INTO ocds.procurement (release_date, ocid, data_id, tender_id, characteristics, tender_amount, budget_amount, budget_currency, tender_currency,
                                  tender_date_published, planning_estimated_date, tender_enquiryperiod_start_date, tender_enquiryperiod_end_date,
                                  tender_tenderperiod_end_date, tender_tenderperiod_start_date, tender_procurementmethoddetails, buyer_name, buyer_id,
                                  tender_bidopening_date, tender_awardcriteria_details, tender_status, tender_status_details,
                                  tender_title, tender_mainprocurementcategorydetails, tender_numberoftenderers, analyzed, number_of_awards,
                                  framework_agreement, electronic_auction, budget, documents, tender_numberofenquiries, url,
                              tender_procurementmethod)   (
    SELECT
    distinct
    (data->>'date')::timestamp as release_date,
    r.ocid,
    data_id as data_id,
           data->'tender'->>'id' as tender_id,
           data->'tender'->'coveredBy' as characteristics,
           (data->'tender'->'value'->>'amount')::numeric as tender_amount,
           (data->'planning'->'budget'->'amount'->>'amount')::numeric as budget_amount,
           data->'planning'->'budget'->'amount'->>'currency' as budget_currency,
           data->'tender'->'value'->>'currency' as tender_currency,
           (data->'tender'->>'datePublished')::timestamp as tender_date_published,
           (data->'planning'->>'estimatedDate')::timestamp as planning_estimated_date,
          (data->'tender'->'enquiryPeriod'->>'startDate')::timestamp as tender_enquiryperiod_start_date,
          (data->'tender'->'enquiryPeriod'->>'endDate')::timestamp as tender_enquiryperiod_end_date,
          (data->'tender'->'tenderPeriod'->>'endDate')::timestamp as tender_tenderperiod_end_date,
          (data->'tender'->'tenderPeriod'->>'startDate')::timestamp as tender_tenderperiod_start_date,
          (data->'tender'->>'procurementMethodDetails') as tender_procurementMethodDetails,
          (data->'buyer'->>'name') as buyer_name,
          (data->'buyer'->>'id') as buyer_id,
          (data->'tender'->'bidOpening'->>'date')::timestamp as tender_bidopening_date,
          data->'tender'->>'awardCriteriaDetails' as tender_awardcriteria_details,
                   data->'tender'->>'status' as tender_status,
                                           data->'tender'->>'statusDetails' as tender_status_details,
                           data->'tender'->>'title' as tender_title,
           data->'tender'->>'mainProcurementCategoryDetails' as tender_mainprocurementCategorydetails,
           data->'tender'->>'numberOfTenderers' as tender_numberoftenderers,
           false as analyzed,
                      COALESCE(jsonb_array_length(data->'awards'),0) as number_of_awards,
               case when data->'tender'->'techniques'->'hasFrameworkAgreement' is not null then TRUE else FALse end as convenio,
           case when data->'tender'->'techniques'->'hasElectronicAuction' is not null then TRUE else FALse end as subasta,
           data->'planning'->'budget'->'budgetBreakdown' as budget,
           data->'tender'->'documents' as documents,
          COALESCE(jsonb_array_length(data->'tender'->'enquiries'),0) as tender_numberofenquiries,
                               case when data->'tender'->>'procurementMethod' = 'direct'
         then 'https://contrataciones.gov.py/sin-difusion-convocatoria/'|| (data->'tender'->>'id') || '.html'
         else 'https://contrataciones.gov.py/licitaciones/convocatoria/'|| (data->'tender'->>'id') || '.html'
       end                                           as url,
                        data->'tender'->>'procurementMethod' as procurement_method
           FROM (
    SELECT
        data.id as data_id,
        data,
           ocid
    FROM
        ocds.data
) AS r
order by release_date desc  );


INSERT INTO ocds.parties (ocid, data_id, party_id, name, contact_point_email, contact_point_name, contact_point_telephone,
                              contact_point_fax, roles, entity_level, entity_entity_type, entity_type, supplier_type,
                              address_country, address_locality, address_region, address_street)  (

    select r.ocid,
           r.id,
           p->>'id' as party_id,
           p->>'name' as name,
           p->'contactPoint'->>'email' as contact_point_email,
           p->'contactPoint'->>'name' as contact_point_name,
           p->'contactPoint'->>'telephone' as contact_point_telephone,
           p->'contactPoint'->>'faxNumber' as contact_point_fax,
           p->'roles' as roles,
           p->'details'->>'level' as entity_level,
           p->'details'->>'entityType' as entity_entity_type,
           p->'details'->>'type' as entity_type,
                   p->'details'->>'legalEntityTypeDetail' as supplier_type,
           p->'address'->>'countryName' as address_contry,
          p->'address'->>'locality' as address_locality,
          p->'address'->>'region' as address_region,
          p->'address'->>'streetAddress' as address_street

    from ocds.data as r
    CROSS JOIN jsonb_array_elements(data -> 'parties') p

);


INSERT INTO ocds.award (ocid, data_id, award_id, date, amount, currency,
                            status, status_details, supplier_id, supplier_name, documents, buyer_id, buyer_name)  (

    select distinct r.ocid,
                    r.id,
           a->>'id' as award_id,
           (a->>'date')::timestamp as date,
           (a->'value'->>'amount')::numeric as amount,
           a->'value'->>'currency' as currency,
           a->>'status' as status,
                               a->>'statusDetails' as status_details,
           a->'suppliers'->0->>'id' as supplier_id,
           a->'suppliers'->0->>'name' as supplier_name,
           a->'documents' as documents,
           a->'buyer'->>'id' as buyer_id,
           a->'buyer'->>'name' as buyer_name

    from ocds.data as r
    CROSS JOIN jsonb_array_elements(data -> 'awards') a

);

INSERT INTO ocds.contract (ocid, data_id, contract_id, award_id, date_signed, amount, currency, status, status_details,
                               duration_in_days, start_date, end_date, budget, documents, amendments)  (

    select distinct r.ocid,
                    r.id,
           a->>'id' as contract_id,
           a->>'awardID' as award_id,
           (a->>'dateSigned')::timestamp as date_signed,
           (a->'value'->>'amount')::numeric as amount,
           a->'value'->>'currency' as currency,
           a->>'status' as status,
                               a->>'statusDetails' as status_details,
           (a->'period'->>'durationInDays')::numeric as duration_in_days,
           (a->'period'->>'startDate')::timestamp as start_date,
           (a->'period'->>'endDate')::timestamp as end_date,
            a->'implementation'->'financialProgress'->'breakdown' as budget,
            a->'documents' as documents,
            a->>'amendments' as amendments

    from ocds.data as r
    CROSS JOIN jsonb_array_elements(data -> 'contracts') a

);

insert into ocds.tender_items (ocid, data_id, item_id, description, classification_id, classification_description,
                                   quantity, unit_name, unit_price, unit_price_currency, attributes, lot)  (

        select distinct r.ocid,
            r.id,
           a->>'id' as item_id,
           a->>'description' as description,
           a->'classification'->>'id' as classification_id,
           a->'classification'->>'description' as classification_description,
           (a->>'quantity')::numeric as quantity,
           (a->'unit'->>'name') as unit_name,
            (a->'unit'->'value'->>'amount')::numeric as unit_price,
            a->'unit'->'value'->>'currency' as unit_price_currency,
            a->'attributes' as attributes,
            a->>'relatedLot' as lot
    from ocds.data as r
    CROSS JOIN jsonb_array_elements(data -> 'tender'-> 'items') a
);

insert into ocds.award_items (ocid, data_id, award_id, item_id, description, classification_id, classification_description,
                                  quantity, unit_name, unit_price, unit_price_currency, attributes, lot)   (

        select distinct r.ocid,
                        r.id,
           aa->>'id' as award_id,
           a->>'id' as item_id,
           a->>'description' as description,
           a->'classification'->>'id' as classification_id,
           a->'classification'->>'description' as classification_description,
           (a->>'quantity')::numeric as quantity,
           (a->'unit'->>'name') as unit_name,
            (a->'unit'->'value'->>'amount')::numeric as unit_price,
            a->'unit'->'value'->>'currency' as unit_price_currency,
            a->'attributes' as attributes,
            a->>'relatedLot' as lot
    from ocds.data as r
    CROSS JOIN jsonb_array_elements(data -> 'awards') aa
    CROSS JOIN jsonb_array_elements(aa->'items') a
);
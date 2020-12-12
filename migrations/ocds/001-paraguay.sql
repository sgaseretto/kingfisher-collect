create schema if not exists ocds;

create table if not exists ocds.data
(
    data       jsonb,
    release_id text,
    ocid       text,
    id         bigserial not null
);

create index if not exists ix_data_1a2253436964eea9
    on ocds.data (release_id);

create index if not exists ix_data_fbe00273b81f8a04
    on ocds.data (release_id, ocid);


create table if not exists ocds.procurement
(
    release_date                          timestamp,
    ocid                                  text,
    tender_id                             text,
    characteristics                       jsonb,
    tender_amount                         numeric,
    budget_amount                         numeric,
    budget_currency                       text,
    tender_currency                       text,
    tender_date_published                 timestamp,
    planning_estimated_date               timestamp,
    tender_enquiryperiod_start_date       timestamp,
    tender_enquiryperiod_end_date         timestamp,
    tender_tenderperiod_end_date          timestamp,
    tender_tenderperiod_start_date        timestamp,
    tender_procurementmethoddetails       text,
    buyer_name                            text,
    buyer_id                              text,
    tender_bidopening_date                timestamp,
    tender_awardcriteria_details          text,
    tender_status                         text,
    tender_title                          text,
    tender_mainprocurementcategorydetails text,
    tender_numberoftenderers              text,
    analyzed                              boolean,
    number_of_awards                      integer,
    framework_agreement                   boolean,
    electronic_auction                    boolean,
    budget                                jsonb,
    documents                             jsonb,
    tender_numberofenquiries              integer,
    url                                   text,
    id                                    bigserial not null
        constraint procurement_pk
            primary key,
    data_id                               bigint
);

create table if not exists ocds.parties
(
    ocid                    text,
    party_id                text,
    name                    text,
    contact_point_email     text,
    contact_point_name      text,
    contact_point_telephone text,
    contact_point_fax       text,
    roles                   jsonb,
    entity_level            text,
    entity_entity_type      text,
    entity_type             text,
    supplier_type           text,
    address_country          text,
    address_locality        text,
    address_region          text,
    address_street          text,
    id                      bigserial not null
        constraint parties_pk
            primary key,
    data_id                 bigint
);

create table if not exists ocds.award
(
    ocid          text,
    award_id      text,
    date          timestamp,
    amount        numeric,
    currency      text,
    status        text,
    supplier_id   text,
    supplier_name text,
    documents     jsonb,
    buyer_id      text,
    buyer_name    text,
    id            bigserial not null
        constraint award_pk
            primary key,
    data_id       bigint
);

create table if not exists ocds.contract
(
    ocid             text,
    contract_id      text,
    award_id         text,
    date_signed      timestamp,
    amount           numeric,
    currency         text,
    status           text,
    duration_in_days numeric,
    start_date       timestamp,
    end_date         timestamp,
    budget           jsonb,
    documents        jsonb,
    id               bigserial not null
        constraint contract_pk
            primary key,
    data_id          bigint
);

create table if not exists ocds.tender_items
(
    ocid                       text,
    item_id                    text,
    description                text,
    classification_id          text,
    classification_description text,
    quantity                   numeric,
    unit_name                  text,
    unit_price                 numeric,
    unit_price_currency        text,
    attributes                 jsonb,
    lot                        text,
    id                         bigserial not null
        constraint tender_items_pk
            primary key,
    data_id                    bigint
);

create table if not exists ocds.award_items
(
    ocid                       text,
    award_id                   text,
    item_id                    text,
    description                text,
    classification_id          text,
    classification_description text,
    quantity                   numeric,
    unit_name                  text,
    unit_price                 numeric,
    unit_price_currency        text,
    attributes                 jsonb,
    lot                        text,
    id                         bigserial not null
        constraint award_items_pk
            primary key,
    data_id                    bigint
);


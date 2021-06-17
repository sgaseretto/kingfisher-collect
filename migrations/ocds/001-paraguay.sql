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
    tender_status_details                 text,
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
    status_details        text,
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
    status_details           text,
    duration_in_days numeric,
    start_date       timestamp,
    end_date         timestamp,
    budget           jsonb,
    documents        jsonb,
--     amendments       jsonb,
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

CREATE MATERIALIZED VIEW IF NOT EXISTS ocds.unique_suppliers AS
(
SELECT DISTINCT parties.name                                  AS name,
                replace(party_id, 'PY-RUC-'::text, ''::text) AS ruc,
                regexp_replace(parties.contact_point_telephone, '[^0-9]+'::text,
                               ''::text, 'g'::text)                                      AS telephone,
                parties.contact_point_name         AS contact_point,
                parties.address_country       AS pais,
                parties.address_region     AS departamento,
                parties.address_locality   AS ciudad,
                parties.address_street     AS direccion
FROM ocds.parties as parties
WHERE NOT parties.roles ? 'buyer'::text
  AND NOT parties.roles ? 'procuringEntity'::text
  AND NOT parties.roles ? 'payer'::text
  AND parties.party_id ~~ 'PY-RUC-%'::text );

alter table ocds.procurement add column if not exists tender_procurementmethod text;

-- Creacion de una vista de objetos de gastos unicos ordenados ascendentemente
CREATE OR REPLACE VIEW ocds.view_objeto_gasto AS
    SELECT distinct(g."codigoObjetoGasto"), g."objetoGasto"
    FROM entidad_gasto g
    ORDER BY g."codigoObjetoGasto" ASC;

-- vista de adjudicaciones
CREATE OR REPLACE VIEW ocds.view_adjudicaciones AS
    SELECT
       p.data_id as data_id,
       p.budget::json->0->'classifications'->>'anio' as anho,
       p.budget::json->0->'classifications'->>'nivel' as nivel,
       e."descripcionNivel" as descripcion_nivel,
       p.budget::json->0->'classifications'->>'entidad' as entidad,
       e."descripcionEntidad" as descripcion_entidad,
       og."codigoObjetoGasto" as codigo_objeto_gasto,
       og."objetoGasto" as descripcion_objeto_gasto,
       a.currency as moneda,
       p.tender_procurementmethoddetails as modalidad,
       p.tender_mainprocurementcategorydetails as categoria,
       a.status as estado,
       a.amount as monto,
--        c.amendments::json->0->'amendments'->>'amendsAmount'->>'amount' as monto_ampliacion,
--        c.amendments::json->0->'amendments'->>'amendsAmount'->>'currency' as moneda_ampliacion,
       p.tender_date_published as fecha_publicacion,
       p.budget::json->0->'classifications'->>'objeto_gasto' as objeto_llamado,
       p.electronic_auction as subasta_electronica,
       CASE WHEN p.tender_id like '%plurianual%' THEN true ELSE false END as plurianual,
       a.award_id
    FROM ocds.procurement p
    LEFT JOIN ocds.award a ON p.data_id = a.data_id
    LEFT JOIN entidad_entidad e ON e."nivel"::text = p.budget::json->0->'classifications'->>'nivel'
                                        AND e."codigoEntidad"::text = p.budget::json->0->'classifications'->>'entidad'
    INNER JOIN ocds.view_objeto_gasto og ON og."codigoObjetoGasto"::text = p.budget::json->0->'classifications'->>'objeto_gasto'
    INNER JOIN ocds.contract c ON c.data_id = p.data_id
    WHERE e.anio = 2020;

-- vista para planificaciones
CREATE OR REPLACE VIEW ocds.view_planificaciones AS
    SELECT
       p.data_id as data_id,
       p.budget::json->0->'classifications'->>'anio' as anho,
       p.budget::json->0->'classifications'->>'nivel' as nivel,
       e."descripcionNivel" as descripcion_nivel,
       p.budget::json->0->'classifications'->>'entidad' as entidad,
       e."descripcionEntidad" as descripcion_entidad,
       a.currency as moneda,
       p.tender_procurementmethoddetails as modalidad,
       p.tender_mainprocurementcategorydetails as categoria,
       p.tender_status as estado,
       p.tender_status_details as descripcion_estado,
       c.date_signed as fecha_implementacion,
       date_part('month', c.date_signed) as mes_implementacion,       -- falta mes de ejecucion
       CASE WHEN p.tender_id like '%plurianual%' THEN true ELSE false END as plurianual,
       a.amount as monto,
       og."codigoObjetoGasto" as codigo_objeto_gasto,
       og."objetoGasto" as descripcion_objeto_gasto,
       p.budget::json->0->'classifications'->>'objeto_gasto' as objeto_llamado,
       date_part('month', p.tender_date_published) as mes_publicacion,
--        p.tender_date_published as fecha_publicacion,
       p.electronic_auction as subasta_electronica,
       p.planning_estimated_date as fecha_planificacion,
       a.award_id
    FROM ocds.procurement p
    LEFT JOIN ocds.award a ON a.data_id = p.data_id
    LEFT JOIN entidad_entidad e ON e."nivel"::text = p.budget::json->0->'classifications'->>'nivel'
                                        AND e."codigoEntidad"::text = p.budget::json->0->'classifications'->>'entidad'
    INNER JOIN ocds.view_objeto_gasto og ON og."codigoObjetoGasto"::text = p.budget::json->0->'classifications'->>'objeto_gasto'
    INNER JOIN ocds.contract c ON c.data_id = p.data_id
    WHERE e.anio = 2020;


-- vista de convocatoria
CREATE OR REPLACE VIEW ocds.view_convocatorias AS
    SELECT
       p.data_id as data_id,
       p.budget::json->0->'classifications'->>'anio' as anho,
       p.budget::json->0->'classifications'->>'nivel' as nivel,
       e."descripcionNivel" as descripcion_nivel,
       p.budget::json->0->'classifications'->>'entidad' as entidad,
       e."descripcionEntidad" as descripcion_entidad,
       p.tender_procurementmethoddetails as modalidad,
       p.tender_mainprocurementcategorydetails as categoria,
       p.tender_status as estado,
       p.tender_status_details as descripcion_estado,
       a.amount as monto,
       a.currency as moneda,
       og."codigoObjetoGasto" as codigo_objeto_gasto,
       og."objetoGasto" as descripcion_objeto_gasto,
       p.planning_estimated_date as fecha_planificacion,
       p.tender_date_published as fecha_publicacion,
       p.electronic_auction as subasta_electronica

    FROM ocds.procurement p
    LEFT JOIN ocds.award a ON a.data_id = p.data_id
    LEFT JOIN entidad_entidad e ON e."nivel"::text = p.budget::json->0->'classifications'->>'nivel'
                                        AND e."codigoEntidad"::text = p.budget::json->0->'classifications'->>'entidad'
    INNER JOIN ocds.view_objeto_gasto og ON og."codigoObjetoGasto"::text = p.budget::json->0->'classifications'->>'objeto_gasto'
    INNER JOIN ocds.contract c ON c.data_id = p.data_id
    WHERE e.anio = 2020;
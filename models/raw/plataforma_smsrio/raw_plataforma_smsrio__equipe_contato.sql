{{
    config(
        alias="equipe_contato",
        tags="smsrio_equipe"
    )
}}
with 
    source as (
        select * from {{ source('brutos_plataforma_smsrio_staging','subpav_cnes__contatos_equipes') }}
    ),
    most_recent as (
        select * from source
        qualify row_number() over (partition by ine order by updated_at desc) = 1
    ),
    transform as (
        select 
            -- Chave Primária
            SAFE_CAST(ine as string) as ine,

            -- Contato
            safe_cast(cod_area as string) as id_area,
            safe_cast(telefone as string) as telefone,
            safe_cast(email as string) as email,
            safe_cast(imei as string) as imei,
            safe_cast(user_id as string) as user_id,

            -- Metadata columns
            timestamp_add(datetime(timestamp({{process_null('created_at')}}), 'America/Sao_Paulo'),interval 3 hour) as created_at,
            timestamp_add(datetime(timestamp({{process_null('updated_at')}}), 'America/Sao_Paulo'),interval 3 hour) as updated_at,
        from most_recent
    )
select * from source
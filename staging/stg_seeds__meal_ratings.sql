with

source as (

    select * from {{ ref('sds_meal_ratings') }}

),

final as (

    select
        cast(rating_id as int64) as rating_id,
        cast(meal_id as string) as meal_id,
        cast(user_id as int64) as user_id,
        cast(rating_score as int64) as rating_score,
        cast(rating_comment as string) as rating_comment,
        cast(meal_date as date) as meal_date,
        cast(created_at as datetime) as created_at

    from source

)

select * from final

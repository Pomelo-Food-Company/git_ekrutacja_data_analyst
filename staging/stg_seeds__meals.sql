with

source as (

    select * from {{ ref('sds_meals') }}

),

final as (

    select
        cast(meal_id as string) as meal_id,
        cast(meal_name as string) as meal_name,
        cast(meal_category as string) as meal_category,
        cast(calories as int64) as calories,
        cast(is_vegetarian as boolean) as is_vegetarian,
        cast(is_active as boolean) as is_active

    from source

)

select * from final

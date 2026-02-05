with

meals as (

    select * from {{ ref('stg_seeds__meals') }}

),

final as (

    select
        -- 1. Primary Key (Surrogate Key)
        {{ dbt_utils.generate_surrogate_key([
            'cast(meals.meal_id as string)'
        ]) }} as meal_sk,

        -- 2. Natural Primary Key
        meals.meal_id,

        -- 3. Business logic fields
        meals.meal_name,
        meals.meal_category,
        meals.is_vegetarian,
        meals.is_active,

        -- 4. Numeric fields
        meals.calories

    from meals

)

select * from final

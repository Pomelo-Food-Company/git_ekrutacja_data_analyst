{#
    Model: fct_meal_ratings

    Tabela faktów z ocenami posiłków.
    Ten model zawiera celowo wprowadzone błędy do code review.

    Zadanie: Znajdź i opisz wszystkie problemy w tym modelu.
#}

with

meal_ratings as (
    select * from {{ ref('stg_seeds__meal_ratings') }}
),
meals as (
    select * from {{ ref('dim_meals') }}
),

final as (

    select
        meals.meal_sk,
        meal_ratings.rating_id,
        meal_ratings.meal_id,
        meal_ratings.user_id,
        meal_ratings.rating_score,
        meal_ratings.rating_comment,
        meal_ratings.meal_date,
        meal_ratings.created_at

    from meal_ratings

    inner join meals
        on meal_ratings.meal_id = meals.meal_id

)

select * from final

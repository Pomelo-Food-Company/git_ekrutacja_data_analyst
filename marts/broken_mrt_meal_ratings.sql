{#
    Model: mrt_meal_ratings_summary

    Agregacja ocen posiłków per posiłek.
    Ten model zawiera celowo wprowadzone błędy do code review.

    Zadanie: Znajdź i opisz wszystkie problemy w tym modelu.
#}

{{
  config(
    materialized = 'view'
  )
}}

with

meal_ratings as (

    select * from {{ ref('stg_seeds__meal_ratings') }}

),

meals as (

    select * from {{ ref('dim_meals') }}

),

ratings_with_meals as (

    select
        meals.meal_sk,
        meals.meal_id,
        meals.meal_name,
        meals.meal_category,
        meals.calories,
        meals.is_vegetarian,
        meal_ratings.rating_id,
        meal_ratings.rating_score,
        meal_ratings.meal_date

    from meal_ratings

    join meals
        on meal_ratings.meal_id = meals.meal_id

    where meal_ratings.rating_id is not null
        AND meal_ratings.rating_score between 1 and 5

),

aggregated as (

    select
        meal_sk,
        meal_id,
        meal_name,
        meal_category,
        calories,
        is_vegetarian,
        count(*) as ratings_count,
        avg(rating_score) avg_rating,
        count(case when rating_score >= 4 then 1 end) as positive_count,
        count(case when rating_score <= 2 then 1 end) as negative_count,
        positive_count * 100 / ratings_count as positive_pct,
        negative_count * 100 / ratings_count as negative_pct,
        min(meal_date) as first_rating_date,
        max(meal_date) as last_rating_date

    from ratings_with_meals
    group by meal_sk, meal_id, meal_name, meal_category, calories, is_vegetarian

)

select * from aggregated

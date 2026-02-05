# dbt Style Guide (skrócona wersja)

Ten dokument zawiera najważniejsze zasady formatowania kodu w tym projekcie dbt.

---

## 1. Nazewnictwo modeli

| Warstwa | Konwencja | Przykład |
|---------|-----------|----------|
| Staging | `stg_<source>__<table>` | `stg_seeds__meal_ratings` |
| Dimension | `dim_<entity>` | `dim_meals` |
| Fact | `fct_<entity>` | `fct_meal_ratings` |
| Mart | `mrt_<description>` | `mrt_meal_ratings_summary` |

- Nazwy zawsze w **liczbie mnogiej** (np. `ratings`, nie `rating`)
- Wszystko w **snake_case**

---

## 2. Struktura CTE

Każdy model powinien używać wzorca CTE z `final` na końcu:

```sql
with

source_data as (

    select * from {{ ref('stg_model') }}

),

transformed as (

    select
        ...
    from source_data

),

final as (

    select * from transformed

)

select * from final
```

**Kluczowe zasady:**
- `with` na początku, potem pusta linia
- Puste linie **wewnątrz** nawiasów CTE
- `final` CTE na końcu - ułatwia debugowanie
- Wszystkie `{{ ref() }}` na górze pliku w osobnych CTE

---

## 3. Formatowanie SQL

### Podstawowe zasady

| Zasada | Przykład |
|--------|----------|
| Indentacja | **4 spacje** |
| Przecinki | **trailing** (na końcu linii) |
| Max długość linii | **80 znaków** |
| Nazwy kolumn | **lowercase** |
| Aliasy | Zawsze z `as` |
| GROUP BY | **by number** (`group by 1, 2`) |

### Przykład formatowania

```sql
select
    rating_id,
    meal_id,
    user_id,
    case
        when rating_score >= 4 then 'positive'
        when rating_score <= 2 then 'negative'
        else 'neutral'
    end as rating_category,
    created_at

from ratings

where rating_id is not null
    and created_at >= '2024-01-01'
```

### JOIN-y

- Zawsze **explicit** (`left join`, nie `join`)
- Pusta linia przed każdym JOIN
- Pełne nazwy tabel (nie aliasy jednoliterowe)

```sql
from meal_ratings

left join meals
    on meal_ratings.meal_id = meals.meal_id

left join users
    on meal_ratings.user_id = users.user_id
```

---

## 4. Kolejność pól w modelu

W modelach warehouse (dim_, fct_) pola zawsze w tej kolejności:

```sql
select
    -- 1. Primary Key (Surrogate Key)
    {{ dbt_utils.generate_surrogate_key([
        'cast(rating_id as string)'
    ]) }} as meal_rating_sk,

    -- 2. Natural Primary Key
    rating_id,

    -- 3. Foreign Keys (Surrogate) - z coalesce!
    coalesce(dim_meals.meal_sk, '-1') as meal_sk,

    -- 4. Natural Foreign Keys
    meal_id,
    user_id,

    -- 5. Business logic fields
    rating_comment,

    -- 6. Numeric/measurement fields
    rating_score,

    -- 7. Timestamps
    meal_date,
    created_at
```

---

## 5. Surrogate Keys

W modelach wymiarów (dim_) i faktów (fct_) używamy surrogate key

**Ważne:**
- Zawsze `cast(... as string)` wewnątrz
- Nazwa kończy się na `_sk` (surrogate key)
- Umieszczamy jako **pierwszą** kolumnę

---

## 6. Foreign Keys z coalesce

W tabelach faktów (fct_) używamy `coalesce()` dla FK do wymiarów:

```sql
-- Jeśli nie ma pasującego rekordu w dim, używamy '-1' jako default
coalesce(dim_meals.meal_sk, '-1') as meal_sk,
```

**Dlaczego?**
- LEFT JOIN może zwrócić NULL jeśli nie ma dopasowania
- `-1` jako default pozwala zachować rekord (nie tracimy danych)
- Ułatwia identyfikację "orphan" rekordów

---

## 7. Konfiguracja modeli

### Marts - zawsze jako tabele

```sql
{{
  config(
    materialized = 'table'
  )
}}

with
...
```

---

## 8. Agregacje w martach

```sql
select
    dim_meals.meal_id,
    dim_meals.meal_name,

    count(*) as ratings_count,
    avg(fct.rating_score) as avg_rating,

    -- Procenty z obsługą dzielenia przez 0
    round(
        count(case when fct.rating_score >= 4 then 1 end) * 100.0
        / nullif(count(*), 0),
        1
    ) as positive_pct

from fct_meal_ratings as fct

inner join dim_meals
    on fct.meal_sk = dim_meals.meal_sk

group by 1, 2  -- GROUP BY by number, nie by name
```

---

## 10. Custom Tests

Custom testy umieszczamy w `macros/`:

**Kluczowe:**
- `{% test nazwa_testu(model) %}` ... `{% endtest %}`
- `{{ model }}` odnosi się do testowanego modelu
- Test PASS = 0 zwróconych wierszy
- Test FAIL = 1+ zwróconych wierszy

**Użycie w YAML:**
```yaml
models:
  - name: fct_meal_ratings
    data_tests:
      - rating_count_matches_staging
```

---

## 11. Jinja

- Spacje wewnątrz delimiterów: `{{ this }}` nie `{{this}}`
- Nowe linie między blokami logicznymi

---

## Wzorce do naśladowania

| Co | Gdzie |
|----|-------|
| Staging model | `models/staging/caterings/stg_caterings__dish.sql` |
| Dimension model | `models/warehouse/dimensions/dim_dishes.sql` |
| Fact model | `models/warehouse/facts/fct_orders.sql` |
| Mart model | `models/marts/mrt_bag_items_ratings.sql` |
| Custom test | `macros/test_bag_count_matches_staging.sql` |
| YAML testy | `models/warehouse/dimensions/_dimensions__models.yml` |

---

## Szybka checklista

Przed zakończeniem sprawdź:

- [ ] CTEs z pustymi liniami wewnątrz
- [ ] Trailing commas
- [ ] 4 spacje indentacji
- [ ] `final` CTE na końcu
- [ ] Surrogate key jako pierwsza kolumna
- [ ] `coalesce()` na FK w tabelach faktów
- [ ] Explicit JOINs (`left join`, `inner join`)
- [ ] Puste linie przed JOIN-ami
- [ ] `group by 1, 2` (nie by name)
- [ ] `materialized = 'table'` w martach
- [ ] Testy unique/not_null na primary key
- [ ] `nullif()` przy dzieleniu (unikaj /0)

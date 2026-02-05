# Zadanie Live Coding - Data Analyst (dbt)

> **Czas:** 90 minut | **Narzędzia:** Claude Code / AI dozwolone

---

## Kontekst biznesowy

Zespół produktowy chce lepiej rozumieć jakość naszych posiłków. Potrzebujemy modelu danych, który pozwoli analizować oceny klientów. Mamy surowe dane w plikach CSV - Twoim zadaniem jest zbudować pełny 3-warstwowy pipeline danych.

---

## Architektura do zbudowania

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────────────┐
│     STAGING     │     │    WAREHOUSE    │     │          MARTS          │
│   (już gotowe)  │     │                 │     │                         │
├─────────────────┤     ├─────────────────┤     ├─────────────────────────┤
│                 │     │                 │     │                         │
│ stg_seeds__     │────►│   dim_meals     │─┐   │ mrt_meal_ratings_       │
│ meals           │     │   (wymiar)      │ │   │ summary                 │
│                 │     │                 │ │   │                         │
│ stg_seeds__     │────►│ fct_meal_       │─┴──►│ (agregat per posiłek)   │
│ meal_ratings    │     │ ratings (fakty) │     │                         │
│                 │     │                 │     │                         │
└─────────────────┘     └─────────────────┘     └─────────────────────────┘
```

---

## Dane źródłowe

W tym folderze znajdują się dwa pliki CSV (skopiuj je do `seeds/` w projekcie):

**`sds_meal_ratings.csv`** - oceny posiłków (12 wierszy)
| Kolumna | Opis |
|---------|------|
| rating_id | Identyfikator oceny (PK) |
| meal_id | Identyfikator posiłku (FK) |
| user_id | Identyfikator użytkownika |
| rating_score | Ocena 1-5 |
| rating_comment | Komentarz (opcjonalny) |
| meal_date | Data posiłku |
| created_at | Timestamp utworzenia |

**`sds_meals.csv`** - słownik posiłków (6 wierszy)
| Kolumna | Opis |
|---------|------|
| meal_id | Identyfikator posiłku (PK) |
| meal_name | Nazwa posiłku |
| meal_category | Kategoria (Obiad, Lunch, Zupa) |
| calories | Kalorie |
| is_vegetarian | Czy wegetariański |
| is_active | Czy aktywny w ofercie |

---

## Zadania do wykonania

### 1. Eksploracja danych (10 min)
- Przejrzyj dane w plikach CSV
- **Zidentyfikuj problemy z jakością danych** (są celowo!)
- Zastanów się, w której warstwie je rozwiązać

### 2. Staging review (10 min)
Modele staging już istnieją w `models/staging/seeds/`.

**Zadanie:** Przejrzyj je i dodaj brakujące testy w `_seeds__models.yml`.

### 3. dim_meals - Wymiar posiłków (15 min)
Stwórz w `models/warehouse/dimensions/`:

| Aspekt | Wymaganie |
|--------|-----------|
| Granulacja | 1 wiersz = 1 posiłek |
| Surrogate key | `meal_sk` (użyj `dbt_utils.generate_surrogate_key()`) |
| Kolumny | meal_id, meal_name, meal_category, calories, is_vegetarian, is_active |

### 4. fct_meal_ratings - Fakty ocen (20 min)
Stwórz w `models/warehouse/facts/`:

| Aspekt | Wymaganie |
|--------|-----------|
| Granulacja | 1 wiersz = 1 ocena (po deduplikacji!) |
| Surrogate key | `meal_rating_sk` |
| Foreign key | `meal_sk` do dim_meals |
| Obsłuż problemy | Duplikaty, null ID |
| Metryki | rating_score |

### 5. mrt_meal_ratings_summary - Mart (20 min)
Stwórz w `models/marts/`:

| Aspekt | Wymaganie |
|--------|-----------|
| Granulacja | 1 wiersz = 1 posiłek |
| Metryki | avg_rating, ratings_count, positive_pct (4-5), negative_pct (1-2) |
| Atrybuty | meal_name, meal_category, calories, is_vegetarian |

**Oczekiwany output (przykład):**

| meal_name | ratings_count | avg_rating | positive_pct |
|-----------|---------------|------------|--------------|
| Kurczak w sosie curry | 4 | 4.75 | 100.0 |
| Sałatka grecka | 3 | 4.33 | 66.7 |
| Łosoś z warzywami | 2 | 3.50 | 50.0 |

### 6. Custom Test (10 min)
- Stwórz test porównujący liczbę rekordów staging vs fact
- Dodaj do YAML modelu

---

## Struktura plików do stworzenia

```
models/
├── staging/seeds/
│   └── _seeds__models.yml           ← uzupełnij testy
│
├── warehouse/
│   ├── dimensions/
│   │   ├── dim_meals.sql            ← STWÓRZ
│   │   └── _dimensions__models.yml  ← uzupełnij
│   └── facts/
│       ├── fct_meal_ratings.sql     ← STWÓRZ
│       └── _facts__models.yml       ← uzupełnij
│
└── marts/
    ├── mrt_meal_ratings_summary.sql ← STWÓRZ
    └── _marts__models.yml           ← uzupełnij

macros/
└── test_rating_count_matches_staging.sql  ← STWÓRZ
```

---

## Przydatne referencje

| Co | Gdzie |
|----|-------|
| **Style guide (skrócony)** | `style_guide.md` (w tym folderze) |
| Style guide (pełny) | `_project_docs/style_guide.md` |
| Wzorzec wymiaru | `models/warehouse/dimensions/dim_dishes.sql` |
| Wzorzec faktów | `models/warehouse/facts/fct_orders.sql` |
| Wzorzec martu | `models/marts/mrt_bag_items_ratings.sql` |
| Wzorzec custom testu | `macros/test_bag_count_matches_staging.sql` |

---

## Weryfikacja

```bash
source ../dbt-env/bin/activate
DBT_PROFILES_DIR=. dbt compile --select +mrt_meal_ratings_summary
DBT_PROFILES_DIR=. dbt test --select fct_meal_ratings mrt_meal_ratings_summary
```

---

## Na co zwracamy uwagę

| Aspekt | Co oceniamy |
|--------|-------------|
| **Eksploracja** | Czy znajdziesz problemy w danych? |
| **Architektura** | Czy rozumiesz różnicę dim / fct / mrt? |
| **Jakość kodu** | Zgodność ze style guide, CTEs, naming |
| **Edge cases** | Obsługa null, duplikatów, dzielenia przez 0 |
| **Współpraca z AI** | Czy weryfikujesz kod? Czy rozumiesz co robi? |

---

## Uwagi końcowe

- Możesz swobodnie korzystać z **Claude Code / AI**
- Deleguj zadania do AI, ale **weryfikuj i rozumiej** kod
- Ważne jest **uzasadnianie decyzji** - będziemy pytać "dlaczego?"
- **Pytaj**, jeśli coś jest niejasne

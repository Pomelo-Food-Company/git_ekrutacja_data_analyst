# Code Review Task - Senior Data Analyst

## Kontekst

Otrzymujesz do przeglądu dwa modele dbt z projektu analitycznego dla firmy cateringowej.
Modele zawierają problemy znalezione podczas audytu kodu.

**Twoje zadanie:**
1. Przeprowadź code review obu modeli
2. Zidentyfikuj i opisz wszystkie problemy
3. Ustal priorytety napraw (co jest krytyczne vs nice-to-have)
4. Napraw **jeden** wybrany model

---

## Dostępne materiały

### Do przeglądu:
- `warehouse/broken_fct_meal_ratings.sql` - tabela faktów z ocenami
- `marts/broken_mrt_meal_ratings.sql` - mart z agregacjami

### Referencja (poprawne modele):
- `warehouse/dim_meals.sql` - wymiar posiłków (poprawny)
- `staging/stg_seeds__meals.sql` - staging posiłków
- `staging/stg_seeds__meal_ratings.sql` - staging ocen
- `style_guide.md` - standard formatowania kodu

### Dane źródłowe:
- `seeds/sds_meals.csv` - 6 posiłków
- `seeds/sds_meal_ratings.csv` - 12 ocen (uwaga: zawiera problemy w danych!)

---

## Część 1: Code Review (20 min)

Przejrzyj oba modele i odpowiedz:

### broken_fct_meal_ratings.sql
1. Jakie problemy widzisz w tym modelu?
2. Które z nich są krytyczne?
3. Jakie będą konsekwencje tych błędów?

### broken_mrt_meal_ratings.sql
1. Jakie problemy widzisz w tym modelu?
2. Czy model poprawnie korzysta z warstw (staging → warehouse → marts)?
3. Jakie błędy spowodują runtime error vs błędne dane?

---

## Część 2: Priorytetyzacja (10 min)

Mając listę wszystkich znalezionych problemów:

1. **Które 3 błędy naprawiłbyś w pierwszej kolejności?**
   - Uzasadnij dlaczego

2. **Które błędy możesz tymczasowo zignorować?**
   - Uzasadnij dlaczego

3. **Jak zakomunikowałbyś te błędy autorowi kodu?**

---

## Część 3: Naprawa (20 min)

Wybierz **jeden** model do naprawy:

### Opcja A: broken_fct_meal_ratings.sql
- Mniejszy model, mniej błędów
- Wymaga znajomości wzorców data warehouse

### Opcja B: broken_mrt_meal_ratings.sql
- Więcej błędów różnych typów
- Wymaga naprawy SQL i architektury

**Wymagania:**
- Napraw wszystkie krytyczne błędy
- Zachowaj zgodność ze style guide
- Dodaj komentarze wyjaśniające kluczowe decyzje

---

## Część 4: Dyskusja (10 min)

Pytania architektoniczne:

1. **"Dlaczego mart pomija fct i idzie bezpośrednio do staging?"**

2. **"Jak zapobiegłbyś takim błędom w przyszłości?"**

3. **"Co byś zmienił w procesie code review w tym zespole?"**

---

## Wskazówki

- Zacznij od eksploracji danych (`seeds/*.csv`)
- Sprawdź `style_guide.md` przed oceną formatowania
- Zwróć uwagę na różnicę między:
  - Błędami kompilacji (SQL nie zadziała)
  - Błędami logicznymi (SQL zadziała, ale da złe wyniki)
  - Błędami stylistycznymi (działa, ale niespójne z konwencjami)

---

## Ocena

| Obszar | Max punkty |
|--------|------------|
| Znalezione błędy w fct | 40 |
| Znalezione błędy w mrt | 45 |
| Priorytetyzacja | 10 |
| Jakość naprawy | 20 |
| Komunikacja/dyskusja | 10 |
| **RAZEM** | **125** |

---

## Powodzenia!

Pamiętaj: celem nie jest znalezienie WSZYSTKICH błędów, ale pokazanie jak myślisz o jakości kodu, priorytetyzujesz problemy i komunikujesz się w zespole.

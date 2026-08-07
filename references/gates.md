# Kapuk — számítás, ár, render

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.

Az `assemble` és a `revise` közös kapui. Sorrendben futnak, és egyik sem opcionális: a számítási kapu az ár prezentálása előtt, az ár-kapu a véglegesítés előtt, a render-QA a kész kimeneten.

## Számítási kapu

Az ár prezentálása **előtt**: számold ki tételesen ÉS összesítve, vesd össze. Sanity check: a végösszeg **a legközelebbi összemérhető nagyságrendjében** van-e — ha nem, a levezetés hibás. Diagnosztizáld a konkrét hibát, ne generáld újra az egészet.

**A kapu minden számpárra vonatkozik, nem csak az árra.** Két szám, ami a dokumentumban ugyanarról beszél, nem mondhat ellent egymásnak:

- tételes ár = összesített ár; nettó × ÁFA-kulcs = bruttó;
- létszám × arány = ígért kapacitás (mért hiba: „~4 × 25 fős csoport" és „25 főnként 1 facilitátor" mellett 3 facilitátor ígérete — ugyanabban a mondatban);
- idő-blokkok összege = a blokk teljes időkerete; darabszámok a szövegben = darabszámok a táblában.

A dokumentum-master zárása előtt ez a keresztellenőrzés a **teljes szövegen** fut le, nem csak az ár-szekción.

## Ár-kapu

A kapu **bármelyik** feltétel teljesülésekor megszólal:

1. az ügyfél költségvetési plafonja a javasolt ár alatt van;
2. a javasolt ár a legalacsonyabb **`won`** összemérhető alatt van;
3. van `cost_floor` érték, és a javasolt ár az alatt van.

Ilyenkor a kimenet kötelezően tartalmazza ezt a blokkot:

```markdown
## Ár-kapu — jóváhagyás szükséges
- Javasolt ár: <érték>
- Kiváltó feltétel: <1 / 2 / 3, és a szembeállított érték>
- Levezetés: <mely összemérhetőkhöz képest>

A blokk után a dokumentum jóváhagyásig nem tartalmaz véglegesített összeget.
```

Nem értékelhető feltételt (nincs plafon, `won` tétel vagy `cost_floor`) írj ki annak — a kapu a többiből még megszólalhat; ha egyik sem értékelhető, az maga is jelzés a belső jegyzetbe.

A folyamat itt megáll. Ez strukturális slot, nem tiltás — a döntés (alacsonyabb ár, scope-vágás, fázisolás, nemet mondás) a felhasználóé.

## Render-QA

A kész kimeneten fut (nem a forráson), és **abban a renderelőben mérve, amiben az ügyfél-artefakt élni fog** — docx-nél Word, ha elérhető; a helyettesítő renderelők tördelése mérhetően, oldalhatárnyit eltér.

- **Oldalkép:** nincs üres vagy csaknem üres utolsó oldal, nincs árván átlógó záróblokk.
- **Karakterek:** magyar/CEE szövegnél ■ / `�` ellenőrzés a renderelt kimeneten — csak 0 hibánál megy tovább.
- **Számok:** a számítási kapu állításai (tételes = összesített, nettó × ÁFA = bruttó, létszám × arány = kapacitás) a renderelt szövegben is stimmelnek.

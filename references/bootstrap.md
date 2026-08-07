# Bootstrap — `{memoryRoot}`, `{company}`, `{slug}` feloldása

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

Minden proposal-skill innen szerzi meg ezt a három értéket. A skillek erre a fájlra hivatkoznak, nem ismétlik meg a logikát. Bármelyik skill lehet a belépési pont — a `drive` és az `init` mellett a `clarify` és az `assemble` is —, ezért mindegyiknek végig kell futnia ezen, mielőtt bármit írna.

## `{memoryRoot}`

Olvasd be: `~/.claude/data/proposal/bootstrap.json`.

- **Ha létezik:** vedd ki a `memoryRoot` értékét.
- **Ha nem létezik:** ez első futás. Kérdezd meg a memória-gyökeret (javasolt alapérték: `~/Documents/memory`), majd hozd létre a fájlt `{"memoryRoot": "<válasz>"}` tartalommal.
- **Soha ne találj ki gyökeret**, és ne írj egyetlen fájlt sem, amíg a kérdésre nincs válasz.

## `{company}`

A felhasználónak több cége is lehet — **soha ne feltételezz egyet**. Sorrend:

1. argumentumból, ha kaptál;
2. a deal `deal.md` frontmatterének `company` mezőjéből;
3. egyébként kérdezd meg.

A normalizálás szabálya (és hogy miért kell karakterre egyeznie a mappanévvel): `{pluginRoot}/references/deal-state.md` → „Cég-azonosító normalizálása".

## `{slug}`

1. Ha az argumentum egy slug vagy cégnév, feleltesd meg egy meglévő `{memoryRoot}/deals/{slug}/` mappának.
2. Ha nincs argumentum, listázd a `{memoryRoot}/deals/` alatti mappákat, és kérdezz rá, melyikkel dolgozunk (vagy hogy új dealről van szó).
3. Ha új deal: kérj slugot és céget, hozd létre a mappát és a `deal.md`-t a `{pluginRoot}/references/deal-state.md` sémája szerint, `status: new` értékkel.

Slug-formátum: ugyanaz a normalizálás, mint a cég-azonosítónál.

## Útvonalak

| Réteg | Útvonal | Ki írja |
|---|---|---|
| cég-réteg | `{memoryRoot}/proposal/{company}/economics.md`, `.../house-style.md` | `init` |
| deal-állapot | `{memoryRoot}/deals/{slug}/deal.md` | `drive`, `clarify`, `assemble` |
| deal-kimenetek | `{memoryRoot}/deals/{slug}/clarify-*.md`, `.../proposal-master-*.md` | `clarify`, `assemble` |

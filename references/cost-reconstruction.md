---
type: Reference
title: "Proposal Skills — Cost-reconstruction & hidden-cost taxonomy (REF-09)"
description: "A REF-09 referencia-blokk önálló fájlban: valós költség és margin rekonstruálása egy elküldött árból, plusz a rejtett költségek taxonómiája. Az init és a v2-es price skill használja."
tags: [proposal, skill-spec, referencia, cost-reconstruction]
timestamp: 2026-07-11T19:16:47+02:00
---

# REF-09 · Cost-reconstruction & hidden-cost taxonomy

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

> Ez a blokk a `{pluginRoot}/references/frameworks.md` (REF-01..08) folytatása — külön fájlban, mert hosszú és csak az `init` (jelenlegi gyűjtemény) és a v2-es `price` skill használja.

> **Cél:** a valós költség és margin rekonstruálása egy *elküldött árból*, amikor a cég a költségeit implicit tartja — plusz a rejtett költségek felszínre hozása. **Confront-the-concrete:** sose absztrakt kérdés; minden érték egy valós számhoz horgonyzva, RANGE-ként, provenance+confidence bélyeggel.

> ⚑ **Ez a blokk a KÖLTSÉG-motor, nem az ár-motor.** Kimenete az `economics.md` `cost_floor` mezője
> és a `hidden_costs` taxonómia: **padlót ad, árat soha**. Az árazás forrása a `price_history` és
> **REF-12** (`{pluginRoot}/references/price-engine.md`). Az itt kiszámolt napidíjat sose szorozd
> a deal nevezőjével azért, hogy árat kapj — ez a gyűjtemény egyik mért kritikus hibája volt.
> Az egész blokk **opcionális**: ha nincs költségadat, `cost_floor.provenance: none`, és az árazás
> ettől még hiánytalanul működik.

### Loaded-rate képlet
**loaded_day_rate = éves fenntartási költség ÷ reálisan billázható napok.** A „terhelt" napidíj — szemben a listaár/„vágyott" napidíjjal. Ez a **padló** alapja. Ha a költség nem ismert: sáv választása, `provenance: benchmark-seed`, `confidence: LOW`.

### Három-utas margin-fork
Egy megfigyelt margin (M%) önmagában nem policy. Minden ár-soron el kell dönteni:

| Ág | Jelentés | Mit tár fel |
|---|---|---|
| **Target** | ez a szándékolt cél-margin | az árazási szándék |
| **Floor** | ez alá nem megy | az abszolút minimum |
| **Discount** | ez engedmény volt | a discount-reflex + a valós floor máshol van |

→ Egy szám → újrahasznosítható szabály, közel-nulla kognitív költséggel. Killer probe: *„mit felejtettél beleszámolni, amikor először áraztál egy ilyen melót?"*

### Hidden-cost taxonómia (a szivárgó margin-pontok)
A tétel, ami SOHA nincs a dokumentumban. Dealhez horgonyzva, egyesével, EUR/%-ra váltva:

- **Revíziós körök** — ígért vs. ténylegesen lefutott.
- **Scope-creep absorb** — mid-project bővülés: újraárazva vagy elnyelve?
- **Utazás / onsite** — számlázva vagy elnyelve?
- **Support-farok** — szállítás utáni ingyenes „gyors kérdés" órák.
- **Payment-delay carry** — mikor esett be a cash valójában (net-15/30 float).
- **Cost-per-pitch** — az ajánlatírás órái × (1 − win rate) = a nem nyert ajánlatok költsége.
- **Prep & anyagok / PM-koordináció** — el nem számolt előkészület.

→ 8-elemű **recognition toggle** („firmák, mint te, ezeket rendszeresen elfelejtik árazni — pipáld, amelyik harap"). Recognition-over-recall a checklistnél OK; a 3-4 margin-meghatározó SZÁMNÁL (rate, floor, discount, loaded) veszélyes — ott konkrét szám kell.

### Estimate-vs-actual variance
*„Ténylegesen hány napot evett a meló vs. amit áraztál?"* Ha nincs mérve: benchmark forcing (*„a te méretedben 20–40% a túlfutás — hol voltál őszintén?"*).

### Truth-guard (kötelező)
- Minden rekonstruált érték **RANGE**, sose álpontos pont.
- **Provenance** (document / computed-with-user / stated / benchmark-seed) + **confidence** (HIGH/MED/LOW) + timestamp minden értéken.
- **Ellentmondás felszínre, nem átlagolva.**
- **Egy-deales = provisional**, low confidence n≥3-ig vagy egy valós win/loss-ig → a tanuló kör (`/consolidate`) korrigálja.
- **`policy: emerging`** az őszinte default fiatal cég árazására — nem hazudik kiforrottságot.

→ Mikor használd: az `init` skill price-replay-e; bármely skill, ami egy sent price-ból valós margint akar visszafejteni.
→ Gyengéje: a legrosszabb inputjáig pontos — ezért kötelező a RANGE + provenance + a `/consolidate`-nak halasztás.

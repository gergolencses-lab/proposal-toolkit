---
name: revise
description: Use when feedback arrives on an existing proposal — a reviewer's notes, a client's change requests, or the user's own second thoughts — and the proposal document needs a verified revision round. Also use when the user pastes review comments about an offer, asks to work feedback into a proposal, or returns a hand-edited version of a previously assembled document.
---

# revise — visszajelzés-kör egy kész ajánlaton

> **Útvonalak.** `{pluginRoot}` = a betöltéskor kiírt `Base directory for this skill` két szinttel feljebb.

Ajánlat ritkán megy ki első verzióban. A `revise` a visszajelzés-kör: verifikál, szétválaszt (mechanika vs. döntés), revideál az **élő** artefakton, és utánahúzza a mastert meg a `deal.md`-t. Futhat kiküldés előtt és után — a `status`-t nem lépteti.

## 0. Memóriagyökér, cég, deal

`{memoryRoot}`, `{company}`, `{slug}`: `{pluginRoot}/references/bootstrap.md` — kövesd, mielőtt bármit írnál. Előfeltétel: van `assemble` sor a `deal.md`-ben; ha nincs, ez nem revízió, hanem első összeállítás → `assemble`.

## 1. Az igazság-artefakt azonosítása

Első kérdés minden körben: **melyik fájl az igazság?** A round-trip szabály (`{pluginRoot}/references/deal-state.md`) szerint ha a felhasználó kézzel szerkesztett példányt ad vissza vagy ilyenre hivatkozik a visszajelzés, **az a bázis** — nem a master. A kézi szerkesztés a rendszer normál útja, nem anomália; a mért hibaminta: a master csendben elmaradt a kézzel bővített docx mögött — az abból indult revízió elveszítette volna a felhasználó munkáját.

Ha nem egyértelmű, melyik példányra jött a visszajelzés: kérdezz, ne válassz csendben.

## 2. Visszajelzés-verifikáció (kötelező, minden pontra)

Minden észrevételt a dokumentum **tényleges szövegén** ellenőrzöl, mielőtt bárminek nekiállnál. Pontonként verdikt: **helytálló / nem áll / részben áll**, evidenciával (a konkrét szöveghely). Ami nem áll, azt kimondod és nem „javítod" — a visszajelzés-adó is tévedhet, és egy nem létező hiba javítása új hibát csinál.

**Osztály-sweep:** ha egy hibaosztályból egy példányt jeleznek, az egész osztályt végignézed. A jelzett lista szinte sosem teljes — a mért esetben hat elütést jeleztek, a teljes átvizsgálás tízet talált, köztük egy terméknevet és egy számot. Elütés-jelzés → teljes korrektúra; számhiba-jelzés → a számítási kapu teljes újrafuttatása; tördelési hiba → teljes render-QA (5. pont).

## 3. Mechanika és döntés szétválasztása

A verifikált pontok két kupacba mennek, és **csak az egyiken haladsz magadtól**:

| Kupac | Mi tartozik ide | Mi történik vele |
|---|---|---|
| **Mechanikus** | elütés, nyelvhelyesség, számszaki hiba, tördelés, konzisztencia (két szám ugyanarról mást mond) | javítod, kérdés nélkül |
| **Döntés** | ár és árszerkezet, scope-változás, lebonyolítási modell, hangnem-él, bármi, ami megváltoztatja, mire mond igent az ügyfél | felsorolod opciókkal és a mögöttes adattal, majd **megállsz és vársz** |

Ár-érintő döntés után a levezetés nem marad a régi: REF-12 újralevezetés az `economics.md` összemérhetőiből, majd a számítási kapu és az ár-kapu (`{pluginRoot}/references/gates.md`) újrafut a friss számokra. A kapuk itt sem lazábbak, mint első összeállításkor.

## 4. Végrehajtás az igazság-artefakton

A revízió a felhasználó formátumában történik (docx-ben élő artefakt → docx-szerkesztés, formázás-őrzéssel), **sebészi módban**: a jelzett és verifikált hibák javulnak, a felhasználó hangja és szövege marad. Verziójelölés kötelező: a dokumentum verziómezője és a fájlnév is lép (v2.1 → v2.2 …); a korábbi példány megmarad, nem íródik felül.

Az ár-szekciót érintő módosításnál a REF-13 árbemutatási szabályok (`{pluginRoot}/references/frameworks.md`) ugyanúgy kötnek, mint az `assemble`-ben.

## 5. Render és QA-kapu

Render a `render_chain` szerint (`{pluginRoot}/references/company-schema.md`), majd a kész kimeneten a render-QA a `{pluginRoot}/references/gates.md` szerint: oldalkép, CEE-karakterek, számok — az ügyfél-artefakt saját renderelőjében mérve, nem helyettesítőben.

## 6. Master utánahúzása

A master sosem maradhat el az élő artefakttól. A futás végén a proposal-master **delta-szekciót** kap (dátum, mi változott, miért — ár-változásnál az új levezetéssel), vagy új datált master íródik, ha a változás szerkezeti. A belső jegyzet szabályai (`{pluginRoot}/references/deal-state.md`) itt is állnak: üzemeltetői tartalom a masterbe és a futás-kimenetbe, az ügyfél-példányba soha.

## 7. Kiküldés-kapu és `deal.md` zárás

Ez a skill fájlt ír — nem küld emailt, nem posztol; a kiküldés a felhasználó lépése.

Zárásként a `deal.md` a `{pluginRoot}/references/deal-state.md` szerint frissül: `revise` sor (dátum; flag, ha döntésre váró pont maradt nyitva — pl. `döntésre vár: árszerkezet`), a „Nyitott kérdések" és a „Következő lépés" felülírva. **A `status` változatlan** — a revízió nem léptet se előre, se hátra: `solutioning` marad `solutioning`, `sent` marad `sent`.

## Idempotencia

Minden visszajelzés-kör újrafuttatható; a `revise` sor felülíródik, nem duplikálódik (a legutóbbi körre mutat). Az artefakt-verziók viszont halmozódnak — a verziólánc a revíziók auditnyoma.

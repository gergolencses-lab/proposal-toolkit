# Ajánlat-korpusz — mi számít bemenetnek, és hogyan számoljuk

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

Az `init` egyetlen bemenete a cég korábbi ajánlatanyaga. Ez a fájl mondja meg, **mi tartozik bele,
mi nem, és hogyan számolunk** — mert egy rosszul összeválogatott szett nem hibát okoz, hanem
csendben rossz cég-réteget épít, amire utána minden `assemble` futás ráépül.

---

## 1. Csak az számít, ami ténylegesen kiment az ügyfélhez

A skill „valós, elküldött ajánlatokat" kér. Ez nem formalitás: a nem elküldött anyagból tanult
stílus és ár egyaránt hamis.

Három dolog kerülhet a szettbe: **kiment ajánlat**, **kiment ajánlat egy korábbi verziója**
(lásd 4. pont), és **kiment kísérőlevél**, ha a kereskedelmi tartalom abban van.

Semmi más. Nem tartozik bele a belső jegyzet, a stratégiai memó, a nyers jegyzet, a sablon és a
sosem elküldött piszkozat.

## 2. A kimenő példány kiválasztása — a `.md` gyakran csak munkaverzió

Ha ugyanahhoz a dealhez több formátum van (`.md` **és** `.html` / `.pdf` / `.pptx` / `.docx`),
a **kimenő artefaktum a mérvadó**, nem az azonos nevű forrásfájl.

Munkaverzióra utaló jelek: kitöltetlen helyőrző (`[TBD]`, `TODO`, `XXX`, `<…>`), üres vagy nullás
ártáblázat, félbehagyott mondat vagy szekció, sablon-maradvány (más ügyfél neve, minta-szöveg),
verziószám nélküli fájl egy verziózott mappában.

**Ha a két példány eltér, a kimenő nyer** — és az eltérés maga is megfigyelés: amit küldés előtt
átírtak, hozzátettek vagy kihagytak, az a házi stílus erős jelzése (pl. a kimenő példány kapott
aláírás-blokkot és „tartalmazza / nem tartalmazza" listát, amit a piszkozat nem tartalmazott).
Az ilyen eltérést írd bele a zárásba.

Ha nem dönthető el, melyik ment ki: **kérdezd meg**. Válasz híján hagyd ki a dealt a szettből,
és a kihagyást nevezd meg — ne találgass.

## 3. Belső munkaanyag felismerése és kizárása

Van olyan fájl, ami ajánlatnak **olvassa magát**, de belső stratégiai anyag. Jelek:

- versenytárs neve, versenytárs ára, piaci horgony;
- tárgyalási forgatókönyv („ha a beszerzés nyom, mondd, hogy…"), fallback-lépcső, engedmény-tartalék;
- belső kockázati tábla, walk-away vagy minimum ár, „ez alatt nem éri meg" típusú mondat;
- belső költség, terhelt napidíj, margin, kapacitás;
- rögzített belső nézeteltérés vagy még eldöntetlen kérdés;
- megszólítás és lezárás nélküli, nem ügyfélnek címzett hangnem; belső kód- vagy becenevek;
- fájlnév/mappanév, ami stratégiát, jegyzetet, kalkulációt jelöl.

**Egy jel gyanú, kettő kizárás.** Bizonytalanságnál kérdezz; válasz híján hagyd ki.

**Kemény szabály.** Belső munkaanyag sem az `economics.md`-t, sem a `house-style.md`-t nem
kalibrálja, és a tartalma **soha nem kerülhet ügyfélnek szóló dokumentumba** — sem idézetként,
sem parafrazálva, sem hangnem-mintaként. Ez ugyanaz a bizalmassági határ, mint a belső jegyzeté
(`{pluginRoot}/references/deal-state.md`), csak a bemeneti oldalon. A kizárt fájlokat a zárásban
nevesítsd (mit hagytál ki és miért), hogy a következő futás ne kezdje elölről.

## 4. Verzióláncok — egy ajánlat, de a legjobb bizonyíték

Egy dealhez tartozó több verzió (v1 → v2 → … → FINAL) **egy ajánlatnak számít** az `n_offers`-ben.
Ettől még a lánc jellemzően a szett legértékesebb darabja, mert olyat mutat meg, amit egyetlen
dokumentum elvileg sem tud:

| Amit a lánc megmutat | Hova kerül |
|---|---|
| Hol volt a **kiinduló horgony**, és mennyit mozdult a végleges árig | `economics.md` → `margin` Discount-ág |
| **Mi mozdult és mi nem**: az ár esett-e scope-csökkentés nélkül | `economics.md` → `policy`, `divergence` |
| Az elmozdulás **kimondott oka** (ügyfél büdzséje / verseny / scope / kapcsolat) | `economics.md` → az árazási horgony természete |
| Kitartott-e a leírt minimum, amikor nyomás alá került | a `price_history` `note`-ja és a `strategic_discount_cap` valósága |
| Hány kör kellett, mennyi idő alatt | `hidden_costs` → cost-per-pitch **inputja** (a ráfordított nap ettől még mérve nincs) |

**Ha egy láncban leírt minimum később elesett, azt ki kell mondani.** Az elesett minimum nem
`strategic_discount_cap` és nem új floor — az a megfigyelés, hogy a leírt floort nyomás alatt
nem tartotta meg semmi. Egyszeri horgony-összeomlásból soha ne csinálj engedmény-politikát.

Ha van lánc, a fejlécbe `n_versions: <db>` is kerüljön az `n_offers` mellé, és a zárásban mondd meg,
melyik dealhez tartozik.

## 5. `n_offers` egysége

**Kimenő, az ügyfélnek ténylegesen elküldött dokumentum.** Pontosan:

- verziólánc → **1**;
- ugyanannak a dokumentumnak több formátuma (`.md` + `.html` + `.pdf`) → **1**;
- belső munkaanyag → **0** (nem számít bele);
- egy ügyfélnek küldött két különböző ajánlat (más scope, más deal) → **2**;
- ugyanannak a dealnek külön dokumentumként kiadott szűkített változata → **2**, mert két külön
  dokumentum ment ki (és a köztük lévő különbség maga is megfigyelés).

Ez az egység hajtja a `confidence`-t és az `n: 1..2` flaget, ezért a két kimeneti fájlban
(`economics.md`, `house-style.md`) **ugyanannak a számnak kell állnia**, ugyanezzel a definícióval.

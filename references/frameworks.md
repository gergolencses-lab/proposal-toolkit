---
type: Reference
title: "Proposal Skills — Közös referencia-könyvtár"
description: "A proposal-* skillek közös, generikus referencia-könyvtára: sales kvalifikációs, döntési, árazási, kockázati, tárgyalási és win-loss keretrendszerek (BANT, MEDDIC, BATNA, ZOPA stb.) egy helyen."
tags: [proposal, skill-spec, referencia, keretrendszerek]
timestamp: 2026-07-11T19:16:47+02:00
---

# Proposal Skills — Közös referencia-könyvtár

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

> **Cél:** A `clarify` / `assemble` / `init` (és a v2-es `price` / `negotiate` / `winloss`) skillek közös, generikus tudásrétege. Minden skill innen hivatkozik be frameworkeket, ahelyett hogy maga ismételné. Egyszer írva, hatszor használva (DRY).
>
> **Konvenció:** Ahol a skill spec-ben `lásd: REF-01` típusú hivatkozás szerepel, az ide mutat. Új framework hozzáadása előtt ellenőrizd, hogy nincs-e már itt.

---

## Tartalomjegyzék

| Kód | Csoport | Frameworkok |
|---|---|---|
| **REF-01** | Sales kvalifikáció | BANT, MEDDIC, MEDDPICC |
| **REF-02** | Decision dynamics | RACI, DACI, decision map (champion/blocker/economic buyer/user) |
| **REF-03** | Pricing strategies | cost-plus, value-based, competitive, anchoring, premium |
| **REF-04** | Risk frameworks | probability × impact, RAID log, contingency pricing |
| **REF-05** | Proposal structures | AIDA, SPIN, executive summary patterns |
| **REF-06** | Negotiation | BATNA, ZOPA, koncessziós lépcső, anchoring |
| **REF-07** | Win-loss analysis | post-mortem kérdéssor, attribution |
| **REF-08** | B2B benchmark defaults | win-rate sávok, sales cycle, deal size, margin ranges |
| **REF-13** | Árbemutatás | csomagár-elv, dekompozíció-tilalom, előkészítés láthatóvá tétele, beszerzési olvasat |

> **REF-09** (cost-reconstruction & hidden-cost taxonomy) külön fájlban él: `{pluginRoot}/references/cost-reconstruction.md`.
> **REF-12** (ár-motor: összemérhető-választás és levezetés) külön fájlban él: `{pluginRoot}/references/price-engine.md`.

---

## REF-01 · Sales kvalifikáció

### BANT
**Budget · Authority · Need · Timeline.** Klasszikus, gyors. 10 perc alatt el lehet dönteni érdemes-e haladni.

- **Budget:** van-e pénz, mennyi, ki kontrollálja
- **Authority:** ki dönt, ki javasolja, ki vétózza
- **Need:** mi a fájdalom, miért most
- **Timeline:** mikorra kell, mi a kényszerítő esemény

→ Mikor használd: gyors triage, korai szakasz, sok lead → szűrés.
→ Gyengéje: elavult, túl tranzakciós, nem fed le komplex deal-eket.

### MEDDIC
**Metrics · Economic Buyer · Decision Criteria · Decision Process · Identify Pain · Champion.**

- **Metrics:** milyen számokban mérik a sikert (ROI, payback, KPI)
- **Economic Buyer:** ki ír alá, ki költ
- **Decision Criteria:** mi alapján döntenek (formal vs. informal kritériumok)
- **Decision Process:** hogyan dönt a cég (lépések, gating, board jóváhagyás)
- **Identify Pain:** konkrét, mérhető fájdalom
- **Champion:** belső támogató, aki nyomja az ügyet

→ Mikor használd: enterprise / komplex B2B, hosszabb sales cycle, multi-stakeholder.
→ Gyengéje: idő- és diskurzus-igényes, kis deal-re overkill.

### MEDDPICC
MEDDIC + **Paper Process** (kontraktus / jogi / beszerzési folyamat) + **Competition** (kik versengenek).

→ Mikor használd: nagy deal, tendereztetős, jogi-gating gyakori.

---

## REF-02 · Decision dynamics

### RACI
**Responsible · Accountable · Consulted · Informed.** Ki *csinálja*, ki *felel*, kit kell *konzultálni*, kit *informálni*.

→ Használat: a cégen belül szerepkörök tisztázása egy döntéshez vagy szállításhoz.

### DACI
**Driver · Approver · Contributors · Informed.** Hasonló a RACI-hoz, de "Approver" egyedül van — egyetlen jóváhagyó. Tisztább a B2B sales-ben, mert egyértelműbb a "ki ír alá".

→ Használat: ajánlat-jóváhagyási folyamat ügyfél-oldalon.

### Decision map (4 szerep)
A klasszikus B2B vásárlási modell:

| Szerep | Mit csinál | Kérdés a sales-nek |
|---|---|---|
| **Economic Buyer** | Pénzt ad rá, aláírja | Mi a ROI-ja az ő szempontjából? |
| **Champion** | Belül nyomja az ügyet | Mit kér tőlünk hogy nyerni tudjon? |
| **User / Technical Buyer** | Használja vagy validálja | Milyen kritériumokat akar lát? |
| **Blocker** | Akadályozza (procurement, legal, IT, vetélytárs csapat) | Mi a kifogása, semlegesíthető-e? |

→ Használat: stakeholder-térkép minden komolyabb deal előtt. A `clarify` skill ebből dolgozik.

---

## REF-03 · Pricing strategies

### Cost-plus
**Költség + margin %.** Egyszerű, transzparens, könnyű kalkulálni.

→ Mikor: van pontos költség-adatod, alacsony differentiation, commodity-jellegű szolgáltatás.
→ Veszély: a versenyhez képest random árat ad, nem reflektálja az ügyfél-értéket.

### Value-based pricing
**Ár = az ügyfél által észlelt érték töredéke (jellemzően 10–30%).** Nem a költségtől, hanem a kimenettől függ.

→ Mikor: van mérhető ROI vagy megfogható üzleti érték (megtakarítás, többletbevétel, kockázatcsökkentés).
→ Veszély: elhitetni, hogy az érték valós — kvantifikálni kell. "Mindenki spórol vele 10%-ot" típusú állítás nem működik.

**Kvantifikálási minta:**
- Ügyfél bevétele/költsége × hatás % × időhorizont = érték
- Ár = érték × 10–30%

### Competitive pricing
**Ár a versenytárs ±X%-án.** Reaktív stratégia.

→ Mikor: tendereztetős környezet, kommodifikált piac, az ügyfél tudja a "piaci árat".
→ Veszély: race to the bottom; nem épít margint.

### Anchoring
**Először egy magas ár-pontot mutatunk, hogy a tényleges ajánlat olcsónak tűnjön.** Multi-tier ajánlat, vagy "rejected option" trükk.

→ Mikor: 3-szintű csomag (good/better/best), ahol a "best" tier az anchor és a "better" a target.
→ Veszély: ha túl extrém, gyanúsnak tűnik.

### Premium positioning
**Magasabb ár, mint a verseny + világos differentiation.** "We are not the cheapest, we are the best."

→ Mikor: erős márka, niche szakértelem, kockázatérzékeny ügyfél.
→ Veszély: a differentiation kommunikációja drága; gyengén pozicionált prémium = veszteség.

---

## REF-04 · Risk frameworks

### Probability × Impact
Minden kockázathoz: **valószínűség (1–5) × hatás (1–5) = score (1–25)**. Top-3 score → mitigation terv.

| Score | Kategória | Akció |
|---|---|---|
| 15–25 | Magas | Mitigálni / beárazni / scope-ból kivenni |
| 8–14 | Közepes | Mitigálni vagy contingencyt képezni (pl. +10% buffer) |
| 1–7 | Alacsony | Tudomásul venni, monitorozni |

### RAID log
**Risks · Assumptions · Issues · Decisions/Dependencies.** Élő dokumentum, projekt során folyamatosan frissítve.

→ Az ajánlatfázisban elsősorban **Risks** és **Assumptions** kell — a többi a projekt-folyamatban él.

### Contingency pricing
**Risk-szám az ár része.** Pl. ha 30% esélye van egy 1M Ft-os csúszásnak → +300k Ft contingency.

→ Két stílus:
- **Visible contingency:** nyíltan kommunikált buffer az ajánlatban (transzparens, néha kedvező).
- **Embedded contingency:** beépített, nem nevesített rezerv (egyszerűbb a kommunikáció, de etikai határ).

---

## REF-05 · Proposal structures

### AIDA
**Attention · Interest · Desire · Action.** Klasszikus marketing-keret, jól működik executive summary-ben.

- **Attention:** egy meglepő szám, idézet vagy provokáció
- **Interest:** miért most, miért nekik fáj ez
- **Desire:** a megoldás-vázlat, mi a végeredmény
- **Action:** konkrét következő lépés

### SPIN selling (kérdezési struktúra a clarify-ban)
**Situation · Problem · Implication · Need-payoff.**

- **Situation:** hol állnak most (kontextus-feltárás)
- **Problem:** mi nem működik
- **Implication:** mi a következménye, ha nem oldják meg (fájdalom-felerősítés)
- **Need-payoff:** mit jelentene, ha megoldódna (pozitív vízió)

→ Inkább interjú-keret, mint dokumentum-struktúra. A `clarify` skill ezt használja.

### Executive summary patternek
3 bevett:

1. **Problem → Solution → Outcome** (1 oldal, 3 bekezdés)
2. **3 KPI / 3 fő üzenet** (számok elöl)
3. **One-liner + 3 bullet** (ultra-tömör, board-decknek)

→ Egy executive summary nem hosszabb mint 1 A4. Ha igen, valami baj van.

---

## REF-06 · Negotiation

> **Megjegyzés:** ezt a keretet a jelenlegi gyűjteményben egyik skill sem hívja közvetlenül — a `negotiate` v2-es bővítés fogja használni. Itt marad, mert generikus és a `assemble`/`drive` is hasznosíthatja tárgyalási helyzet felismerésekor.

### BATNA — Best Alternative To a Negotiated Agreement
**Mi a legjobb opciónk, ha nincs deal?** Ezt KELL ismerni mielőtt tárgyalsz, különben kapkodva engedsz.

→ Két szinten:
- A mi BATNA-nk: van-e más deal a pipeline-ban, mi az opportunity cost
- Az ügyfél BATNA-ja: van-e versenytársuk, mit veszítenek ha nem velünk dolgoznak

### ZOPA — Zone of Possible Agreement
**A mi minimumunk és az ő maximumuk közötti zóna.** Ha nincs ZOPA, nincs deal.

```
| ←—— mi minimum | ZOPA | ő maximum ——→ |
```

→ A ZOPA megbecslése a kezdeti ajánlat előtt — ha nincs zóna, ne tegyünk ajánlatot.

### Koncessziós lépcső
**Pre-tervezett engedmény-szekvencia.** Soha ne improvizálj engedményt.

| Engedmény-pont | Mit adunk | Mit kérünk cserébe |
|---|---|---|
| 1. lépcső | -5% ár | gyorsabb fizetés (30 → 14 nap) |
| 2. lépcső | scope kiegészítés (kis modul) | hosszabb szerződés (1 → 2 év) |
| 3. lépcső | -10% ár (max) | exclusivity vagy referenciajog |

**Szabály:** minden engedménynek **viszonzata** kell legyen. "Ingyen engedmény" → az ügyfél azt tanulja, hogy nyomásra mindig adunk többet.

### Anchoring
Az **első szám az ár-tárgyalásban** torzítja az egész tárgyalási zónát. Ha mi anchor-ozunk, a saját kedvező végünkről induljunk (de ne abszurdan magasról).

→ Stratégia: első ajánlatunk **legalább a target ár 110–120%-án** legyen, hogy legyen mit engednünk.

---

## REF-07 · Win-loss analysis

> **Megjegyzés:** ezt a jelenlegi gyűjteményben egyik skill sem hívja közvetlenül — a `winloss` v2-es bővítés fogja használni.

### Post-mortem kérdéssor (8 kérdés, sorrendben)

1. **Mit gondolt rólunk először, mielőtt kommunikáltunk?** (előzetes pozíció)
2. **Mi tette ki a végső döntést?** (nyertes szempont)
3. **Mi volt a "második legjobb" — kit / mit választottak helyettünk vagy mellettünk?** (alternatíva)
4. **Hol voltunk a legerősebbek?** (megerősített differentiation)
5. **Hol voltunk a leggyengébbek?** (gap)
6. **Volt-e olyan pillanat, amikor ki voltunk vágva, és visszafordult?** (kritikus pont)
7. **Mit kéne másképp csinálnunk, ha újra ajánlanánk?** (improvement vector)
8. **Mit gondol, mások mit csinálnak nálunk jobban?** (külső benchmark)

### Attribution-modell — miért nyertünk/vesztettünk?
Minden ügynél **3 fő ok** azonosítása:

| Kategória | Példák |
|---|---|
| **Product/Solution fit** | scope match, feature gap, technical alignment |
| **Commercial** | ár, fizetési feltételek, rugalmasság |
| **Relationship/Trust** | champion erőssége, válaszidő, kommunikáció minősége |
| **Timing** | ügyfél prioritás, költségvetés-ciklus, internal politika |
| **Competitor move** | vetélytárs ár-akciója, feature launch, FUD |

→ Trend: 10+ deal után **mintázat** rajzolódik ki. Ez visszacsatolódik a `clarify` és a v2-es `price` skillbe.

---

## REF-08 · B2B benchmark defaults

> **Figyelem:** Ezek **iparági átlagok**, nem cégspecifikusak. Csak fallback-ként használjuk, ha nincs cég-saját adat. Az `init` skill az interjú után felülírja a cégspecifikus értékkel.

### Win-rate sávok (kvalifikált opportunity → close)
- **Cold lead:** 1–5%
- **Warm inbound:** 10–20%
- **Referral:** 30–50%
- **Existing customer expansion:** 40–70%

### Sales cycle hossz (B2B átlag)
- **SMB (<50 fő ügyfél):** 1–6 hét
- **Mid-market (50–500 fő):** 1–3 hónap
- **Enterprise (500+ fő):** 3–9 hónap, néha 12+

### Average deal size kategóriák (consulting / B2B service)
- **Mikro:** < 5 M Ft (≈ 12 k EUR)
- **Kicsi:** 5–25 M Ft (12–60 k EUR)
- **Közepes:** 25–100 M Ft (60–250 k EUR)
- **Nagy:** 100–500 M Ft (250 k–1.2 M EUR)
- **Enterprise:** > 500 M Ft

### Margin range-ek (gross margin, B2B service)
- **Commodity szolgáltatás:** 15–25%
- **Standard consulting:** 25–40%
- **Specialized advisory:** 40–60%
- **Niche/Premium expertise:** 60–80%
- **Pure IP / training products:** 70–90%

### Payment terms minták
- **Default:** Net 30 (számla utáni 30 nap)
- **Risk-szelíd:** 30/30/40 (start / midway / final), milestone-based
- **Avans:** 50% előre / 50% szállításkor (új ügyfélnél vagy nagy projektnél)
- **Subscription:** havi vagy negyedéves díjazás

---

## REF-13 · Árbemutatás (price presentation)

**Purpose:** a helyes ár is elbukik, ha a bemutatása visszaosztásra vagy szétszedésre csábít — ez a szabálykészlet azt rögzíti, milyen formában kerülhet ár a kliens-példányba.

**Lényeg.** A beszerzés nem az értéket olvassa, hanem az egységárat, amit ki tud számolni belőle. Négy szabály:

1. **Csomagár-elv.** A kliens-tábla olyan egységeket áraz, amiket az ügyfél ténylegesen megrendelhet. Önállóan nem rendelhető modul nem kap önálló ársort — a modulbontás és a levezetés a belső jegyzetben él. (Mért eset: egy önállóan nem rendelhető ráépülő modul külön ársora önálló megrendelésre és összeg-vitára nyitott ajtót.)
2. **Dekompozíció-tilalom.** Idő-tört (0,25 nap), óra-alap vagy bármilyen egységre visszaosztható bontás nem kerül a kliens-példányba — a beszerzés napidíjat számol vissza belőle, és a színpadi időt árazza, nem az értéket meg az előkészítést. (Mért eset: egy „60–90 perc, 0,25 nap" bontású ársor négyszeres napidíj-olvasatot termelt a beszerzésnél.)
3. **Az előkészítés láthatóvá tétele.** A díj mögötti nem-színpadi munka („amit a díj tartalmaz") mennyiséggel és tartalommal nevesítve — enélkül az ár a látható időhöz mérve túlzónak tűnik. (Mért visszajelzés, szó szerint: „az ár húzósnak tűnik… mert nem jön át, hogy beleteszel két napot előtte.")
4. **Beszerzési olvasat-teszt.** Zárás előtt a kliens ár-tábláját egy beszerző szemével olvasod: mit osztana vissza egységárra, mit rendelne meg önállóan, mit tenne össze olcsóbban? Amit vissza tud osztani, azt vissza fogja — azt a bontást vedd ki vagy tedd visszaoszthatatlanná.

**Mikor használd:** az `assemble` 5. pontjában (ár-szekció formája + zárás előtti teszt) és a `revise` minden ár-érintő körében. **Gyengéje:** formális pályáztatásnál (tételes bontást előíró kiírás) a kiírás felülírja — ilyenkor a bontás kötelező, és a védelem az egységárak konzisztenciája, nem az elrejtésük.

---

## Hozzáadás-protokoll

Új framework felvétele előtt:
1. Van-e már hasonló a könyvtárban? Ha igen, **bővítsd**, ne duplikálj.
2. Generikus-e? Cégspecifikus dolog **nem ide** való.
3. Min. 1 skill-spec hivatkozza? Ha senki, ne tegyük be — YAGNI.

Új belépő szerkezete: kód (REF-XX), 1 mondat purpose, 3-5 mondat lényeg, "mikor használd / gyengéje" pár.

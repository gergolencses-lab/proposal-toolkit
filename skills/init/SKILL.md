---
name: init
description: Use when setting up the proposal workflow for a company for the first time, when the company's pricing or house style has changed, or when another proposal skill reports that the company layer is missing. Also use when the user wants to calibrate rates, margins, or proposal formatting from past offers.
---

# init — cég-kalibráció valós ajánlatokból

> **Útvonalak.** `{pluginRoot}` = a betöltéskor kiírt `Base directory for this skill` két szinttel feljebb.

Egyszeri (vagy frissítő) kalibráció: a cég korábban ténylegesen elküldött ajánlataiból rekonstruálja a gazdasági logikát (`economics.md`) és a házi stílust (`house-style.md`). Ez a két fájl minden későbbi `clarify`/`assemble` futás alapja.

## 0. Memóriagyökér és cég

`{memoryRoot}` és a **cég azonosítója**: `{pluginRoot}/references/bootstrap.md` — kövesd onnan (a normalizálás szabálya: `{pluginRoot}/references/deal-state.md`). Az útvonalak: `{memoryRoot}/proposal/{company}/economics.md` és `.../house-style.md`.

## 1. Beolvasási szakasz

Kérj be 3–4 valós, ténylegesen elküldött ajánlatot (PDF/DOCX/MD/deck), lehetőleg nyert és vesztett vegyesen. **Nulla dokumentum → STOP.** Ne építs konfigot absztrakt interjúból — ha nincs anyag, mondd meg, mi hiányzik, és állj meg.

**Melyik példány számít.** Egy mappa tartalma nem azonos azzal, ami kiment: a `.md` gyakran munkaverzió, a HTML/PDF/PPTX a kiküldött, és van, ami ajánlatnak olvassa magát, de belső stratégiai anyag. **Belső munkaanyagból sem stílust, sem árat nem kalibrálsz, és a tartalma ügyfélnek szóló dokumentumba sose kerül.** A kiválasztás, a felismerés-jelek, a verziólánc-kezelés és az `n_offers` pontos egysége: `{pluginRoot}/references/offer-corpus.md`.

1–2 dokumentum esetén a skill lefut, de minden érték `provisional` + `confidence: LOW`, és mindkét kimenet fejlécébe bekerül az `n: 1..2` flag. Ezt az `assemble` olvassa: a belső jegyzetébe mindenképp, az ügyfélnek szóló ár-kitételnek pedig ez az egyik triggere — lásd `{pluginRoot}/references/deal-state.md` → Bizonytalanság-továbbítás.

Egyszer olvasd be a teljes szettet — mindkét kimenet (economics + house-style) ugyanabból az olvasásból készül.

## 2. `economics.md` — két motor

A séma (mezőnevek, típusok): `{pluginRoot}/references/company-schema.md` → `economics.md`.

**a) Ár-motor — ez az alapértelmezett, és nulla költség-inputból működik.** Írd ki **minden árazott tételt** a `price_history`-ba, külön sorral, úgy ahogy a dokumentumban állt: mit fedett, mennyiért, mi lett a kimenetele. Ne összesíts, ne átlagolj, és **ne képezz belőle napidíjat vagy horgonyt** — az összemérhetőséget dealenként az `assemble` dönti el (**REF-12**: `{pluginRoot}/references/price-engine.md`). A kimenetel gyakran nem áll a dokumentumban: **kérdezd meg**, és ami így sem derül ki, az `unknown` — nem `won`.

**b) Költség-motor — opcionális, és csak PADLÓT ad.** **Kérdezd meg**, van-e ismert éves működési költség és kapacitás; magától nem fog megérkezni. Ha nincs, `cost_floor.provenance: none` — teljes értékű válasz, a futás normálisan befejeződik, az árazás ettől még működik. Ha van szám, tisztázd, **mit mér**: valós működési költség (kötelezettség) vagy a tulajdonos elvárt kivéte (cél)? A kettő döntési következménye ellentétes — írd ki a `basis`-ban. Rejtett költségek és truth-guard: **REF-09** (`{pluginRoot}/references/cost-reconstruction.md`); ahol nincs cégadat, **REF-08** benchmark-seed.

**c) Külső benchmark — opcionális.** Piaci referencia forrással és dátummal a `benchmark` tömbbe. Se nem ár, se nem padló.

## 3. `house-style.md`

A `language` és a `mail_backend` nem a dokumentumokból olvasható ki — **kérdezd meg** (levelező-backend: a cég tényleges rendszere, amiben a `clarify` keresni fog). Hogy melyik mezőt ki fogyasztja és mi történik hiányuk esetén: `{pluginRoot}/references/company-config.md`.

A séma: `{pluginRoot}/references/company-schema.md` → `house-style.md`.

## 4. Képesség-próba

A `render_chain` slotjait (`primary`, `critique`, `to_docx`, `to_pdf`) tölti ki: két forrásból (lemez + futásidejű skill-lista), alkalmasság-vizsgálattal, **nulla beégetett defaulttal**. A teljes eljárás: `{pluginRoot}/references/capability-probe.md`.

## 5. Írás és lezárás

Írd ki mindkét fájlt a fenti útvonalakra. **Meglévő cég-fájl frissítésekor**: additív bővítés mehet magától; meglévő érték lecserélése — kivált egy padló- vagy engedmény-korlát csökkentése — csak kimondva, régi → új párral a zárásban. Néma felülírás nincs.

Zárásként mondd meg röviden, mi `provisional`/LOW, **mit hagytál ki a szettből és miért**, és mi hiányzik a következő futtatáshoz (pl. „még csak 2 ajánlat, 3. után frissítsd").

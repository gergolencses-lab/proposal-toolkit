---
name: assemble
description: Use when a deal has been decoded and the actual proposal document needs to be written. Also use when the user asks to put an offer together, draft the quote document, or turn deal notes into something that can be sent to a client.
---

# assemble — scope, ár, dokumentum-master

> **Útvonalak.** `{pluginRoot}` = a betöltéskor kiírt `Base directory for this skill` két szinttel feljebb.

Előfeltétel: `clarify-{dátum}.md`; ha nincs → `clarify`. Az ár-réteg `economics.md`-ből, a forma `house-style.md`-ből jön (`init` kimenetei) — hiányuk nem hibaág, lásd lent.

## 0. Memóriagyökér, cég, deal

`{memoryRoot}`, `{company}`, `{slug}`: `{pluginRoot}/references/bootstrap.md` — kövesd, mielőtt bármit írnál.

## 1. Forma és scope

Az **ajánlati formát** (hogyan gradálódik az ár) és a **dokumentumfajt** (milyen szekciókból áll) **a dealre** választod, nem a cégre. Értékkészlet, szabály, alapértelmezés (**additív moduláris**), kötelező indoklás: `{pluginRoot}/references/document-shapes.md`.

A választott forma adja a **scope-egységeket**. Egységenként: deliverable-bontás mérhető outcome-mal, **tételes out-of-scope**, effort szerepkörönként, top-3 kockázat mitigációval (REF-04, probability × impact), acceptance criteria deliverable-önként. **Puha scope-nál** (transzformáció, képzés „hatása") az acceptance **szállítási tény** — „X alkalom megtörtént, Y résztvevő végigment" —, nem hatás-ígéret.

Bemenetek — ne találj ki újakat:

- **Siker-kritériumok** (clarify-output) — a mérőszámok, amikre az acceptance criteria épül.
- **Kényszerek** (clarify-output) — belőle **külön kiemelve a költségvetési plafon** (a 4. pont bemenete), értékként megnevezve. Ha nincs benne szám: `nincs megadva`, és nyitott kérdés lesz. Plafont sose feltételezz.
- **Bizonytalanságok** (clarify-output) + a `deal.md` flag-oszlopa és a `clarify` confidence-e → `{pluginRoot}/references/deal-state.md`.

## 2. Ár

Nincs `economics.md` → **ár nélküli scope-dokumentum**; a magyarázó mondat az ügyfélnek szól (az összeg egy következő körben jön), sose a belső hiányról — normál működés, nem hiba.

Van `economics.md`: az ár a `price_history` **megnevezett korábbi tételeiből** áll elő — összemérhető-választás, pozicionálás, kötelező levezetési tábla, `null`-szabály: `{pluginRoot}/references/price-engine.md` (REF-12). **Tárolt átlagot, horgonyt vagy napidíjat sose szorozz a deal nevezőjével.** `null` ár mellett a dokumentum ár nélkül készül el, és a kérdés a futás kimenetébe kerül.

## 3. Számítási kapu (kötelező)

Az ár prezentálása **előtt**, a szabályok a `{pluginRoot}/references/gates.md`-ből: tételes = összesített, sanity check a legközelebbi összemérhetőhöz — és **minden számpárra**, nem csak az árra (létszám × arány = kapacitás, idő-összegek, bruttó/nettó). Zárás előtt a keresztellenőrzés a teljes szövegen fut. Hibánál a konkrét hibát diagnosztizáld, ne generáld újra az egészet.

## 4. Ár-kapu (kötelező)

A három feltétel, a kötelező kimenet-blokk és a nem-értékelhető feltételek kezelése: `{pluginRoot}/references/gates.md`. Bármelyik feltétel teljesülésekor a folyamat megáll — ez strukturális slot, nem tiltás: a döntés (alacsonyabb ár, scope-vágás, fázisolás, nemet mondás) a felhasználóé.

## 5. Dokumentum-master

A választott faj szekció-sorrendjében (`structures.<faj>`, hiányában `structure`), a választott forma egységneveivel, `language` nyelvén, AIDA-narratívával (REF-05), max 1 A4 exec summary. Ahol ábra kellene: `[VISUAL: <név>]` placeholder. A `house-style.md` kereskedelmi invariánsai és vizuális rendszere is ide kerül (`{pluginRoot}/references/company-config.md`).

**Bizonytalanság** (1. pont) → `{pluginRoot}/references/deal-state.md`: belső jegyzet minden futásban (futás-kimenet + master vége), ügyfél-kitétel csak az ott nevezett triggerekre, az ott tiltott tartalom nélkül.

**Nincs `house-style.md`** → nem hibaág: a `{pluginRoot}/references/company-config.md` fallback-táblája szerint dolgozz; ez a belső jegyzetbe kerül, az ügyfél példányába nem.

**Az ár-szekció formája** REF-13 szerint (`{pluginRoot}/references/frameworks.md`): csomagár, idő-tört nélkül, az előkészítés nevesítve.

**Zárás előtt:** a `clarify` Döntési térképének mind a négy szerepe megtalálja-e a magáét a dokumentumban — aki vakon marad, oda mondat kell. És az ár-tábla átmegy-e a REF-13 beszerzési olvasatán.

## 6. Render

`render_chain` szerint (`primary` → `critique` → `to_docx` → `to_pdf`). A lánc **kizárólag az ügyfélnek szóló részt** viszi: a belső jegyzet sose renderelődik. Bármelyik slot `none` vagy hiányzik → markdown master marad, egy mondattal a továbbvitelről.

**A szerkeszthető artefakt az igazság vége.** Docx-ben szerkesztő cégnél a lánc vége a docx, **a PDF belőle készül, nem mellette** — két párhuzamos végartefakt széttart (round-trip: `{pluginRoot}/references/deal-state.md`).

**Render-QA a kész kimeneten**, a `{pluginRoot}/references/gates.md` szerint: oldalkép, CEE-karakterek, számok — az ügyfél-artefakt saját renderelőjében mérve.

## 7. Kiküldés-kapu

Ez a skill fájlt ír. Nem küld emailt, nem posztol, nem oszt meg — a kiküldés a felhasználó lépése; a belső jegyzet küldés előtt kikerül.

## 8. Írás és `deal.md` zárás

Írd: `{memoryRoot}/deals/{slug}/proposal-master-{dátum}.md`. Zárásként a `deal.md`-t a `{pluginRoot}/references/deal-state.md` szerint frissítsd: `assemble` sor dátummal — és flaggel, ha az ár-kapu aktiválódott vagy ügyfél-kitétel került a dokumentumba —, `status: solutioning`, „Következő lépés” felülírása.

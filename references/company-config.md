# Cég-réteg — mezők fogyasztása és fallbackek

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

A cég-réteg két fájlból áll (`{memoryRoot}/proposal/{company}/`), mindkettőt az `init` írja:

- `economics.md` — az árazási logika
- `house-style.md` — forma, nyelv, backendek, render-lánc

A **mezőlista forrása a séma** (`{pluginRoot}/references/company-schema.md`) — ez a fájl nem másolja, hanem azt írja le, hogyan fogyasztja a `clarify` és az `assemble` ezeket a mezőket, és mi történik, ha a fájl vagy a mező hiányzik. Hiány esetén egyik ág sem hiba: normál degradálás, jelzéssel.

## Nyelv — `language`

A `house-style.md` `language` mezője dönti el a **kimenetek nyelvét**: a `clarify` output prózájáét és az `assemble` proposal-masteréét. `hu` → magyar, `en` → angol, `hu-en` → a mező megjegyzése szerinti vegyes használat (jellemzően magyar törzs, angol exec summary és deliverable-nevek).

Ami **nem** fordul, nyelvtől függetlenül:

- a `clarify` kilenc kötött szekciócíme — az `assemble` név szerint olvassa a „Siker-kritériumok" és „Kényszerek" szekciót, tehát ezek gépi kontraktusok;
- a `deal.md` séma-mezői és a `status` értékei;
- az `assemble` „Ár-kapu — jóváhagyás szükséges" blokkjának mezőnevei;
- az `assemble` belső jegyzete — az üzemeltetőnek szól, nem az ügyfélnek (`{pluginRoot}/references/deal-state.md`).

Az ügyfélnek szóló próza mindenhol a `language` szerint megy. A skillek törzsének nyelve ettől független.

**Fallback**, ha nincs `house-style.md` vagy nincs benne `language`: a forrásanyagok (RFP, levelezés, átadott dokumentumok) nyelve. Ha az sem egyértelmű, kérdezz — ne válassz csendben.

**`keep_untranslated`** — ha a mező ki van töltve, az ott felsorolt terminusköröket sem a `clarify` prózája, sem a proposal-master **nem fordítja le**, hanem az eredeti alakjukban viszi. A `language_note` nem gépi mező: az üzemeltetőnek és a következő `init` futásnak szól. **Fallback**, ha hiányzik: nincs védett terminuskör, a `language` szerint fordítasz — de ha a forrásanyag következetesen fordítatlanul használ egy szakszókört, azt hagyd úgy, és vidd be a belső jegyzetbe, hogy az `init` rögzítse.

## Levelező-backend — `mail_backend`

A `clarify` levelezés-sávja ezt a mezőt használja: a **cég konfigurált levelező-backendje** (pl. `exchange`, `gmail`, `imap`, `none`), és mellette opcionálisan a keresés hatóköre (melyik postafiók, mely domainek). Konkrét backend egyetlen SKILL.md-be sem égethető be — cégenként más, és a partnercég beállítása nem a szerzőé.

**Fallback**, ha a mező vagy a fájl hiányzik: kérdezd meg egyszer, melyik backendben keressen a skill, és javasold, hogy az `init` írja be tartósan. Ha nincs elérhető backend, vagy a keresés nem fut le, a sáv flagje `mail: unavailable` — a `clarify` többi sávja ettől még fut.

## Hiányzó `house-style.md` — az `assemble` fallbackjei

Ilyenkor a dokumentum generikus formát kap. Hogy nincs bekalibrált házi stílus, az a **belső jegyzetbe** kerül (`{pluginRoot}/references/deal-state.md` → Bizonytalanság-továbbítás), az ügyfél példányába nem — az `init` oldja meg.

| Mező | Fallback |
|---|---|
| `offer_shapes` | `module_additive` — a választási szabály és a többi forma: `{pluginRoot}/references/document-shapes.md` |
| `structures` / `default_structure` | nincs fajonkénti váz → a `structure` az egyetlen |
| `structure` | exec summary (max 1 A4) → helyzet és fájdalom → megközelítés → a scope-egységek → ütemezés → ár → feltételek és out-of-scope → következő lépés |
| `tier_naming` | üres → a `variant_comparative` forma nem választható magától; ha a deal mégis ezt kívánja, kérdezd meg a neveket. Ha a formát a felhasználó rendeli el és nevet nem ad: minimum / target / ambiciózus, és ez a belső jegyzetbe kerül mint nem a cég szóhasználata |
| `language` | lásd fent |
| `tone` | semleges, tényközlő üzleti hangnem; se marketing-lelkesedés, se jogi szárazság |
| `tc_path` | nincs csatolható feltétel-anyag → a szerződéses feltételek helyére `[TODO: szerződéses feltételek]` placeholder |
| `render_chain` | mind a négy slot `none` → a kimenet markdown master marad |

## Kereskedelmi invariánsok — `commercial_invariants`

Ezek a mezők **a dokumentumba kerülnek**, nem az árszámításba. Az `assemble` a dokumentum-mesterben
helyezi el őket; a szekció-sorrend a `structure`/`structures` dolga, ez a tábla azt mondja meg,
mi kerül a szekciókba és mi történik, ha a mező hiányzik.

| Mező | Hova kerül a dokumentumban | Fallback, ha hiányzik |
|---|---|---|
| `validity` | az ár mellé vagy a záró feltételek közé, konkrét dátumként (nem „30 nap") | `[TODO: érvényességi idő]` placeholder + belső jegyzet — érvényesség nélkül nem megy ki ajánlat |
| `inclusions` / `exclusions` | a scope-határ szekcióba, **párban** | a scope-ból amúgy is kötelező **tételes out-of-scope** marad, `inclusions` nélkül; a hiány a belső jegyzetbe |
| `payment_terms` | a feltételek szekcióba | `[TODO: fizetési feltétel]` placeholder |
| `cancellation` | a feltételek szekcióba | kimarad, és a belső jegyzetbe kerül, hogy nincs lemondási védelem |
| `reference_scheme` | a fejlécbe, a séma szerint generált azonosítóként | nincs azonosító; ne találj ki sémát |
| `currency_rule` | eldönti, **milyen devizában** áll az ár és milyen átváltási kikötéssel | az `economics.md` `currency`-je, átváltási kikötés nélkül |
| `identity_block` | a mező által megnevezett helyre, változatlan tartalommal | kimarad; adatot **soha ne találj ki** (adószám, bankszámla) |
| `signature_block` | ahol a mező előírja | kimarad |
| `discount_policy` | ha az ajánlat engedményt tartalmaz: az engedmény **megnevezve és megindokolva** | akkor is nevezd meg és indokold — néma engedmény sose megy ki |
| `visual_identity` | a `render_chain` bemenete: a renderelő ezt valósítja meg, nem a saját alapértelmezését | a renderelő alapértelmezése, és a belső jegyzetbe, hogy nincs bekalibrált vizuális rendszer |

Egyik hiány sem hibaág, és **egyik sem kerül az ügyfél példányába magyarázatként**: a placeholder
azt jelzi az üzemeltetőnek, hogy kitöltendő a kiküldés előtt (`{pluginRoot}/references/deal-state.md`
→ tartalmi tilalom).

## Az ár-réteg — `price_history`, `cost_floor`, `benchmark`

Az `assemble` az árat **kizárólag** a `price_history` tételeiből vezeti le
(`{pluginRoot}/references/price-engine.md`). A másik két mező nem árazási bemenet.

| Mező | Mit csinál az `assemble` | Fallback, ha hiányzik |
|---|---|---|
| `price_history` | ebből választja az összemérhetőket, és ehhez pozicionálja a dealt | **nincs ár**: ár nélküli scope-dokumentum, ugyanúgy, mintha nem lenne `economics.md` |
| `price_history` van, de <2 összemérhető | az ár `null` | nem hibaág: a dokumentum ár nélkül készül el, a kérdés a futás kimenetébe és a belső jegyzetbe kerül |
| `cost_floor.value` | az ár-kapu 3. feltétele | `provenance: none` → a 3. feltétel nem értékelhető; a kapu az 1-2. feltételből még megszólal |
| `benchmark` | kontextus a levezetéshez és a belső jegyzethez | kimarad; külső számból árat vezetni tilos |
| `margin.strategic_discount_cap` | az engedmény felső korlátja, ha az ajánlat engedményt tartalmaz | nincs korlát-precedens → engedményt csak megnevezve és indokolva adj (`discount_policy`) |

**Egyik `won` tétel sincs** (mind `unknown`/`open`): az árazás fut, de az ár-kapu 2. feltétele nem
értékelhető, és a belső jegyzetbe kerül, hogy a korpusz nem tartalmaz megerősített árat.

## Szolgáltatásvonalak — `service_lines`

A vonal **címke és kontextus, nem árazási szint** — árat nem tárol
(`{pluginRoot}/references/company-schema.md` → 6. pont). Az `assemble` azonosítja a dealhez tartozó
vonalat, de az összemérhetőket a `what` szerinti hasonlóság dönti el, nem a vonalcímke: egy másik
vonal tétele is lehet összemérhető, ha tényleg hasonlít.

**Fallback**, ha nincs `service_lines`, vagy a deal egyik vonalhoz sem rendelhető: a teljes
`price_history` a merítés, a vonalcímke `nincs`. Ha a hozzárendelés kétes, ne találgass — a kétséget
és a választott vonalat (vagy annak hiányát) a **belső jegyzet** viszi.

Hiányzó `economics.md`: ár nélküli scope-dokumentum — lásd az `assemble` 2. pontját.

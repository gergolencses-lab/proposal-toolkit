# Ajánlati forma és dokumentumfaj — a cég kínálata, a deal választása

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

Két különböző dolgot kell eldönteni minden ajánlatnál, és a kettő **független egymástól**:

| Tengely | Kérdés | Cég-réteg mező | Ki választ |
|---|---|---|---|
| **Ajánlati forma** | hogyan gradálódik az ár a dokumentumon belül | `offer_shapes` (+ `tier_naming`) | az `assemble`, dealenként |
| **Dokumentumfaj** | milyen szekciókból áll maga a dokumentum | `structures` (+ `structure`) | az `assemble`, dealenként |

**A cég-réteg azt rögzíti, mit tud a cég előállítani. A választás a dealé.** Egyik forma és egyik
faj sem beégetett alapértelmezés a skillben — de ha a cég-réteg nem mond semmit, az alapértelmezett
forma az **additív moduláris**, mert ez a leggyakoribb valós mintázat, és mert nem hazudik
összehasonlítható alternatívákat oda, ahol nincsenek.

---

## 1. Ajánlati formák

| Érték | Mit jelent | Mikor ez a helyes |
|---|---|---|
| `module_additive` | Modulok, amelyek **összeadódnak** a teljes megoldássá (M1 + M2 + M3 = program), mindegyik külön árazva, mellettük opcionális modulok. **Alapértelmezés.** | a scope önállóan is megvehető, egymásra épülő blokkokra bomlik |
| `service_levels` | Ugyanannak a szolgáltatásnak n **nevesített szintje** (jellemzően 2), támogatás/SLA/hatókör szerint | folyamatos szolgáltatás vagy licensz, ahol a különbség a szint, nem a tartalom |
| `variant_comparative` | n **alternatíva egymás mellett**, a `tier_naming` neveivel. Az ügyfél egyet választ. | a vevő kifejezetten összehasonlítható változatokat kért, **és** a cégnek van rá szóhasználata |
| `single_item` | Egy tétel, egy ár, opciók nélkül | egyetlen, tovább nem bontható szállítás |
| `separate_document` | Az olcsóbb/szűkített változat **külön dokumentumként** megy ki, nem oszlopként | a cég így ad alternatívát: nem három hasábbal, hanem új ajánlattal |

`tier_naming` **csak a `variant_comparative` formához tartozik**: a változatok neve a cég saját
szóhasználatával. Üres lista (`[]`) érvényes és gyakori érték — azt jelenti, hogy a cégnél
**nincs megfigyelt változat-elnevezés**, nem azt, hogy az `init` nem töltötte ki. Üres
`tier_naming` mellett a `variant_comparative` forma **nem választható magától**: ha a deal mégis
ezt kívánná, a neveket meg kell kérdezni, és a hiányt a belső jegyzet viszi.

### A forma választásának szabálya — fentről lefelé, az első illeszkedő nyer

1. A vevő **kifejezetten összehasonlítható változatokat kért** (a `clarify` „Döntési folyamat" vagy
   „Kényszerek" szekciója szerint), a cég `offer_shapes`-e tartalmazza a `variant_comparative`-ot,
   **és** a `tier_naming` nem üres → `variant_comparative`.
2. A dealhez tartozó szolgáltatásvonalnak vannak nevesített szolgáltatási szintjei, és a vevő
   ezek között választ → `service_levels`.
3. A scope önállóan is megvehető, összeadódó blokkokra bomlik → **`module_additive`**.
4. Egyetlen, tovább nem bontható szállítás → `single_item`.
5. Ha az ügyfélnek olcsóbb változat is kell (jellemzően az **ár-kapu** után hozott felhasználói
   döntés nyomán), és a cég `offer_shapes`-e tartalmazza a `separate_document`-et → a szűkített
   változat **külön dokumentum**, saját fájlnéven, nem egy második oszlop. Ilyenkor két ajánlat megy
   ki, és az `offer-corpus.md` szerint később kettőnek is számít.

Ha a `offer_shapes` hiányzik vagy üres → `module_additive`, és a belső jegyzetbe kerül, hogy a
forma nincs bekalibrálva.

---

## 2. Dokumentumfajok

A faj a dokumentum **vázát** dönti el, és a valóságban nem a cég ízlése választja, hanem a
**vevő beszerzési útja**. Ugyanaz a cég ugyanazon a napon két teljesen más vázú ajánlatot ad ki,
ha két különböző úton érkezett a kérés.

| Kulcs | Kiváltó ok | Jellegzetes jegyek |
|---|---|---|
| `procurement_tender` | a vevőnek beszerzési funkciója van, és a **saját általános feltételeivel** pályáztat | kétoldali adatblokk, ajánlattételi kötöttség, a vevő feltételeinek elfogadása, cégszerű aláírás; gyakran **nincs** deliverable-lista és **nincs** scope-határ szekció |
| `program` | szakmai vagy üzleti szponzor vásárol, beszerzési út nélkül | kontextus („miért most"), modul-bontás ütemtáblával, deliverables, scope-határ („mit NEM tartalmaz"), következő lépés |
| `enterprise_terms` | ipari/nagyvállalati vevő **szállítói feltételrendszerrel**, folyamatos kötelezettséggel (licensz, SLA, IP, átadás-átvétel) | §-számozott szakaszok, kétoldali kötelezettség-táblák, IP, felelősség-korlátozás, change management, SLA, felmondás, aláírás-rács — a terjedelem nagyobb része jogi és üzemeltetési |
| `letter` | partneri / alapítói viszony, beszerzés egyáltalán nincs | megszólítás, indoklás prózában, szintek szövegben, ellenszolgáltatás, konkrét időpont-javaslat, keresztnév-aláírás; **nincs** cégadat-blokk, érvényesség, ártáblázat |

A lista **nyitott**: a `structures` kulcsai a cégnél ténylegesen megfigyelt fajok. Ha a cégnek van
olyan váza, ami egyikbe sem passzol, saját kulcsot kap, és ide is bekerülhet a következő
`init` futáskor.

### A faj választásának szabálya — fentről lefelé, az első illeszkedő nyer

Bemenet: a `clarify` **„Döntési folyamat"** szekciója (beszerzési út), másodsorban a
„Döntési térkép" (ki a tényleges vevő).

1. A vevő formális pályáztatással vagy saját beszerzési általános feltételeivel szerez be, illetve
   beszerzési funkció vezeti az ügyet → `procurement_tender`.
2. A vevő szállítói feltételrendszere irányadó, **és** a deal folyamatos kötelezettséget hordoz
   (licensz, SLA, IP, átadás-átvétel, hosszú távú üzemeltetés) → `enterprise_terms`.
3. A viszony partneri/alapítói, beszerzési út egyáltalán nincs, és a dokumentum személyes levélként
   működik → `letter`.
4. Egyébként → `default_structure`, ennek hiányában a `structures` legtöbbször megfigyelt kulcsa,
   ennek hiányában a `structure` lista.

**Ha a „Döntési folyamat" nem mondja meg a beszerzési utat: ne találgass.** Az alapértelmezett
fajjal dolgozz, a hiányzó tényt írd a belső jegyzetbe, és vidd be a `deal.md` „Nyitott kérdések"
közé — a következő `clarify` ezt fogja megkérdezni. Ez **nem** ügyfélnek szóló kitétel: a
kitétel-triggerek zárt listája a `{pluginRoot}/references/deal-state.md`-ben áll, és ez nincs köztük.

Ha a `structures` hiányzik → a `structure` az egyetlen váz; ha az is hiányzik → a
`{pluginRoot}/references/company-config.md` fallback-sora. Mindkét eset a belső jegyzetbe kerül.

---

## 3. Kötelező indoklás

Az `assemble` **mindkét választást megindokolja** a belső jegyzetben, a
`{pluginRoot}/references/deal-state.md` A) blokkjának két erre való sorában. Az indoklás egy
mondat, és **konkrét tényre hivatkozik** a clarify-outputból vagy a cég-rétegből — nem
„ez tűnt a legjobbnak".

Ez üzemeltetői információ: az ügyfél példányába nem kerül át, a `render_chain` nem viszi.

---

## 4. Két végigvezetett példa

### Példa A — additív moduláris, `program` váz

**A deal.** Egy gyártó cég HR-vezetője 35 vezetőnek kér AI-alapozó képzést. A `clarify`
„Döntési folyamat" szekciója: a HR-vezető dönt az üzletági vezetővel, a keret már allokált,
beszerzési eljárás nincs, pályáztatás nincs. A „Kényszerek" nem kér összehasonlítható változatokat.

**A cég-réteg.** `offer_shapes: [module_additive, service_levels, separate_document]` ·
`structures:` `program`, `procurement_tender`, `enterprise_terms`, `letter` ·
`default_structure: program` · `tier_naming: []`.

**Faj.** 1. szabály nem áll (nincs pályáztatás, nincs beszerzési feltételrendszer). 2. nem áll
(nincs folyamatos kötelezettség). 3. nem áll (nem partneri levélviszony). → 4. szabály:
`default_structure` = **`program`**.

**Forma.** 1. szabály nem áll (a vevő nem kért változatokat, és a `tier_naming` amúgy is üres).
2. nem áll (a képzési vonalon nincsenek nevesített szolgáltatási szintek). 3. **áll**: a scope
három, önállóan is megvehető, egymásra épülő modulra bomlik → **`module_additive`**.

**Ami ebből következik a dokumentumban.** Modulonként külön ár + `ÖSSZESEN` sor, mellette
opcionális modul külön áron; **nincs** három hasáb, és nincs „minimum / target / ambiciózus".
Scope-egység = modul, tehát a deliverable-bontás, a tételes out-of-scope, az effort és az
acceptance criteria **modulonként** áll elő.

**Belső jegyzet.**
`Választott dokumentumfaj: program — a clarify „Döntési folyamat" szerint HR-szponzor dönt, beszerzési út és pályáztatás nincs.`
`Választott ajánlati forma: module_additive — a scope 3 önállóan megvehető, összeadódó modulra bomlik; a vevő nem kért összehasonlítható változatokat, és a tier_naming üres.`

### Példa B — egytételes, `procurement_tender` váz, és a szűkített változat sorsa

**A deal.** Egy bank stratégiai beszerzése kér ajánlatot egy vezetői konferencia nyitóelőadására,
**a bank saját pályázati általános feltételei szerint**, megadott ajánlattételi kötöttséggel.
A `clarify` „Döntési folyamat": beszerzés vezeti, a szakmai szponzor véleményez.

**Faj.** 1. szabály **áll** (beszerzési funkció + saját általános feltételek) →
**`procurement_tender`**. Ennél a cégnél ez a váz nem tartalmaz deliverable-listát és
scope-határ szekciót, viszont tartalmaz ajánlattételi kötöttséget, a vevő általános feltételeinek
elfogadását és cégszerű aláírást. **A hiányzó scope-határ szekció itt nem hiba** — a scope-egység
tételes out-of-scope-ja a belső jegyzetben és a scope-munkában akkor is elkészül, csak a
dokumentumnak ez a faja nem viszi ki.

**Forma.** 1–3. szabály nem áll (egyetlen előadás, nincs mit összeadni). → 4. szabály:
**`single_item`**.

**Ha az ügyfél olcsóbbat kér.** Ez a cég `offer_shapes`-e tartalmazza a `separate_document`-et,
tehát a szűkített változat **külön ajánlatfájlként** megy ki, saját referenciaszámmal és saját
érvényességgel — nem második oszlopként az eredeti mellé. Az eredeti ajánlat változatlan marad.

**Belső jegyzet.**
`Választott dokumentumfaj: procurement_tender — a clarify „Döntési folyamat" szerint a bank stratégiai beszerzése vezeti az ügyet a saját pályázati általános feltételeivel.`
`Választott ajánlati forma: single_item — egyetlen előadás, tovább nem bontható; a szűkített változat a cég offer_shapes-e szerint külön dokumentum lenne.`

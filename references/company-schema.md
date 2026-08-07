# Cég-réteg — a két kimeneti fájl sémája

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

Ez a fájl a **mezőlista forrása**: az `init` ezt a két sémát írja ki
`{memoryRoot}/proposal/{company}/economics.md` és `.../house-style.md` néven.

- **Mit ír bele az `init`** → itt.
- **Ki fogyasztja a mezőt, és mi történik, ha hiányzik** → `{pluginRoot}/references/company-config.md`.
- **Melyik dokumentum számít bemenetnek, és hogyan számolunk** → `{pluginRoot}/references/offer-corpus.md`.
- **Hogyan lesz ebből ár** (összemérhetők, levezetés, a `null` szabálya) → REF-12:
  `{pluginRoot}/references/price-engine.md`. **Ez az árazás forrása** — a `price_history` az egyetlen bemenete.
- **A költség-oldal rekonstrukciója** (rejtett költségek, truth-guard) → REF-09:
  `{pluginRoot}/references/cost-reconstruction.md`. Ez **padlót** ad, árat nem.

**A mezőnevek kötöttek, az értékek nem.** Cégspecifikus érték soha nem kerül sem ebbe a fájlba,
sem egy SKILL.md-be — az értékek a bekalibrált cég-fájlokban élnek.

---

## `economics.md`

```yaml
company: <id>
n_offers: <db>                     # egység: offer-corpus.md §5
n_versions: <db vagy elhagyható>   # ha volt verziólánc a szettben
confidence: HIGH | MED | LOW       # a fájl egészére
confidence_detail:                 # opcionális, de többvonalas cégnél gyakorlatilag kötelező:
  price_history:  HIGH|MED|LOW     # egyetlen betű nem viszi el a három különböző erősségű réteget
  cost_floor:     HIGH|MED|LOW|NONE
  hidden_costs:   HIGH|MED|LOW

currency: <ISO kód>                # az elsődleges elszámolási deviza — NEM beégetett érték
currency_secondary: <ISO kód vagy nincs>
fx:                                # KÖTELEZŐ, ha van currency_secondary
  rate: <érték>
  as_of: <ISO dátum>
  provenance: document | stated | published-rate
  note: <egy mondat: honnan jött, és mire NEM használható>

policy: emerging | converging | settled   # REF-09 default: emerging
timestamp: <ISO dátum>

price_history:                     # ⚑ AZ ÁR-MOTOR EGYETLEN BEMENETE — REF-12
  - client: <ügyfél>               # tételenként EGY sor; se összesítés, se átlag, se horgony
    date: <ISO dátum>
    line: <service_lines kulcs vagy `nincs`>
    what: <egy mondat: mit fedett — terjedelem, létszám, napszám, szerep, ami az árat magyarázza>
    price: <ahogy a dokumentumban állt>
    currency: <ISO kód>
    outcome: won | lost | open | unknown          # `unknown` teljes értékű — lásd REF-12 §1d
    note: <ha van: megnevezett engedmény és indoka, vagy miért nem összemérhető>

cost_floor:                        # OPCIONÁLIS — PADLÓT ad, árat SOHA
  value: <érték/egység, sáv is lehet, vagy `nincs`>
  basis: <mi van benne, mi nincs, és melyik nevezővel>
  provenance: stated | reconstructed | none      # `none` = nincs padló; megállapítás, nem hiány
  note: <mit nem fed; ha a nevező vitatott, itt mondd ki — ne simítsd el>

benchmark:                         # OPCIONÁLIS — külső referencia; se nem ár, se nem padló
  - what: <mire vonatkozik>
    value: <érték/egység>
    source: <honnan, dátummal>
    note: <miért nem közvetlenül összemérhető a saját tételeiddel>

margin:                            # OPCIONÁLIS — csak akkor értelmes, ha van `cost_floor` érték
  observed: <% vagy sáv vagy `nem meghatározható`>   # megfigyelés, nem cél
  strategic_discount_cap: <%>      # a megfigyelt, ÍRÁSBAN INDOKOLT legnagyobb engedmény — lásd 4. pont

service_lines:                     # opcionális; több szolgáltatásvonalnál KÖTELEZŐ
  <vonal-id>:                      # a vonal CÍMKE és kontextus — árat nem tárol
    label: <mit fed>
    currency: <ISO kód, ha eltér az elsődlegestől>
    confidence: HIGH | MED | LOW
    policy: emerging | converging | settled
    note: <ami csak erre a vonalra igaz — pl. mi horgonyozza az árat ezen a vonalon>

hidden_costs:                      # REF-09 taxonómia
  - name: <tétel>
    observed_in: <hány ajánlatban látszik a NYOMA>
    tax: <% vagy sáv vagy `unknown`>       # `unknown` teljes értékű válasz — lásd 5. pont
    confidence: HIGH | MED | LOW
    fills_it: <KÖTELEZŐ, ha tax: unknown — melyik EGY mérés töltené ki>

provenance: <miből jött: dokumentum / interjú / benchmark-seed>
```

### 1. `price_history` — a tételek, nem az átlaguk

Ez a mező **az ár-motor egyetlen bemenete**; a levezetés szabályai:
`{pluginRoot}/references/price-engine.md` (REF-12).

Az `init` dolga itt: **minden árazott tételt kiírni külön sorral**, úgy, ahogy a dokumentumban állt.
Nem összesít, nem átlagol, nem képez belőle horgonyt vagy napidíjat. Ha egy dokumentum több árazott
egységet tartalmaz (modulok, változatok, opciók), az **több sor** — az összemérhetőséget az `assemble`
dönti el dealenként, nem az `init` előre.

- **`what`** a legfontosabb mező: ez alapján dől el, mi hasonlít mire. Terjedelem, létszám, napszám,
  szerep, on-site vagy távoli, ki szállította. Egy „AI tréning" nem elég; „1,5 napos hibrid csomag,
  1 csoport, 12 fő, on-site" igen.
- **`price`** az az érték, ami a dokumentumban állt, a saját devizájában. Ne váltsd át, ne normalizáld
  napra vagy főre: a származtatott egységek elvesztik azt, ami az árat magyarázta.
- **`outcome`** — az `unknown` teljes értékű válasz, és korai fázisban ez a többség. Ne írj `won`-t
  oda, ahol csak valószínű. Ha a kimenetel sehol nincs rögzítve, az `unknown`, és a lezárásban
  mondd meg, hogy ez a legolcsóbban pótolható hiányzó adat.
- **Verziólánc.** Ha egy dealre több ajánlatverzió készült, a `price_history`-ba a **ténylegesen
  kiküldött végleges** kerül. A korábbi verziók ára nem külön tétel — ha az elmozdulás önmagában
  tanulságos (leírt floor elesett, horgony összeomlott), az a `note`-ba megy, nem új sorba.

### 2. `cost_floor` — a költség padlót ad, árat soha

A költség itt **nem árazási bemenet**, hanem alsó korlát. Ezért nincs szükség a két számítási út
egyeztetésére: egy sáv, a benne lévő tételek megnevezésével, elég.

Amit ki kell mondani a `basis`-ban: **mit mér a nevező** (csak a szállítási napot, vagy minden bevételt
hozó napot — a kettő közt tipikusan 20–30% a különbség), és mi van a számlálóban. Külön figyelj arra,
hogy a **tulajdonos elvárt kivéte nem működési költség**: az előbbi cél, az utóbbi kötelezettség, és a
kettő döntési következménye ellentétes. Ha a megadott szám valójában kivét-cél, írd ki a `note`-ban,
és a `provenance` maradjon annak, ami: `stated`.

`provenance: none` **teljes értékű állapot** — ilyenkor nincs padló, az ár-kapu a másik két feltételére
támaszkodik (`{pluginRoot}/references/price-engine.md` és az `assemble` ár-kapuja). Ne tölts ide
valószínűnek tűnő számot azért, hogy a mező ki legyen töltve.

### 3. Deviza és FX

`currency` **nem beégetett érték** — a megfigyelt ajánlatokból jön. Ha egy szolgáltatásvonal
más devizában árazódik, az `currency_secondary` (és a vonalnál `service_lines.<id>.currency`).

Az `fx` blokk kötelező, ha van másodlagos deviza. **Provenance-szabály:**

- `document` — az árfolyam egy korábbi ajánlatból származik. Ez a leggyakoribb eset. Az ilyen
  árfolyam **múltbeli tény, nem aktuális ráta**: az `as_of` dátummal együtt kell megjelennie, és
  a `note`-nak ki kell mondania, hogy nem ellenőrzött aktuális jegyzés.
- `published-rate` — jegyzett árfolyam. **Csak akkor**, ha ténylegesen ki is kerested; ellenőrizetlen
  árfolyamot sose állíts jegyzettként (ez a tényellenőrzési kapu, nem stílus kérdése).
- `stated` — a felhasználó adta meg.

Belső összehasonlításra (margin, sávok) minden konverzió mehet a rögzített rátán. **Ügyfélnek szóló
dokumentumba az `fx.rate` mint aktuális árfolyam soha nem kerülhet** — ott a `house-style.md`
`currency_rule`-ja dönt (jellemzően: melyik deviza melyik vonalon, és milyen átváltási kikötéssel).

### 4. `strategic_discount_cap` — levezetés és ütközés-ellenőrzés

**Levezetés.** A cap nem vágyérték és nem benchmark: a korpuszban **ténylegesen megadott, írásban
megindokolt** legnagyobb engedmény. Ami indoklás nélkül ment ki, az nem precedens. Ami egyszeri
horgony-összeomlás volt (nagy esés dokumentált scope-csökkentés nélkül), az **nem cap** — az a
megfigyelés, hogy a floor nem tartott, és így is kell leírni.

**Ütközés-ellenőrzés (kötelező, ha van `cost_floor` érték).** Számold ki, hova esik az ár a cap
melletti legnagyobb engedménnyel, és vesd össze a `cost_floor`-ral:

- ha a cap melletti ár **a padló felett** marad → nincs teendő;
- ha **a padlónál vagy alatta** → írd ki a `note`-ban, hogy a cap ilyenkor **plafon, nem
  kiindulópont**, és sorold fel, mi nem fér mellé (további erőforrás, külső helyszín, megnyújtott
  utánkövetés) — mert az viszi át a padló alá.

Az ütközés nem hiba a fájlban: ez a futás egyik legértékesebb kimenete. Elhallgatni viszont az.
`cost_floor.provenance: none` mellett az ellenőrzés nem futtatható — ezt írd ki, ne hagyd üresen.

### 5. `hidden_costs[].tax` — az `unknown` teljes értékű válasz

REF-09 maga mondja, hogy ezek a tételek **soha nincsenek benne a dokumentumban** — az `init`
egyetlen bemenete viszont a dokumentum. Ezért:

- `tax: unknown` **elvárt és helyes** ott, ahol nincs mérés. Nem hiányos kitöltés.
- **Tilos** valószínűnek tűnő százalékot beírni, hogy a mező „ki legyen töltve" — ez pontosan az a
  szám-kitalálás, amit REF-09 truth-guardja tilt.
- Ha `tax: unknown`, a `fills_it` **kötelező**: az az egy mérés, ami kitöltené (pl. „km/óra-napló
  engagementenként", „számla-dátum vs. beérkezés egy lezárt évre").
- Az `observed_in` akkor is kitölthető, ha a `tax` `unknown` — a **nyom** látszik a dokumentumból
  (pl. fizetési határidő mindenhol ott van), a **költség** nem.

### 6. Szolgáltatásvonalak — címke, nem árazási szint

Ha a cég ajánlatai **érdemben eltérő gazdaságú** vonalakra esnek (más árazási egység, más deviza,
más kockázat, más horgony), a `service_lines` kötelező — de a vonal **nem tárol árat**. Az ár
minden vonalon ugyanúgy a `price_history` tételeiből jön (REF-12); a vonal azt mondja meg, *mit
kell tudni* arról a szegmensről: mi horgonyozza ott az árat, milyen devizában megy, mennyire szilárd.

**Amit az `assemble` a vonallal csinál:** a `line` mező **szűkítési segédlet**, nem szűrő. Az
összemérhetőket a `what` szerinti hasonlóság dönti el; ha egy másik vonal tétele valóban jobban
hasonlít erre a dealre, az **összemérhető**, és a levezetésben ezt írd is ki. Vonalcímke alapján
kizárni egy egyébként hasonló tételt nem érvényes kizárás.

Ha a deal egyik vonalhoz sem rendelhető, az nem hibaág: a `price_history` egésze a merítés, a
vonalcímke pedig `nincs`. A választott vonal (vagy annak hiánya) a **belső jegyzetbe** kerül.

Egy vonalra a margin gyakran **nem meghatározható** (nincs dokumentált ráfordítás). Az `margin.observed:
nem meghatározható` + `note` — nem 0 és nem becslés. Ez nem akadálya az árazásnak: a margin
megfigyelés, nem bemenet.

---

## `house-style.md`

A csomagolás és a tier-elnevezés mögött **REF-03** (pricing strategies — pl. anchoring
több változat esetén) áll **támpontként, nem szabályként**: a mezőnevek kötöttek, az értékek a
megfigyelt cégből jönnek. Ha a cég nem használ egy mintázatot, azt nem írjuk bele, mert a
framework szerint úgy „szokás".

```yaml
company: <id>
n_offers: <db>                     # ugyanaz a szett, mint az economics.md-nél
confidence: HIGH | MED | LOW       # 1–2 ajánlatnál LOW, `flags: [n: 1..2]`
flags: [<pl. n: 1..2>] vagy []
language: hu | en | hu-en          # a kimenetek nyelve (clarify próza, proposal-master)
language_note: <ha a három érték nem fedi pontosan a regisztert: egy mondat>
keep_untranslated: [<terminuskör, amit a cég szándékosan nem fordít>] vagy []
mail_backend: <exchange | gmail | imap | none>   # + hatókör (postafiók/domain), ha van

offer_shapes:                      # amit a cég TÉNYLEGESEN használ, megfigyelt gyakoriság szerint
  - module_additive                # értékkészlet és választási szabály: document-shapes.md
  - service_levels
tier_naming: [<változat-nevek a cég saját szóhasználatával>] vagy []   # csak a variant_comparative formához

structure: [<a közös gerinc / az alapértelmezett faj szekció-sorrendje>]
structures:                        # dokumentumfajonként; elhagyható, ha a cégnek egy váza van
  <faj-kulcs>: [<szekció-sorrend>]
default_structure: <faj-kulcs>     # melyik váz nyer, ha a választási szabály nem dönt

tone: <2-3 mondat a megfigyelt hangnemről, idézettel>
tc_path: <útvonal vagy nincs>

commercial_invariants:             # amit a cég MINDEN kimenő ajánlata tartalmaz
  validity: <érvényességi idő; ha vonalanként más, vonalanként>
  inclusions: [<amit a díj tartalmaz>]
  exclusions: [<amit kifejezetten nem>]
  payment_terms: <fizetési határidő és mihez képest>
  cancellation: <lemondási klauzula: határidő és következmény>
  reference_scheme: <az ajánlat-azonosító sémája, vagy `nincs`>
  currency_rule: <melyik deviza melyik vonalon + átváltási kikötés>
  identity_block: <a szolgáltató fix adatblokkja: mely adatok, és hol áll>
  signature_block: <mikor kell aláírás-blokk és milyen alakban; `nincs`, ha sose>
  discount_policy: <hogyan ad a cég engedményt — lásd lent>

visual_identity:                   # forma, nem hangnem — a `tone` prózamező, ide nem való
  colors: [<hex értékek szerepükkel>]
  fonts: [<betűtípusok, célformátummal>]
  page: <lapméret, margó, fejléc/lábléc szerkezete>
  marks: [<ismétlődő vizuális jegy: sáv, keret, logóhasználat, tipográfiai szabály>]
  formats: [<milyen kimeneti formátumban megy ki: html, pdf, pptx, docx>]

render_chain:
  primary: <skill-név vagy none>
  critique: <skill-név vagy none>
  to_docx: <skill-név vagy none>
  to_pdf: <skill-név vagy none>
```

A `to_docx` a **szerkeszthető végartefakt** slotja: akkor töltsd ki, ha a megfigyelt norma az,
hogy a felhasználó a kimenő dokumentumot kiküldés előtt kézzel szerkeszti (a `visual_identity.formats`
docx-ot tartalmaz). Ilyenkor a docx a lánc igazság-vége, és a `to_pdf` **belőle** dolgozik — nem a
`primary` kimenetéből párhuzamosan: két külön ágon készülő végartefakt széttart, és a kézi szerkesztés
csak az egyikbe kerül be (round-trip szabály: `{pluginRoot}/references/deal-state.md`).

### 7. `offer_shapes`, `tier_naming`, `structure` / `structures`

Ez a négy mező együtt írja le, **mit tud a cég előállítani** — nem azt, hogy egy adott ajánlat
hogyan fog kinézni. A választás dealenként történik, az `assemble`-ben, a
`{pluginRoot}/references/document-shapes.md` szabályai szerint.

Amit az `init`-nek itt tennie kell:

- **`offer_shapes`** — csak azt írd bele, ami a korpuszban **ténylegesen megfigyelhető**. Ha a cég
  sehol nem ad három egymás melletti alternatívát, akkor a `variant_comparative` nem kerül a
  listába, függetlenül attól, hogy REF-03 szerint az anchoring szokásos eszköz. Ha a cég az
  olcsóbb változatot új dokumentumként adja ki, az `separate_document`.
- **`tier_naming`** — a `variant_comparative` **változat-nevei**, a cég saját szavaival. Ha a cég
  nem használ ilyen formát, az érték `[]`, és ez **megállapítás, nem kitöltetlen mező** — írd is
  oda a `flags` közé, hogy nem megfigyelt. Ne találj ki neveket, és ne vedd át egy másik cég
  vagy egy framework szóhasználatát.
- **`structure`** — a cég összes kimenő ajánlatának **közös gerince**, illetve az alapértelmezett
  faj szekció-sorrendje. Ez a mező akkor is kell, ha van `structures`: ez a visszaesési út, és ezt
  olvassa az a fogyasztó, amelyik a `structures`-t nem ismeri.
- **`structures`** — fajonként a **tényleges** szekció-sorrend. Akkor kötelező, ha a korpuszban
  szerkezetileg eltérő dokumentumok vannak. Ha egy faj vázából hiányzik olyan szekció, amit egy
  másik kötelezővé tesz (pl. nincs deliverable-lista vagy nincs scope-határ), azt **hagyd
  hiányozni** — ez megfigyelés, nem hiba, és a fajok átlagolása olyan vázat ad, ami egyikre sem
  illik. A kulcsok nyitottak; ha a cégnek saját váza van, adj neki saját kulcsot.
- **`default_structure`** — melyik kulcs nyerjen, ha a választási szabály nem dönt. Jellemzően a
  legtöbbször megfigyelt faj.

### 8. Kereskedelmi invariánsok és vizuális rendszer

Ezek a mezők **nem díszítés**: mindegyik egy döntés, amit az ajánlat írójának amúgy is meg kell
hoznia, és amit a cég korábbi ajánlatai már eldöntöttek. Ha az `init` nem rögzíti őket, minden
`assemble` futás újra kitalálja — vagy kihagyja, és a kimenet nem a cég ajánlata lesz.

- **`validity`** — érvényességi idő. Gyakran vonalanként graduált (rövidebb a gyorsan mozgó
  vagy devizás munkánál, hosszabb a nagy keretnél); ha így van, vonalanként írd ki. Érvényesség
  nélküli ajánlat kereskedelmileg nyitott ajánlat.
- **`inclusions` / `exclusions`** — a „a díj tartalmazza / nem tartalmazza" pár. Kereskedelmileg
  teherviselő és **párban** kell megjelennie: a kizárás nélküli felsorolás nem lehatárolás.
- **`payment_terms` / `cancellation`** — határidő és mihez képest (számla kelte vagy kézhezvétele),
  illetve a lemondási ablak és következménye.
- **`reference_scheme`** — az ajánlat-azonosító mintázata, sablonként kiírva
  (pl. `<cégkód>-<év>-<ügyfélkód>-<típus><sorszám>`), hogy az `assemble` generálni tudja.
- **`currency_rule`** — melyik deviza melyik vonalon, és milyen átváltási kikötéssel. Ez
  **stílus- és üzletág-döntés**, nem költség-döntés: az `economics.md` `currency`-je azt mondja meg,
  miben számolunk, ez azt, miben ajánlunk.
- **`identity_block`** — a szolgáltató fix adatblokkja (cégadatok, bankkapcsolat). Nem csak a
  tartalma kötött, a **helye is** — és a helye dokumentumfajonként más lehet.
- **`signature_block`** — bináris és fajfüggő: van, ahol kötelező, van, ahol sose szerepel.
- **`discount_policy`** — hogyan ad a cég engedményt. Ha a megfigyelés az, hogy **minden engedmény
  meg van nevezve és megindokolva** a dokumentumban (pilot-ár, stratégiai partneri ár, egyedi cap),
  azt írd ide, mert ez egyszerre stílus- és kereskedelmi szabály: néma engedmény nem mehet ki.
  Az engedmény **mértékének** korlátja ettől független, és az `economics.md`
  `margin.strategic_discount_cap`-jében él.
- **`visual_identity`** — a `tone` a **hangról** szól (mondatok, fordulatok, regiszter); a vizuális
  rendszer a **formáról**. Sok cégnél ez a legállandóbb elem az egész korpuszban, formátumtól
  függetlenül, ezért külön mezőt kap. A `render_chain` ezt a leírást használja: a renderelő skillnek
  ezt kell megvalósítania, nem a saját alapértelmezését.

### 9. `language`, `language_note`, `keep_untranslated`

A `language` enum a **kimenet fő nyelvét** rögzíti. Van olyan valós regiszter, amit a három érték
nem fed: magyar törzsszöveg, amely **szándékosan fordítatlanul** viszi az ügyfél szakterületi és
iparági szókincsét (angol szakszavak, a megrendelő saját üzemi terminusai). Ez nem `hu-en` — a
`hu-en` vegyes nyelvű **dokumentumrészeket** jelent, nem fordítatlan terminusokat.

Ilyenkor: `language` a legkevésbé rossz enum-érték, `language_note` egy mondatban a regiszter, és
a `keep_untranslated` felsorolja a terminusköröket. Az `assemble` és a `clarify` ezeket a szavakat
**nem fordítja le** — ez nem szabadságlevél mindent az eredeti nyelven hagyni, hanem nevesített lista.

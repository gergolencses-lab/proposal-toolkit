# deal.md — a deal-állapot kontraktusa

Minden deal egyetlen állapotfájlt kap: `{memoryRoot}/deals/{slug}/deal.md`.
A `clarify`, az `assemble`, a `revise` és a `drive` a futása végén **kötelezően** frissíti.
Ez az egyetlen dolog, ami a lépések között életben marad — a chat-kontextus nem az.

## Séma

```markdown
---
company: <cég-azonosító a {memoryRoot}/proposal/ alól>
status: <new | discovery | solutioning | sent | closed>
---
# <Ügyfél> · <deal rövid neve>

| lépés | mikor | confidence | flag |
|---|---|---|---|
| clarify | <ISO dátum vagy —> | HIGH/MED/LOW vagy — | <flag vagy —> |
| assemble | — | — | — |

## Nyitott kérdések
- <kérdés>

## Következő lépés
- <konkrét akció, felelőssel ha van>
```

A `revise` sora nem része az induló sémának — az első revíziós kör után kerül a táblába
(`| revise | <dátum> | — | <flag vagy —> |`), és onnantól ugyanúgy felülíródik, mint a többi.

## Írási szabályok

- **Sor felülírása, nem hozzáfűzés.** Egy lépés újrafuttatásakor a saját sora frissül.
- **A flagek nem tűnnek el.** Ha egy lépés flaggel futott, az a sorában marad, amíg a lépés újra nem fut flag nélkül.
- **A `status` monoton.** Csak előre lép, kivéve ha a felhasználó explicit visszalépést kér.
- **Ütközés.** Ha a fájl kézzel szerkesztettnek tűnik (a séma sérül), ne írd felül: jelezd, és kérdezz. A felhasználó kérésére végrehajtott `status`-állítás (lásd lent) **nem** kézi szerkesztés — az a rendszer normál útja.

## Ki állítja a `status`-t, és mikor

| érték | ki írja be | mikor |
|---|---|---|
| `new` | a dealt létrehozó lépés (jellemzően `drive`) | a `deal.md` első kiírásakor |
| `discovery` | `clarify` | minden sikeres `clarify` futás zárásaként |
| `solutioning` | `assemble` | a proposal-master fájl kiírásakor |
| `sent` | a **felhasználó** — a `drive` írja be a szavára | miután ténylegesen kiküldte az ajánlatot az ügyfélnek |
| `closed` | a **felhasználó** — a `drive` írja be a szavára | amikor a deal kimenetele ismert (nyert vagy vesztett) |

Két szabály:

- **Skill sose lép magától `sent`-re vagy `closed`-ra.** A kiküldés és a kimenetel emberi tény, a fájlokból nem számítható ki. A `drive` ezeket kizárólag a felhasználó explicit közlésére írja be.
- **A monotonitás írás közben is érvényes.** Ha a `status` már előrébb tart, mint amit a lépés beírna (pl. `assemble` fut újra egy `sent` dealen), hagyd az értéket változatlanul — ne léptesd vissza.

A `revise` a `status`-hoz **egyáltalán nem nyúl**: revízió futhat `solutioning`-on (kiküldés előtti kör) és `sent`-en (az ügyfél kér módosítást) — egyik esetben sem állapot-átmenet.

## Kézzel szerkesztett artefakt — round-trip szabály

A felhasználó a kiment vagy kiküldésre szánt artefaktot (docx, pdf) **kézzel szerkeszti** — ez a rendszer normál útja, nem anomália. Ebből következik az egyetlen szabály, amit minden lépésnek tartania kell:

- **Az igazság az élő artefakt, nem a master.** Ha a felhasználó szerkesztett példányt ad vissza, arra hivatkozik, vagy a példány verziója/dátuma frissebb a masternél, akkor minden további munka (revízió, render, ellenőrzés) **abból** indul. A master ilyenkor követő dokumentum: a `revise` húzza utána (delta-szekcióval vagy új datált masterrel).
- **Tilos a csendes regeneráció.** Elavult masterből újragenerálni az artefaktot a felhasználó kézi munkájának felülírása — ha a master és az artefakt széttartása kiderül, ezt kimondod, és az artefakt nyer, kivéve ha a felhasználó mást mond.
- A fenti „Ütközés" szabály a `deal.md`-re vonatkozik, nem az artefaktokra: a `deal.md` kézi szerkesztése séma-sérülés esetén kérdést vált ki — az artefakt kézi szerkesztése viszont várt viselkedés.

## Bizonytalanság-továbbítás

A flagek lefelé utaznak. Ami az `init`-ben vagy a `clarify`-ban gyenge volt, annak az `assemble` futásán is látszania kell — de **két külön címzettnek, két külön helyre**. Az üzemeltetőnek mindig mindent; az ügyfélnek csak azt, amin változtatni tud.

### A) Belső jegyzet — minden futásban, küszöb nélkül

Az `assemble` **minden** futása kiírja, akkor is, ha minden input szilárd. Két helyre, azonos tartalommal:

- a futás saját kimenetébe, az üzemeltetőnek — ez a futás első közlése, még a dokumentum előtt;
- a proposal-master **végére**, önálló, feliratozott szekcióba.

```markdown
## Belső jegyzet — nem az ügyfél példányába

- Kiesett forrássávok: <sávonként, a clarify `Bizonytalanságok`-ból — vagy „nincs">
- Álló flagek: <a `deal.md` flag-oszlopa lépésenként — vagy „nincs">
- `clarify` confidence: <HIGH | MED | LOW>
- `economics.md`: n_offers = <db>, confidence = <érték> — vagy „nincs `economics.md`"
- Ár-alap: <melyik `service_lines` vonal, vagy „aggregát" — és miért az>
- `house-style.md`: <van | nincs — nincs esetén generikus forma, az `init` kalibrálja>
- Választott dokumentumfaj: <kulcs> — <egy mondat, konkrét tényre hivatkozva>
- Választott ajánlati forma: <érték> — <egy mondat, konkrét tényre hivatkozva>
- Ügyfélnek szóló kitétel: <ár | scope | mindkettő | egyik sem>
```

A két „Választott…" sor indoklása a `{pluginRoot}/references/document-shapes.md` szabályaira és a
clarify-outputra hivatkozik, nem ízlésre. Az „Ár-alap" sor akkor is kitöltendő, ha nincs
`service_lines` map — ilyenkor „aggregát".

Küszöb nincs, mert az üzemeltetőnek minden sor hasznos, és semmibe nem kerül: ez a szekció nem megy ki az ügyfélhez. A jegyzet a **fájl végén**, egyértelmű felirattal áll, hogy a kiküldés előtt egy mozdulattal levágható legyen — a kiküldés (és a levágás) a felhasználó lépése. A jegyzet az üzemeltetőnek szól, ezért a skill nyelvén megy, nem a `house-style.md` `language` mezője szerint.

**A jegyzet sose kerül át az ügyfélnek szánt artefaktumba.** A futás saját kimenete és a markdown master az üzemeltetői útvonal — azon belül marad. A `render_chain` viszont kizárólag az ügyfélnek szóló részt viszi: a jegyzet nem renderelődik és nem kerül PDF-be (`assemble` 6. pont), a kiküldés előtt pedig kikerül (`assemble` 7. pont). Ez ugyanaz a bizalmassági szabály, mint a B) pont tartalmi tilalma, csak a fájl-útvonalra alkalmazva.

### B) Ügyfélnek szóló kitétel — csak amin az ügyfél változtatni tud

Nem a flagek számából következik. Az egyetlen kérdés: **megváltoztatja-e a gyengeség azt, amire az ügyfél igent mond?** Két dolgot érinthet — az árat és a scope-ot:

| Trigger | Mikor áll | Hova, mit ír |
|---|---|---|
| **Nincs ár** | nincs `economics.md` — a kimenet ár nélküli scope-dokumentum (`assemble` 2. pont) | oda, ahol az ár állna (a `structure` ár-szekciójának helyére): egy mondat arról, hogy az összeg egy következő körben jön. Hogy most miért nincs, azt nem mondja meg |
| **Az ár nem fix** | van `economics.md`, de `confidence: LOW` vagy `n_offers` ≤ 2 | az ár-szekcióba: a megadott összeg indikatív, a kötelező érvényű árajánlat a következő körben jön |
| **A scope alapja vékony** | **(i)** áll a `docs: none` flag, **ÉS** a clarify-output deliverable-listája következtetett, nem tételesen kiírt — a két feltétel együtt; **vagy (ii)** a clarify `Siker-kritériumok` csak kvalitatívak, mérőszám nélkül | a scope-szekcióba: a deliverable-ök a visszaigazolásig előzetesek, és **nevezd meg, mi igazolná vissza** (a hiányzó mérőszám, az átadandó specifikáció, egy egyeztetés) |

Az első két sor kizárja egymást: vagy van ár, vagy nincs.

Az (i) ág azért **konjunktív**, mert a `docs: none` önmagában csak annyit jelent, hogy a skill nem kapott helyi fájlt — a részletes kiírás állhat a levél törzsében is, csatolmány nélkül. Ez a magyar B2B-ben hétköznapi: a deal ilyenkor pontosan specifikált, a deliverable-lista tételesen kiírt, tehát a trigger **nem** áll, és nem tesszük a saját ajánlatunkat bizonytalanabbnak a valósnál. Csak akkor tüzel, ha a fájl is hiányzik **és** a listát mi következtettük ki.

Mindkét ág eldönthető a rendelkezésre álló fájlokból: a flag a `deal.md`-ből, a lista jellege és a kritériumok mérhetősége a clarify-outputból. A `docs: none` elérhető állapot — a `clarify` STOP-küszöbe csak a **kettős** hiányt zárja ki (sem levelezés, sem átadott fájl). Olyan feltétel, amit az `assemble` ezekből nem tud kiértékelni, nem kerül ebbe a táblába.

Ha egyik trigger sem áll, **semmilyen kitétel nem kerül a dokumentumba**. Ez a gyakori eset, és így helyes.

**Tartalmi tilalom — ez bizalmassági szabály, nem stílus.** Az ügyfélnek szóló szöveg soha nem említi: a belső kalibrációt, a margin- és költségadatokat, hány korábbi ajánlatból jött az `economics.md`, a levelező- vagy rendszer-hozzáférést, a hiányzó házi stílust. Ezek kizárólag a belső jegyzetbe tartoznak. A kitétel azt mondja meg, **mi következik ebből az ügyfélre nézve** — sose azt, hogy nálunk mi hiányzik.

A `deal.md` flag-oszlopa ugyanezt hordozza a rendszer felé. Ha egy lépés flag nélkül fut újra, a belső jegyzet sorai ennek megfelelően ürülnek, és a triggerét vesztett kitétel kikerül a dokumentumból.

## Cég-azonosító normalizálása

A `deal.md` frontmatter `company` mezője és a `{memoryRoot}/proposal/{company}/` mappanév **karakterre ugyanaz a string** — ez köti a dealt a cég-réteghez. Normalizálás: kisbetűs, ékezet nélküli ASCII, minden nem alfanumerikus karakter `-`, ismétlődő `-` összevonva, a széleken levágva („Acme Tanácsadó Kft." → `acme-tanacsado-kft`). Ha a felhasználó ettől eltérő, rövidebb azonosítót ad (`acme`), az a mérvadó — de akkor mindenhol az, és a `deal.md` is azt kapja. A teljes, megjelenítendő cégnév a fájl törzsébe kerül, nem a mappanévbe.

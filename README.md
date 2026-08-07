# proposal — ajánlat-workflow Claude Code-hoz

Claude Code plugin egy end-to-end B2B ajánlatkészítési workflow-hoz. Öt skillből áll, amik egymásra épülnek: egyszer kalibrálod a céged a valódi múltbeli ajánlataidból, utána minden új dealt ezen a bekalibrált alapon futtatsz végig — verifikált revíziós körökkel, számítási és ár-kapukkal, ember által kontrollált kiküldéssel.

*An end-to-end B2B proposal workflow for Claude Code: calibrate once from your own past offers, then decode, assemble, and revise every new deal on that calibrated base. Hungarian-first; the method is language-agnostic.*

**A plugin nem tartalmaz és nem gyűjt cégadatot.** Nincs beégetett napidíj, horgony-ár, stílus vagy útvonal — minden kalibráció az `init` futásakor, a te gépeden, a saját memória-könyvtáradban jön létre, és ott is marad. A repo a módszert adja; a számok a tieid.

## Telepítés

```
/plugin marketplace add gergolencses-lab/proposal-toolkit
/plugin install proposal@zel
```

## Gyors kezdés

1. **Kalibráció (egyszer):** `/proposal:init` — a skill 3–4 valós, elküldött ajánlatot kér, és ezekből építi fel a cég-réteget: árazott tételek listája (`economics.md`), házi stílus (`house-style.md`).
2. **Új deal:** `/proposal:drive` — a router megkérdezi, mi jött (email, RFP, hívás-jegyzet), és végigterel: `clarify` (a deal dekódolása négy forrássávból) → `assemble` (ajánlat-dokumentum ár-levezetéssel) → `revise` (visszajelzés-körök).
3. **Kiküldés:** mindig a tiéd. A rendszer fájlt ír — emailt soha nem küld.

Példa: beesik egy megkeresés a (fiktív) Meridian Energia Zrt.-től vezetői AI-workshopra. A `clarify` kiszedi a levelezésből, ki dönt és mi fáj; az `assemble` a te korábbi, hasonló árazott tételeidhez pozicionálja az árat, és kiírja a levezetést; a visszajelzés után a `revise` tételesen verifikálja az észrevételeket, mielőtt bármit átírna. Minden lépés a `deals/<slug>/deal.md` állapotfájlba dolgozik — két hét múlva is pontosan onnan folytatod, ahol abbahagytad.

## Az öt skill

| Skill | Mit csinál |
|-------|-----------|
| `init` | Egyszeri kalibráció: a cég korábbi valódi ajánlataiból kiolvassa a gazdasági logikát (árazás, marzs, csomagolás) és a házi stílust (hangnem, szerkezet, formázás). |
| `clarify` | Egy új deal lebontása — a kliens, a scope és a kontextus tisztázása, mielőtt bármi is íródna. |
| `assemble` | Az ajánlat dokumentum összeállítása a kalibrált cég-logika és a tisztázott deal-adatok alapján. |
| `revise` | Visszajelzés-kör egy kész ajánlaton: az észrevételek verifikálása a tényleges szövegen, mechanika és döntés szétválasztása, revízió az élő artefakton, master- és állapot-utánhúzás. |
| `drive` | Router — eldönti, hol tart a folyamat, és a megfelelő lépéshez irányít (init → clarify → assemble → revise). |

Mind az öt skill kész és telepíthető. A v1 hatókörén kívül maradt a mély árazás (`price`), a tárgyalás-támogatás (`negotiate`) és a win-loss elemzés (`winloss`) — ezek v2-es bővítések, a `drive` jelzi, ha egy deal ilyen ponthoz ér.

## Deal-életciklus

A `deal.md` `status` mezője viszi az állapotot: `new` → `discovery` (a `clarify` írja) → `solutioning` (az `assemble` írja) → `sent` → `closed`. Az utolsó kettőt kizárólag a felhasználó szavára írja be a `drive`: a kiküldés és a kimenetel emberi tény. A skillek soha nem küldenek emailt — a `assemble` és a `revise` fájlt ír, a kiküldés a felhasználó lépése. A `revise` a `status`-hoz nem nyúl: revíziós kör futhat kiküldés előtt és után is.

Két elv, ami a teljes életciklust köti: **az igazság az élő artefakt** — ha a felhasználó kézzel szerkesztette a kimenő dokumentumot, minden további munka abból indul, és a master követi (round-trip szabály, `references/deal-state.md`); és **a szerkeszthető formátum a lánc vége** — docx-ben szerkesztő cégnél a PDF a docx-ből készül, nem mellette.

Két helyen áll meg a folyamat emberi döntésre: ha az ár-kapu bármelyik feltétele teljesül (az ügyfél plafonja a javasolt ár alatt van, az ár a legalacsonyabb nyert összemérhető alatt van, vagy a `cost_floor` alatt), és a kiküldésnél.

## Hogyan lesz ár — két motor

**1. Ár-motor (alapértelmezett, nulla költség-input).** Az `init` kiírja a cég **minden árazott
tételét** egyenként (`price_history`): mit fedett, mennyiért, mi lett a kimenetele. Az `assemble`
ebből választja ki azokat, amik az adott dealre hasonlítanak, és ahhoz képest pozicionál — a
levezetést kötelezően kiírva. **Nincs tárolt napidíj vagy horgony, amit a deal nevezőjével
szoroznánk**; ez a szerkezet mérhetően nagyságrendi tévedést tud csendben előállítani. Kettőnél
kevesebb összemérhetőnél az ár `null`, és a skill kérdez — nem becsül.

**2. Költség-motor (opcionális, csak padlót ad).** Ha van ismert működési költség, `cost_floor`
lesz belőle: az ár nem mehet alá. Ha nincs, `provenance: none`, és az árazás ettől még hiánytalanul
működik. A költség **soha nem árazási bemenet**, csak alsó korlát. Külső piaci benchmarknak is van
helye (`benchmark`) — de az se nem ár, se nem padló, hanem kontextus.

A szabályok: `references/price-engine.md` (REF-12).

## Forma és dokumentumfaj

Egy cégnek jellemzően **több ajánlati formája és több dokumentumváza** van, és nem az ízlése választ közülük: az ajánlati formát (additív modulok, szolgáltatási szintek, összehasonlítható változatok, egyetlen tétel, külön dokumentum) a deal tartalma, a dokumentum vázát pedig a **vevő beszerzési útja** dönti el. Ezért a cég-réteg csak azt rögzíti, mit tud a cég előállítani (`offer_shapes`, `structures`), a választás dealenként az `assemble`-ben történik, és mindkét választást meg kell indokolni a belső jegyzetben. Alapértelmezés az additív moduláris forma. A szabályok és két végigvezetett példa: `references/document-shapes.md`.

## Hova ír a rendszer

A workflow két réteget különböztet meg:

- **Cég-réteg** — az `init` skill kimenete: a cég gazdasági logikája és stílusa, egyszer kalibrálva, később minden dealhez újrahasznosítva.
- **Deal-réteg** — a `clarify` és `assemble` skillek kimenete: az adott, konkrét ajánlat adatai és a kész dokumentum.

A memóriagyökér a `~/.claude/data/proposal/bootstrap.json`-ban él, és az első futáskor a skill kérdezi meg — beégetett útvonal sehol nincs. A pontos útvonal-táblát a `references/bootstrap.md` tartalmazza; a deal-állapot kontraktusát a `references/deal-state.md`; a cég-réteg **sémáját** a `references/company-schema.md`, a mezők **fogyasztását** és a hiányuk esetén érvényes fallbackeket a `references/company-config.md`. Cégspecifikus érték (napidíj, hangnem, levelező-backend, nyelv) soha nem kerül SKILL.md-be — minden ilyen a bekalibrált cég-fájlokban él.

**Hivatkozási forma.** A `references/` fájlok a plugin **gyökerében** élnek, egy skill saját könyvtára viszont `skills/<név>/` — ezért a skillek `{pluginRoot}/references/<fájl>.md` alakban hivatkoznak rájuk. A `{pluginRoot}` feloldása futásidőben: a harness a skill betöltésekor kiírja a `Base directory for this skill` útvonalat, és a plugin gyökere ehhez képest két szinttel feljebb van. Ez mindkét telepítési elrendezésben ugyanaz (fejlesztői plugin-gyökér és verziózott `plugins/cache/<marketplace>/<plugin>/<verzió>/` másolat).

## Ha nincs 3-4 múltbeli ajánlatod

Az `init` valós, elküldött ajánlatokból dolgozik, és nulla dokumentumnál megáll. Ez nem zsákutca: ilyenkor az `assemble` **ár nélküli scope-dokumentumot** ad, és a cég-réteg később, az első valós ajánlatok után is bekalibrálható.

Ami bemegy, az számít: egy mappa tartalma nem azonos azzal, ami kiment az ügyfélhez. A `.md` gyakran munkaverzió (a HTML/PDF a kiküldött), és van, ami ajánlatnak olvassa magát, de belső stratégiai anyag — versenytárs-horgonyokkal és tárgyalási fallbackekkel. **Belső munkaanyagból sem stílust, sem árat nem kalibrálunk**, és a tartalma ügyfélnek szóló dokumentumba sose kerül. A kiválasztás szabályai, a verziólánc-kezelés és az `n_offers` egysége: `references/offer-corpus.md`.

## Validátor

A `scripts/check.sh` ellenőrzi a plugin higiénéjét: érvényes-e minden JSON manifest a `.claude-plugin/` alatt, és minden `skills/*/SKILL.md` megfelel-e a formai szabályoknak (frontmatter `name` = mappanév, `description` "Use when "-nel kezdődik, max 700 szó). A `references/` fájlokra nincs szóhossz-korlát: ami nem fér a skillbe, az oda kerül, és a skill hivatkozza.

```
./scripts/check.sh; echo "exit=$?"
```

## Hogyan működik — vizuálisan

A workflow magyarázó oldala: **https://gergolencses-lab.github.io/proposal-toolkit/**

## Licenc

MIT © 2026 [ZEL Group](https://www.zel-group.com) · Lencsés Gergő

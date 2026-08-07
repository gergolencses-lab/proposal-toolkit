# REF-12 — Ár-motor: összemérhető tételekből

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.

Ez a fájl mondja meg, **hogyan lesz ár**. Egyetlen bemenete az `economics.md` `price_history`-ja:
a cég ténylegesen kiküldött, árazott tételei, egyenként.

**Az árat nem egy tárolt szám szorzása adja, hanem megnevezett korábbi tételekhez való pozicionálás.**
Ez a különbség az egész motor lényege, és minden alábbi szabály ebből következik.

## 1. A levezetés

**a) Válassz összemérhetőket.** A hasonlóság mértéke az, **mit fedett a tétel** — terjedelem, létszám,
szerep, kockázat, ismételhetőség —, nem az, milyen címke (`line`) van rajta. Két tétel elég; ennél
kevesebbnél lásd a 2. pontot. Minden kizárást írj le: melyik tételt hagytad ki, és milyen **megengedett
forrásból** származó okból (dokumentum vagy a felhasználó kijelentése). Belső munkaanyagra hivatkozó
kizárás nem érvényes — amit kalibrációra nem használhatsz, azzal kizárni sem lehet
(`{pluginRoot}/references/offer-corpus.md`).

**b) Pozicionálj.** Az összemérhetők ára a kiindulópont; a mostani deal ehhez képest feljebb vagy
lejjebb áll. Ami mozgat: terjedelem, létszám, seniority, on-site vs. távoli, ismételhetőség,
kockázatvállalás, az ügyfél mérete. **Egy megnevezett tétel átskálázása megengedett** — de mondd ki,
melyiket skálázod, milyen arányban, és **miért tart** az arány. A méret ritkán lineáris: a rövidebb
változat gyakran drágább naponta, mint a hosszú, és ezt a korpusz szokta is mutatni.

**c) A kimenet egy szám ÉS a levezetés.** Kötelező alak, a dokumentum ár-szekciója elé:

```markdown
### Ár — levezetés
| Összemérhető tétel | Ár | Kimenet | Miben tér el ez a deal |
|---|---|---|---|
| <ügyfél, dátum, mit fedett> | <ár> | won/lost/open/unknown | <az eltérés, ami mozgatja az árat> |

**Javasolt ár:** <érték> — <egy mondat: melyik tételhez képest, milyen irányban, miért>
```

**Ha a levezetés nem írható le, nincs ár.** A levezetés nem az ár indoklása utólag: a levezetés *maga*
az árazás. Ami nem vezethető le, azt nem tudod.

**d) Kimenet-súlyok.** A `won` ár bizonyíték arra, hogy az ár **megállt** — de csak az az ár, ami tényleg elhangzott: ha a tétel `note`-ja megnevezett engedményt rögzít, a `won` a **kedvezményes** árat igazolja, nem a listaárat, és a levezetésben ezt ki kell mondani. Egy padló közelében megnyert deal engedmény nélküli horgonyként betanulva csendben lefelé húzza a következő árat. A `lost` arra, hogy az adott
ügyfélnél nem — ez nem teszi az árat rosszá, de a levezetésben meg kell jelennie. Az `unknown` is
teljes értékű bizonyíték: azt mutatja, **mit kértél el**. Csupa `unknown` kimenet mellett is árazhatsz,
csak a megerősítés hiányzik — ezt írd bele a levezetésbe és a belső jegyzetbe.

**e) Két független ügyfélnél azonos ár.** Ha ugyanazt a csomagot két különböző ügyfélnek ugyanazon az
áron adtad, az a korpusz **legerősebb** jelzése — erősebb, mint bármilyen napra vagy főre vetített
átszámítás. Ilyenkor az az ár a kiindulópont, és eltérni tőle csak megnevezett, a dealben tényleg
meglévő különbségre hivatkozva lehet.

## 2. Ha nincs elég összemérhető → `ár: null`

Kettőnél kevesebb összemérhető tételnél az ár `null`. Ilyenkor **nem becsülsz**: leírod, mihez képest
nem tudsz árazni, és megkérdezed a felhasználót. A `null` megállítja a futást és kérdezni kényszerít;
egy odaírt szám nem. Egy megbízhatóan „nem tudom" működő motor többet ér, mint egy magabiztosan téves.

Ez nem hibaág: új szolgáltatásvonalnál ez a **várt** viselkedés.

## 3. Padló és külső benchmark

- **`cost_floor`** (opcionális) — ha ki van töltve, az ár nem mehet alá. A költség **padlót ad, árat
  soha**. Ha `provenance: none`, nincs padló; ez nem hiány, hanem megállapítás.
- **`benchmark`** (opcionális) — külső piaci referencia. **Se nem ár, se nem padló**: kontextus a
  levezetéshez és a belső jegyzethez. Külső számból árat vezetni tilos — más cég költségszerkezete,
  szállítási modellje és pozíciója van mögötte.

## 4. Tiltások

| Tiltott | A racionalizáció, ami odavisz | Miért tilos |
|---|---|---|
| Egy tárolt átlagot/skalárt szorozni a deal nevezőjével | „Van egy kalibrált napidíj, ezt szorzom" | Ez a motor egyetlen mért kritikus hibája: az egységükben nem összeillő skalár és nevező szorzata csendben ad nagyságrendi tévedést, és minden kapu átengedi, mert **van** szám. |
| Számot mondani kettőnél kevesebb összemérhetőből | „Legalább egy közelítés jobb a semminél" | Nem jobb: a becsült szám ugyanúgy néz ki, mint a levezetett, és a hibája csak a kiküldés után derül ki. |
| Ismétlődő tényleges árat elvetni, mert kevés a megfigyelés | „Nincs meg a minimális elemszám, biztonságosabb átszámolni" | A két ügyfélnél azonos ár a legerősebb megfigyelés, amid van; egy másik egységből visszaszámolt érték gyengébb bizonyíték, nem erősebb. |
| Kizárni egy összemérhetőt belső munkaanyagra hivatkozva | „Ott le van írva, hogy az az ár nem volt reális" | Ha a forrásból árat nem kalibrálhatsz, akkor bizonyítékként sem használhatod — különben a kizárás azt teszi be az árazásba, amit a szabály éppen kizár. |
| Külső benchmarkból árat vezetni | „A piaci átlag ennyi, tehát ennyi az ár" | A benchmark mögött más cég van; az `assemble` a **te** korpuszodból árazik. |

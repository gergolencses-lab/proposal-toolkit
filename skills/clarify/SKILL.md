---
name: clarify
description: Use when a client brief, RFP, or sales call has produced scattered information about a deal and the picture needs to be assembled. Also use when it is unclear who decides, what the client actually needs, or what questions to ask on the next call.
---

# clarify — deal-dekódolás négy forrásból

> **Útvonalak.** `{pluginRoot}` = a betöltéskor kiírt `Base directory for this skill` két szinttel feljebb.

Egy dealhez az információ mindig szétszórva áll rendelkezésre — levelezés, átadott anyag, nyilvános háttér, korábbi kapcsolat. A `clarify` ezt a négy sávot egyenként lekérdezi, összeáll belőle a kép, és a futás fő haszna a **Következő 3 kérdés**: a felderítés a legdrágább lépés, mielőtt egy sornyi ajánlat is megszületne.

## 1. Memóriagyökér és deal

`{memoryRoot}`, `{company}`, `{slug}` feloldása: `{pluginRoot}/references/bootstrap.md` — kövesd onnan, a logika itt nincs megismételve. Ez akkor is a te dolgod, ha a munka közvetlenül a `clarify`-jal indul: hiányzó bootstrap-fájl esetén is ott áll a teendő, ne a `drive`-ra várj.

## 2. A négy forrássáv

Mindegyiket megpróbálod, sávonként külön degradálva — egy hiányzó sáv **soha** nem állítja meg a többit:

| Sáv | Hogyan | Ha nincs |
|---|---|---|
| Levelezés | A cég **konfigurált levelező-backendjében** (`mail_backend`, `house-style.md`) keress az ügyfél domainjére és a kontaktnevekre; a mező feloldása és hiány esetén a teendő: `{pluginRoot}/references/company-config.md` | flag `mail: unavailable` |
| Átadott fájlok | A felhasználó megadott path-jai (RFP, jegyzet, deck) | flag `docs: none` |
| Publikus cégháttér | Webkeresés: árbevétel, tulajdonos, friss hírek, trigger event | flag `web: skipped` |
| Saját memória | `{memoryRoot}/orgs/`, `{memoryRoot}/people/`, korábbi dealek | flag `memory: no prior` |

**STOP-küszöb:** ha SEM levelezés, SEM átadott fájl nincs (nulla elsődleges forrás) → állj meg, mondd meg mi hiányzik. Web és memória önmagában nem elég dealt dekódolni — ezek kiegészítik az elsődleges forrást, nem helyettesítik.

**Tényellenőrzés (kötelező).** A publikus cégháttér-sáv minden állítása — létező cégről, személyről, árbevételről, hírről — kizárólag webkeresésből származhat. Amit nem kerestél ki, azt nem írod le tényként; ha nincs megbízható forrás, flagold, ne találgass.

## 3. A kimenet szerkezete

Írd: `{memoryRoot}/deals/{slug}/clarify-{dátum}.md`. A kilenc szekciócím **kötött** — az `assemble` név szerint olvassa a „Siker-kritériumok" és „Kényszerek" szekciót. A szekciókon belüli próza nyelve viszont a `house-style.md` `language` mezője szerinti (feloldás és fallback: `{pluginRoot}/references/company-config.md`); a címek nyelvtől függetlenül ezek maradnak:

```markdown
## Topline
## Döntési térkép
## Fájdalom
## Döntési folyamat
## Siker-kritériumok
## Kényszerek
## Miért mi, miért most
## Bizonytalanságok
## Következő 3 kérdés
```

- **Döntési térkép** — REF-02 négy szerep (Economic Buyer, Champion, User/Tech, Blocker), amennyi a sávokból kitölthető.
- **Fájdalom** — REF-05 SPIN struktúra (Situation, Problem, Implication, Need-payoff).
- **Döntési folyamat** — DACI (REF-02) + timeline + a **beszerzési út**: formális pályáztatás, a vevő saját beszerzési általános feltételei, szállítói feltételrendszer folyamatos kötelezettséggel, vagy közvetlen szakmai döntés beszerzés nélkül. Ebből választ az `assemble` dokumentumfajt (`{pluginRoot}/references/document-shapes.md`), ezért ha nem derül ki, mondd ki, hogy nem derült ki — ne következtesd.
- **Siker-kritériumok** — 6 és 12 hónapos, mérőszámmal, nem általánosságban.
- **Kényszerek** — budget, timeline, scope must/no-go, jogi.
- **Bizonytalanságok** — minden flag ide kerül, sávonként megjelölve, mi hiányzik. Gyanújel, ha a brief **feltűnően pontosan illik rátok**: az ilyen pályázat belül gyakran már meg van írva — nektek vagy egy versenytársnak —, ezt a Következő 3 kérdés egyike ellenőrizze.
- **Következő 3 kérdés** — nem díszítés: ez a futás fő haszna. Konkrét, a következő hívásra vihető kérdések, a legdrágább bizonytalanságot célozva, a felhasználó fájdalom-sorrendje szerint.

## 4. `deal.md` frissítés

A séma és az írási szabályok: `{pluginRoot}/references/deal-state.md` — kövesd onnan (sor felülírása nem hozzáfűzés, flag megmarad amíg flag nélkül újra nem fut a lépés, `status` monoton). Zárásként:

- `clarify` sor: dátum, confidence (HIGH/MED/LOW — minél több sávkiesés, annál lejjebb), flagek.
- `status: discovery` — ha a `status` már előrébb tart, hagyd változatlanul (monotonitás).
- „Nyitott kérdések" — a Bizonytalanságok szekcióból átvezetve.
- „Következő lépés" felülírása a friss állapot szerint.

## 5. Idempotencia

Új infó beérkezésekor (pl. egy visszaérkezett email) a `clarify` újra lefuttatható. A `deal.md` `clarify` sora **frissül, nem duplikálódik** — lásd `{pluginRoot}/references/deal-state.md` írási szabályai. Az output fájl a futás dátumát viseli; ha aznap már létezik ilyen, **ne írd felül** — a következő szabad sorszámmal ments (`clarify-{dátum}-2.md`, `-3.md`). A `deal.md` `clarify` sora mindig a legfrissebb futásra mutat.

---
name: drive
description: Use when a new proposal request arrives, when picking up an in-flight deal, or when unsure what the next step on a deal is. Also use when the user asks where a deal stands, what to do next on an offer, or mentions a client asking for a quote.
---

# drive — a proposal workflow routere

> **Útvonalak.** `{pluginRoot}` = a betöltéskor kiírt `Base directory for this skill` két szinttel feljebb.

## 1. Bootstrap és deal-azonosítás

`{memoryRoot}`, `{company}`, `{slug}` feloldása: `{pluginRoot}/references/bootstrap.md` — kövesd onnan, a logika itt nincs megismételve. Ha a bootstrap-fájl most készült el (első futás), a soron következő lépés az `init`: cég-réteg nélkül nincs mihez routolni.

## 2. Cég-réteg ellenőrzése

Nézd meg, létezik-e `{memoryRoot}/proposal/{company}/economics.md` a deal cégéhez. A `{company}` normalizálása: `{pluginRoot}/references/deal-state.md`.

**Egyetlen szabály, akkor is ha egyetlen cégre sincs economics.md.** Ha a deal cégéhez nincs `economics.md`, az ajánlott első lépés az `init` — enélkül nincs mihez viszonyítani az árat vagy a stílust. De az `init` 3–4 valós, elküldött ajánlatot kér, és nulla dokumentumnál megáll; akinek nincs ennyi anyaga, vagy most nem akar kalibrálni, annak a nyitott út az **ár nélküli scope-dokumentum** az `assemble`-lel. Ajánld az `init`-et, mondd meg mit kér, és a felhasználó válasszon — ne blokkold vele a dealt.

## 3. Routing-tábla

A `deal.md` frontmatter `status`-a és a lépés-tábla sorai alapján (séma: `{pluginRoot}/references/deal-state.md`). **A sorokat fentről lefelé értékeld: az első illeszkedő sor nyer** — így a LOW confidence sora megelőzi az `assemble`-sort, de csak akkor illeszkedik, ha tényleg van mivel újrafuttatni a `clarify`-t.

| `deal.md` állapota | Következő lépés |
|---|---|
| `status: closed` | nincs v1-es következő lépés — a deal le van zárva; az utólagos elemzés a `winloss` v2 bővítés dolga |
| `status: sent`, ÉS visszajelzés érkezett a kiment ajánlatra | `revise` — a `status` marad `sent` |
| `status: sent` egyébként | nincs v1-es következő lépés — a post-mortem a `winloss` v2 bővítés dolga (REF-07), ne próbáld meghívni |
| nincs `clarify` sor, vagy üres | `clarify` |
| a legutóbbi `clarify` LOW confidence-ű, ÉS azóta új forrás érkezett vagy van megválaszolható nyitott kérdés | `clarify` újra, a „Nyitott kérdések" szekcióval |
| van `clarify` sor, nincs `assemble` sor | `assemble` — LOW confidence mellett is; a bizonytalanságot ilyenkor az `assemble` belső jegyzete viszi tovább |
| van `assemble` sor, a `status` még nem `sent`, ÉS visszajelzés érkezett az artefaktra (review-megjegyzés, kézzel szerkesztett példány) | `revise` — a bázis az élő artefakt, nem a master (round-trip: `{pluginRoot}/references/deal-state.md`) |
| van `assemble` sor, a `status` még nem `sent` | **nincs automatikus következő lépés — a kiküldés a felhasználó lépése.** A belső jegyzet küldés előtt kikerül (`{pluginRoot}/references/deal-state.md`). Kérdezd meg, kiment-e: ha igen, `status: sent`; ha nem: `revise`, vagy új deal-infónál `clarify` újra |

Ha egyik sor sem illik (a fájl kézzel szerkesztettnek tűnik, a séma sérül): ne találgass, ne írd felül — jelezd a fájlt, és kérdezz.

**`status`-léptetés.** A `sent` és a `closed` értéket kizárólag a `drive` írja be, és kizárólag a felhasználó explicit közlésére („kiment", „megnyertük", „elbukott") — soha nem következtetve. A teljes tábla: `{pluginRoot}/references/deal-state.md`.

## 4. Megállás emberi döntésnél

Két döntés nem a `drive` vagy bármely más skill dolga: **ár margin floor alá vitele**, és **az ajánlat kiküldése**. Ezek kapui az `assemble` skillben élnek. A `drive` dolga itt annyi:

- Ha a routing-tábla szerinti következő lépés egy ilyen döntésen múlik, **ne indítsd el azt a lépést**.
- Mondd meg konkrétan, mi a döntés és milyen adat áll mögötte, majd várj a felhasználó válaszára.
- Ha a döntés megszületett, haladj tovább a normál routing-táblán.

## 5. Zárás

Minden `drive` futás végén frissítsd a `deal.md` „Következő lépés" szekcióját a `{pluginRoot}/references/deal-state.md` írási szabályai szerint (sor felülírása, nem hozzáfűzés; flag megmarad amíg a lépés flag nélkül újra nem fut; `status` monoton). Ha tényleges routing nem történt (pl. csak bootstrap vagy tisztázó kérdés volt), ezt a lépést hagyd ki.

## Puha függőségek

A `clarify`, `init`, `assemble` és `revise` skillek erre a routerre épülnek, de a `drive` sose hasaljon el, ha valamelyik hiányzik a telepítésből — jelezd egyszerűen, hogy az adott lépés skillje nincs telepítve, és a felhasználó kézzel folytathatja. Ahol a routing-tábla `winloss` v2-es bővítésre mutatna (`status: sent` vagy `status: closed`), mondd meg, hogy ez későbbi bővítés, ne próbáld meghívni.

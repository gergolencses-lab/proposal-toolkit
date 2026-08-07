# Képesség-próba — mi hívható ezen a gépen

> **Útvonalak.** `{pluginRoot}` a plugin gyökerét jelöli. A harness a skill betöltésekor kiírja a
> `Base directory for this skill` útvonalat (`…/skills/<név>/`); a gyökér ehhez képest két szinttel feljebb van.
> Ez a fájl és a többi hivatkozott referencia a gyökér alatti `references/` mappában él.

Az `init` ezzel tölti ki a `house-style.md` `render_chain` slotjait (`primary`, `critique`, `to_docx`, `to_pdf`).
A slotok jelentése és a hiányuk következménye: `{pluginRoot}/references/company-config.md`; a `to_docx`
szemantikája (a szerkeszthető végartefakt, amiből a PDF készül): `{pluginRoot}/references/company-schema.md`.
A `to_docx`-ra csak akkor keress jelöltet, ha a korpusz `visual_identity.formats` mezőjében docx megfigyelt —
alkalmas jelölt az, ami Word-dokumentumot ír vagy szerkeszt, formázás-őrzéssel.

---

Két külön forrásból derül ki, mi hívható — **nézd meg mindkettőt**.

**a) Lemez.** Egy skill mindig `skills/<név>/SKILL.md`; a fölötte lévő szintek száma viszont telepítési
módonként más (felhasználói skill, plugin-gyökér, verziózott plugin-cache), és a szintszám verziónként
változik. Ezért **mélységgel keress, ne rögzített szintszámú globbal**, és **kövesd a symlinkeket**
(`-L`) — ezek az útvonalak jellemzően azok:

```bash
for root in ~/.claude/skills ~/.claude/plugins .claude/skills .claude/plugins; do
  [ -e "$root" ] && find -L "$root" -maxdepth 7 -type f -name SKILL.md 2>/dev/null
done | sed 's#/SKILL\.md$##' | sort -u
```

**b) Futásidő.** A harness által kiszolgált skillek egyetlen ilyen útvonalon sincsenek rajta, mégis
hívhatók. Ezeket a **saját, futásidejű skill-listádból** vedd. Ami csak ott van meg, az is érvényes
jelölt — de jelöld meg, hogy fájlrendszer-szinten nem található.

**A jelenlét nem alkalmasság.** Slotba csak olyan skill kerül, ami a leírása szerint tényleg
ajánlat-dokumentumot állít elő, lektorál vagy PDF-be visz; a névhasonlóság (pl. „house style" a nevében)
nem elég, és egy deck- vagy UI-célú skill nem ajánlat-renderelő. Több jelöltnél vagy kétes szerepnél
kérdezz rá (interjú van úgyis). Amit nem talál, arról egy sor: mi hiányzik, mivel telepíthető.

**Nulla beégetett default.** Ha egy slotra nincs alkalmas jelölt, az `none` — ez nem hiba, az `assemble`
ilyenkor markdown mastert ad.

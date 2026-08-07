#!/usr/bin/env bash
# Skill-higiénia validátor. Exit 1, ha bármelyik szabály sérül.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

for f in "$ROOT"/.claude-plugin/*.json; do
  [ -e "$f" ] || continue
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    echo "OK   $f"
  else
    echo "FAIL $f: érvénytelen JSON"; fail=1
  fi
done

for d in "$ROOT"/skills/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  f="$d/SKILL.md"
  if [ ! -f "$f" ]; then echo "FAIL $d: nincs SKILL.md"; fail=1; continue; fi

  # Frontmatter-ellenőrzés: valódi YAML-parserrel (PyYAML), ha elérhető;
  # ha nincs telepítve, toleráns szöveges fallback egy jelzéssel a kimenetben.
  # Idézőjeles ÉS idézőjel nélküli YAML scalarokat egyaránt elfogad.
  fm_out="$(python3 - "$f" "$name" <<'PYEOF'
import re
import sys

path, expected_name = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    text = fh.read()
lines = text.splitlines()

if not lines or lines[0].strip() != "---":
    print(f"FAIL {path}: nincs frontmatter (nem '---'-tal kezdődik)")
    sys.exit(1)

end = None
for i, line in enumerate(lines[1:], start=1):
    if line.strip() == "---":
        end = i
        break
if end is None:
    print(f"FAIL {path}: frontmatter nincs lezárva ('---')")
    sys.exit(1)

fm_text = "\n".join(lines[1:end])
note = ""
data = None

try:
    import yaml
    try:
        data = yaml.safe_load(fm_text)
    except yaml.YAMLError as e:
        msg = str(e).splitlines()[0]
        print(f"FAIL {path}: érvénytelen YAML frontmatter: {msg}")
        sys.exit(1)
    if not isinstance(data, dict):
        print(f"FAIL {path}: a frontmatter nem YAML dict (kulcs: érték párok)")
        sys.exit(1)
except ImportError:
    note = " [FALLBACK: PyYAML nem elérhető, szöveges közelítő ellenőrzés futott]"
    data = {}
    for line in fm_text.splitlines():
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_-]*):\s?(.*)$', line)
        if not m:
            continue
        key, val = m.group(1), m.group(2).strip()
        if len(val) >= 2 and val[0] == val[-1] and val[0] in ('"', "'"):
            val = val[1:-1]
        data[key] = val

fm_name = str(data.get("name", ""))
if fm_name != expected_name:
    print(f"FAIL {path}: frontmatter name='{fm_name}' != mappanév '{expected_name}'{note}")
    sys.exit(1)

description = data.get("description", "")
if not isinstance(description, str) or not description.startswith("Use when "):
    shown = description if isinstance(description, str) else repr(description)
    print(f"FAIL {path}: a description nem 'Use when '-nel kezdődik (érték: {shown!r}){note}")
    sys.exit(1)

print(f"__PASS__{note}")
sys.exit(0)
PYEOF
)"
  fm_rc=$?
  if [ $fm_rc -ne 0 ]; then
    echo "$fm_out"; fail=1; continue
  fi
  note="${fm_out#__PASS__}"

  words="$(wc -w < "$f" | tr -d ' ')"
  if [ "$words" -gt 700 ]; then
    echo "FAIL $f: $words szó (max 700)$note"; fail=1; continue
  fi

  echo "OK   $f ($words szó)$note"
done

exit $fail

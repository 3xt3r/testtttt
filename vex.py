#!/usr/bin/env python3
"""
Удаляет из CycloneDX VEX/BOM все уязвимости, чей id начинается
с заданных префиксов (по умолчанию CLSA- и OSV-).

Использование:
    python3 clean_vex.py input.json                 # перезапишет input.json
    python3 clean_vex.py input.json -o output.json  # запишет в новый файл
    python3 clean_vex.py input.json -p CLSA- OSV- GHSA-   # свои префиксы
    python3 clean_vex.py input.json --dry-run       # только показать, что удалится
"""
import argparse
import json
import sys

DEFAULT_PREFIXES = ("CLSA-", "OSV-")


def should_remove(vuln: dict, prefixes: tuple) -> bool:
    vid = str(vuln.get("id", "")).upper()
    return any(vid.startswith(p.upper()) for p in prefixes)


def main() -> int:
    parser = argparse.ArgumentParser(description="Очистка CycloneDX VEX от уязвимостей по префиксу id")
    parser.add_argument("input", help="Входной JSON-файл (CycloneDX VEX)")
    parser.add_argument("-o", "--output", help="Выходной файл (по умолчанию перезаписывается входной)")
    parser.add_argument("-p", "--prefixes", nargs="+", default=list(DEFAULT_PREFIXES),
                        help="Префиксы id для удаления (по умолчанию: CLSA- OSV-)")
    parser.add_argument("--dry-run", action="store_true", help="Ничего не записывать, только показать")
    args = parser.parse_args()

    prefixes = tuple(args.prefixes)

    with open(args.input, "r", encoding="utf-8") as f:
        doc = json.load(f)

    vulns = doc.get("vulnerabilities", [])
    kept, removed = [], []
    for v in vulns:
        (removed if should_remove(v, prefixes) else kept).append(v)

    removed_refs = {v.get("bom-ref") for v in removed if v.get("bom-ref")}

    print(f"Всего уязвимостей: {len(vulns)}")
    print(f"Удалено:           {len(removed)}")
    print(f"Осталось:          {len(kept)}")
    for v in removed:
        print(f"  - {v.get('id')}")

    if args.dry_run:
        return 0

    doc["vulnerabilities"] = kept

    # Если в документе есть ссылки на удалённые уязвимости через bom-ref
    # (например, в dependencies), убираем их тоже, чтобы документ оставался валидным.
    if removed_refs and isinstance(doc.get("dependencies"), list):
        new_deps = []
        for dep in doc["dependencies"]:
            if dep.get("ref") in removed_refs:
                continue
            if "dependsOn" in dep:
                dep["dependsOn"] = [r for r in dep["dependsOn"] if r not in removed_refs]
            new_deps.append(dep)
        doc["dependencies"] = new_deps

    out_path = args.output or args.input
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"Результат записан в {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

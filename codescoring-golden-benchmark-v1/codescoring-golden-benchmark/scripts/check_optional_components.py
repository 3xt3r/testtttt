#!/usr/bin/env python3
import argparse, csv, json, re
from pathlib import Path

def canon(s): return re.sub(r"[-_.]+", "-", (s or "").lower())
def version_eq(a,b): return a==b or (a.startswith('v') and a[1:]==b) or (b.startswith('v') and b[1:]==a)
def cname(c):
    name=c.get('name','') or ''
    group=c.get('group','') or ''
    purl=c.get('purl','') or ''
    if purl.startswith('pkg:maven/') and group: return f'{group}:{name}'
    return name

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--bom', type=Path, required=True)
    ap.add_argument('--expected', type=Path, required=True)
    args=ap.parse_args()
    data=json.loads(args.bom.read_text(encoding='utf-8'))
    comps=[(canon(cname(c)), str(c.get('version','') or '')) for c in data.get('components',[])]
    bad=0
    with args.expected.open(newline='',encoding='utf-8') as f:
        rows=list(csv.DictReader(f))
    for r in rows:
        ok=any(n==canon(r['name']) and version_eq(v,r['version']) for n,v in comps)
        print(f"{r['name']}@{r['version']}: {'PASS' if ok else 'FAIL'}")
        bad += 0 if ok else 1
    raise SystemExit(1 if bad else 0)
if __name__=='__main__': main()

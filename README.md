# CodeScoring / Johnny Golden Benchmark v1

Небольшой воспроизводимый benchmark для проверки качества SCA в CodeScoring/Johnny.

## Что проверяет

1. Поиск компонентов из manifest/lock/dependency-tree файлов.
2. Корректность name/version/PURL.
3. Direct vs transitive dependencies.
4. Target-CVE assertions: конкретная CVE должна находиться на vulnerable fixture и не должна находиться на fixed fixture.
5. Archive scanning и direct inclusion по hash.
6. Docker image scanning (OS packages + language packages).
7. C/C++: Conan manifest + отдельный build-scan fixture.

> Важно: `expected/target_vulnerabilities.csv` — это набор обязательных assertions, а не полный список всех CVE.
> База уязвимостей меняется со временем, поэтому новые дополнительные CVE не считаются false positive автоматически.

## Требования

- Linux
- Johnny CLI
- доступ к вашей on-prem CodeScoring
- Python 3.9+
- для отдельных кейсов: Docker, CMake/GCC, zlib/OpenSSL dev packages
- для `prepare_artifacts.sh`: интернет и `curl`/`npm`

Актуальная документация Johnny на момент подготовки benchmark: версия changelog 2026.35.1.

## Быстрый запуск manifest benchmark

```bash
export JOHNNY=/path/to/johnny
export JOHNNY_API_URL='https://codescoring.example.local'
export JOHNNY_API_TOKEN='YOUR_TOKEN'

./scripts/run_manifest_suite.sh
./scripts/score.sh
```

Каждый fixture сохраняется отдельным CLI project, чтобы vulnerable/fixed версии одного компонента не смешивались.

## Fixtures

| Fixture | Назначение |
|---|---|
| `python-vulnerable` | PyYAML 5.3.1 + requests tree с urllib3 1.26.4 |
| `python-fixed` | PyYAML 5.4 + тот же tree с urllib3 1.26.5 |
| `npm-vulnerable` | lodash 4.17.20 + mkdirp -> minimist 0.0.8 |
| `npm-fixed` | lodash 4.18.0 + mkdirp -> minimist 1.2.6 |
| `go-vulnerable` | golang.org/x/text v0.3.7 |
| `go-fixed` | golang.org/x/text v0.3.8 |
| `maven-vulnerable` | log4j-core 2.14.1 + commons-text 1.9 |
| `maven-fixed` | log4j-core 2.17.1 + commons-text 1.10.0 |
| `conan-cpp` | Conan manifest parsing |
| `hash-and-archives` | JAR/Wheel/NPM direct inclusion and archive scanning |
| `docker` | OS + Python packages inside image |
| `cpp-build` | linked zlib/OpenSSL in actual CMake build |

## Target CVE assertions

Benchmark intentionally checks a few well-bounded historical CVEs:

- PyYAML: CVE-2020-14343 — affected `< 5.4`, patched `5.4`.
- urllib3: CVE-2021-33503 — affected `>=1.25.4,<1.26.5`, patched `1.26.5`.
- lodash: CVE-2021-23337 — affected `<4.17.21`; fixed fixture uses 4.18.0 so it is also beyond newer 2026 fixes.
- minimist: CVE-2021-44906 — affected `<0.2.4` or `>=1.0.0,<1.2.6`; patched `0.2.4`/`1.2.6`.
- golang.org/x/text: CVE-2022-32149 — affected before `v0.3.8`.
- log4j-core: CVE-2021-44228 — 2.14.1 affected; fixed in 2.15.0 for Java 8+, fixed fixture uses 2.17.1.
- commons-text: CVE-2022-42889 — affected before 1.10.0.

## Почему fixed не означает «вообще без CVE»

`fixed` означает только «не затронут указанной target CVE». Например, старые ветки urllib3 получили новые CVE значительно позже. Это нормально: checker оценивает target assertion, а дополнительные findings нужно анализировать отдельно.

## Hash / archive fixture

Сначала подготовьте опубликованные артефакты:

```bash
./scripts/prepare_artifacts.sh
```

Потом:

```bash
./scripts/run_hash_archive.sh
```

`--with-hashes` проверяет direct inclusion. Для чистого hash-only режима можно использовать `--only-hashes`.

## Docker fixture

```bash
./scripts/run_docker.sh
```

Скрипт собирает `codescoring-benchmark:v1` и запускает `johnny scan image`.

## C/C++ build fixture

На Debian/Ubuntu:

```bash
sudo apt-get install -y build-essential cmake zlib1g-dev libssl-dev
sudo -E ./scripts/run_cpp_build.sh
```

Этот тест environment-sensitive. Строгий expected-version для системных библиотек специально не задан.

## Expected data

- `expected/components.csv` — строгие компоненты для manifest fixtures.
- `expected/dependencies.csv` — ключевые dependency edges.
- `expected/target_vulnerabilities.csv` — positive/negative CVE assertions.
- `expected/environment_components.csv` — компоненты, где версия зависит от окружения.
- `expected/archive_components.csv` — ожидаемые находки archive/hash fixture.
- `expected/docker_components.csv` — pinned language packages внутри Docker image.

## Оценка

Для manifest suite основной показатель:

- component recall;
- exact version accuracy;
- PURL accuracy (если Johnny его сформировал);
- missing/extra components;
- ключевые dependency edges.

Не используйте «все дополнительные CVE = FP»: vulnerability feeds изменяются.

## Расширенная оценка

После запуска hash/archive и Docker fixtures:

```bash
./scripts/score_extended.sh
```

Источники и зафиксированные границы CVE находятся в `SOURCES.md`.

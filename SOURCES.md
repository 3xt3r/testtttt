# Benchmark provenance

Baseline checked: 2026-09-21.

## CodeScoring / Johnny

- Supported ecosystems, manifest formats, archive formats, hash search and C/C++ build scanning:
  https://docs.codescoring.ru/en/functionality/supported-package-managers
- Johnny scan command and CycloneDX output:
  https://docs.codescoring.ru/en/user-guide/agent/scan
- Docker image scanning:
  https://docs.codescoring.ru/en/user-guide/agent/scan-docker
- C/C++ build scanning / eBPF:
  https://docs.codescoring.ru/en/user-guide/agent/scan-build
- Johnny changelog:
  https://docs.codescoring.ru/en/changelog/johnny-changelog

## Target vulnerability boundaries

- PyYAML / CVE-2020-14343:
  https://github.com/advisories/GHSA-8q59-q68h-6hv4
- urllib3 / CVE-2021-33503:
  https://nvd.nist.gov/vuln/detail/CVE-2021-33503
- lodash / CVE-2021-23337:
  https://github.com/advisories/GHSA-35jh-r3h4-6jhm
- minimist / CVE-2021-44906:
  https://github.com/advisories/GHSA-xvch-5gv4-984h
- golang.org/x/text / CVE-2022-32149:
  https://pkg.go.dev/vuln/GO-2022-1059
- Log4j Core / CVE-2021-44228:
  https://logging.apache.org/security.html
- Apache Commons Text / CVE-2022-42889:
  https://commons.apache.org/proper/commons-text/security.html

## Dependency facts used by fixtures

- Commons Text 1.9 -> commons-lang3 3.11:
  https://central.sonatype.com/artifact/org.apache.commons/commons-text/1.9
- Log4j Core 2.14.1 -> Log4j API:
  https://central.sonatype.com/artifact/org.apache.logging.log4j/log4j-core/2.14.1

The benchmark uses target assertions instead of pretending that vulnerability databases are immutable.

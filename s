~/.cache/oss_checks/sqlite/registry_versions.db
~/.cache/oss_checks/vcs_tag_urls.db
cpluschecks/fingerprints.sqlite

Для начала можно посмотреть, какие вообще таблицы есть:
sqlite3 ~/.cache/oss_checks/sqlite/registry_versions.db ".tables"

Для registry_versions.db у тебя таблица:
registry_versions

Посмотреть структуру:
sqlite3 ~/.cache/oss_checks/sqlite/registry_versions.db ".schema registry_versions"

Посмотреть первые записи:
sqlite3 -header -column ~/.cache/oss_checks/sqlite/registry_versions.db \
'SELECT * FROM registry_versions LIMIT 20;'

Там будут примерно поля:
ecosystem
package
value_json
fetched_at

Например можно проверить конкретный PyPI-пакет:
sqlite3 -header -column ~/.cache/oss_checks/sqlite/registry_versions.db \
"SELECT ecosystem, package, value_json FROM registry_versions WHERE package='cssselect';"

value_json содержит список найденных версий и reason.
Для кэша Git/VCS:
sqlite3 ~/.cache/oss_checks/vcs_tag_urls.db ".tables"

У тебя там как минимум:
vcs_tag_urls
nuget_source_repo

Посмотреть содержимое:
sqlite3 -header -column ~/.cache/oss_checks/vcs_tag_urls.db \
'SELECT * FROM vcs_tag_urls LIMIT 20;'

Например конкретный репозиторий:
sqlite3 -header -column ~/.cache/oss_checks/vcs_tag_urls.db \
"SELECT * FROM vcs_tag_urls WHERE repo_url LIKE '%galera%';"

Или:
sqlite3 -header -column ~/.cache/oss_checks/vcs_tag_urls.db \
"SELECT * FROM vcs_tag_urls WHERE repo_url LIKE '%libsmi%';"

У этой таблицы ключ:
repo_url
version

а найденный URL тега хранится в:
value_json

Если тег не нашёлся, там вполне может лежать пустое значение — отрицательный результат тоже кэшируется.
Для твоей C/C++ fingerprint DB:
sqlite3 cpluschecks/fingerprints.sqlite ".tables"

Это уже не простой TTL-кэш, там несколько таблиц. Полезно сначала:
sqlite3 cpluschecks/fingerprints.sqlite ".schema"

И посмотреть metadata:
sqlite3 -header -column cpluschecks/fingerprints.sqlite \
'SELECT * FROM meta;'

Например количество компонентов:
sqlite3 cpluschecks/fingerprints.sqlite \
"SELECT value FROM meta WHERE key='component_count';"

Посмотреть компоненты, по которым есть fingerprints:
sqlite3 -header -column cpluschecks/fingerprints.sqlite \
'SELECT DISTINCT component FROM segments ORDER BY component LIMIT 100;'

Посмотреть fingerprints конкретной библиотеки:
sqlite3 -header -column cpluschecks/fingerprints.sqlite \
"SELECT component, source_label, kind, source_path, exact_hash, normalized_hash
 FROM segments
 WHERE component='openssl'
 LIMIT 20;"

Очень удобная универсальная последовательность для любой .db:
sqlite3 database.db

а внутри:
.tables
.schema
.headers on
.mode column
SELECT * FROM имя_таблицы LIMIT 20;

Выход:
.quit

Если хочешь увидеть все SQLite-базы, которые у тебя реально уже созданы, можно выполнить:
find ~/.cache/oss_checks . -type f \
  \( -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" \) \
  -print 2>/dev/null

И ещё полезная команда, которая для каждой базы покажет таблицы:
find ~/.cache/oss_checks . -type f \
  \( -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" \) \
  -print0 2>/dev/null |
while IFS= read -r -d '' db; do
    echo "===== $db ====="
    sqlite3 "$db" ".tables"
done

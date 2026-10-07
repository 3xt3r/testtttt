# C# benchmark: csproj without lock file

Цель кейса — проверить обнаружение NuGet-зависимостей непосредственно из `.csproj`
без `packages.lock.json`.

## Зависимости

- Newtonsoft.Json 12.0.3
- Serilog 2.10.0
- YamlDotNet 11.2.1

## Важно

В каталоге намеренно отсутствует `packages.lock.json`.

Обычный запуск:

```bash
dotnet restore
dotnet build
dotnet run
```

`dotnet restore` по умолчанию создаст `obj/project.assets.json`, но не создаст
`packages.lock.json`, пока lock-файл явно не включён через `RestorePackagesWithLockFile`
или `--use-lock-file`.

## Что проверять сканером

1. Находит ли зависимости только по `BenchmarkCsprojNoLock.csproj`.
2. Правильно ли определяет версии.
3. Формирует ли NuGet PURL.
4. Отделяет ли прямые зависимости от транзитивных после `dotnet restore`.
5. Меняется ли результат до и после появления `obj/project.assets.json`.

## Ожидаемые прямые компоненты

- pkg:nuget/Newtonsoft.Json@12.0.3
- pkg:nuget/Serilog@2.10.0
- pkg:nuget/YamlDotNet@11.2.1

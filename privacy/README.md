# Privacy policies

Шаблонизированный генератор политик конфиденциальности для приложений в Google Play / App Store.

## Как добавить политику для нового проекта

1. Создай папку `privacy/<slug>/` (например, `privacy/my-cool-game/`).
2. Положи в неё `project.json`:

   ```json
   {
     "appName": "My Cool Game",
     "developer": "My Studio",
     "email": "contact@example.com",
     "effectiveDate": "2026-05-01",
     "lastUpdated": "2026-05-01",
     "audience": "general",
     "sdks": ["yandex-ads", "admob"]
   }
   ```

3. Запусти из этой папки:

   ```powershell
   .\New-Policy.ps1 -Project my-cool-game
   ```

4. Сделай `git add`, `commit`, `push`. Через ~1 минуту политика будет доступна по адресам:
   - `https://striker1238.github.io/privacy/<slug>/ru.html`
   - `https://striker1238.github.io/privacy/<slug>/en.html`

5. Вставь URL в Google Play Console → Контент приложения → Политика конфиденциальности.

## Поля project.json

| Поле | Обязательное | Описание |
|------|--------------|----------|
| `appName` | да | Название приложения как в сторе |
| `developer` | да | Имя/ник разработчика |
| `email` | да | Контактный e-mail |
| `effectiveDate` | да | Дата вступления в силу (YYYY-MM-DD) |
| `lastUpdated` | нет | Дата последнего обновления (по умолчанию — сегодня) |
| `audience` | нет | `general` (>=13 лет) или `family` (Designed for Families) |
| `sdks` | нет | Список SDK (имена сниппетов из `templates/sdk-snippets/`) |

## Доступные SDK-сниппеты

| Имя | Что включает |
|-----|--------------|
| `yandex-ads` | Yandex Mobile Ads |
| `admob` | Google AdMob |
| `firebase-analytics` | Google Firebase Analytics |

## Добавить новый SDK

1. Создай два файла:
   - `templates/sdk-snippets/<sdk-name>.ru.md`
   - `templates/sdk-snippets/<sdk-name>.en.md`
2. Опиши в каждом: что собирает, ссылки на политики/условия.
3. Используй имя `<sdk-name>` в `sdks` массиве `project.json`.

## Структура

```
privacy/
├── README.md                    — этот файл
├── New-Policy.ps1               — генератор
├── index.md                     — лендинг со списком политик
├── templates/
│   ├── policy.ru.md             — RU-шаблон
│   ├── policy.en.md             — EN-шаблон
│   ├── sdk-snippets/            — описания SDK
│   └── kids-snippets/           — блоки про детей (general / family)
└── <slug>/
    ├── project.json             — конфиг проекта (исходник)
    ├── ru.md                    — сгенерированная RU-политика
    └── en.md                    — сгенерированная EN-политика
```

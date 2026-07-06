# Git Cheat

Веб-шпаргалка по командам Git с поиском и фильтрацией по категориям. Быстрое нахождение нужной команды, просмотр синтаксиса, флагов и примеры использования.

**Живой сайт:** 

## Возможности

- Поиск команд по названию
- Фильтрация по категориям (основы, ветки, удалённые, откат, stash, конфигурация)
- Детальная страница каждой команды: синтаксис, частые флаги, примеры, предупреждения
- Адаптивная вёрстка для десктопа, планшетов и телефонов

## Стек

- **Vue 3** - Frontend
- **HTML/CSS** - Базовая вёрстка
- **Vue Router** — Маршрутизация
- **Supabase (PostgreSQL)** — База данных команд
- **Vite** — Сборка

## Запуск локально

```bash
git clone https://github.com/login/git-cheat.git
cd git-cheat
npm install
```

Создайте файл `.env` в корне:

```js
VITE_SUPABASE_URL=твой_project_url
VITE_SUPABASE_ANON_KEY=твой_publishable_key
```

Запустите:

```bash
npm run dev
```

## Структура

- `src/pages/HomePage.vue` — главная: поиск, категории, список команд
- `src/pages/CommandPage.vue` — страница команды с деталями
- `src/components/CommandCard.vue` — карточка команды
- `src/lib/supabase.js` — клиент Supabase
- `src/router/` — маршруты


# Git Cheat

Веб-шпаргалка для разработчика с поиском и фильтрацией по категориям и разделам. Быстрое нахождение нужной команды, просмотр синтаксиса, флагов и примеры использования.

**Рабочий сайт:** https://git-cheat-sigma.vercel.app

## Возможности

- Поиск команд по названию
- Фильтрация по категориям (основы, ветки, удалённые, откат, stash, конфигурация)
- Команды по разделам (Git, SQL, Alembic, Docker, Pytest, Vitest, Jest)
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
git clone https://github.com/vulkan790/GitCheat.git
npm install
```

Создайте файл `.env` в корне:

```js
VITE_SUPABASE_URL=ваш_project_url
VITE_SUPABASE_ANON_KEY=ваш_publishable_key
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

# Git Cheat

A web-based cheat sheet for developers with search and category filtering. Quickly find the command you need and view its syntax, flags, and usage examples.

**Live site:** https://git-cheat-sigma.vercel.app

## Features

- Search commands by name
- Filter by category (basics, branching, remote, undo, stash, config)
- Commands by section (Git, SQL, Alembic, Docker, Pytest, Vitest, Jest)
- Detailed page for each command: syntax, common flags, examples, warnings
- Responsive layout for desktop, tablet, and mobile

## Stack

- **Vue 3** — Frontend
- **HTML/CSS** — Base styling
- **Vue Router** — Routing
- **Supabase (PostgreSQL)** — Command database
- **Vite** — Build tool

## Running locally

```bash
git clone https://github.com/vulkan790/GitCheat.git
cd GitCheat
npm install
```

Create a `.env` file in the root:

```
VITE_SUPABASE_URL=your_project_url
VITE_SUPABASE_ANON_KEY=your_publishable_key
```

Start the dev server:

```bash
npm run dev
```

## Structure

- `src/pages/HomePage.vue` — home: search, categories, command list
- `src/pages/CommandPage.vue` — command detail page
- `src/components/CommandCard.vue` — command card
- `src/lib/supabase.js` — Supabase client
- `src/router/` — routes

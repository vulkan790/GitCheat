DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS commands CASCADE;
DROP TABLE IF EXISTS flags CASCADE;
DROP TABLE IF EXISTS examples CASCADE;
DROP TABLE IF EXISTS topics CASCADE;

CREATE TABLE topics (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL,
  slug text NOT NULL UNIQUE
);

CREATE TABLE categories (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  topic_id bigint references topics(id)
);

CREATE TABLE commands (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  category_id bigint references categories(id),
  description text,
  syntax text,
  warning text
);

CREATE TABLE flags (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  command_id bigint references commands(id) ON DELETE CASCADE,
  flag text NOT NULL,
  description text
);

CREATE TABLE examples (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  command_id bigint references commands(id) ON DELETE CASCADE,
  code text NOT NULL,
  description text
);

DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text,
  age int,
  city text,
  email text,
  login text
);

CREATE TABLE orders (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id bigint references users(id),
  total numeric,
  status text
);

INSERT INTO users (name, age, city, email, login) VALUES
  ('Иван', 30, 'Москва', 'ivan@mail.com', 'ivan'),
  ('Анна', 25, 'Казань', 'anna@mail.com', 'anna'),
  ('Пётр', 17, 'Москва', 'petr@mail.com', 'petr');

INSERT INTO orders (user_id, total, status) VALUES
  (1, 1200, 'paid'),
  (1, 800, 'cancelled'),
  (2, 500, 'paid');

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "read users" ON users FOR SELECT USING (TRUE);
CREATE POLICY "read orders" ON orders FOR SELECT USING (TRUE);

INSERT INTO topics (name, slug) VALUES
  ('Git', 'git'),
  ('SQL', 'sql'),
  ('Alembic', 'alembic'),
  ('Docker', 'docker'),
  ('pytest', 'pytest'),
  ('Vue', 'vue'),
  ('React', 'react')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO categories (name, slug) VALUES
  ('Основы', 'basics'),
  ('Ветки', 'branching'),
  ('Удалённые', 'remote'),
  ('Откат изменений', 'undo'),
  ('Stash', 'stash'),
  ('Конфигурация', 'config'),
  ('Инспекция', 'inspect'),
  ('Теги', 'tags'),
  ('Продвинутое', 'advanced')
ON conflict (slug) DO nothing;

UPDATE categories SET topic_id = (SELECT id FROM topics WHERE slug = 'git') WHERE topic_id IS NULL;

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git init', 'init', (SELECT id FROM categories WHERE slug = 'basics'), 'Создаёт новый пустой репозиторий в текущей папке — появляется скрытая директория .git, где хранится вся история. С этой команды начинается работа с проектом.', 'git init [<папка>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'init'), '--bare', 'Создать репозиторий без рабочей копии (обычно для серверов)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='init'), 'git init', 'Инициализировать репозиторий в текущей папке'),
  ((SELECT id FROM commands WHERE slug='init'), 'git init my-project', 'Создать папку my-project и репозиторий внутри');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git add', 'add', (SELECT id FROM categories WHERE slug = 'basics'), 'Добавляет изменения из рабочей копии в индекс (staging area), готовя их к коммиту.', 'git add [<опции>] <файл>...', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'add'), '-A', 'Добавить все изменения: новые, изменённые и удалённые'),
  ((SELECT id FROM commands WHERE slug = 'add'), '-p', 'Выбирать изменения по частям (интерактивно)'),
  ((SELECT id FROM commands WHERE slug = 'add'), '.', 'Добавить всё в текущей папке и вложенных');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='add'), 'git add index.html', 'Добавить один файл'),
  ((SELECT id FROM commands WHERE slug='add'), 'git add .', 'Добавить всё в текущей папке');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git status', 'status', (SELECT id FROM categories WHERE slug = 'basics'), 'Показывает состояние рабочей директории и индекса: какие файлы изменены, какие добавлены в staging, какие не отслеживаются.', 'git status [-s]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'status'), '-s', 'Краткий формат вывода (одна строка на файл)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='status'), 'git status -s', 'Компактный вид состояния');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git commit', 'commit', (SELECT id FROM categories WHERE slug = 'basics'), 'Сохраняет изменения из индекса (staging area) в историю репозитория, создавая новый коммит с уникальным идентификатором.', 'git commit [-m "сообщение"] [--amend]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'commit'), '-m', 'Задать сообщение коммита прямо в команде, без открытия редактора'),
  ((SELECT id FROM commands WHERE slug = 'commit'), '-a', 'Автоматически добавить в коммит все отслеживаемые изменённые файлы'),
  ((SELECT id FROM commands WHERE slug = 'commit'), '--amend', 'Изменить последний коммит вместо создания нового');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='commit'), 'git commit -m "Добавил форму входа"', 'Обычный коммит с сообщением'),
  ((SELECT id FROM commands WHERE slug='commit'), 'git commit --amend -m "Новое сообщение"', 'Переписать сообщение последнего коммита');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git log', 'log', (SELECT id FROM categories WHERE slug = 'basics'), 'Показывает историю коммитов текущей ветки: автор, дата, сообщение и хеш каждого коммита.', 'git log [--oneline] [--graph]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'log'), '--oneline', 'Краткий вид: один коммит в одну строку'),
  ((SELECT id FROM commands WHERE slug = 'log'), '--graph', 'Рисует дерево веток псевдографикой');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='log'), 'git log --oneline --graph', 'Компактная история с ветвлением');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git rm', 'rm', (SELECT id FROM categories WHERE slug = 'basics'), 'Удаляет файлы из рабочей копии и из индекса, чтобы удаление попало в следующий коммит.', 'git rm [--cached] <файл>...', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'rm'), '--cached', 'Убрать файл из-под контроля Git, но оставить его на диске'),
  ((SELECT id FROM commands WHERE slug = 'rm'), '-r', 'Рекурсивно удалить папку со всем содержимым');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='rm'), 'git rm old.txt', 'Удалить файл и зафиксировать удаление'),
  ((SELECT id FROM commands WHERE slug='rm'), 'git rm --cached .env', 'Перестать отслеживать .env, не удаляя его с диска');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git mv', 'mv', (SELECT id FROM categories WHERE slug = 'basics'), 'Переименовывает или перемещает файл и сразу фиксирует это изменение в индексе (по сути rm + add одной командой).', 'git mv <источник> <назначение>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'mv'), '-f', 'Перезаписать назначение, если такой файл уже существует');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='mv'), 'git mv old.js new.js', 'Переименовать файл'),
  ((SELECT id FROM commands WHERE slug='mv'), 'git mv style.css assets/style.css', 'Переместить файл в папку assets');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git branch', 'branch', (SELECT id FROM categories WHERE slug = 'branching'), 'Управляет ветками: показывает список, создаёт новые и удаляет существующие.', 'git branch [<имя>] [-d | -D]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'branch'), '-d', 'Удалить ветку (только если она слита)'),
  ((SELECT id FROM commands WHERE slug = 'branch'), '-D', 'Принудительно удалить ветку, даже если не слита');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='branch'), 'git branch feature-login', 'Создать ветку feature-login'),
  ((SELECT id FROM commands WHERE slug='branch'), 'git branch -d old-feature', 'Удалить слитую ветку');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git checkout', 'checkout', (SELECT id FROM categories WHERE slug = 'branching'), 'Переключает ветки и восстанавливает файлы. Старая универсальная команда, которую сейчас частично заменяют switch (для веток) и restore (для файлов).', 'git checkout [-b] <ветка | файл>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'checkout'), '-b', 'Создать новую ветку и сразу переключиться на неё'),
  ((SELECT id FROM commands WHERE slug = 'checkout'), '--', 'Отменить изменения в файле, вернув его версию из индекса');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='checkout'), 'git checkout main', 'Перейти на ветку main'),
  ((SELECT id FROM commands WHERE slug='checkout'), 'git checkout -b feature-x', 'Создать ветку feature-x и перейти на неё');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git switch', 'switch', (SELECT id FROM categories WHERE slug = 'branching'), 'Переключается между ветками. Современная и более понятная замена git checkout для работы с ветками.', 'git switch [-c] <ветка>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'switch'), '-c', 'Создать новую ветку и сразу переключиться на неё');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='switch'), 'git switch main', 'Перейти на ветку main'),
  ((SELECT id FROM commands WHERE slug='switch'), 'git switch -c feature-x', 'Создать feature-x и перейти');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git merge', 'merge', (SELECT id FROM categories WHERE slug = 'branching'), 'Вливает изменения из указанной ветки в текущую, создавая коммит слияния при необходимости.', 'git merge <ветка> [--abort]', 'При конфликтах слияние остановится — их нужно разрешить вручную перед завершением.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'merge'), '--abort', 'Отменить слияние и вернуть всё как было до него');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='merge'), 'git merge feature-login', 'Влить ветку feature-login в текущую');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git rebase', 'rebase', (SELECT id FROM categories WHERE slug = 'branching'), 'Переносит коммиты текущей ветки поверх другой, делая историю линейной вместо коммита слияния.', 'git rebase [-i] <ветка>', 'Rebase переписывает историю (меняет хеши коммитов). Не применяйте к уже опубликованным веткам, которыми пользуются другие.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'rebase'), '-i', 'Интерактивно: менять порядок, объединять и править коммиты'),
  ((SELECT id FROM commands WHERE slug = 'rebase'), '--abort', 'Прервать rebase и вернуть ветку в исходное состояние'),
  ((SELECT id FROM commands WHERE slug = 'rebase'), '--continue', 'Продолжить после разрешения конфликтов');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='rebase'), 'git rebase main', 'Перенести коммиты текущей ветки поверх main'),
  ((SELECT id FROM commands WHERE slug='rebase'), 'git rebase -i HEAD~3', 'Интерактивно переписать последние 3 коммита');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git cherry-pick', 'cherry-pick', (SELECT id FROM categories WHERE slug = 'branching'), 'Применяет один или несколько конкретных коммитов из другой ветки к текущей, создавая их копии.', 'git cherry-pick <commit>...', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'cherry-pick'), '-n', 'Применить изменения, но не создавать коммит автоматически'),
  ((SELECT id FROM commands WHERE slug = 'cherry-pick'), '--abort', 'Отменить cherry-pick при конфликте');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='cherry-pick'), 'git cherry-pick a1b2c3d', 'Перенести один коммит по его хешу'),
  ((SELECT id FROM commands WHERE slug='cherry-pick'), 'git cherry-pick main~2', 'Взять конкретный коммит из ветки main');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git clone', 'clone', (SELECT id FROM categories WHERE slug = 'remote'), 'Копирует удалённый репозиторий целиком (со всей историей) на локальную машину и сразу настраивает связь с origin.', 'git clone <url> [<папка>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'clone'), '--depth', 'Скачать только последние N коммитов (поверхностное клонирование)'),
  ((SELECT id FROM commands WHERE slug = 'clone'), '-b', 'Склонировать и сразу переключиться на указанную ветку');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='clone'), 'git clone https://github.com/user/repo.git', 'Склонировать репозиторий'),
  ((SELECT id FROM commands WHERE slug='clone'), 'git clone --depth 1 <url>', 'Быстрое клонирование только последнего коммита');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git remote', 'remote', (SELECT id FROM categories WHERE slug = 'remote'), 'Управляет списком удалённых репозиториев: показывает, добавляет, переименовывает и удаляет их.', 'git remote [add | remove | rename] [<имя>] [<url>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'remote'), '-v', 'Показать список удалённых репозиториев с их URL'),
  ((SELECT id FROM commands WHERE slug = 'remote'), 'add', 'Добавить новый удалённый репозиторий'),
  ((SELECT id FROM commands WHERE slug = 'remote'), 'remove', 'Удалить удалённый репозиторий');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='remote'), 'git remote -v', 'Посмотреть все привязанные репозитории'),
  ((SELECT id FROM commands WHERE slug='remote'), 'git remote add origin <url>', 'Привязать удалённый репозиторий под именем origin');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git fetch', 'fetch', (SELECT id FROM categories WHERE slug = 'remote'), 'Скачивает новые коммиты и ветки с удалённого репозитория, но НЕ вливает их в рабочую ветку — в этом отличие от pull.', 'git fetch [<remote>] [<ветка>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'fetch'), '--all', 'Скачать изменения со всех удалённых репозиториев'),
  ((SELECT id FROM commands WHERE slug = 'fetch'), '-p', 'Удалить локальные ссылки на ветки, которых больше нет на сервере');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='fetch'), 'git fetch origin', 'Забрать изменения с origin без слияния'),
  ((SELECT id FROM commands WHERE slug='fetch'), 'git fetch -p', 'Скачать обновления и подчистить удалённые ветки');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git pull', 'pull', (SELECT id FROM categories WHERE slug = 'remote'), 'Загружает изменения с удалённого репозитория и сразу вливает их в текущую ветку (fetch + merge).', 'git pull [origin <ветка>]', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='pull'), 'git pull origin main', 'Забрать и влить изменения из main');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git push', 'push', (SELECT id FROM categories WHERE slug = 'remote'), 'Отправляет локальные коммиты на удалённый репозиторий.', 'git push [-u origin <ветка>] [--force]', 'git push --force перезаписывает историю на сервере и может стереть чужие коммиты. На общих ветках используйте с крайней осторожностью.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'push'), '-u', 'Установить отслеживание ветки, чтобы дальше хватало просто git push'),
  ((SELECT id FROM commands WHERE slug = 'push'), '--force', 'Принудительно перезаписать историю на сервере');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='push'), 'git push -u origin feature-x', 'Отправить ветку и связать с origin'),
  ((SELECT id FROM commands WHERE slug='push'), 'git push', 'Отправить коммиты в уже связанную ветку');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git reset', 'reset', (SELECT id FROM categories WHERE slug = 'undo'), 'Перемещает HEAD на указанный коммит. В зависимости от флага меняет индекс и рабочую копию — используется для отмены коммитов и очистки staging.', 'git reset [--soft | --hard] <commit>', 'Флаг --hard безвозвратно удаляет незакоммиченные изменения. Убедитесь, что ничего важного не потеряете.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'reset'), '--soft', 'Сдвинуть HEAD, изменения остаются в индексе'),
  ((SELECT id FROM commands WHERE slug = 'reset'), '--hard', 'Откатить всё: и индекс, и рабочую копию (изменения теряются)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='reset'), 'git reset --soft HEAD~1', 'Отменить последний коммит, сохранив правки'),
  ((SELECT id FROM commands WHERE slug='reset'), 'git reset --hard HEAD~1', 'Полностью откатить последний коммит');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git restore', 'restore', (SELECT id FROM categories WHERE slug = 'undo'), 'Восстанавливает файлы в рабочей копии или убирает их из индекса.', 'git restore [--staged] <файл>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'restore'), '--staged', 'Убрать файл из индекса, не трогая сами изменения');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='restore'), 'git restore index.html', 'Отменить изменения в файле'),
  ((SELECT id FROM commands WHERE slug='restore'), 'git restore --staged index.html', 'Убрать файл из staging');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git revert', 'revert', (SELECT id FROM categories WHERE slug = 'undo'), 'Отменяет указанный коммит, создавая новый коммит с обратными изменениями. Безопасен для общей истории, так как ничего не переписывает.', 'git revert <commit>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'revert'), '-n', 'Внести обратные изменения, но не создавать коммит сразу');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='revert'), 'git revert a1b2c3d', 'Отменить конкретный коммит новым коммитом'),
  ((SELECT id FROM commands WHERE slug='revert'), 'git revert HEAD', 'Откатить последний коммит');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git clean', 'clean', (SELECT id FROM categories WHERE slug = 'undo'), 'Удаляет неотслеживаемые файлы и папки из рабочей директории.', 'git clean [-n | -f] [-d]', 'git clean -f безвозвратно удаляет файлы, которых нет в Git. Сначала запустите с -n, чтобы увидеть, что именно будет удалено.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'clean'), '-n', 'Показать, что будет удалено, ничего не удаляя (пробный прогон)'),
  ((SELECT id FROM commands WHERE slug = 'clean'), '-f', 'Выполнить удаление (без этого флага clean не сработает)'),
  ((SELECT id FROM commands WHERE slug = 'clean'), '-d', 'Удалять также неотслеживаемые папки');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='clean'), 'git clean -n', 'Посмотреть список файлов на удаление'),
  ((SELECT id FROM commands WHERE slug='clean'), 'git clean -fd', 'Удалить все неотслеживаемые файлы и папки');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git reflog', 'reflog', (SELECT id FROM categories WHERE slug = 'undo'), 'Показывает журнал всех перемещений HEAD — переключений веток, коммитов, сбросов. Главный инструмент, чтобы найти и восстановить потерянные коммиты.', 'git reflog', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='reflog'), 'git reflog', 'Посмотреть историю перемещений HEAD'),
  ((SELECT id FROM commands WHERE slug='reflog'), 'git reset --hard HEAD@{2}', 'Вернуться к состоянию из reflog');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git stash', 'stash', (SELECT id FROM categories WHERE slug = 'stash'), 'Временно прячет незакоммиченные изменения, очищая рабочую копию, чтобы вернуться к ним позже.', 'git stash [pop | list | drop]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'stash'), 'pop', 'Вернуть последние спрятанные изменения и удалить их из стека'),
  ((SELECT id FROM commands WHERE slug = 'stash'), 'list', 'Показать список всех отложенных изменений'),
  ((SELECT id FROM commands WHERE slug = 'stash'), 'apply', 'Применить изменения, оставив их в стеке');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='stash'), 'git stash', 'Спрятать текущие изменения'),
  ((SELECT id FROM commands WHERE slug='stash'), 'git stash pop', 'Вернуть спрятанное обратно');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git config', 'config', (SELECT id FROM categories WHERE slug = 'config'), 'Управляет настройками Git: имя пользователя, email, редактор, алиасы. С флагом --global применяется ко всем репозиториям.', 'git config [--global] <ключ> <значение>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'config'), '--global', 'Применить настройку ко всем репозиториям пользователя'),
  ((SELECT id FROM commands WHERE slug = 'config'), '--list', 'Показать все текущие настройки');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='config'), 'git config --global user.name "Имя"', 'Задать имя пользователя'),
  ((SELECT id FROM commands WHERE slug='config'), 'git config --global user.email "you@mail.com"', 'Задать email');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git diff', 'diff', (SELECT id FROM categories WHERE slug = 'inspect'), 'Показывает построчную разницу между состояниями: рабочей копией, индексом и коммитами.', 'git diff [--staged] [<commit> [<commit>]]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'diff'), '--staged', 'Показать изменения, уже добавленные в индекс (готовые к коммиту)'),
  ((SELECT id FROM commands WHERE slug = 'diff'), '--stat', 'Краткая сводка: сколько строк изменилось в каждом файле');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='diff'), 'git diff', 'Изменения, ещё не добавленные в индекс'),
  ((SELECT id FROM commands WHERE slug='diff'), 'git diff --staged', 'Изменения, уже готовые к коммиту');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git show', 'show', (SELECT id FROM categories WHERE slug = 'inspect'), 'Показывает подробности объекта Git — чаще всего содержимое конкретного коммита вместе с его изменениями.', 'git show [<commit>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'show'), '--stat', 'Показать только список изменённых файлов без содержимого');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='show'), 'git show', 'Показать последний коммит с изменениями'),
  ((SELECT id FROM commands WHERE slug='show'), 'git show a1b2c3d', 'Посмотреть содержимое конкретного коммита');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git blame', 'blame', (SELECT id FROM categories WHERE slug = 'inspect'), 'Показывает, кто и в каком коммите изменил каждую строку файла.', 'git blame <файл>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'blame'), '-L', 'Ограничить вывод определённым диапазоном строк');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='blame'), 'git blame main.js', 'Узнать авторство каждой строки файла'),
  ((SELECT id FROM commands WHERE slug='blame'), 'git blame -L 10,20 main.js', 'Посмотреть авторство строк с 10 по 20');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git grep', 'grep', (SELECT id FROM categories WHERE slug = 'inspect'), 'Быстро ищет текст по файлам репозитория, просматривая только отслеживаемые файлы.', 'git grep <шаблон>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'grep'), '-n', 'Показывать номера строк'),
  ((SELECT id FROM commands WHERE slug = 'grep'), '-i', 'Игнорировать регистр');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='grep'), 'git grep "TODO"', 'Найти все упоминания TODO в коде'),
  ((SELECT id FROM commands WHERE slug='grep'), 'git grep -n useState', 'Найти строки с useState и их номера');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git tag', 'tag', (SELECT id FROM categories WHERE slug = 'tags'), 'Создаёт метки на коммитах — обычно для обозначения версий и релизов. Метки бывают лёгкие и аннотированные.', 'git tag [-a <имя> -m <сообщение>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'tag'), '-a', 'Создать аннотированную метку (с автором, датой и сообщением)'),
  ((SELECT id FROM commands WHERE slug = 'tag'), '-m', 'Задать сообщение для аннотированной метки'),
  ((SELECT id FROM commands WHERE slug = 'tag'), '-d', 'Удалить метку');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='tag'), 'git tag v1.0.0', 'Создать лёгкую метку на текущем коммите'),
  ((SELECT id FROM commands WHERE slug='tag'), 'git tag -a v1.0.0 -m "Первый релиз"', 'Создать аннотированную метку');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git describe', 'describe', (SELECT id FROM categories WHERE slug = 'tags'), 'Формирует человекочитаемое имя коммита на основе ближайшей метки — удобно для версий сборки.', 'git describe [--tags]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'describe'), '--tags', 'Использовать в том числе лёгкие метки, а не только аннотированные');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='describe'), 'git describe --tags', 'Получить имя вида v1.0.0-5-gA1B2C3'),
  ((SELECT id FROM commands WHERE slug='describe'), 'git describe', 'Описать коммит по ближайшей аннотированной метке');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git bisect', 'bisect', (SELECT id FROM categories WHERE slug = 'advanced'), 'Помогает найти коммит, в котором появилась ошибка, с помощью бинарного поиска по истории.', 'git bisect start | good | bad | reset', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'bisect'), 'start', 'Начать поиск проблемного коммита'),
  ((SELECT id FROM commands WHERE slug = 'bisect'), 'good', 'Пометить текущий коммит как рабочий'),
  ((SELECT id FROM commands WHERE slug = 'bisect'), 'bad', 'Пометить текущий коммит как сломанный');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='bisect'), 'git bisect start', 'Запустить поиск проблемного коммита'),
  ((SELECT id FROM commands WHERE slug='bisect'), 'git bisect bad', 'Отметить, что в этом коммите баг уже есть');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git submodule', 'submodule', (SELECT id FROM categories WHERE slug = 'advanced'), 'Подключает один Git-репозиторий внутрь другого как вложенный модуль, сохраняя их истории раздельными.', 'git submodule [add | update | init] [<url>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'submodule'), 'add', 'Добавить новый подмодуль по URL'),
  ((SELECT id FROM commands WHERE slug = 'submodule'), 'update', 'Подтянуть содержимое подмодулей'),
  ((SELECT id FROM commands WHERE slug = 'submodule'), '--init', 'Инициализировать подмодули (например, после клонирования)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='submodule'), 'git submodule add <url> libs/ui', 'Добавить внешний репозиторий как подмодуль'),
  ((SELECT id FROM commands WHERE slug='submodule'), 'git submodule update --init --recursive', 'Инициализировать и загрузить все подмодули');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git worktree', 'worktree', (SELECT id FROM categories WHERE slug = 'advanced'), 'Позволяет держать несколько рабочих директорий для одного репозитория, чтобы работать сразу над разными ветками без переключений.', 'git worktree [add | list | remove] <путь> [<ветка>]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'worktree'), 'add', 'Создать новую рабочую директорию'),
  ((SELECT id FROM commands WHERE slug = 'worktree'), 'list', 'Показать все рабочие директории'),
  ((SELECT id FROM commands WHERE slug = 'worktree'), 'remove', 'Удалить рабочую директорию');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='worktree'), 'git worktree add ../hotfix main', 'Отдельная папка для ветки main'),
  ((SELECT id FROM commands WHERE slug='worktree'), 'git worktree list', 'Посмотреть все рабочие деревья');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git archive', 'archive', (SELECT id FROM categories WHERE slug = 'advanced'), 'Упаковывает содержимое ветки или коммита в архив без служебной папки .git — удобно для выкладки исходников.', 'git archive [--format=zip] <ветка> -o <файл>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'archive'), '--format', 'Формат архива: tar или zip'),
  ((SELECT id FROM commands WHERE slug = 'archive'), '-o', 'Имя выходного файла');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='archive'), 'git archive --format=zip main -o site.zip', 'Собрать zip из ветки main'),
  ((SELECT id FROM commands WHERE slug='archive'), 'git archive HEAD -o snapshot.tar', 'Архив текущего состояния');

INSERT INTO categories (name, slug, topic_id) VALUES
  ('Выборка', 'querying', (SELECT id FROM topics WHERE slug = 'sql')),
  ('Соединения', 'joins', (SELECT id FROM topics WHERE slug = 'sql')),
  ('Агрегация', 'aggregation', (SELECT id FROM topics WHERE slug = 'sql')),
  ('Изменение данных', 'dml', (SELECT id FROM topics WHERE slug = 'sql')),
  ('Определение схемы', 'ddl', (SELECT id FROM topics WHERE slug = 'sql')),
  ('Подзапросы и CTE', 'subqueries', (SELECT id FROM topics WHERE slug = 'sql'));

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('SELECT', 'select', (SELECT id FROM categories WHERE slug = 'querying'), 'Извлекает данные из таблицы: перечисляете нужные столбцы (или * для всех) и таблицу, откуда их взять.', 'SELECT [DISTINCT] столбцы FROM таблица', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'select'), '*', 'Выбрать все столбцы таблицы'),
  ((SELECT id FROM commands WHERE slug = 'select'), 'DISTINCT', 'Убрать повторяющиеся строки из результата'),
  ((SELECT id FROM commands WHERE slug = 'select'), 'AS', 'Задать псевдоним столбцу или таблице');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'select'), 'SELECT id, name FROM users', 'Выбрать два столбца из таблицы users'),
  ((SELECT id FROM commands WHERE slug = 'select'), 'SELECT name AS имя FROM users', 'Выбрать столбец с псевдонимом');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('WHERE', 'where', (SELECT id FROM categories WHERE slug = 'querying'), 'Фильтрует строки по условию — в результат попадают только те, что ему удовлетворяют.', 'SELECT ... FROM таблица WHERE условие', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'where'), 'IN', 'Проверить, входит ли значение в список'),
  ((SELECT id FROM commands WHERE slug = 'where'), 'BETWEEN', 'Проверить попадание в диапазон (включительно)'),
  ((SELECT id FROM commands WHERE slug = 'where'), 'LIKE', 'Поиск по шаблону: % — любые символы, _ — один символ'),
  ((SELECT id FROM commands WHERE slug = 'where'), 'IS NULL', 'Проверить, что значение пустое (NULL)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'where'), 'SELECT * FROM users WHERE age >= 18', 'Пользователи 18 лет и старше'),
  ((SELECT id FROM commands WHERE slug = 'where'), 'SELECT * FROM users WHERE city IN (''Москва'', ''Казань'')', 'Пользователи из двух городов'),
  ((SELECT id FROM commands WHERE slug = 'where'), 'SELECT * FROM users WHERE name LIKE ''А%''', 'Имена, начинающиеся на А');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('ORDER BY', 'order-by', (SELECT id FROM categories WHERE slug = 'querying'), 'Сортирует результат по одному или нескольким столбцам.', 'SELECT ... FROM таблица ORDER BY столбец [ASC | DESC]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'order-by'), 'ASC', 'По возрастанию (значение по умолчанию)'),
  ((SELECT id FROM commands WHERE slug = 'order-by'), 'DESC', 'По убыванию');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'order-by'), 'SELECT * FROM users ORDER BY age DESC', 'Сначала самые старшие'),
  ((SELECT id FROM commands WHERE slug = 'order-by'), 'SELECT * FROM users ORDER BY city, name', 'Сортировка по двум столбцам');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('LIMIT / OFFSET', 'limit', (SELECT id FROM categories WHERE slug = 'querying'), 'LIMIT ограничивает число строк, OFFSET пропускает первые N — вместе дают постраничный вывод.', 'SELECT ... FROM таблица LIMIT n [OFFSET m]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'limit'), 'OFFSET', 'Пропустить первые m строк перед выборкой');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'limit'), 'SELECT * FROM users LIMIT 10', 'Первые 10 строк'),
  ((SELECT id FROM commands WHERE slug = 'limit'), 'SELECT * FROM users LIMIT 10 OFFSET 20', 'Третья страница по 10 записей');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('INNER JOIN', 'inner-join', (SELECT id FROM categories WHERE slug = 'joins'), 'Соединяет строки двух таблиц по условию и оставляет только пары, для которых совпадение нашлось в обеих.', 'SELECT ... FROM a JOIN b ON a.id = b.a_id', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'inner-join'), 'ON', 'Условие соединения таблиц'),
  ((SELECT id FROM commands WHERE slug = 'inner-join'), 'USING', 'Короткая запись, когда столбец связи назван одинаково');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'inner-join'), 'SELECT u.name, o.total FROM users u JOIN orders o ON u.id = o.user_id', 'Пользователи и их заказы');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('LEFT JOIN', 'left-join', (SELECT id FROM categories WHERE slug = 'joins'), 'Возвращает все строки левой таблицы и совпадающие из правой где совпадения нет, столбцы правой будут NULL.', 'SELECT ... FROM a LEFT JOIN b ON a.id = b.a_id', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'left-join'), 'ON', 'Условие соединения таблиц');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'left-join'), 'SELECT u.name, o.id FROM users u LEFT JOIN orders o ON u.id = o.user_id', 'Все пользователи, даже без заказов'),
  ((SELECT id FROM commands WHERE slug = 'left-join'), 'SELECT u.name FROM users u LEFT JOIN orders o ON u.id = o.user_id WHERE o.id IS NULL', 'Пользователи без единого заказа');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('RIGHT / FULL JOIN', 'outer-join', (SELECT id FROM categories WHERE slug = 'joins'), 'RIGHT JOIN — зеркало LEFT: все строки правой таблицы. FULL JOIN — все строки обеих таблиц, с NULL там, где пары нет.', 'SELECT ... FROM a FULL JOIN b ON a.id = b.a_id', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'outer-join'), 'RIGHT JOIN', 'Все строки правой таблицы плюс совпадения из левой'),
  ((SELECT id FROM commands WHERE slug = 'outer-join'), 'FULL JOIN', 'Все строки обеих таблиц');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'outer-join'), 'SELECT * FROM a FULL JOIN b ON a.id = b.a_id', 'Полное внешнее соединение двух таблиц');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('GROUP BY', 'group-by', (SELECT id FROM categories WHERE slug = 'aggregation'), 'Группирует строки с одинаковым значением столбца, чтобы посчитать агрегаты по каждой группе. HAVING фильтрует сами группы.', 'SELECT столбец, COUNT(*) FROM таблица GROUP BY столбец [HAVING условие]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'group-by'), 'HAVING', 'Фильтр по группам (в отличие от WHERE, работает после агрегации)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'group-by'), 'SELECT city, COUNT(*) FROM users GROUP BY city', 'Сколько пользователей в каждом городе'),
  ((SELECT id FROM commands WHERE slug = 'group-by'), 'SELECT city, COUNT(*) FROM users GROUP BY city HAVING COUNT(*) > 100', 'Только города, где больше 100 человек');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('COUNT / SUM / AVG …', 'aggregate', (SELECT id FROM categories WHERE slug = 'aggregation'), 'Агрегатные функции считают одно значение по набору строк: количество, сумму, среднее, минимум и максимум.', 'SELECT COUNT(*), SUM(столбец), AVG(столбец) FROM таблица', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'aggregate'), 'COUNT', 'Количество строк или ненулевых значений'),
  ((SELECT id FROM commands WHERE slug = 'aggregate'), 'SUM', 'Сумма значений столбца'),
  ((SELECT id FROM commands WHERE slug = 'aggregate'), 'AVG', 'Среднее значение'),
  ((SELECT id FROM commands WHERE slug = 'aggregate'), 'MIN / MAX', 'Минимальное и максимальное значение');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'aggregate'), 'SELECT COUNT(*) FROM orders', 'Общее число заказов'),
  ((SELECT id FROM commands WHERE slug = 'aggregate'), 'SELECT AVG(total) FROM orders', 'Средний чек');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('INSERT', 'insert', (SELECT id FROM categories WHERE slug = 'dml'), 'Добавляет новые строки в таблицу.', 'INSERT INTO таблица (столбцы) VALUES (значения)', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'insert'), 'VALUES', 'Список значений для вставки'),
  ((SELECT id FROM commands WHERE slug = 'insert'), 'RETURNING', 'Вернуть данные добавленных строк (например, сгенерированный id)'),
  ((SELECT id FROM commands WHERE slug = 'insert'), 'ON CONFLICT', 'Что делать при нарушении уникальности: пропустить или обновить');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'insert'), 'INSERT INTO users (name, age) VALUES (''Иван'', 30)', 'Добавить одного пользователя'),
  ((SELECT id FROM commands WHERE slug = 'insert'), 'INSERT INTO users (name) VALUES (''Анна'') RETURNING id', 'Вставить и получить новый id');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('UPDATE', 'update', (SELECT id FROM categories WHERE slug = 'dml'), 'Изменяет значения в уже существующих строках.', 'UPDATE таблица SET столбец = значение WHERE условие', 'Без WHERE команда обновит ВСЕ строки таблицы. Всегда проверяйте условие.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'update'), 'SET', 'Какие столбцы и на какие значения менять'),
  ((SELECT id FROM commands WHERE slug = 'update'), 'WHERE', 'Ограничить, какие строки обновлять'),
  ((SELECT id FROM commands WHERE slug = 'update'), 'RETURNING', 'Вернуть обновлённые строки');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'update'), 'UPDATE users SET age = 31 WHERE id = 1', 'Обновить возраст одного пользователя'),
  ((SELECT id FROM commands WHERE slug = 'update'), 'UPDATE orders SET status = ''paid'' WHERE id = 42', 'Пометить заказ оплаченным');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('DELETE', 'delete', (SELECT id FROM categories WHERE slug = 'dml'), 'Удаляет строки из таблицы.', 'DELETE FROM таблица WHERE условие', 'Без WHERE команда удалит ВСЕ строки таблицы. Действие необратимо.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'delete'), 'WHERE', 'Ограничить, какие строки удалять'),
  ((SELECT id FROM commands WHERE slug = 'delete'), 'RETURNING', 'Вернуть удалённые строки');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'delete'), 'DELETE FROM users WHERE id = 1', 'Удалить одного пользователя'),
  ((SELECT id FROM commands WHERE slug = 'delete'), 'DELETE FROM orders WHERE status = ''cancelled''', 'Удалить все отменённые заказы');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('CREATE TABLE', 'create-table', (SELECT id FROM categories WHERE slug = 'ddl'), 'Создаёт новую таблицу с описанием столбцов, их типов и ограничений.', 'CREATE TABLE имя (столбец тип [ограничения], ...)', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'create-table'), 'PRIMARY KEY', 'Первичный ключ — уникальный идентификатор строки'),
  ((SELECT id FROM commands WHERE slug = 'create-table'), 'NOT NULL', 'Запретить пустые значения в столбце'),
  ((SELECT id FROM commands WHERE slug = 'create-table'), 'references', 'Внешний ключ — ссылка на строку другой таблицы'),
  ((SELECT id FROM commands WHERE slug = 'create-table'), 'DEFAULT', 'Значение по умолчанию, если не указано явно');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'create-table'), 'CREATE TABLE users (id bigserial PRIMARY KEY, name text NOT NULL)', 'Простая таблица с ключом'),
  ((SELECT id FROM commands WHERE slug = 'create-table'), 'CREATE TABLE orders (id bigserial PRIMARY KEY, user_id bigint references users(id))', 'Таблица со ссылкой на users');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('ALTER TABLE', 'alter-table', (SELECT id FROM categories WHERE slug = 'ddl'), 'Изменяет структуру существующей таблицы: добавляет, удаляет или переименовывает столбцы.', 'ALTER TABLE имя ADD COLUMN | DROP COLUMN | RENAME ...', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alter-table'), 'ADD COLUMN', 'Добавить новый столбец'),
  ((SELECT id FROM commands WHERE slug = 'alter-table'), 'DROP COLUMN', 'Удалить столбец вместе с данными'),
  ((SELECT id FROM commands WHERE slug = 'alter-table'), 'RENAME', 'Переименовать таблицу или столбец');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alter-table'), 'ALTER TABLE users ADD COLUMN email text', 'Добавить столбец email'),
  ((SELECT id FROM commands WHERE slug = 'alter-table'), 'ALTER TABLE users RENAME COLUMN name TO full_name', 'Переименовать столбец');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('DROP / TRUNCATE', 'drop-truncate', (SELECT id FROM categories WHERE slug = 'ddl'), 'DROP TABLE удаляет таблицу целиком вместе со структурой. TRUNCATE быстро очищает все строки, оставляя саму таблицу.', 'DROP TABLE имя  |  TRUNCATE TABLE имя', 'Обе команды необратимы: DROP уничтожает таблицу, TRUNCATE стирает все строки без отбора по WHERE.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'drop-truncate'), 'CASCADE', 'Удалить вместе с зависимыми объектами (внешние ключи и т.п.)'),
  ((SELECT id FROM commands WHERE slug = 'drop-truncate'), 'IF EXISTS', 'Не выдавать ошибку, если таблицы уже нет');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'drop-truncate'), 'DROP TABLE IF EXISTS temp_data', 'Удалить таблицу, если она существует'),
  ((SELECT id FROM commands WHERE slug = 'drop-truncate'), 'TRUNCATE TABLE logs', 'Быстро очистить таблицу от всех строк');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('CREATE INDEX', 'index', (SELECT id FROM categories WHERE slug = 'ddl'), 'Создаёт индекс по столбцу, чтобы ускорить поиск и сортировку по нему. Ускоряет чтение, но чуть замедляет запись.', 'CREATE [UNIQUE] INDEX имя ON таблица (столбец)', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'index'), 'UNIQUE', 'Индекс, который также запрещает повторяющиеся значения');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'index'), 'CREATE INDEX idx_users_email ON users (email)', 'Ускорить поиск по email'),
  ((SELECT id FROM commands WHERE slug = 'index'), 'CREATE UNIQUE INDEX idx_users_login ON users (login)', 'Уникальный индекс по логину');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('Подзапрос (Subquery)', 'subquery', (SELECT id FROM categories WHERE slug = 'subqueries'), 'Запрос внутри другого запроса — его результат используется как значение, список или таблица во внешнем запросе.', 'SELECT ... WHERE столбец IN (SELECT ...)', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'subquery'), 'IN', 'Сравнить значение со списком из подзапроса'),
  ((SELECT id FROM commands WHERE slug = 'subquery'), 'EXISTS', 'Проверить, вернул ли подзапрос хотя бы одну строку');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'subquery'), 'SELECT * FROM users WHERE id IN (SELECT user_id FROM orders)', 'Пользователи, у которых есть заказы'),
  ((SELECT id FROM commands WHERE slug = 'subquery'), 'SELECT name FROM users u WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id)', 'То же самое через EXISTS');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('CTE (WITH)', 'cte', (SELECT id FROM categories WHERE slug = 'subqueries'), 'Именованный временный результат в начале запроса. Делает сложные запросы читаемее и позволяет рекурсию.', 'WITH имя AS (SELECT ...) SELECT ... FROM имя', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'cte'), 'WITH', 'Объявить временный именованный набор данных'),
  ((SELECT id FROM commands WHERE slug = 'cte'), 'RECURSIVE', 'Разрешить CTE ссылаться на себя (деревья, иерархии)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'cte'), 'WITH top AS (SELECT * FROM users ORDER BY age DESC LIMIT 5) SELECT * FROM top', 'Вынести выборку в отдельный блок');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('UNION / UNION ALL', 'union', (SELECT id FROM categories WHERE slug = 'subqueries'), 'Объединяет результаты двух запросов в один список. UNION убирает дубликаты, UNION ALL оставляет всё.', 'SELECT ... UNION [ALL] SELECT ...', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'union'), 'UNION', 'Объединить и убрать повторяющиеся строки'),
  ((SELECT id FROM commands WHERE slug = 'union'), 'UNION ALL', 'Объединить без удаления дубликатов (быстрее)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'union'), 'SELECT name FROM clients UNION SELECT name FROM partners', 'Общий список без повторов');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('CASE WHEN', 'case', (SELECT id FROM categories WHERE slug = 'subqueries'), 'Условное выражение внутри запроса — возвращает разные значения в зависимости от условия, как if/else.', 'CASE WHEN условие THEN значение ELSE значение END', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'case'), 'ELSE', 'Значение, если ни одно из условий не подошло');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'case'), 'SELECT name, CASE WHEN age >= 18 THEN ''взрослый'' ELSE ''ребёнок'' END AS группа FROM users', 'Пометить пользователей по возрасту');

INSERT INTO categories (name, slug, topic_id) VALUES
  ('Миграции', 'alembic-migrations', (SELECT id FROM topics WHERE slug = 'alembic')),
  ('Конфигурация', 'alembic-config', (SELECT id FROM topics WHERE slug = 'alembic'));

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic init', 'alembic-init',
   (SELECT id FROM categories WHERE slug = 'alembic-migrations'),
   'Создаёт структуру Alembic в проекте: папку migrations/, файл alembic.ini и env.py — точку входа, где Alembic подключается к моделям SQLAlchemy.',
   'alembic init <папка>', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-init'), 'alembic init migrations', 'Инициализировать Alembic в папке migrations');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic revision', 'alembic-revision',
   (SELECT id FROM categories WHERE slug = 'alembic-migrations'),
   'Создаёт новый файл миграции. С флагом --autogenerate Alembic сам сравнит модели SQLAlchemy с текущей схемой БД и сгенерирует код.',
   'alembic revision --autogenerate -m "сообщение"', 'Autogenerate не видит переименования столбцов и часть изменений типов — всегда проверяйте сгенерированный файл.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-revision'), '--autogenerate', 'Сгенерировать миграцию на основе разницы между моделями и БД'),
  ((SELECT id FROM commands WHERE slug = 'alembic-revision'), '-m', 'Сообщение миграции (попадёт в имя файла и docstring)'),
  ((SELECT id FROM commands WHERE slug = 'alembic-revision'), '--empty', 'Создать пустой файл миграции для ручного заполнения');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-revision'), 'alembic revision --autogenerate -m "add users"', 'Сгенерировать миграцию по моделям'),
  ((SELECT id FROM commands WHERE slug = 'alembic-revision'), 'alembic revision -m "manual fix" --empty', 'Создать пустую миграцию вручную');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic upgrade', 'alembic-upgrade',
   (SELECT id FROM categories WHERE slug = 'alembic-migrations'),
   'Применяет миграции «вверх» по цепочке. head — до последней, +1 — на одну вперёд, либо конкретный revision.',
   'alembic upgrade head | +1 | <rev>', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-upgrade'), 'alembic upgrade head', 'Применить все миграции'),
  ((SELECT id FROM commands WHERE slug = 'alembic-upgrade'), 'alembic upgrade +1', 'Применить одну следующую');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic downgrade', 'alembic-downgrade',
   (SELECT id FROM categories WHERE slug = 'alembic-migrations'),
   'Откатывает миграции «вниз»: -1 — на одну назад, base — до пустой БД, либо конкретный revision.',
   'alembic downgrade -1 | base | <rev>', 'Downgrade может удалить данные (DROP COLUMN, DROP TABLE). Делайте бэкап перед откатом на проде.');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-downgrade'), 'alembic downgrade -1', 'Откатить одну миграцию'),
  ((SELECT id FROM commands WHERE slug = 'alembic-downgrade'), 'alembic downgrade base', 'Откатить всё до пустой БД');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic history', 'alembic-history',
   (SELECT id FROM categories WHERE slug = 'alembic-migrations'),
   'Показывает цепочку миграций: ревизии, их родителей и текущую позицию.',
   'alembic history [--verbose]', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-history'), 'alembic history --verbose', 'Полная история миграций');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic current', 'alembic-current',
   (SELECT id FROM categories WHERE slug = 'alembic-migrations'),
   'Показывает, какая миграция применена к БД прямо сейчас.',
   'alembic current [--verbose]', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-current'), 'alembic current', 'Текущая ревизия БД');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic stamp', 'alembic-stamp',
   (SELECT id FROM categories WHERE slug = 'alembic-migrations'),
   'Помечает БД как находящуюся на указанной ревизии, не выполняя сами миграции. Полезно, когда схема уже есть, а Alembic о ней не знает.',
   'alembic stamp <rev | head>', 'Stamp не трогает схему — только меняет запись в alembic_version.');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-stamp'), 'alembic stamp head', 'Отметить БД как актуальную');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('alembic.ini', 'alembic-ini',
   (SELECT id FROM categories WHERE slug = 'alembic-config'),
   'Главный конфиг Alembic: путь к скриптам миграций, настройки логирования и строка подключения (обычно переопределяется из env.py).',
   E'[alembic]\nscript_location = migrations\nsqlalchemy.url = postgresql://...', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-ini'), 'script_location = migrations', 'Папка со скриптами миграций');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('env.py', 'alembic-env',
   (SELECT id FROM categories WHERE slug = 'alembic-config'),
   'Python-файл, который Alembic выполняет при запуске. Здесь связывают metadata моделей, URL БД и режим offline/online.',
   'target_metadata = Base.metadata', 'Без target_metadata = Base.metadata автогенерация ничего не увидит.');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'alembic-env'), E'from app.models import Base\ntarget_metadata = Base.metadata', 'Подключить модели к Alembic'),
  ((SELECT id FROM commands WHERE slug = 'alembic-env'), 'config.set_main_option("sqlalchemy.url", os.getenv("DATABASE_URL"))', 'Брать URL из переменной окружения');

INSERT INTO categories (name, slug, topic_id) VALUES
  ('Образы', 'docker-images', (SELECT id FROM topics WHERE slug = 'docker')),
  ('Контейнеры', 'docker-containers', (SELECT id FROM topics WHERE slug = 'docker')),
  ('Compose', 'docker-compose', (SELECT id FROM topics WHERE slug = 'docker')),
  ('Сети и тома', 'docker-networks', (SELECT id FROM topics WHERE slug = 'docker'));

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker build', 'docker-build',
   (SELECT id FROM categories WHERE slug = 'docker-images'),
   'Собирает образ из Dockerfile. Контекст — папка, содержимое которой отправляется демону (обычно текущая).',
   'docker build -t <имя:тег> <контекст>', 'Не ставьте контекст в / — в сборку уедет вся файловая система.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-build'), '-t', 'Задать имя и тег образа (например, myapp:1.0)'),
  ((SELECT id FROM commands WHERE slug = 'docker-build'), '--no-cache', 'Собрать без кэша слоёв'),
  ((SELECT id FROM commands WHERE slug = 'docker-build'), '-f', 'Указать путь к Dockerfile, если он не в корне контекста');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-build'), 'docker build -t myapp:1.0 .', 'Собрать образ из текущей папки'),
  ((SELECT id FROM commands WHERE slug = 'docker-build'), 'docker build --no-cache -t myapp:1.0 .', 'Пересобрать без кэша');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker images', 'docker-images',
   (SELECT id FROM categories WHERE slug = 'docker-images'),
   'Список локальных образов с размерами и тегами.',
   'docker images [-a]', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-images'), 'docker images', 'Все локальные образы');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker pull', 'docker-pull',
   (SELECT id FROM categories WHERE slug = 'docker-images'),
   'Скачивает образ из реестра (Docker Hub по умолчанию).',
   'docker pull <образ:тег>', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-pull'), 'docker pull postgres:16', 'Скачать официальный образ Postgres 16');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker push', 'docker-push',
   (SELECT id FROM categories WHERE slug = 'docker-images'),
   'Отправляет образ в реестр.',
   'docker push <образ:тег>', 'Перед push нужно docker login и правильный тег с именем реестра.');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-push'), 'docker push registry.example.com/myapp:1.0', 'Отправить образ в приватный реестр');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker rmi', 'docker-rmi',
   (SELECT id FROM categories WHERE slug = 'docker-images'),
   'Удаляет локальный образ. По умолчанию не даст удалить образ, используемый контейнером.',
   'docker rmi <образ>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-rmi'), '-f', 'Удалить принудительно, даже если есть контейнеры'),
  ((SELECT id FROM commands WHERE slug = 'docker-rmi'), 'prune', 'Удалить все неиспользуемые образы (docker image prune)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-rmi'), 'docker rmi myapp:1.0', 'Удалить образ'),
  ((SELECT id FROM commands WHERE slug = 'docker-rmi'), 'docker image prune -a', 'Удалить все неиспользуемые образы');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker run', 'docker-run',
   (SELECT id FROM categories WHERE slug = 'docker-containers'),
   'Создаёт и запускает контейнер из образа.',
   'docker run [опции] <образ> [команда]', 'Без -d контейнер займёт терминал. Без -p порты не будут доступны снаружи.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-run'), '-d', 'Запустить в фоне (detached)'),
  ((SELECT id FROM commands WHERE slug = 'docker-run'), '-p', 'Пробросить порт хост:контейнер (например, -p 8000:8000)'),
  ((SELECT id FROM commands WHERE slug = 'docker-run'), '-v', 'Примонтировать том или папку'),
  ((SELECT id FROM commands WHERE slug = 'docker-run'), '-e', 'Передать переменную окружения'),
  ((SELECT id FROM commands WHERE slug = 'docker-run'), '--name', 'Задать имя контейнера'),
  ((SELECT id FROM commands WHERE slug = 'docker-run'), '--rm', 'Удалить контейнер после остановки');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-run'), 'docker run -d -p 8000:8000 --name web myapp:1.0', 'Запустить web-сервер в фоне'),
  ((SELECT id FROM commands WHERE slug = 'docker-run'), 'docker run --rm -it ubuntu bash', 'Интерактивный shell в Ubuntu'),
  ((SELECT id FROM commands WHERE slug = 'docker-run'), 'docker run -e DATABASE_URL=... myapp:1.0', 'Передать переменную окружения');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker ps', 'docker-ps',
   (SELECT id FROM categories WHERE slug = 'docker-containers'),
   'Список контейнеров. Без флагов — только запущенные.',
   'docker ps [-a]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-ps'), '-a', 'Показать все контейнеры, включая остановленные'),
  ((SELECT id FROM commands WHERE slug = 'docker-ps'), '-q', 'Только ID контейнеров (удобно для скриптов)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-ps'), 'docker ps -a', 'Все контейнеры'),
  ((SELECT id FROM commands WHERE slug = 'docker-ps'), 'docker ps -q | xargs docker stop', 'Остановить все запущенные');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker start / stop / restart', 'docker-lifecycle',
   (SELECT id FROM categories WHERE slug = 'docker-containers'),
   'Управляет жизненным циклом существующего контейнера.',
   'docker start|stop|restart <контейнер>', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-lifecycle'), 'docker stop web', 'Остановить контейнер web'),
  ((SELECT id FROM commands WHERE slug = 'docker-lifecycle'), 'docker restart web', 'Перезапустить контейнер');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker exec', 'docker-exec',
   (SELECT id FROM categories WHERE slug = 'docker-containers'),
   'Выполняет команду внутри работающего контейнера. Чаще всего — для отладки.',
   'docker exec -it <контейнер> <команда>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-exec'), '-it', 'Интерактивный режим с TTY (для shell)'),
  ((SELECT id FROM commands WHERE slug = 'docker-exec'), '-u', 'Запустить от имени указанного пользователя');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-exec'), 'docker exec -it web bash', 'Зайти в shell контейнера'),
  ((SELECT id FROM commands WHERE slug = 'docker-exec'), 'docker exec web ls /app', 'Выполнить одну команду');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker logs', 'docker-logs',
   (SELECT id FROM categories WHERE slug = 'docker-containers'),
   'Показывает stdout/stderr контейнера.',
   'docker logs [-f] [--tail N] <контейнер>', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-logs'), '-f', 'Следить за логами в реальном времени'),
  ((SELECT id FROM commands WHERE slug = 'docker-logs'), '--tail', 'Показать только последние N строк');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-logs'), 'docker logs -f web', 'Смотреть логи в реальном времени'),
  ((SELECT id FROM commands WHERE slug = 'docker-logs'), 'docker logs --tail 100 web', 'Последние 100 строк логов');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker rm', 'docker-rm',
   (SELECT id FROM categories WHERE slug = 'docker-containers'),
   'Удаляет остановленный контейнер.',
   'docker rm <контейнер>', 'Запущенный контейнер без -f не удалится.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-rm'), '-f', 'Удалить даже запущенный контейнер'),
  ((SELECT id FROM commands WHERE slug = 'docker-rm'), '-v', 'Удалить связанные анонимные тома');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-rm'), 'docker rm web', 'Удалить остановленный контейнер'),
  ((SELECT id FROM commands WHERE slug = 'docker-rm'), 'docker rm -f $(docker ps -aq)', 'Удалить все контейнеры');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker compose up', 'compose-up',
   (SELECT id FROM categories WHERE slug = 'docker-compose'),
   'Поднимает сервисы из docker-compose.yml: создаёт сети, тома, контейнеры и запускает их.',
   'docker compose up [-d] [--build]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'compose-up'), '-d', 'Запустить в фоне'),
  ((SELECT id FROM commands WHERE slug = 'compose-up'), '--build', 'Пересобрать образы перед запуском'),
  ((SELECT id FROM commands WHERE slug = 'compose-up'), '--force-recreate', 'Пересоздать контейнеры, даже если конфиг не менялся');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'compose-up'), 'docker compose up -d --build', 'Поднять сервисы в фоне, пересобрав образы'),
  ((SELECT id FROM commands WHERE slug = 'compose-up'), 'docker compose up', 'Запустить с логами в терминале');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker compose down', 'compose-down',
   (SELECT id FROM categories WHERE slug = 'docker-compose'),
   'Останавливает и удаляет контейнеры, сети и (опционально) тома Compose.',
   'docker compose down [-v]', 'С -v удаляются volume — все данные сервисов пропадут.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'compose-down'), '-v', 'Удалить также анонимные и именованные тома'),
  ((SELECT id FROM commands WHERE slug = 'compose-down'), '--rmi', 'Удалить также образы (all — все, local — только локальные)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'compose-down'), 'docker compose down', 'Остановить и удалить контейнеры'),
  ((SELECT id FROM commands WHERE slug = 'compose-down'), 'docker compose down -v', 'Остановить и удалить всё, включая тома');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker compose logs', 'compose-logs',
   (SELECT id FROM categories WHERE slug = 'docker-compose'),
   'Собирает логи всех сервисов Compose в один поток.',
   'docker compose logs [-f] [сервис]', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'compose-logs'), 'docker compose logs -f web', 'Логи сервиса web в реальном времени'),
  ((SELECT id FROM commands WHERE slug = 'compose-logs'), 'docker compose logs --tail 50', 'Последние 50 строк по всем сервисам');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker compose exec', 'compose-exec',
   (SELECT id FROM categories WHERE slug = 'docker-compose'),
   'Выполняет команду внутри запущенного сервиса Compose.',
   'docker compose exec <сервис> <команда>', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'compose-exec'), 'docker compose exec web bash', 'Зайти в shell сервиса web');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker network', 'docker-network',
   (SELECT id FROM categories WHERE slug = 'docker-networks'),
   'Управляет сетями Docker: создаёт, показывает, подключает контейнеры.',
   'docker network [ls | create | inspect | connect]', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-network'), 'docker network ls', 'Список сетей'),
  ((SELECT id FROM commands WHERE slug = 'docker-network'), 'docker network create mynet', 'Создать сеть mynet');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('docker volume', 'docker-volume',
   (SELECT id FROM categories WHERE slug = 'docker-networks'),
   'Управляет томами — постоянным хранилищем данных между перезапусками контейнеров.',
   'docker volume [ls | create | inspect | rm]', 'docker volume prune безвозвратно удаляет неиспользуемые тома.');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'docker-volume'), 'docker volume ls', 'Список томов'),
  ((SELECT id FROM commands WHERE slug = 'docker-volume'), 'docker volume rm mydata', 'Удалить том mydata');

INSERT INTO categories (name, slug, topic_id) VALUES
  ('Запуск', 'pytest-run', (SELECT id FROM topics WHERE slug = 'pytest')),
  ('Фикстуры', 'pytest-fixtures', (SELECT id FROM topics WHERE slug = 'pytest')),
  ('Параметризация', 'pytest-params', (SELECT id FROM topics WHERE slug = 'pytest')),
  ('Ассерты и маркеры', 'pytest-asserts', (SELECT id FROM topics WHERE slug = 'pytest'));

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('pytest', 'pytest-run-all',
   (SELECT id FROM categories WHERE slug = 'pytest-run'),
   'Запускает все тесты в проекте. По умолчанию ищет файлы test_*.py и *_test.py.',
   'pytest [опции] [путь]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), '-v', 'Подробный вывод: каждый тест отдельной строкой'),
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), '-q', 'Тихий режим'),
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), '-x', 'Остановиться на первом упавшем тесте'),
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), '--lf', 'Запустить только тесты, упавшие в прошлый раз (last failed)'),
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), '--ff', 'Сначала упавшие, потом остальные'),
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), '-s', 'Не перехватывать stdout (print будет виден)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), 'pytest -v', 'Запустить все тесты подробно'),
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), 'pytest -x --lf', 'Остановиться на первой ошибке, только прошлые падения'),
  ((SELECT id FROM commands WHERE slug = 'pytest-run-all'), 'pytest tests/test_api.py::test_login', 'Один конкретный тест');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('pytest -k', 'pytest-k',
   (SELECT id FROM categories WHERE slug = 'pytest-run'),
   'Запускает тесты, чьи имена совпадают с подстрокой (поддерживает and/or/not).',
   'pytest -k "выражение"', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-k'), 'pytest -k "login"', 'Только тесты про логин'),
  ((SELECT id FROM commands WHERE slug = 'pytest-k'), 'pytest -k "login and not slow"', 'Логин, но не медленные');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('pytest -m', 'pytest-m',
   (SELECT id FROM categories WHERE slug = 'pytest-run'),
   'Запускает тесты с определённой меткой (@pytest.mark.<имя>).',
   'pytest -m "метка"', 'Метки нужно регистрировать в pytest.ini, иначе будет warning.');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-m'), 'pytest -m "slow"', 'Только медленные тесты'),
  ((SELECT id FROM commands WHERE slug = 'pytest-m'), 'pytest -m "not integration"', 'Без интеграционных');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('@pytest.fixture', 'pytest-fixture',
   (SELECT id FROM categories WHERE slug = 'pytest-fixtures'),
   'Декоратор, превращающий функцию в фикстуру. Тест получает её значение через параметр с тем же именем.',
   E'@pytest.fixture\ndef resource():\n    return setup()', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-fixture'), 'scope', 'Область жизни: function (по умолчанию), class, module, package, session'),
  ((SELECT id FROM commands WHERE slug = 'pytest-fixture'), 'autouse', 'Автоматически применять фикстуру ко всем тестам в области'),
  ((SELECT id FROM commands WHERE slug = 'pytest-fixture'), 'params', 'Список параметров — фикстура запустит тест по разу для каждого');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-fixture'), E'@pytest.fixture\ndef db():\n    conn = connect()\n    yield conn\n    conn.close()', 'Фикстура с очисткой через yield'),
  ((SELECT id FROM commands WHERE slug = 'pytest-fixture'), E'@pytest.fixture(scope="session")\ndef app():\n    return create_app()', 'Фикстура на всю сессию тестов');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('yield-фикстура', 'pytest-yield',
   (SELECT id FROM categories WHERE slug = 'pytest-fixtures'),
   'Фикстура, отдающая значение через yield: код до yield — setup, после — teardown (выполнится даже при падении теста).',
   E'@pytest.fixture\ndef resource():\n    r = acquire()\n    yield r\n    release(r)', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-yield'), E'@pytest.fixture\ndef file():\n    f = open("data.txt")\n    yield f\n    f.close()', 'Открыть файл и гарантированно закрыть');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('conftest.py', 'pytest-conftest',
   (SELECT id FROM categories WHERE slug = 'pytest-fixtures'),
   'Файл, чьи фикстуры и хуки автоматически доступны всем тестам в папке и подпапках — без импортов.',
   E'# tests/conftest.py\n@pytest.fixture\ndef client():\n    ...', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-conftest'), E'@pytest.fixture\ndef client():\n    return TestClient(app)', 'Общий клиент для всех тестов в папке');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('@pytest.mark.parametrize', 'pytest-parametrize',
   (SELECT id FROM categories WHERE slug = 'pytest-params'),
   'Запускает один тест несколько раз с разными входными данными.',
   E'@pytest.mark.parametrize("a,b,expected", [(1,2,3),(2,3,5)])\ndef test_sum(a,b,expected):\n    assert a+b == expected', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-parametrize'), 'ids', 'Человекочитаемые имена для каждого набора данных'),
  ((SELECT id FROM commands WHERE slug = 'pytest-parametrize'), 'indirect', 'Передать параметры в фикстуру, а не в тест');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-parametrize'), E'@pytest.mark.parametrize("x", [1,2,3])\ndef test_square(x):\n    assert x**2 > 0', 'Три запуска одного теста'),
  ((SELECT id FROM commands WHERE slug = 'pytest-parametrize'), E'@pytest.mark.parametrize("s", ["a","b"], ids=["letter-a","letter-b"])\ndef test_len(s):\n    assert len(s) == 1', 'С понятными id');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('pytest.raises', 'pytest-raises',
   (SELECT id FROM categories WHERE slug = 'pytest-asserts'),
   'Контекстный менеджер, проверяющий, что блок кода выбрасывает указанное исключение.',
   E'with pytest.raises(ValueError):\n    int("abc")', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-raises'), E'with pytest.raises(ZeroDivisionError):\n    1 / 0', 'Ожидаем деление на ноль'),
  ((SELECT id FROM commands WHERE slug = 'pytest-raises'), E'with pytest.raises(ValueError, match="invalid"):\n    parse("x")', 'Проверить ещё и текст ошибки');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('pytest.approx', 'pytest-approx',
   (SELECT id FROM categories WHERE slug = 'pytest-asserts'),
   'Сравнивает числа с плавающей точкой с допуском — без ложных падений из-за округления.',
   'assert 0.1 + 0.2 == pytest.approx(0.3)', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-approx'), 'assert 0.1 + 0.2 == pytest.approx(0.3)', 'Сравнение float'),
  ((SELECT id FROM commands WHERE slug = 'pytest-approx'), 'assert [0.1, 0.2] == pytest.approx([0.1, 0.2])', 'Сравнение списков float');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('skip / skipif / xfail', 'pytest-skip',
   (SELECT id FROM categories WHERE slug = 'pytest-asserts'),
   'Маркеры для пропуска тестов или пометки «ожидаемо падает»: skip — всегда, skipif — по условию, xfail — падение не считается ошибкой.',
   E'@pytest.mark.skip(reason="...")\n@pytest.mark.skipif(cond, reason="...")\n@pytest.mark.xfail', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'pytest-skip'), '@pytest.mark.skip(reason="not implemented")', 'Всегда пропускать'),
  ((SELECT id FROM commands WHERE slug = 'pytest-skip'), '@pytest.mark.skipif(sys.platform == "win32", reason="POSIX only")', 'Пропускать на Windows'),
  ((SELECT id FROM commands WHERE slug = 'pytest-skip'), '@pytest.mark.xfail(reason="known bug")', 'Ожидаемое падение');

INSERT INTO categories (name, slug, topic_id) VALUES
  ('Запуск', 'vue-run', (SELECT id FROM topics WHERE slug = 'vue')),
  ('Компоненты', 'vue-components', (SELECT id FROM topics WHERE slug = 'vue')),
  ('Асинхронность', 'vue-async', (SELECT id FROM topics WHERE slug = 'vue'));

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('vitest', 'vitest-watch',
   (SELECT id FROM categories WHERE slug = 'vue-run'),
   'Запускает тесты Vitest в режиме наблюдения: перезапускает при изменениях файлов.',
   'npx vitest', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vitest-watch'), '--ui', 'Открыть интерактивный UI в браузере'),
  ((SELECT id FROM commands WHERE slug = 'vitest-watch'), '--coverage', 'Собрать покрытие');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vitest-watch'), 'npx vitest', 'Watch-режим'),
  ((SELECT id FROM commands WHERE slug = 'vitest-watch'), 'npx vitest --ui', 'Открыть UI');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('vitest run', 'vitest-run',
   (SELECT id FROM categories WHERE slug = 'vue-run'),
   'Один прогон тестов без наблюдения — режим для CI.',
   'npx vitest run', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vitest-run'), '--reporter', 'Формат вывода (default, verbose, json)'),
  ((SELECT id FROM commands WHERE slug = 'vitest-run'), '-t', 'Фильтр по имени теста');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vitest-run'), 'npx vitest run', 'Один прогон'),
  ((SELECT id FROM commands WHERE slug = 'vitest-run'), 'npx vitest run -t "Button"', 'Только тесты с Button в имени');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('mount', 'vue-mount',
   (SELECT id FROM categories WHERE slug = 'vue-components'),
   'Монтирует компонент вместе со всеми дочерними — для полноценных тестов интеграции.',
   E'import { mount } from "@vue/test-utils"\nconst w = mount(MyButton, { props: { label: "OK" } })', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vue-mount'), 'const w = mount(MyButton)', 'Смонтировать компонент'),
  ((SELECT id FROM commands WHERE slug = 'vue-mount'), 'const w = mount(MyButton, { props: { label: "OK" } })', 'С props');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('shallowMount', 'vue-shallow',
   (SELECT id FROM categories WHERE slug = 'vue-components'),
   'Монтирует компонент, подменяя дочерние на заглушки — изолирует тест от внутренностей детей.',
   'const w = shallowMount(Parent)', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vue-shallow'), 'const w = shallowMount(Parent)', 'Родитель без реальных детей');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('wrapper.find / findAll', 'vue-find',
   (SELECT id FROM categories WHERE slug = 'vue-components'),
   'Ищет элемент или элементы внутри отрендеренного компонента по CSS-селектору.',
   E'w.find("button")\nw.findAll(".item")', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vue-find'), 'expect(w.find("h1").text()).toBe("Hello")', 'Проверить текст заголовка'),
  ((SELECT id FROM commands WHERE slug = 'vue-find'), 'expect(w.findAll("li")).toHaveLength(3)', 'Три элемента списка');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('trigger / setValue', 'vue-trigger',
   (SELECT id FROM categories WHERE slug = 'vue-components'),
   'Симулирует DOM-событие (клик, ввод) или задаёт значение input.',
   E'await w.find("button").trigger("click")\nawait w.find("input").setValue("text")', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vue-trigger'), 'await w.find("button").trigger("click")', 'Клик по кнопке'),
  ((SELECT id FROM commands WHERE slug = 'vue-trigger'), 'await w.find("input").setValue("hello")', 'Ввод текста');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('setProps', 'vue-setprops',
   (SELECT id FROM categories WHERE slug = 'vue-components'),
   'Обновляет props уже смонтированного компонента и ждёт перерисовки.',
   'await w.setProps({ label: "New" })', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vue-setprops'), 'await w.setProps({ count: 5 })', 'Передать новое значение prop');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('flushPromises', 'vue-flush',
   (SELECT id FROM categories WHERE slug = 'vue-async'),
   'Ждёт, пока разрешатся все pending-промисы — нужно для тестов с async setup или API-запросами.',
   E'import { flushPromises } from "@vue/test-utils"\nawait flushPromises()', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vue-flush'), E'await flushPromises()\nexpect(w.text()).toContain("Loaded")', 'Дождаться загрузки данных');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('nextTick', 'vue-nexttick',
   (SELECT id FROM categories WHERE slug = 'vue-async'),
   'Ждёт цикл обновления реактивности Vue. Обычно используется после изменения state.',
   E'import { nextTick } from "vue"\nawait nextTick()', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'vue-nexttick'), E'await w.vm.$nextTick()\nexpect(w.find(".counter").text()).toBe("1")', 'Дождаться обновления DOM');

INSERT INTO categories (name, slug, topic_id) VALUES
  ('Запуск', 'react-run', (SELECT id FROM topics WHERE slug = 'react')),
  ('Рендер', 'react-render', (SELECT id FROM topics WHERE slug = 'react')),
  ('События', 'react-events', (SELECT id FROM topics WHERE slug = 'react')),
  ('Асинхронность', 'react-async', (SELECT id FROM topics WHERE slug = 'react'));

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('jest', 'jest-run',
   (SELECT id FROM categories WHERE slug = 'react-run'),
   'Запускает тесты Jest.',
   'npx jest', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'jest-run'), '--watch', 'Перезапускать при изменениях'),
  ((SELECT id FROM commands WHERE slug = 'jest-run'), '--coverage', 'Собрать покрытие'),
  ((SELECT id FROM commands WHERE slug = 'jest-run'), '-t', 'Фильтр по имени теста'),
  ((SELECT id FROM commands WHERE slug = 'jest-run'), '--ci', 'Режим CI (без watch, стабильные снапшоты)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'jest-run'), 'npx jest --watch', 'Watch-режим'),
  ((SELECT id FROM commands WHERE slug = 'jest-run'), 'npx jest -t "Button"', 'Только тесты с Button в имени');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('render', 'react-render',
   (SELECT id FROM categories WHERE slug = 'react-render'),
   'Рендерит React-компонент в виртуальный DOM для теста.',
   E'import { render, screen } from "@testing-library/react"\nrender(<Button label="OK" />)', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-render'), 'render(<Button label="OK" />)', 'Отрендерить компонент'),
  ((SELECT id FROM commands WHERE slug = 'react-render'), 'render(<App />, { wrapper: ThemeProvider })', 'Рендер с обёрткой');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('screen.getByText / getByRole', 'react-get',
   (SELECT id FROM categories WHERE slug = 'react-render'),
   'Находит элемент в отрендеренном дереве. getBy* бросает ошибку, если ничего не нашёл queryBy* возвращает null.',
   E'screen.getByText(/hello/i)\nscreen.getByRole("button", { name: /save/i })', 'По возможности ищите через getByRole — это ближе к тому, как элемент видит пользователь.');
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-get'), 'getBy*', 'Бросает ошибку, если не нашёл (для положительных проверок)'),
  ((SELECT id FROM commands WHERE slug = 'react-get'), 'queryBy*', 'Возвращает null, если не нашёл (для проверки отсутствия)'),
  ((SELECT id FROM commands WHERE slug = 'react-get'), 'findBy*', 'Асинхронная версия: ждёт появления элемента'),
  ((SELECT id FROM commands WHERE slug = 'react-get'), 'getAllBy*', 'Возвращает массив всех совпадений');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-get'), 'expect(screen.getByText("OK")).toBeInTheDocument()', 'Элемент с текстом OK есть'),
  ((SELECT id FROM commands WHERE slug = 'react-get'), 'expect(screen.queryByText("Error")).not.toBeInTheDocument()', 'Элемента с Error нет'),
  ((SELECT id FROM commands WHERE slug = 'react-get'), 'screen.getByRole("button", { name: /save/i })', 'Кнопка Save по роли и имени');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('within', 'react-within',
   (SELECT id FROM categories WHERE slug = 'react-render'),
   'Ограничивает поиск внутри конкретного контейнера — удобно, когда одинаковый текст встречается несколько раз.',
   E'const form = screen.getByRole("form")\nwithin(form).getByLabelText("Email")', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-within'), 'within(screen.getByRole("dialog")).getByText("Confirm")', 'Искать текст только внутри диалога');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('rerender', 'react-rerender',
   (SELECT id FROM categories WHERE slug = 'react-render'),
   'Перерисовывает компонент с новыми props без полного размонтирования.',
   E'const { rerender } = render(<C count={1} />)\nrerender(<C count={2} />)', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-rerender'), E'const { rerender } = render(<C n={1} />)\nrerender(<C n={2} />)', 'Обновить props');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('fireEvent', 'react-fireevent',
   (SELECT id FROM categories WHERE slug = 'react-events'),
   'Симулирует DOM-событие напрямую. Низкоуровневый, но работает без user-event.',
   'fireEvent.click(screen.getByRole("button"))', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-fireevent'), 'fireEvent.click(screen.getByRole("button"))', 'Клик по кнопке');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('userEvent', 'react-userevent',
   (SELECT id FROM categories WHERE slug = 'react-events'),
   'Симулирует пользовательское поведение (клики, ввод) с учётом фокуса, hover и т.п. Предпочтительнее fireEvent.',
   E'import userEvent from "@testing-library/user-event"\nawait userEvent.click(screen.getByRole("button"))', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-userevent'), 'await userEvent.click(screen.getByRole("button"))', 'Клик'),
  ((SELECT id FROM commands WHERE slug = 'react-userevent'), 'await userEvent.type(screen.getByLabelText("Email"), "a@b.c")', 'Ввод текста');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('waitFor', 'react-waitfor',
   (SELECT id FROM categories WHERE slug = 'react-async'),
   'Ждёт, пока условие внутри колбэка станет истинным (например, появится элемент после запроса).',
   E'await waitFor(() => {\n  expect(screen.getByText("Loaded")).toBeInTheDocument()\n})', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-waitfor'), 'timeout', 'Максимальное время ожидания в мс');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-waitfor'), 'await waitFor(() => expect(screen.getByText("OK")).toBeInTheDocument())', 'Дождаться появления текста'),
  ((SELECT id FROM commands WHERE slug = 'react-waitfor'), 'await waitFor(() => expect(fn).toHaveBeenCalledTimes(1))', 'Дождаться вызова мока');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('findBy*', 'react-findby',
   (SELECT id FROM categories WHERE slug = 'react-async'),
   'Асинхронный поиск: возвращает промис, который резолвится, когда элемент появился.',
   'const el = await screen.findByText("Loaded")', null);
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'react-findby'), 'expect(await screen.findByText("Loaded")).toBeInTheDocument()', 'Дождаться появления элемента'),
  ((SELECT id FROM commands WHERE slug = 'react-findby'), 'const rows = await screen.findAllByRole("row")', 'Дождаться нескольких элементов');

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE commands ENABLE ROW LEVEL SECURITY;
ALTER TABLE flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE examples ENABLE ROW LEVEL SECURITY;
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "read categories" ON categories FOR SELECT USING (TRUE);
CREATE POLICY "read commands" ON commands FOR SELECT USING (TRUE);
CREATE POLICY "read flags" ON flags FOR SELECT USING (TRUE);
CREATE POLICY "read examples" ON examples FOR SELECT USING (TRUE);
CREATE POLICY "read topics" ON topics FOR SELECT USING (TRUE);
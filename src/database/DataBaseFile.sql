DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS commands CASCADE;
DROP TABLE IF EXISTS flags CASCADE;
DROP TABLE IF EXISTS examples CASCADE;

CREATE TABLE categories (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL,
  slug text NOT NULL UNIQUE
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

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE commands ENABLE ROW LEVEL SECURITY;
ALTER TABLE flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE examples ENABLE ROW LEVEL SECURITY;

CREATE policy "read categories" ON categories FOR SELECT USING (TRUE);
CREATE policy "read commands" ON commands FOR SELECT USING (TRUE);
CREATE policy "read flags" ON flags FOR SELECT USING (TRUE);
CREATE policy "read examples" ON examples FOR SELECT USING (TRUE);
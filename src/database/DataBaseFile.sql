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
  ('Конфигурация', 'config')
ON conflict (slug) DO nothing;

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
  ('git commit', 'commit', (SELECT id FROM categories WHERE slug = 'basics'), 'Сохраняет изменения из индекса (staging area) в историю репозитория, создавая новый коммит с уникальным идентификатором.', 'git commit [-m "сообщение"] [--amend]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'commit'), '-m', 'Задать сообщение коммита прямо в команде, без открытия редактора'),
  ((SELECT id FROM commands WHERE slug = 'commit'), '-a', 'Автоматически добавить в коммит все отслеживаемые изменённые файлы'),
  ((SELECT id FROM commands WHERE slug = 'commit'), '--amend', 'Изменить последний коммит вместо создания нового');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='commit'), 'git commit -m "Добавил форму входа"', 'Обычный коммит с сообщением'),
  ((SELECT id FROM commands WHERE slug='commit'), 'git commit --amend -m "Новое сообщение"', 'Переписать сообщение последнего коммита');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git status', 'status', (SELECT id FROM categories WHERE slug = 'basics'), 'Показывает состояние рабочей директории и индекса: какие файлы изменены, какие добавлены в staging, какие не отслеживаются.', 'git status [-s]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'status'), '-s', 'Краткий формат вывода (одна строка на файл)');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='status'), 'git status -s', 'Компактный вид состояния');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git log', 'log', (SELECT id FROM categories WHERE slug = 'basics'), 'Показывает историю коммитов текущей ветки: автор, дата, сообщение и хеш каждого коммита.', 'git log [--oneline] [--graph]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'log'), '--oneline', 'Краткий вид: один коммит в одну строку'),
  ((SELECT id FROM commands WHERE slug = 'log'), '--graph', 'Рисует дерево веток псевдографикой');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='log'), 'git log --oneline --graph', 'Компактная история с ветвлением');

INSERT INTO commands (name, slug, category_id, description, syntax, warning) VALUES
  ('git branch', 'branch', (SELECT id FROM categories WHERE slug = 'branching'), 'Управляет ветками: показывает список, создаёт новые и удаляет существующие.', 'git branch [<имя>] [-d | -D]', null);
INSERT INTO flags (command_id, flag, description) VALUES
  ((SELECT id FROM commands WHERE slug = 'branch'), '-d', 'Удалить ветку (только если она слита)'),
  ((SELECT id FROM commands WHERE slug = 'branch'), '-D', 'Принудительно удалить ветку, даже если не слита');
INSERT INTO examples (command_id, code, description) VALUES
  ((SELECT id FROM commands WHERE slug='branch'), 'git branch feature-login', 'Создать ветку feature-login'),
  ((SELECT id FROM commands WHERE slug='branch'), 'git branch -d old-feature', 'Удалить слитую ветку');

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

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE commands ENABLE ROW LEVEL SECURITY;
ALTER TABLE flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE examples ENABLE ROW LEVEL SECURITY;

CREATE policy "read categories" ON categories FOR SELECT USING (TRUE);
CREATE policy "read commands" ON commands FOR SELECT USING (TRUE);
CREATE policy "read flags" ON flags FOR SELECT USING (TRUE);
CREATE policy "read examples" ON examples FOR SELECT USING (TRUE);
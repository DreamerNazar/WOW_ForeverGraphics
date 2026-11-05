# Публикация на CurseForge

## 1. Перед первым релизом

1. Запустить игру и выполнить `/fg info`. Сверить номер Interface с
   `## Interface` в [ForeverGraphics.toc](../ForeverGraphics/ForeverGraphics.toc)
   (сейчас там `16001` — подтверждён в игре на клиенте 1.60.1 (70790)).
   После обновления клиента проверить снова.
2. Проверить в игре: `/fg`, пресеты, кнопки «Сброс», «Сбросить всё»,
   «Применить». `/fg apply ultra` → `/fg show` покажет, что движок обрезал.
3. `## Author` в `.toc` уже есть. После создания проекта дописать:
   ```
   ## X-Curse-Project-ID: <ID со страницы проекта>
   ```

## 2. Сборка архива

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

Результат — `dist\ForeverGraphics-<версия>.zip` (версия из `## Version` в `.toc`).
Внутри одна папка `ForeverGraphics\` с `.toc` и `.lua` — именно такую структуру
ждёт CurseForge. `dist\` в git не попадает.

## 3. Создание проекта (один раз)

1. Войти на <https://authors.curseforge.com> → **Create Project** → игра
   **World of Warcraft**.
2. Заполнить: название `ForeverGraphics`, краткое описание, полное описание
   (можно взять из README), категорию, лицензию, логотип —
   [docs/logo.png](logo.png) (512×512).
3. Отправить на модерацию. Новые проекты CurseForge проверяет вручную —
   это может занять от нескольких часов до пары дней.
4. Скопировать **Project ID** со страницы проекта в `## X-Curse-Project-ID`.

## 4. Загрузка файла

1. Страница проекта → **Files** → **Upload File**.
2. Выбрать zip из `dist\`.
3. **Release type**: `Release` для стабильной версии, `Beta`/`Alpha` для тестовых.
4. **Game version**: отметить версию WoW Forever (1.60.x). Если CurseForge
   ещё не добавил этот клиент в список версий — написать в их поддержку или
   временно не публиковать; ставить чужую версию (Classic/Retail) не стоит,
   менеджеры аддонов будут предлагать аддон не тому клиенту.
5. **Changelog**: что изменилось в этой версии.

## 5. Новые версии

1. Поднять `## Version` в `.toc` (например `0.3.0` → `0.3.1`).
2. Закоммитить, поставить тег: `git tag v0.3.1`.
3. Собрать `build.ps1` и загрузить zip, как в п. 4.

## Автоматизация (на будущее, не настроено)

Стандартный путь — репозиторий на GitHub и
[BigWigsMods/packager](https://github.com/BigWigsMods/packager) в GitHub Actions:
при пуше тега он сам собирает архив и заливает на CurseForge. Нужно:

- файл `.pkgmeta` в корне; т.к. аддон лежит в подпапке, в нём понадобится
  `move-folders`, а README/docs/build.ps1 — в `ignore`;
- секрет `CF_API_KEY` в репозитории (токен из настроек аккаунта CurseForge);
- `## X-Curse-Project-ID` в `.toc`.

Packager определяет версию игры по `## Interface`, поэтому заработает только
когда CurseForge начнёт знать номер Interface клиента WoW Forever.

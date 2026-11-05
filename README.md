[**RU**](#forevergraphics) | [**ENG**](#forevergraphics-english)

# ForeverGraphics

Аддон для WoW Forever (клиент 1.60.x на современном движке, DX12), выставляющий
графические CVar'ы сверх того, что доступно в стандартном меню настроек.

## Установка
Скопировать папку `ForeverGraphics` в
`World of Warcraft/_forever_/Interface/AddOns/` (папку `Interface/AddOns`
создать рядом с `Wow.exe`, если её нет).

## Команды
- `/fg` — окно настроек (также «Настройки → Аддоны → ForeverGraphics»):
  значение каждого параметра можно ввести вручную (Enter — применить; ручные
  значения сохраняются и применяются при входе поверх пресета), кнопка «Сброс»
  у каждого параметра и общая «Сбросить всё». Переключатели 0/1 — галочками,
  сверху кнопки пресетов «Низкий / Высокий / Ультра»
- `/fg apply <low|high|ultra>` — применить пресет (повторяется при каждом входе)
- `/fg fog <on|off>` — объёмный туман (`volumeFog`)
- `/fg tweaks` — не графические мелочи: отдаление камеры, без окон ошибок Lua,
  без геймпада, цифры урона, искры на квестовых предметах
- `/fg restart` — перезапуск графики (`RestartGx`, как кнопка «Применить» в окне).
  `/reload` графику не перезапускает; большинство настроек применяются сразу,
  перезапуск нужен лишь некоторым (например, разрешению текстур)
- `/fg show` — фактические значения CVar'ов текущего пресета (видно, что движок обрезал)
- `/fg info` — версия клиента и номер Interface
- `/fg probe` — значения, значения по умолчанию и блокировки скрытых
  CVar'ов-кандидатов; результат сохраняется в
  `WTF\Account\<аккаунт>\SavedVariables\ForeverGraphics.lua` после выхода из игры
- `/fg reset` — вернуть значения, сохранённые до первого применения
- `/fg defaults` — сбросить всё к значениям движка по умолчанию

## Публикация
Сборка архива: `powershell -ExecutionPolicy Bypass -File build.ps1`.
Пошагово про CurseForge: [docs/CURSEFORGE.md](docs/CURSEFORGE.md).

---

# ForeverGraphics (English)

An addon for WoW Forever (client 1.60.x on the modern engine, DX12) that exposes
graphics CVars beyond what the standard settings menu offers.

## Installation
Copy the `ForeverGraphics` folder to
`World of Warcraft/_forever_/Interface/AddOns/` (create the `Interface/AddOns`
folder next to `Wow.exe` if it doesn't exist).

## Commands
- `/fg` — settings window (also "Settings → AddOns → ForeverGraphics"):
  every value can be entered manually (Enter applies it; manual values are
  saved and applied on login on top of the preset), a "Reset" button for each
  setting and a global "Reset all". On/off (0/1) settings are checkboxes;
  "Low / High / Ultra" preset buttons are at the top
- `/fg apply <low|high|ultra>` — apply a preset (reapplied on every login)
- `/fg fog <on|off>` — volumetric fog (`volumeFog`)
- `/fg tweaks` — non-graphics extras: max camera distance, no Lua error popups,
  gamepad off, floating combat text, sparkles on quest items
- `/fg restart` — restart graphics (`RestartGx`, same as the "Apply" button).
  `/reload` does not restart graphics; most settings apply immediately, only a
  few (e.g. texture resolution) need a restart
- `/fg show` — actual CVar values of the current preset (shows what the engine clamped)
- `/fg info` — client version and Interface number
- `/fg probe` — values, defaults and locks of candidate hidden CVars; the result
  is saved to `WTF\Account\<account>\SavedVariables\ForeverGraphics.lua` after
  you exit the game
- `/fg reset` — restore the values saved before the first apply
- `/fg defaults` — reset everything to the engine defaults

## Publishing
Build the archive: `powershell -ExecutionPolicy Bypass -File build.ps1`.
CurseForge step by step (in Russian): [docs/CURSEFORGE.md](docs/CURSEFORGE.md).

## Tags
graphics, graphics-settings, cvar, cvars, video-settings, performance, fps,
visual-quality, render, shadows, fog, volumetric-fog, view-distance,
draw-distance, texture-quality, presets, ultra-settings, camera-zoom,
settings-panel, wow-forever, forever, world-of-warcraft, wow-addon, lua, dx12

local ADDON, ns = ...

-- Строки в коде пишем по-английски, они же ключи перевода. Для русского
-- клиента подставляем перевод, для остальных ключ возвращается как есть
local L = setmetatable({}, { __index = function(_, key) return key end })
ns.L = L

if GetLocale() ~= "ruRU" then return end

-- Core.lua
L["missing in client: "] = "нет в клиенте: "
L["unknown preset: "] = "неизвестный пресет: "
L["applied preset %s"] = "применён пресет %s"
L["/fg fog <on|off>, current volumeFog = "] = "/fg fog <on|off>, сейчас volumeFog = "
L["volumetric fog enabled"] = "объёмный туман включён"
L["volumetric fog disabled"] = "объёмный туман выключен"
L["tweaks applied: camera zoom out, no Lua error popups, no gamepad, damage numbers, sparkles on quest items"] =
    "твики применены: отдаление камеры, без окон ошибок Lua, без геймпада, цифры урона, искры на квестовых предметах"
L["nothing to restore"] = "нечего восстанавливать"
L["original settings restored"] = "исходные настройки восстановлены"
L["%s: engine accepted %s instead of %s"] = "%s: движок принял %s вместо %s"
L["all settings reset to defaults"] = "все настройки сброшены к значениям по умолчанию"
L["RestartGx is unavailable, restart the game"] = "RestartGx недоступен, перезапустите игру"
L["wanted %s"] = "хотели %s"
L["missing"] = "нет"
L["locked"] = "заблокирован"
L["read-only"] = "только чтение"
L["secure"] = "защищён"
L["%s = %s (default %s)%s"] = "%s = %s (по умолч. %s)%s"
L["result saved, after exiting the game it will be in WTF\\Account\\<account>\\SavedVariables\\ForeverGraphics.lua"] =
    "результат сохранён, после выхода из игры он будет в WTF\\Account\\<аккаунт>\\SavedVariables\\ForeverGraphics.lua"
L["client %s (%s), Interface %s, preset: %s"] = "клиент %s (%s), Interface %s, пресет: %s"
L["none"] = "нет"
L["/fg — settings window, /fg apply <low|high|ultra>, /fg fog <on|off>, /fg tweaks, /fg restart, /fg show, /fg info, /fg probe, /fg reset, /fg defaults"] =
    "/fg — окно настроек, /fg apply <low|high|ultra>, /fg fog <on|off>, /fg tweaks, /fg restart, /fg show, /fg info, /fg probe, /fg reset, /fg defaults"

-- Panel.lua: названия CVar'ов
L["Texture resolution"] = "Разрешение текстур"
L["View distance"] = "Дальность обзора"
L["Environment detail"] = "Детализация окружения"
L["Ground clutter (slider)"] = "Растительность (ползунок)"
L["Shadow quality"] = "Качество теней"
L["Particle density"] = "Плотность частиц"
L["SSAO"] = "Затенение SSAO"
L["Depth effects"] = "Эффекты глубины"
L["Compute effects"] = "Вычисляемые эффекты"
L["Liquid detail"] = "Детализация воды"
L["Projected textures"] = "Проецируемые текстуры"
L["Texture filtering"] = "Фильтрация текстур"
L["Weather density"] = "Плотность погоды"
L["Sun shafts"] = "Солнечные лучи"
L["Cloud detail"] = "Детализация облаков"
L["Sharpness strength"] = "Сила резкости"
L["Always sharpen"] = "Резкость всегда"
L["Draw distance"] = "Дальность прорисовки"
L["Horizon start"] = "Начало горизонта"
L["Terrain LOD"] = "LOD ландшафта"
L["Building LOD"] = "LOD зданий"
L["Creature LOD"] = "LOD существ"
L["Small object culling"] = "Отсечение мелких объектов"
L["Object fade"] = "Исчезновение объектов"
L["Doodad LOD"] = "LOD декораций"
L["Grass density"] = "Густота травы"
L["Grass fade start"] = "Начало исчезновения травы"
L["Grass distance"] = "Дальность травы"
L["Volumetric fog"] = "Объёмный туман"
L["Camera zoom out"] = "Отдаление камеры"
L["Lua error popups"] = "Окна ошибок Lua"
L["Gamepad"] = "Геймпад"
L["Damage numbers"] = "Цифры урона"
L["Sparkles on quest items"] = "Искры на квестовых предметах"

-- Panel.lua: интерфейс
L["Low"] = "Низкий"
L["High"] = "Высокий"
L["Ultra"] = "Ультра"
L["Enter a value and press Enter. Default value on the right. Greyed out: settings missing in the client."] =
    "Введите значение и нажмите Enter. Справа — значение по умолчанию. Серым — параметры, которых нет в клиенте."
L["Reset all ForeverGraphics settings to defaults?"] = "Сбросить все настройки ForeverGraphics к значениям по умолчанию?"
L["Apply the \"%s\" preset? Manually entered values will be replaced."] =
    "Применить пресет «%s»? Значения, введённые вручную, будут заменены."
L["Reset all"] = "Сбросить всё"
L["Apply"] = "Применить"
L["Restart graphics"] = "Перезапуск графики"
L["Only needed for some settings, such as texture resolution. The screen will flicker for a second."] =
    "Нужен только для части настроек, например разрешения текстур. Экран на секунду мигнёт."
L["Preset:"] = "Пресет:"
L["Reset"] = "Сброс"
L["+ manual changes"] = "+ ручные изменения"
L["not selected"] = "не выбран"
L["/ on"] = "/ вкл"
L["/ off"] = "/ выкл"

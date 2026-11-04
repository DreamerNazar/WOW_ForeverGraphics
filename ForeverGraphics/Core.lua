local ADDON, ns = ...

-- Клиент WoW Forever (1.60.x) работает на современном движке, поэтому
-- используем C_CVar, а для старых сборок оставляем глобальные функции
local GetCVar = C_CVar and C_CVar.GetCVar or GetCVar
local SetCVar = C_CVar and C_CVar.SetCVar or SetCVar
local GetCVarDefault = C_CVar and C_CVar.GetCVarDefault or GetCVarDefault
ns.GetCVar, ns.GetCVarDefault = GetCVar, GetCVarDefault

-- Пресеты задаются списком, а не таблицей: порядок важен, т.к. ползунки
-- graphics* сами переписывают низкоуровневые CVar'ы, и наши тонкие
-- настройки должны идти после них. Значения сверх допустимых движок
-- обрезает сам, реально применённое значение видно в /fg show.
local PRESETS = {
    low = {
        { "graphicsViewDistance", 3 },
        { "graphicsEnvironmentDetail", 3 },
        { "graphicsGroundClutter", 2 },
        { "graphicsShadowQuality", 1 },
        { "graphicsParticleDensity", 2 },
        { "graphicsSSAO", 0 },
        { "graphicsDepthEffects", 0 },
        { "graphicsComputeEffects", 0 },
        { "graphicsLiquidDetail", 1 },
        { "textureFilteringMode", 2 },
        { "weatherDensity", 0 },
        { "sunShafts", 0 },
    },
    high = {
        { "graphicsTextureResolution", 2 },
        { "graphicsViewDistance", 8 },
        { "graphicsEnvironmentDetail", 8 },
        { "graphicsGroundClutter", 8 },
        { "graphicsShadowQuality", 4 },
        { "graphicsParticleDensity", 4 },
        { "graphicsSSAO", 3 },
        { "graphicsDepthEffects", 2 },
        { "graphicsComputeEffects", 3 },
        { "graphicsLiquidDetail", 2 },
        { "graphicsProjectedTextures", 1 },
        { "textureFilteringMode", 5 },
        { "weatherDensity", 2 },
        { "sunShafts", 1 },
        { "ResampleSharpness", 0.2 },
        { "ResampleAlwaysSharpen", 1 },
        { "groundEffectDensity", 128 },
        { "groundEffectDist", 200 },
    },
    -- Максимум меню плюс то, чего в меню нет: дальность прорисовки,
    -- LOD объектов/ландшафта, плотность травы
    ultra = {
        { "graphicsTextureResolution", 2 },
        { "graphicsViewDistance", 10 },
        { "graphicsEnvironmentDetail", 10 },
        { "graphicsGroundClutter", 10 },
        { "graphicsShadowQuality", 5 },
        { "graphicsParticleDensity", 5 },
        { "graphicsSSAO", 4 },
        { "graphicsDepthEffects", 3 },
        { "graphicsComputeEffects", 4 },
        { "graphicsLiquidDetail", 3 },
        { "graphicsProjectedTextures", 1 },
        { "textureFilteringMode", 5 },
        { "weatherDensity", 3 },
        { "sunShafts", 2 },
        { "SkyCloudLOD", 3 },
        { "ResampleSharpness", 0.2 },
        { "ResampleAlwaysSharpen", 1 },
        { "farclip", 10000 },
        { "horizonStart", 4000 },
        { "terrainLodDist", 650 },
        { "wmoLodDist", 650 },
        { "entityLodDist", 100 },
        { "lodObjectCullSize", 0 },
        { "lodObjectFadeScale", 150 },
        { "doodadLodScale", 150 },
        -- Трава: значения из сообщества, стандарт groundEffectDensity = 48
        { "groundEffectDensity", 256 },
        { "groundEffectFade", 370 },
        { "groundEffectDist", 500 },
    },
}
ns.PRESETS = PRESETS

-- Не графика, но полезные мелочи; включаются отдельно через /fg tweaks
local TWEAKS = {
    { "cameraDistanceMaxZoomFactor", 2.6 },
    { "scriptErrors", 0 },
    { "GamePadEnable", 0 },
    { "floatingCombatTextCombatDamage_v2", 1 },
    { "outlineModeShowLootEffectWhenDisabled", 1 },
}

-- Всё, что аддон может поменять, без повторов и в порядке показа в окне
local CVARS = {}
do
    local seen = {}
    for _, list in ipairs({ PRESETS.ultra, PRESETS.high, PRESETS.low, { { "volumeFog" } }, TWEAKS }) do
        for _, entry in ipairs(list) do
            if not seen[entry[1]] then
                seen[entry[1]] = true
                CVARS[#CVARS + 1] = entry[1]
            end
        end
    end
end
ns.CVARS = CVARS

-- Кандидаты, которых нет в меню: найдены в строках Wow.exe, но допустимые
-- значения и эффект надо выяснять в игре через /fg probe
local PROBE = {
    "shadowTextureSize", "shadowNumCascades", "shadowBlendCascades", "shadowSoft", "shadowRt", "shadowMode",
    "worldBaseMip", "terrainMipLevel", "componentTextureLevel", "lodBias", "MSAAAlphaTest", "MSAAQuality",
    "maxLightCount", "maxLightDist", "volumeFogLevel", "volumeFogInterior", "bloomEnable", "bloomUserMult",
    "skyNoiseStrength", "ffxGlow", "ffxDeath", "ffxNether",
    "reflectionMode", "reflectionDownscale", "rippleDetail", "waterDetail",
    "lodObjectMinSize", "lodObjectSizeScale", "lodObjectCullDist", "entityLodOffset", "wmoLodDistScale",
    "terrainLodDiv", "horizonClip",
    "cameraFov", "cameraBobbing", "cameraTerrainTilt",
    "particleMTDensity", "physicsLevel", "worldPreloadNonCritical", "RenderScale", "ffxAntiAliasingMode",
}

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" .. ADDON .. "|r: " .. msg)
end
ns.Print = Print

-- Обновляет окно настроек, если оно уже создано
local function Changed()
    if ns.RefreshPanel then ns.RefreshPanel() end
end

local function BackupOnce()
    if ForeverGraphicsDB.backup then return end
    local backup = {}
    for _, cvar in ipairs(CVARS) do
        backup[cvar] = GetCVar(cvar)
    end
    ForeverGraphicsDB.backup = backup
end

-- skip — CVar'ы, которые пользователь сбросил вручную и которые не надо трогать
local function SetList(list, skip)
    BackupOnce()
    local missing = {}
    for _, entry in ipairs(list) do
        local cvar, value = entry[1], entry[2]
        -- GetCVar возвращает nil для CVar'ов, которых нет в этой сборке
        if GetCVar(cvar) == nil then
            missing[#missing + 1] = cvar
        elseif not (skip and skip[cvar]) then
            SetCVar(cvar, value)
        end
    end
    if #missing > 0 then
        Print("нет в клиенте: " .. table.concat(missing, ", "))
    end
end

local function Apply(name, quiet)
    local preset = PRESETS[name]
    if not preset then
        Print("неизвестный пресет: " .. tostring(name))
        return
    end
    -- При ручном применении пресет снова распространяется на все CVar'ы,
    -- при автоматическом на входе — уважаем ручные сбросы
    if quiet then
        SetList(preset, ForeverGraphicsDB.excluded)
    else
        ForeverGraphicsDB.excluded = nil
        ForeverGraphicsDB.custom = nil
        SetList(preset)
    end
    ForeverGraphicsDB.preset = name
    if ForeverGraphicsDB.noFog then
        SetCVar("volumeFog", 0)
    end
    if not quiet then
        Print("применён пресет " .. name)
    end
    Changed()
end

local function Fog(arg)
    if arg ~= "on" and arg ~= "off" then
        Print("/fg fog <on|off>, сейчас volumeFog = " .. tostring(GetCVar("volumeFog")))
        return
    end
    BackupOnce()
    ForeverGraphicsDB.noFog = arg == "off" or nil
    SetCVar("volumeFog", arg == "on" and 1 or 0)
    Print("объёмный туман " .. (arg == "on" and "включён" or "выключен"))
    Changed()
end

local function Tweaks()
    SetList(TWEAKS)
    Print("твики применены: отдаление камеры, без окон ошибок Lua, без геймпада, цифры урона, искры на квестовых предметах")
    Changed()
end

-- Возврат к значениям, которые были до первого применения аддона
local function Restore()
    local backup = ForeverGraphicsDB.backup
    if not backup then
        Print("нечего восстанавливать")
        return
    end
    for cvar, value in pairs(backup) do
        SetCVar(cvar, value)
    end
    ForeverGraphicsDB.backup = nil
    ForeverGraphicsDB.preset = nil
    ForeverGraphicsDB.noFog = nil
    ForeverGraphicsDB.excluded = nil
    ForeverGraphicsDB.custom = nil
    Print("исходные настройки восстановлены")
    Changed()
end

-- Значение, введённое вручную в окне. Запоминается и применяется при входе
-- поверх пресета
function ns.SetValue(cvar, value)
    if GetCVar(cvar) == nil then return end
    BackupOnce()
    SetCVar(cvar, value)
    local actual = GetCVar(cvar)
    if tonumber(actual) ~= tonumber(value) then
        Print(("%s: движок принял %s вместо %s"):format(cvar, tostring(actual), tostring(value)))
    end
    ForeverGraphicsDB.custom = ForeverGraphicsDB.custom or {}
    ForeverGraphicsDB.custom[cvar] = actual
    if ForeverGraphicsDB.excluded then
        ForeverGraphicsDB.excluded[cvar] = nil
    end
    if cvar == "volumeFog" then
        ForeverGraphicsDB.noFog = nil
    end
    Changed()
end

local function ApplyCustom()
    for cvar, value in pairs(ForeverGraphicsDB.custom or {}) do
        if GetCVar(cvar) ~= nil then
            SetCVar(cvar, value)
        end
    end
end

-- Сброс одного CVar'а к заводскому значению движка
function ns.ResetToDefault(cvar)
    local default = GetCVarDefault(cvar)
    if default == nil then return end
    SetCVar(cvar, default)
    if cvar == "volumeFog" then
        ForeverGraphicsDB.noFog = nil
    end
    if ForeverGraphicsDB.custom then
        ForeverGraphicsDB.custom[cvar] = nil
    end
    -- Иначе пресет вернёт значение при следующем входе
    ForeverGraphicsDB.excluded = ForeverGraphicsDB.excluded or {}
    ForeverGraphicsDB.excluded[cvar] = true
    Changed()
end

function ns.ResetAllToDefault()
    for _, cvar in ipairs(CVARS) do
        local default = GetCVarDefault(cvar)
        if default ~= nil then
            SetCVar(cvar, default)
        end
    end
    ForeverGraphicsDB.preset = nil
    ForeverGraphicsDB.noFog = nil
    ForeverGraphicsDB.excluded = nil
    ForeverGraphicsDB.custom = nil
    Print("все настройки сброшены к значениям по умолчанию")
    Changed()
end

function ns.RestartGraphics()
    if RestartGx then
        RestartGx()
    else
        Print("RestartGx недоступен, перезапустите игру")
    end
end

-- Показывает фактические значения: так видно, где движок обрезал пресет
local function Show()
    local preset = PRESETS[ForeverGraphicsDB.preset or "ultra"]
    for _, entry in ipairs(preset) do
        local cvar, wanted = entry[1], entry[2]
        local actual = GetCVar(cvar)
        local mark = (actual and tonumber(actual) == tonumber(wanted)) and "" or " |cffff6060(хотели " .. wanted .. ")|r"
        Print(cvar .. " = " .. tostring(actual) .. mark)
    end
end

-- Выводит и сохраняет в SavedVariables всё про CVar'ы-кандидаты и CVar'ы
-- аддона: после выхода из игры файл ForeverGraphics.lua можно разобрать целиком
local function Probe()
    local version, build, _, interface = GetBuildInfo()
    local result = { client = ("%s (%s), Interface %s"):format(version, build, interface), cvars = {} }
    local function ProbeOne(cvar, show)
        local info
        if C_CVar and C_CVar.GetCVarInfo then
            local value, default, account, character, locked, secure, readOnly = C_CVar.GetCVarInfo(cvar)
            if value ~= nil then
                info = { value = value, default = default, locked = locked or nil, secure = secure or nil, readOnly = readOnly or nil }
            end
        elseif GetCVar(cvar) ~= nil then
            info = { value = GetCVar(cvar), default = GetCVarDefault and GetCVarDefault(cvar) }
        end
        result.cvars[cvar] = info or false
        if not show then return end
        if not info then
            Print("|cff808080" .. cvar .. ": нет|r")
        else
            local flags = (info.locked and " |cffff6060заблокирован|r" or "") ..
                (info.readOnly and " |cffff6060только чтение|r" or "") ..
                (info.secure and " |cffffd100защищён|r" or "")
            Print(("%s = %s (по умолч. %s)%s"):format(cvar, tostring(info.value), tostring(info.default), flags))
        end
    end
    for _, cvar in ipairs(PROBE) do
        ProbeOne(cvar, true)
    end
    -- CVar'ы аддона только сохраняем, чтобы не засорять чат
    for _, cvar in ipairs(CVARS) do
        if result.cvars[cvar] == nil then
            ProbeOne(cvar, false)
        end
    end
    ForeverGraphicsDB.probe = result
    Print("результат сохранён, после выхода из игры он будет в WTF\\Account\\<аккаунт>\\SavedVariables\\ForeverGraphics.lua")
end

local function Info()
    local version, build, _, interface = GetBuildInfo()
    Print(("клиент %s (%s), Interface %s, пресет: %s"):format(
        version, build, interface, ForeverGraphicsDB.preset or "нет"))
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON then return end
        ForeverGraphicsDB = ForeverGraphicsDB or {}
        self:UnregisterEvent("ADDON_LOADED")
    else
        -- Часть CVar'ов (farclip, LOD) не сохраняется в Config.wtf или
        -- перезаписывается ползунками при входе, поэтому повторяем пресет
        if ForeverGraphicsDB.preset then
            Apply(ForeverGraphicsDB.preset, true)
        elseif ForeverGraphicsDB.noFog then
            SetCVar("volumeFog", 0)
        end
        ApplyCustom()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

SLASH_FOREVERGRAPHICS1 = "/fg"
SlashCmdList.FOREVERGRAPHICS = function(msg)
    local cmd, arg = msg:lower():match("^(%S*)%s*(.-)$")
    if cmd == "" then
        ns.OpenPanel()
    elseif cmd == "apply" then
        Apply(arg)
    elseif cmd == "reset" then
        Restore()
    elseif cmd == "defaults" then
        ns.ResetAllToDefault()
    elseif cmd == "restart" then
        ns.RestartGraphics()
    elseif cmd == "show" then
        Show()
    elseif cmd == "info" then
        Info()
    elseif cmd == "probe" then
        Probe()
    elseif cmd == "fog" then
        Fog(arg)
    elseif cmd == "tweaks" then
        Tweaks()
    else
        Print("/fg — окно настроек, /fg apply <low|high|ultra>, /fg fog <on|off>, /fg tweaks, /fg restart, /fg show, /fg info, /fg probe, /fg reset, /fg defaults")
    end
end

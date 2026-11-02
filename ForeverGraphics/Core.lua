local ADDON = "ForeverGraphics"

-- Пресеты графических CVar'ов клиента 3.3.5a
local PRESETS = {
    low = {
        farclip = 777, groundEffectDensity = 16, groundEffectDist = 70,
        environmentDetail = 0.5, particleDensity = 0.3, weatherDensity = 0,
        shadowLevel = 1, extShadowQuality = 0, SkyCloudLOD = 0, ffxGlow = 0,
    },
    high = {
        farclip = 1277, groundEffectDensity = 128, groundEffectDist = 140,
        environmentDetail = 1.5, particleDensity = 1, weatherDensity = 3,
        shadowLevel = 0, extShadowQuality = 4, SkyCloudLOD = 2, ffxGlow = 1,
    },
    ultra = {
        farclip = 1600, groundEffectDensity = 256, groundEffectDist = 300,
        environmentDetail = 2, particleDensity = 1, weatherDensity = 3,
        shadowLevel = 0, extShadowQuality = 5, SkyCloudLOD = 3, ffxGlow = 1,
        projectedTextures = 1,
    },
}

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" .. ADDON .. "|r: " .. msg)
end

local function Apply(name)
    local preset = PRESETS[name]
    if not preset then
        Print("неизвестный пресет: " .. tostring(name))
        return
    end
    -- Запоминаем исходные значения один раз, чтобы /fg reset мог их вернуть
    if not ForeverGraphicsDB.backup then
        ForeverGraphicsDB.backup = {}
        for _, p in pairs(PRESETS) do
            for cvar in pairs(p) do
                ForeverGraphicsDB.backup[cvar] = ForeverGraphicsDB.backup[cvar] or GetCVar(cvar)
            end
        end
    end
    for cvar, value in pairs(preset) do
        SetCVar(cvar, value)
    end
    ForeverGraphicsDB.preset = name
    Print("применён пресет " .. name .. " (часть настроек вступит в силу после /reload или перезапуска)")
end

local function Reset()
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
    Print("исходные настройки восстановлены")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 ~= ADDON then return end
    ForeverGraphicsDB = ForeverGraphicsDB or {}
    self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_FOREVERGRAPHICS1 = "/fg"
SlashCmdList.FOREVERGRAPHICS = function(msg)
    local cmd, arg = msg:lower():match("^(%S*)%s*(.-)$")
    if cmd == "apply" then
        Apply(arg)
    elseif cmd == "reset" then
        Reset()
    else
        Print("/fg apply <low|high|ultra>, /fg reset")
    end
end

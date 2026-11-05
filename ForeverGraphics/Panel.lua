local ADDON, ns = ...
local L = ns.L

local LABELS = {
    graphicsTextureResolution = L["Texture resolution"],
    graphicsViewDistance = L["View distance"],
    graphicsEnvironmentDetail = L["Environment detail"],
    graphicsGroundClutter = L["Ground clutter (slider)"],
    graphicsShadowQuality = L["Shadow quality"],
    graphicsParticleDensity = L["Particle density"],
    graphicsSSAO = L["SSAO"],
    graphicsDepthEffects = L["Depth effects"],
    graphicsComputeEffects = L["Compute effects"],
    graphicsLiquidDetail = L["Liquid detail"],
    graphicsProjectedTextures = L["Projected textures"],
    textureFilteringMode = L["Texture filtering"],
    weatherDensity = L["Weather density"],
    sunShafts = L["Sun shafts"],
    SkyCloudLOD = L["Cloud detail"],
    ResampleSharpness = L["Sharpness strength"],
    ResampleAlwaysSharpen = L["Always sharpen"],
    farclip = L["Draw distance"],
    horizonStart = L["Horizon start"],
    terrainLodDist = L["Terrain LOD"],
    wmoLodDist = L["Building LOD"],
    entityLodDist = L["Creature LOD"],
    lodObjectCullSize = L["Small object culling"],
    lodObjectFadeScale = L["Object fade"],
    doodadLodScale = L["Doodad LOD"],
    groundEffectDensity = L["Grass density"],
    groundEffectFade = L["Grass fade start"],
    groundEffectDist = L["Grass distance"],
    volumeFog = L["Volumetric fog"],
    cameraDistanceMaxZoomFactor = L["Camera zoom out"],
    scriptErrors = L["Lua error popups"],
    GamePadEnable = L["Gamepad"],
    floatingCombatTextCombatDamage_v2 = L["Damage numbers"],
    outlineModeShowLootEffectWhenDisabled = L["Sparkles on quest items"],
}

local ROW_HEIGHT = 26

-- "1.000000" -> "1", чтобы числа помещались в поле
local function Format(value)
    local n = tonumber(value)
    if n then return ("%g"):format(n) end
    return tostring(value)
end

local function Same(a, b)
    local na, nb = tonumber(a), tonumber(b)
    if na and nb then return math.abs(na - nb) < 1e-6 end
    return a == b
end

-- Переключатели 0/1 показываем галочкой вместо поля ввода
local BOOLEAN = {
    graphicsProjectedTextures = true,
    ResampleAlwaysSharpen = true,
    volumeFog = true,
    scriptErrors = true,
    GamePadEnable = true,
    floatingCombatTextCombatDamage_v2 = true,
    outlineModeShowLootEffectWhenDisabled = true,
}

local PRESET_BUTTONS = {
    { "low", L["Low"] },
    { "high", L["High"] },
    { "ultra", L["Ultra"] },
}

local panel = CreateFrame("Frame")
panel.name = ADDON

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(ADDON)

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText(L["Enter a value and press Enter. Default value on the right. Greyed out: settings missing in the client."])

StaticPopupDialogs.FOREVERGRAPHICS_RESET_ALL = {
    text = L["Reset all ForeverGraphics settings to defaults?"],
    button1 = YES,
    button2 = NO,
    OnAccept = function() ns.ResetAllToDefault() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Пресет перезаписывает ручные значения, поэтому при их наличии спрашиваем
StaticPopupDialogs.FOREVERGRAPHICS_APPLY_PRESET = {
    text = L["Apply the \"%s\" preset? Manually entered values will be replaced."],
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, preset) ns.Apply(preset) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local resetAll = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetAll:SetSize(140, 22)
resetAll:SetPoint("TOPRIGHT", -16, -14)
resetAll:SetText(L["Reset all"])
resetAll:SetScript("OnClick", function()
    StaticPopup_Show("FOREVERGRAPHICS_RESET_ALL")
end)

-- /reload графику не перезапускает: большинство CVar'ов применяются сразу,
-- а тем, что требуют пересоздания устройства (текстуры), нужен RestartGx
local apply = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
apply:SetSize(140, 22)
apply:SetPoint("RIGHT", resetAll, "LEFT", -8, 0)
apply:SetText(L["Apply"])
apply:SetScript("OnClick", ns.RestartGraphics)
apply:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText(L["Restart graphics"])
    GameTooltip:AddLine(L["Only needed for some settings, such as texture resolution. The screen will flicker for a second."], 1, 1, 1, true)
    GameTooltip:Show()
end)
apply:SetScript("OnLeave", GameTooltip_Hide)

local presetLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
presetLabel:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -14)
presetLabel:SetText(L["Preset:"])

local presetButtons = {}
local anchor = presetLabel
for _, entry in ipairs(PRESET_BUTTONS) do
    local preset, text = entry[1], entry[2]
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(90, 22)
    button:SetPoint("LEFT", anchor, "RIGHT", anchor == presetLabel and 10 or 6, 0)
    button:SetText(text)
    button:SetScript("OnClick", function()
        if next(ForeverGraphicsDB.custom or {}) then
            local dialog = StaticPopup_Show("FOREVERGRAPHICS_APPLY_PRESET", text)
            if dialog then dialog.data = preset end
        else
            ns.Apply(preset)
        end
    end)
    button.preset = preset
    presetButtons[#presetButtons + 1] = button
    anchor = button
end

local presetCurrent = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
presetCurrent:SetPoint("LEFT", anchor, "RIGHT", 10, 0)

local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", presetLabel, "BOTTOMLEFT", 0, -14)
scroll:SetPoint("BOTTOMRIGHT", -32, 16)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(1, #ns.CVARS * ROW_HEIGHT)
scroll:SetScrollChild(content)
scroll:SetScript("OnSizeChanged", function(self, width)
    content:SetWidth(width)
end)

local function CreateEdit(row, cvar)
    local edit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    edit:SetSize(70, 20)
    edit:SetPoint("RIGHT", row.default, "LEFT", -6, 0)
    edit:SetAutoFocus(false)
    edit:SetJustifyH("RIGHT")
    edit:SetScript("OnEnterPressed", function(self)
        local text = strtrim(self:GetText())
        self:ClearFocus()
        if text ~= "" then
            ns.SetValue(cvar, text)
        end
    end)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    -- Незавершённый ввод не применяем, возвращаем фактическое значение
    edit:SetScript("OnEditFocusLost", function()
        ns.RefreshPanel()
    end)
    return edit
end

local function CreateCheck(row, cvar)
    local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    -- Выравниваем по правому краю места, где у остальных строк поле ввода
    check:SetPoint("RIGHT", row.default, "LEFT", -6, 0)
    check:SetScript("OnClick", function(self)
        ns.SetValue(cvar, self:GetChecked() and 1 or 0)
    end)
    return check
end

local rows = {}
for i, cvar in ipairs(ns.CVARS) do
    local row = CreateFrame("Frame", nil, content)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
    row:SetPoint("RIGHT")

    row.label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    row.label:SetPoint("LEFT", 4, 0)
    row.label:SetText(LABELS[cvar] or cvar)

    row.button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.button:SetSize(70, 20)
    row.button:SetPoint("RIGHT", -4, 0)
    row.button:SetText(L["Reset"])
    row.button:SetScript("OnClick", function()
        ns.ResetToDefault(cvar)
    end)

    row.default = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    row.default:SetPoint("RIGHT", row.button, "LEFT", -8, 0)
    row.default:SetWidth(60)
    row.default:SetJustifyH("LEFT")

    if BOOLEAN[cvar] then
        row.check = CreateCheck(row, cvar)
    else
        row.edit = CreateEdit(row, cvar)
    end

    -- Длинные имена CVar'ов обрезаем, чтобы не залезали под поле ввода
    row.name = row:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    row.name:SetPoint("LEFT", row.label, "RIGHT", 6, 0)
    row.name:SetPoint("RIGHT", row.check or row.edit, "LEFT", -8, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.name:SetText(cvar)

    row.cvar = cvar
    rows[i] = row
end

local function RefreshPresets()
    local current = ForeverGraphicsDB and ForeverGraphicsDB.preset
    for _, button in ipairs(presetButtons) do
        if button.preset == current then
            button:LockHighlight()
        else
            button:UnlockHighlight()
        end
    end
    if current and next(ForeverGraphicsDB.custom or {}) then
        presetCurrent:SetText(L["+ manual changes"])
    elseif current then
        presetCurrent:SetText("")
    else
        presetCurrent:SetText(L["not selected"])
    end
end

local function RefreshRow(row)
    local current = ns.GetCVar(row.cvar)
    local default = ns.GetCVarDefault(row.cvar)
    local control = row.check or row.edit
    if current == nil then
        row.label:SetTextColor(0.5, 0.5, 0.5)
        if row.edit then row.edit:SetText("") end
        if row.check then row.check:SetChecked(false) end
        control:Disable()
        row.default:SetText("")
        row.button:Disable()
        return
    end
    row.label:SetTextColor(1, 1, 1)
    control:Enable()
    local changed = not Same(current, default)
    if row.check then
        row.check:SetChecked(tonumber(current) == 1)
        row.default:SetText(tonumber(default) == 1 and L["/ on"] or L["/ off"])
    else
        -- Не перебиваем то, что пользователь сейчас печатает
        if not row.edit:HasFocus() then
            row.edit:SetText(Format(current))
            row.edit:SetCursorPosition(0)
        end
        -- Изменённые значения подсвечиваем, чтобы было видно, что сбрасывать
        if changed then
            row.edit:SetTextColor(0.2, 1, 0.6)
        else
            row.edit:SetTextColor(1, 1, 1)
        end
        row.default:SetText("/ " .. Format(default))
    end
    row.button:SetEnabled(changed)
end

function ns.RefreshPanel()
    if not panel:IsVisible() then return end
    RefreshPresets()
    for _, row in ipairs(rows) do
        RefreshRow(row)
    end
end
panel:SetScript("OnShow", ns.RefreshPanel)

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, ADDON)
    Settings.RegisterAddOnCategory(category)
    ns.OpenPanel = function()
        Settings.OpenToCategory(category:GetID())
    end
else
    InterfaceOptions_AddCategory(panel)
    ns.OpenPanel = function()
        -- Старый интерфейс с первого раза открывает не ту страницу
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end

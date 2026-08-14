-- ============================================================================
-- SlotMachine - Minimap-Knopf
-- ============================================================================
--
-- Bewusst ohne LibDBIcon gebaut, aus demselben Grund wie das ganze Add-on ohne
-- Ace3 auskommt: die Grundmuster selbst verstehen. Ein Minimap-Knopf ist rund
-- achtzig Zeilen, eine Bibliothek dafuer waere mehr Abhaengigkeit als Nutzen.
--
-- Die Position wird als WINKEL gespeichert, nicht als Koordinate. Die Minimap
-- ist rund, der Knopf sitzt auf ihrem Rand. Ein Winkel bleibt auch dann
-- richtig, wenn die Minimap ihre Groesse oder Position aendert, ein x/y-Paar
-- nicht.

local AddonName, ns = ...

local ICON = "Interface\\Icons\\INV_Misc_Bag_10"

-- Abstand vom Mittelpunkt der Minimap.
--
-- Frueher stand hier fest 80, was zur Standard-Minimap passt. Bei ersetzten
-- Minimaps wie der von EllesmereUI stimmt das nicht: Ist die Karte breiter,
-- liegt der Knopf mitten darauf und verschwindet hinter dem Kartenmaterial.
-- Deshalb wird der Radius aus der tatsaechlichen Groesse abgeleitet.
local function Radius()
    local w = 140
    pcall(function() w = Minimap:GetWidth() or 140 end)
    return (w / 2) + 12
end

local btn = CreateFrame("Button", "SlotMachineMinimapButton", Minimap)
btn:SetSize(31, 31)
-- Ueber der Minimap, nicht darin. MEDIUM reichte bei ersetzten Minimaps nicht
-- immer aus, deren eigene Elemente lagen teilweise darueber.
btn:SetFrameStrata("HIGH")
btn:SetFrameLevel(20)
btn:RegisterForClicks("AnyUp")
btn:RegisterForDrag("LeftButton")
btn:SetMovable(true)

local icon = btn:CreateTexture(nil, "BACKGROUND")
icon:SetSize(20, 20)
icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
icon:SetTexture(ICON)
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)   -- Blizzard-Rand wegschneiden

local border = btn:CreateTexture(nil, "OVERLAY")
border:SetSize(53, 53)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
highlight:SetSize(31, 31)
highlight:SetPoint("CENTER")
highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
highlight:SetBlendMode("ADD")

local function Place(angle)
    local rad = math.rad(angle)
    local r = Radius()
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", r * math.cos(rad), r * math.sin(rad))
end

-- Ziehen: Der Winkel ergibt sich aus der Cursorposition relativ zur Mitte der
-- Minimap. Skalierung einrechnen, sonst springt der Knopf bei skalierter UI.
btn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale  = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        local angle = math.deg(math.atan2(py - my, px - mx))
        SlotMachineDB.minimapAngle = angle
        Place(angle)
    end)
end)

btn:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

btn:SetScript("OnClick", function(_, button)
    if button == "RightButton" and ns.UI and ns.UI.ToggleOptions then
        ns.UI:ToggleOptions()
    elseif ns.UI and ns.UI.Toggle then
        ns.UI:Toggle()
    end
end)

btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("SlotMachine")
    GameTooltip:AddLine("Linksklick öffnet den Loot-Planer", 0.85, 0.82, 0.76)
    GameTooltip:AddLine("Rechtsklick öffnet die Einstellungen", 0.85, 0.82, 0.76)
    GameTooltip:AddLine("Ziehen verschiebt den Knopf", 0.65, 0.63, 0.58)
    GameTooltip:Show()
end)
btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

ns.Minimap = {}

-- Init laeuft ueber ADDON_LOADED. Kommt dort etwas dazwischen, gab es bisher
-- keinen zweiten Versuch und der Knopf blieb unsichtbar, weil er ohne
-- SetPoint gar nicht platziert war. Deshalb sichert ein eigener Event-Frame
-- zusaetzlich bei PLAYER_ENTERING_WORLD nach.
local placed = false

function ns.Minimap:Init()
    -- SavedVariables selbst absichern, nicht auf die Ladereihenfolge verlassen
    SlotMachineDB = SlotMachineDB or {}
    Place(tonumber(SlotMachineDB.minimapAngle) or 200)
    if SlotMachineDB.hideMinimap then btn:Hide() else btn:Show() end
    placed = true
end

local guard = CreateFrame("Frame")
guard:RegisterEvent("PLAYER_ENTERING_WORLD")
guard:SetScript("OnEvent", function(self)
    if not placed then ns.Minimap:Init() end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

function ns.Minimap:Toggle()
    SlotMachineDB.hideMinimap = not SlotMachineDB.hideMinimap
    if SlotMachineDB.hideMinimap then btn:Hide() else btn:Show() end
end

function ns.Minimap:IsHidden()
    return SlotMachineDB.hideMinimap and true or false
end

-- Diagnose. Sagt, ob der Knopf existiert, wo er sitzt und wie gross die
-- Minimap ist. Bei ersetzten Minimaps ist genau das die entscheidende Frage.
function ns.Minimap:Debug()
    local say = (ns.Scanner and ns.Scanner.Say) or print
    say("Minimap-Knopf:")
    say("   existiert: " .. tostring(btn ~= nil))
    say("   sichtbar:  " .. tostring(btn and btn:IsShown()))
    say("   versteckt per Einstellung: " .. tostring(SlotMachineDB.hideMinimap and true or false))
    local w, h = 0, 0
    pcall(function() w, h = Minimap:GetWidth(), Minimap:GetHeight() end)
    say(string.format("   Minimap: %.0f x %.0f, Radius %.0f", w, h, Radius()))
    say("   Winkel: " .. tostring(SlotMachineDB.minimapAngle))
    local p, _, _, x, y = nil, nil, nil, 0, 0
    pcall(function() p, _, _, x, y = btn:GetPoint() end)
    say(string.format("   Position: %s bei %.0f / %.0f", tostring(p), x or 0, y or 0))
    say("   Parent: " .. tostring(btn and btn:GetParent() and btn:GetParent():GetName()))
    -- Notausgang: in die Bildschirmmitte setzen, dann ist er garantiert da
    say("Mit |cffffd100/sm minimap reset|r springt er auf eine sichere Position.")
end

-- Setzt Winkel und Position zurueck. Hilft, wenn der Knopf durch eine
-- ersetzte Minimap an einer unerreichbaren Stelle gelandet ist.
function ns.Minimap:Reset()
    SlotMachineDB.minimapAngle = 200
    SlotMachineDB.hideMinimap = nil
    Place(200)
    btn:Show()
end

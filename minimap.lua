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

local RADIUS   = 80      -- Abstand vom Mittelpunkt, Standard fuer runde Minimap
local ICON     = "Interface\\Icons\\INV_Misc_Bag_10"

local btn = CreateFrame("Button", "SlotMachineMinimapButton", Minimap)
btn:SetSize(31, 31)
btn:SetFrameStrata("MEDIUM")
btn:SetFrameLevel(8)
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
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER",
        RADIUS * math.cos(rad), RADIUS * math.sin(rad))
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

function ns.Minimap:Init()
    Place(tonumber(SlotMachineDB.minimapAngle) or 200)
    if SlotMachineDB.hideMinimap then btn:Hide() else btn:Show() end
end

function ns.Minimap:Toggle()
    SlotMachineDB.hideMinimap = not SlotMachineDB.hideMinimap
    if SlotMachineDB.hideMinimap then btn:Hide() else btn:Show() end
end

function ns.Minimap:IsHidden()
    return SlotMachineDB.hideMinimap and true or false
end

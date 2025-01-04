-- Default settings
local defaultSettings = {
    point = "CENTER",
    relativeTo = nil,
    relativePoint = "CENTER",
    xOfs = 0,
    yOfs = 0,
    width = 300,
    height = 200,
    alpha = 0.8,
    closed = false,
}

-- Initialize or load saved settings
if not BaseFrameSettings then
    BaseFrameSettings = {} -- Create the SavedVariable if it doesn't exist
end

-- Merge saved settings with defaults
for key, value in pairs(defaultSettings) do
    if BaseFrameSettings[key] == nil then
        BaseFrameSettings[key] = value
    end
end

-- Load the frame function from another file
GetStartFrame = GetStartFrame or nil

local MyAddon = CreateFrame("Frame")

MyAddon:RegisterEvent("PLAYER_LOGIN")

MyAddon:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Pass settings to the frame creation function
        local frame = GetStartFrame(BaseFrameSettings)

        if BaseFrameSettings.closed then
            frame:Hide()
        else
            frame:Show()
        end -- Show the frame when the player logs in

        -- Slash command to toggle frame visibility
        SLASH_ZONELORE1 = "/zonelore"
        SlashCmdList["ZONELORE"] = function()
            if frame:IsShown() then
                frame:Hide()
                BaseFrameSettings.closed = true
            else
                frame:Show()
                BaseFrameSettings.closed = false
            end
        end

        local addon = LibStub("AceAddon-3.0"):NewAddon("ZoneLore")
        local zoneloreLDB = LibStub("LibDataBroker-1.1"):NewDataObject("ZoneLore", {
            type = "data source",
            text = "ZoneLore",
            icon = "Interface\\AddOns\\ZoneLore\\icons\\MinimapIcon.PNG",
            OnTooltipShow = function(tt)
                tt:AddLine("ZoneLore")
                tt:AddLine("|cFF8B8000Left click|r or command |cFF8B8000/zonelore|r: show/hide main window",.8,.8,.8,1)
                 end,
            OnClick = function()
                if frame:IsShown() then
                    frame:Hide()
                    BaseFrameSettings.closed = true
                else
                    frame:Show()
                    BaseFrameSettings.closed = false
                end
            end,
        })
        local icon = LibStub("LibDBIcon-1.0")

        function addon:OnInitialize()
            -- Assuming you have a ## SavedVariables: ZLoreDB line in your TOC
            self.db = LibStub("AceDB-3.0"):New("ZLoreDB", {
                profile = {
                    minimap = {
                        hide = false,
                    },
                },
            })
            icon:Register("ZoneLore", zoneloreLDB, self.db.profile.minimap)
        end
    end
end)


function GetStartFrame(settings)
    -- Create a new frame
    local MainFrame = CreateFrame("Frame", "MainFrame", UIParent, "BasicFrameTemplate")
    MainFrame:SetSize(settings.width, settings.height)
    MainFrame:SetPoint(settings.point, settings.relativeTo, settings.relativePoint, settings.xOfs, settings.yOfs)
    MainFrame:SetResizable(true)
    MainFrame:SetAlpha(settings.alpha)

    -- Enable mouse interaction
    MainFrame:EnableMouse(true)
    MainFrame:SetMovable(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetClampedToScreen(true)

    -- Dragging behavior
    MainFrame:SetScript("OnDragStart", function(self)
        if self:IsMovable() then
            self:StartMoving()
        end
    end)

    MainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save the new position
        BaseFrameSettings.point, BaseFrameSettings.relativeTo, BaseFrameSettings.relativePoint,
        BaseFrameSettings.xOfs, BaseFrameSettings.yOfs = self:GetPoint()
    end)

    -- Add a title to the frame
    MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    MainFrame.title:SetPoint("TOP", MainFrame, "TOP", 0, -5)
    MainFrame.title:SetText("ZoneLore")

    -- Add a scrollable text area to the frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, MainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -30, 50)

    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)
    content:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())

    scrollFrame:SetScript("OnSizeChanged", function(self)
        content:SetSize(self:GetWidth(), self:GetHeight())
    end)

    local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    text:SetWidth(content:GetWidth())

    scrollFrame:SetScript("OnSizeChanged", function(self)
        text:SetWidth(self:GetWidth())
    end)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetText("Initializing zone information...")

    -- Function to update text on zone change
    local function UpdateZoneText(zoneKey)
        scrollFrame:SetVerticalScroll(0)
        for _, child in ipairs({ content:GetChildren() }) do
            child:Hide()
        end
        local pretext = ""
        local currentZone = GetZoneText()
        if zoneKey == currentZone then
            pretext = "You are in "
        end
        local zoneLore = DictionaryLookup.GetLore(zoneKey)
        text:SetText(pretext .. ColorFormat(zoneKey, Format.zoneName) .. "\n\n" .. zoneLore)
    end

    -- Function to display the list of zones
    local function ShowZoneList()
        scrollFrame:SetVerticalScroll(0)
        local yOffset = -10

        -- Clear previous content
        text:SetText("")

        local zoneKeys = DictionaryLookup.GetLoreKeys()

        for _, zoneKey in pairs(zoneKeys) do
            local zoneButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
            zoneButton:SetSize(200, 20)
            zoneButton:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
            zoneButton:SetText(zoneKey)
            zoneButton:SetScript("OnClick", function()
                UpdateZoneText(zoneKey)
            end)
            yOffset = yOffset - 30
        end

    end

    -- Register for zone change updates
    MainFrame:RegisterEvent("ZONE_CHANGED")
    MainFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    MainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    MainFrame:SetScript("OnEvent", function(self, event)
        if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
            local zoneName = GetZoneText()
            UpdateZoneText(zoneName)
        end
    end)

    -- Initial update
    local zoneName = GetZoneText()
    UpdateZoneText(zoneName)

    -- Add a resize handle (bottom-right corner)
    local resizeHandle = CreateFrame("Button", nil, MainFrame)
    resizeHandle:SetSize(10, 10)
    resizeHandle:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -5, 5)
    resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeHandle:SetScript("OnMouseDown", function()
        MainFrame:StartSizing("BOTTOMRIGHT")
    end)
    resizeHandle:SetScript("OnMouseUp", function()
        MainFrame:StopMovingOrSizing()
        BaseFrameSettings.width = MainFrame:GetWidth()
        BaseFrameSettings.height = MainFrame:GetHeight()
    end)

    MainFrame:SetScript("OnSizeChanged", function(self, width, height)
        local minWidth, minHeight = 230, 115
        if width < minWidth then
            self:SetWidth(minWidth)
        end
        if height < minHeight then
            self:SetHeight(minHeight)
        end
    end)

    -- Add a button to show the list of zones
    local ListButton = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    ListButton:SetSize(100, 25)
    ListButton:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 10, 10)
    ListButton:SetText("Zone List")
    ListButton:SetScript("OnClick", function ()
        ShowZoneList()
    end)

    -- Add a button to return to the current zone
    local CurrentZoneButton = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    CurrentZoneButton:SetSize(100, 25)
    CurrentZoneButton:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -10, 10)
    CurrentZoneButton:SetText("Current Zone")
    CurrentZoneButton:SetScript("OnClick", function ()
        zoneName = GetZoneText()
        UpdateZoneText(zoneName)
    end)

    return MainFrame
end

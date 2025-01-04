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
    scrollFrame:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -30, 10)

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
    local function UpdateZoneText()
        local zoneName = GetZoneText()
        local zoneLore = DictionaryLookup.GetLore(zoneName)
        text:SetText("Current Zone: " .. zoneName .. "\n\n" .. zoneLore)
    end

    -- Register for zone change updates
    MainFrame:RegisterEvent("ZONE_CHANGED")
    MainFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    MainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    MainFrame:SetScript("OnEvent", function(self, event)
        if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
            UpdateZoneText()
        end
    end)

    -- Initial update
    UpdateZoneText()

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

    return MainFrame
end

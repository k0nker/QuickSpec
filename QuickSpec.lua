local QuickSpec = {}
_G.QuickSpec = QuickSpec

BINDING_HEADER_QUICKSPECFRAME = "QuickSpec"
_G["BINDING_NAME_QSBINDINGINFO"] = "Open/Close QuickSpec"

-- API compatibility for older versions
local GetSpecialization = GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local SetSpecialization = SetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.SetSpecialization)

-- Create the main frame using native Blizzard UI
local QuickSpecFrame = CreateFrame("Frame", "QuickSpecFrame", UIParent, "BackdropTemplate")
QuickSpecFrame:SetSize(160, 127)
QuickSpecFrame:SetPoint("CENTER")
QuickSpecFrame:SetMovable(true)
QuickSpecFrame:EnableMouse(true)
QuickSpecFrame:RegisterForDrag("LeftButton")
QuickSpecFrame:SetScript("OnDragStart", QuickSpecFrame.StartMoving)
QuickSpecFrame:SetScript("OnDragStop", QuickSpecFrame.StopMovingOrSizing)
QuickSpecFrame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
QuickSpecFrame:SetBackdropColor(0, 0, 0, 0.8)
QuickSpecFrame:Hide()

-- Set the frame title
QuickSpecFrame.title = QuickSpecFrame:CreateFontString(nil, "OVERLAY")
QuickSpecFrame.title:SetFontObject("GameFontHighlight")
QuickSpecFrame.title:SetPoint("TOP", QuickSpecFrame, "TOP", 0, -10)
QuickSpecFrame.title:SetText("QuickSpec 2.0")

-- Function to create/recreate the close button
local function CreateCloseButton()
    if QuickSpecFrame.closeButton then
        QuickSpecFrame.closeButton:Hide()
        QuickSpecFrame.closeButton = nil
    end
    
    -- Create close button in top right corner
    QuickSpecFrame.closeButton = CreateFrame("Button", nil, QuickSpecFrame)
    QuickSpecFrame.closeButton:SetSize(16, 16)
    QuickSpecFrame.closeButton:SetPoint("TOPRIGHT", QuickSpecFrame, "TOPRIGHT", -8, -8)
    
    -- Use the actual Blizzard close button textures
    QuickSpecFrame.closeButton:SetNormalTexture("Interface/Buttons/UI-StopButton")
    QuickSpecFrame.closeButton:SetPushedTexture("Interface/Buttons/UI-StopButton")
    QuickSpecFrame.closeButton:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
    

    -- Close button functionality
    QuickSpecFrame.closeButton:SetScript("OnClick", function()
        QuickSpecFrame:Hide()
        -- Clear position and reset to center
        QuickSpecFrame:ClearAllPoints()
        QuickSpecFrame:SetPoint("CENTER")
        -- Reset size to default
        QuickSpecFrame:SetSize(160, 127)
    end)
    
    QuickSpecFrame.closeButton:Show()
end

-- Add to UISpecialFrames so it closes with ESC
tinsert(UISpecialFrames, "QuickSpecFrame")

-- Function to print messages from this addon
function QuickSpec.p(arg)
	print("|CFF008051QuickSpec:|r " .. arg)
end

--for i, v in pairs({"qs", "quickspec"}) do
--	_G["SLASH_QUICKSPEC"..i] = "/"..v
--end

--SlashCmdList.QUICKSPEC = function()
--if not QuickSpecFrame == nil then AceGUI:Release(QuickSpecFrame) else QuickSpec.Execute() end
--if QuickSpecFrame:IsVisible() then QuickSpecFrame:Hide() else QuickSpecFrame:Show() end
--	QuickSpec.Execute(i)
--end

-- Helper function to clear all children from the frame
local function ClearFrameChildren(frame)
	local children = { frame:GetChildren() }
	for _, child in ipairs(children) do
		child:Hide()
		child:SetParent(nil)
	end
end

function QuickSpec.Execute(specArg)
	if specArg == nil then
		if QuickSpecFrame:IsVisible() then
			QuickSpecFrame:Hide()
		else
			-- Clear any existing content
			ClearFrameChildren(QuickSpecFrame)

			local height = 60   -- Base height for frame borders and title
			local yOffset = -30 -- Starting position for content

			-- Get current spec info
			local currSpecName, _, currIcon = select(2, GetSpecializationInfo(GetSpecialization()))

			-- Current Spec Label - centered
			local currentSpecLabel = QuickSpecFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			currentSpecLabel:SetPoint("TOP", QuickSpecFrame, "TOP", 0, yOffset)
			currentSpecLabel:SetText("Current Spec:")
			yOffset = yOffset - 25
			height = height + 25

			-- Current Spec Button - centered
			local currentSpecButton = CreateFrame("Button", nil, QuickSpecFrame)
			currentSpecButton:SetPoint("TOP", QuickSpecFrame, "TOP", 0, yOffset)
			currentSpecButton:SetSize(120, 40)

			-- Current spec icon
			local currentSpecIcon = currentSpecButton:CreateTexture(nil, "ARTWORK")
			currentSpecIcon:SetPoint("LEFT", currentSpecButton, "LEFT", 0, 0)
			currentSpecIcon:SetSize(32, 32)
			currentSpecIcon:SetTexture(currIcon)

			-- Current spec text
			local currentSpecText = currentSpecButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			currentSpecText:SetPoint("LEFT", currentSpecIcon, "RIGHT", 5, 0)
			currentSpecText:SetText("|cFF008051" .. currSpecName .. "|r")

			-- Current spec button functionality
			currentSpecButton:SetScript("OnClick", function()
				QuickSpec.p("Spec is already set to " .. currSpecName .. '.')
				QuickSpecFrame:Hide()
			end)

			-- Hover effects for current spec button
			currentSpecButton:SetScript("OnEnter", function()
				currentSpecButton:SetAlpha(0.8)
			end)
			currentSpecButton:SetScript("OnLeave", function()
				currentSpecButton:SetAlpha(1.0)
			end)

			yOffset = yOffset - 55
			height = height + 55

			-- Choose Spec Label - centered
			local chooseSpecLabel = QuickSpecFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			chooseSpecLabel:SetPoint("TOP", QuickSpecFrame, "TOP", 0, yOffset)
			chooseSpecLabel:SetText("Choose Spec:")
			yOffset = yOffset - 25
			height = height + 25

			-- Create buttons for other specs - arranged horizontally
			local numspecs = GetNumSpecializations()
			local specButtons = {}
			local availableSpecs = {}
			
			-- First, collect all non-current specs
			for i = 1, numspecs do
				local specID, specName, _, icon = GetSpecializationInfo(i)
				if GetSpecialization() ~= i then
					table.insert(availableSpecs, {id = i, name = specName, icon = icon})
				end
			end
			
			-- Calculate horizontal positioning
			local buttonWidth = 50
			local buttonHeight = 50
			local spacing = 10
			local totalWidth = (#availableSpecs * buttonWidth) + ((#availableSpecs - 1) * spacing)
			local startX = -totalWidth / 2 + buttonWidth / 2
			
			-- Adjust frame width to accommodate horizontal layout
			local frameWidth = math.max(160, totalWidth + 40) -- Minimum 160 or fit buttons + padding
			QuickSpecFrame:SetWidth(frameWidth)

			for index, spec in ipairs(availableSpecs) do
				-- Create spec button
				local specButton = CreateFrame("Button", nil, QuickSpecFrame)
				local xPos = startX + ((index - 1) * (buttonWidth + spacing))
				specButton:SetPoint("TOP", QuickSpecFrame, "TOP", xPos, yOffset)
				specButton:SetSize(buttonWidth, buttonHeight)

				-- Spec icon (larger, no text)
				local specIcon = specButton:CreateTexture(nil, "ARTWORK")
				specIcon:SetAllPoints(specButton)
				specIcon:SetTexture(spec.icon)

				-- Button click functionality
				specButton:SetScript("OnClick", function()
					if GetSpecialization() == spec.id then
						QuickSpec.p("Spec is already set to " .. spec.name .. '.')
						QuickSpecFrame:Hide()
					else
						QuickSpec.p("Switching to spec: " .. spec.name .. '.')
						QuickSpecFrame:Hide()
						SetSpecialization(spec.id)
					end
				end)

				-- Hover effects and tooltip
				specButton:SetScript("OnEnter", function(self)
					specButton:SetAlpha(0.8)
					GameTooltip:SetOwner(self, "ANCHOR_TOP")
					GameTooltip:SetText(spec.name)
					GameTooltip:Show()
				end)
				specButton:SetScript("OnLeave", function()
					specButton:SetAlpha(1.0)
					GameTooltip:Hide()
				end)

				specButtons[spec.id] = specButton
			end
			
			-- Add height for the horizontal button row
			height = height + buttonHeight + 10

			-- Set final frame height
			QuickSpecFrame:SetHeight(height + 20) -- Add some padding at bottom
			
			-- Create the close button
			CreateCloseButton()
			
			QuickSpecFrame:Show()
		end
	else
		-- Handle slash command with spec argument
		local currSpecName = select(2, GetSpecializationInfo(GetSpecialization()))
		local currSpecNameString = string.lower(currSpecName or "")
		local specArgString = string.lower(specArg)

		if currSpecNameString == specArgString then
			QuickSpec.p("Spec is already set to " .. currSpecName)
			return
		end

		local numspecs2 = GetNumSpecializations()
		for i = 1, numspecs2 do
			local _, newSpecName = GetSpecializationInfo(i)
			local newSpecNameString = string.lower(newSpecName or "")
			if newSpecNameString == specArgString then
				SetSpecialization(i)
				QuickSpec.p("Switching to spec: " .. newSpecName .. '.')
				return
			end
		end

		QuickSpec.p(specArg .. " is not a valid spec choice")
	end
end

-- Slash Commands

local function QuickSpec_SlashCommandHandler(spec)
	if spec == "" then
		QuickSpec.Execute(nil)
	else
		QuickSpec.Execute(spec)
	end
end

local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")

SLASH_QUICKSPEC1 = "/quickspec";
SLASH_QUICKSPEC2 = "/qs";

Frame:SetScript("OnEvent", function(self, event)
	SlashCmdList["QUICKSPEC"] = QuickSpec_SlashCommandHandler;
end)

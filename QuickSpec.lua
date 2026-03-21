local QuickSpec = {}
_G.QuickSpec = QuickSpec

BINDING_HEADER_QUICKSPECFRAME = "QuickSpec"
_G["BINDING_NAME_QSBINDINGINFO"] = "Open/Close QuickSpec"

-- Fallback for older API versions if needed
local GetSpecialization = GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local SetSpecialization = SetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.SetSpecialization)

-- Main frame setup
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
QuickSpecFrame.title:SetText("QuickSpec")

-- Close button setup
local function CreateCloseButton()
    if QuickSpecFrame.closeButton then
        QuickSpecFrame.closeButton:Hide()
        QuickSpecFrame.closeButton = nil
    end
    
    QuickSpecFrame.closeButton = CreateFrame("Button", nil, QuickSpecFrame)
    QuickSpecFrame.closeButton:SetSize(16, 16)
    QuickSpecFrame.closeButton:SetPoint("TOPRIGHT", QuickSpecFrame, "TOPRIGHT", -8, -8)
    
    local closeTexture = QuickSpecFrame.closeButton:CreateTexture(nil, "ARTWORK")
    closeTexture:SetAllPoints()
    closeTexture:SetTexture("Interface\\AddOns\\QuickSpec\\Assets\\close-button.png")
    closeTexture:SetVertexColor(1, 1, 1, 1)
    
    QuickSpecFrame.closeButton.texture = closeTexture
    
    -- Red tint on hover
    QuickSpecFrame.closeButton:SetScript("OnEnter", function(self)
        self.texture:SetVertexColor(1, 0, 0, 1)
    end)
    QuickSpecFrame.closeButton:SetScript("OnLeave", function(self)
        self.texture:SetVertexColor(1, 1, 1, 1)
    end)

    -- Reset frame position and size when closed
    QuickSpecFrame.closeButton:SetScript("OnClick", function()
        QuickSpecFrame:Hide()
        QuickSpecFrame:ClearAllPoints()
        QuickSpecFrame:SetPoint("CENTER")
        QuickSpecFrame:SetSize(160, 127)
    end)
    
    QuickSpecFrame.closeButton:Show()
end

tinsert(UISpecialFrames, "QuickSpecFrame")

function QuickSpec.p(arg)
	print("|CFF008051QuickSpec:|r " .. arg)
end

-- Persistent spec change message frame
local SpecChangeFrame = CreateFrame("Frame", "QuickSpecChangeFrame", UIParent)
SpecChangeFrame:SetSize(512, 72)
SpecChangeFrame:SetPoint("TOP", UIParent, "TOP", 0, -500)
SpecChangeFrame:SetFrameStrata("DIALOG")
SpecChangeFrame:Hide()

SpecChangeFrame.text = SpecChangeFrame:CreateFontString(nil, "OVERLAY")
SpecChangeFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
SpecChangeFrame.text:SetPoint("CENTER")
SpecChangeFrame.text:SetTextColor(0, 0.5019607843, 0.3176470588, 1)
SpecChangeFrame.text:SetShadowOffset(2, -2)
SpecChangeFrame.text:SetShadowColor(0, 0, 0, 1)

SpecChangeFrame.fadeGroup = SpecChangeFrame:CreateAnimationGroup()
SpecChangeFrame.fade = SpecChangeFrame.fadeGroup:CreateAnimation("Alpha")
SpecChangeFrame.fade:SetFromAlpha(1)
SpecChangeFrame.fade:SetToAlpha(0)
SpecChangeFrame.fade:SetDuration(7)
SpecChangeFrame.fade:SetSmoothing("OUT")
SpecChangeFrame.fade:SetStartDelay(0.5)

SpecChangeFrame.fadeGroup:SetScript("OnFinished", function()
	SpecChangeFrame:Hide()
end)

-- Show raid warning style message
local function ShowSpecChangeMessage(specName)
	-- Stop any existing animation and reset
	SpecChangeFrame.fadeGroup:Stop()
	SpecChangeFrame:SetAlpha(1)
	SpecChangeFrame.text:SetText(specName)
	SpecChangeFrame:Show()
	SpecChangeFrame.fadeGroup:Play()
end

-- Central spec switching function
local function SwitchToSpec(specSlotID, specName)
	if GetSpecialization() == specSlotID then
		QuickSpec.p("Spec is already set to " .. specName .. '.')
		return false
	end
	
	ShowSpecChangeMessage("Switching spec to " .. specName)
	QuickSpec.p("Switching spec to " .. specName .. '.')
	SetSpecialization(specSlotID)
	return true
end

--for i, v in pairs({"qs", "quickspec"}) do
--	_G["SLASH_QUICKSPEC"..i] = "/"..v
--end

--SlashCmdList.QUICKSPEC = function()
--if not QuickSpecFrame == nil then AceGUI:Release(QuickSpecFrame) else QuickSpec.Execute() end
--if QuickSpecFrame:IsVisible() then QuickSpecFrame:Hide() else QuickSpecFrame:Show() end
--	QuickSpec.Execute(i)
--end

local function ClearFrameChildren(frame)
	local children = { frame:GetChildren() }
	for _, child in ipairs(children) do
		child:Hide()
		child:SetParent(nil)
	end
end

local function BuildFrameContent()
	ClearFrameChildren(QuickSpecFrame)

	local height = 60
	local yOffset = -30

	-- Grab player class to build atlas icon names
	local _, playerClass = UnitClass("player")
	playerClass = string.lower(playerClass)

	local currSpecName, _, currIcon = select(2, GetSpecializationInfo(GetSpecialization()))

	-- Show current spec at the top
	local currentSpecButton = CreateFrame("Button", nil, QuickSpecFrame)
	currentSpecButton:SetPoint("TOP", QuickSpecFrame, "TOP", 0, yOffset)
	currentSpecButton:SetSize(120, 40)

	local currentSpecIcon = currentSpecButton:CreateTexture(nil, "ARTWORK")
	currentSpecIcon:SetPoint("TOP", currentSpecButton, "TOP", 0, -2)
	currentSpecIcon:SetSize(32, 32)
	-- Use atlas icons if available, otherwise fall back to default texture
	local atlasName = "spec-icon-" .. playerClass .. "-" .. string.lower(currSpecName):gsub("%s+", "")
	if C_Texture.GetAtlasInfo(atlasName) then
		currentSpecIcon:SetAtlas(atlasName)
	else
		currentSpecIcon:SetTexture(currIcon)
	end

	local currentSpecText = currentSpecButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	currentSpecText:SetPoint("TOP", currentSpecButton, "BOTTOM", 0, 0)
	currentSpecText:SetText("|cFF008051" .. currSpecName .. "|r")

	currentSpecButton:SetScript("OnClick", function()
		QuickSpec.p("Spec is already set to " .. currSpecName .. '.')
		QuickSpecFrame:Hide()
	end)

	currentSpecButton:SetScript("OnEnter", function()
		currentSpecButton:SetAlpha(0.8)
	end)
	currentSpecButton:SetScript("OnLeave", function()
		currentSpecButton:SetAlpha(1.0)
	end)

	yOffset = yOffset - 55
	height = height + 40

	local chooseSpecLabel = QuickSpecFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	chooseSpecLabel:SetPoint("TOP", QuickSpecFrame, "TOP", 0, yOffset)
	chooseSpecLabel:SetText("Choose Spec:")
	yOffset = yOffset - 20
	height = height + 20

	-- Build list of available specs (minus current one)
	local numspecs = GetNumSpecializations()
	local specButtons = {}
	local availableSpecs = {}
	
	for i = 1, numspecs do
		local specID, specName, _, icon = GetSpecializationInfo(i)
		if GetSpecialization() ~= i then
			table.insert(availableSpecs, {id = i, name = specName, icon = icon})
		end
	end
	
	-- Size and position the spec buttons horizontally
	local buttonWidth = 50
	local buttonHeight = 50
	local spacing = 10
	local totalWidth = (#availableSpecs * buttonWidth) + ((#availableSpecs - 1) * spacing)
	local startX = -totalWidth / 2 + buttonWidth / 2
	
	local frameWidth = math.max(160, totalWidth + 40)
	QuickSpecFrame:SetWidth(frameWidth)

	for index, spec in ipairs(availableSpecs) do
		local specButton = CreateFrame("Button", nil, QuickSpecFrame)
		local xPos = startX + ((index - 1) * (buttonWidth + spacing))
		specButton:SetPoint("TOP", QuickSpecFrame, "TOP", xPos, yOffset)
		specButton:SetSize(buttonWidth, buttonHeight)

		local specIcon = specButton:CreateTexture(nil, "ARTWORK")
		specIcon:SetAllPoints(specButton)
		local atlasName = "spec-icon-" .. playerClass .. "-" .. string.lower(spec.name):gsub("%s+", "")
		if C_Texture.GetAtlasInfo(atlasName) then
			specIcon:SetAtlas(atlasName)
		else
			specIcon:SetTexture(spec.icon)
		end
		
		-- Green overlay for hover
		local hoverOverlay = specButton:CreateTexture(nil, "OVERLAY")
		hoverOverlay:SetAllPoints(specButton)
		hoverOverlay:SetColorTexture(0, 0.5, 0.32, 0.3)
		hoverOverlay:Hide()
		
		specButton.hoverOverlay = hoverOverlay

		specButton:SetScript("OnClick", function()
			SwitchToSpec(spec.id, spec.name)
			QuickSpecFrame:Hide()
		end)

		specButton:SetScript("OnEnter", function(self)
			self.hoverOverlay:Show()
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(spec.name)
			GameTooltip:Show()
		end)
		specButton:SetScript("OnLeave", function(self)
			self.hoverOverlay:Hide()
			GameTooltip:Hide()
		end)

		specButtons[spec.id] = specButton
	end
	
	height = height + buttonHeight + 5
	QuickSpecFrame:SetHeight(height + 10)
	
	CreateCloseButton()
end

function QuickSpec.Execute(specArg)
	if specArg == nil then
		if QuickSpecFrame:IsVisible() then
			QuickSpecFrame:Hide()
		else
			BuildFrameContent()
			QuickSpecFrame:Show()
		end
	else
		-- Slash command with spec name argument
		local currSpecName = select(2, GetSpecializationInfo(GetSpecialization()))
		local currSpecNameString = string.lower(currSpecName or "")
		local specArgString = string.lower(specArg)

		local numspecs2 = GetNumSpecializations()
		for i = 1, numspecs2 do
			local _, newSpecName = GetSpecializationInfo(i)
			local newSpecNameString = string.lower(newSpecName or "")
			if newSpecNameString == specArgString then
				SwitchToSpec(i, newSpecName)
				return
			end
		end

		QuickSpec.p(specArg .. " is not a valid spec choice")
	end
end

-- Slash Commands

-- Parse macro conditionals like [mod:ctrl] or [nomod]
local function ParseMacroConditionals(text)
	if not text:match("%[.-%]") then
		return text
	end
	
	local lines = {}
	for line in text:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	
	for _, line in ipairs(lines) do
		local conditional, spec = line:match("^%[(.-)%]%s*(.+)$")
		if conditional and spec then
			if conditional == "nomod" then
				if not IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown() then
					return spec:trim()
				end
			else
				local condType, condValue = conditional:match("(%w+):(%w+)")
				
				if condType == "mod" then
					local isPressed = false
					condValue = condValue:lower()
					
					if condValue == "ctrl" and IsControlKeyDown() then
						isPressed = true
					elseif condValue == "alt" and IsAltKeyDown() then
						isPressed = true
					elseif condValue == "shift" and IsShiftKeyDown() then
						isPressed = true
					end
					
					if isPressed then
						return spec:trim()
					end
				end
			end
		end
	end
	
	-- Nothing matched, look for a line without conditionals (default case)
	for _, line in ipairs(lines) do
		if not line:match("^%[") then
			return line:trim()
		end
	end
	
	return nil
end

if not string.trim then
	function string.trim(s)
		return s:match("^%s*(.-)%s*$")
	end
end

local function QuickSpec_SlashCommandHandler(spec)
	if spec == "" then
		QuickSpec.Execute(nil)
	else
		-- Parse macro conditionals
		local parsedSpec = ParseMacroConditionals(spec)
		if parsedSpec and parsedSpec ~= "" then
			QuickSpec.Execute(parsedSpec)
		elseif not spec:match("%[.-%]") then
			-- No conditionals, just execute normally
			QuickSpec.Execute(spec)
		end
	end
end

local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")

SLASH_QUICKSPEC1 = "/quickspec";
SLASH_QUICKSPEC2 = "/qs";

Frame:SetScript("OnEvent", function(self, event)
	SlashCmdList["QUICKSPEC"] = QuickSpec_SlashCommandHandler;
end)

local QuickSpec = {}
_G.QuickSpec = QuickSpec

local L = LibStub("AceLocale-3.0"):GetLocale("QuickSpec")

BINDING_HEADER_QUICKSPECFRAME = "QuickSpec"
_G["BINDING_NAME_QSBINDINGINFO"] = L["Open/Close QuickSpec"]

-- Fallback for older API versions if needed
local GetSpecialization = GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local SetSpecialization = SetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.SetSpecialization)

-- ── Main frame ──────────────────────────────────────────────────────────────
-- Clean, frameless base — background + Dragonflight NineSlice border applied in code.
local QuickSpecFrame = CreateFrame("Frame", "QuickSpecFrame", UIParent)
QuickSpecFrame:SetSize(306, 270)  -- width fixed at 306; height set dynamically by BuildFrameContent
QuickSpecFrame:SetPoint("CENTER")
QuickSpecFrame:SetMovable(true)
QuickSpecFrame:EnableMouse(true)
QuickSpecFrame:RegisterForDrag("LeftButton")
QuickSpecFrame:SetScript("OnDragStart", QuickSpecFrame.StartMoving)
QuickSpecFrame:SetScript("OnDragStop", QuickSpecFrame.StopMovingOrSizing)
QuickSpecFrame:SetFrameStrata("DIALOG")
QuickSpecFrame:Hide()

-- Stoney grey background from the Blizzard spec choice window.
-- spec-background atlas is only registered after Blizzard_PlayerSpells loads,
-- so we apply it in OnShow after demanding that addon.
local frameBg = QuickSpecFrame:CreateTexture(nil, "BACKGROUND", nil, -2)
frameBg:SetAllPoints()
frameBg:SetColorTexture(0.22, 0.20, 0.18, 1)  -- sensible fallback while atlas loads

-- Dark overlay to take the edge off the stone texture ("only slightly darker")
local frameDarkOverlay = QuickSpecFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
frameDarkOverlay:SetAllPoints()
frameDarkOverlay:SetColorTexture(0, 0, 0, 0.22)

QuickSpecFrame:SetScript("OnShow", function()
    C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
    if C_Texture.GetAtlasInfo("spec-background") then
        frameBg:SetAtlas("spec-background", false)
    end
end)

-- 1px gold pixel border — four edge textures
-- Unified accent: deep amber gold used for all chrome (title, spec name, close btn, borders when class color off)
local DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A = 0.78, 0.55, 0.10, 1

-- Overridden from QuickSpecCharDB at PLAYER_LOGIN; default true until then
local USE_CLASS_COLOR = true
local BORDER_R, BORDER_G, BORDER_B, BORDER_A = DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A
local borderTop    = QuickSpecFrame:CreateTexture(nil, "OVERLAY")
borderTop:SetHeight(1)
borderTop:SetPoint("TOPLEFT",  QuickSpecFrame, "TOPLEFT",  0,  0)
borderTop:SetPoint("TOPRIGHT", QuickSpecFrame, "TOPRIGHT", 0,  0)
borderTop:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)

local borderBottom = QuickSpecFrame:CreateTexture(nil, "OVERLAY")
borderBottom:SetHeight(1)
borderBottom:SetPoint("BOTTOMLEFT",  QuickSpecFrame, "BOTTOMLEFT",  0, 0)
borderBottom:SetPoint("BOTTOMRIGHT", QuickSpecFrame, "BOTTOMRIGHT", 0, 0)
borderBottom:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)

local borderLeft   = QuickSpecFrame:CreateTexture(nil, "OVERLAY")
borderLeft:SetWidth(1)
borderLeft:SetPoint("TOPLEFT",    QuickSpecFrame, "TOPLEFT",    0,  0)
borderLeft:SetPoint("BOTTOMLEFT", QuickSpecFrame, "BOTTOMLEFT", 0,  0)
borderLeft:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)

local borderRight  = QuickSpecFrame:CreateTexture(nil, "OVERLAY")
borderRight:SetWidth(1)
borderRight:SetPoint("TOPRIGHT",    QuickSpecFrame, "TOPRIGHT",    0,  0)
borderRight:SetPoint("BOTTOMRIGHT", QuickSpecFrame, "BOTTOMRIGHT", 0,  0)
borderRight:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)

-- Resolves BORDER_R/G/B/A from class color or gold depending on USE_CLASS_COLOR.
local function ResolveColors()
	if USE_CLASS_COLOR then
		local _, classToken = UnitClass("player")
		local cc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
		if cc then
			BORDER_R, BORDER_G, BORDER_B, BORDER_A = cc.r, cc.g, cc.b, 1
			return
		end
	end
	BORDER_R, BORDER_G, BORDER_B, BORDER_A = DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A
end

-- Forward declaration so RefreshBorderColors can call it before its definition
local BuildFrameContent

-- Repaints the four window border lines and rebuilds frame content if open.
local function RefreshBorderColors()
	ResolveColors()
	borderTop:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)
	borderBottom:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)
	borderLeft:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)
	borderRight:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)
	if QuickSpecFrame:IsVisible() then
		BuildFrameContent()
	end
end

-- Title floats top-left inside the gold border
local titleText = QuickSpecFrame:CreateFontString(nil, "OVERLAY")
titleText:SetFontObject("Fancy16Font")
titleText:SetText("QuickSpec")
titleText:SetPoint("TOPLEFT", QuickSpecFrame, "TOPLEFT", 14, -10)
titleText:SetTextColor(DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A)

-- Custom close button (Assets/close-button.png)
local closeBtn = CreateFrame("Button", nil, QuickSpecFrame)
closeBtn:SetSize(16, 16)
closeBtn:SetPoint("TOPRIGHT", QuickSpecFrame, "TOPRIGHT", -8, -8)
closeBtn:SetFrameLevel(QuickSpecFrame:GetFrameLevel() + 10)  -- must sit above contentFrame children

local closeTex = closeBtn:CreateTexture(nil, "ARTWORK")
closeTex:SetAllPoints()
closeTex:SetTexture("Interface\\AddOns\\QuickSpec\\Assets\\close-button.png")
closeTex:SetVertexColor(DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A)

closeBtn:SetScript("OnEnter", function(self)
    closeTex:SetVertexColor(1, 0, 0, 1)
end)
closeBtn:SetScript("OnLeave", function(self)
    closeTex:SetVertexColor(DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A)
end)
closeBtn:SetScript("OnClick", function()
    QuickSpecFrame:Hide()
    QuickSpecFrame:ClearAllPoints()
    QuickSpecFrame:SetPoint("CENTER")
end)

-- Content container — rebuilt each time the frame opens
local contentFrame = CreateFrame("Frame", nil, QuickSpecFrame)
contentFrame:SetAllPoints()

tinsert(UISpecialFrames, "QuickSpecFrame")

function QuickSpec.p(arg)
	print("|CFFC78C1AQuickSpec:|r " .. arg)
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
SpecChangeFrame.text:SetTextColor(DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A)
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
		QuickSpec.p(format(L["Spec is already set to %s."], specName))
		return false
	end
	
	ShowSpecChangeMessage(format(L["Switching spec to %s"], specName))
	QuickSpec.p(format(L["Switching spec to %s"], specName) .. ".")
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

-- Clears only the dedicated content container, never the frame's own chrome
local function ClearContent()
	local children = { contentFrame:GetChildren() }
	for _, child in ipairs(children) do
		child:Hide()
		child:SetParent(nil)
	end
	-- Also clear FontStrings / Textures added directly to contentFrame
	contentFrame:SetSize(1, 1)  -- reset so child anchors recalculate cleanly
end

-- Creates a circular spec icon button using a circle mask (like the Blizzard spec frame)
local function CreateCircleSpecButton(parent, spec, playerClass, size)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetSize(size, size)

	-- Dark disc background (visible around the circle edge)
	local bg = btn:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetAtlas("talents-node-circle-shadow")

	-- Spec icon, clipped to a circle via mask
	local icon = btn:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT",     btn, "TOPLEFT",     4, -4)
	icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4,  4)

	-- Use the known spec thumbnail format with fallback to raw texture
	local atlasName = "spec-icon-" .. playerClass .. "-" .. string.lower(spec.name):gsub("%s+", "")
	if C_Texture.GetAtlasInfo(atlasName) then
		icon:SetAtlas(atlasName)
	else
		icon:SetTexture(spec.icon)
		icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	end

	-- Circle mask so the icon is round, not square
	local mask = btn:CreateMaskTexture()
	mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask",
		"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetPoint("TOPLEFT",     icon, "TOPLEFT",     0, 0)
	mask:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
	icon:AddMaskTexture(mask)

	-- Thin golden ring border around the outside of the circle
	local ring = btn:CreateTexture(nil, "OVERLAY")
	ring:SetAllPoints()
	ring:SetAtlas("spec-sampleabilityring")

	-- Hover glow
	local hl = btn:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetAtlas("talents-node-circle-shadow")
	hl:SetAlpha(0.5)
	hl:SetBlendMode("ADD")

	return btn
end

BuildFrameContent = function()
	ClearContent()

	local _, playerClass = UnitClass("player")
	playerClass = string.lower(playerClass)

	local currSpecIndex = GetSpecialization()
	local currSpecID, currSpecName, _, currIcon = GetSpecializationInfo(currSpecIndex)

	-- Build list of available specs (all except current)
	local availableSpecs = {}
	for i = 1, GetNumSpecializations() do
		local specID, specName, _, icon = GetSpecializationInfo(i)
		if i ~= currSpecIndex then
			table.insert(availableSpecs, {id = i, specID = specID, name = specName, icon = icon})
		end
	end

	-- ── Layout constants ─────────────────────────────────────────────
	local PAD     = 10    -- outer padding / gutter on all four sides
	local TOP_PAD = 36    -- extra top clearance for the title text
	local GAP     = 6     -- gap between alt-spec slices
	local FRAME_W = 340   -- total frame width (wider to allow for padding)
	local INNER_W = FRAME_W - PAD * 2   -- usable inner width
	local THUMB_H = 186   -- active spec card height
	local SLICE_H = 130   -- height of each alt-spec slice (pillar-style, taller than wide)
	local DIV_GAP_TOP = 16   -- gap from spec card bottom to divider (extra for atlas overhang)
	local DIV_GAP_BOT = 10   -- gap from divider to pillar tops
	local BOT_PAD = PAD   -- padding below slices

	local numAvail = #availableSpecs
	local frameH   = TOP_PAD + THUMB_H + (numAvail > 0 and (DIV_GAP_TOP + 1 + DIV_GAP_BOT + SLICE_H + BOT_PAD) or BOT_PAD)

	QuickSpecFrame:SetSize(FRAME_W, frameH)
	contentFrame:SetSize(FRAME_W, frameH)

	-- ── Spec ID → thumbnail string lookup ───────────────────────────
	local specFmtStrings = {
		[62]  = "mage-arcane",       [63]  = "mage-fire",          [64]  = "mage-frost",
		[65]  = "paladin-holy",      [66]  = "paladin-protection",  [70]  = "paladin-retribution",
		[71]  = "warrior-arms",      [72]  = "warrior-fury",        [73]  = "warrior-protection",
		[102] = "druid-balance",     [103] = "druid-feral",         [104] = "druid-guardian",    [105] = "druid-restoration",
		[250] = "deathknight-blood", [251] = "deathknight-frost",   [252] = "deathknight-unholy",
		[253] = "hunter-beastmastery", [254] = "hunter-marksmanship", [255] = "hunter-survival",
		[256] = "priest-discipline", [257] = "priest-holy",         [258] = "priest-shadow",
		[259] = "rogue-assassination", [260] = "rogue-outlaw",       [261] = "rogue-subtlety",
		[262] = "shaman-elemental",  [263] = "shaman-enhancement",  [264] = "shaman-restoration",
		[265] = "warlock-affliction", [266] = "warlock-demonology", [267] = "warlock-destruction",
		[268] = "monk-brewmaster",   [269] = "monk-windwalker",     [270] = "monk-mistweaver",
		[577] = "demonhunter-havoc", [581] = "demonhunter-vengeance", [1480] = "demonhunter-devourer",
		[1467]= "evoker-devastation", [1468]= "evoker-preservation", [1473]= "evoker-augmentation",
	}

	-- ── Active spec card (padded inset) ─────────────────────────────
	-- Border atlas is natively 306×186; size the button to match exactly (no stretching).
	-- Center it in INNER_W. This matches how Blizzard sizes SpecImage + SpecImageBorderOn.
	local THUMB_W   = 306
	local thumbOffX = math.floor((INNER_W - THUMB_W) / 2)
	local thumbBtn = CreateFrame("Button", nil, contentFrame)
	thumbBtn:SetSize(THUMB_W, THUMB_H)
	thumbBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", PAD + thumbOffX, -TOP_PAD)

	-- Spec artwork fills the button exactly (same 306×186 as the border atlas)
	local thumbTex = thumbBtn:CreateTexture(nil, "ARTWORK")
	thumbTex:SetAllPoints()
	local thumbAtlas = specFmtStrings[currSpecID] and ("spec-thumbnail-" .. specFmtStrings[currSpecID])
	if thumbAtlas and C_Texture.GetAtlasInfo(thumbAtlas) then
		thumbTex:SetAtlas(thumbAtlas, false)
	else
		thumbTex:SetTexture(currIcon)
	end

	-- spec-thumbnailborder-on has a built-in vignette; render at its native atlas size
	-- (useAtlasSize=true) centered on the button — same as Blizzard's XML.
	-- The atlas is slightly larger than 306×186 so the visible frame extends over the image edges.
	local thumbBorder = thumbBtn:CreateTexture(nil, "OVERLAY")
	thumbBorder:SetPoint("CENTER", thumbBtn, "CENTER")
	thumbBorder:SetAtlas("spec-thumbnailborder-on", true)
	thumbBorder:SetDesaturation(1)
	thumbBorder:SetVertexColor(BORDER_R, BORDER_G, BORDER_B, BORDER_A)

	-- Two-stop gradient behind the spec name: bottom 50px opaque→mid, upper 60px mid→transparent.
	-- Stacking two textures fakes a curved (eased) fade so it doesn't cut off sharply.
	local GRAD_BOT_H = 50
	local GRAD_TOP_H = 70
	local nameBgBot = thumbBtn:CreateTexture(nil, "OVERLAY", nil, 1)
	nameBgBot:SetHeight(GRAD_BOT_H)
	nameBgBot:SetPoint("BOTTOMLEFT",  thumbBtn, "BOTTOMLEFT")
	nameBgBot:SetPoint("BOTTOMRIGHT", thumbBtn, "BOTTOMRIGHT")
	nameBgBot:SetColorTexture(1, 1, 1, 1)
	nameBgBot:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.90), CreateColor(0, 0, 0, 0.45))

	local nameBgTop = thumbBtn:CreateTexture(nil, "OVERLAY", nil, 1)
	nameBgTop:SetHeight(GRAD_TOP_H)
	nameBgTop:SetPoint("BOTTOMLEFT",  thumbBtn, "BOTTOMLEFT",  0, GRAD_BOT_H)
	nameBgTop:SetPoint("BOTTOMRIGHT", thumbBtn, "BOTTOMRIGHT", 0, GRAD_BOT_H)
	nameBgTop:SetColorTexture(1, 1, 1, 1)
	nameBgTop:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.45), CreateColor(0, 0, 0, 0))

	local activeNameStr = thumbBtn:CreateFontString(nil, "OVERLAY")
	activeNameStr:SetFont("Fonts\\MORPHEUS.TTF", 24, "OUTLINE")
	activeNameStr:SetTextColor(DARK_GOLD_R, DARK_GOLD_G, DARK_GOLD_B, DARK_GOLD_A)
	activeNameStr:SetText(currSpecName)
	activeNameStr:SetPoint("BOTTOM", thumbBtn, "BOTTOM", 0, 10)

	thumbBtn:SetScript("OnClick", function()
		QuickSpec.p(format(L["Spec is already set to %s."], currSpecName))
		QuickSpecFrame:Hide()
	end)
	thumbBtn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(currSpecName)
		GameTooltip:AddLine(L["Currently active"], 0, 1, 0.5)
		GameTooltip:Show()
	end)
	thumbBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

	if numAvail == 0 then return end

	-- ── Lower section: divider + alt spec artwork slices ─────────────
	local lowerSection = CreateFrame("Frame", nil, contentFrame)
	lowerSection:SetSize(INNER_W, DIV_GAP_TOP + 1 + DIV_GAP_BOT + SLICE_H + BOT_PAD)
	lowerSection:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", PAD, -(TOP_PAD + THUMB_H))

	-- Divider
	local divider = lowerSection:CreateTexture(nil, "ARTWORK")
	divider:SetPoint("TOPLEFT",  lowerSection, "TOPLEFT",  0, -DIV_GAP_TOP)
	divider:SetPoint("TOPRIGHT", lowerSection, "TOPRIGHT", 0, -DIV_GAP_TOP)
	if C_Texture.GetAtlasInfo("spec-dividerline") then
		divider:SetAtlas("spec-dividerline", true)   -- native size keeps the tapered ends
		divider:SetDesaturation(1)
		divider:SetVertexColor(BORDER_R, BORDER_G, BORDER_B, BORDER_A)
	else
		divider:SetHeight(1)
		divider:SetColorTexture(BORDER_R, BORDER_G, BORDER_B, BORDER_A)
	end

	-- Alt spec slices — pillar-style: equal spacing across the full inner width (space-between)
	local MAX_PILLAR_W = 80
	local sliceW    = math.min(MAX_PILLAR_W, math.floor(INNER_W / numAvail))
	local totalSliceW = numAvail * sliceW
	-- Distribute leftover space evenly between pillars (and at both edges)
	local spacing   = (numAvail > 1) and math.floor((INNER_W - totalSliceW) / (numAvail + 1)) or 0
	local sliceY    = -(DIV_GAP_TOP + 1 + DIV_GAP_BOT)

	for index, spec in ipairs(availableSpecs) do
		local xPos    = spacing + (index - 1) * (sliceW + spacing)
		local specBtn = CreateFrame("Button", nil, lowerSection)
		specBtn:SetPoint("TOPLEFT", lowerSection, "TOPLEFT", xPos, sliceY)
		specBtn:SetSize(sliceW, SLICE_H)

		-- Spec artwork: center-crop so the panoramic thumbnail fills the pillar height
		-- without squishing. We compute UV coords to act like CSS object-fit:cover.
		local sliceAtlas = specFmtStrings[spec.specID] and ("spec-thumbnail-" .. specFmtStrings[spec.specID])
		local atlasInfo  = sliceAtlas and C_Texture.GetAtlasInfo(sliceAtlas)
		local sliceTex   = specBtn:CreateTexture(nil, "ARTWORK")
		sliceTex:SetAllPoints()
		if atlasInfo then
			-- Scale atlas to fill SLICE_H, then crop the sides to sliceW.
			local scaleFactor = SLICE_H / atlasInfo.height
			local scaledW     = atlasInfo.width * scaleFactor
			local fraction    = math.min(1, sliceW / scaledW)
			local crop        = (1 - fraction) / 2
			local uvW         = atlasInfo.rightTexCoord - atlasInfo.leftTexCoord
			sliceTex:SetTexture(atlasInfo.file or atlasInfo.filename)
			sliceTex:SetTexCoord(
				atlasInfo.leftTexCoord  + crop * uvW,
				atlasInfo.rightTexCoord - crop * uvW,
				atlasInfo.topTexCoord,
				atlasInfo.bottomTexCoord
			)
		else
			sliceTex:SetTexture(spec.icon)
			sliceTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		sliceTex:SetDesaturation(1)

		specBtn:SetScript("OnClick", function()
			SwitchToSpec(spec.id, spec.name)
			QuickSpecFrame:Hide()
		end)
		specBtn:SetScript("OnEnter", function(self)
			sliceTex:SetDesaturation(0)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(spec.name)
			GameTooltip:Show()
		end)
		specBtn:SetScript("OnLeave", function(self)
			sliceTex:SetDesaturation(1)
			GameTooltip:Hide()
		end)
	end
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

		QuickSpec.p(format(L["%s is not a valid spec choice"], specArg))
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
	elseif spec == "classcolor" then
		QuickSpecCharDB.useClassColor = not QuickSpecCharDB.useClassColor
		USE_CLASS_COLOR = QuickSpecCharDB.useClassColor
		RefreshBorderColors()
		QuickSpec.p(L["Class color borders: "] .. (USE_CLASS_COLOR and "|cff00ff00ON|r" or "|cffff4444OFF|r"))
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
	-- Init per-character saved variables and apply saved color preference
	QuickSpecCharDB = QuickSpecCharDB or {}
	if QuickSpecCharDB.useClassColor == nil then
		QuickSpecCharDB.useClassColor = false
	end
	USE_CLASS_COLOR = QuickSpecCharDB.useClassColor
	RefreshBorderColors()
	SlashCmdList["QUICKSPEC"] = QuickSpec_SlashCommandHandler
end)

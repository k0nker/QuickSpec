QuickSpec = LibStub( "AceAddon-3.0" ):NewAddon( "QuickSpec" )

BINDING_HEADER_QUICKSPECFRAME = "QuickSpec"
_G["BINDING_NAME_QSBINDINGINFO"] = "Open/Close QuickSpec"

local AceGUI = LibStub("AceGUI-3.0")

QuickSpecFrame  = AceGUI:Create("Window")
_G[" QuickSpecFrame"]  = QuickSpecFrame
QuickSpecFrame:Hide()
local _, _, classid = UnitClass("player")

function QuickSpec:OnEnable()
end
tinsert(UISpecialFrames, "QuickSpecFrame")

-- Function to print messages from this addon
function QuickSpec.p( arg )
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

function QuickSpec.Execute( specArg )
	--if QuickSpecFrame:IsVisible() then QuickSpecFrame:Hide() else QuickSpecFrame:Show() end
	--if QuickSpecFrame then AceGUI:Release(QuickSpecFrame) else
	if specArg == nil then
		--print("|cFF008B8BQuickSpec:|r " .. "NIL ARGUMENT")

		if QuickSpecFrame:IsVisible() then
			QuickSpecFrame:Hide()
		else
		AceGUI:Release(QuickSpecFrame)
		QuickSpecFrame = AceGUI:Create("Window")
		local height = 127
		QuickSpecFrame:SetCallback("OnClose",function(widget) QuickSpecFrame:Hide() end)
		QuickSpecFrame:SetTitle("QuickSpec")
		--f:SetStatusText("Status Bar")
		QuickSpecFrame:SetLayout("Flow")
		QuickSpecFrame:SetWidth(160)
		QuickSpecFrame:SetHeight(height)
		--QuickSpecFrame:SetPoint("TOPRIGHT", "PlayerTalentFrame", "TOPRIGHT", 175,0)
		QuickSpecFrame:EnableResize(true)
		local currSpecName, _, currIcon = select(2,GetSpecializationInfo(GetSpecialization()))
		local currentspeclabel = AceGUI:Create("Label")
		local currentspecicn = AceGUI:Create("Icon")
		currentspeclabel:SetText("Current Spec:")
		currentspeclabel:SetWidth(150)
		currentspeclabel:SetHeight(10)
		QuickSpecFrame:AddChild(currentspeclabel)
		currentspecicn:SetLabel("|CFF008051" .. currSpecName .. "|r")
		currentspecicn:SetImage(currIcon)
		currentspecicn:SetImageSize(31,31)
		currentspecicn:SetWidth(150)
		currentspecicn:SetHeight(55)
		currentspecicn:SetCallback("OnClick", function() QuickSpec.p("Spec is already set to " .. currSpecName .. '.') QuickSpecFrame:Hide() end )
		QuickSpecFrame:AddChild(currentspecicn)
		local choosespeclabel = AceGUI:Create("Label")
		choosespeclabel:SetText("Choose Spec:")
		choosespeclabel:SetWidth(150)
		choosespeclabel:SetHeight(10)
		QuickSpecFrame:AddChild(choosespeclabel)
		--QuickSpecFrame:SetHeight(PlayerTalentFrame:GetHeight())

		local numspecs = GetNumSpecializations()
--		local btn = {}
		local icn = {}
		local icnOverlay = {}
		for i=1, numspecs do
			local specID, specName, _, icon = select(1,GetSpecializationInfo(i))
			if GetSpecialization() == i then
				 else
				icn[i] = AceGUI:Create("Icon")
				icn[i]:SetImage(icon)
				icn[i]:SetLabel( specName )
				icn[i]:SetHeight(45)
				icn[i]:SetWidth(150)
				icn[i]:SetImageSize(45,45)
				height = height + 71
				QuickSpecFrame:SetHeight(height)
				--QuickSpecFrame:SetHeight(PlayerTalentFrame:GetHeight())
				icn[i]:SetCallback("OnClick", function() 
					if GetSpecialization() == i then QuickSpec.p("Spec is already set to " .. specName .. '.') QuickSpecFrame:Hide() else
					QuickSpec.p("Switching to spec: " .. specName .. '.') QuickSpecFrame:Hide() SetSpecialization(i) end
					end )
	
		-- Add the button to the container
				QuickSpecFrame:AddChild(icn[i])
			end
		end

		if classid == 3 and GetPetIcon() then
			for i=1,3 do
				local n = i +10
				local id, name, description, icon, role = GetSpecializationInfo(i, false, true)
				local curid, curname = GetSpecializationInfo(GetSpecialization(false, true), false, true)
				if id == curid then else
					icn[n] = AceGUI:Create("Button")
					icn[n]:SetText(name)
					icn[n]:SetCallback("OnClick", function() SetSpecialization(i, true) QuickSpecFrame:Hide()
										QuickSpec.p("Switching pet to spec: " .. name .. '.')  end)
					height = height + 30
					QuickSpecFrame:SetHeight(height)
					--QuickSpecFrame:SetHeight(PlayerTalentFrame:GetHeight())
					QuickSpecFrame:AddChild(icn[n])
				end
			end
		end
		QuickSpecFrame:Show()
	end
	else
		local currSpecName =  select(2,GetSpecializationInfo(GetSpecialization()))
		local currSpecNameString = string.lower(currSpecName)
		specArgString = string.lower(specArg)
		if currSpecNameString == specArgString then
			QuickSpec.p("Spec is already set to " .. currSpecName)
			return
		end
		local numspecs2 = GetNumSpecializations()
		for i=1, numspecs2 do
			local _, newSpecName = GetSpecializationInfo(i)
			newSpecNameString = string.lower(newSpecName)
			if newSpecNameString == specArgString then
				SetSpecialization(i)
				QuickSpec.p("Switching to spec: " .. newSpecName .. '.') 
				return
			end
		end
		-- Hunters changing their pets spec
		if classid == 3 and GetPetIcon() then
			local currPetSpecName = select(2,GetSpecializationInfo(GetSpecialization(false, true), false, true))
			local currPetSpecNameString = string.lower(currPetSpecName)
			--specArgString = string.lower(specArg)
			if currPetSpecNameString == specArgString then
				QuickSpec.p("Pet spec is already set to " .. currPetSpecName)
				return
			end
			for i=1,3 do
				local _, newPetSpecName = GetSpecializationInfo(i, false, true)
				newPetSpecNameString = string.lower(newPetSpecName)
				if newPetSpecNameString == specArgString then
					SetSpecialization(i, true)
					QuickSpec.p("Switching pet to spec: " .. newPetSpecName .. '.') 
					return
				end
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


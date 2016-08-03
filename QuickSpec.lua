QuickSpec = LibStub( "AceAddon-3.0" ):NewAddon( "QuickSpec" )

BINDING_HEADER_QUICKSPECFRAME = "QuickSpec Frame Bindings"
_G["BINDING_NAME_QSBINDINGINFO"] = "Open QuickSpec"

 local AceGUI = LibStub("AceGUI-3.0")
local QuickSpecFrame = ...

function QuickSpec:OnEnable()
	QuickSpecFrame = AceGUI:Create("Window")
	local height = 85
	QuickSpecFrame:SetCallback("OnClose",function(widget) QuickSpecFrame:Hide() end)--AceGUI:Release(widget) end)
	--QuickSpecFrame:SetTitle("QuickSpec")
	--f:SetStatusText("Status Bar")
	QuickSpecFrame:SetLayout("Flow")
	QuickSpecFrame:SetWidth(155)
	QuickSpecFrame:SetHeight(height)
	QuickSpecFrame:EnableResize(false)
	numspecs = GetNumSpecializations()
--	local btn = {}
	local icn = {}
	for i=1, numspecs do
	local specID, specName, _, icon = select(1,GetSpecializationInfo(i))
--	btn[i] = AceGUI:Create("Button")
	icn[i] = AceGUI:Create("Icon")
	icn[i]:SetImage(icon)
	icn[i]:SetLabel( specName )
	icn[i]:SetHeight(45)
	icn[i]:SetWidth(150)
	icn[i]:SetImageSize(45,45)
	height = height + 70
	QuickSpecFrame:SetHeight(height)
--	btn[i]:SetWidth(170)
--	btn[i]:SetText( specName )
	icn[i]:SetCallback("OnClick", function() print("Switching to spec: " .. specName .. '.') QuickSpecFrame:Hide() SetSpecialization(i)
					end )
	-- Add the button to the container
--	f:AddChild(btn[i])
	QuickSpecFrame:AddChild(icn[i])
	end
	QuickSpecFrame:Hide()
end

for i, v in pairs({"qs", "quickspec"}) do
	_G["SLASH_QUICKSPEC"..i] = "/"..v
end

SlashCmdList.QUICKSPEC = function()
QuickSpecFrame:Show()
end

function QuickSpec.Execute()
	QuickSpecFrame:Show()
end

scope()

local pws = wow_helpers.MakeRaidSpellMacro('SHIELD', 'Power Word: Shield')

local btn
btn = wow_helpers.SelectMacroButton.create('SHIELD_ME_BTN')
btn:SetLines({'/click ' .. pws})

btn:SetSelections({1})
btn:SetArgs(function()
	return { unitId = 'player' }
end)


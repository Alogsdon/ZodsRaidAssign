scope()

local druidSpells = {
    'Faerie Fire (Feral)',
    'Savage Roar',
    'Rip',
    'Ferocious Bite',
    'Shred',
    'Rake',
    'Mangle (Cat)',
    "Tiger's Fury",
    'Berserk',
    'Swipe ',
}

local druidLines = {}
local druidSpellLineMap = {}
for i, spell in ipairs(druidSpells) do
    table.insert(druidLines, "/cast " .. spell)
    druidSpellLineMap[spell] = i
end

local btn
btn = wow_helpers.SelectMacroButton.create('DRUID_ROTO_BTN')
btn:SetLines(druidLines)
btn:SetSelections(function(args)
	if (not args.spell) and druidSpellLineMap[args.spell] then
		return {}
	end
	if args.spell == 'Rip' or args.spell == 'Rake' or args.spell == 'Ferocious Bite' then
		if args.wait > 0 then
			return {}
		end
	end
	return { druidSpellLineMap[args.spell] }
end)
btn:SetArgs(function()
	local sn, t = ZodsUtil.GetRotationFirst()
	return {
		spell = sn,
		wait = t
	}
end)

local addonName, ZRA = ...


--INSTANCE RESET STUFF

function ZRA.ParseEvents()
	local events = ZRA_vars.events or {}
	local inside = false
	local iname = ''
	local cnt = 0
	for i,event in ipairs(events) do
		if event.inst_type == "party" then
			inside = true
			iname = event.instance
		else
			if inside == true then
				--exited
				inside = false
				local t = GetTime()
				cnt = cnt + 1
				print(cnt .. '. Exited ' .. iname.. ' ' .. string.format("%.1f", (t - event.time)/60) ..' mins ago')
			end
		end
	end
end

function ZRA.notFreshInstance()
	local last_exit = false
	local events = ZRA_vars.events or {}
	local inside = false
	for i,event in ipairs(events) do
		if event.inst_type == "party" then
			inside = true
		else
			if inside == true then
				last_exit = i
			end
		end
	end
	if last_exit then
		table.remove(events, last_exit)
	end
end

--MACRO STUFF
function ZRA.MakeMacros()
	ZRA.BuffMacro()
end

function ZRA.GroupDistribute(numGroups,numBuffers)
	local sets = {}
	local avg = numGroups / numBuffers
	local quota = 0
	for i = 1, numGroups do
		if quota > 0 then
			table.insert(sets[#sets], i)
			quota = quota - 1
		else
			table.insert(sets, {})
			table.insert(sets[#sets], i)
			quota = quota + avg - 1
		end
	end
	return sets
end

function ZRA.GetMakeMacro(name)
	local mi = GetMacroIndexByName(name)
	if mi == 0 then 
		CreateMacro(name, 'INV_Misc_QuestionMark', "")
		mi = GetMacroIndexByName(name)
	end
	return mi
end

function ZRA.MacroSetBody(i, body)
	local name,	texture = GetMacroInfo(i)
	EditMacro(i, name, texture, body)
end

function ZRA.BuffMacro()
	local numgroups = 8
	local mi = ZRA.mage_iter()
	local di = ZRA.druid_iter()
	local pi = ZRA.priest_iter()
	local s,i = ''
	local mages_groups = ZRA.GroupDistribute(numgroups, #ZRA.GetMages())
	s = s .. '/rw MAGE BUFFS\n'
	for i, groups in pairs(mages_groups) do
		local mage = mi()
		s = s .. '/rw ' .. mage.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZRA.GetMakeMacro("ZMageBuffs")
	ZRA.MacroSetBody(i, s)

	s = ''
	local priest_groups = ZRA.GroupDistribute(numgroups, #ZRA.GetPriests())
	s = s .. '/rw PRIEST BUFFS\n'
	for i, groups in pairs(priest_groups) do
		local priest = pi()
		s = s .. '/rw ' .. priest.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZRA.GetMakeMacro("ZPriestBuffs")
	ZRA.MacroSetBody(i, s)

	s = ''
	local druids_groups = ZRA.GroupDistribute(numgroups, #ZRA.GetDruids())
	s = s .. '/rw DRUID BUFFS\n'
	for i, groups in pairs(druids_groups) do
		local druid = di()
		s = s .. '/rw ' .. druid.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZRA.GetMakeMacro("ZDruidBuffs")
	ZRA.MacroSetBody(i, s)
end
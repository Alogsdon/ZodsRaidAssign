


local ZodsRaidAssign = {

}
	

function ZodsRaidAssign.onUpdate()
	if ZodsRaidAssign.requestSent then
		if GetTime() - ZodsRaidAssign.requestSent.t > 3.0 then
			ZodsRaidAssign.requestTimeout()
		end
	end
end

function ZodsRaidAssign.requestTimeout()
	local request = ZodsRaidAssign.requestSent
	if request.item == 'rosterVersion' then
		print('using my own roster version')
		ZodsRaidAssign.raidsRosterVersion = ZodsRaidAssign.rosterVersion()
		ZodsRaidAssign.reGreet()
	elseif request.item == 'rosterPayload' then
		print(request.askee)
		ZodsRaidAssign.otherUsers[request.askee] = nil
	end
	ZodsRaidAssign.requestSent = nil
	if #ZodsRaidAssign.request_queue > 0 then
		ZodsRaidAssign.sendRequestFromQueue()
	end
end

function ZodsRaidAssign.onLoad()
	C_ChatInfo.RegisterAddonMessagePrefix("ZRA")
	ZodsRaidAssign.otherUsers = {}
	ZodsRaidAssign.CODES = {}
	ZodsRaidAssign.request_queue = {}
	ZodsRaidAssign.LETTER_MAP = {}
	ZodsRaidAssign.CLASS_MAP = {
		["WARLOCK"] = 1,
		["WARRIOR"] = 2,
		["PALADIN"] = 3,
		["PRIEST"] = 4,
		["DRUID"] = 5,
		["MAGE"] = 6,
		["ROGUE"] = 7,
		["HUNTER"] = 8,
		["SHAMAN"] = 9,
	}
	ZodsRaidAssign.CLASS_MAP_BACK = {}
	for k,v in pairs(ZodsRaidAssign.CLASS_MAP) do
		ZodsRaidAssign.CLASS_MAP_BACK[v] = k
	end
	ZodsRaidAssign.RAID_MAP = {
		['Roles'] = '0',
		['Onyxias Lair'] = '1',
		['Molten Core'] = '2',
	}
	ZodsRaidAssign.RAID_MAP_BACK = {}
	for k,v in pairs(ZodsRaidAssign.RAID_MAP) do
		ZodsRaidAssign.RAID_MAP_BACK[v] = k
	end

	local str = 'abcdefghijklmnopqrstuvwxysABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	for i = 1, string.len(str) do
		table.insert(ZodsRaidAssign.CODES, string.sub(str, i, i))
		ZodsRaidAssign.LETTER_MAP[string.sub(str, i, i)] = i
	end
	ZodsRaidAssign.checkSavedVars()
	ZodsRaidAssign.Greet()
end


function ZodsRaidAssign.onEvent(frame, event, arg1, arg2, arg3, arg4, ...)
	if (event == "ADDON_LOADED" and arg1 == "ZodsRaidAssign") then
		
		ZodsRaidAssign.onLoad()
		ZodsRaidAssign.cleanupEvents()
		
		
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "ZRA" and string.gmatch(arg4,'(%w+)-')() ~= UnitName("player") then
      		ZodsRaidAssign.HandleRemoteData(arg2, arg3, arg4)
		end
	elseif event == "GROUP_JOINED" then
		ZodsRaidAssign.Greet()
	elseif event == "GROUP_ROSTER_UPDATE" then
		ZodsRaidAssign.reGreet()
	elseif event == 'PLAYER_ENTERING_WORLD' or event == 'PLAYER_LEAVING_WORLD' then
		--unhandled onEvent
		local events = ZRA_vars.events or {}
		ZRA_vars.events = events
		local iname, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
		if #events==0 or (not (instanceType == events[#events].inst_type)) then
			table.insert(events, {event = event, time = GetTime(), instance = iname, inst_type = instanceType, id = instanceID})
		else
			print(instanceType .. events[#events].inst_type)
		end
	else
	end
end



function ZodsRaidAssign.Greet()
	ZodsRaidAssign.otherUsers = {}
	ZodsRaidAssign.requestSent = {t = GetTime(), item = 'rosterVersion'}
	ZodsRaidAssign.raidsRosterVersion = nil
	C_ChatInfo.SendAddonMessage("ZRA", "hello", 'RAID')
end

function ZodsRaidAssign.reGreet()
	ZodsRaidAssign.otherUsers = {}
	if ZodsRaidAssign.raidsRosterVersion then
		C_ChatInfo.SendAddonMessage("ZRA", "hi"..ZodsRaidAssign.raidsRosterVersion, 'RAID')
	end
end

function ZodsRaidAssign.rosterVersion()
	local version = 0
	local m = ZodsRaidAssign.LETTER_MAP
	for k,v in pairs(ZRA_vars.roster) do
		if m[string.sub(v.name, 1, 1)] then
			version = version + m[string.sub(k, 1, 1)] * m[string.sub(v.name, 1, 1)]
		else
			version = version + 1
		end
	end
	return string.format("%04d", modulo(version, 9547))
end



function ZodsRaidAssign.HandleRemoteData(arg2, arg3, arg4)
	local sender = string.gmatch(arg4,'(%w+)-')() or arg4
	local task = string.sub(arg2,0,2)
	print('heard ' .. arg2)
	if task == 'he' then
		ZodsRaidAssign.reGreet()
		ZodsRaidAssign.otherUsers[sender] = true
	elseif task == 'hi' then
		ZodsRaidAssign.raidsRosterVersion = string.sub(arg2,3,6)
		ZodsRaidAssign.otherUsers[sender] = true
		if ZodsRaidAssign.requestSent and ZodsRaidAssign.requestSent.item == 'rosterVersion' then
			ZodsRaidAssign.requestSent = nil
		end
		if ZodsRaidAssign.rosterVersion() ~= ZodsRaidAssign.raidsRosterVersion then
			ZRA_vars.roster = {}
			ZodsRaidAssign.askForRosterPayload()
		end
	elseif task == 'rr' then
		ZodsRaidAssign.sendRosterData(sender)
	elseif task == 'sr' then
		if ZodsRaidAssign.rosterVersion() ~= ZodsRaidAssign.raidsRosterVersion then
			ZodsRaidAssign.requestSent = nil
			ZodsRaidAssign.setRosterFromMess(string.sub(arg2,3))
		end
	elseif task == 'bu' then
		ZodsRaidAssign.hearBossAssigns(string.sub(arg2,3))
	end
end

function ZodsRaidAssign.sendRosterData(dest)
	ZodsRaidAssignPublic.updateRaidNums()
	local mess_arr = {}
	for k,v in pairs(ZRA_vars.roster) do
		if v.raidNum > 0 then
			table.insert(mess_arr,k .. v.raidNum)
		else
			table.insert(mess_arr,k .. v.name..ZodsRaidAssign.CLASS_MAP[v.class])
		end
	end
	local lines = splitmess(mess_arr, ',', 220)
	for i,v in ipairs(lines) do
		C_ChatInfo.SendAddonMessage("ZRA", "sr" .. v, 'WHISPER', dest)
	end

	ZodsRaidAssignPublic.sendBossAssigns("Roles", nil, dest)
	for raidName, raidData in pairs(ZRA_vars.raids) do
		for bossIndex,bossAssigns in ipairs(raidData) do
			ZodsRaidAssignPublic.sendBossAssigns(raidName, bossIndex, dest)
		end
	end
	
end

function ZodsRaidAssign.hearBossAssigns(mess)
	local raidKey = ZodsRaidAssign.RAID_MAP_BACK[string.sub(mess,1,1)]
	local bosskey = tonumber(string.sub(mess,2,3))
	local assignsMess = string.sub(mess,4)
	local groups = mysplit(assignsMess, '.')
	for groupInd, colmnsMess in ipairs(groups) do
		local columns = mysplit(colmnsMess, ',')
		for colInd,membersMess in ipairs(columns) do
			local members = dicestring(membersMess)
			if raidKey == "Roles" then
				ZRA_vars.roles[groupInd].columns[colInd].members = members
			else
				ZRA_vars.raids[raidKey][bosskey][groupInd].columns[colInd].members = members
			end
		end
	end
	ZodsRaidAssignPublic.updateUI()
end

function ZodsRaidAssignPublic.sendBossAssigns(raidName, bossIndex, dest)
	if not bossIndex then bossIndex = 0 end
	local bossAssigns
	if bossIndex == -1 then
		raidName = "Roles"
	end
	if raidName == "Roles" then
		bossAssigns = ZRA_vars.roles
	else
		bossAssigns = ZRA_vars.raids[raidName][bossIndex]
	end

	local p = 'bu' .. ZodsRaidAssign.RAID_MAP[raidName] .. string.format("%02d", bossIndex)
	for groupInd, group in ipairs(bossAssigns) do
		for columnInd, column in ipairs(group.columns) do
			for _, playerCode in ipairs(column.members) do
				p = p .. playerCode
			end
			p = p .. ","
		end
		p = p .. "."
	end
	if dest then
		C_ChatInfo.SendAddonMessage("ZRA", p, 'WHISPER', dest)
	else
		C_ChatInfo.SendAddonMessage("ZRA", p, 'RAID')
	end
end

function ZodsRaidAssign.askForRosterPayload()
	local guy_to_ask = tablefirstkey(ZodsRaidAssign.otherUsers)
	if not guy_to_ask then return end
	local request = {t = GetTime(), item = 'rosterPayload', askee = guy_to_ask}
	if ZodsRaidAssign.requestSent then
		table.insert(ZodsRaidAssign.request_queue, request)
	else
		ZodsRaidAssign.requestSent = request
		C_ChatInfo.SendAddonMessage("ZRA", "rr", 'WHISPER', guy_to_ask)
	end
end

function ZodsRaidAssign.sendRequestFromQueue()
	local request = table.remove(ZodsRaidAssign.request_queue, 1)
	if request.item == 'rosterPayload' then
		ZodsRaidAssign.askForRosterPayload()
	end
end

function ZodsRaidAssign.setRosterFromMess(mess)
	for entry in string.gmatch(mess, '([^,]+)') do
		if string.len(entry) == 2 then
			local rnum = tonumber(string.sub(entry,2))
			local name, _, _, _, _, class = GetRaidRosterInfo(rnum)
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA_vars.roster[string.sub(entry,1,1)] = dude
		else
			local rnum = 0
			local name = string.sub(entry,2,-2)
			local class = ZodsRaidAssign.CLASS_MAP_BACK[tonumber(string.sub(entry,-1))]
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA_vars.roster[string.sub(entry,1,1)] = dude
		end
	end
	ZodsRaidAssign.myRosterChanged()
end

function ZodsRaidAssign.cleanupEvents()
	local events = ZRA_vars.events or {}
	local removing = {}
	local t = GetTime()
	for i,v in ipairs(events) do
		if t - v.time > 60 * 60 * 2 then
			table.insert(removing, i)
		end
	end
	for i = #removing, 1, -1 do
		table.remove(events, removing[i])
	end
end

function ZodsRaidAssign.checkSavedVars()
	if not ZRA_vars then ZRA_vars = {} end
	--if not ZRA_vars.raids then ZRA_vars.raids = {
	if true then 
		ZRA_vars.raids = ZodsRaidAssignPublic.raidschema
		ZRA_vars.roles = ZodsRaidAssignPublic.roleschema
	end
	--dummy roster
	if true then 
		ZRA_vars.roster = {}
		local i = 1
		for r in ZodsRaidAssign.raid_iter() do
			ZRA_vars.roster[ZodsRaidAssign.getUnusedCode()] = {
				class = r.class,
				name = r.name,
				raidNum = i,
			}
			i = i + 1
		end
	end
end

--codes for player UID, to make pickling easier
function ZodsRaidAssign.getUnusedCode()
	for i,v in ipairs(ZodsRaidAssign.CODES) do
		if ZRA_vars.roster[v] == nil then
			return v
		end
	end
end



function ZodsRaidAssign.ParseEvents()
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
				print(cnt .. '. Exited ' .. iname.. ' ' .. string.format("%.1f", (GetTime() - event.time)/60) ..' mins ago')
			end
		end
	end
end

function notFreshInstance()
	local last_exit = false
	local events = ZRA_vars.events or {}
	local inside = false
	for i,event in ipairs(events) do
		if event.inst_type == "party" then
			inside = true
			iname = event.instance
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

function ZodsRaidAssign.MakeMacros()
	ZodsRaidAssign.TankMacro()
	ZodsRaidAssign.CCMacro()
	ZodsRaidAssign.BuffMacro()
	ZodsRaidAssign.TrashHealMacro()
	ZodsRaidAssign.LuciMacro()
	ZodsRaidAssign.MagMacro()
	ZodsRaidAssign.GehMacro()
	ZodsRaidAssign.GarrMacro()
	ZodsRaidAssign.DomoMacro()
	ZodsRaidAssign.SulfMacro()
	ZodsRaidAssign.RagMacro()
	ZodsRaidAssign.GoleMaggMacro()
end

function ZodsRaidAssignPublic.parseRaidPost(post)
	local tanks, ti = {}, ZodsRaidAssignPublic.tank_iter()
	local heals, hi = {}, ZodsRaidAssignPublic.tank_heal_iter()
	local locks, li = {}, ZodsRaidAssign.lock_iter()
	local melee, mi = {}, ZodsRaidAssign.melee_iter()
	for i = 1,10 do
		table.insert(tanks, ti())
		table.insert(heals, hi())
		table.insert(locks, li())
		table.insert(melee, mi())
	end
	local temp = string.gsub(post, "%%%a+%d", function(str)
		local pre = string.sub(str, 2, -2)
		local ind = tonumber(string.sub(str,-1))
		if pre == "tank" then 
			return tanks[ind].name
		elseif pre == "heal" then 
			return heals[ind].name
		elseif pre == "lock" then 
			return locks[ind].name
		elseif pre == "melee" then 
			return melee[ind].name
		else
			return str
		end
	end)
	return temp
end


function ZodsRaidAssign.BaronMacro()
end

function ZodsRaidAssign.ShazzMacro()

end

function ZodsRaidAssign.GoleMaggMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()

	s = '/rw GOLEMAG\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on Skull{Skull}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on X{X}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'

	i = ZodsRaidAssign.GetMakeMacro("ZGolemag")
	ZodsRaidAssign.MacroSetBody(i, s)
end


function ZodsRaidAssign.RagMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()

	s = '/rw RAG\n'
	s = s .. '/rw  Heal the bosses target ' .. hi().name .. ', ' .. hi().name .. ' and ' .. hi().name ..'\n'
	s = s .. '/rw  Healing ' .. ti().name .. ' full time is ' .. hi().name .. '\n'
	s = s .. '/rw  Healing ' .. ti().name .. ' full time is ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ZodsRaidAssign.RemainingHeals(hi) .. ' on raid heals'

	i = ZodsRaidAssign.GetMakeMacro("ZRagnaros")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.SulfMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()
	local mi = ZodsRaidAssign.melee_iter()
	local s = '/rw SULF\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {X}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Skull}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Square}, HEALED BY ' .. hi().name .. '\n'
	i = ZodsRaidAssign.GetMakeMacro("ZSulf1")
	ZodsRaidAssign.MacroSetBody(i, s)

	s = ''
	s = s .. '/rw ' .. ti().name .. ' is on {Moon}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. mi().name .. ' kick {X}\n'
	s = s .. '/rw ' .. mi().name .. ' kick {Skull}\n'
	s = s .. '/rw ' .. mi().name .. ' kick {Square}\n'
	s = s .. '/rw ' .. mi().name .. ' kick {Moon}\n'
	i = ZodsRaidAssign.GetMakeMacro("ZSulf2")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.DomoMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()
	local t1 = ti()
	local t2 = ti()
	local t3 = ti()
	local t4 = ti()
	local t5 = ti()

	local s = '/rw DOMO\n'
	s = s .. '/rw ' .. t3.name .. ' is on DOMO, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. t4.name .. ' is on {X}->{Moon}->{Diamond}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. t5.name .. ' is on {Skull}->{Star}->{Circle}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. t1.name .. ' is on {Square}, HEALED BY ' .. hi().name .. '\n'
	i = ZodsRaidAssign.GetMakeMacro("ZDomo1")
	ZodsRaidAssign.MacroSetBody(i, s)

	local mi = ZodsRaidAssign.mage_iter()
	s = ''
	
	s = s .. '/rw ' .. t2.name .. ' is on {Triangle}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Moon}\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Star}\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Diamond}\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Circle}\n'
	i = ZodsRaidAssign.GetMakeMacro("ZDomo2")
	ZodsRaidAssign.MacroSetBody(i, s)

end

function ZodsRaidAssign.GarrMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()
	local s = '/rw GARR\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {X}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Skull}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Square}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Moon}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Triangle}, HEALED BY ' .. hi().name .. '\n'
	i = ZodsRaidAssign.GetMakeMacro("ZGarr")
	ZodsRaidAssign.MacroSetBody(i, s)
end


function ZodsRaidAssign.GehMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()

	s = '/rw GEHENAS\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on Skull{Skull}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on X{X}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is BACKUP tank\n'

	i = ZodsRaidAssign.GetMakeMacro("ZGehns")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.LuciMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()

	s = '/rw LUCI\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on Skull{Skull}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on X{X}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is BACKUP tank\n'
	s = s .. '/rw DISPEL MAGIC/CURSE\n'

	i = ZodsRaidAssign.GetMakeMacro("ZLuci")
	ZodsRaidAssign.MacroSetBody(i, s)
end


function ZodsRaidAssign.MagMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()

	local s = '/rw MAG\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ', ' .. hi().name .. ', ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is BACKUP tank\n'
	s = s .. '/rw ' .. ZodsRaidAssign.RemainingHeals(hi) .. ' on raid heals'

	i = ZodsRaidAssign.GetMakeMacro("ZMag")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.RemainingHeals(hi)
	local s = ''
	n = hi()
	repeat
		s = s .. n.name .. ', '
		n = hi()
	until( n.name == 'missing healer' )
	s = string.sub(s, 0, #s - 2)
	return s
end

function ZodsRaidAssign.GroupDistribute(numGroups,numBuffers)
	sets = {}
	avg = numGroups / numBuffers
	quota = 0
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

function ZodsRaidAssign.TrashHealMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	local hi = ZodsRaidAssignPublic.tank_heal_iter()

	s = '/rw TRASH HEAL ASSIGNMENTS\n'
	for i = 1, 3 do
		tank = ti()

		s = s .. '/rw '  .. tank.name .. ' is being healed by '
		for i = 1, 2 do
			healer = hi()
			s = s .. healer.name .. ' , '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	
	s = s .. '/rw '
	n = hi()
	repeat
		s = s .. n.name .. ', '
		n = hi()
	until( n.name == 'missing healer' )
	s = string.sub(s, 0, #s - 2)
	s = s .. ' on raid heals'

	i = ZodsRaidAssign.GetMakeMacro("ZTrashHeals")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.GetMakeMacro(name)
	mi = GetMacroIndexByName(name)
	if mi == 0 then 
		CreateMacro(name, 'INV_Misc_QuestionMark', "")
		mi = GetMacroIndexByName(name)
	end
	return mi
end

function ZodsRaidAssign.MacroSetBody(i, body)
	local name,	texture = GetMacroInfo(i)
	EditMacro(i, name, texture, body)
end

function ZodsRaidAssign.TankMacro()
	local ti = ZodsRaidAssignPublic.tank_iter()
	shapes = {
		'X {X}',
		'skull {Skull}',
		'Square {Square}',
		'Moon {Moon}',
		'Triangle {Triangle}',
	}
	s = '/rw TANK ASSIGNMENTS \n'
	for _, shape in pairs(shapes) do
		tank = ti()
		s = s .. '/rw '  .. tank.name .. ' tanking ' .. shape .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZTankShapes")
	ZodsRaidAssign.MacroSetBody(i, s)
end

ZodsRaidAssign.SHAPES = {
	skull = true,
	x = true,
	square = true,
	moon = true,
	triangle = true,
	diamond = true,
	circle = true,
	star = true,
}

function ZodsRaidAssignPublic.shape(s)
	if ZodsRaidAssign.SHAPES[string.lower(s)] then
		return '{' .. s .. '}'
	else
		return s
	end
end

function ZodsRaidAssign.CCMacro()
	local li = ZodsRaidAssign.lock_iter()
	shapes = {
		'Diamond {Diamond}',
		'Circle {Circle}',
		'Star {Star}',
	}
	s = '/rw LOCK BANISH ASSIGNMENTS\n'
	for _, shape in pairs(shapes) do
		lock = li()
		s = s .. '/rw '  .. lock.name .. ' banishing ' .. shape .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZLockShapes")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.BuffMacro()
	local numgroups = 8
	local mi = ZodsRaidAssign.mage_iter()
	local di = ZodsRaidAssign.druid_iter()
	local pi = ZodsRaidAssign.priest_iter()
	s = ''
	mages_groups = ZodsRaidAssign.GroupDistribute(numgroups, #ZodsRaidAssign.GetMages())
	s = s .. '/rw MAGE BUFFS\n'
	for i, groups in pairs(mages_groups) do
		mage = mi()
		s = s .. '/rw ' .. mage.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZMageBuffs")
	ZodsRaidAssign.MacroSetBody(i, s)

	s = ''
	priest_groups = ZodsRaidAssign.GroupDistribute(numgroups, #ZodsRaidAssign.GetPriests())
	s = s .. '/rw PRIEST BUFFS\n'
	for i, groups in pairs(priest_groups) do
		priest = pi()
		s = s .. '/rw ' .. priest.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZPriestBuffs")
	ZodsRaidAssign.MacroSetBody(i, s)

	s = ''
	druids_groups = ZodsRaidAssign.GroupDistribute(numgroups, #ZodsRaidAssign.GetDruids())
	s = s .. '/rw DRUID BUFFS\n'
	for i, groups in pairs(druids_groups) do
		druid = di()
		s = s .. '/rw ' .. druid.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZDruidBuffs")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.GetTanks()

	return shallowcopy(ZRA_vars.roles[1].columns[1].members)
end

function ZodsRaidAssign.GetHeals()
	return {
		priests=shallowcopy(ZRA_vars.roles[2].columns[1].members),
		pallies=shallowcopy(ZRA_vars.roles[2].columns[2].members),
		druids=shallowcopy(ZRA_vars.roles[2].columns[3].members)
	}
end

function ZodsRaidAssignPublic.tank_heal_iter()
	local unass_healers = ZodsRaidAssign.GetHeals()
	local lf = 'pally'
	return 
		function ()
			if lf == 'pally' then 
				if #unass_healers.pallies > 0 then
					lf = 'priest'
					return table.remove(unass_healers.pallies, 1)
				elseif #unass_healers.priests > 0 then
					lf = 'pally'
					return table.remove(unass_healers.priests, 1)
				elseif #unass_healers.druids > 0 then
					lf = 'pally'
					return table.remove(unass_healers.druids, 1)
				else
					--nil
				end
			elseif lf == 'priest' then
				if #unass_healers.priests > 0 then
					lf = 'pally'
					return table.remove(unass_healers.priests, 1)
				elseif #unass_healers.pallies > 0 then
					lf = 'priest'
					return table.remove(unass_healers.pallies, 1)
				elseif #unass_healers.druids > 0 then
					lf = 'pally'
					return table.remove(unass_healers.druids, 1)
				else
					--nil
				end
			end
		end
end

function ZodsRaidAssignPublic.tank_iter()
	local unass_tanks = ZodsRaidAssign.GetTanks()
	return 
		function ()
			if #unass_tanks > 0 then
				return table.remove(unass_tanks, 1)
			end
		end
end

function ZodsRaidAssign.GetLocks()
	return shallowcopy(ZRA_vars.raid.locks)
end

function ZodsRaidAssign.lock_iter()
	local unass_locks = ZodsRaidAssign.GetLocks()
	return 
		function ()
			if #unass_locks > 0 then
				return table.remove(unass_locks, 1)
			else
				return {name='missing warlock'}
			end
		end
end

function ZodsRaidAssign.GetMelee()
	return shallowcopy(ZRA_vars.raid.melee)
end

function ZodsRaidAssign.melee_iter()
	local unass = ZodsRaidAssign.GetMelee()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing melee'}
			end
		end
end

function ZodsRaidAssign.GetMages()
	return shallowcopy(ZRA_vars.raid.mages)
end

function ZodsRaidAssign.mage_iter()
	local unass = ZodsRaidAssign.GetMages()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing mage'}
			end
		end
end

function ZodsRaidAssign.GetDruids()
	return shallowcopy(ZRA_vars.raid.healers.druids)
end

function ZodsRaidAssign.druid_iter()
	local unass = ZodsRaidAssign.GetDruids()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing druid'}
			end
		end
end

function ZodsRaidAssign.GetPriests()
	return shallowcopy(ZRA_vars.raid.healers.priests)
end

function ZodsRaidAssign.priest_iter()
	unass = ZodsRaidAssign.GetPriests()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing priest'}
			end
		end
end

function ZodsRaidAssign.PurgeRaid()
	local raid_mems = {}
	for i=1,GetNumGroupMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		raid_mems[name] = true
	end
	for n in ZodsRaidAssign.raid_iter() do
		if raid_mems[n.name] == nil then
			ZodsRaidAssign.DeleteRaider(n)
		end
	end
end

function ZodsRaidAssign.DeleteRaider(n, raid)
	if not raid then raid = ZRA_vars.raid end
	for i,v in pairs(raid) do
		if v.name then
			if v.name == n then
				raid[i] = nil
			end
		elseif type(v) == 'table' then
			ZodsRaidAssign.DeleteRaider(n, v)
		end
	end
	return false
end

function ZodsRaidAssign.SnapShotRaid()
	local raid = ZRA_vars.raid or {tanks = {}, healers = {pallies = {}, priests = {}, druids = {}}, mages = {}, locks = {}, hunters = {}, melee = {}}
	for i=1,GetNumGroupMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		 ZodsRaidAssign.AssumeRole(raid, {name=name, class=class})
	end
	return raid
end

function ZodsRaidAssign.AssumeRole(raid, member)
	if ZodsRaidAssign.MemberIsInRaidAlready(member, raid) then return end
	if member.class == 'WARRIOR' then
		table.insert(raid.tanks, member)
	elseif member.class == 'PALADIN' then
		table.insert(raid.healers.pallies, member)
	elseif member.class == 'PRIEST' then
		table.insert(raid.healers.priests, member)
	elseif member.class == 'DRUID' then
		table.insert(raid.healers.druids, member)
	elseif member.class == 'WARLOCK' then
		table.insert(raid.locks, member)
	elseif member.class == 'MAGE' then
		table.insert(raid.mages, member)
	elseif member.class == 'HUNTER' then
		table.insert(raid.hunters, member)
	elseif member.class == 'ROGUE' then
		table.insert(raid.melee, member)
	else 
		print('wtf is ' .. member.class .. ' class')
	end
end

function ZodsRaidAssign.raid_iter()
	local index = nil
	local subindex = nil
	local groups = {
		ZRA_vars.raid.tanks,
		ZRA_vars.raid.melee,
		ZRA_vars.raid.hunters,
		ZRA_vars.raid.locks,
		ZRA_vars.raid.mages,
		ZRA_vars.raid.healers.pallies,
		ZRA_vars.raid.healers.druids,
		ZRA_vars.raid.healers.priests,
	}
	index = next(groups, nil)
	
	return function()
		subindex = next(groups[index], subindex)
		if subindex then
			return groups[index][subindex]
		else
			repeat
			index = next(groups, index)
			until (not index) or #groups[index] >0
			if index then
				subindex = next(groups[index], subindex)
				if subindex then
					return groups[index][subindex]
				end
			end
		end

	end
end

function ZodsRaidAssignPublic.raid_iter()
	local key = nil
	return function()
		key = next(ZRA_vars.roster, key)
		if key then
			return ZRA_vars.roster[key]
		end
	end
	--	for r in ZodsRaidAssignPublic.raid_iter() do
	--	print(dump(r))
	--end
end

function ZodsRaidAssignPublic.loadMembers()
	local reverse_ind = {}
	for k,v in pairs(ZRA_vars.roster) do
		reverse_ind[v.name] = k
	end
	for i=1,GetNumGroupMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		if not reverse_ind[name] then
			ZRA_vars.roster[ZodsRaidAssign.getUnusedCode()] = {
			class = class,
			name = name,
			raidNum = i,
			}
		end
	end
	ZodsRaidAssign.pushNewRoster()
	
end

function ZodsRaidAssign.pushNewRoster()
	ZodsRaidAssign.raidsRosterVersion = ZodsRaidAssign.rosterVersion()
	ZodsRaidAssign.reGreet()
end

function ZodsRaidAssign.myRosterChanged()
	if ZRALayoutFrame:IsShown() then 
		ZodsRaidAssignPublic.OpenMenu()
	end
end

function ZodsRaidAssignPublic.updateRaidNums()
	local reverse_ind = {}
	for k,v in pairs(ZRA_vars.roster) do
		reverse_ind[v.name] = k
	end
	for k,v in pairs(ZRA_vars.roster) do
		v.raidNum = 0
	end
	for i=1,GetNumGroupMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		if reverse_ind[name] then
			ZRA_vars.roster[reverse_ind[name]].raidNum = i
		end
	end
end

function ZodsRaidAssignPublic.dropMembers()
	ZRA_vars.roster = {}
	ZodsRaidAssignPublic.loadMembers()
end

function ZodsRaidAssignPublic.getCodeFromName(n)
	for k,v in pairs(ZRA_vars.roster) do
		if v.name ==n then
			return k
		end
	end
end



function ZodsRaidAssign.MemberIsInRaidAlready(member, raid)
	for i,v in pairs(raid) do
		if v.name then
			if v.name == member.name then
				return true 
			end
		else
			if ZodsRaidAssign.MemberIsInRaidAlready(member, v) then
				return true
			end
		end
	end
	return false
end

--- slash handler
SLASH_ZRAIDASSIGN1 = "/zra"
SlashCmdList["ZRAIDASSIGN"] = function(msg)
	local command, arg1, arg2, arg3 = strsplit(" ",msg)
	if command == '' then
		ZodsRaidAssign.PrintHelp()
	end
	if (command == "re") then
		local s = ZodsRaidAssign.GroupDistribute(8,4)
		print(dump(s))
	elseif (command == "load") then
		ZRA_vars.raid = ZodsRaidAssign.SnapShotRaid()
		print('loaded')
	elseif (command == "purge") then
		ZodsRaidAssign.PurgeRaid()
		print('purged')
	elseif (command == "rf") then
		ZRA_vars.raid = ZodsRaidAssign.SnapShotRaid()
		ZodsRaidAssign.PurgeRaid()
		print('refreshed')
	elseif (command == 'clear') then
		ZRA_vars.raid = {tanks = {}, healers = {pallies = {}, priests = {}, druids = {}}, mages = {}, locks = {}, hunters = {}, melee = {}}
		print('cleared')
	elseif (command == 'print') then
		for n in ZodsRaidAssign.raid_iter() do
			print(n.name)
		end
	elseif (command == 'macros') then
		ZodsRaidAssign.MakeMacros()
		print('macros made')
	elseif (command == 'i') then
		ZodsRaidAssign.ParseEvents()
	elseif (command == 'wipe') then
		notFreshInstance()
		print('wipe')
	elseif (command == 'menu') then
		ZodsRaidAssignPublic.OpenMenu()
	elseif (command == 'test') then
		print(ZodsRaidAssign.raidsRosterVersion)
	else 
	end
end

function ZodsRaidAssign.PrintHelp()
	print('load, clear, purge, rf, macros, i, wipe, print, menu')
end

function dump(o)
	if type(o) == 'table' then
		 local s = '{ '
		 for k,v in pairs(o) do
				if type(k) ~= 'number' then k = '"'..k..'"' end
				s = s .. '['..k..'] = ' .. dump(v) .. ','
		 end
		 return s .. '} '
	else
		 return tostring(o)
	end
end

function shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in pairs(orig) do
					copy[orig_key] = orig_value
			end
	else -- number, string, boolean, etc
			copy = orig
	end
	return copy
end

function modulo(a,b)
	return a - math.floor(a/b)*b
end

function tablelen(t)
	local numItems = 0
	for k,v in pairs(t) do
		numItems = numItems + 1
	end
	return numItems
end

function tablefirstkey(t)
	for k,v in pairs(t) do
		return(k)
	end
end

function splitmess(mess_arr, sep, lencap)
	local lines = {}
	local current_line = ""
	for i,v in ipairs(mess_arr) do
		if string.len(current_line) + string.len(sep) + string.len(v) >= lencap then
			table.insert(lines, current_line)
			current_line = ""
		elseif string.len(current_line) > 0 then
			current_line = current_line .. sep
		end
		current_line = current_line .. v
	end
	if string.len(current_line) > 0 then
		table.insert(lines, current_line)
	end
	return lines
end

function remaining(it)
	local temp = {}
	for item in it do
		table.insert(temp,item)
	end
	return temp
end

function mysplit (inputstr, sep)
	local t={}
	local p = ''
	for i = 1, string.len(inputstr) do
		local letter = string.sub(inputstr, i, i)
		if letter == sep then
			table.insert(t, p)
			p = ''
		else
			p = p .. letter
		end
	end
	return t
end

function dicestring(str)
	local t = {}
	for i = 1, string.len(str) do
		table.insert(t, string.sub(str, i, i))
	end
	return t
end

function codesToValsArr(codes, hash, key)
	local vals = {}
	for _,v in ipairs(codes) do
		table.insert(vals, hash[v][key])
	end
	return vals
end

ZodsRaidAssign.scriptframe = CreateFrame("Frame", 'ZRAFrame')
ZodsRaidAssign.scriptframe:RegisterEvent("ADDON_LOADED")
ZodsRaidAssign.scriptframe:RegisterEvent("CHAT_MSG_ADDON")
ZodsRaidAssign.scriptframe:RegisterEvent("GROUP_JOINED")
ZodsRaidAssign.scriptframe:RegisterEvent("GROUP_ROSTER_UPDATE")
ZodsRaidAssign.scriptframe:SetScript("OnEvent", ZodsRaidAssign.onEvent)
ZodsRaidAssign.scriptframe:SetScript("OnUpdate", ZodsRaidAssign.onUpdate)

some_events = {
	'PLAYER_QUITING',
	'PLAYER_LOGOUT',
	'PLAYER_LOGIN',
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEAVING_WORLD",
}
for k, v in pairs(some_events) do
	ZodsRaidAssign.scriptframe:RegisterEvent(v)
end
local addonName, ZRA = ...


function ZRA.onLoadComms()
    C_ChatInfo.RegisterAddonMessagePrefix("ZRA")
    ZRA.otherUsers = {}
    ZRA.state = ZRA.STATES.FRESH
    ZRA.request_queue = {}

end

function ZRA.CommOnEvent(frame, event, arg1, arg2, arg3, arg4, ...)

	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "ZRA" then
			local sender = string.gmatch(arg4,'(%w+)-')() or arg4
			if sender == UnitName("player") then
			else
				ZRA.HandleRemoteData(arg2, arg3, sender)
			end
		end
	elseif event == "GROUP_JOINED" then
		ZRA.state = ZRA.States.FRESH
	elseif event == "GROUP_ROSTER_UPDATE" then
		ZRA.loadMembers()
		ZRA.reGreet()
	elseif event == 'PLAYER_ENTERING_WORLD' or event == 'PLAYER_LEAVING_WORLD' then
		--unhandled onEvent
		local events = ZRA_vars.events or {}
		ZRA_vars.events = events
		local iname, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
		if #events==0 or (not (instanceType == events[#events].inst_type)) then
			table.insert(events, {event = event, time = GetTime(), instance = iname, inst_type = instanceType, id = instanceID})
		else
		end
	else
	end
end


function ZRA.CommOnUpdate()
	if ZRA.requestSent then
		if GetTime() - ZRA.requestSent.t > 3.0 then
			ZRA.requestTimeout()
		end
	end

	if ZRA.state == ZRA.STATES.FRESH then
		ZRA.Greet()
	elseif ZRA.state == ZRA.STATES.GREETED then
	elseif ZRA.state == ZRA.STATES.GETTING_ROSTER then
	elseif ZRA.state == ZRA.STATES.GOOD then
	elseif ZRA.state == ZRA.STATES.ASKED then
	elseif ZRA.state == ZRA.STATES.GETTING_ASSIGNS then
	end
end


function ZRA.setRosterFromMess(mess)
	for entry in string.gmatch(mess, '([^,]+)') do
		if string.len(entry) <= 3 then
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
			local class = ZRA.CLASS_MAP_BACK[tonumber(string.sub(entry,-1))]
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA_vars.roster[string.sub(entry,1,1)] = dude
		end
	end
	ZRA.myRosterChanged()
end

function ZRA.requestTimeout()
	local request = ZRA.requestSent
	if request.item == 'rosterVersion' then
		ZRA.raidsRosterVersion = ZRA.rosterVersion()
		ZRA.raidsAssignsVersion = ZRA.raidAssignsVersion()
		ZRA.reGreet()
	elseif request.item == 'rosterPayload' then
		ZRA.otherUsers[request.askee] = nil
		ZRA.askForRosterPayload()
	elseif request.item == 'bossAssigns' then
		ZRA.otherUsers[request.askee] = nil
		ZRA.askForBossAssigns()
	end
	ZRA.requestSent = nil
	if #ZRA.request_queue > 0 then
		ZRA.sendRequestFromQueue()
	end
end

function ZRA.sendRequestFromQueue()
	local request = table.remove(ZRA.request_queue, 1)
	if request.item == 'rosterPayload' then
		ZRA.askForRosterPayload()
	end
end


function ZRA.askForBossAssigns()
	local guy_to_ask = ZRA.tablefirstkey(ZRA.otherUsers)
	if not guy_to_ask then return end
	local request = {t = GetTime(), item = 'bossAssigns', askee = guy_to_ask}
	if ZRA.requestSent then
		table.insert(ZRA.request_queue, request)
	else
		ZRA.requestSent = request
		C_ChatInfo.SendAddonMessage("ZRA", "ra", 'WHISPER', guy_to_ask)
	end
end

function ZRA.askForRosterPayload()
	local guy_to_ask = ZRA.tablefirstkey(ZRA.otherUsers)
	if not guy_to_ask then return end
	local request = {t = GetTime(), item = 'rosterPayload', askee = guy_to_ask}
	if ZRA.requestSent then
		table.insert(ZRA.request_queue, request)
	else
		ZRA.requestSent = request
		C_ChatInfo.SendAddonMessage("ZRA", "rr", 'WHISPER', guy_to_ask)
	end
end

function ZRA.hearBossAssigns(mess, sender)
	local raidKey = ZRA.RAID_MAP_BACK[string.sub(mess,1,1)]
	local bosskey = tonumber(string.sub(mess,2,3))
	local bossName = nil
	local BossData = nil
	if raidKey == "Roles" then
		BossData = ZRA_vars.roles
	else
		bossName = ZRA_vars.raids[raidKey][bosskey].name
		BossData = ZRA_vars.raids[raidKey][bosskey]
	end
	
	local assignsMess = string.sub(mess,4)
	local diff = nil
	local groups = ZRA.mysplit(assignsMess, '.')
	for groupInd, colmnsMess in ipairs(groups) do
		local columns = ZRA.mysplit(colmnsMess, ',')
		local groupTitle = BossData[groupInd].title
		for colInd,membersMess in ipairs(columns) do
			local members = ZRA.dicestring(membersMess)
			local header = BossData[groupInd].columns[colInd].header
			local thisDiff = ZRA.setGetDiff(BossData[groupInd].columns[colInd], 'members', members)
			if thisDiff then
				if diff then
					diff = 'multiple changes'
				else
					diff = ' g:' .. groupTitle .. ' c:' .. header .. " -"..thisDiff
				end
			end
		end
	end
	if diff then
		table.insert(ZRA.assignUpdateHistory, {update_type = 'boss', sender = sender, raid = raidKey, boss = bossName or "_", diff = diff})
		ZRA.dataChanged()
	end
end

function ZRA.sendAllBossAssigns(dest)
	ZRA.sendBossAssigns("Roles", nil, dest)
	for raidName, raidData in pairs(ZRA_vars.raids) do
		for bossIndex,bossAssigns in ipairs(raidData) do
			ZRA.sendBossAssigns(raidName, bossIndex, dest)
		end
	end
end

function ZRA.pushNewRoster()
	ZRA.raidsRosterVersion = ZRA.rosterVersion()
	ZRA.reGreet()
end

function ZRA.sendRosterData(dest)
	ZRA.updateRaidNums()
	local mess_arr = {}
	for k,v in pairs(ZRA_vars.roster) do
		if v.raidNum > 0 then
			table.insert(mess_arr,k .. v.raidNum)
		else
			table.insert(mess_arr,k .. v.name..ZRA.CLASS_MAP[v.class])
		end
	end
	local lines = ZRA.splitmess(mess_arr, ',', 220)
	for i,v in ipairs(lines) do
		C_ChatInfo.SendAddonMessage("ZRA", "sr" .. v, 'WHISPER', dest)
	end

	ZRA.sendBossAssigns("Roles", nil, dest)
	for raidName, raidData in pairs(ZRA_vars.raids) do
		for bossIndex,bossAssigns in ipairs(raidData) do
			ZRA.sendBossAssigns(raidName, bossIndex, dest)
		end
	end
	
end

function ZRA.HandleRemoteData(arg2, arg3, arg4)
	local sender = arg4
	local task = string.sub(arg2,0,2)
	if ZRA.debugging then print('heard '.. arg4 .. '-'.. arg2 ) end
	if task == 'he' then
		ZRA.reGreet()
		ZRA.otherUsers[sender] = true
	elseif task == 'hi' then
		ZRA.raidsRosterVersion = string.sub(arg2,3,6)
		ZRA.raidsAssignsVersion = string.sub(arg2,7,10)
		ZRA.otherUsers[sender] = true
		if ZRA.requestSent and ZRA.requestSent.item == 'rosterVersion' then
			ZRA.requestSent = nil
		end
		if ZRA.rosterVersion() ~= ZRA.raidsRosterVersion then
			ZRA.wipeVars()
			table.insert(ZRA.assignUpdateHistory, {update_type = 'roster', sender = sender, mess = 'clear your roster, its out of date'})
			ZRA.askForRosterPayload()
		elseif ZRA.raidAssignsVersion() ~= ZRA.raidsAssignsVersion then
			ZRA.askForBossAssigns()
		end
	elseif task == 'rr' then
		ZRA.sendRosterData(sender)
	elseif task == 'sr' then
		if ZRA.rosterVersion() ~= ZRA.raidsRosterVersion then
			ZRA.requestSent = nil
			table.insert(ZRA.assignUpdateHistory, {update_type = 'roster', sender = sender, mess = 'updated per roster payload partial'})
			ZRA.setRosterFromMess(string.sub(arg2,3))
		end
	elseif task == 'bu' then
		ZRA.hearBossAssigns(string.sub(arg2,3), sender)
	elseif task == 'ra' then
		ZRA.sendAllBossAssigns(sender)
	end
end

function ZRA.reGreet()
	ZRA.otherUsers = {}
	if ZRA.raidsRosterVersion and ZRA.raidsAssignsVersion then
		C_ChatInfo.SendAddonMessage("ZRA", "hi"..ZRA.raidsRosterVersion..ZRA.raidsAssignsVersion, 'RAID')
	end
end

function ZRA.Greet()
	ZRA.otherUsers = {}
	ZRA.requestSent = {t = GetTime(), item = 'rosterVersion'}
	ZRA.raidsRosterVersion = nil
	ZRA.raidsAssignsVersion = nil
	C_ChatInfo.SendAddonMessage("ZRA", "hello", 'RAID')
end

function ZRA.sendBossAssigns(raidName, bossIndex, dest)
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

	local p = 'bu' .. ZRA.RAID_MAP[raidName] .. string.format("%02d", bossIndex)
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


hooksecurefunc(C_ChatInfo,"SendAddonMessage",function(arg1,arg2,arg3,arg4,...)
	if arg1 == "ZRA" and ZRA.debugging then
		print("ME->" .. arg3 .. (arg4 or '') ..": " .. arg2)
	end
end)


ZRA.state = 0
ZRA.STATES = {
    UNKNOWN = 0,
    FRESH = 1,
    GREETED = 2,
    GETTING_ROSTER = 3,
    GOOD = 4,
    ASKED = 5,
    GETTING_ASSIGNS = 6,
    COLLECTING_ROSTERS = 7
}

ZRA.commscriptframe = CreateFrame("Frame", 'ZRACOMMFrame')
ZRA.commscriptframe:RegisterEvent("ADDON_LOADED")
ZRA.commscriptframe:RegisterEvent("CHAT_MSG_ADDON")
ZRA.commscriptframe:RegisterEvent("GROUP_JOINED")
ZRA.commscriptframe:RegisterEvent("GROUP_ROSTER_UPDATE")
ZRA.commscriptframe:SetScript("OnEvent", ZRA.CommOnEvent)
ZRA.commscriptframe:SetScript("OnUpdate", ZRA.CommOnUpdate)
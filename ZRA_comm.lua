local addonName, ZRA = ...

ZRA.com_version = "2"

ZRA.DEFAULT_WAIT_REQUEST = 4

function ZRA.onLoadComms()
		C_ChatInfo.RegisterAddonMessagePrefix("ZRA")
		ZRA.otherUsers = {} --needed?
		ZRA.request_queue = {} --needed?

		ZRA.setState(ZRA.STATES.FRESH)
		ZRA.unhandled_msgs = {}
		ZRA.backlogged_msgs = {}
end

local old_ZRA_on_load = ZRA.onLoad
function ZRA.onLoad(...)
	old_ZRA_on_load(...)
	ZRA.onLoadComms(...)
end

function ZRA.CommOnEvent(frame, event, arg1, arg2, arg3, arg4, ...)
	ZRA.safecall('comm-on-event', function()
		if event == "CHAT_MSG_ADDON" then
			if arg1 == "ZRA" then
				local sender = string.gmatch(arg4,'(%w+)-')() or arg4
				if sender == UnitName("player") then
				else
					ZRA.HandleRemoteData(arg2, arg3, sender)
				end
			end
		elseif event == "GROUP_JOINED" then
			ZRA.setState(ZRA.STATES.FRESH)
		elseif event == "GROUP_ROSTER_UPDATE" then
			ZRA.loadMembers()
			--make sure we get teh same new roster
		else
		end
	end) 
end

function ZRA.CommOnUpdate()
	ZRA.safecall('comm-on-update', function()
		if ZRA.currentRequest then
			if GetTime() - ZRA.currentRequest.t > ZRA.current_wait_time then
				ZRA.requestTimeout()
			end
		end

		ZRA.handleMessageQueue()

		if ZRA.state == ZRA.STATES.FRESH then
			ZRA.Greet()
		elseif ZRA.state == ZRA.STATES.GREETED then
		elseif ZRA.state == ZRA.STATES.GETTING_ROSTER then
		elseif ZRA.state == ZRA.STATES.GOOD then
		elseif ZRA.state == ZRA.STATES.ASKED then
		elseif ZRA.state == ZRA.STATES.GETTING_ASSIGNS then
		end
	end)
end

function ZRA.handleMessageQueue()
	while #ZRA.unhandled_msgs > 0 do
		local msg = table.remove(ZRA.unhandled_msgs, 1)
		local f = ZRA.STATE_MSG_RESPONSES[ZRA.state][msg.task]
		if f then
			ZRA.d('handling: ' .. ZRA.dump(msg))
			f(msg)
		else
			ZRA.d('backlogging: ' .. ZRA.dump(msg))
			table.insert(ZRA.backlogged_msgs, msg)
		end
	end
end

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

ZRA.STATE_MSG_RESPONSES = {
	[ZRA.STATES.UNKNOWN] = {},
    [ZRA.STATES.FRESH] = {},
    [ZRA.STATES.GREETED] = {
		['hi'] = function(msg)
			table.insert(ZRA.reponders, {sender = msg.sender, prio = string.sub(msg.mess,1,5), roster_v = string.sub(msg.mess,6,9)})
			ZRA.setTimeout(1)
		end
	},
    [ZRA.STATES.GETTING_ROSTER] = {
		['sr'] = function(msg)
			ZRA.setRosterFromMess(msg)
		end
	},
    [ZRA.STATES.GOOD] = {
		['hi'] = function()
			--make sure roster is the same, something is wrong if not. discard
		end,
		['he'] = function()
			ZRA.reGreet()
		end,
		['rr'] = function(msg)
			ZRA.sendRosterData(msg.sender)
		end,
		['bu'] = function(msg)
			ZRA.hearBossAssigns(msg)
		end
	},
    [ZRA.STATES.ASKED] = {},
    [ZRA.STATES.GETTING_ASSIGNS] = {},
    [ZRA.STATES.COLLECTING_ROSTERS] = {}
}




function ZRA.setState(state)
	ZRA.d('new state: ' .. state)
	ZRA.refresh_messages()
	ZRA.state = state
end

function ZRA.cancelRequest()
	if ZRA.currentRequest then
		print('canceling current request')
		ZRA.currentRequest = nil
	end
end

function ZRA.refresh_messages()
	ZRA.backlogged_msgs = {}
	for i,v in ipairs(ZRA.backlogged_msgs) do
		table.insert(ZRA.unhandled_msgs, v)
	end
	ZRA.backlogged_msgs = {}
end

function ZRA.setRosterFromMess(msg)
	local saw_end = false
	for entry in string.gmatch(msg.mess, '([^,]+)') do
		if string.sub(entry,1,1) == '~' then
			saw_end = true
		elseif string.len(entry) <= 3 then
			local rnum = tonumber(string.sub(entry,2))
			local name, _, _, _, _, class = GetRaidRosterInfo(rnum)
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA.temp_roster[string.sub(entry,1,1)] = dude
		else
			local rnum = 0
			local name = string.sub(entry,2,-2)
			local class = ZRA.CLASS_MAP_BACK[tonumber(string.sub(entry,-1))]
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA.temp_roster[string.sub(entry,1,1)] = dude
		end
	end
	if saw_end then
		ZRA_vars.roster = ZRA.temp_roster
		ZRA.temp_roster = nil
		ZRA.rosterModified('other-'..msg.sender)
		ZRA.checkRoster()
		ZRA.cancelRequest()
		ZRA.setState(ZRA.STATES.GOOD)
	else
		ZRA.setTimeout(2)
	end
end

function ZRA.checkRoster()
	local rv = ZRA.rosterVersion()
	if ZRA.raidsRosterVersion == rv then
		ZRA.d('roster checked out good')
	else
		error('roster didnt check out for some reason. target:' .. ZRA.dump(ZRA.raidsRosterVersion) .. ' mine:' .. ZRA.dump(rv) )
	end
end

function ZRA.askForRoster(responder)
	ZRA.raidsRosterVersion = tostring(responder.roster_v)
	ZRA.d('target roster v = ' .. ZRA.raidsRosterVersion)
	ZRA.temp_roster = {}
	ZRA.sendRequest("roster", responder.sender)
	ZRA.setState(ZRA.STATES.GETTING_ROSTER)
end

function ZRA.Greet()
	ZRA.sendRequest("greet")
	ZRA.setState(ZRA.STATES.GREETED)
end

function ZRA.sendRequest(item, askee, timeout)
	ZRA.currentRequest = {t = GetTime(), item = item, askee = askee}
	ZRA.setTimeout(timeout or ZRA.DEFAULT_WAIT_REQUEST)
	
	if item == "greet" then
		ZRA.reponders = {}
		ZRA.sendAddonMessage("he", 'RAID')
	elseif item == "roster" then
		ZRA.sendAddonMessage("rr", 'WHISPER', askee)
	else
		error('unkown request item')
	end
	
end

function ZRA.sendAddonMessage(mess, channel, dest)
	C_ChatInfo.SendAddonMessage("ZRA", ZRA.com_version .. mess , channel, dest)
end

function ZRA.setTimeout(relative_time)
	if ZRA.currentRequest then
		ZRA.current_wait_time = GetTime() - ZRA.currentRequest.t + relative_time
	else --shouldn't actually happen
		ZRA.current_wait_time = relative_time
	end
end

function ZRA.requestTimeout()
	local request = ZRA.currentRequest
	ZRA.currentRequest = nil
	if request.item == 'greet' then
		if #ZRA.reponders > 0 then
			table.sort(ZRA.reponders, function(a,b) return a.prio < b.prio end)
			ZRA.d(ZRA.dump((ZRA.reponders)))
			ZRA.askForRoster(ZRA.reponders[1])
		else
			ZRA.useMyRoster()
		end
	elseif request.item == 'roster' then
		ZRA.Greet()
	elseif request.item == 'bossAssigns' then
		ZRA.otherUsers[request.askee] = nil
		ZRA.askForBossAssigns()
	end
	
	if #ZRA.request_queue > 0 then
		ZRA.sendRequestFromQueue()
	end
end

function ZRA.useMyRoster()
	ZRA.raidsRosterVersion = ZRA.rosterVersion()
	ZRA.raidsAssignsVersion = ZRA.raidAssignsVersion()
	ZRA.setState(ZRA.STATES.GOOD)
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


function ZRA.hearBossAssigns(msg)
	local mess, sender = msg.mess, msg.sender
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
	table.insert(mess_arr,'~')
	local lines = ZRA.splitmess(mess_arr, ',', 220)
	for i,v in ipairs(lines) do
		ZRA.sendAddonMessage("sr" .. v, 'WHISPER', dest)
	end

	--ZRA.sendBossAssigns("Roles", nil, dest)
	--for raidName, raidData in pairs(ZRA_vars.raids) do
	--	for bossIndex,bossAssigns in ipairs(raidData) do
	--		ZRA.sendBossAssigns(raidName, bossIndex, dest)
	--	end
	--end
	
end

function ZRA.HandleRemoteData_OLD(mess, channel, sender)
	local task = string.sub(mess,0,2)
	ZRA.d('heard '.. sender .. '-'.. mess )
	if task == 'he' then
		ZRA.reGreet()
		ZRA.otherUsers[sender] = true
	elseif task == 'hi' then
		ZRA.raidsRosterVersion = string.sub(mess,3,6)
		ZRA.raidsAssignsVersion = string.sub(mess,7,10)
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
			ZRA.setRosterFromMess(string.sub(mess,3))
		end
	elseif task == 'bu' then
		ZRA.hearBossAssigns(string.sub(mess,3), sender)
	elseif task == 'ra' then
		ZRA.sendAllBossAssigns(sender)
	end
end

function ZRA.HandleRemoteData(mess, channel, sender)
	local version = string.sub(mess,1,1)
	if version ~= ZRA.com_version then return end
	local task = string.sub(mess,2,3)
	local rest = string.sub(mess, 4)
	ZRA.d('heard '.. sender .. '-'.. mess )
	table.insert(ZRA.unhandled_msgs, {task = task, mess = rest, sender = sender})
end

function ZRA.reGreet()
	local prio = string.sub(string.format("%.4f",math.random()),3)
	ZRA.sendAddonMessage("hi".. prio .." " ..ZRA.rosterVersion(), 'RAID')
end




--hook send_boss_assigns after assignments modified
local old_zra_modified = ZRA.assignmentsModified; 
function ZRA.assignmentsModified(...)
	old_zra_modified(...)
	local raid, boss, initiator = ...
	if initiator == 'self' then
		ZRA.sendBossAssigns(raid, boss)
	end
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
		ZRA.sendAddonMessage(p, 'WHISPER', dest)
	else
		ZRA.sendAddonMessage(p, 'RAID')
	end
end


hooksecurefunc(C_ChatInfo,"SendAddonMessage",function(arg1,arg2,arg3,arg4,...)
	if arg1 == "ZRA" then
		ZRA.d("ME->" .. arg3 .. (arg4 or '') ..": " .. arg2)
	end
end)

local old_zra_reset = ZRA.reset
function ZRA.reset(...)
	ZRA.commReset()
	old_zra_reset(...)
end

function ZRA.commReset()
	ZRA.setState(ZRA.STATES.FRESH)
	ZRA.unhandled_msgs = {}
	ZRA.backlogged_msgs = {}
	ZRA.currentRequest = nil
end


ZRA.commscriptframe = CreateFrame("Frame", 'ZRACOMMFrame')
ZRA.commscriptframe:RegisterEvent("ADDON_LOADED")
ZRA.commscriptframe:RegisterEvent("CHAT_MSG_ADDON")
ZRA.commscriptframe:RegisterEvent("GROUP_JOINED")
ZRA.commscriptframe:RegisterEvent("GROUP_ROSTER_UPDATE")
ZRA.commscriptframe:SetScript("OnEvent", ZRA.CommOnEvent)
ZRA.commscriptframe:SetScript("OnUpdate", ZRA.CommOnUpdate)
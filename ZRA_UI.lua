
local addonName, ZRA = ...

ZRA.UI = {}
ZRA.lastColumnId = 0

function ZRA.onUpdateUI()
	if ZDragframe:IsVisible() then
		local f = ZRA.getMouseFrame(ZRA.column_frames)
		if not f then f = {id = 0} end
		if not (f.id == ZRA.lastColumnId) then
			--entered, left, or transitioned
			if ZRA.lastColumnId ~= 0 then
				ZRA.column_frames[ZRA.lastColumnId]:GetScript("OnLeave")()
			end
			if f.id ~= 0 then
				f:GetScript("OnEnter")()
			end
			ZRA.lastColumnId = f.id
		end
		if f.id ~= 0 then
			local _ , mousey = GetCursorPosition()
			mousey = mousey / UIParent:GetEffectiveScale()
			local y = f:GetTop()
			f.hover_ind = floor((y - mousey)/ZRA.PLAYER_SIZE) + 1
			f:hoverAdjust()
		end
	end
	
	
end

function ZRA.updateUI()
	if not ZRALayoutFrame:IsVisible() then return end

	local raid = ZRA.current_tab or 'Roles'
	ZRA.raid_data = nil
	if raid == "Roles" then
		ZRA.raid_data = ZRA_vars.roles
		ZRALayoutFrame.rosterParent:Show()
		ZRA.dropdown:Hide()
	elseif raid == "Log" then
		ZRALayoutFrame.rosterParent:Hide()
		ZRA.raid_data = {}
		ZRA.dropdown:Hide()
	else
		ZRALayoutFrame.rosterParent:Show()
		if (ZRA.tablelen(ZRA_vars.raids[ZRA.current_tab]) == 1) then
			ZRA.dropdown:Hide()
		else
			ZRA.dropdown:Show()
		end
		local boss_name = UIDropDownMenu_GetSelectedName(ZRA.dropdown)
		local ind = 1
		for i,v in ipairs(ZRA_vars.raids[ZRA.current_tab]) do
			if v.name == boss_name then
				ind = i
				break
			end
		end
		ZRA.raid_data = ZRA_vars.raids[raid][ind]
	end

	--print("update ui " .. (ZRA.current_tab or "no tab set"))

	ZRAGenAssBtn:Show()
	ZRAdrop_mems_btn:Show()
	ZRAload_mems_btn:Show()
	ZRAscrollbox:Hide()
	if ZRA.current_tab == "Roles" then
		ZRApost_ass_btn:Hide()
	elseif ZRA.current_tab == "Log" then
		ZRApost_ass_btn:Hide()
		ZRAGenAssBtn:Hide()
		ZRAdrop_mems_btn:Hide()
		ZRAload_mems_btn:Hide()
		ZRAscrollbox:Show()
	else
		ZRApost_ass_btn:Show()
	end
			
	ZRA.freeFrames(ZRA.group_frames)
	ZRALayoutFrame.usedSpaceX = 0
	for groupInd, assign_group in ipairs(ZRA.raid_data) do
		local f = ZRA.GetAGroupFrame()
		f.text:SetText(assign_group.title)
		f:SetPoint("TOPLEFT", ZRALayoutFrame, "TOPLEFT", 30 + ZRALayoutFrame.usedSpaceX, -60)
		f.width = 60 * #assign_group.columns
		f.height = ZRA.GROUP_HEIGHT
		f:SetWidth(f.width)
		f:SetHeight(f.height)
		f:Show()
		f.busy = true
		ZRALayoutFrame.usedSpaceX = ZRALayoutFrame.usedSpaceX + f.width
		
		ZRA.freeFrames(f.columns)
		f.usedSpaceX = 0
		f.columns = {}
		
		for colInd,v in ipairs(assign_group.columns) do
			local c = ZRA.GetAColumnFrame()
			c.width = 60
			c.text:SetWidth(c.width)
			c.text:SetText(v.header)
			c.text:SetPoint("TOPLEFT", 0, c.text:GetHeight())
			local offset = - 40 - c.text:GetHeight()
			c.dataRef = assign_group.columns[colInd]
			c.column = colInd
			c.groupind = groupInd
			c:SetWidth(c.width)
			c.height = f.height + offset
			c:SetHeight(c.height)
			c:SetPoint("TOPLEFT", f, "TOPLEFT", f.usedSpaceX, offset)
			c:Show()
			c:SetParent(f)
			c.busy = true
			c.texture:SetTexture(nil, 0)
			c.texture:SetPoint("TOPLEFT", c, "TOPLEFT", 4, -4)
			c.texture:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", -4, 4)
			c:SetScript('OnEnter', function()
				c.texture:SetColorTexture(0,.25,.25, .25)
			end)
			c:SetScript('OnLeave', function()
				c.texture:SetTexture(nil, 0)
				c:adjustMembers()
			end)
			table.insert(f.columns, c)
			f.usedSpaceX = f.usedSpaceX + c.width
			for _, member in ipairs(v.members) do
				c:showGuy(ZRA_vars.roster[member])
			end
			c:adjustMembers()
		end
	end
	local s = ''
	for i, v in ipairs(ZRA.assignUpdateHistory) do
		if v.update_type == 'boss' then
			s = '\n' .. 'from: ' .. v.sender .. " r:" .. v.raid .. " b:" .. v.boss .. " ".. v.diff .. s
		elseif v.update_type == 'roster' then
			s = '\n' .. 'from: ' .. v.sender .. " r:" .. v.mess .. s
		elseif v.update_type == 'self' then
			s = '\n' .. 'from: ME ' .. " r:" .. v.raid .. " b:" .. v.boss .. " ".. v.diff .. s
		else
			print('else')
		end
	end
	s = "Event Log (most recent at top)" .. s
	ZRA.eventLogFontString:SetText(s)
end



local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}
local backdrop2 = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}
ZRA.PLAYER_SIZE = 38
ZRA.GROUP_HEIGHT = 300

function ZRA.onLoadUI()
	ZRA.group_frames = {}
	ZRA.column_frames = {}
	ZRA.player_frames = {}
	ZRA.asignee_frames = {}
	
	local f = CreateFrame("Frame", "ZRALayoutFrame", UIParent)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, 110)
	f:SetScript("OnMouseUp", f.StopMovingOrSizing)
	f:SetScript("OnHide", f.StopMovingOrSizing)
	f:SetScript("OnMouseDown", f.StartMoving)
	f:SetFrameStrata("MEDIUM")
	f:SetWidth(710)
	f:SetHeight(500)
	-- create background
	f:SetFrameLevel(0)
	
	f:SetBackdrop(backdrop)
	-- create bg texture
	f.texture = f:CreateTexture(nil, "BORDER")
	f.texture:SetColorTexture(0,0,.5,.5)
	f.texture:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
	f.texture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
	f.texture:SetBlendMode("ADD")
	f.texture:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .2, .2, .2, 0.5)
	f:SetBackdropColor(.3,.3,.3,.3)
	f:Show()
	f.usedSpaceX = 0

	tinsert(UISpecialFrames, f:GetName())

	local closebutton = CreateFrame("Button",nil,f,"UIPanelCloseButton")
	closebutton:SetScript("OnClick", ZRA.closeOnClick)
	closebutton:SetPoint("TOPRIGHT",f,"TOPRIGHT",-2,-2)
	f.closebutton = closebutton
	closebutton.obj = f

	ZRALayoutFrame.rosterParent = CreateFrame("Frame",nil,f)
	ZRALayoutFrame.rosterParent:Show()

	--make tabs
	local b = CreateFrame("Button", "$parentTab1", ZRALayoutFrame, "TabButtonTemplate")
	local tabkey = "Roles"
	b:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", 100, 0)
	b:SetWidth(100)
	b:Show()
	b:SetText(tabkey)
	b.id = 1
	b:SetScript("OnClick", ZRA.tabClicked(tabkey, 1))
	PanelTemplates_TabResize(b, 10, 100, 300)

	local tabind = 2
	for raid, _ in pairs(ZRA_vars.raids) do
		b = CreateFrame("Button", "$parentTab" .. tabind, ZRALayoutFrame, "TabButtonTemplate")
		b:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", tabind*100, 0)
		b:SetWidth(100)
		b:Show()
		b:SetText(raid)
		b.id = tabind
		b:SetScript("OnClick", ZRA.tabClicked(raid, tabind))
		PanelTemplates_TabResize(b, 10, 100, 300)
		tabind = tabind + 1
	end
	b = CreateFrame("Button", "$parentTab" .. tabind, ZRALayoutFrame, "TabButtonTemplate")
	b:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", tabind*100, 0)
	b:SetWidth(100)
	b:Show()
	b:SetText("Log")
	b.id = tabind
	b:SetScript("OnClick", ZRA.tabClicked("Log", tabind))
	PanelTemplates_TabResize(b, 10, 100, 300)

	PanelTemplates_SetNumTabs(ZRALayoutFrame, tabind)
	PanelTemplates_SetTab(ZRALayoutFrame, 1)

	ZRA.dropdown = CreateFrame("Frame", "ZRAFightDropDown", ZRALayoutFrame, "UIDropDownMenuTemplate")
	ZRA.dropdown:SetPoint("TOPRIGHT", ZRALayoutFrame, "TOPRIGHT", -150, -20)
	UIDropDownMenu_Initialize(ZRA.dropdown, ZRA.clickDropDown)

	--dragframe
	local dragframe = CreateFrame("Button", "ZDragframe", ZRALayoutFrame)
	dragframe:SetBackdrop(backdrop2)
	dragframe.Text = dragframe:CreateFontString(nil, "ARTWORK")
	dragframe.Text:SetFont(STANDARD_TEXT_FONT, 12)
	dragframe.Text:SetJustifyH("CENTER")
	dragframe.Text:SetJustifyV("CENTER")
	dragframe.Text:SetPoint("CENTER", dragframe, "CENTER")
	dragframe.Text:SetText("test")
	dragframe.Text:SetTextColor(0,0,0)
	dragframe:SetMovable(true)
	dragframe:Hide()


	ZRA.updateRosterUI()
	

	--Generate Assignments
	local gen_ass_btn = CreateFrame("Button",'ZRAGenAssBtn', ZRALayoutFrame, "UIPanelButtonTemplate")
	gen_ass_btn:SetText("Auto Fill")
	gen_ass_btn:SetPoint("TOPLEFT", ZRALayoutFrame, "TOPLEFT", 14, -14)
	gen_ass_btn:SetWidth(120)
	gen_ass_btn:SetHeight(30)
	gen_ass_btn:SetScript("OnClick", function()
		if ZRA.current_tab == "Roles" then
			--print('generating assignments for ' .. ZRA.current_tab)
			ZRA.funcs.Roles()
			ZRA.sendBossAssigns("Roles")
		else
			--print('generating assignments for ' .. ZRA.current_tab .. ' ' .. ZRA.getDropdownName())
			ZRA.funcs[ZRA.current_tab][ZRA.getDropdownName()]()
			ZRA.sendBossAssigns(ZRA.current_tab, ZRA.getDropdownInd())
		end
		table.insert(ZRA.assignUpdateHistory, {update_type = 'self', raid = ZRA.current_tab, boss =  ZRA.getDropdownName() or "_", diff = 'I auto filled'})
		ZRA.updateUI()
	end)
	gen_ass_btn:Show()

	--Post Assignments
	local ZRApost_ass_btn = CreateFrame("Button",'ZRApost_ass_btn', ZRALayoutFrame, "UIPanelButtonTemplate")
	ZRApost_ass_btn:SetText("Post")
	ZRApost_ass_btn:SetPoint("TOPLEFT", ZRALayoutFrame, "TOPLEFT", 14 + 130, -14)
	ZRApost_ass_btn:SetWidth(120)
	ZRApost_ass_btn:SetHeight(30)
	ZRApost_ass_btn:SetScript("OnClick", function()
		--print('posting ' .. UIDropDownMenu_GetSelectedName(ZRA.dropdown) .. ' assignments to raid')
		local phrases = ZRA.announcements[ZRA.current_tab][UIDropDownMenu_GetSelectedName(ZRA.dropdown)](ZRA.raid_data)
		if UnitInRaid("player") and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then
			for _, line in ipairs(phrases or {}) do
				SendChatMessage(line ,"RAID_WARNING" )
			end
		elseif UnitInRaid("player") then
			for _, line in ipairs(phrases or {}) do
				SendChatMessage(line ,"RAID" )
			end
		else
			for _, line in ipairs(phrases or {}) do
				print(line )
			end
		end
		
	end)
	ZRApost_ass_btn:Show()

	--load members
	local load_mems_btn = CreateFrame("Button",'ZRAload_mems_btn', ZRALayoutFrame, "UIPanelButtonTemplate")
	load_mems_btn:SetText("Populate")
	load_mems_btn:SetPoint("TOPLEFT", ZRALayoutFrame, "BOTTOMLEFT", 14 , 50)
	load_mems_btn:SetWidth(67)
	load_mems_btn:SetHeight(30)
	load_mems_btn:SetScript("OnClick", function()
		ZRA.loadMembers()
		ZRA.updateRosterUI()
		ZRA.updateUI()
	end)
	load_mems_btn:Show()

	--drop members
	local drop_mems_btn = CreateFrame("Button",'ZRAdrop_mems_btn', ZRALayoutFrame, "UIPanelButtonTemplate")
	drop_mems_btn:SetText("Drop")
	drop_mems_btn:SetPoint("TOPLEFT", ZRALayoutFrame, "BOTTOMLEFT", 14 , 90)
	drop_mems_btn:SetWidth(67)
	drop_mems_btn:SetHeight(30)
	drop_mems_btn:SetScript("OnClick", function()
		ZRA.dropExternalMembers()
		ZRA.updateRosterUI()
		ZRA.updateUI()
	end)
	drop_mems_btn:Show()


	--local scrollparent = 
	
	local scrollbox = CreateFrame("Frame", "ZRAscrollbox", f)
	scrollbox:EnableMouse(true)
	scrollbox:SetMovable(true)
	scrollbox:SetClampedToScreen(true)
	scrollbox:SetPoint("TOPRIGHT", f, "TOPRIGHT", -50, -40)
	scrollbox:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -40)
	scrollbox:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -50, 40)
	scrollbox:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 40)
	scrollbox:SetFrameStrata("MEDIUM")
	scrollbox:SetBackdrop(backdrop)
	scrollbox:SetBackdropColor(.8,.8,.8,.8)
	scrollbox:Show()

	scrollbox.scroll = CreateFrame("ScrollFrame", "ZRAmyScrollFrame", scrollbox, "UIPanelScrollFrameTemplate")
	scrollbox.content = CreateFrame("Frame", 'ZRAScrollyTextFrame', scrollbox.scroll)
	scrollbox.content:SetSize(scrollbox.scroll:GetWidth(), 0) -- Vert scroll only (*)
	scrollbox.scroll:SetScrollChild(scrollbox.content)
	local eventsLogString = scrollbox.content:CreateFontString()
 
	eventsLogString:SetPoint("TOPLEFT")
	eventsLogString:SetPoint("TOPRIGHT") -- Vert scroll only
	eventsLogString:SetFont(STANDARD_TEXT_FONT, 12)
	eventsLogString:SetText('events log')
	ZRA.eventLogFontString = eventsLogString

	scrollbox.scroll:SetAllPoints(scrollbox)
	scrollbox.scroll:SetPoint("TOPLEFT", 0, -20)
	scrollbox.scroll:SetPoint("TOPRIGHT", 0, -20)
	scrollbox.content:SetSize(scrollbox.scroll:GetWidth(),  scrollbox.scroll:GetHeight())
	scrollbox:Hide()

	ZRA.showRoles()
	f:Hide()
end

function ZRA.updateRosterUI()
	ZRA.freeFrames(ZRA.player_frames)
	ZRA.updateRaidNums()
	
	local temp = {}
	for r in ZRA.raid_iter() do
		table.insert(temp, r)
	end
	table.sort(temp, function(a, b) return(a.class < b.class) end)
	for i, r in ipairs(temp) do
		ZRA.setAPlayerFrame(r)
	end
end

function ZRA.clickDropDown()
	if ZRA_vars.raids[ZRA.current_tab] then
		for i, v in ipairs(ZRA_vars.raids[ZRA.current_tab]) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = v.name
			info.func = function (arg)
				--print(arg.value)
				UIDropDownMenu_SetSelectedName(ZRAFightDropDown, arg.value)
				UIDropDownMenu_SetText(ZRAFightDropDown, arg.value)
				if ZRA.assignmentsAreBlank(ZRA.current_tab or "Roles", ZRA.getDropdownInd()) then
					ZRAGenAssBtn:GetScript("OnClick")()
				end
				ZRA.showBoss(ZRA.current_tab, ZRA.getDropdownInd())
			end
			UIDropDownMenu_AddButton(info)
		end
	end
end

function ZRA.getDropdownInd()
	local ind = 1
	if ZRA.current_tab == "Roles" or ZRA.current_tab == "Log" then
		return -1
	end
	for i,v in ipairs(ZRA_vars.raids[ZRA.current_tab]) do
		if v.name == UIDropDownMenu_GetSelectedName(ZRA.dropdown) then
			ind = i
			break
		end
	end
	return ind
end

function ZRA.getDropdownName()
	if ZRA.current_tab == "Roles" or ZRA.current_tab == "Log" then return end
	return ZRA_vars.raids[ZRA.current_tab][ZRA.getDropdownInd()].name
end

function ZRA.tabClicked(key, tabindex)
	return function()
		PanelTemplates_SetTab(ZRALayoutFrame, tabindex)
		ZRA.current_tab = key
		if ZRA.assignmentsAreBlank(ZRA.current_tab or "Roles", ZRA.getDropdownInd()) then
			ZRAGenAssBtn:GetScript("OnClick")()
		end

		if key == "Roles" then
			ZRA.showRoles()
		elseif key == "Log" then
			ZRA.showLog()
		else
			local boss_name = UIDropDownMenu_GetSelectedName(ZRA.dropdown)
			local ind = 1
			for i,v in ipairs(ZRA_vars.raids[ZRA.current_tab]) do
				if v.name == boss_name then
					ind = i
					break
				end
			end
			UIDropDownMenu_SetSelectedName(ZRAFightDropDown, ZRA_vars.raids[ZRA.current_tab][ind].name)
			UIDropDownMenu_SetText(ZRAFightDropDown, ZRA_vars.raids[ZRA.current_tab][ind].name)
			ZRA.showBoss(key)
		end
	end
end

function ZRA.showRoles()
	ZRA.showBoss("Roles")
end

function ZRA.showLog()
	
	ZRA.showBoss("Log")
end

function ZRA.showBoss()
	

	ZRA.updateUI()
end

function ZRA.freeFrames(frames)
	for i, v in pairs(frames) do 
		v.busy = false
		if v.members then
			ZRA.freeFrames(v.members)
			v.members = {}
		end
		if v.columns then
			ZRA.freeFrames(v.columns)
			v.columns = {}
			v.usedSpaceX = 0
		end
		v:Hide()
	end
end

function ZRA.catchAsignee(catcher, player)
	local code = ZRA.getCodeFromName(player.name)
	local setZRA = ZRA.setRaidAssignment
	for i,v in pairs(catcher.dataRef.members) do
		--dont allowe dupplicated
		if code == v then return end
	end
	catcher.hover_ind = min(catcher.hover_ind, #catcher.members + 1)
	local updatedMembers = ZRA.shallowcopy(catcher.dataRef.members)
	table.insert(updatedMembers, catcher.hover_ind , code)
	setZRA(ZRA.current_tab, ZRA.getDropdownInd(), catcher.groupind, catcher.column , updatedMembers, 'self')
	ZRA.showAsignee(catcher, player, catcher.hover_ind )
	table.insert(ZRA.assignUpdateHistory, {update_type = 'self', raid = ZRA.current_tab, boss =  UIDropDownMenu_GetSelectedName(ZRA.dropdown) or "_", diff = 'assigned ' .. player.name})
	ZRA.sendBossAssigns(ZRA.current_tab, ZRA.getDropdownInd())
	--return catcher
end

function ZRA.showAsignee(catcher, player, where)
	local f = ZRA.getAnAsigneeFrame()
	f:SetParent(catcher)
	f:SetScript("OnMouseUp", function(self,btn)
		ZDragframe:StopMovingOrSizing()
		local inframe = ZRA.getMouseFrame(ZRA.column_frames)
		if inframe then	
			inframe:catchGuy(player)
		end
		ZDragframe:Hide()
		self:finishHide()
	end)
	f:SetScript("OnMouseDown", function(self,btn)
		self:GetParent():dropGuy(player)
		ZRA.pickUpPlayer(f, player)
	end)
	f:SetScript('OnEnter', function()
		ZRA.mouseOverEnter(player)
	end)
	f:SetScript('OnLeave', function()
		ZRA.mouseOverExit(player)
	end)
	f:SetPoint("CENTER", catcher, "TOP", 0 , -20 );
	local color = ZRA.playerColor(player)
	f:SetBackdropColor(color.r, color.g, color.b,1)
	f.Text:SetText(string.sub(player.name,1,4))
	f.busy = true
	f.player = player
	table.insert(catcher.members, where or #catcher.members + 1, f)
	catcher:adjustMembers()
	f:Show()
end

function ZRA.playerColor(player)
	local rn = ZRA_vars.roster[ZRA.getCodeFromName(player.name)].raidNum
	local c = RAID_CLASS_COLORS[player.class]
	if ZRA.dontgray or player.name == UnitName("player") then return c end
	if rn == 0 then
		return {r=0.2*c.r, g=0.2*c.g, b=0.2*c.b}
	else
		local _, _, _, _, _, _, _, online = GetRaidRosterInfo(rn)
		if online then
			return RAID_CLASS_COLORS[player.class]
		else
			return {r=0.55, g=0.55, b=0.55}
		end
	end
end

function ZRA.UIDropAsignee(columnframe, player)
	local playerCode = ZRA.getCodeFromName(player.name)
	ZRA.dropAsignee(playerCode, ZRA.current_tab, ZRA.getDropdownInd(), columnframe.groupind, columnframe.column, 'self')
	for i,v in ipairs(columnframe.members) do
		if v.player.name == player.name then
			v:startHide()
			table.remove(columnframe.members, i)
		end
	end
	table.insert(ZRA.assignUpdateHistory, {update_type = 'self', raid = ZRA.current_tab, boss =  UIDropDownMenu_GetSelectedName(ZRA.dropdown) or "_", diff = 'removed ' .. player.name})
	ZRA.sendBossAssigns(ZRA.current_tab, ZRA.getDropdownInd())
end

function ZRA.mouseOverEnter(player)
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit("raid" .. player.raidNum)
	GameTooltip:Show()
end

function ZRA.mouseOverExit(player)
	GameTooltip:FadeOut()
end

function ZRA.getAnAsigneeFrame()
	local i  = ZRA.findNotBusyFrame(ZRA.asignee_frames)
	if i then 
		return ZRA.asignee_frames[i]
	else
		local f = CreateFrame("Button", nil, ZRALayoutFrame)
		f = CreateFrame("Button", nil, ZRALayoutFrame);
		f:SetWidth(ZRA.PLAYER_SIZE)
		f:SetHeight(ZRA.PLAYER_SIZE)
		f:SetBackdrop(backdrop2)
		--f:EnableMouse()
		f.texture = f:CreateTexture(nil, "BORDER")
		f.Text = f:CreateFontString(nil, "ARTWORK")
		f.Text:SetFont(STANDARD_TEXT_FONT, 12)
		f.Text:SetJustifyH("CENTER")
		f.Text:SetJustifyV("CENTER")
		f.Text:SetPoint("CENTER", f, "CENTER")
		f.Text:SetTextColor(0,0,0)
		f.id = #ZRA.asignee_frames + 1
		f.startHide = ZRA.asigneeStartHide
		f.finishHide = ZRA.asigneeFinishHide
		table.insert(ZRA.asignee_frames, f)
		return f
	end
end

function ZRA.asigneeStartHide(self)
	self:SetAlpha(0)
end

function ZRA.asigneeFinishHide(self)
	self:SetAlpha(1)
	self.busy = false
	self:Hide()
end

function ZRA.GetAColumnFrame()
	local i  = ZRA.findNotBusyFrame(ZRA.column_frames)
	if i then 
		return ZRA.column_frames[i]
	else
		local f = CreateFrame("Frame", nil, ZRALayoutFrame)
		f.text = f.text or f:CreateFontString(nil,"ARTWORK","GameFontNormal")
		f.text:SetJustifyH("CENTER")
		f.text:SetJustifyV("TOP")
		f.text:SetPoint("TOPLEFT", 0, 10)
		f.texture = f:CreateTexture(nil, "BORDER")
		f:EnableMouse()
		f.text:SetTextColor(1,1,0,1)
		f.id = #ZRA.column_frames + 1
		f.members = {}
		f.catchGuy = ZRA.catchAsignee
		f.showGuy = ZRA.showAsignee
		f.dropGuy = ZRA.UIDropAsignee
		f.adjustMembers = ZRA.columnAdjustMembers
		f.hoverAdjust = ZRA.columnAdjustHover
		table.insert(ZRA.column_frames, f)
		return f
	end
end

function ZRA.UI.ActiveFramesIter(frames_group)
	local i = 0
	local n = #frames_group
	return function ()
		while i <= n do
			i = i + 1
			if frames_group[i].busy == true then
				return frames_group[i]
			end
		end
	end
end

function ZRA.columnAdjustMembers(self)
	for i,v in ipairs(self.members) do
		v:SetPoint("CENTER", self, "TOP", 0 , -20 - ZRA.PLAYER_SIZE*(i -1));
	end
end

function ZRA.columnAdjustHover(self)
	--hover_ind is set
	for i,v in ipairs(self.members) do
		local adjustment = self.hover_ind <= i and 1 or 0
		v:SetPoint("CENTER", self, "TOP", 0 , -20 - ZRA.PLAYER_SIZE*(i -1 + adjustment))
	end
end

function ZRA.GetAGroupFrame()
	local i  = ZRA.findNotBusyFrame(ZRA.group_frames)
	if i then 
		return ZRA.group_frames[i]
	else
		local f = CreateFrame("Frame", nil, ZRALayoutFrame)
		f:SetFrameStrata("MEDIUM")
		f:SetFrameLevel(0)
		f:SetBackdrop(backdrop)
		f.texture = f:CreateTexture(nil, "BORDER")
		f.texture:SetColorTexture(.5,.5,.5, 1)
		f.texture:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
		f.texture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
		f:SetBackdropColor(.3,.3,.3,.3)
		f.text = f.text or f:CreateFontString(nil,"ARTWORK","QuestFont_Shadow_Huge")
		f.text:SetAllPoints(true)
		f.text:SetJustifyH("CENTER")
		f.text:SetJustifyV("TOP")
		f.text:SetPoint("TOPLEFT", 0, -10)
		f.text:SetTextColor(1,1,0,1)
		f.columns = {}
		table.insert(ZRA.group_frames, f)
		return f
	end
end

function ZRA.getMouseFrame(frames)
	local mousex, mousey = GetCursorPosition()
	mousex = mousex / UIParent:GetEffectiveScale()
	mousey = mousey / UIParent:GetEffectiveScale()
	for i, v in ipairs(ZRA.column_frames) do
		if v:IsVisible() then
			local x,y = v:GetCenter()
			if abs(x - mousex) < v:GetWidth()/2 and abs(y - mousey) < v:GetHeight()/2 then
				return v
			end
		end
	end
end

function ZRA.pickUpPlayer(copying_frame, player)
	ZDragframe:SetPoint("TOPLEFT", copying_frame, "TOPLEFT")
	ZDragframe:SetPoint("BOTTOMRIGHT", copying_frame, "TOPLEFT", ZRA.PLAYER_SIZE, -ZRA.PLAYER_SIZE)
	--ZDragframe:SetHeight(ZRA.PLAYER_SIZE)
	--ZDragframe:SetWidth(ZRA.PLAYER_SIZE)
	local color = ZRA.playerColor(player)
	ZDragframe:SetBackdropColor(color.r, color.g, color.b,1)
	ZDragframe.Text:SetText(string.sub(player.name,1,4))
	ZDragframe:Show()
	ZDragframe:StartMoving()
	ZDragframe.player = player
end


function ZRA.setAPlayerFrame(player)
	local f = ZRA.getAPlayerFrame() 

	f:SetScript("OnMouseUp", function(self,btn)
		ZDragframe:StopMovingOrSizing()
		local inframe = ZRA.getMouseFrame(ZRA.column_frames)
		if inframe then	
			inframe:catchGuy(player)
		end
		ZDragframe:Hide()
	end)
	f:SetScript("OnMouseDown", function(self,btn)
		ZRA.pickUpPlayer(f, player)
	end)
	f:SetScript('OnEnter', function()
		ZRA.mouseOverEnter(player)
	end)
	f:SetScript('OnLeave', function()  
		ZRA.mouseOverExit(player)
	end)
	local nframes = ZRA.countBusyFrames(ZRA.player_frames)
	local cols_per_row =  math.floor((ZRALayoutFrame:GetWidth() - 8 - 80 )/ (f:GetWidth() + 2))
	local row = math.floor(nframes / cols_per_row)
	local col = ZRA.modulo(nframes , cols_per_row)
	f:SetPoint("CENTER", ZRALayoutFrame, "BOTTOMLEFT", 80 + 30 + f:GetHeight()*col , 30 + f:GetWidth()*row);
	local color = ZRA.playerColor(player)
	f:SetBackdropColor(color.r, color.g, color.b,1)
	f.Text:SetText(string.sub(player.name,1,4))
	f.busy = true
	f:Show()
end


function ZRA.getAPlayerFrame()
	local i = ZRA.findNotBusyFrame(ZRA.player_frames)
	if i then
		return ZRA.player_frames[i]
	else
		local f = CreateFrame("Button", nil, ZRALayoutFrame.rosterParent);
		f:SetWidth(ZRA.PLAYER_SIZE)
		f:SetHeight(ZRA.PLAYER_SIZE)
		f:SetBackdrop(backdrop2)
		f:EnableMouse()
		f.Text = f:CreateFontString(nil, "ARTWORK")
		f.Text:SetFont(STANDARD_TEXT_FONT, 12)
		f.Text:SetJustifyH("CENTER")
		f.Text:SetJustifyV("CENTER")
		f.Text:SetPoint("CENTER", f, "CENTER")
		f.Text:SetText("test")
		f.Text:SetTextColor(0,0,0)
		table.insert(ZRA.player_frames, f)
		return f
	end
end



function ZRA.findNotBusyFrame(frames)
	for i = 1, #frames do
		if frames[i].busy == false then
			return i
		end
	end
end

function ZRA.countBusyFrames(frames)
	local cnt = 0
	for i = 1, #frames do
		if frames[i].busy == true then
			cnt = cnt + 1
		end
	end
	return cnt
end



ZRA.scriptframe = CreateFrame("Frame")
ZRA.scriptframe:RegisterEvent("ADDON_LOADED")

ZRA.scriptframe:SetScript("OnUpdate", ZRA.onUpdateUI)



function ZRA.OpenMenu()
	ZRA.updateRaidNums()
	if not ZRA.current_tab then 
		ZRA.tabClicked("Roles")()
	end
	if ZRA.assignmentsAreBlank(ZRA.current_tab or "Roles", ZRA.getDropdownInd()) then
		ZRAGenAssBtn:GetScript("OnClick")()
	end
	ZRALayoutFrame:Show()
	ZRA.updateRosterUI()
	ZRA.updateUI()
end

function ZRA.closeOnClick(self)
	self.obj:Hide()
end






--local RL = AceLibrary("Roster-2.1")

local ZodsRaidAssign = {

}


	

ZodsRaidAssign.lastColumnId = 0

function ZodsRaidAssign.onUpdate()
	if ZDragframe:IsVisible() then
		local f = ZodsRaidAssign.getMouseFrame(ZodsRaidAssign.column_frames)
		if not f then f = {id = 0} end
		if not (f.id == ZodsRaidAssign.lastColumnId) then
			--entered, left, or transitioned
			if ZodsRaidAssign.lastColumnId ~= 0 then
				ZodsRaidAssign.column_frames[ZodsRaidAssign.lastColumnId]:GetScript("OnLeave")()
			end
			if f.id ~= 0 then
				f:GetScript("OnEnter")()
			end
			ZodsRaidAssign.lastColumnId = f.id
		end
		if f.id ~= 0 then
			local _ , mousey = GetCursorPosition()
			mousey = mousey / UIParent:GetEffectiveScale()
			local y = f:GetTop()
			f.hover_ind = floor((y - mousey)/ZodsRaidAssign.PLAYER_SIZE) + 1
			f:hoverAdjust()
		end
	end
	
	
end


function ZodsRaidAssign.onEvent(frame, event, arg1, arg2, arg3, ...)

	if (event == "ADDON_LOADED" and arg1 == "ZodsRaidAssign") then
		ZodsRaidAssign.onLoad()
		
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "ZRA" and (arg3 == "PARTY" or arg3 == "WHISPER" or arg3 == "RAID")  then -- and arg4 ~= UnitName("player")
      ZodsRaidAssign:HandleRemoteData(arg2, arg4)
	end
	else
		--unhandled onEvent
		--DEFAULT_CHAT_FRAME:AddMessage(event..(arg1 or ""))
	end
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
ZodsRaidAssign.PLAYER_SIZE = 38
ZodsRaidAssign.GROUP_HEIGHT = 300

function ZodsRaidAssign.onLoad()
	ZodsRaidAssign.group_frames = {}
	ZodsRaidAssign.column_frames = {}
	ZodsRaidAssign.player_frames = {}
	ZodsRaidAssign.asignee_frames = {}
	
	local f = CreateFrame("Frame", "ZRALayoutFrame", UIParent)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, 20)
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
	f.texture:SetTexture(0,0,.5,.5)
	f.texture:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
	f.texture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
	f.texture:SetBlendMode("ADD")
	f.texture:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .2, .2, .2, 0.5)
	f:SetBackdropColor(.3,.3,.3,.3)
	f:Show()
	f.usedSpaceX = 0

	local closebutton = CreateFrame("Button",nil,f,"UIPanelCloseButton")
	closebutton:SetScript("OnClick", ZodsRaidAssign.closeOnClick)
	closebutton:SetPoint("TOPRIGHT",f,"TOPRIGHT",-2,-2)
	f.closebutton = closebutton
	closebutton.obj = f

	--make tabs
	local b = CreateFrame("Button", "$parentTab1", ZRALayoutFrame, "TabButtonTemplate")
	local tabkey = "Roles"
	b:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", 100, 0)
	b:SetWidth(100)
	b:Show()
	b:SetText(tabkey)
	b.id = 1
	b:SetScript("OnClick", ZodsRaidAssign.tabClicked(tabkey, 1))
	PanelTemplates_TabResize(b, 10, 100, 300)

	local tabind = 2
	for raid, _ in pairs(ZRA_vars.raids) do
		b = CreateFrame("Button", "$parentTab" .. tabind, ZRALayoutFrame, "TabButtonTemplate")
		b:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", tabind*100, 0)
		b:SetWidth(100)
		b:Show()
		b:SetText(raid)
		b.id = tabind
		b:SetScript("OnClick", ZodsRaidAssign.tabClicked(raid, tabind))
		PanelTemplates_TabResize(b, 10, 100, 300)
		tabind = tabind + 1
	end
	PanelTemplates_SetNumTabs(ZRALayoutFrame, tabind - 1)
	PanelTemplates_SetTab(ZRALayoutFrame, 1)

	ZodsRaidAssign.dropdown = CreateFrame("Frame", "ZRAFightDropDown", ZRALayoutFrame, "UIDropDownMenuTemplate")
	ZodsRaidAssign.dropdown:SetPoint("TOPRIGHT", ZRALayoutFrame, "TOPRIGHT", -150, -20)
	UIDropDownMenu_Initialize(ZodsRaidAssign.dropdown, ZodsRaidAssign.clickDropDown)

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

	--make roster
	local temp = {}
	for r in ZodsRaidAssignPublic.raid_iter() do
		table.insert(temp, r)
	end
	table.sort(temp, function(a, b) return(a.class < b.class) end)
	for i, r in ipairs(temp) do
		ZodsRaidAssign.setAPlayerFrame(r)
	end

	--Generate Assignments
	local gen_ass_btn = CreateFrame("Button",'ZRAGenAssBtn', ZRALayoutFrame, "UIPanelButtonTemplate")
	gen_ass_btn:SetText("Auto Fill")
	gen_ass_btn:SetPoint("TOPLEFT", ZRALayoutFrame, "TOPLEFT", 10, -10)
	gen_ass_btn:SetWidth(120)
	gen_ass_btn:SetHeight(30)
	gen_ass_btn:SetScript("OnClick", function()
		print('generating assignments for page')
	end)
	gen_ass_btn:Show()

	--Post Assignments
	local post_ass_btn = CreateFrame("Button",'post_ass_btn', ZRALayoutFrame, "UIPanelButtonTemplate")
	post_ass_btn:SetText("Post")
	post_ass_btn:SetPoint("TOPLEFT", ZRALayoutFrame, "TOPLEFT", 10 + 130, -10)
	post_ass_btn:SetWidth(120)
	post_ass_btn:SetHeight(30)
	post_ass_btn:SetScript("OnClick", function()
		print('posting assignments to raid')
	end)
	post_ass_btn:Show()

	--Push Assignments
	--local share_ass_btn = CreateFrame("Button",'share_ass_btn', ZRALayoutFrame, "UIPanelButtonTemplate")
	--share_ass_btn:SetText("Push")
	--share_ass_btn:SetPoint("TOPLEFT", ZRALayoutFrame, "TOPLEFT", 10 + 130, -10)
	--share_ass_btn:SetWidth(120)
	--share_ass_btn:SetHeight(30)
	--share_ass_btn:SetScript("OnClick", function()
	--	print('pushing assignments to raid')
	--end)
	--share_ass_btn:Show()

	f:Hide()
end

function ZodsRaidAssign.clickDropDown()
	if ZRA_vars.raids[ZodsRaidAssign.current_tab] then
		for i, v in ipairs(ZRA_vars.raids[ZodsRaidAssign.current_tab]) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = v.name
			info.func = function (arg)
				--print(arg.value)
				UIDropDownMenu_SetSelectedName(ZRAFightDropDown, arg.value)
				UIDropDownMenu_SetText(ZRAFightDropDown, arg.value)
				local ind = 1
				for i,v in ipairs(ZRA_vars.raids[ZodsRaidAssign.current_tab]) do
					if v.name == arg.value then
						ind = i
						break
					end
				end
				ZodsRaidAssign.showBoss(ZodsRaidAssign.current_tab, ind)
			end
			UIDropDownMenu_AddButton(info)
		end
	end
end


function ZodsRaidAssign.tabClicked(key, tabindex)
	return function()
		PanelTemplates_SetTab(ZRALayoutFrame, tabindex)
		ZodsRaidAssign.current_tab = key
		--print(key)
		if key == "Roles" or tablelen(ZRA_vars.raids[ZodsRaidAssign.current_tab]) == 1 then
			ZodsRaidAssign.dropdown:Hide()
		else
			ZodsRaidAssign.dropdown:Show()
		end
		if key == "Roles" then
			ZodsRaidAssign.showRoles()
		else
			local boss_name = UIDropDownMenu_GetSelectedName(ZodsRaidAssign.dropdown)
			local ind = 1
			for i,v in ipairs(ZRA_vars.raids[ZodsRaidAssign.current_tab]) do
				if v.name == boss_name then
					ind = i
					break
				end
			end
			UIDropDownMenu_SetSelectedName(ZRAFightDropDown, ZRA_vars.raids[ZodsRaidAssign.current_tab][ind].name)
			UIDropDownMenu_SetText(ZRAFightDropDown, ZRA_vars.raids[ZodsRaidAssign.current_tab][ind].name)
			ZodsRaidAssign.showBoss(key, ind)
		end
	end
end

function ZodsRaidAssign.showRoles()
	ZodsRaidAssign.showBoss()
end

function ZodsRaidAssign.showBoss(raid, boss)
	local raid_data = nil
	if boss then 
		raid_data = ZRA_vars.raids[raid][boss] 
	else
		raid_data = ZRA_vars.roles
	end
	ZodsRaidAssign.freeFrames(ZodsRaidAssign.group_frames)
	ZRALayoutFrame.usedSpaceX = 0
	for i, assign_group in ipairs(raid_data) do
		local f = ZodsRaidAssign.GetAGroupFrame()
		f.text:SetText(assign_group.title)
		f:SetPoint("TOPLEFT", ZRALayoutFrame, "TOPLEFT", 30 + ZRALayoutFrame.usedSpaceX, -60)
		f.width = 60 * #assign_group.columns
		f.height = ZodsRaidAssign.GROUP_HEIGHT
		f:SetWidth(f.width)
		f:SetHeight(f.height)
		f:Show()
		f.busy = true
		ZRALayoutFrame.usedSpaceX = ZRALayoutFrame.usedSpaceX + f.width
		
		ZodsRaidAssign.freeFrames(f.columns)
		f.usedSpaceX = 0
		f.columns = {}
		
		for i,v in ipairs(assign_group.columns) do
			local c = ZodsRaidAssign.GetAColumnFrame()
			c.width = 60
			c.text:SetWidth(c.width)
			c.text:SetText(v.header)
			c.text:SetPoint("TOPLEFT", 0, c.text:GetHeight())
			local offset = - 40 - c.text:GetHeight()
			c.dataRef = assign_group.columns[i]
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
			for i, member in ipairs(v.members) do
				c:showGuy(ZRA_vars.roster[member])
			end
			c:adjustMembers()
		end
	end
end

function ZodsRaidAssign.freeFrames(frames)
	for i, v in pairs(frames) do 
		v.busy = false
		if v.members then
			ZodsRaidAssign.freeFrames(v.members)
			v.members = {}
		end
		if v.columns then
			ZodsRaidAssign.freeFrames(v.columns)
			v.columns = {}
			v.usedSpaceX = 0
		end
		v:Hide()
	end
end

function ZodsRaidAssign.catchAsignee(catcher, player)
	catcher.hover_ind = min(catcher.hover_ind, #catcher.members + 1)
	table.insert(catcher.dataRef.members, catcher.hover_ind , ZodsRaidAssignPublic.getCodeFromName(player.name))
	ZodsRaidAssign.showAsignee(catcher, player, catcher.hover_ind )
	return f
end

function ZodsRaidAssign.showAsignee(catcher, player, where)
	local f = ZodsRaidAssign.getAnAsigneeFrame()
	f:SetParent(catcher)
	f:SetScript("OnMouseUp", function(self,btn)
		ZDragframe:StopMovingOrSizing()
		local inframe = ZodsRaidAssign.getMouseFrame(ZodsRaidAssign.column_frames)
		if inframe then	
			inframe:catchGuy(player)
		end
		ZDragframe:Hide()
		self:finishHide()
	end)
	f:SetScript("OnMouseDown", function(self,btn)
		self:GetParent():dropGuy(player)
		ZodsRaidAssign.pickUpPlayer(f, player)
	end)
	f:SetScript('OnEnter', function()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetUnit("raid" .. player.raidNum)
		GameTooltip:Show()
	end)
	f:SetScript('OnLeave', function()
	end)
	f:SetPoint("CENTER", catcher, "TOP", 0 , -20 );
	local color = RAID_CLASS_COLORS[player.class]
	f:SetBackdropColor(color.r, color.g, color.b,1)
	f.Text:SetText(string.sub(player.name,1,4))
	f.busy = true
	f.player = player
	table.insert(catcher.members, where or #catcher.members + 1, f)
	catcher:adjustMembers()
	f:Show()
end

function ZodsRaidAssign.dropAsignee(columnframe, player)
	--modify data
	for i,v in ipairs(columnframe.dataRef.members) do
		if ZRA_vars.roster[v].name == player.name then
			table.remove(columnframe.dataRef.members, i)
		end
	end
	--remove frames
	for i,v in ipairs(columnframe.members) do
		if v.player.name == player.name then
			v:startHide()
			table.remove(columnframe.members, i)
		end
	end
end

function ZodsRaidAssign.getAnAsigneeFrame()
	local i  = ZodsRaidAssign.findNotBusyFrame(ZodsRaidAssign.asignee_frames)
	if i then 
		return ZodsRaidAssign.asignee_frames[i]
	else
		local f = CreateFrame("Button", nil, ZRALayoutFrame)
		f = CreateFrame("Button", nil, ZRALayoutFrame);
		f:SetWidth(ZodsRaidAssign.PLAYER_SIZE)
		f:SetHeight(ZodsRaidAssign.PLAYER_SIZE)
		f:SetBackdrop(backdrop2)
		f:EnableMouse()
		f.texture = f:CreateTexture(nil, "BORDER")
		f.Text = f:CreateFontString(nil, "ARTWORK")
		f.Text:SetFont(STANDARD_TEXT_FONT, 12)
		f.Text:SetJustifyH("CENTER")
		f.Text:SetJustifyV("CENTER")
		f.Text:SetPoint("CENTER", f, "CENTER")
		f.Text:SetTextColor(0,0,0)
		f.id = #ZodsRaidAssign.asignee_frames + 1
		f.startHide = ZodsRaidAssign.asigneeStartHide
		f.finishHide = ZodsRaidAssign.asigneeFinishHide
		table.insert(ZodsRaidAssign.asignee_frames, f)
		return f
	end
end

function ZodsRaidAssign.asigneeStartHide(self)
	self:SetAlpha(0)
end

function ZodsRaidAssign.asigneeFinishHide(self)
	self:SetAlpha(1)
	self.busy = false
	self:Hide()
end

function ZodsRaidAssign.GetAColumnFrame()
	local i  = ZodsRaidAssign.findNotBusyFrame(ZodsRaidAssign.column_frames)
	if i then 
		return ZodsRaidAssign.column_frames[i]
	else
		local f = CreateFrame("Frame", nil, ZRALayoutFrame)
		f.text = f.text or f:CreateFontString(nil,"ARTWORK","GameFontNormal")
		f.text:SetJustifyH("CENTER")
		f.text:SetJustifyV("TOP")
		f.text:SetPoint("TOPLEFT", 0, 10)
		f.texture = f:CreateTexture(nil, "BORDER")
		f:EnableMouse()
		f.text:SetTextColor(1,1,0,1)
		f.id = #ZodsRaidAssign.column_frames + 1
		f.members = {}
		f.catchGuy = ZodsRaidAssign.catchAsignee
		f.showGuy = ZodsRaidAssign.showAsignee
		f.dropGuy = ZodsRaidAssign.dropAsignee
		f.adjustMembers = ZodsRaidAssign.columnAdjustMembers
		f.hoverAdjust = ZodsRaidAssign.columnAdjustHover
		table.insert(ZodsRaidAssign.column_frames, f)
		return f
	end
end

function ZodsRaidAssign.columnAdjustMembers(self)
	for i,v in ipairs(self.members) do
		v:SetPoint("CENTER", self, "TOP", 0 , -20 - ZodsRaidAssign.PLAYER_SIZE*(i -1));
	end
end

function ZodsRaidAssign.columnAdjustHover(self)
	--hover_ind is set
	for i,v in ipairs(self.members) do
		local adjustment = self.hover_ind <= i and 1 or 0
		v:SetPoint("CENTER", self, "TOP", 0 , -20 - ZodsRaidAssign.PLAYER_SIZE*(i -1 + adjustment))
	end
end

function ZodsRaidAssign.GetAGroupFrame()
	local i  = ZodsRaidAssign.findNotBusyFrame(ZodsRaidAssign.group_frames)
	if i then 
		return ZodsRaidAssign.group_frames[i]
	else
		local f = CreateFrame("Frame", nil, ZRALayoutFrame)
		f:SetFrameStrata("MEDIUM")
		f:SetFrameLevel(0)
		f:SetBackdrop(backdrop)
		f.texture = f:CreateTexture(nil, "BORDER")
		f.texture:SetTexture(.5,.5,.5, 1)
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
		table.insert(ZodsRaidAssign.group_frames, f)
		return f
	end
end

function ZodsRaidAssign.getMouseFrame(frames)
	local mousex, mousey = GetCursorPosition()
	mousex = mousex / UIParent:GetEffectiveScale()
	mousey = mousey / UIParent:GetEffectiveScale()
	for i, v in ipairs(ZodsRaidAssign.column_frames) do
		if v:IsVisible() then
			local x,y = v:GetCenter()
			if abs(x - mousex) < v:GetWidth()/2 and abs(y - mousey) < v:GetHeight()/2 then
				return v
			end
		end
	end
end

function ZodsRaidAssign.pickUpPlayer(copying_frame, player)
	ZDragframe:SetPoint("TOPLEFT", copying_frame, "TOPLEFT")
	ZDragframe:SetPoint("BOTTOMRIGHT", copying_frame, "TOPLEFT", ZodsRaidAssign.PLAYER_SIZE, -ZodsRaidAssign.PLAYER_SIZE)
	--ZDragframe:SetHeight(ZodsRaidAssign.PLAYER_SIZE)
	--ZDragframe:SetWidth(ZodsRaidAssign.PLAYER_SIZE)
	local color = RAID_CLASS_COLORS[player.class]
	ZDragframe:SetBackdropColor(color.r, color.g, color.b,1)
	ZDragframe.Text:SetText(string.sub(player.name,1,4))
	ZDragframe:Show()
	ZDragframe:StartMoving()
	ZDragframe.player = player
end


function ZodsRaidAssign.setAPlayerFrame(player)
	local f = ZodsRaidAssign.getAPlayerFrame() 

	f:SetScript("OnMouseUp", function(self,btn)
		ZDragframe:StopMovingOrSizing()
		local inframe = ZodsRaidAssign.getMouseFrame(ZodsRaidAssign.column_frames)
		if inframe then	
			inframe:catchGuy(player)
		end
		ZDragframe:Hide()
	end)
	f:SetScript("OnMouseDown", function(self,btn)
		ZodsRaidAssign.pickUpPlayer(f, player)
	end)
	f:SetScript('OnEnter', function()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetUnit("raid" .. player.raidNum)
		GameTooltip:Show()
	end)
	f:SetScript('OnLeave', function()  
	end)
	local nframes = ZodsRaidAssign.countBusyFrames(ZodsRaidAssign.player_frames)
	local cols_per_row =  math.floor((ZRALayoutFrame:GetWidth() - 8 )/ (f:GetWidth() + 2))
	local row = math.floor(nframes / cols_per_row)
	local col = modulo(nframes , cols_per_row)
	f:SetPoint("CENTER", ZRALayoutFrame, "BOTTOMLEFT", 30 + f:GetHeight()*col , 30 + f:GetWidth()*row);
	local color = RAID_CLASS_COLORS[player.class]
	f:SetBackdropColor(color.r, color.g, color.b,1)
	f.Text:SetText(string.sub(player.name,1,4))
	f.busy = true
	f:Show()
end


function ZodsRaidAssign.getAPlayerFrame()
	local i = ZodsRaidAssign.findNotBusyFrame(ZodsRaidAssign.player_frames)
	if i then
		return ZodsRaidAssign.player_frames[i]
	else
		f = CreateFrame("Button", nil, ZRALayoutFrame);
		f:SetWidth(ZodsRaidAssign.PLAYER_SIZE)
		f:SetHeight(ZodsRaidAssign.PLAYER_SIZE)
		f:SetBackdrop(backdrop2)
		f:EnableMouse()
		f.Text = f:CreateFontString(nil, "ARTWORK")
		f.Text:SetFont(STANDARD_TEXT_FONT, 12)
		f.Text:SetJustifyH("CENTER")
		f.Text:SetJustifyV("CENTER")
		f.Text:SetPoint("CENTER", f, "CENTER")
		f.Text:SetText("test")
		f.Text:SetTextColor(0,0,0)
		table.insert(ZodsRaidAssign.player_frames, f)
		return f
	end
end



function ZodsRaidAssign.findNotBusyFrame(frames)
	for i = 1, #frames do
		if frames[i].busy == false then
			return i
		end
	end
end

function ZodsRaidAssign.countBusyFrames(frames)
	local cnt = 0
	for i = 1, #frames do
		if frames[i].busy == true then
			cnt = cnt + 1
		end
	end
	return cnt
end







function ZodsRaidAssign.PositionRoleMembers(self)
	for i, v in ipairs(self.role.groups[self.rolegroup]) do
		v:SetPoint("TOPLEFT", v.role, "TOPLEFT", 20+40*(v.rolegroup-1), -40 - (i-2)*32)
	end
	local size = #self.role.groups[self.rolegroup]
	self.role.groups[self.rolegroup][1]:SetPoint("TOPLEFT", self.role, "TOPLEFT", 20+40*(self.rolegroup-1), -40 - (size-1)*32)
end



function ZodsRaidAssign.Z_OptionsFrame(options, returnfunction)
	local width = 300
	local height = 300
	
	local currentY = 20
	local currentX = 20
	local busy_selectframes = 0
	
	local busy_stringframes = 0
	local busy_labelframes = 0
	
	ZOptionsFrame.groups = {}
	ZOptionsFrame.optionsSelected = {}
	ZOptionsFrame:Raise()
	for i, v in ipairs(options) do
		local group = {}
		if v.input == "SELECT" then
			for i2, v2 in ipairs(v) do
				local btn
				if #ZOptionsFrame.selectframes - busy_selectframes == 0 then
					btn = CreateFrame("Button",nil,ZOptionsFrame, "UIPanelButtonTemplate")
					DEFAULT_CHAT_FRAME:AddMessage("made frame for "..v2)
					table.insert(ZOptionsFrame.selectframes, btn)
					
					local highlight = btn:CreateTexture(nil, "BORDER")
					btn.highlight = highlight
					highlight:SetTexture("Interface\\ChatFrame\\ChatFrameBorder")
					highlight:SetPoint("TOPLEFT", btn, "TOPLEFT", -4, 1)
					highlight:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 4, -7)
					highlight:Hide()
				else
					btn = ZOptionsFrame.selectframes[1 + busy_selectframes]
				end
				local text = btn:GetFontString()
				text:SetPoint("LEFT",btn,"LEFT",7,0)
				text:SetPoint("RIGHT",btn,"RIGHT",-7,0)
				text:SetText(v2)
				btn:SetHeight(24)
				btn:SetWidth(text:GetWidth()+20)
				btn:SetPoint("TOPLEFT", ZOptionsFrame ,"TOPLEFT", currentX, 0-currentY)
				btn:SetScript("OnClick", function()
					for j,k in ipairs(ZOptionsFrame.groups[btn.group]) do
						k.selected = false
						k.highlight:Hide()
					end
					btn.highlight:Show() 
					btn.selected = true
					ZOptionsFrame.optionsSelected[i] = options[i][i2]
				end)
				
				btn.group = i
				btn.selected = false
				btn.highlight:Hide()
				busy_selectframes = busy_selectframes + 1
				currentX = currentX + text:GetWidth() + 30
				table.insert(group, btn)
			end
		elseif v.input == "STRING" then
			--v.phrase
				-- edit box
				local edb
				if #ZOptionsFrame.stringframes - busy_stringframes == 0 then
					edb = CreateFrame("EditBox",nil,ZOptionsFrame, "InputBoxTemplate")
					table.insert(ZOptionsFrame.stringframes, edb)
					edb:SetAutoFocus(false)
					edb:SetScript("OnEscapePressed", function(self) 
						self:ClearFocus()
						edb:SetText(ZOptionsFrame.optionsSelected[i])
					end)
					
					edb:SetScript("OnEnterPressed", function(self) 
						ZOptionsFrame.optionsSelected[i] = edb:GetText()
						self:ClearFocus() 
					end)
					
				else
					edb = ZOptionsFrame.stringframes[1 + busy_stringframes]
				end
				edb:SetPoint("TOPLEFT", ZOptionsFrame ,"TOPLEFT", currentX + 50 , 0-currentY)
				edb:SetWidth(100)
				edb:SetHeight(25)
				edb:Show()
				edb:SetText("DEFAULT")
				edb.group = i
				ZOptionsFrame.optionsSelected[i] = edb:GetText()
				--label
				local lbl
				if #ZOptionsFrame.labelframes - busy_labelframes == 0 then
					lbl = ZOptionsFrame:CreateFontString(nil, "ARTWORK")
					table.insert(ZOptionsFrame.labelframes, lbl)
				else
					lbl = ZOptionsFrame.labelframes[1 + busy_labelframes]
				end
				lbl:SetFont(STANDARD_TEXT_FONT, 12)
				lbl:SetTextColor(0,0,0)
				lbl:SetJustifyH("CENTER")
				lbl:SetJustifyV("CENTER")
				lbl:SetPoint("TOPLEFT", ZOptionsFrame ,"TOPLEFT", currentX, 0-currentY - 5)
				lbl:SetText(v.phrase)
				lbl:Show()
		end
		currentY = currentY + 40
		currentX = 20
		table.insert(ZOptionsFrame.groups, group)
	end
	
	ZOptionsFrame:SetWidth(width)
	ZOptionsFrame:SetHeight(height)
	ZOptionsFrame.OK:SetScript("OnClick",function() returnfunction(options) ZOptionsFrame:Hide() end)
	
	ZOptionsFrame:Show()

end



--ZOptionsFrame.selectframes[1]:GetScript("OnLeave")

--local function editbox()
--local editbox = CreateFrame("EditBox",nil,btn)
--	editbox:SetFontObject(ChatFontNormal)
--	editbox:SetScript("OnEscapePressed",function(this) this:ClearFocus() end)
--	editbox:SetScript("OnEnterPressed",function(this) this:ClearFocus() end)
--
--	editbox:SetTextInsets(5,5,3,3)
--	editbox:SetMaxLetters(256)
--	editbox:SetAutoFocus(false)
--	editbox:SetBackdropColor(0,0,0)
--	editbox:SetPoint("TOPLEFT",btn,"TOPLEFT",0,0)
--	editbox:SetPoint("BOTTOMRIGHT",btn,"BOTTOMRIGHT",0,0)
--	editbox:SetText("rere")
--end




ZodsRaidAssign.scriptframe = CreateFrame("Frame")
ZodsRaidAssign.scriptframe:RegisterEvent("ADDON_LOADED")
ZodsRaidAssign.scriptframe:RegisterEvent("CHAT_MSG_ADDON")
ZodsRaidAssign.scriptframe:SetScript("OnEvent", ZodsRaidAssign.onEvent)
ZodsRaidAssign.scriptframe:SetScript("OnUpdate", ZodsRaidAssign.onUpdate)


function debugthis(arg1)
	func = ZDragframe:GetCenter()
	params = nil
	if arg1 then
		params = arg1
	end
	values = {func(params)}
	for i, v in ipairs(values) do
		DEFAULT_CHAT_FRAME:AddMessage("arg"..i.."="..(v or "F"))
	end
end

local function justholdingthis()
	btn = CreateFrame("Button", "myButton", ZRALayoutFrame, "SecureActionButtonTemplate");
	btn:SetAttribute("type1", "macro");
	btn:SetAttribute("unit", "player")
	btn:SetAttribute("macrotext", "/targetexact " .. "Vindicator Aeus")


	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up")
	btn:SetPoint("CENTER", ZRALayoutFrame, "TOPLEFT", 140, 26);
	btn:SetWidth(30);
	btn:SetHeight(30);
	btn:SetMovable(true)
	btn:EnableMouse(true)
	btn:RegisterForDrag("LeftButton")
	btn:SetScript("OnDragStart", btn.StartMoving)
	btn:SetScript("OnDragStop", btn.StopMovingOrSizing)
	
	btn:Show();

	btn.BarBG = btn:CreateTexture()
	local color = RAID_CLASS_COLORS["WARRIOR"]
	btn.BarBG:SetTexture(color.r, color.g, color.b,0)
	btn.BarBG:SetAllPoints(btn)
	
	btn:SetBackdrop(backdrop)
	btn:SetBackdropColor(color.r, color.g, color.b,1)
	
	
	
	btn.Text = btn:CreateFontString(nil, "ARTWORK")
	btn.Text:SetFont(STANDARD_TEXT_FONT, 12)
	btn.Text:SetJustifyH("CENTER")
	btn.Text:SetJustifyV("CENTER")
	btn.Text:SetPoint("CENTER", btn, "CENTER")
	btn.Text:SetText("rere")
	
	btn.Text:SetTextColor(0,0,0)

end




function ZodsRaidAssignPublic.OpenMenu()
	--ZodsRaidAssign.AllPlayerFrames()
	if not ZodsRaidAssign.current_tab then 
		ZodsRaidAssign.tabClicked("Roles")()
	end
	ZRALayoutFrame:Show()
end

function ZodsRaidAssign.closeOnClick(self)
	self.obj:Hide()
end





scope()
setModule('wow_helpers')

local macroButtons = {}
SelectMacroButton = util.CreateClass({})
local SelectMacroButton = SelectMacroButton


-- heres the hack. cmon bliz..

-- padding the lines seems to help with flakyness I've seen
-- ill take this bandaid fix. they'll fix this bug soon anyway right?..
local padCount = 3
local delimiter = '\n/r\n/r\n/r\n'


local function setMacroEnable(enabled)
    if enabled == false then
        MacroEditBox:UnregisterEvent("EXECUTE_CHAT_LINE")
    else
        MacroEditBox:RegisterEvent("EXECUTE_CHAT_LINE")
    end
end

local function stackHeight()
    return #(SelectMacroButton.stack)
end

local function getFrame(index)
    if index < 1 or index > #(SelectMacroButton.stack) then
        return nil
    end
    return SelectMacroButton.stack[index]
end

local function getTopFrame()
    local h = stackHeight()
    return getFrame(h)
end

local function frameShouldEnable(index)
    index = index or stackHeight()
    local frame = getFrame(index)
    if not frame then return true end
    local i = frame.macroIndex
    local cnt = frame.macroLineCount
    if i > cnt - 2 then
        -- frame ending. prepare for deeper frame
        return frameShouldEnable(index - 1)
    end
    if i == 1 then return true end

    local nextLine = math.floor((i - 1) / (padCount + 1)) + 1
    if (not frame.selections) or frame.selections[nextLine] then
        return true
    else
        return false
    end
end

local function onChatLine(_, _, line)
    local frame = getTopFrame()
    if not frame then
        setMacroEnable(true)
        return
    end
    if line == '/r' then
        setMacroEnable(frameShouldEnable())
    end
    frame.macroIndex = frame.macroIndex + 1
    if frame.macroIndex == frame.macroLineCount + 1 then
        table.remove(SelectMacroButton.stack)
        if stackHeight() == 0 then
            SelectMacroButton.args = {}
        end
    end
end

-- rest doesnt matter if they fix this above

local selectMacroButtons = {}

local registerFrame = nil
local function register()
    if not registerFrame then
        registerFrame = CreateFrame("Frame")
        registerFrame:RegisterEvent("EXECUTE_CHAT_LINE")
        registerFrame:SetScript("OnEvent", onChatLine)
    end
end

function SelectMacroButton.create(name)
    local sbtn = selectMacroButtons[name] or SelectMacroButton:new()
    sbtn.mbtn = wow_helpers.MacroButton.get(name)
    sbtn.name = name
    sbtn.key = name
    selectMacroButtons[name] = sbtn
    register()
    return sbtn
end

function SelectMacroButton.find(name)
    return selectMacroButtons[name]
end

SelectMacroButton.stack = {}
SelectMacroButton.args  = {}

local function getMacroText(lines)
    local macrotext = ''
    for _, line in ipairs(lines) do
        macrotext = macrotext .. delimiter .. line
    end
    return macrotext
end

function SelectMacroButton:getFirstLine()
    return "/run startSelectMacro('" .. self.key .. "')\n"
end

function SelectMacroButton:SetLines(lineArray)
    self.lines = lineArray
    self.mbtn:SetMacro(self:getFirstLine() .. getMacroText(lineArray) .. delimiter)
end

function SelectMacroButton:SetSelections(arrayOrFunc)
    if type(arrayOrFunc) == 'table' then
        self.selector = nil
        self.selections = arrayOrFunc
    elseif type(arrayOrFunc) == 'function' then
        self.selector = arrayOrFunc
        self.selections = nil
    else
        debug.dump('passed nil for SetSelections defaulting to {}')
        self.selector = nil
        self.selections = {}
    end
end

function SelectMacroButton:GetSelections()
    if self.selections then return self.selections end

    if self.selector then
        local args = SelectMacroButton.args
        return self.selector(args) or {}
    end

    return self.lines
end

function SelectMacroButton:SelectionSet()
    local selectionSet = {}
    for _, lineNo in ipairs(self:GetSelections()) do
        selectionSet[lineNo] = true
    end
    return selectionSet
end

function SelectMacroButton:SetArgs(tableOrFunc)
    if type(tableOrFunc) == 'table' then
        self.argGetter = nil
        self.args = tableOrFunc
    elseif type(tableOrFunc) == 'function' then
        self.argGetter = tableOrFunc
        self.args = nil
    else
        debug.dump('passed nil for SetArgs defaulting to {}')
        self.argGetter = nil
        self.args = {}
    end
end

function SelectMacroButton:GetArgs()
    return self.argGetter and self.argGetter(SelectMacroButton.args) or self.args
end

function SelectMacroButton:LoadArgs()
    local args = self:GetArgs()
    if args then
        -- only merging them in. it clears after last frame anyway
        -- I dont think we need scoped variables for this..
        for k,v in pairs(args) do
            SelectMacroButton.args[k] = v
        end
    end
end

function SelectMacroButton:MacroLineCount()
    -- actual lines, including pad and starter
    return (#(self.lines)* (padCount + 1)) + 1 + padCount
end

function SelectMacroButton:CreateFrame()
    local nextFrame = {}
    nextFrame.selections = self:SelectionSet()
    nextFrame.key = self.key -- not used, just here for debug
    nextFrame.macroIndex = 1
    nextFrame.macroLineCount = self:MacroLineCount()
    return nextFrame
end

function SelectMacroButton:Start()
    self:LoadArgs()
    local frame = self:CreateFrame()
    table.insert(SelectMacroButton.stack, frame)
end

local function startSelectMacro(key)
    local sbtn = SelectMacroButton.find(key)
    if sbtn then
        sbtn:Start()
    else
        debug.dump('no macro config for ' .. key)
    end
end
dev.leakglobal('startSelectMacro', startSelectMacro)

local created = false
debug.Quest('selectable macro', function()
    if not created then
        local sbtn = wow_helpers.SelectMacroButton.create('TEST_SELECT_MACRO_BTN_1')
        local lines = {
            '/run quest_result_object.select_macro_test = 1',
            '/run quest_result_object.select_macro_test = quest_result_object.select_macro_test + 2',
            '/run quest_result_object.select_macro_test = quest_result_object.select_macro_test + 4',
            '/run quest_result_object.select_macro_test = quest_result_object.select_macro_test + 8',
        }
        sbtn:SetLines(lines)
        sbtn:SetSelections({3,1})

        local sbtn2 = wow_helpers.SelectMacroButton.create('TEST_SELECT_MACRO_BTN_2')
        sbtn2:SetLines(lines)
        sbtn2:SetSelections(function(args) return args.select end)
        sbtn2:SetArgs({ select = { 4 } })

        local sbtn3 = wow_helpers.SelectMacroButton.create('TEST_SELECT_MACRO_BTN_3')
        sbtn3:SetLines(lines)
        sbtn3:SetSelections(function(args) return args.select end)
        sbtn3:SetArgs(function(args) return { select = { 2, 4 } } end)

        created = true
        return 'fail, awaiting macro click these select macros.. you know their names'
    end

    local result = _G['quest_result_object'].select_macro_test
    if result ~= 23 then
        return 'fail, calculated wrong value for button 1. did they fix it?? expected 23, got ' .. result
    end

    return 'pass'
end)




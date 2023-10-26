scope()
setModule('wow_helpers')

local debug = debug

local function CreateMacroButton(buttonName)
    debug.dump('creating macro button ' .. buttonName)
    local button = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate");
    button:SetAttribute("type", 'macro')
    return button
end

local macroButtons = {}
MacroButton = util.CreateClass({})
local MacroButton = MacroButton

function MacroButton.get(name)
    local btn = MacroButton:new()
    btn.btn = macroButtons[name] or CreateMacroButton(name)
    btn.name = name
    return btn
end

function MacroButton:SetMacro(txt)
    self.btn:SetAttribute("macrotext", txt)
end


local created = false
debug.Quest('macro', function()
    if not created then
        local btn = wow_helpers.MacroButton.get('TEST_MACRO_BTN')
        btn:SetMacro('/run quest_result_object.macro_test = 1')
        created = true
    end
    if _G['quest_result_object'].macro_test == 1 then return 'pass' end
    if created then
        return 'fail, awaiting macro press try /click TEST_MACRO_BTN'
    end
end)

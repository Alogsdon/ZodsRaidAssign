scope()
setModule('wow_helpers')

Encounter = {}
local Encounter = Encounter

Encounter.subscribers = {}

local NO_ENCOUNTER = 'NO_ENCOUNTER'
local current = NO_ENCOUNTER

function Encounter.update(eventName)
  current = eventName
  for sub in pairs(Encounter.subscribers) do
    sub.callback(current)
  end
end

function Encounter.onEvent(stamp, event, _encountedId, encounterName, difficultyID, groupSize, success)
  if event == 'ENCOUNTER_START' then
    Encounter.update(encounterName)
    return
  end
  if event == 'ENCOUNTER_END' then
      Encounter.update(NO_ENCOUNTER)
    return
  end
end

function Encounter.Subscribe(callback)
  local sub = {
      callback = callback,
  }
  Encounter._register()
  Encounter.subscribers[sub] = true
  local unsub = function()
    Encounter.subscribers[sub] = nil
  end
  callback(current)
  return unsub
end

function Encounter._register()
  if Encounter.scriptFrame then return end
  local f = CreateFrame("Frame")
  f:RegisterEvent("ENCOUNTER_END")
  f:RegisterEvent("ENCOUNTER_START")
  f:SetScript("OnEvent", Encounter.onEvent)
  Encounter.scriptFrame = f
end

-- ENCOUNTER_END encounterID, encounterName, difficultyID, groupSize, success
-- ENCOUNTER_START encounterID, encounterName, difficultyID, groupSize

function spec.Tests:CombatEventTest()
  local currentEnounter
  Encounter.onEvent(123, 'ENCOUNTER_START', 123, 'Deathbringer Saurfang', 1, 5)
  wow_helpers.Encounter.Subscribe(function(nextEncounter) currentEnounter = nextEncounter end)
  spec.AreEqual(currentEnounter, 'Deathbringer Saurfang')
  Encounter.onEvent(123, 'ENCOUNTER_END', 123, 'Deathbringer Saurfang', 1, 5, 1)
  spec.AreEqual(currentEnounter, 'NO_ENCOUNTER')
end


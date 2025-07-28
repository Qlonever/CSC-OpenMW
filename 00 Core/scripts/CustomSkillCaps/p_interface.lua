-- Interface for getting skill caps from this mod
local core = require('openmw.core')
local self = require('openmw.self')
local storage = require('openmw.storage')
local types = require('openmw.types')

local info = require('scripts.CustomSkillCaps.info')

local function contains(t, element)
  for _, value in pairs(t) do
    if value == element then
      return true
    end
  end
  return false
end

local function C(text)
    return text:gsub('^%l', string.upper)
end

-- Mod settings

local modSettings = {
    basic = storage.playerSection('SettingsPlayer' .. info.name .. 'Basic')
}

-- Player data

local Player = types.Player

local playerStats = Player.stats
local levelStat = playerStats.level(self)
local skillStats = playerStats.skills

local function getPlayerRecords()
    local playerRecord = Player.record(self)
    return {
        class = Player.classes.record(playerRecord.class)
    }
end

-- Get maximum value for skill depending on settings and class
local function getSkillCap(skillId)
    local capMethod = modSettings.basic:get('SkillCapMethod')
    if capMethod == 'SharedCap' then
        return modSettings.basic:get('SharedSkillCap')
    elseif capMethod == 'ClassCap' then
        local playerRecords = getPlayerRecords()
        if contains(playerRecords.class.majorSkills, skillId) then
            return modSettings.basic:get('MajorSkillCap')
        elseif contains(playerRecords.class.minorSkills, skillId) then
            return modSettings.basic:get('MinorSkillCap')
        else
            return modSettings.basic:get('MiscSkillCap')
        end
    elseif capMethod == 'UniqueCap' then
        return modSettings.basic:get(C(skillId) .. 'Cap')
    end
end

return {
    version = info.interfaceVersion,
    getSkillCap = getSkillCap
}
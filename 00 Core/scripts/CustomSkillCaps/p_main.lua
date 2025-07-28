-- The main logic and functions of this mod
local core = require('openmw.core')

local info = require('scripts.CustomSkillCaps.info')

local IName = info.interfaceName
local L = core.l10n(info.name)

if core.API_REVISION < info.minApiVersion then
    print(L('UpdateOpenMW'))
    return
end

local ambient = require('openmw.ambient')
local async = require('openmw.async')
local I = require('openmw.interfaces')
local input = require('openmw.input')
local self = require('openmw.self')
local types = require('openmw.types')
local ui = require('openmw.ui')

local settings = require('scripts.' .. info.name .. '.p_settings')
local interface = require('scripts.' .. info.name .. '.p_interface')
local CSCUI = require('scripts.' .. info.name .. '.p_ui')

-- Player data

local Player = types.Player

local playerStats = Player.stats
local levelStat = playerStats.level(self)
local skillStats = playerStats.skills

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Handlers

-- Near-duplicate of built in handler, meant to replace it
local function skillLevelUpHandler(skillId, source, params)
    local skillStat = skillStats[skillId](self)
    -- Check against modded skill cap instead of 100
    local skillCap = I[IName].getSkillCap(skillId)
    if skillCap ~= 0 and skillStat.base >= skillCap then 
        return false 
    end

    if params.skillIncreaseValue then
        skillStat.base = skillStat.base + params.skillIncreaseValue
    end

    if params.levelUpProgress then
        levelStat.progress = levelStat.progress + params.levelUpProgress
    end

    if params.levelUpAttribute and params.levelUpAttributeIncreaseValue then
        levelStat.skillIncreasesForAttribute[params.levelUpAttribute]
            = levelStat.skillIncreasesForAttribute[params.levelUpAttribute] + params.levelUpAttributeIncreaseValue
    end

    if params.levelUpSpecialization and params.levelUpSpecializationIncreaseValue then
        levelStat.skillIncreasesForSpecialization[params.levelUpSpecialization]
            = levelStat.skillIncreasesForSpecialization[params.levelUpSpecialization] + params.levelUpSpecializationIncreaseValue;
    end

    local skillRecord = core.stats.Skill.record(skillId)

    -- Why are these even here?
    --local npcRecord = NPC.record(self)
    --local class = NPC.classes.record(npcRecord.class)

    ambient.playSound("skillraise")

    local message = string.format(core.getGMST('sNotifyMessage39'),skillRecord.name,skillStat.base)

    if source == I.SkillProgression.SKILL_INCREASE_SOURCES.Book then
        message = '#{sBookSkillMessage}\n'..message
    end

    ui.showMessage(message, { showInDialogue = false })

    if levelStat.progress >= core.getGMST('iLevelUpTotal') then
        ui.showMessage('#{sLevelUpMsg}', { showInDialogue = false })
    end

    if not source or source == I.SkillProgression.SKILL_INCREASE_SOURCES.Usage then skillStat.progress = 0 end

    CSCUI.updateProgressMenu(skillId)

    return false
end

-- Near-duplicate of built in handler, meant to replace it
local function skillUsedHandler(skillId, params)
    if types.NPC.isWerewolf(self) then
        return false
    end

    local skillStat = skillStats[skillId](self)
    skillStat.progress = skillStat.progress + params.skillGain / I.SkillProgression.getSkillProgressRequirement(skillId)

    local skillCap = I[IName].getSkillCap(skillId)
    -- The built-in handler doesn't check if the skill has reached its cap, but this one does
    if skillStat.progress >= 1 and (skillCap == 0 or skillStat.base < skillCap) then
        I.SkillProgression.skillLevelUp(skillId, I.SkillProgression.SKILL_INCREASE_SOURCES.Usage)
    end

    CSCUI.updateProgressMenu(skillId)

    return false
end

-- Open/close this mod's UI
local function progressMenuKey()
    if CSCUI.hideProgressMenu() and (I.UI.modes[1] == 'Interface' or I.UI.modes[1] == nil) then
        CSCUI.createProgressMenu()
    end
end

-- Close this mod's UI if other UI modes are active
local function UiModeChanged(data)
    if data.newMode ~= nil and data.newMode ~= 'Interface' and data.newMode ~= 'Loading' then
        CSCUI.hideProgressMenu()
    end
end

input.registerTriggerHandler('Progress' .. info.name, async:callback(progressMenuKey))

-- Save/load handlers

local function onLoad(data)
    -- Include version in save data to track breaking changes
    if info.saveVersion > data.saveVersion then
        ui.showMessage(L('SaveVersionNew'), {showInDialogue = false})
        print(L('SaveVersionNew'))
    elseif info.saveVersion < data.saveVersion then
        ui.showMessage(L('SaveVersionOld'), {showInDialogue = false})
        print(L('SaveVersionOld'))
    end
end

local function onSave()
    return {
        saveVersion = info.saveVersion,
        settingsVersion = info.settingsVersion
    }
end

I.SkillProgression.addSkillUsedHandler(skillUsedHandler)
I.SkillProgression.addSkillLevelUpHandler(skillLevelUpHandler)

return {
    eventHandlers = {
        UiModeChanged = UiModeChanged
    },
    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave
    },
    interfaceName = IName,
    interface = interface
}
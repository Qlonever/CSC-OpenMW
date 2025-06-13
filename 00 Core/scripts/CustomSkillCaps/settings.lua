-- Settings
local async = require('openmw.async')
local core = require('openmw.core')
local I = require('openmw.interfaces')
local input = require('openmw.input')
local storage = require('openmw.storage')

local info = require('scripts.CustomSkillCaps.info')

local function sortAlphabetical(a, b)
    return a:lower() < b:lower()
end

local function capital(text)
    return text:gsub('^%l', string.upper)
end

input.registerTrigger {
    key = 'Progress' .. info.name,
    l10n = info.name
}

local modSettings = {
    basic = storage.playerSection('SettingsPlayer' .. info.name .. 'Basic')
}

I.Settings.registerPage {
    key = 'Page' .. info.name,
    l10n = info.name,
    name = 'PageName'
}

-- Something stupid to get around I.Settings.updateRendererArgument() replacing the entire table
local dependentArguments = {
    SkillCap = {
        integer = true,
        min = 0,
        disabled = modSettings.basic:get('UniqueSkillCap')
    }
}

-- Dependent settings must belong to the same section as the settings they depend on
local dependentSettings = {
    SkillCap = {UniqueSkillCap = false}
}

-- Basic settings

local settings = {
    {
        key = 'ProgressKey',
        renderer = 'inputBinding',
        name = 'ProgressKeyName',
        description = 'ProgressKeyDesc',
        default = '',
        argument = {type = 'trigger', key = 'Progress' .. info.name}
    },
    {
        key = 'SkillCap',
        renderer = 'number',
        name = 'SkillCapName',
        description = 'SkillCapDesc',
        default = 0,
        argument = dependentArguments.SkillCap
    },
    {
        key = 'UniqueSkillCap',
        renderer = 'checkbox',
        name = 'UniqueSkillCapName',
        description = 'UniqueSkillCapDesc',
        default = false
    }
}

local skillList = {}

for i, skillRecord in ipairs(core.stats.Skill.records) do
    table.insert(skillList, skillRecord.id)
end

table.sort(skillList, sortAlphabetical)

for i, skillId in ipairs(skillList) do
    dependentArguments[capital(skillId) .. 'Cap'] = {integer = true, min = 0, disabled = not modSettings.basic:get('UniqueSkillCap')}
    dependentSettings[capital(skillId) .. 'Cap'] = {UniqueSkillCap = true}
    table.insert(settings, {
        key = capital(skillId) .. 'Cap',
        renderer = 'number',
        name = core.stats.Skill.record(skillId).name,
        default = 0,
        argument = dependentArguments[capital(skillId) .. 'Cap']
    })
end

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name .. 'Basic',
    page = 'Page' .. info.name,
    order = 1,
    l10n = info.name,
    name = 'SettingsBasicName',
    permanentStorage = true,
    settings = settings
}

-- Dependent Settings

-- Need to search dependency data from both directions
-- Automatically construct a reversed table
local dependedSettings = {}
for dependentKey, dependedKeys in pairs(dependentSettings) do
    for dependedKey, _ in pairs(dependedKeys) do
        if dependedSettings[dependedKey] ~= nil then
            table.insert(dependedSettings[dependedKey], dependentKey)
        else
            dependedSettings[dependedKey] = {dependentKey}
        end
    end
end

local dependentCallback = async:callback(function(sectionKey, changedKey)
    if changedKey ~= nil and dependedSettings[changedKey] ~= nil then
        for _, dependentKey in pairs(dependedSettings[changedKey]) do
            local disabled = false
            for dependedKey, value in pairs(dependentSettings[dependentKey]) do
                if modSettings[sectionKey:gsub('SettingsPlayer' .. info.name, ''):lower()]:get(dependedKey) ~= value then
                    disabled = true
                end
            end
            local argument = dependentArguments[dependentKey]
            argument.disabled = disabled
            I.Settings.updateRendererArgument(sectionKey, dependentKey, argument)
        end
    end
end)

modSettings.basic:subscribe(dependentCallback)
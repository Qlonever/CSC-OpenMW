# Custom Skill Caps
### Ver. 1.0.0
Custom Skill Caps is an OpenMW Lua mod allowing users to set custom maximum values for skills. It doesn't change any other mechanics or add any other features.

## Settings
<Details>
<Summary>Basic Settings</Summary>

### Skill Progress Menu Key
Shows a menu containing the current progress of all skills. Needed to view progress for skills above the vanilla cap of 100.
### Skill Capping Method
Skills have a configurable maximum value that they cannot be raised above. If set to 0, the corresponding skill can be raised infinitely.

This setting decides whether skills will share one maximum value, use differing maximums if they belong to your character's class, or use completely unique maximums. (Default: Shared)
### Shared/Major/Minor/Misc./Unique Skill Caps
(Default: All 0)
</Details>

## Installation
Add the `00 Core` directory of this mod to OpenMW as a data path, then make sure `CustomSkillCaps.omwscripts` is enabled as a content file. It should be placed before other Lua mods in your load order.

Example:
```
data="C:/games/OpenMWMods/Leveling/Custom Skill Caps/00 Core"
content=CustomSkillCaps.omwscripts
```
### Requirements
This mod requires OpenMW version 0.49 or later. If your version is too old, a warning will appear in the log. (Press F10 or check openmw.log)
### Compatibility
This should be compatible with anything that doesn't completely override the built-in skill leveling mechanics. However, it must be placed before other Lua mods in your load order.
### Known Issues
Currently, the vanilla stats menu won't show progress for skills above the vanilla cap of 100. This mod includes a keybind for displaying those progress values.

MWscripts or console commands using modskill functions can't increase skills past 100, even with this mod installed.

If you encounter any bugs, please create an issue or inform me some other way.
## Credits
Author: Qlonever

## Other Sources
This mod can be found on Nexus Mods: https://www.nexusmods.com/morrowind/mods/56938

Numbered releases will be uploaded there.

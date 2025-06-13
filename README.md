# Custom Skill Caps
### Ver. 1.0.0
Custom Skill Caps is an OpenMW Lua mod allowing users to set custom maximum values for skills. It doesn't change any other mechanics or add any other features.

## Settings
<Details>
<Summary>Basic Settings</Summary>

### Skill Progress Menu Key
Shows a menu containing the current progress of all skills. Needed to view progress for skills above the vanilla cap of 100.
### Skill Cap
You cannot raise skills above this value. If set to 0, skills can be raised infinitely. (Default: 0)
### Cap Skills Individually
If enabled, each skill will have an individually-adjustable maximum value. If set to 0, the corresponding skill can be raised infinitely. (Default: OFF)
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
This should be compatible with anything that doesn't completely override the built-in skill leveling mechanics.
### Known Issues
Currently, the vanilla stats menu won't show progress for skills above the vanilla cap of 100. This mod includes a keybind for displaying those progress values.

## Credits
Author: Qlonever

## Source
This mod can be found on Github: https://github.com/Qlonever/CSC-OpenMW

Updates there will be smaller and more frequent.

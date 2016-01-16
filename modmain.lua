-- Prefabs for the mod.
PrefabFiles = {
    "blowgun",
	"darts"
}

ComponentFiles = {
	"ammunition",
	"reloadable"
}

-- Tuning for the mod.
TUNING.BLOWGUN_REVAMPED =
{
	-- Tuning for Blowgun
	BLOWGUN_RANGE = 8,

	-- Tuning for Fire Dart.
	FIRE_DART_SPEED = 60,
	FIRE_DART_HOMING = false,		
	FIRE_DART_DAMAGE = 100,
	FIRE_DART_RECOVER_CHANCE = 1,
	
	DARTS = {
		"fire_dart",
	}
}

-- The Strings table.
local STRINGS = GLOBAL.STRINGS

-- The names of the prefabs.
STRINGS.NAMES.BLOWGUN = "Blowgun"
STRINGS.NAMES.FIRE_DART = "Fire Dart"

-- Generic examination quotes for the prefabs.
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLOWGUN = "Pointy shooty."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FIRE_DART = "It burns things."

-- Create new Ammunition Type table to handle ammunition.
GLOBAL.AMMUNITIONTYPE =
{
	DART = "DART"
}

-- The Action Handler and Actions tables.
local ActionHandler = GLOBAL.ActionHandler
local ACTIONS = GLOBAL.ACTIONS

-- Create load action to allow ammunition to be loaded into reloadables.
local function OnLoad(action)
	local item = action.invobject
	local target = action.target
	if item and target then
		print("Success?")
		target.components.reloadable:TakeAmmoItem(item)
	end
	return true
end

AddAction("BLOWGUN_REVAMPED_LOAD", "Load", OnLoad)

-- Create action handler and tie into state graph.
local load_action = ActionHandler(ACTIONS.BLOWGUN_REVAMPED_LOAD, "dolongaction")
AddStategraphActionHandler("wilson", load_action)

-- Create component action handler to tie action to component.
local function LoadActionFn(inst, origin, target, actions, right)
	if target:HasTag("reloadable") then
		table.insert(actions, ACTIONS.BLOWGUN_REVAMPED_LOAD)
	end
end
AddComponentAction("USEITEM", "ammunition", LoadActionFn)

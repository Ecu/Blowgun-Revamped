-- Adds tag representing ammunition type loadable.
local function OnAmmoType(self, ammotype, old_ammotype)
    if old_ammotype ~= nil then
        self.inst:RemoveTag(old_ammotype.."_loadable")
    end
    if ammotype ~= nil then
        self.inst:AddTag(ammotype.."_loadable")
    end
end

-- Adds tag representing ammunition type loadable.
local function OnAccepting(self, accepting)
    if accepting then
        self.inst:AddTag(self.ammotype.."_loadable")
	else
		self.inst:RemoveTag(self.ammotype.."_loadable")
    end
end

-- Adds tag if empty.
local function OnCurrentAmmo(self, currentammo)
	if currentammo <= 0 then
		self.inst:AddTag("ammodepleted")
	else
		self.inst:RemoveTag("ammodepleted")
	end
end

-- Reloadable Definition / Initialization
local Reloadable = Class(function(self, inst)
    self.inst = inst
    self.consuming = false

    self.maxammo = 0
    self.currentammo = 0

    self.ammotype = AMMUNITIONTYPE.DART
	self.accepting = true
	self.onacceptfn = nil
	self.onreloadedfn = nil
	self.ondepletedfn = nil
end,
nil,
{
	ammotype = OnAmmoType,
	accepting = OnAccepting,
	currentammo = OnCurrentAmmo
})

-- Clean up added tags on removal from an entity.
function Reloadable:OnRemoveFromEntity()
	if self.ammotype ~= nil then
		self.inst:RemoveTag(self.ammotype.."_loadable")
	end
	self.inst:RemoveTag("ammodepleted")
end

-- Empties out ammunition.
function Reloadable:MakeEmpty()
	if self.currentammo > 0 then
		self:DoDelta(-self.currentammo)
	end
end

-- Saves current ammunition amount.
function Reloadable:OnSave()
    if self.currentammo ~= self.maxammo then
        return {ammo = self.currentammo}
    end
end

-- Loads current ammunition amount.
function Reloadable:OnLoad(data)
    if data.ammo then
        self:InitializeAmmo(math.max(0, data.ammo))
    end
end

-- Sets function callback for when ammunition is reloaded.
function Reloadable:SetReloadedFn(fn)
    self.onreloadedfn = fn
end

-- Sets function callback for when ammunition is depleted.
function Reloadable:SetDepletedFn(fn)
    self.ondepletedfn = fn
end

-- Sets function callback for checking if item should be accepted.
function Reloadable:SetAcceptFn(fn)
    self.onacceptfn = fn
end

-- Checks and returns if ammunition is depleted.
function Reloadable:IsDepleted()
    return self.currentammo <= 0
end

-- Checks if the reloadable can accept the item.
function Reloadable:CanAcceptItem(item)
	return 	self.accepting and item and item.components.ammunition and
			(item.components.ammunition.ammotype == self.ammotype) and
			((item.components.ammunition.ammovalue + self.currentammo) <= self.maxammo) and
			((self.onacceptfn and self.onacceptfn(item)) or true)
end

-- Handles loading ammunition and removing item.
function Reloadable:TakeAmmoItem(item)
	if self:CanAcceptItem(item) then
		print("Acceptable?")
		-- Check if item is a stack and if so, get single instance.
		if item.components.stackable then
			item = item.components.stackable:Get(1)
		end
	
		-- Increase current ammunition by item's ammunition value.
		self:DoDelta(item.components.ammunition.ammovalue)
		
		-- Call loaded callback of item.
		if item.components.ammunition then
			item.components.ammunition:Loaded(self.inst)
		end		
		item:Remove()
		
		if self.onreloadedfn then
			self.onreloadedfn(self.inst, item)
		end
		
		return true
	end
end

-- Returns percentage value of current ammunition.
function Reloadable:GetPercent()
    return self.maxammo > 0 and math.max(0, math.min(1, self.currentammo / self.maxammo)) or 0
end

-- Sets ammunition ammount by percentage.
function Reloadable:SetPercent(amount)
    local target = (self.maxammo * amount)
    self:DoDelta(target - self.currentammo)
end

-- Initializes the ammunition amount.
function Reloadable:InitializeAmmo(value)
    if self.maxammo < value then
        self.maxammo = value
    end
    self.currentammo = value
end

function Reloadable:DoDelta(amount)

    self.currentammo = math.max(0, math.min(self.maxammo, self.currentammo + amount) )

	if self.currentammo <= 0 and self.ondepletedfn then
		self.ondepletedfn(self.inst)
	end

    self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
end

return Reloadable
local function OnAmmoType(self, ammotype, old_ammotype)
    if old_ammotype ~= nil then
        self.inst:RemoveTag(old_ammotype.."_ammo")
    end
    if ammotype ~= nil then
        self.inst:AddTag(ammotype.."_ammo")
    end
end

local Ammunition = Class(function(self, inst)
    self.inst = inst
    self.ammovalue = 1
    self.ammotype = AMMUNITIONTYPE.DART
    self.onloadedfn = nil
end,
nil,
{
    ammotype = OnAmmoType,
})

function Ammunition:OnRemoveFromEntity()
    if self.ammotype ~= nil then
        self.inst:RemoveTag(self.ammotype.."_ammo")
    end
end

function Ammunition:SetOnLoadedFn(fn)
    self.onloadedfn = fn
end

function Ammunition:Loaded(loader)
    self.inst:PushEvent("ammoloaded", {loader = loader})
    if self.onloadedfn then
        self.onloadedfn(self.inst, loader)
    end
end

return Ammunition
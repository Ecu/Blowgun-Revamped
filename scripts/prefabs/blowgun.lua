-- Image and Animation Assets for blowgun.
local assets =
{
	-- Animations.
    Asset("ANIM", "anim/blowgun.zip"),
    Asset("ANIM", "anim/swap_blowgun.zip"),
 
	-- Inventory images.
    Asset("ATLAS", "images/inventoryimages/blowgun.xml"),
    Asset("IMAGE", "images/inventoryimages/blowgun.tex")
}

-- Load additional Prefabs, just in case.
local prefabs = TUNING.BLOWGUN_REVAMPED.DARTS

-- Reduces ammo count by one.
local function DepleteAmmo(inst, owner, target)
	inst.components.reloadable:DoDelta(-1)
end

-- Make Blowgun a weapon with the correct projectile type, based on the type loaded.
local function MakeWeapon(inst)
	if inst.currentdart then
		inst:AddComponent("weapon")
		inst.components.weapon:SetDamage(0)
		inst.components.weapon:SetRange(TUNING.BLOWGUN_REVAMPED.BLOWGUN_RANGE, TUNING.BLOWGUN_REVAMPED.BLOWGUN_RANGE + 2)
		inst.components.weapon:SetProjectile(inst.currentdart)
		inst.components.weapon:SetOnProjectileLaunch(DepleteAmmo)
	end
	return false
end

-- Use 'percentusedchange' to determine if blowgun can be fired or not.
local function OnPercentChange(inst, data)
	if inst.components.reloadable:IsDepleted() then
		if inst.components.weapon then
			--inst:AddTag("nopunch")
			inst:RemoveComponent("weapon")
		end
	else
		if inst.components.weapon == nil then
			--inst:RemoveTag("nopunch")
			MakeWeapon(inst)
		end
	end
end

-- Show blowgun weapon on the symbol on the hand, then switch to holding animation.
local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_blowgun", "swap_blowgun")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

-- Remove blowgun weapon from the symbol on the hand, and switch to normal animation.
local function OnUnequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function OnLoad(inst, data)
	if data.currentdart then
		inst.currentdart = data.currentdart
	end
	OnPercentChange(inst)
end

local function OnSave(inst, data)
	if inst.currentdart then
		data.currentdart = inst.currentdart
	end
end

local function OnReload(inst, item)
	inst.currentdart = item.prefab
	inst.components.inventoryitem:ChangeImageName("blowgun_"..inst.currentdart)
	OnPercentChange(inst)
end

local function OnDepleted(inst)
	inst.currentdart = nil
	inst.components.inventoryitem:ChangeImageName("blowgun")
end

-- Blowgun Definition / Initialization
local function fn()

    local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("blowgun")
	inst.AnimState:SetBuild("blowgun")
	inst.AnimState:PlayAnimation("idle")
	
	inst.entity:SetPristine()
	
	inst:AddTag("reloadable")
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst.currentdart = nil
	
    inst:AddComponent("inspectable")
     
	inst:AddComponent("reloadable")
	inst.components.reloadable:InitializeAmmo(1)
	inst.components.reloadable:MakeEmpty()
	inst.components.reloadable:SetReloadedFn(OnReload)
	inst.components.reloadable:SetDepletedFn(OnDepleted)
	inst:ListenForEvent("percentusedchange", OnPercentChange)
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "blowgun"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/blowgun.xml"
	
	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
		
	MakeWeapon(inst)
	
	MakeHauntableLaunch(inst)
	
	inst.OnLoad = OnLoad
	inst.OnSave = OnSave
	
    return inst
end

return  Prefab("blowgun", fn, assets, prefabs)
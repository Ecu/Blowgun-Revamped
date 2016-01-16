-- Image and Animation Assets for fire dart.
local assets =
{
	-- Animations.
    Asset("ANIM", "anim/fire_dart.zip"),
	
	-- Inventory images.
	Asset("ATLAS", "images/inventoryimages/fire_dart.xml"),
    Asset("IMAGE", "images/inventoryimages/fire_dart.tex"),
}

-- Load additional Prefabs, just in case.
local prefabs =
{
	"impact"
}

-- On a hit, hit the target and damage it.  Remove dart afterwards.
local function OnHit(inst, owner, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if owner ~= nil then
            impactfx:FacePoint(owner.Transform:GetWorldPosition())
			target.components.combat:GetAttacked(owner, TUNING.BLOWGUN_REVAMPED.FIRE_DART_DAMAGE)
        end
    end
	inst:Remove()
end

-- On a miss, spawn the dart for pickup.  Remove projectile dart afterwards.
local function OnMiss(inst, owner, target)
	local dart = SpawnPrefab("fire_dart")
	if dart then
		local x, y, z = inst.Transform:GetWorldPosition()
		dart.Transform:SetPosition(x, y, z)
	end
	inst:Remove()
end

-- Orient the dart so that it looks correct.
local function OnThrown(inst, data)	
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

-- Handle animation of dart.
local function DartThrown(inst)
	inst:AddTag("NOCLICK")
	inst.persists = false
	inst.AnimState:PlayAnimation("projectile")
end

-- Fire Darat Definition / Initialization
local function fn()
 
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	
	inst.AnimState:SetBank("fire_dart")
	inst.AnimState:SetBuild("fire_dart")	
	inst.AnimState:PlayAnimation("idle")	
	
	inst.entity:SetPristine()	
	
	inst:AddTag("projectile")
	inst:AddTag("ammunuition")
	
	if not TheWorld.ismastersim then
		return inst
	end
     
	-- Make dart inspectable.
    inst:AddComponent("inspectable")
    
	-- Make dart an inventory item.
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "fire_dart"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/fire_dart.xml"
	
	-- Handle stack size.
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	-- Make dart into ammunition.
	inst:AddComponent("ammunition")	
	
	-- Make dart a projectile.
	inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.BLOWGUN_REVAMPED.FIRE_DART_SPEED)
    inst.components.projectile:SetHoming(TUNING.BLOWGUN_REVAMPED.FIRE_DART_HOMING)
    inst.components.projectile:SetRange(TUNING.BLOWGUN_REVAMPED.BLOWGUN_RANGE)
	
	-- Handle dart actions.
	inst.components.projectile:SetOnHitFn(OnHit)
	inst.components.projectile:SetOnMissFn(OnMiss)
	inst.components.projectile:SetOnThrownFn(OnThrown)
	inst:ListenForEvent("onthrown", DartThrown)
 
	MakeHauntableLaunch(inst)
 
    return inst
end

return Prefab("fire_dart", fn, assets)
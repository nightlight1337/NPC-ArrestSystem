AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/Barney.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:CapabilitiesAdd(CAP_TURN_HEAD)
	self:DropToFloor()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end
end

function ENT:PlayerUse(pl)
	for id, v in pairs(ArrestNPC.ArrestNow) do
		local checkpl = player.GetByID(id)
		if not IsValid(checkpl) then ArrestNPC.ArrestNow[id] = nil end
	end

	net.Start("ArrestNPC.UnMenu")
	net.WriteTable(ArrestNPC.ArrestNow)
	net.Send(pl)
end

function ENT:AcceptInput(name, activator, pl, data)
	if name == "Use" then self:PlayerUse(pl) end
end
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
	local arrpl = ArrestNPC.GetHandcuffPlayer(pl)
	if IsValid(arrpl) then
		net.Start("ArrestNPC.Menu")
		net.WriteEntity(arrpl)
		net.Send(pl)
	else
		pl:ChatPrint("No one to arrest.")
	end
end

function ENT:AcceptInput(name, activator, pl, data)
	if name == "Use" then self:PlayerUse(pl) end
end
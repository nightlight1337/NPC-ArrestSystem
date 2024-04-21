include("shared.lua")
local NPCText = "UnArrest - NPC"
local COL_TEXT = Color(255, 255, 255)
local FONT = "ArrestNPC.Main"
local function textPlate(text, y)
	surface.SetFont(FONT)
	local tw = surface.GetTextSize(text)
	surface.SetTextColor(COL_TEXT)
	surface.SetTextPos(-tw / 2, y)
	surface.DrawText(text)
end

local function drawInfo(ent, text)
	local head = (ent:GetPos() - EyePos()):Angle().yaw - 90
	local center = ent:LocalToWorld(ent:OBBCenter())
	cam.Start3D2D(center + Vector(0, 0, 44), Angle(0, head, 90), 0.13)
	textPlate(text, 15)
	cam.End3D2D()
	surface.SetAlphaMultiplier(1)
end

function ENT:Draw()
	self:DrawModel()
	drawInfo(self, NPCText)
end
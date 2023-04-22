if !LinvFriends then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(LinvFriends.Config.NPC_Model)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
    self:DropToFloor()
end

function ENT:Use(ply)
    net.Start("LinvFriends")
        net.WriteUInt(4, 8)
    net.Send(ply)
end
include("shared.lua")

function ENT:Draw()
	self:DrawModel()
    LinvLib:DrawNPCText(self, LinvFriends.Config.NPC_Name, LinvFriends.Config.NPC_Height)
end
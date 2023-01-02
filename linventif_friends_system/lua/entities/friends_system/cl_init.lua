include("shared.lua")

function ENT:Draw()
	if not IsValid(self) or not IsValid(LocalPlayer()) then return end

	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Forward(), 85)

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 40000 then
		cam.Start3D2D(pos + ang:Up()*0, Angle(0,LocalPlayer():EyeAngles().y-90, 90), 0.025)

			draw.RoundedBox(16, -500, -3125, 1000, 220, FriendsSys.Config.Color["border"])
            draw.RoundedBox(16, -480, -3105, 960, 180, FriendsSys.Config.Color["background"])

			draw.SimpleText(FriendsSys.Config.NPCName, "LinvFontResp01", 0, -3085, FriendsSys.Config.Color["text"], TEXT_ALIGN_CENTER)

		cam.End3D2D()
	end
end
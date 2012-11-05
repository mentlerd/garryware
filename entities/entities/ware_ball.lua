
AddCSLuaFile()

ENT.Type	= "anim"
ENT.Size	= 24

if ( SERVER ) then

	function ENT:Initialize()
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		self:PhysicsInitSphere( self.Size, "metal_bouncy" )
	
		self:PhysWake()
	end
	
	function ENT:PhysicsCollide( data, physobj )
	
		if ( data.Speed > 80 and data.DeltaTime > 0.2 ) then
			self:EmitSound( "Rubber.BulletImpact" )
		end
	
		local ware = GAMEMODE.Ware
		
		if ( ware and ware.BallHitEntity and IsValid( data.HitEntity ) ) then
			ware:SafeCall( ware.BallHitEntity, self, data.HitEntity )
		end
		
		local speed = math.max( data.OurOldVelocity:Length(), data.Speed )
		local vel	= physobj:GetVelocity():GetNormalized()
		
		physobj:SetVelocity( vel * speed )
	end

else

	ENT.RenderGroup	= RENDERGROUP_TRANSLUCENT
	
	local sprite	= Material( "sprites/sent_ball" )
	
	function ENT:Draw()
		local pos = self:GetPos()
		local vel = self:GetVelocity()
				
		render.SetMaterial( sprite )
		
		local color = self:GetColor()
		
		if ( vel:Length() > 1 ) then
			for index = 1, 8 do
				color.a = ( 200 / index )
				render.DrawSprite( pos + vel * ( index * -0.001 ), self.Size *2, self.Size *2, color )
			end
		end
		
		color.a = 255
		render.DrawSprite( pos, self.Size *2, self.Size *2, color )	
	end

end
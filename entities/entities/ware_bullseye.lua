
AddCSLuaFile()

ENT.Type 	= "anim"
ENT.Size	= 32

ENT.GravGunBlocked = true

if ( SERVER ) then

	ENT.Speed	= 16

	function ENT:Initialize()
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		
		self:PhysicsInitSphere( self.Size, "metal_bouncy" )
		
		local phys = self:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:EnableGravity( false )
			phys:Wake()
		end
	end

	function ENT:PhysicsCollide( data, phys )

		if ( data.Speed > 80 and data.DeltaTime > 0.2 ) then
			self:EmitSound( "Rubber.BulletImpact" )
		end
		
		local ware = GAMEMODE.Ware
		if ( ware and ware.TargetCollide ) then
			ware:SafeCall( ware.TargetCollide, self, data, phys )
		end

		local speed = math.max( data.OurOldVelocity:Length(), data.Speed )
		local vel	= phys:GetVelocity():GetNormalized()
		
		if ( self.Speed ) then
			phys:SetVelocity( vel * self.Speed )
		else
			phys:SetVelocity( vel * speed * 0.85 )
		end
	end

	function ENT:Think()	
		if ( self.Speed ) then
			local phys = self:GetPhysicsObject()
			
			local vel	= phys:GetVelocity()
			local speed	= vel:Length()
			
			if ( speed < self.Speed ) then
				vel = vel:GetNormalized() * self.Speed * 1.5
				
				phys:SetVelocity( vel )
			end
		end
	end
	
	function ENT:OnTakeDamage( dmginfo )
		dmginfo:SetDamageForce( dmginfo:GetDamageForce() * 0.1 )
		self:TakePhysicsDamage( dmginfo )
		
		local ply	= dmginfo:GetAttacker()
		local ware 	= GAMEMODE.Ware
	
		if ( ware and ware.TargetHit and IsValid( ply ) and ply:IsPlayer() ) then
			ware:SafeCall( ware.TargetHit, ply )
		end
	end

else

	ENT.RenderGroup	= RENDERGROUP_TRANSLUCENT
	ENT.Sprite		= Material( "ware/sprites/bullseye.png", MAT_SMOOTH )
	
	function ENT:Draw()
		local pos = self:GetPos()
		local vel = self:GetVelocity()
				
		render.SetMaterial( self.Sprite )
		
		if ( vel:Length() > 1 ) then
			local color = Color( 0, 0, 0 )
			
			for index = 1, 10 do
				color.a = ( 200 / index )
				render.DrawSprite( pos + vel * ( index * -0.001 ), self.Size *2, self.Size *2, color )
			end
		end
		
		render.DrawSprite( pos, self.Size *2, self.Size *2, self:GetColor() )	
	end

end

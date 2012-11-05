
AddCSLuaFile()

ENT.Type = "anim"

if ( SERVER ) then

	function ENT:Initialize()
		self:SetModel("models/weapons/w_crowbar.mdl")
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
		
		local phys = self:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:EnableDrag( true )
			
			phys:SetMass( 80 )
			phys:SetMaterial( "crowbar" )
			
			phys:AddAngleVelocity( VectorRand() * 600 )
			phys:Wake()
		end
		
		GAMEMODE:AddToTrash( self )
	end

	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
	end

	function ENT:PhysicsCollide( data, physobj )
		if ( data.Speed > 50 and data.DeltaTime > 0.2 ) then
			self:EmitSound( "Weapon_Crowbar.Melee_HitWorld", data.Speed/2 )
		end
		
		local hitEntity = data.HitEntity
		
		if ( data.Speed > 512 and IsValid( hitEntity ) ) then
			if ( hitEntity:IsPlayer() or hitEntity:IsNPC() ) then
			   self:EmitSound( "weapons/hitbod1.wav", data.Speed *1.5 )
			end
		end
	end

end
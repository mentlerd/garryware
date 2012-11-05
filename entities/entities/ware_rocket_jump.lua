
AddCSLuaFile()

ENT.Type	= "anim"
ENT.Base	= "base_anim"

if ( SERVER ) then
	
	function ENT:Initialize()
		self:SetModel("models/Weapons/W_missile_launch.mdl")
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
		
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:EnableDrag( true )
			
			phys:SetMass( 80 )
			phys:SetMaterial( "crowbar" )
			
			phys:Wake()
		end
	end
	
	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
	end

	function ENT:PhysicsCollide( coll, physobj )
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
		
		local pos = self:GetPos()
		local hit = coll.HitPos
				
		local data = EffectData( )
			data:SetOrigin( pos + coll.HitNormal * 16 )
			data:SetNormal( (pos - hit):GetNormalized() )
		util.Effect( "ware_explosion", data )

		for index, ply in pairs( ents.FindInSphere( hit, 60 ) ) do
			if ( ply:IsPlayer() and ply == self:GetOwner() ) then
				ply:SetVelocity( ply:GetAimVector() * -500, 0 )
				break
			end
		end
		
		self:Remove()
	end 

end


AddCSLuaFile()

SWEP.Base			= "gmdm_base"
SWEP.PrintName		= "WARE Rocketjump"

SWEP.Slot			= 1
SWEP.SlotPos		= 0

SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true

SWEP.ViewModel		= "models/weapons/v_rpg.mdl"
SWEP.WorldModel		= "models/weapons/w_rocket_launcher.mdl"

SWEP.HoldType = "rpg"

SWEP.ShootSound = Sound( "npc/env_headcrabcanister/launch.wav" )

SWEP.RunArmAngle  = Angle( -20, 0, 0 )
SWEP.RunArmOffset = Vector( 0, -4, 0 )

SWEP.Delay = 0.75
SWEP.TickDelay = 0.1

SWEP.ProjectileEntity = "ware_rocket_jump"
SWEP.ProjectileForce = 5000000

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Delay )
	self:SetNextSecondaryFire( CurTime() + self.TickDelay )
	
	if ( !self:CanShootWeapon() ) then return end
	
	self:EmitSound( self.ShootSound )
	
	if ( SERVER ) then
		self:ShootRocket( self.ProjectileForce )
	end
end


if ( SERVER ) then
	
	function SWEP:ShootRocket( shotPower )		
		local owner = self.Owner
		
		if ( !IsValid( owner ) ) then return end
		
		local ent = ents.Create( self.ProjectileEntity )	
			ent:SetPos( owner:GetShootPos() )
			ent:SetAngles( owner:EyeAngles() )
		
			ent:SetOwner( owner )
			ent:Spawn()
		
		ent:Trail( "trails/tube.vmt", Color( 255, 255, 255, 255 ), 8, 0, 0.2 )
		
		local phys = ent:GetPhysicsObject()
			phys:ApplyForceCenter( owner:GetAimVector():GetNormalized() * shotPower )
	end
	
end

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:SecondaryAttack()
end

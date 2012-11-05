
AddCSLuaFile()

GMDMLastShoot = 0

SWEP.ViewModelFOV	= 55

SWEP.CustomSecondaryAmmo 	= false
SWEP.Primary.Ammo 			= "Buckshot"

SWEP.HoldType 			= "smg"

SWEP.AllowRicochet 		= true
SWEP.AllowPenetration 	= true

SWEP.PenetrationMax 		= 32
SWEP.PenetrationMaxWood 	= 128
SWEP.MaxRicochet 			= 1
SWEP.ImpactEffects 			= true

SWEP.CanSprintAndShoot = false

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )	
end

SWEP.SprayTime 		= 0.1
SWEP.SprayAccuracy 	= 0.5

function SWEP:GetStanceAccuracyBonus()
	local owner = self.Owner
	
	if( owner:IsNPC() ) then 
		return 0.8
	end
	
	if( self.ConstantAccuracy ) then
		return 1.0
	end
	
	local last = self.LastAccuracy or 0
	local accuracy = 1.0
	
	local lastShoot = GMDMLastShoot
	
	local speed = self.Owner:GetVelocity():Length()
	local speedperc = math.Clamp( math.abs( speed / 705 ), 0, 1 )	
	
	if( CurTime() <= lastShoot + self.SprayTime ) then
		accuracy = accuracy * self.SprayAccuracy
	end
	
	if( speed > 10 ) then
		accuracy = accuracy * ( 1.1 - speedperc ) / 1.5
	end
	
	if( owner:KeyDown( IN_DUCK ) ) then
		accuracy = accuracy * 1.75
	end

	if( owner:KeyDown( IN_LEFT ) or owner:KeyDown( IN_RIGHT ) ) then
		accuracy = accuracy * 0.95
	end
	
	if( last != 0 ) then
		local speed = FrameTime() *2
	
		if( accuracy > last ) then
			accuracy = math.Approach( last, accuracy,  speed )
		else
			accuracy = math.Approach( last, accuracy, -speed )
		end
	end
	
	self.LastAccuracy = accuracy
	return accuracy
end

function SWEP:GMDMShootBullet( dmg, sound, pitch, yaw, num, cone )
	num 	= num	or 1
	cone 	= cone 	or 0.01
	
	local owner = self.Owner
	
	if( owner and owner:IsPlayer() ) then
		owner:SetNetworkedInt( "BulletType", 0 )
	end
	
	if( self.GMDMShootBulletEx ) then
		self:GMDMShootBulletEx( dmg, num, cone, 1 )
	end
	
	if ( !IsFirstTimePredicted() ) then return end

	if( sound != nil ) then
		self.Weapon:EmitSound( sound )
	end

	if( owner and owner:IsPlayer() ) then
		--owner:Recoil( pitch, yaw )
	end
	
	local data = EffectData()
		data:SetOrigin( owner:GetShootPos() )
		data:SetStart( owner:GetShootPos() )
		data:SetNormal( owner:GetAimVector() )
		
		data:SetEntity( self.Weapon )
		data:SetAttachment( 1 )
	util.Effect( "GMDM_GunSmoke", data )
	
	self:NoteGMDMShot()
end

function SWEP:RicochetCallback( bouncenum, attacker, tr, dmginfo )
	if ( tr.HitSky ) then return end
	
	local doDefault = !tr.HitWorld

	if ( tr.MatType != MAT_METAL ) then
		if ( tr.MatType != MAT_FLESH and self.ImpactEffects ) then
		
			local data = EffectData()
				data:SetOrigin( tr.HitPos )
				data:SetNormal( tr.HitNormal )
				
				data:SetScale( dmginfo:GetDamage() / 10000 )
			util.Effect( "GMDM_HitSmoke", data )
		
			if ( SERVER ) then
				util.ScreenShake( tr.HitPos, 100, 0.2, 1, 128 )
			end
		end
		
		return
	end

	if ( !self.AllowRiochet ) then
		return {
			damage	= true,
			effects	= doDefault
		}
	end
	
	if ( bouncenum > self.MaxRicochet ) then return end
	
	-- Bounce vector (Don't worry - I don't understand the maths either :x)
	local DotProduct = tr.HitNormal:Dot( tr.Normal * -1 )
	local Dir = ( 2 * tr.HitNormal * DotProduct ) + tr.Normal
	Dir:Normalize()
	
	local bullet = {	
		Damage		= damage,
		Force		= 5,
		Num 		= 1,
		
		Tracer		= 1,
		TracerName 	= "GMDM_RicochetTrace",
		
		Dir 		= Dir,	
		Spread 		= Vector( 0.05, 0.05, 0 ),
		Src 		= tr.HitPos,
		
		AmmoType 	= "Pistol",
		HullSize	= 2
	}
	
	function bullet.Callback( dmgInfo, hitPos, dir )
		if ( self.RiochetCallback ) then
			self:RiochetCallback( bouncenum +1, dmgInfo, hitPos, dir )
		end
	end
	
	timer.Simple( 0.05, function()
		attacker:FireBullets( bullet )
	end )

	attacker:SetNetworkedInt( "BulletType", 2 )
	
	return { 
		damage = true, 
		effects = doDefault
	}	
end

function SWEP:WeaponKilledPlayer( pl, dmginfo )
	Msg( "[GMDM] Weapon " .. self:GetClass() .. " owned by " .. self:GetOwner():Name() .. " killed player " .. pl:Name() .. "\n" )
end

function SWEP:NoteGMDMShot()
	GMDMLastShoot = CurTime()
	
	-- No prediction in SP. Make sure it knows when we last shot.
	if ( game.SinglePlayer() ) then
		self.Owner:SendLua( "GMDMLastShoot = CurTime()" )
	end
end

function SWEP:Reload()
	local canReload = self.Weapon:DefaultReload( ACT_VM_RELOAD )
	
	if ( canReload and self.Weapon.CustomReload ) then
		self.Weapon:CustomReload()
	end
end

function SWEP:CanShootWeapon()

	if ( self.Owner:IsNPC() ) then
		return true
	end
	
	if ( !self.CanSprintAndShoot ) then
		if ( self.Owner:KeyDown( IN_RELOAD ) ) then return false end
		if ( self.LastSprintTime and CurTime() - self.LastSprintTime < 0.1 ) then return false end
	end
	
	return true
end

function SWEP:Think()
	
	if ( self.Owner and self.Owner:KeyDown( IN_RELOAD ) ) then
		self.LastSprintTime = CurTime()
	end

end

function SWEP:GMDMShootBulletEx( damage, num, aimcone, tracerfreq )
	local owner	= self.Owner
	
	if( self.SupportsSilencer and self.Weapon:GetNetworkedBool( "Silenced", false ) == true ) then
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
	else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end

	owner:SetAnimation( PLAYER_ATTACK1 )
	owner:MuzzleFlash()

	if ( !IsFirstTimePredicted() ) then return end

	local bullet = {
		Damage		= damage,
		Force		= 10,
		Num 		= num,
		
		Tracer		= tracerfreq,
		TracerName 	= "Tracer",
		
		Dir 		= owner:GetAimVector(),	
		Spread 		= Vector( aimcone, aimcone, 0 ),
		Src 		= owner:GetShootPos(),
		
		AmmoType 	= "Pistol",
		HullSize	= 4
	}
	
	function bullet.Callback( dmgInfo, hitPos, dir )
		self:RicochetCallback( 0, dmgInfo, hitPos, dir )
	end
	
	owner:FireBullets( bullet )
end

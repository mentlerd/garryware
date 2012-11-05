
AddCSLuaFile( "cl_init.lua" )
include('shared.lua')

function SWEP:GetCapabilities()
	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1, CAP_WEAPON_RANGE_ATTACK2, CAP_INNATE_RANGE_ATTACK2 )
end

function SWEP:NPCShoot_Secondary( ShootPos, ShootDir )
	self:PrimaryAttack()
end

function SWEP:Deploy()

	-- If it's silenced, we need to play a different anim.
	if( self.SupportsSilencer and self:GetNetworkedBool( "Silenced" ) == true ) then
		self:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
	else
		self:SendWeaponAnim( ACT_VM_DRAW )
	end

	return true
end 

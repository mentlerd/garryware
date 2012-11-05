WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_FRENZY

WARE.Windup	= 0.7
WARE.Length	= 6

WARE.BoxRatio	= 0.7

WARE.Models = { 
	"models/props_junk/wood_crate001a.mdl" 
}

function WARE:Initialize()
	self:Instruction( "Be useful!" )
end

function WARE:StartAction()
	self:Instruction( "Break all crates!" )

	self.BoxCount = self:PlayerRatio( self.BoxRatio, 2, 64 )
	
	local points = self:GetRandomFilterBox( self.BoxCount, ONCRATE, IsPlayer, 30 )
	local offset = Vector( 0, 0, 32 )
	
	for _, point in pairs( points ) do
		local ent = point:SpawnProp( self.Models[1], offset )	
			ent:RandomYaw()
			ent:SetHealth( 15 )
		
		ent.IsGoal = true
	end

	self:GiveAll( "weapon_crowbar" )	
end

function WARE:EndAction()
	if ( self.BoxCount > 0 ) then
		self:ApplyAll( false, true )
	end
end

function WARE:PropBreak( killer, prop )
	if ( !prop.IsGoal ) then return end
	
	self.BoxCount = self.BoxCount -1
	
	if ( killer:IsPlayer() ) then
		killer:ApplyState( true )
	end
	
	if ( self.BoxCount <= 0 ) then
		self:ForceEnd()
	end
end

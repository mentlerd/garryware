WARE.Author = "Kilburn"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= { AWARD_FRENZY, AWARD_MOVES }

WARE.Windup	= 2
WARE.Length = 14

WARE.Models = {
	"models/props_junk/sawblade001a.mdl",
	"models/props_lab/blastdoor001b.mdl"
}
 
WARE.Ratio			= 0.75
WARE.RespawnTime	= 1.7

function WARE:Initialize()
	self:Instruction( "Punt a sawblade to freeze it..." , Color(0,0,0) )
	
	local points = self:GetPoints( ONCRATE )
	local offset = Vector( 0, 0, 20 )
	
	for _, point in pairs( points ) do
		local saw = point:SpawnProp( self.Models[1], offset )
			saw.SpawnPos = saw:GetPos()
	end
	
	self:GiveAll("weapon_physcannon")
end

function WARE:StartAction()
	self:Instruction( "Get up there!" )
	
	local count  = self:PlayerRatio( self.Ratio, 1, 16 )
	local points = self:GetRandomPoints( count, AIR )
	
	local offset = Vector( -50, 0, 20 )
	
	for _, point in ipairs( points ) do
		local platform = point:SpawnProp( self.Models[2], offset )
			platform:EnableMotion( false )
			
			platform:SetAngles( Angle( 90, 0, 0 ) )
			platform:SetColor( Color( 255, 0, 0 ) )
			
		platform.IsGoal = true
	end

end

function WARE:Think()
	for _, ply in pairs( self:GetPlayers() ) do
		local ground = ply:GetGroundEntity()
		
		if ( IsValid( ground ) and ground.IsGoal ) then
			ply:ApplyWin()
		end
	end
end

function WARE:GravGunPunt( ply, prop )
	if ( !ply:IsPlayer() ) then return end
	
	if ( !prop.IsStuck and !prop.IsGoal ) then
		prop:EnableMotion( false )
		prop.IsStuck = true
		
		prop:EmitSound( "doors/vent_open3.wav" )
		prop:GetPos():Effect( "ware_disappear" )
		
		timer.Simple( self.RespawnTime, function()
			if ( !self.IsPlaying or !IsValid( prop ) ) then return end
			
			local saw = prop.SpawnPos:SpawnProp( self.Models[1] )
				saw.SpawnPos = prop.SpawnPos
		end )
	end
end

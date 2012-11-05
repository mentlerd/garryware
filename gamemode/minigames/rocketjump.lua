WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_PLAIN 
WARE.Award	= AWARD_MOVES

WARE.Windup	= 1
WARE.Length	= 9

WARE.InitialStatus	= false

WARE.Ratio	= 0.3

WARE.Models = {
	"models/props_lab/blastdoor001b.mdl"
}

function WARE:Initialize()
	self:Instruction( "Look up!" )
end

function WARE:StartAction()
	self:Instruction( "Rocketjump onto a plate!" )	
	self:GiveAll( "ware_rocketjump" )
	
	local count  = self:PlayerRatio( self.Ratio, 1, 64 )
	local points = self:GetRandomPoints( count, AIR )
		
	for _, point in pairs( points ) do
		local prop = point:SpawnProp( self.Models[1] )
			prop:EnableMotion( false )
			
			prop:SetAngles( Angle(90, 0, 0 ) )
			prop:SetColor( Color( 255, 0, 0 ) )
			
		prop.IsGoal = true
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

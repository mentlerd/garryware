WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID

WARE.Windup	= 1.5
WARE.Length	= 8

WARE.InitialState	= true

WARE.BallColor	= Color( 250, 250, 0 )
WARE.Ratio		= 1.1

function WARE:Initialize()
	self:Instruction( "Dodge!" )	
	self:GiveAll( "weapon_physcannon" )
end

function WARE:StartAction()
	
	local count  = self:PlayerRatio( self.Ratio, 3, 64 )
	local points = self:GetRandomPoints( count, AIR )
	
	for _, point in pairs( points ) do
		local ball = point:MakeEntity( "ware_ball" )
			ball:SetColor( self.BallColor )
			ball:Spawn()
		
		local phys = ball:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:ApplyForceCenter( VectorRand() * 512 )
		end
	end
end

function WARE:BallHitEntity( ball, ply )
	if ( !ply:IsPlayer() ) then return end

	ply:ApplyLose()
end

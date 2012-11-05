WARE.Author = "Kelth"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_FRENZY

WARE.Windup	= 0.8
WARE.Length	= 6

WARE.Ratio	= 0.5

WARE.UnusableColor	= Color( 230, 135, 135 )

function WARE:Initialize()
	self:Instruction( "Catch a white!" )
	
	local count  = self:PlayerRatio( self.Ratio, 1, 64 )
	local points = self:GetRandomPoints( count, AIR )
	
	for _, point in pairs( points ) do
		local ball = point:MakeEntity( "ware_ball")
			ball:Spawn()
			
		local phys = ball:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:ApplyForceCenter (VectorRand() * 1024)
		end
		
		ball.IsGoal = true
	end

end

function WARE:StartAction()
	self:GiveAll( "weapon_physcannon" )	
end

function WARE:GravGunOnPickedUp( ply, ball )
	if ( !ball.IsGoal ) then return end
	
	ply:ApplyWin()
	
	ball.IsGoal = false
	ball:SetColor( self.UnusableColor )
end

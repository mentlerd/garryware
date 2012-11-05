WARE.Author = "Hurricaaane (Ha3)"

WARE.Room = ROOM_PLAIN

WARE.Windup	= 2
WARE.Length	= 1.4

WARE.InitialStatus	= false

function WARE:Initialize()
	self.OnGround	= math.random( 1, 10 ) <= 3		
	
	if ( self.OnGround ) then
		self.TargetZ	= self:GetRandomPoints( 1, FLOOR )[1].z +10
	else
		self.TargetZ	= self:GetRandomPoints( 1, AIR )[1].z -10
	end

	self:Instruction( "When the clock reaches zero... " )
end

function WARE:StartAction()
	if ( self.OnGround ) then
		self:Instruction( "Stay on the ground!" )	
	else
		self:Instruction( "Be high in the air!" )
	end
	
	self:GiveAll( "ware_rocketjump" )	
end

function WARE:Think()
	for _, ply in pairs( self:GetPlayers() ) do
		local zPos = ply:GetPos().z
	
		if ( self.OnGround ) then
			ply:ApplyState( zPos < self.TargetZ )
		else
			ply:ApplyState( zPos > self.TargetZ )
		end
	end
end

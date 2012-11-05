WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_ANY
WARE.Award	= { AWARD_AIM, AWARD_REFLEX }

WARE.Windup	= 1.5
WARE.Length	= 8

WARE.Velocity 	= 128
WARE.Ratio		= 0.3

function WARE:Initialize()
	self.TimesToHit = math.random( 3,5 )
	
	for _, ply in pairs( self:GetPlayers() ) do
		ply.BullseyeHit = 0
	end
	
	self:Instruction( "Hit the bullseye exactly "..self.TimesToHit.." times!" )
	self:GiveAll( "ware_pistol" )	
end

function WARE:StartAction()	
	local count		= self:PlayerRatio( self.Ratio, 1, 64 )
	local points	= self:GetRandomPoints( count, AIR )
	
	self.Bullseyes = {}
	
	for index, point in pairs( points ) do
		local ent = point:MakeEntity("ware_bullseye")
			ent.Speed = self.Velocity
			ent:Spawn()
			
		local phys = ent:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:ApplyForceCenter(VectorRand() * 16)
			phys:Wake()
		end
	end
end

function WARE:TargetHit( ply )
	ply.BullseyeHit = ply.BullseyeHit +1
end

function WARE:Think()
	for _, ply in pairs( self:GetPlayers() ) do
		local times = ply.BullseyeHit or 0
		
		if ( times == self.TimesToHit ) then
			ply:ApplyState( true )
		elseif ( times > self.TimesToHit ) then
			ply:ApplyLose()
		end
	end	
end

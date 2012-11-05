WARE.Author = "Frostyfrog"

WARE.Room = ROOM_ANY

WARE.Windup	= 2.5
WARE.Length	= 5

WARE.InitialState	= true
WARE.DieOnLose		= true

WARE.MaxSpeed = 320

function WARE:Initialize()
	self:Instruction( "Don't stop sprinting!" )
end

function WARE:Think()
	for k,ply in pairs( self:GetPlayers() ) do 
	
		if ( ply:GetVelocity():Length() < self.MaxSpeed * 0.8 ) then
			ply:ApplyLose()
		end
		
	end
end

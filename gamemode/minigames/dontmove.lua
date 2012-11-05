
WARE.Author = "Hurricaaane (Ha3)"
WARE.Room	= ROOM_BOXGRID

WARE.Windup	= 3.5
WARE.Length	= 2

WARE.InitialState	= true
WARE.DieOnLose		= true

function WARE:Initialize()
	self:Instruction( "Don't move!" )
end

function WARE:StartAction()
	self:GiveAll( "ware_crowbar" )
end

function WARE:Think()
	for _, ply in pairs( self:GetPlayers() ) do
	
		if ( ply:GetVelocity():Length() > 16 ) then	
			ply:ApplyLose()
		end

	end
end

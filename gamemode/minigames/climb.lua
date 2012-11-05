WARE.Author = "Kelth"
WARE.Room	= ROOM_BOXGRID

WARE.Windup	= 1.5
WARE.Length	= 3

function WARE:Initialize()
	self:Instruction( "Get on a box!" )
end

function WARE:StartAction()
	self:GiveAll( "ware_crowbar" )	
end

function WARE:Think()
	self:ApplyAll( false )
	
	local points = self:GetPoints( ONCRATE )
	
	for _, point in pairs( points ) do
		local box = point:FindInBox( Vector(-30,-30,0), Vector(30,30,64) )
		
		for _,target in pairs( box ) do
			if ( target:IsPlayer() ) then
				target:ApplyState( true )
			end
		end
	end
end

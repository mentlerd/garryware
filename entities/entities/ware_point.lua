
ENT.Base		= "base_point"

function ENT:Initialize()
	self:PhysicsInitSphere( 1 )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end


function ENT:KeyValue( key, value )
	local key = key:lower()
	
	if ( key == "pointclass" ) then
		self.PointClass = value
	end
end

function ENT:CommitPoints( map )
	local class = self.PointClass

	if ( !map[class] ) then
		map[class] = {}
	end

	table.insert( map[class], self:GetPos() )
end